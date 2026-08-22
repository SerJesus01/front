-- Primer caso real de StudentBook dinámico (Fase 2 del plan): predicción
-- antes de revelar la regla + tabla de asociación, aplicado a los dos
-- subtemas que el dueño usó como ejemplo concreto al pedir esto
-- (fase-4-was-were, fase-9-there-is-there-are).
--
-- Orden en pantalla (ver GramaticaView.vue): predicción primero (orden
-- bajo, antes de la regla existente que ya tiene orden 1), tabla de
-- asociación como fichas 'referencia' (después de la regla, mismo lugar
-- que cualquier otra tabla), sin tocar los ejemplos ya sembrados.

-- ─── Predicción (tipo='prediccion', metadata={"opciones":[...],"correcta":idx}) ───

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, metadata)
SELECT t.id, 'prediccion', x.texto_es, x.texto_en, 'A1', 0, x.metadata::jsonb
FROM (VALUES
    ('fase-4-was-were',
     '¿Por qué creés que se dice "was" acá y no "is" o "were"?',
     'I was at the office yesterday.',
     '{"opciones": ["Porque \"I\" en pasado siempre usa \"was\"", "Porque \"yesterday\" obliga a esa forma", "Es una regla de cortesía en inglés formal"], "correcta": 0}'),
    ('fase-9-there-is-there-are',
     '¿Por qué creés que se dice "There''s a chair" y no "It is a chair"?',
     'There''s a chair behind the desk.',
     '{"opciones": ["Porque anuncia que algo existe, sin ser el foco de la oración", "Porque \"chair\" es un objeto y no una persona", "Porque la oración empieza con \"There\""], "correcta": 0}')
) AS x(subtema_slug, texto_es, texto_en, metadata)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;

-- ─── Tabla was/were: pron_sujeto + tobe_pasado, alineadas por `orden` 1..7 ───
-- (I/you/he/she/it/we/they -- mismo orden que ya usa la tabla de
-- pronombres de fase-2-pronombres-sujeto-objeto, migración 058, pero acá
-- vive DENTRO de este subtema porque el frontend arma cada tabla con el
-- contenido cargado de un solo subtema a la vez, no cruza subtemas).

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, x.variante
FROM (VALUES
    ('yo', 'I', 1, 'pron_sujeto'), ('tú/usted', 'you', 2, 'pron_sujeto'), ('él', 'he', 3, 'pron_sujeto'),
    ('ella', 'she', 4, 'pron_sujeto'), ('eso', 'it', 5, 'pron_sujeto'), ('nosotros', 'we', 6, 'pron_sujeto'),
    ('ellos/ellas', 'they', 7, 'pron_sujeto'),

    ('pasado', 'was', 1, 'tobe_pasado'), ('pasado', 'were', 2, 'tobe_pasado'), ('pasado', 'was', 3, 'tobe_pasado'),
    ('pasado', 'was', 4, 'tobe_pasado'), ('pasado', 'was', 5, 'tobe_pasado'), ('pasado', 'were', 6, 'tobe_pasado'),
    ('pasado', 'were', 7, 'tobe_pasado')
) AS x(texto_es, texto_en, orden, variante)
JOIN gramatica_temas t ON t.slug = 'fase-4-was-were' AND t.parent_id IS NOT NULL;

-- ─── Tabla there is/there are: forma + uso, 2 filas ───

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, 'there_forma'
FROM (VALUES
    ('una sola cosa (singular)', 'there is / there''s', 1),
    ('dos o más cosas (plural)', 'there are', 2)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-9-there-is-there-are' AND t.parent_id IS NOT NULL;
