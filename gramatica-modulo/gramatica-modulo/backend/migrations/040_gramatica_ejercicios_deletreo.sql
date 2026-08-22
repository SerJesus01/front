-- Ejercicio pedido por el dueño para "Abecedario y deletreo": escuchar
-- las letras deletreadas una por una (reusando el audio YA generado de
-- cada letra, migración 033 -- cero audio nuevo acá) y elegir entre
-- varias palabras cuál se deletreó. Dificultad creciente (3 a 10
-- letras). formato='audio_secuencia' (ver migración 038) -- el frontend
-- reproduce cada letra de metadata->secuencia en orden usando el audio_key
-- que el backend resuelve contra gramatica_contenido (ver
-- routers/gramatica.py::ejercicios_gramatica).
--
-- contexto_en queda como placeholder de guiones (largo de la palabra) en
-- vez de la palabra real -- nunca se muestra en este formato, pero evita
-- filtrar la respuesta en el JSON de /subtemas/{slug}/ejercicios si
-- alguien inspecciona la red antes de responder.
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'audio_secuencia', 'Escuchá el deletreo y elegí la palabra correcta.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    ('_ _ _', 'cat', ARRAY['cat', 'cap', 'can', 'hat'], '{"secuencia": ["C","A","T"]}'::jsonb, 'A1'),
    ('_ _ _ _ _', 'apple', ARRAY['apple', 'rice', 'america', 'grape'], '{"secuencia": ["A","P","P","L","E"]}'::jsonb, 'A1'),
    ('_ _ _ _ _ _', 'monkey', ARRAY['monkey', 'donkey', 'turkey', 'rabbit'], '{"secuencia": ["M","O","N","K","E","Y"]}'::jsonb, 'A2'),
    ('_ _ _ _ _ _ _ _', 'elephant', ARRAY['elephant', 'alligator', 'dinosaur', 'butterfly'], '{"secuencia": ["E","L","E","P","H","A","N","T"]}'::jsonb, 'A2'),
    ('_ _ _ _ _ _ _ _ _ _', 'helicopter', ARRAY['helicopter', 'television', 'restaurant', 'motorcycle'], '{"secuencia": ["H","E","L","I","C","O","P","T","E","R"]}'::jsonb, 'B1')
) AS x(contexto_en, respuesta_esperada, opciones, metadata, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-abecedario' AND t.parent_id IS NOT NULL;
