-- Pedido en vivo: mezclar listening también en los ejercicios de
-- números, no solo en abecedario. Reusa exactamente el mismo formato
-- 'audio_secuencia' del deletreo (migración 038/040) -- acá la
-- "secuencia" tiene un solo token (la palabra del número, ya generada
-- en la grilla de cardinales, ver migración 034), en vez de varias
-- letras. Cero código nuevo en backend/frontend: _resolver_audio_secuencia
-- y el botón "Escuchar" (ver GramaticaView.vue) ya soportan cualquier
-- largo de secuencia.
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'audio_secuencia', 'Escuchá el número y elegí la palabra correcta.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, 'A1', 'en'
FROM (VALUES
    ('_ _ _ _ _', 'three', ARRAY['two', 'three', 'four', 'five'], '{"secuencia": ["three"]}'::jsonb),
    ('_ _ _ _ _', 'eight', ARRAY['seven', 'eight', 'nine', 'ten'], '{"secuencia": ["eight"]}'::jsonb),
    ('_ _ _ _ _ _', 'twelve', ARRAY['eleven', 'twelve', 'thirteen', 'fourteen'], '{"secuencia": ["twelve"]}'::jsonb),
    ('_ _ _ _ _ _ _', 'sixteen', ARRAY['fifteen', 'sixteen', 'seventeen', 'eighteen'], '{"secuencia": ["sixteen"]}'::jsonb),
    ('_ _ _ _ _ _', 'twenty', ARRAY['seventeen', 'eighteen', 'nineteen', 'twenty'], '{"secuencia": ["twenty"]}'::jsonb)
) AS x(contexto_en, respuesta_esperada, opciones, metadata)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
