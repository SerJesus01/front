-- ===========================================================================
-- Módulo nuevo "Gramática" (studentbook + workbook, ver memoria del
-- proyecto): explica el POR QUÉ de la estructura del inglés -- ningún
-- módulo existente lo hace hoy (vocabulario técnico usa tiempo_verbal
-- como ETIQUETA de una forma ya conjugada, ejercicios como "have deployed"
-- para present_perfect, nunca como la explicación de la regla). Diseño
-- validado con Fable (2 rondas, 01-02/ago/2026) antes de codear.
--
-- Cero LLM/Whisper/Kokoro en runtime (restricción explícita del dueño):
-- todo el contenido y audio vive resuelto acá o en un caché ya generado --
-- ver 030_gramatica_seed_temas.sql para la siembra de las 18 Fases y
-- gramatica/generar_audio.py (script batch aparte) para el audio.
--
-- Jerarquía de 2 niveles (Fase -> subtema), decisión explícita del dueño:
-- reusar EXACTAMENTE el patrón de `hashtags.parent_id` (parent_id IS NULL
-- = Fase, parent_id NOT NULL = subtema) para poder reusar tal cual el
-- query de 2 pasos que ya usa routers/vocabulario.py -- NO se modela como
-- árbol de 3 niveles (Fase > tema > subtema) aunque la agrupación
-- pedagógica original (Fundamentos/Estructura/Conectores/Preposiciones/
-- Vocabulario situacional) tenía naturalmente 3 capas: esa capa extra se
-- aplanó a propósito, queda solo como agrupación visual en el frontend,
-- no en la base -- evita escribir un CTE recursivo nuevo.
--
-- Tabla PROPIA (`gramatica_temas`), no reusar `hashtags`: hashtags es M:N
-- (una frase/palabra puede pertenecer a varios intereses a la vez, ver
-- migración 006), Gramática es un currículum de pertenencia ÚNICA (un
-- subtema vive en UNA sola Fase) -- mezclarlo contaminaría el filtro de
-- intereses/profesión que ya usan frases/vocabulario.
-- ===========================================================================

CREATE TABLE gramatica_temas (
    id        SERIAL PRIMARY KEY,
    nombre    VARCHAR(100) NOT NULL,
    slug      VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES gramatica_temas(id),
    orden     INTEGER NOT NULL,
    idioma    VARCHAR(10) NOT NULL DEFAULT 'en' REFERENCES idiomas(codigo),
    UNIQUE (idioma, slug)
);
CREATE INDEX idx_gramatica_temas_parent_id ON gramatica_temas(parent_id);

-- gramatica_contenido: el STUDENTBOOK real -- SOLO tipo regla/ejemplo
-- (explicación de estructura). Vocabulario situacional (familia,
-- ubicaciones) NO vive acá -- corrección explícita de Fable: eso ya lo
-- resuelve `vocabulario` de punta a punta (banco -> examen -> intento ->
-- gamificación), duplicarlo en una tabla de contenido paralela hubiera
-- sido reinventar una rueda que ya funciona. `texto_es` es el activo
-- central del módulo (la explicación de "por qué se arma así" que hoy no
-- existe en ningún lado del repo) -- más importante que el ejemplo o el
-- audio, no un acompañante secundario.
--
-- `audio_key`: clave de `CACHE_TTS_DIR` (mismo hash sha256(voz:speed:texto)
-- que ya usa audio_pipeline.obtener_audio_patron), NO una ruta de archivo
-- fija -- corrección de Fable: `static/` se hornea en la imagen Docker en
-- cada build, cualquier .wav ahí desaparece en el próximo deploy;
-- `frases.url_audio` (migración 002) es el precedente de ese error, nunca
-- se implementó. Con clave por hash, si se corrige texto_en después de
-- sembrado el hash cambia solo -- invalidación gratis, sin lógica extra.
-- Nullable: se llena recién cuando corre el script batch de siembra de
-- audio (gramatica/generar_audio.py), no en esta migración.
CREATE TABLE gramatica_contenido (
    id         SERIAL PRIMARY KEY,
    tema_id    INTEGER NOT NULL REFERENCES gramatica_temas(id),
    tipo       VARCHAR(20) NOT NULL,
    texto_es   TEXT NOT NULL,
    texto_en   TEXT NOT NULL,
    nivel_cefr VARCHAR(2) NOT NULL,
    idioma     VARCHAR(10) NOT NULL DEFAULT 'en' REFERENCES idiomas(codigo),
    audio_key  VARCHAR(128),
    orden      INTEGER NOT NULL,
    CONSTRAINT chk_gramatica_contenido_tipo CHECK (tipo IN ('regla', 'ejemplo')),
    CONSTRAINT chk_gramatica_contenido_nivel_cefr CHECK (nivel_cefr IN ('A1','A2','B1','B2','C1','C2'))
);
CREATE INDEX idx_gramatica_contenido_tema_id ON gramatica_contenido(tema_id);

