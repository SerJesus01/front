-- Feedback en vivo: los ejercicios de fecha específica ("The party is on
-- December ___.") eran texto frío sin ningún contexto real -- "no hay
-- nada con que comparar", solo memorizar la ortografía del ordinal. Se
-- convierten a formato='audio_frase' (nuevo): UNA sola voz narra una
-- oración corta con contexto real (~5s), el alumno escucha y responde
-- una pregunta de comprensión, en vez de leer una oración descontextualizada.
--
-- Distinto de 'conversacion_audio' (que son diálogos de dos hablantes,
-- se ven como chat) -- acá es una sola persona narrando, se ve como el
-- botón "Escuchar" de audio_secuencia (metadata simple: texto_en + voz,
-- no un array de turnos). El audio se genera y persiste en metadata igual
-- que las conversaciones (ver scripts/generar_audio_gramatica.py::sembrar_audio_frase).
ALTER TABLE ejercicios DROP CONSTRAINT chk_ejercicios_formato;
ALTER TABLE ejercicios ADD CONSTRAINT chk_ejercicios_formato
    CHECK (formato IN ('texto', 'audio_secuencia', 'conteo_visual', 'reloj_visual', 'conversacion_audio', 'audio_frase'));

UPDATE ejercicios e
SET formato = 'audio_frase',
    contexto_en = 'What date is the birthday party?',
    metadata = '{"texto_en": "My friend''s birthday party is on July fourth.", "voz": "af_heart"}'
FROM gramatica_temas t
WHERE e.tema_gramatica_id = t.id AND t.slug = 'fase-1-fecha'
  AND e.contexto_en = 'Her birthday is on July ___.';

UPDATE ejercicios e
SET formato = 'audio_frase',
    contexto_en = 'What date is grandma''s birthday party?',
    metadata = '{"texto_en": "My grandmother''s birthday party is on December twenty-fifth.", "voz": "af_heart"}'
FROM gramatica_temas t
WHERE e.tema_gramatica_id = t.id AND t.slug = 'fase-1-fecha'
  AND e.contexto_en = 'The party is on December ___.';
