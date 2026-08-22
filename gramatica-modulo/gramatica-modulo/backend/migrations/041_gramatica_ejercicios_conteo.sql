-- Ejercicio pedido por el dueño para "Números": contar objetos en un
-- "rectángulo" visual (emojis repetidos, sin necesidad de imágenes
-- reales/assets -- más atractivo que solo texto, mismo mecanismo cloze +
-- opciones que el resto) y elegir el numeral correcto. formato='conteo_visual'
-- (ver migración 038); metadata trae emoji + cantidad explícitos (no se
-- derivan de respuesta_esperada por parseo, para no acoplar el render al
-- formato exacto de la respuesta).
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'conteo_visual', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, 'A1', 'en'
FROM (VALUES
    ('Contá cuántas manzanas hay y elegí el número correcto.', 'How many apples are there?', '4', ARRAY['3', '4', '5', '6'], '{"emoji": "🍎", "cantidad": 4}'::jsonb),
    ('Contá cuántas monedas hay y elegí el número correcto.', 'How many coins are there?', '7', ARRAY['6', '7', '8', '9'], '{"emoji": "🪙", "cantidad": 7}'::jsonb),
    ('Contá cuántas estrellas hay y elegí el número correcto.', 'How many stars are there?', '11', ARRAY['10', '11', '12', '13'], '{"emoji": "⭐", "cantidad": 11}'::jsonb),
    ('Contá cuántos globos hay y elegí el número correcto.', 'How many balloons are there?', '15', ARRAY['14', '15', '16', '17'], '{"emoji": "🎈", "cantidad": 15}'::jsonb),
    ('Contá cuántos peces hay y elegí el número correcto.', 'How many fish are there?', '19', ARRAY['18', '19', '20', '21'], '{"emoji": "🐟", "cantidad": 19}'::jsonb)
) AS x(consigna_es, contexto_en, respuesta_esperada, opciones, metadata)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
