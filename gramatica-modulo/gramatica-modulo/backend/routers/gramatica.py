"""Endpoints del módulo de Gramática (/gramatica/*): studentbook (reglas +
ejemplos por Fase/subtema) + workbook (ejercicios cloze/multiple choice
evaluados de forma determinista) -- ver memoria del proyecto para el
diseño completo (validado con Fable, 2 rondas, antes de codear).

Cero LLM/Whisper/Kokoro en el camino de request de studentbook/workbook:
todo el contenido y los ejercicios ya están sembrados en base (migraciones
029-032), y el audio se sirve tal cual desde CACHE_TTS_DIR (clave ya
calculada por scripts/generar_audio_gramatica.py) -- nunca se llama a
Kokoro acá, a diferencia de /vocabulario/audio o /audio-guia. Única
excepción documentada (Fase 3 del plan de dinamismo, ver memoria del
proyecto): POST /subtemas/{slug}/autoexplicacion, opt-in y de baja
frecuencia (una llamada por cierre de subtema), mismo criterio ya
aceptado en /vocabulario/generar-ejercicio."""
import json
import re
from datetime import date
from typing import Annotated, Literal

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field

from auth.port import SesionInfo
from dependencies import (
    CACHE_TTS_DIR,
    IMAGENES_GRAMATICA_DIR,
    db_conn,
    get_llm_adapter,
    identidad_id,
    logger,
    sesion_actual,
    verificar_limite_llm,
)
from gamificacion import (
    evaluar_evolucion_gusano,
    evaluar_insignias_periodo,
    otorgar_puntos,
    puntos_ejercicio,
    puntos_subtema_completado,
)
from gramatica import autoexplicacion
from motor_memoria import calcular_movimiento_caja, proxima_fecha_por_caja

# imagen_key/audio_key siempre son claves generadas por nosotros (nombre de
# archivo curado a mano o hash sha256) -- este patrón rechaza cualquier
# intento de path traversal (".."/"/") en vez de confiar en que nunca
# llegue un valor así por la URL.
_CLAVE_ARCHIVO_VALIDA = re.compile(r"^[a-zA-Z0-9_-]+$")

router = APIRouter(prefix="/gramatica", tags=["gramatica"])

_EJERCICIO_GRAMATICA_NO_ENCONTRADO = "Ejercicio no encontrado."
_SUBTEMA_NO_ENCONTRADO = "Subtema no encontrado."

# Hallazgo de Sonar (python:S1192): este SELECT se repetía igual en 3
# endpoints distintos para validar que el subtema exista antes de seguir.
_SQL_EXISTE_SUBTEMA = "SELECT 1 FROM gramatica_temas WHERE slug = $1 AND idioma = $2 AND parent_id IS NOT NULL"
_FASE_NO_ENCONTRADA = "Fase no encontrada o no habilitada para el Gusanito."

# El Gusanito (Fase 9 del plan de dinamismo, ver memoria del proyecto):
# arranca con 1-2 Fases habilitadas, no las 18 -- Fundamentos y Verbo to
# be/pronombres son las que ya tienen el banco de ejercicios más sólido
# (Fase 4 del plan las amplió primero). Ampliar esta lista es un paso
# posterior explícito, no un cambio de arquitectura.
_FASES_GUSANITO_HABILITADAS = {"fase-1-fundamentos", "fase-2-to-be-pronombres"}

# Umbral de "dominado" para un ejercicio dentro del Gusanito: caja 3 de 5
# (mitad del camino de Leitner) -- heurística inicial, no calibrada con
# datos reales todavía, mismo criterio que UMBRAL_RESPUESTA_RAPIDA_MS en
# motor_memoria.py.
_CAJA_DOMINADO_GUSANITO = 3


class _EvaluarEjercicioGramaticaBody(BaseModel):
    ejercicio_id: int
    respuesta_usuario: str
    # Ambas opcionales: un frontend viejo (o un llamado sin estas señales)
    # sigue funcionando -- se trata como "sin señal" en la tabla de
    # decisión, nunca rompe el flujo de evaluación existente.
    tiempo_respuesta_ms: int | None = None
    confianza: Literal["seguro", "creo", "adivine"] | None = None


class _CompletarSubtemaGramaticaBody(BaseModel):
    slug: str
    idioma: str = "en"


class _AutoexplicacionBody(BaseModel):
    # max_length: mismo endurecimiento contra abuso/DoS que MAX_TEXTO_CHARS
    # en dependencies.py -- una explicación de un párrafo alcanza, no hace
    # falta aceptar texto arbitrariamente largo hacia el LLM.
    explicacion: str = Field(min_length=1, max_length=500)


