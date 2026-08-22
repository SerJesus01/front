-- Pedido en vivo: "Pronombres sujeto y objeto" no tenía la lista real
-- (I, you, she, he...) -- solo regla + ejemplos, sin fichas de
-- referencia. Se fusiona con "Posesivos básicos" en un solo subtema
-- (mismo criterio que Hora 1+2 / to be, migraciones 053/057) y se agrega
-- una tabla de 4 columnas (sujeto/objeto/posesivo adjetivo/posesivo
-- pronombre) -- mismo patrón visual que la tabla de números
-- (numeral/cardinal/ordinal), pero con 4 columnas en vez de 3.
--
-- 4 variantes nuevas, una por columna -- las 7 filas de cada variante
-- comparten el mismo `orden` relativo (1..7 = I/you/he/she/it/we/they)
-- para que el frontend pueda alinear las 4 columnas por persona (join
-- por `orden`, no por texto -- a diferencia de números, acá texto_es
-- cambia en cada columna, no hay un numeral común que extraer).
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN (
        'cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia',
        'fecha_especifica', 'fecha_relativa', 'fecha_casual',
        'pron_sujeto', 'pron_objeto', 'pron_posesivo_adj', 'pron_posesivo_pron'
    ));

UPDATE gramatica_contenido gc
SET tema_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE gc.tema_id = origen.id AND origen.slug = 'fase-2-posesivos-basicos'
  AND destino.slug = 'fase-2-pronombres-sujeto-objeto';

UPDATE ejercicios e
SET tema_gramatica_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE e.tema_gramatica_id = origen.id AND origen.slug = 'fase-2-posesivos-basicos'
  AND destino.slug = 'fase-2-pronombres-sujeto-objeto';

UPDATE gramatica_temas SET nombre = 'Pronombres y posesivos' WHERE slug = 'fase-2-pronombres-sujeto-objeto';

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, x.variante
FROM (VALUES
    ('yo',     'I',     1, 'pron_sujeto'), ('tú/usted', 'you',  2, 'pron_sujeto'), ('él',  'he',  3, 'pron_sujeto'),
    ('ella',   'she',   4, 'pron_sujeto'), ('eso',      'it',   5, 'pron_sujeto'), ('nosotros', 'we', 6, 'pron_sujeto'),
    ('ellos/ellas', 'they', 7, 'pron_sujeto'),

    ('a mí',   'me',    1, 'pron_objeto'), ('a ti/usted', 'you', 2, 'pron_objeto'), ('a él', 'him', 3, 'pron_objeto'),
    ('a ella', 'her',   4, 'pron_objeto'), ('a eso',      'it',  5, 'pron_objeto'), ('a nosotros', 'us', 6, 'pron_objeto'),
    ('a ellos/ellas', 'them', 7, 'pron_objeto'),

    ('mi',     'my',    1, 'pron_posesivo_adj'), ('tu/su', 'your', 2, 'pron_posesivo_adj'), ('su (de él)', 'his', 3, 'pron_posesivo_adj'),
    ('su (de ella)', 'her', 4, 'pron_posesivo_adj'), ('su (de eso)', 'its', 5, 'pron_posesivo_adj'), ('nuestro', 'our', 6, 'pron_posesivo_adj'),
    ('su (de ellos)', 'their', 7, 'pron_posesivo_adj'),

    ('mío/mía', 'mine', 1, 'pron_posesivo_pron'), ('tuyo/suyo', 'yours', 2, 'pron_posesivo_pron'), ('suyo (de él)', 'his', 3, 'pron_posesivo_pron'),
    ('suyo (de ella)', 'hers', 4, 'pron_posesivo_pron'), ('nuestro (pron.)', 'ours', 6, 'pron_posesivo_pron'),
    ('suyo (de ellos)', 'theirs', 7, 'pron_posesivo_pron')
    -- "it" (orden 5) no tiene pronombre posesivo real en inglés -- se
    -- deja sin fila, mismo criterio que los hitos de miles sin ordinal
    -- (migración 039): la celda queda vacía en la tabla, no rota nada.
) AS x(texto_es, texto_en, orden, variante)
JOIN gramatica_temas t ON t.slug = 'fase-2-pronombres-sujeto-objeto' AND t.parent_id IS NOT NULL;
