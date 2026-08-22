-- Ejercicio pedido por el dueño: la palabra en inglés escrita, elegir el
-- numeral correcto entre opciones -- reusa el mismo mecanismo de 'cloze'
-- + `opciones` que ya usan el resto de los ejercicios de Gramática (ver
-- migración 032), sin ningún cambio de schema: el "hueco" acá es
-- conceptual (elegir el numeral, no completar una oración), `contexto_en`
-- simplemente no tiene "___" -- el frontend ya maneja ese caso (ver
-- GramaticaView.vue: si no matchea el regex de hueco, muestra el texto
-- completo tal cual).
INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'Elegí el numeral correcto para esta palabra.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES
    ('one hundred', '100', ARRAY['10', '100', '1,000', '1,000,000']),
    ('one thousand', '1,000', ARRAY['100', '1,000', '10,000', '100,000']),
    ('ten thousand', '10,000', ARRAY['1,000', '10,000', '100,000', '1,000,000']),
    ('one hundred thousand', '100,000', ARRAY['10,000', '100,000', '1,000,000', '1,000']),
    ('one million', '1,000,000', ARRAY['100,000', '1,000,000', '10,000,000', '1,000'])
) AS x(contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