def _normalizar_respuesta_gramatica(texto: str) -> str:
    """Comparación tolerante: minúsculas, sin espacios de más, sin
    puntuación final -- mismo criterio que _normalizar_respuesta_vocab en
    routers/vocabulario.py (un punto final o una mayúscula de más no debe
    contar como respuesta incorrecta)."""
    return texto.strip().lower().rstrip(".!?")


@router.get("/fases")
async def fases_gramatica(sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en"):
    """Catálogo de las 18 Fases (gramatica_temas con parent_id NULL),
    ordenadas por prioridad pedagógica (columna `orden`, ver migración
    030) -- no alfabético ni por fecha de siembra. Se devuelven las 18
    SIEMPRE (taxonomía completa), no solo las que ya tienen contenido
    sembrado -- el dueño quiere ver el roadmap completo del curso desde el
    día uno, aunque el contenido se vaya completando Fase por Fase
    (expansión iterativa). `disponible` marca si la Fase ya tiene al
    menos un subtema con contenido real; el frontend usa esa bandera para
    mostrarla deshabilitada ("Próximamente") en vez de dejar entrar a una
    pantalla de subtemas vacía. `completado` solo puede ser true si
    además está disponible (una Fase sin contenido nunca cuenta como
    completada, aunque aritméticamente 0=0). `idioma` filtra por idioma
    ENSEÑADO (columna gramatica_temas.idioma, UNIQUE junto a slug) -- sin
    este filtro, un segundo idioma sembrado a futuro devolvería Fases de
    ambos mezcladas (mismo slug puede repetirse entre idiomas)."""
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT f.nombre, f.slug, f.orden,
                   sub_stats.total > 0 AS disponible,
                   (sub_stats.total > 0 AND sub_stats.total = sub_stats.completados) AS completado
            FROM gramatica_temas f
            JOIN LATERAL (
                SELECT COUNT(DISTINCT sub.id) AS total,
                       COUNT(DISTINCT sub.id) FILTER (
                           WHERE EXISTS (
                               SELECT 1 FROM eventos_puntos ep
                               WHERE ep.identidad_id = $1 AND ep.modulo = 'gramatica'
                                 AND ep.tipo_evento = 'subtema_completado' AND ep.referencia_id = sub.id
                           )
                       ) AS completados
                FROM gramatica_temas sub
                WHERE sub.parent_id = f.id
                  AND EXISTS (SELECT 1 FROM gramatica_contenido gc WHERE gc.tema_id = sub.id)
            ) sub_stats ON true
            WHERE f.parent_id IS NULL AND f.idioma = $2
            ORDER BY f.orden
            """,
            identidad_id(sesion), idioma,
        )
        return {"fases": [dict(f) for f in filas]}
    finally:
        await conn.close()


@router.get("/fases/{fase_slug}/subtemas")
async def subtemas_gramatica(
    fase_slug: str, sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en",
):
    """Subtemas (gramatica_temas hijos) de la Fase dada que ya tienen
    contenido real sembrado -- una Fase es solo agrupador, nunca tiene
    studentbook propio (mismo criterio que un tema de vocabulario nunca
    tiene banco de palabras propio, ver migración 021). `completado`
    marca si la identidad ya rindió el examen corto de ese subtema.
    `idioma` filtra la Fase padre (slug no es único por sí solo, ver
    /fases) -- los subtemas heredan el idioma de esa Fase vía parent_id,
    no hace falta filtrarlos por separado."""
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT DISTINCT sub.nombre, sub.slug, sub.orden,
                   EXISTS (
                       SELECT 1 FROM eventos_puntos ep
                       WHERE ep.identidad_id = $2 AND ep.modulo = 'gramatica'
                         AND ep.tipo_evento = 'subtema_completado' AND ep.referencia_id = sub.id
                   ) AS completado
            FROM gramatica_temas sub
            JOIN gramatica_temas fase ON fase.id = sub.parent_id
            JOIN gramatica_contenido gc ON gc.tema_id = sub.id
            WHERE fase.slug = $1 AND fase.idioma = $3
            ORDER BY sub.orden
            """,
            fase_slug, identidad_id(sesion), idioma,
        )
        return {"subtemas": [dict(f) for f in filas]}
    finally:
        await conn.close()


