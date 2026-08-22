-- Fichas de referencia de "Hora y fecha" -- mismo patrón que abecedario/
-- números (migraciones 033/034): tipo='referencia', texto_es = forma
-- digital ("9:45"), texto_en = frase hablada ("quarter to ten"), audio
-- pendiente de scripts/generar_audio_gramatica.py. `orden` continúa desde
-- 4 (la Fase ya tiene 1 regla + 2 ejemplos sembrados en orden 1-3, ver
-- migración 031).
--
-- Cuatro estilos (variante en_punto/media/cuarto/minutos, ver migración
-- 045), 4 horas de ejemplo cada uno -- suficiente variedad para el
-- studentbook y para sortear ejercicios/listening sin agotar el banco.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, x.variante
FROM (VALUES
    -- En punto
    ('12:00', 'twelve o''clock', 4, 'en_punto'),
    ('3:00',  'three o''clock',  5, 'en_punto'),
    ('7:00',  'seven o''clock',  6, 'en_punto'),
    ('9:00',  'nine o''clock',   7, 'en_punto'),
    -- Y media
    ('1:30',  'half past one',   8,  'media'),
    ('4:30',  'half past four',  9,  'media'),
    ('8:30',  'half past eight', 10, 'media'),
    ('10:30', 'half past ten',   11, 'media'),
    -- Cuarto (y cuarto / menos cuarto)
    ('2:15',  'quarter past two',   12, 'cuarto'),
    ('5:15',  'quarter past five',  13, 'cuarto'),
    ('6:45',  'quarter to seven',   14, 'cuarto'),
    ('11:45', 'quarter to twelve',  15, 'cuarto'),
    -- Minutos sueltos (pasados/para, múltiplos de 5)
    ('1:20',  'twenty past one', 16, 'minutos'),
    ('5:10',  'ten past five',   17, 'minutos'),
    ('3:50',  'ten to four',     18, 'minutos'),
    ('9:40',  'twenty to ten',   19, 'minutos')
) AS x(texto_es, texto_en, orden, variante)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;

-- Partes del día: preposición at/in + momento -- vocabulario funcional,
-- sin visual de reloj, mismas fichas tocables que abecedario.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, 'parte_dia'
FROM (VALUES
    ('muy temprano por la mañana', 'early in the morning', 20),
    ('por la mañana',              'in the morning',       21),
    ('al mediodía',                'at noon',               22),
    ('por la tarde',               'in the afternoon',     23),
    ('al atardecer / a la noche',  'in the evening',       24),
    ('de noche',                   'at night',              25),
    ('a la medianoche',            'at midnight',           26)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;
