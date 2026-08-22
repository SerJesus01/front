-- ===========================================================================
-- Siembra de la taxonomía completa de Gramática: 18 Fases (parent_id NULL)
-- + sus subtemas (parent_id = Fase), jerarquía de 2 niveles idéntica al
-- patrón de `hashtags` que ya usa vocabulario por interés.
--
-- El índice de las 18 Fases NO es una escala inventada -- se investigó la
-- tabla de contenidos real de "Essential Grammar in Use" (Raymond Murphy,
-- Cambridge, A1-B1), que ya agrupa sus 115 unidades en 18 bloques
-- temáticos probados con décadas de uso real -- esa agrupación es
-- literalmente el molde de "Fase" de acá. Se agregaron 3 Fases propias que
-- el libro no cubre por pedido explícito del dueño (Fase 1 Fundamentos,
-- el bloque de conectores secuenciales tipo receta dentro de la Fase 16,
-- y la Fase 18 de vocabulario situacional). Ver memoria del proyecto para
-- el detalle completo de fuentes y las 2 rondas de validación con Fable.
--
-- Orden de Fases: prioridad pedagógica (no orden del libro tal cual) --
-- corrección de Fable tras aclarar el dueño que este módulo es la BASE que
-- el resto de la app da por sabida (vocabulario técnico usa "past_simple"/
-- "modal"/"conditional_1" como ETIQUETA, nunca explica la regla) -- por
-- eso to be/pronombres/artículos/modales/condicionales/pasiva van antes
-- que preposiciones/vocabulario situacional, aunque el libro real las
-- ponga más adelante.
-- ===========================================================================

INSERT INTO gramatica_temas (nombre, slug, orden) VALUES
    ('Fundamentos',                              'fase-1-fundamentos',              1),
    ('Verbo to be y pronombres básicos',         'fase-2-to-be-pronombres',         2),
    ('Presente',                                 'fase-3-presente',                 3),
    ('Pasado',                                   'fase-4-pasado',                   4),
    ('Presente perfecto',                        'fase-5-presente-perfecto',        5),
    ('Voz pasiva',                                'fase-6-voz-pasiva',               6),
    ('Futuro',                                   'fase-7-futuro',                   7),
    ('Modales e imperativo',                     'fase-8-modales-imperativo',       8),
    ('There is / there are y ubicación',         'fase-9-there-is-are',             9),
    ('Preguntas y negación',                     'fase-10-preguntas-negacion',      10),
    ('Gerundio vs. infinitivo',                  'fase-11-gerundio-infinitivo',     11),
    ('Pronombres y posesivos',                   'fase-12-pronombres-posesivos',    12),
    ('Artículos y contables/incontables',        'fase-13-articulos-contables',     13),
    ('Determinantes y cuantificadores',          'fase-14-determinantes',           14),
    ('Adjetivos y adverbios',                    'fase-15-adjetivos-adverbios',     15),
    ('Conectores y cláusulas',                   'fase-16-conectores-clausulas',    16),
    ('Preposiciones',                            'fase-17-preposiciones',           17),
    ('Vocabulario situacional',                  'fase-18-vocabulario-situacional', 18)
ON CONFLICT (idioma, slug) DO NOTHING;