@router.get("/subtemas/{subtema_slug}/contenido", responses={404: {"description": _SUBTEMA_NO_ENCONTRADO}})
async def contenido_gramatica(
    subtema_slug: str,
    _sesion: Annotated[SesionInfo, Depends(sesion_actual)],
    idioma: str = "en",
):
    """Studentbook del subtema: reglas + ejemplos ordenados (`orden`), con
    `audio_key` si ya se sembró (ver scripts/generar_audio_gramatica.py) --
    null si ese contenido todavía no tiene audio generado, el frontend
    simplemente no muestra el botón de reproducir en ese caso. `idioma`
    desambigua el slug (no único por sí solo entre idiomas, ver /fases)."""
    conn = await db_conn()
    try:
        existe = await conn.fetchval(
            _SQL_EXISTE_SUBTEMA,
            subtema_slug, idioma,
        )
        if not existe:
            raise HTTPException(status_code=404, detail=_SUBTEMA_NO_ENCONTRADO)
        filas = await conn.fetch(
            """
            SELECT gc.id, gc.tipo, gc.texto_es, gc.texto_en, gc.nivel_cefr, gc.audio_key, gc.variante, gc.orden,
                   gc.metadata, gc.imagen_key, pc.nombre AS personaje_nombre
            FROM gramatica_contenido gc
            JOIN gramatica_temas t ON t.id = gc.tema_id
            LEFT JOIN personajes_conversacion pc ON pc.slug = gc.personaje_slug
            WHERE t.slug = $1 AND t.idioma = $2
            ORDER BY gc.orden
            """,
            subtema_slug, idioma,
        )
        contenido = [{**dict(f), "metadata": json.loads(f["metadata"]) if f["metadata"] else None} for f in filas]
        return {"contenido": contenido}
    finally:
        await conn.close()


@router.get("/audio/{audio_key}", responses={404: {"description": "Audio no generado todavía para esa clave"}})
async def audio_gramatica(audio_key: str, _sesion: Annotated[SesionInfo, Depends(sesion_actual)]):
    """Sirve el audio YA PREGENERADO (ver scripts/generar_audio_gramatica.py)
    tal cual desde CACHE_TTS_DIR -- a diferencia de /vocabulario/audio o
    /audio-guia, este endpoint NUNCA llama a Kokoro: si la clave no tiene
    un .wav cacheado, es porque el script batch todavía no corrió para
    ese contenido, no un cache-miss a resolver on-the-fly (restricción
    explícita del dueño: cero TTS en el camino de request de Gramática)."""
    ruta = CACHE_TTS_DIR / f"{audio_key}.wav"
    if not ruta.is_file():
        raise HTTPException(status_code=404, detail="Audio no generado todavía para esa clave.")
    return FileResponse(ruta, media_type="audio/wav", filename="gramatica.wav")


@router.get("/imagen/{imagen_key}", responses={404: {"description": "Imagen no encontrada para esa clave"}})
async def imagen_gramatica(imagen_key: str, _sesion: Annotated[SesionInfo, Depends(sesion_actual)]):
    """Sirve una escena curada offline (ver migración 061 y la memoria del
    proyecto) desde IMAGENES_GRAMATICA_DIR -- igual que /audio, nunca
    genera nada en el camino de request, solo lee un archivo ya versionado
    en el repo. Acepta .png o .webp (el que se haya guardado)."""
    if not _CLAVE_ARCHIVO_VALIDA.match(imagen_key):
        raise HTTPException(status_code=404, detail="Imagen no encontrada para esa clave.")
    for extension, media_type in ((".webp", "image/webp"), (".png", "image/png")):
        ruta = IMAGENES_GRAMATICA_DIR / f"{imagen_key}{extension}"
        if ruta.is_file():
            return FileResponse(ruta, media_type=media_type, filename=f"gramatica{extension}")
    raise HTTPException(status_code=404, detail="Imagen no encontrada para esa clave.")


async def _resolver_audio_secuencia(conn, ejercicios: list[dict], idioma: str) -> None:
    """Para ejercicios formato='audio_secuencia' (deletreo, ver migración
    038/040): cada uno trae en metadata.secuencia una lista de tokens
    (p.ej. letras "A","P","P","L","E") a reproducir en orden. En vez de
    generar audio nuevo por ejercicio, se resuelve cada token contra el
    banco de audio YA generado en gramatica_contenido (tipo='referencia',
    el mismo que alimenta la grilla del abecedario/números) -- así un
    ejercicio nuevo de este formato no requiere correr
    scripts/generar_audio_gramatica.py, solo sembrar la fila. Muta cada
    dict agregando 'secuencia_audio' (lista de {token, audio_key})."""
    tokens = {
        token
        for ej in ejercicios
        if ej["formato"] == "audio_secuencia" and ej.get("metadata")
        for token in ej["metadata"].get("secuencia", [])
    }
    if not tokens:
        return
    filas = await conn.fetch(
        "SELECT texto_en, audio_key FROM gramatica_contenido WHERE tipo = 'referencia' AND idioma = $1 AND texto_en = ANY($2::text[])",
        idioma, list(tokens),
    )
    audio_por_token = {f["texto_en"]: f["audio_key"] for f in filas}
    for ej in ejercicios:
        if ej["formato"] == "audio_secuencia" and ej.get("metadata"):
            ej["secuencia_audio"] = [
                {"token": t, "audio_key": audio_por_token.get(t)} for t in ej["metadata"]["secuencia"]
            ]


