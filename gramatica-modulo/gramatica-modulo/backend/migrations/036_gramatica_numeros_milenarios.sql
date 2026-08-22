-- Ampliación pedida por el dueño tras ver la migración 035: además de
-- 100/10.000/1.000.000 (los únicos "hitos" sembrados ahí), agrega
-- 1.000 y 100.000 -- la secuencia completa de hitos redondos que se usa
-- para ENSEÑAR cómo el inglés agrupa números grandes (compositivo:
-- "one hundred thousand", no una palabra sola como el "cien mil" del
-- español). texto_es pasa a ser el NUMERAL puro (sin el prefijo
-- "Número ") para estos 5 hitos -- el frontend lo usa como subtítulo
-- bajo la palabra en inglés cuando detecta que es solo dígitos/puntos,
-- a diferencia de "Número 1".."Número 20" que siguen con su texto_es
-- descriptivo (no hace falta reforzar el numeral en los primeros 20,
-- ya son obvios).
UPDATE gramatica_contenido gc
SET texto_es = '100', orden = 24
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'one hundred';

UPDATE gramatica_contenido gc
SET texto_es = '10.000', orden = 26
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'ten thousand';

UPDATE gramatica_contenido gc
SET texto_es = '1.000.000', orden = 28
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'one million';

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('1.000', 'one thousand', 25),
    ('100.000', 'one hundred thousand', 27)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