-- ─── Subtemas por Fase (parent_id resuelto por slug de la Fase) ───
INSERT INTO gramatica_temas (nombre, slug, parent_id, orden)
SELECT x.nombre, x.slug, f.id, x.orden
FROM (VALUES
    -- Fase 1: Fundamentos
    ('fase-1-fundamentos', 'Abecedario y deletreo',   'fase-1-abecedario',   1),
    ('fase-1-fundamentos', 'Números',                 'fase-1-numeros',      2),
    ('fase-1-fundamentos', 'Hora y fecha',             'fase-1-hora-fecha',   3),

    -- Fase 2: Verbo to be y pronombres básicos
    ('fase-2-to-be-pronombres', 'Verbo to be (afirmativo)',   'fase-2-to-be-afirmativo',        1),
    ('fase-2-to-be-pronombres', 'Verbo to be (negativo)',     'fase-2-to-be-negativo',          2),
    ('fase-2-to-be-pronombres', 'Verbo to be (preguntas)',    'fase-2-to-be-preguntas',         3),
    ('fase-2-to-be-pronombres', 'Pronombres sujeto y objeto', 'fase-2-pronombres-sujeto-objeto', 4),
    ('fase-2-to-be-pronombres', 'Posesivos básicos',          'fase-2-posesivos-basicos',       5),

    -- Fase 3: Presente
    ('fase-3-presente', 'Presente simple',                          'fase-3-presente-simple',    1),
    ('fase-3-presente', 'Presente continuo',                        'fase-3-presente-continuo',  2),
    ('fase-3-presente', 'Presente simple vs. presente continuo',    'fase-3-simple-vs-continuo', 3),

    -- Fase 4: Pasado
    ('fase-4-pasado', 'was / were',        'fase-4-was-were',        1),
    ('fase-4-pasado', 'Pasado simple',     'fase-4-pasado-simple',   2),
    ('fase-4-pasado', 'Pasado continuo',   'fase-4-pasado-continuo', 3),

    -- Fase 5: Presente perfecto
    ('fase-5-presente-perfecto', 'Presente perfecto (introducción)',       'fase-5-perfecto-intro',       1),
    ('fase-5-presente-perfecto', 'just / already / yet',                  'fase-5-just-already-yet',     2),
    ('fase-5-presente-perfecto', 'ever / how long',                       'fase-5-ever-how-long',        3),
    ('fase-5-presente-perfecto', 'for / since / ago',                     'fase-5-for-since-ago',        4),
    ('fase-5-presente-perfecto', 'Presente perfecto vs. pasado simple',   'fase-5-perfecto-vs-pasado',   5),

    -- Fase 6: Voz pasiva
    ('fase-6-voz-pasiva', 'Voz pasiva (presente)', 'fase-6-pasiva-presente', 1),
    ('fase-6-voz-pasiva', 'Voz pasiva (pasado)',   'fase-6-pasiva-pasado',   2),

    -- Fase 7: Futuro
    ('fase-7-futuro', 'going to',                                  'fase-7-going-to',        1),
    ('fase-7-futuro', 'will / shall',                              'fase-7-will-shall',      2),
    ('fase-7-futuro', 'Presente continuo con valor de futuro',     'fase-7-continuo-futuro', 3),

    -- Fase 8: Modales e imperativo
    ('fase-8-modales-imperativo', 'can / could',    'fase-8-can-could',      1),
    ('fase-8-modales-imperativo', 'must / have to', 'fase-8-must-have-to',   2),
    ('fase-8-modales-imperativo', 'should',         'fase-8-should',         3),
    ('fase-8-modales-imperativo', 'would like',     'fase-8-would-like',    4),
    ('fase-8-modales-imperativo', 'Imperativo',     'fase-8-imperativo',    5),

    -- Fase 9: There is / there are y ubicación
    ('fase-9-there-is-are', 'there is / there are',              'fase-9-there-is-there-are', 1),
    ('fase-9-there-is-are', 'Preposiciones de ubicación básicas', 'fase-9-ubicacion-basica',   2),

    -- Fase 10: Preguntas y negación
    ('fase-10-preguntas-negacion', 'Wh-questions',           'fase-10-wh-questions',        1),
    ('fase-10-preguntas-negacion', 'Question tags',         'fase-10-question-tags',       2),
    ('fase-10-preguntas-negacion', 'Preguntas indirectas',  'fase-10-preguntas-indirectas', 3),

    -- Fase 11: Gerundio vs. infinitivo
    ('fase-11-gerundio-infinitivo', 'Verbo + -ing', 'fase-11-verbo-ing', 1),
    ('fase-11-gerundio-infinitivo', 'Verbo + to',   'fase-11-verbo-to',  2),

    -- Fase 12: Pronombres y posesivos (profundización)
    ('fase-12-pronombres-posesivos', 'Pronombres reflexivos', 'fase-12-reflexivos',       1),
    ('fase-12-pronombres-posesivos', 'whose / mine / yours', 'fase-12-whose-mine-yours', 2),
    ('fase-12-pronombres-posesivos', 'Posesivo ''s',          'fase-12-posesivo-s',       3),

    -- Fase 13: Artículos y contables/incontables
    ('fase-13-articulos-contables', 'a / an / the',              'fase-13-a-an-the',            1),
    ('fase-13-articulos-contables', 'Contables e incontables',   'fase-13-contables-incontables', 2),
    ('fase-13-articulos-contables', 'some / any',                'fase-13-some-any',            3),

    -- Fase 14: Determinantes y cuantificadores
    ('fase-14-determinantes', 'this / that / these / those', 'fase-14-this-that',           1),
    ('fase-14-determinantes', 'every / all',                 'fase-14-every-all',           2),
    ('fase-14-determinantes', 'both / either / neither',     'fase-14-both-either-neither', 3),
    ('fase-14-determinantes', 'much / many',                 'fase-14-much-many',           4),
    ('fase-14-determinantes', 'a little / a few',            'fase-14-little-few',          5),

    -- Fase 15: Adjetivos y adverbios
    ('fase-15-adjetivos-adverbios', 'Orden de adjetivos',      'fase-15-orden-adjetivos',    1),
    ('fase-15-adjetivos-adverbios', 'Comparativos',            'fase-15-comparativos',       2),
    ('fase-15-adjetivos-adverbios', 'Superlativos',            'fase-15-superlativos',       3),
    ('fase-15-adjetivos-adverbios', 'Adverbios de modo',       'fase-15-adverbios-modo',     4),
    ('fase-15-adjetivos-adverbios', 'Adverbios de frecuencia', 'fase-15-adverbios-frecuencia', 5),

    -- Fase 16: Conectores y cláusulas (incluye el bloque de conectores
    -- secuenciales tipo receta pedido explícitamente por el dueño)
    ('fase-16-conectores-clausulas', 'Conectores de adición',     'fase-16-conectores-adicion',      1),
    ('fase-16-conectores-clausulas', 'Conectores causales',       'fase-16-conectores-causales',     2),
    ('fase-16-conectores-clausulas', 'Conectores de contraste',   'fase-16-conectores-contraste',    3),
    ('fase-16-conectores-clausulas', 'Conectores secuenciales',   'fase-16-conectores-secuenciales', 4),
    ('fase-16-conectores-clausulas', 'Condicionales con if',      'fase-16-condicionales-if',        5),
    ('fase-16-conectores-clausulas', 'Cláusulas relativas',       'fase-16-clausulas-relativas',     6),

    -- Fase 17: Preposiciones
    ('fase-17-preposiciones', 'Preposiciones de tiempo',    'fase-17-preposiciones-tiempo',      1),
    ('fase-17-preposiciones', 'Preposiciones de lugar',     'fase-17-preposiciones-lugar',       2),
    ('fase-17-preposiciones', 'Preposiciones de dirección', 'fase-17-preposiciones-direccion',   3),

    -- Fase 18: Vocabulario situacional (vive acá como Fase, pero su
    -- contenido real cuelga de `vocabulario`, no de gramatica_contenido)
    ('fase-18-vocabulario-situacional', 'Familia y árbol genealógico', 'fase-18-familia',       1),
    ('fase-18-vocabulario-situacional', 'Rutina diaria',              'fase-18-rutina-diaria', 2)
) AS x(fase_slug, nombre, slug, orden)
JOIN gramatica_temas f ON f.slug = x.fase_slug AND f.parent_id IS NULL
ON CONFLICT (idioma, slug) DO NOTHING;