@router.get("/building-words")
async def building_words_gramatica(
    _sesion: Annotated[SesionInfo, Depends(sesion_actual)],
    idioma: str = "en",
    limit: int = 10,
):
    """Banco concentrado para Building Words.

    Reutiliza ejercicios audio_secuencia existentes, oculta la respuesta
    esperada y resuelve los audio_key de cada letra. La evaluación y el
    progreso del Gusanito siguen pasando por POST /ejercicios/evaluar.
    """
    limite = max(1, min(limit, 20))
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT e.id, e.nivel_cefr, e.metadata
            FROM ejercicios e
            JOIN gramatica_temas t ON t.id = e.tema_gramatica_id
            WHERE e.idioma = $1
              AND t.idioma = $1
              AND e.formato = 'audio_secuencia'
              AND e.tipo = 'cloze'
            ORDER BY e.nivel_cefr, e.id
            LIMIT $2
            """,
            idioma, limite,
        )
        ejercicios = [
            {
                "id": fila["id"],
                "formato": "audio_secuencia",
                "nivel_cefr": fila["nivel_cefr"],
                "metadata": json.loads(fila["metadata"]) if fila["metadata"] else {},
            }
            for fila in filas
        ]
        await _resolver_audio_secuencia(conn, ejercicios, idioma)

        puzzles = []
        for ejercicio in ejercicios:
            secuencia = ejercicio.get("secuencia_audio", [])
            puzzles.append({
                "id": ejercicio["id"],
                "longitud": len(secuencia),
                "pista": f"Palabra de {len(secuencia)} letras · nivel {ejercicio['nivel_cefr']}",
                "alimento": 1 if ejercicio["nivel_cefr"] == "A1" else 2,
                "nivel_cefr": ejercicio["nivel_cefr"],
                "secuencia_audio": secuencia,
            })
        return {"puzzles": puzzles}
    finally:
        await conn.close()


@router.get("/subtemas/{subtema_slug}/ejercicios", responses={404: {"description": _SUBTEMA_NO_ENCONTRADO}})
async def ejercicios_gramatica(
    subtema_slug: str, _sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en",
):
    """Workbook del subtema: TODOS sus ejercicios de una vez (a diferencia
    de /vocabulario/ejercicios/siguiente, acá el banco por subtema es
    chico y curado -- 2 ejercicios por subtema en la siembra inicial, ver
    migración 032 -- no hace falta repetición espaciada todavía, el
    frontend arma el examen corto con esta lista completa). `idioma`
    desambigua el slug del subtema (ver /fases); los ejercicios en sí
    tienen su propia columna `ejercicios.idioma` (usada para gamificación
    en /ejercicios/evaluar), acá solo hace falta para resolver el tema.

    `formato` (ver migración 038) le dice al frontend cómo presentar el
    ejercicio (texto con hueco, secuencia de audio, conteo visual) de
    forma genérica -- la evaluación (`tipo`) no cambia con el formato, y
    agregar un formato nuevo a futuro no requiere tocar el evaluador."""
    conn = await db_conn()
    try:
        existe = await conn.fetchval(
            _SQL_EXISTE_SUBTEMA,
            subtema_slug, idioma,
        )
        if not existe:
            raise HTTPException(status_code=404, detail=_SUBTEMA_NO_ENCONTRADO)
        filas = await conn.fetch(
            """
            SELECT e.id, e.tipo, e.formato, e.consigna_es, e.contexto_en, e.nivel_cefr, e.opciones, e.metadata
            FROM ejercicios e
            JOIN gramatica_temas t ON t.id = e.tema_gramatica_id
            WHERE t.slug = $1 AND t.idioma = $2
            ORDER BY e.id
            """,
            subtema_slug, idioma,
        )
        ejercicios = [{**dict(f), "metadata": json.loads(f["metadata"]) if f["metadata"] else None} for f in filas]
        await _resolver_audio_secuencia(conn, ejercicios, idioma)
        return {"ejercicios": ejercicios}
    finally:
        await conn.close()


@router.post("/ejercicios/evaluar", responses={404: {"description": _EJERCICIO_GRAMATICA_NO_ENCONTRADO}})
async def evaluar_ejercicio_gramatica(
    body: _EvaluarEjercicioGramaticaBody,
    sesion: Annotated[SesionInfo, Depends(sesion_actual)],
):
    """Evalúa la respuesta de un ejercicio de Gramática -- comparación
    determinista contra respuesta_esperada/respuestas_alternativas, sin
    LLM (restricción explícita del dueño para todo este módulo, a
    diferencia de vocabulario técnico que sí evalúa producción libre con
    LLM en Fase 3). Guarda el intento en intentos_gramatica."""
    conn = await db_conn()
    try:
        ejercicio = await conn.fetchrow(
            "SELECT respuesta_esperada, respuestas_alternativas, idioma FROM ejercicios "
            "WHERE id = $1 AND tema_gramatica_id IS NOT NULL",
            body.ejercicio_id,
        )
        if ejercicio is None:
            raise HTTPException(status_code=404, detail=_EJERCICIO_GRAMATICA_NO_ENCONTRADO)
        respuestas_validas = {_normalizar_respuesta_gramatica(ejercicio["respuesta_esperada"])}
        respuestas_validas.update(_normalizar_respuesta_gramatica(r) for r in ejercicio["respuestas_alternativas"])
        correcto = _normalizar_respuesta_gramatica(body.respuesta_usuario) in respuestas_validas
        await conn.execute(
            """
            INSERT INTO intentos_gramatica
                (identidad_id, ejercicio_id, respuesta_usuario, correcto, tiempo_respuesta_ms, confianza)
            VALUES ($1, $2, $3, $4, $5, $6)
            """,
            identidad_id(sesion), body.ejercicio_id, body.respuesta_usuario, correcto,
            body.tiempo_respuesta_ms, body.confianza,
        )

        # Motor de Memoria: mueve la caja de Leitner según la tabla de
        # decisión (correcto + confianza + tiempo), nunca solo por
        # correcto/incorrecto. Best-effort igual que la gamificación de
        # abajo -- un fallo acá no debe romper la respuesta al ejercicio.
        caja_nueva = None
        error_consolidado = False
        try:
            caja_previa = await conn.fetchval(
                "SELECT caja FROM repaso_programado WHERE identidad_id = $1 AND modulo = 'gramatica' AND ejercicio_id = $2",
                identidad_id(sesion), body.ejercicio_id,
            )
            # 0 = "concepto nunca tocado" (distinto de 1 = "recién falló o
            # recién visto una vez") -- así el primer intento de algo nuevo
            # no arranca con historia previa que no existió. Ver "concepto
            # 0" en la memoria del proyecto: el Gusanito (Fase 9) necesita
            # poder ofrecer estos ejercicios "en caja 0" desde el primer
            # toque, sin que el alumno haya completado nada antes.
            caja_actual = caja_previa if caja_previa is not None else 0
            caja_nueva, error_consolidado = calcular_movimiento_caja(
                correcto, body.confianza, body.tiempo_respuesta_ms, caja_actual,
            )
            await conn.execute(
                """
                INSERT INTO repaso_programado (identidad_id, modulo, ejercicio_id, caja, proxima_fecha)
                VALUES ($1, 'gramatica', $2, $3, $4)
                ON CONFLICT (identidad_id, modulo, ejercicio_id)
                DO UPDATE SET caja = $3, proxima_fecha = $4, actualizado_en = now()
                """,
                identidad_id(sesion), body.ejercicio_id, caja_nueva, proxima_fecha_por_caja(caja_nueva),
            )
        except Exception as e:
            logger.warning("No se pudo actualizar el Motor de Memoria (ejercicio_id=%s): %s", body.ejercicio_id, e)

        # Gamificación best-effort (ver gamificacion.py) -- nunca bloquea la
        # respuesta principal si falla, mismo criterio que routers/vocabulario.py.
        try:
            await otorgar_puntos(
                conn, identidad_id(sesion), ejercicio["idioma"], "gramatica",
                "ejercicio_correcto" if correcto else "ejercicio_intento",
                puntos_ejercicio(correcto), body.ejercicio_id,
            )
            await evaluar_insignias_periodo(conn, identidad_id(sesion), ejercicio["idioma"], date.today().replace(day=1))
        except Exception as e:
            logger.warning("No se pudo registrar gamificación (ejercicio_id=%s): %s", body.ejercicio_id, e)
        return {
            "correcto": correcto,
            "respuesta_esperada": ejercicio["respuesta_esperada"],
            "caja": caja_nueva,
            "error_consolidado": error_consolidado,
        }
    finally:
        await conn.close()


@router.get("/repaso")
async def repaso_gramatica(sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en"):
    """Cola de repaso del Motor de Memoria: ejercicios cuya `proxima_fecha`
    ya venció, ordenados por más vencidos primero. Disparo por PULL (el
    frontend la consulta cuando el alumno entra al hub), nunca por cron --
    mismo criterio de "cero procesamiento en segundo plano" del resto del
    módulo, esto es una consulta a demanda como cualquier otro GET."""
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT e.id, e.tipo, e.formato, e.consigna_es, e.contexto_en, e.nivel_cefr, e.opciones, e.metadata,
                   rp.caja, rp.proxima_fecha
            FROM repaso_programado rp
            JOIN ejercicios e ON e.id = rp.ejercicio_id
            WHERE rp.identidad_id = $1 AND rp.modulo = 'gramatica' AND rp.proxima_fecha <= CURRENT_DATE
                  AND e.idioma = $2
            ORDER BY rp.proxima_fecha ASC
            """,
            identidad_id(sesion), idioma,
        )
        ejercicios = [{**dict(f), "metadata": json.loads(f["metadata"]) if f["metadata"] else None} for f in filas]
        await _resolver_audio_secuencia(conn, ejercicios, idioma)
        return {"ejercicios": ejercicios, "total_vencidos": len(ejercicios)}
    finally:
        await conn.close()


