-- fase-9-ubicacion-basica y fase-17-preposiciones-lugar habían quedado
-- sembradas con los MISMOS 2 ejemplos (bootstrap de la migración 067,
-- densidad inicial pareja para todo Fases 10-17) -- el dueño lo notó al
-- revisar la app: "básica" y "avanzada" eran idénticas. Se diferencian:
-- Fase 9 se queda con preposiciones simples de una sola relación
-- (on/under/in/above/behind/next to, un objeto contra un punto de
-- referencia); Fase 17 pasa a preposiciones relativas entre VARIOS
-- objetos (between/across from/among/opposite), genuinamente más
-- avanzadas porque exigen ubicar un objeto respecto a dos o más
-- referencias a la vez.

-- Fase 9: el ejemplo "between" (id 91) se reemplaza por uno de relación
-- simple ("under") -- ese texto se va a Fase 17 en su lugar. Se limpia
-- su imagen_key (apuntaba a escena_puertas_entre, que es la escena de
-- "entre dos puertas", ya no corresponde a este ejemplo).
UPDATE gramatica_contenido
SET texto_es = 'Ubicación debajo de algo',
    texto_en = 'The cat is under the table.',
    imagen_key = NULL,
    audio_key = NULL
WHERE id = 91;

-- Fase 9: 2 ejemplos nuevos, misma familia de preposición simple.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, idioma, orden)
SELECT t.id, 'ejemplo', 'Ubicación dentro de un espacio cerrado', 'The keys are in the drawer.', 'A1', 'en', 4
FROM gramatica_temas t WHERE t.slug = 'fase-9-ubicacion-basica'
UNION ALL
SELECT t.id, 'ejemplo', 'Ubicación arriba de algo', 'The picture is above the sofa.', 'A1', 'en', 5
FROM gramatica_temas t WHERE t.slug = 'fase-9-ubicacion-basica';

-- Fase 17: 3 ejemplos nuevos, preposiciones relativas entre varios
-- objetos (más avanzadas que las de Fase 9 en la exigencia de ubicar un
-- objeto contra dos referencias).
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, idioma, orden)
SELECT t.id, 'ejemplo', 'Ubicación al otro lado de la calle, frente a algo', 'The pharmacy is across from the bank.', 'A2', 'en', 4
FROM gramatica_temas t WHERE t.slug = 'fase-17-preposiciones-lugar'
UNION ALL
SELECT t.id, 'ejemplo', 'Ubicación en medio de un grupo de más de dos elementos', 'The cushion is among the pillows on the sofa.', 'A2', 'en', 5
FROM gramatica_temas t WHERE t.slug = 'fase-17-preposiciones-lugar'
UNION ALL
SELECT t.id, 'ejemplo', 'Ubicación justo enfrente de algo, del otro lado', 'The gym is opposite the supermarket.', 'A2', 'en', 6
FROM gramatica_temas t WHERE t.slug = 'fase-17-preposiciones-lugar';