-- Vocabulario situacional (familia, ubicaciones, Fase 18) vive en
-- `vocabulario` extendido, no en gramatica_contenido -- agrega 'sustantivo'
-- al CHECK de pos (hasta ahora solo verbo/conector, ver migración 015).
ALTER TABLE vocabulario DROP CONSTRAINT chk_vocabulario_pos;
ALTER TABLE vocabulario ADD CONSTRAINT chk_vocabulario_pos CHECK (pos IN ('verbo', 'conector', 'sustantivo'));

-- Puente M:N análogo a vocabulario_hashtags (migración 015) pero hacia
-- gramatica_temas en vez de hashtags -- un sustantivo de vocabulario
-- situacional (ej. "grandmother") cuelga de un subtema de Gramática
-- (Fase 18 > Familia), nunca de un hashtag de interés.
CREATE TABLE vocabulario_gramatica_temas (
    vocabulario_id INTEGER NOT NULL REFERENCES vocabulario(id),
    tema_id        INTEGER NOT NULL REFERENCES gramatica_temas(id),
    PRIMARY KEY (vocabulario_id, tema_id)
);

-- ejercicios (WORKBOOK): reusa la tabla genérica ya existente en vez de
-- crear una espejo -- mismo criterio ya usado para vocab_tecnico/
-- vocab_interes (ver migración 021). Un ejercicio de Gramática cuelga de
-- tema_gramatica_id, nunca de vocabulario_id/vocabulario_forma_id.
--
-- CHECK "a lo sumo 1" (NO "exactamente 1" como se había propuesto en la
-- validación inicial de Fable): los ejercicios generados on-demand por el
-- LLM (POST /vocabulario/generar-ejercicio, ver migración 017 y
-- routers/vocabulario.py) se insertan HOY con las 3 columnas de dominio
-- en null (lema improvisado, sin catalogar) -- una constraint "= 1"
-- hubiera roto esas filas ya existentes en producción. Verificado leyendo
-- el INSERT real antes de escribir el CHECK, no asumido.
ALTER TABLE ejercicios ADD COLUMN tema_gramatica_id INTEGER REFERENCES gramatica_temas(id);
ALTER TABLE ejercicios ADD CONSTRAINT chk_ejercicios_maximo_una_fk_dominio
    CHECK (num_nonnulls(vocabulario_forma_id, vocabulario_id, tema_gramatica_id) <= 1);

-- intentos_gramatica: espejo de intentos_vocab/intentos_listening (mismo
-- patrón ya usado 2 veces en el repo). Sin columna `evaluacion JSONB` --
-- a diferencia de vocabulario técnico (que sí evalúa producción libre con
-- LLM en Fase 3), TODOS los ejercicios de Gramática son deterministas
-- (cloze/transformación/multiple choice/ordenar_oracion), corrección por
-- comparación exacta contra respuesta_esperada/respuestas_alternativas/
-- opciones -- cero LLM en runtime, restricción explícita del dueño.
CREATE TABLE intentos_gramatica (
    id                INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    identidad_id      INTEGER NOT NULL,
    ejercicio_id      INTEGER NOT NULL REFERENCES ejercicios(id),
    respuesta_usuario TEXT NOT NULL,
    correcto          BOOLEAN NOT NULL,
    creado_en         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_intentos_gramatica_identidad ON intentos_gramatica(identidad_id);
CREATE INDEX idx_intentos_gramatica_ejercicio ON intentos_gramatica(ejercicio_id);

-- Amplía el módulo permitido en el ledger de gamificación (mismo patrón
-- que la migración 027 agregó 'listening') -- sin esto, otorgar_puntos
-- con modulo='gramatica' viola el CHECK y falla en silencio (tragado por
-- el try/except amplio ya existente en cada endpoint).
ALTER TABLE eventos_puntos DROP CONSTRAINT chk_evento_modulo;
ALTER TABLE eventos_puntos ADD CONSTRAINT chk_evento_modulo
    CHECK (modulo IN ('score', 'conversacion', 'vocab_tecnico', 'vocab_interes', 'listening', 'gramatica'));