@router.post("/subtemas/completar", responses={404: {"description": _SUBTEMA_NO_ENCONTRADO}})
async def completar_subtema_gramatica(
    body: _CompletarSubtemaGramaticaBody,
    sesion: Annotated[SesionInfo, Depends(sesion_actual)],
):
    """Marca un subtema como completado -- evento deduplicado para
    siempre (uq_eventos_puntos_unicos ya cubre 'subtema_completado', ver
    migración 018), mismo criterio que /vocabulario/subtemas/completar.
    Sin verificación server-side de qué ejercicios se completaron
    realmente -- mismo nivel de confianza que el resto de la
    gamificación (ver gamificacion.py)."""
    conn = await db_conn()
    try:
        fila = await conn.fetchrow(
            "SELECT id FROM gramatica_temas WHERE slug = $1 AND idioma = $2 AND parent_id IS NOT NULL",
            body.slug, body.idioma,
        )
        if fila is None:
            raise HTTPException(status_code=404, detail=_SUBTEMA_NO_ENCONTRADO)
        try:
            await otorgar_puntos(
                conn, identidad_id(sesion), body.idioma, "gramatica",
                "subtema_completado", puntos_subtema_completado(), fila["id"],
            )
            await evaluar_insignias_periodo(conn, identidad_id(sesion), body.idioma, date.today().replace(day=1))
        except Exception as e:
            logger.warning("No se pudo registrar gamificación de subtema (slug=%s): %s", body.slug, e)
        return {"ok": True}
    finally:
        await conn.close()


