-- Pedido en vivo: "Hora 4" -- sigue la secuencia Hora 1/2/3, sesión de
-- práctica con diálogos cortos de DOS personas (dos voces Kokoro
-- distintas, ver VOICES.md -- af_heart US femenina / am_michael US
-- masculina, elegidas por contraste de género para que se note
-- claramente el cambio de hablante) terminando en una pregunta de
-- comprensión sobre HORA o FECHA (no solo hora -- el dueño pidió que las
-- conversaciones mezclen ambos temas), como refuerzo final de todo lo
-- enseñado en Fecha + Hora 1/2/3.
--
-- formato='conversacion_audio' (nuevo, se suma a la lista de la migración
-- 045): metadata.turnos = [{hablante, voz, texto_en}, ...]. A diferencia
-- de audio_secuencia (que resuelve audio contra un banco YA generado de
-- palabras sueltas), acá cada turno es una oración única del diálogo --
-- el audio_key de cada turno se genera y persiste DENTRO del propio
-- metadata (ver scripts/generar_audio_gramatica.py::sembrar_audio_conversaciones),
-- así el endpoint sigue sin tocar Kokoro en el camino de request (mismo
-- principio que el resto del módulo).
ALTER TABLE ejercicios DROP CONSTRAINT chk_ejercicios_formato;
ALTER TABLE ejercicios ADD CONSTRAINT chk_ejercicios_formato
    CHECK (formato IN ('texto', 'audio_secuencia', 'conteo_visual', 'reloj_visual', 'conversacion_audio'));

INSERT INTO gramatica_temas (nombre, slug, parent_id, orden)
SELECT 'Hora 4: conversaciones', 'fase-1-hora-4', f.id, 7
FROM gramatica_temas f WHERE f.slug = 'fase-1-fundamentos' AND f.parent_id IS NULL;

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'regla', 'Escuchá diálogos cortos entre dos personas y prestá atención a la hora o la fecha que mencionan -- combina todo lo aprendido en Fecha y Hora 1, 2 y 3.', 'What time are we meeting? What day works for you?', 'A1', 1
FROM gramatica_temas t WHERE t.slug = 'fase-1-hora-4' AND t.parent_id IS NOT NULL;
