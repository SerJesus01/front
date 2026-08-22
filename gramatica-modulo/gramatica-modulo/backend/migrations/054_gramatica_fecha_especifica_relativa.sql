-- Pedido en vivo: "Fecha" solo tenía el ejemplo de ''on Monday, July
-- 4th''. Se agregan dos bloques: fechas ESPECÍFICAS (cómo se lee un
-- ordinal de fecha en voz alta, "July 4th" -> "July fourth") y fechas
-- RELATIVAS (next week/month/year). Dos variantes nuevas (mismo criterio
-- genérico ya usado para reloj/partes del día, ver migración 045).
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN ('cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia', 'fecha_especifica', 'fecha_relativa'));

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A2', x.orden, x.variante
FROM (VALUES
    ('4 de julio',       'July fourth',          10, 'fecha_especifica'),
    ('1 de enero',       'January first',        11, 'fecha_especifica'),
    ('31 de octubre',    'October thirty-first', 12, 'fecha_especifica'),
    ('25 de diciembre',  'December twenty-fifth', 13, 'fecha_especifica'),
    ('la próxima semana', 'next week',  14, 'fecha_relativa'),
    ('el próximo mes',    'next month', 15, 'fecha_relativa'),
    ('el próximo año',    'next year',  16, 'fecha_relativa')
) AS x(texto_es, texto_en, orden, variante)
JOIN gramatica_temas t ON t.slug = 'fase-1-fecha' AND t.parent_id IS NOT NULL;

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    ('Completá cómo se lee la fecha en voz alta.', 'Her birthday is on July ___.', 'fourth', ARRAY['four', 'fourth', 'forth', 'fourteenth'], 'A2'),
    ('Completá cómo se lee la fecha en voz alta.', 'The party is on December ___.', 'twenty-fifth', ARRAY['twenty-five', 'twenty-fifth', 'twentieth', 'twenty-fourth'], 'A2'),
    ('Completá con la palabra correcta (fecha relativa).', 'Let''s meet ___ week, not this one.', 'next', ARRAY['next', 'last', 'this', 'the'], 'A1'),
    ('Completá con la palabra correcta (fecha relativa).', 'The trip is planned for ___ year.', 'next', ARRAY['next', 'last', 'this', 'on'], 'A1')
) AS x(consigna_es, contexto_en, respuesta_esperada, opciones, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-fecha' AND t.parent_id IS NOT NULL;