@router.post(
    "/subtemas/{subtema_slug}/autoexplicacion",
    responses={404: {"description": _SUBTEMA_NO_ENCONTRADO}, 502: {"description": "El LLM no pudo evaluar la autoexplicación"}},
)
async def autoexplicacion_gramatica(
    subtema_slug: str,
    body: _AutoexplicacionBody,
    sesion: Annotated[SesionInfo, Depends(sesion_actual)],
    idioma: str = "en",
):
    """Auto-explicación con LLM (Fase 3 del plan de dinamismo, ver
    gramatica/autoexplicacion.py y la memoria del proyecto) -- ÚNICA
    excepción de este router a "cero LLM en runtime": opt-in, una sola
    llamada al cerrar un subtema, nunca en el camino normal de
    studentbook/ejercicios. Rate limit por identidad (mismo motivo que
    /vocabulario/generar-ejercicio: dispara una llamada a un LLM de pago
    sin otro costo real, trivialmente automatizable sin límite)."""
    verificar_limite_llm(identidad_id(sesion))
    conn = await db_conn()
    try:
        fila = await conn.fetchrow(
            """
            SELECT t.id AS tema_id, gc.texto_es AS regla
            FROM gramatica_temas t
            JOIN gramatica_contenido gc ON gc.tema_id = t.id AND gc.tipo = 'regla'
            WHERE t.slug = $1 AND t.idioma = $2
            ORDER BY gc.orden LIMIT 1
            """,
            subtema_slug, idioma,
        )
        if fila is None:
            raise HTTPException(status_code=404, detail=_SUBTEMA_NO_ENCONTRADO)
        evaluacion = await autoexplicacion.evaluar_autoexplicacion(get_llm_adapter(), fila["regla"], body.explicacion)
        if evaluacion is None:
            raise HTTPException(status_code=502, detail="El LLM no pudo evaluar la autoexplicación, intentá de nuevo.")
        await conn.execute(
            """
            INSERT INTO gramatica_autoexplicaciones (identidad_id, tema_id, explicacion_usuario, evaluacion)
            VALUES ($1, $2, $3, $4)
            """,
            identidad_id(sesion), fila["tema_id"], body.explicacion, json.dumps(evaluacion),
        )
        return {"evaluacion": evaluacion}
    finally:
        await conn.close()


