-- Pedido en vivo: mezclar listening también en "Hora y fecha", mismo
-- mecanismo que números (migración 043) -- reusa formato='audio_secuencia'
-- (migración 038) con una secuencia de UN solo token: la frase completa
-- ("twelve o'clock"), ya generada como fila de referencia en la migración
-- 046. Cero audio nuevo: _resolver_audio_secuencia (routers/gramatica.py)
-- busca el token tal cual contra gramatica_contenido.texto_en.
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'audio_secuencia', 'Escuchá la hora y elegí la frase correcta.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    ('_ _ _ _ _ _', 'twelve o''clock',
     ARRAY['eleven o''clock', 'twelve o''clock', 'one o''clock', 'twelve thirty'],
     '{"secuencia": ["twelve o''clock"]}'::jsonb, 'A1'),
    ('_ _ _ _ _ _', 'half past one',
     ARRAY['half past twelve', 'half past one', 'half past two', 'quarter past one'],
     '{"secuencia": ["half past one"]}'::jsonb, 'A1'),
    ('_ _ _ _ _ _', 'quarter to twelve',
     ARRAY['quarter past twelve', 'quarter to eleven', 'quarter to twelve', 'half past eleven'],
     '{"secuencia": ["quarter to twelve"]}'::jsonb, 'A2'),
    ('_ _ _ _ _ _', 'ten to four',
     ARRAY['ten past four', 'ten to four', 'ten to five', 'twenty to four'],
     '{"secuencia": ["ten to four"]}'::jsonb, 'B1')
) AS x(contexto_en, respuesta_esperada, opciones, metadata, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;
