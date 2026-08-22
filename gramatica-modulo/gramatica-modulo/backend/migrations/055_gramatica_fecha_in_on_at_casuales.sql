-- Pedido en vivo: dos reglas nuevas para "Fecha" -- (1) IN/ON/AT según
-- qué tan amplio es el período de tiempo (condensado del texto/tabla que
-- pasó el dueño a un párrafo, mismo formato que el resto de las reglas
-- del módulo -- acá no hay render de tablas, solo texto_es/texto_en), y
-- (2) expresiones casuales de día relativo (anteayer/pasado mañana/hace
-- X días...), con fichas de referencia nuevas (variante 'fecha_casual').
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN ('cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia', 'fecha_especifica', 'fecha_relativa', 'fecha_casual'));

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'regla', x.texto_es, x.texto_en, 'A2', x.orden
FROM (VALUES
    (
        'La preposición depende de qué tan amplio es el período: ''on'' para días y fechas completas (on Monday, on July 4th), ''in'' para meses, años, estaciones o décadas (in May, in 2026, in the summer), y ''at'' para horas o momentos concretos (at 5 PM, at midnight, at lunchtime).',
        'On Monday. In May. At midnight.', 3
    ),
    (
        'Para hablar de un día relativo al presente se usan expresiones fijas: ''the day before yesterday'' (anteayer), ''the day after tomorrow'' (pasado mañana), ''in + número + days'' (en X días, futuro), ''+ número + days + ago'' (hace X días, pasado), y ''a week from today'' (de hoy en una semana).',
        'I''ll be back in two days. I saw her three days ago.', 4
    )
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-fecha' AND t.parent_id IS NOT NULL;

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A2', x.orden, 'fecha_casual'
FROM (VALUES
    ('anteayer',              'the day before yesterday', 20),
    ('pasado mañana',         'the day after tomorrow',   21),
    ('en dos días',           'in two days',               22),
    ('hace tres días',        'three days ago',            23),
    ('de hoy en una semana',  'a week from today',         24),
    ('en un par de días',     'in a couple of days',       25),
    ('el martes que viene',   'this coming Tuesday',       26)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-fecha' AND t.parent_id IS NOT NULL;

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    ('Completá con la preposición correcta (in/on/at).', 'The meeting is ___ Monday.', 'on', ARRAY['on', 'in', 'at', 'for'], 'A2'),
    ('Completá con la preposición correcta (in/on/at).', 'School starts ___ September.', 'in', ARRAY['on', 'in', 'at', 'for'], 'A2'),
    ('Completá con la preposición correcta (in/on/at).', 'Let''s meet ___ 5 PM.', 'at', ARRAY['on', 'in', 'at', 'for'], 'A2'),
    ('Completá con la preposición correcta (in/on/at).', 'It gets cold ___ winter.', 'in', ARRAY['on', 'in', 'at', 'for'], 'A2'),
    ('Completá con la preposición correcta (in/on/at).', 'Wake me up ___ midnight.', 'at', ARRAY['on', 'in', 'at', 'for'], 'A2'),
    ('Completá la expresión de día relativo.', 'I bought this the day ___ yesterday.', 'before', ARRAY['before', 'after', 'from', 'ago'], 'A2'),
    ('Completá la expresión de día relativo.', 'Let''s meet the day ___ tomorrow.', 'after', ARRAY['before', 'after', 'from', 'ago'], 'A2'),
    ('Completá la expresión de día relativo.', 'I saw her three days ___.', 'ago', ARRAY['ago', 'in', 'before', 'from'], 'A2'),
    ('Completá la expresión de día relativo.', 'The event is a week ___ today.', 'from', ARRAY['from', 'in', 'ago', 'after'], 'A2'),
    ('Completá la expresión de día relativo.', 'Are you free ___ coming Tuesday?', 'this', ARRAY['this', 'next', 'the', 'on'], 'A2')
) AS x(consigna_es, contexto_en, respuesta_esperada, opciones, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-fecha' AND t.parent_id IS NOT NULL;
