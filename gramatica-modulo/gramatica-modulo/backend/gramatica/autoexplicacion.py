"""Auto-explicación con LLM (Fase 3 del plan de dinamismo pedagógico, ver
memoria del proyecto): al cerrar un subtema, el alumno explica con sus
propias palabras cuándo usaría la regla -- el LLM NO la corrige ni la
califica, la usa como refuerzo positivo (self-explanation effect).
Opt-in y de baja frecuencia (una llamada por cierre de subtema, nunca
por ejercicio) -- única excepción documentada al "cero LLM en runtime"
de Gramática, mismo criterio ya aceptado en Vocabulario (ver
vocabulario/generador.py).

Antes devolvía también "falta" (contraste de qué matiz le faltaba al
alumno) -- se sacó (04/ago/2026, hallazgo en vivo del dueño): en
subtemas de puro vocabulario (Frutas, Saludos...) la "regla real" es
solo una descripción del tema, sin matices reales que contrastar, así
que el LLM terminaba inventando exigencias tontas ("te falta mencionar
ejemplos concretos de frutas") o partiendo la frase en tercera persona
en vez de un fragmento. Más simple y más honesto: solo refuerzo
positivo, funciona igual de bien para una regla gramatical que para un
tema de vocabulario."""
import json
from typing import Optional

from llm.port import LLMPort, LLMRespuestaInvalida

_SYSTEM_PROMPT = """You compare a student's own-words explanation of an English
grammar/vocabulary topic against the real description, for a
Spanish-speaking learner app. You do NOT grade, correct, or point out
what's missing -- you only give POSITIVE reinforcement of what the
student already got right (self-explanation effect).

Se te da REGLA_REAL (la explicación oficial en español) y
EXPLICACION_ALUMNO (lo que el alumno escribió con sus propias palabras,
también en español). Nunca reescribas la regla completa de vuelta --
señalá puntualmente qué entendió bien, en frases cortas.

Reglas:
- "coincide": lista de FRAGMENTOS cortos en español que completen
  naturalmente la frase "Coincidís en: ...". NUNCA empieces un fragmento
  nombrando al alumno en tercera persona ("el alumno entiende...", "el
  alumno dice...") ni repitas "coincidís"/"entendés" al inicio -- el
  frontend ya antepone esa frase, vos solo escribís lo que sigue.
  Correcto: "que el presente perfecto conecta el pasado con el
  presente". Incorrecto (no lo hagas): "El alumno entiende que el
  presente perfecto conecta el pasado con el presente". Puede ser una
  lista vacía si no acertó nada real -- NUNCA inventes un acierto que no
  esté realmente en su explicación solo para tener algo que decir.
- NO devuelvas ninguna clave de "lo que falta" o "lo que no dijo" --
  esta evaluación es solo refuerzo positivo, ni corrige ni señala
  huecos.
- Nunca uses HTML ni markdown en los textos.

Formato de salida -- SOLO JSON válido, sin texto adicional, sin markdown:
{"coincide": [str]}"""


def construir_prompt_usuario(regla_real: str, explicacion_alumno: str) -> str:
    return json.dumps({"REGLA_REAL": regla_real, "EXPLICACION_ALUMNO": explicacion_alumno}, ensure_ascii=False)


def _contiene_html(*valores: str) -> bool:
    """Mismo guardrail que vocabulario/generador.py::_contiene_html --
    defensa en profundidad contra HTML embebido en la respuesta del LLM
    (el frontend ya renderiza por nodos DOM, esto es la segunda capa)."""
    return any(("<" in v or ">" in v) for v in valores if v)


def validar_evaluacion(evaluacion: dict) -> bool:
    """Guardrail determinista: rechaza si falta la lista esperada, si
    algún elemento no es string, o si algo trae HTML -- nunca se confía
    en que el LLM haya respetado el formato pedido."""
    coincide = evaluacion.get("coincide")
    if not isinstance(coincide, list):
        return False
    if not all(isinstance(v, str) for v in coincide):
        return False
    if _contiene_html(*coincide):
        return False
    return True


async def evaluar_autoexplicacion(llm_adapter: LLMPort, regla_real: str, explicacion_alumno: str) -> Optional[dict]:
    """Devuelve la evaluación de contraste, o None si el LLM falló o el
    guardrail la rechazó -- el caller (routers/gramatica.py) decide qué
    hacer (502 en vez de persistir basura)."""
    prompt_usuario = construir_prompt_usuario(regla_real, explicacion_alumno)
    try:
        evaluacion = await llm_adapter.generar(
            _SYSTEM_PROMPT, [{"role": "user", "content": prompt_usuario}], temperature=0.3,
        )
    except LLMRespuestaInvalida:
        return None
    if not validar_evaluacion(evaluacion):
        return None
    return evaluacion
