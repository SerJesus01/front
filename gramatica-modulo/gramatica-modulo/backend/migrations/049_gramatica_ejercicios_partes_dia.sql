-- Ejercicios de preposición (at/in) para las fichas de "partes del día"
-- sembradas en la migración 046 -- formato='texto' (default de la columna,
-- ver migración 038), mismo mecanismo cloze que el resto del módulo, sin
-- visual especial.
INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'Completá con la preposición correcta (at/in).', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES
    ('I wake up ___ 6 AM.', 'at', ARRAY['at', 'in', 'on', 'by']),
    ('I go for a walk ___ the evening.', 'in', ARRAY['at', 'in', 'on', 'during']),
    ('We have lunch ___ noon.', 'at', ARRAY['at', 'in', 'on', 'by']),
    ('She reads ___ the morning.', 'in', ARRAY['at', 'in', 'on', 'from']),
    ('They go to bed ___ night.', 'at', ARRAY['at', 'in', 'on', 'by']),
    ('The shop closes ___ midnight.', 'at', ARRAY['at', 'in', 'on', 'before'])
) AS x(contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;
