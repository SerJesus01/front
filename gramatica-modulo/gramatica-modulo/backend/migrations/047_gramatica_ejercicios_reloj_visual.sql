-- Ejercicio pedido por el dueño: mostrar un reloj analógico (dibujado en
-- CSS a partir de metadata.hora/metadata.minuto, formato='reloj_visual',
-- ver migración 045) y elegir la frase en inglés correcta -- mismo
-- mecanismo cloze + opciones que conteo_visual (migración 041), sin
-- assets/imágenes. Dos ejercicios por estilo (en_punto/media/cuarto/
-- minutos), mismo orden de dificultad que las fichas de referencia
-- (migración 046). contexto_en queda como pregunta genérica -- no se
-- renderiza en este formato (el frontend solo dibuja el reloj), mismo
-- criterio que el placeholder de deletreo (migración 040).
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'reloj_visual', 'Mirá el reloj y elegí la hora correcta.', 'What time is it?', x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    ('three o''clock', ARRAY['two o''clock', 'three o''clock', 'four o''clock', 'three thirty'], '{"hora": 3, "minuto": 0}'::jsonb, 'A1'),
    ('nine o''clock',  ARRAY['eight o''clock', 'nine o''clock', 'ten o''clock', 'nine thirty'],  '{"hora": 9, "minuto": 0}'::jsonb, 'A1'),
    ('half past four', ARRAY['half past three', 'half past four', 'half past five', 'quarter past four'], '{"hora": 4, "minuto": 30}'::jsonb, 'A1'),
    ('half past ten',  ARRAY['half past nine', 'half past ten', 'half past eleven', 'quarter to ten'],    '{"hora": 10, "minuto": 30}'::jsonb, 'A1'),
    ('quarter past two',  ARRAY['quarter to two', 'half past two', 'quarter past two', 'quarter past three'], '{"hora": 2, "minuto": 15}'::jsonb, 'A2'),
    ('quarter to seven',  ARRAY['quarter past six', 'quarter to six', 'half past six', 'quarter to seven'],  '{"hora": 6, "minuto": 45}'::jsonb, 'A2'),
    ('ten past five',  ARRAY['five past five', 'ten past five', 'ten to five', 'twenty past five'], '{"hora": 5, "minuto": 10}'::jsonb, 'B1'),
    ('twenty to ten',  ARRAY['twenty past nine', 'ten to ten', 'twenty to nine', 'twenty to ten'],  '{"hora": 9, "minuto": 40}'::jsonb, 'B1')
) AS x(respuesta_esperada, opciones, metadata, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;