@router.get("/relaciones")
async def relaciones_gramatica(_sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en"):
    """Mapa "VS" de cruces (Fase 6 del plan de dinamismo, ver migración
    065 y la memoria del proyecto): tabla chica y curada a mano, NO un
    grafo dinámico -- devuelve las ~12 relaciones con nombre/slug de
    ambos subtemas ya resueltos para armar las tarjetas de contraste."""
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT r.id, r.tipo_relacion, r.texto_es,
                   ta.slug AS tema_a_slug, ta.nombre AS tema_a_nombre,
                   tb.slug AS tema_b_slug, tb.nombre AS tema_b_nombre
            FROM gramatica_relaciones r
            JOIN gramatica_temas ta ON ta.id = r.tema_a_id
            JOIN gramatica_temas tb ON tb.id = r.tema_b_id
            WHERE ta.idioma = $1
            ORDER BY r.id
            """,
            idioma,
        )
        return {"relaciones": [dict(f) for f in filas]}
    finally:
        await conn.close()


@router.get("/relaciones/{relacion_id}/ejercicios", responses={404: {"description": "Relación no encontrada"}})
async def relacion_ejercicios_gramatica(
    relacion_id: int, _sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en",
):
    """Ejercicios para "practicar el cruce": mezcla los ejercicios de
    ambos subtemas de la relación -- reusa `ejercicios` tal cual, cero
    ejercicios nuevos generados. Mismo shape que /subtemas/{slug}/
    ejercicios para que el frontend reuse la pantalla de examen ya
    existente sin duplicar lógica."""
    conn = await db_conn()
    try:
        relacion = await conn.fetchrow(
            "SELECT tema_a_id, tema_b_id FROM gramatica_relaciones WHERE id = $1", relacion_id,
        )
        if relacion is None:
            raise HTTPException(status_code=404, detail="Relación no encontrada.")
        filas = await conn.fetch(
            """
            SELECT e.id, e.tipo, e.formato, e.consigna_es, e.contexto_en, e.nivel_cefr, e.opciones, e.metadata
            FROM ejercicios e
            WHERE e.tema_gramatica_id = ANY($1) AND e.idioma = $2
            ORDER BY e.id
            """,
            [relacion["tema_a_id"], relacion["tema_b_id"]], idioma,
        )
        ejercicios = [{**dict(f), "metadata": json.loads(f["metadata"]) if f["metadata"] else None} for f in filas]
        await _resolver_audio_secuencia(conn, ejercicios, idioma)
        return {"ejercicios": ejercicios}
    finally:
        await conn.close()


@router.get("/gusanito/evolucion")
async def evolucion_gusanito_gramatica(sesion: Annotated[SesionInfo, Depends(sesion_actual)]):
    """Tier de evolución del Gusanito (Fase 10 del plan de dinamismo, ver
    gamificacion.evaluar_evolucion_gusano) -- global a todas las Fases de
    Gramática, no solo las habilitadas para jugar
    (_FASES_GUSANITO_HABILITADAS). DEBE declararse ANTES de
    /gusanito/{fase_slug} -- FastAPI matchea rutas en orden de registro,
    y {fase_slug} (segmento único) también matchea literalmente
    "evolucion" si se registra primero (bug real encontrado al testear:
    devolvía 404 en vez de la evolución, porque "evolucion" no está en
    _FASES_GUSANITO_HABILITADAS)."""
    conn = await db_conn()
    try:
        return await evaluar_evolucion_gusano(conn, identidad_id(sesion))
    finally:
        await conn.close()


@router.get("/gusanito/{fase_slug}", responses={404: {"description": _FASE_NO_ENCONTRADA}})
async def gusanito_gramatica(
    fase_slug: str, sesion: Annotated[SesionInfo, Depends(sesion_actual)], idioma: str = "en",
):
    """Estado del camino del Gusanito para una Fase (Fase 9 del plan de
    dinamismo, ver memoria del proyecto) -- nodos = subtemas de esa Fase,
    NÚMERO FIJO (nunca preguntas ilimitadas). Un subtema está 'dominado'
    cuando TODOS sus ejercicios alcanzaron caja >= _CAJA_DOMINADO_GUSANITO
    en el Motor de Memoria (Fase 1) -- un ejercicio nunca intentado cuenta
    como caja 0 (ver "concepto 0" en la memoria del proyecto), así que un
    subtema con algo sin tocar todavía no puede estar dominado."""
    if fase_slug not in _FASES_GUSANITO_HABILITADAS:
        raise HTTPException(status_code=404, detail=_FASE_NO_ENCONTRADA)
    conn = await db_conn()
    try:
        filas = await conn.fetch(
            """
            SELECT s.slug, s.nombre, s.orden,
                   count(e.id) AS total_ejercicios,
                   count(rp.ejercicio_id) AS intentados,
                   count(rp.ejercicio_id) FILTER (WHERE rp.caja >= $3) AS dominados
            FROM gramatica_temas f
            JOIN gramatica_temas s ON s.parent_id = f.id
            JOIN ejercicios e ON e.tema_gramatica_id = s.id
            LEFT JOIN repaso_programado rp
                   ON rp.ejercicio_id = e.id AND rp.identidad_id = $2 AND rp.modulo = 'gramatica'
            WHERE f.slug = $1 AND f.idioma = $4 AND f.parent_id IS NULL
            GROUP BY s.id, s.slug, s.nombre, s.orden
            ORDER BY s.orden
            """,
            fase_slug, identidad_id(sesion), _CAJA_DOMINADO_GUSANITO, idioma,
        )
        nodos = []
        for f in filas:
            if f["total_ejercicios"] > 0 and f["dominados"] == f["total_ejercicios"]:
                estado = "dominado"
            elif f["intentados"] > 0:
                estado = "en_progreso"
            else:
                estado = "pendiente"
            nodos.append({"slug": f["slug"], "nombre": f["nombre"], "estado": estado})
        posicion = sum(1 for n in nodos if n["estado"] == "dominado")
        return {"nodos": nodos, "posicion": posicion, "meta_alcanzada": posicion == len(nodos) and len(nodos) > 0}
    finally:
        await conn.close()


@router.get(
    "/gusanito/{fase_slug}/{subtema_slug}/ejercicios",
    responses={404: {"description": _SUBTEMA_NO_ENCONTRADO}},
)
async def gusanito_ejercicios_gramatica(
    fase_slug: str,
    subtema_slug: str,
    sesion: Annotated[SesionInfo, Depends(sesion_actual)],
    idioma: str = "en",
):
    """Ejercicios jugables AHORA en un nodo del Gusanito: unión de
    "concepto 0" (ejercicios sin ninguna fila en repaso_programado --
    nunca tocados, siempre disponibles) y ejercicios vencidos
    (proxima_fecha <= hoy) -- así un usuario que nunca estudió esta Fase
    puede jugar desde el primer toque, sin depender de progreso previo.
    Reusa `ejercicios` tal cual (cero ejercicios nuevos generados) y el
    mismo POST /ejercicios/evaluar de siempre para responder -- este
    endpoint solo decide QUÉ mostrar, no cambia cómo se evalúa."""
    if fase_slug not in _FASES_GUSANITO_HABILITADAS:
        raise HTTPException(status_code=404, detail=_FASE_NO_ENCONTRADA)
    conn = await db_conn()
    try:
        existe = await conn.fetchval(
            _SQL_EXISTE_SUBTEMA,
            subtema_slug, idioma,
        )
        if not existe:
            raise HTTPException(status_code=404, detail=_SUBTEMA_NO_ENCONTRADO)
        filas = await conn.fetch(
            """
            SELECT e.id, e.tipo, e.formato, e.consigna_es, e.contexto_en, e.nivel_cefr, e.opciones, e.metadata
            FROM ejercicios e
            JOIN gramatica_temas t ON t.id = e.tema_gramatica_id
            LEFT JOIN repaso_programado rp
                   ON rp.ejercicio_id = e.id AND rp.identidad_id = $3 AND rp.modulo = 'gramatica'
            WHERE t.slug = $1 AND t.idioma = $2
                  AND (rp.ejercicio_id IS NULL OR rp.proxima_fecha <= CURRENT_DATE)
            ORDER BY (rp.ejercicio_id IS NULL) DESC, rp.caja ASC NULLS FIRST, e.id
            """,
            subtema_slug, idioma, identidad_id(sesion),
        )
        ejercicios = [{**dict(f), "metadata": json.loads(f["metadata"]) if f["metadata"] else None} for f in filas]
        await _resolver_audio_secuencia(conn, ejercicios, idioma)
        return {"ejercicios": ejercicios}
    finally:
        await conn.close()
