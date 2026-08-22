-- Feedback en vivo: los 4 hitos de miles con separador (1.000, 10.000,
-- 100.000, 1.000.000, ver migraciones 035/036) usaban el separador de
-- miles en ESPAÑOL (punto) -- inconsistente con los ejercicios de
-- "elegir el numeral" (migración 037), que ya usaban coma ('1,000',
-- '10,000'...) porque el contenido es en INGLÉS, donde el separador de
-- miles es coma. Se corrigen las 4 fichas para que coincidan.
-- '100' (sin separador) no cambia.
UPDATE gramatica_contenido gc
SET texto_es = '1,000'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'one thousand' AND gc.tipo = 'referencia';

UPDATE gramatica_contenido gc
SET texto_es = '10,000'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'ten thousand' AND gc.tipo = 'referencia';

UPDATE gramatica_contenido gc
SET texto_es = '100,000'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'one hundred thousand' AND gc.tipo = 'referencia';

UPDATE gramatica_contenido gc
SET texto_es = '1,000,000'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.texto_en = 'one million' AND gc.tipo = 'referencia';
