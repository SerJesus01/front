-- Pedido en vivo: fusionar los 3 subtemas de "to be" (afirmativo/
-- negativo/preguntas) en uno solo -- mismo criterio que la fusión de
-- Hora 1+2 (migración 053): se reusa el tema 'afirmativo' como el
-- unificado, se mueve el resto ahí, los subtemas viejos quedan vacíos y
-- desaparecen solos del listado.
--
-- A diferencia de Hora 1+2 (donde las 2 reglas eran redundantes), acá las
-- 3 reglas son COMPLEMENTARIAS (afirmativo/negativo/preguntas son 3
-- explicaciones distintas) -- se mueven las 9 filas (3 regla + 6 ejemplo)
-- tal cual, sin borrar ninguna.
UPDATE gramatica_contenido gc
SET tema_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE gc.tema_id = origen.id AND origen.slug IN ('fase-2-to-be-negativo', 'fase-2-to-be-preguntas')
  AND destino.slug = 'fase-2-to-be-afirmativo';

UPDATE ejercicios e
SET tema_gramatica_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE e.tema_gramatica_id = origen.id AND origen.slug IN ('fase-2-to-be-negativo', 'fase-2-to-be-preguntas')
  AND destino.slug = 'fase-2-to-be-afirmativo';

UPDATE gramatica_temas SET nombre = 'Verbo to be' WHERE slug = 'fase-2-to-be-afirmativo';

-- Pedido en vivo: agregar la estructura de WH-questions (how -> cómo,
-- con ejemplo, y la gramática WH + to be + subject) -- regla dedicada +
-- fichas sueltas de cada palabra WH (referencia, sin variante -- entran
-- en la grilla simple igual que el abecedario) + ejemplos de la
-- estructura completa (reusa tipo='ejemplo', cero frontend nuevo).
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'regla', 'Para preguntar con una palabra WH, la estructura es: WH + to be + sujeto. La palabra WH siempre va primero, después el verbo, después quien pregunta.', 'What is this? Where are you? How is the project going?', 'A1', 20
FROM gramatica_temas t WHERE t.slug = 'fase-2-to-be-afirmativo' AND t.parent_id IS NOT NULL;

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES ('qué', 'what', 21), ('dónde', 'where', 22), ('cuándo', 'when', 23), ('por qué', 'why', 24), ('quién', 'who', 25), ('cómo', 'how', 26))
    AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-2-to-be-afirmativo' AND t.parent_id IS NOT NULL;

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'ejemplo', x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('Preguntar qué es algo',            'What is this?', 27),
    ('Preguntar dónde está alguien',     'Where are you?', 28),
    ('Preguntar cuándo es algo',         'When is the meeting?', 29),
    ('Preguntar por qué pasa algo',      'Why is the server down?', 30),
    ('Preguntar quién está disponible',  'Who is available?', 31),
    ('Preguntar cómo va algo',           'How is the project going?', 32)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-2-to-be-afirmativo' AND t.parent_id IS NOT NULL;

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'Completá con la palabra WH correcta.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES
    ('___ is the meeting?', 'Where', ARRAY['Where', 'What', 'When', 'Who']),
    ('___ is your name?', 'What', ARRAY['What', 'Who', 'Where', 'How']),
    ('___ are you? -- I''m doing great.', 'How', ARRAY['How', 'What', 'Why', 'When']),
    ('___ is the deploy scheduled?', 'When', ARRAY['When', 'Where', 'Who', 'What'])
) AS x(contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = 'fase-2-to-be-afirmativo' AND t.parent_id IS NOT NULL;
