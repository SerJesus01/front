-- Fase 1 "Fundamentos" > "Abecedario y deletreo" (fase-1-abecedario) tenía
-- solo 1 regla + 2 ejemplos sobre CÓMO pedir que te deletreen algo (migración
-- 031), pero nunca el abecedario en sí -- corrección real pedida por el
-- dueño después de probar el módulo en vivo: esperaba ver las 26 letras,
-- cada una con su propio audio (así se aprende a NOMBRAR cada letra en
-- inglés, prerequisito real para poder deletrear/entender un deletreo).
-- tipo 'ejemplo' (no 'regla' nueva, ya hay una regla general del tema) --
-- texto_en es la letra sola, para que el TTS (Kokoro, ver
-- scripts/generar_audio_gramatica.py) la lea por su nombre de letra en
-- inglés ("ei", "bi:", "si:"...) y no como un caracter suelto sin sentido.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, x.nivel_cefr, x.orden
FROM (VALUES
    ('fase-1-abecedario', 'ejemplo', 'Letra A', 'A', 'A1', 4),
    ('fase-1-abecedario', 'ejemplo', 'Letra B', 'B', 'A1', 5),
    ('fase-1-abecedario', 'ejemplo', 'Letra C', 'C', 'A1', 6),
    ('fase-1-abecedario', 'ejemplo', 'Letra D', 'D', 'A1', 7),
    ('fase-1-abecedario', 'ejemplo', 'Letra E', 'E', 'A1', 8),
    ('fase-1-abecedario', 'ejemplo', 'Letra F', 'F', 'A1', 9),
    ('fase-1-abecedario', 'ejemplo', 'Letra G', 'G', 'A1', 10),
    ('fase-1-abecedario', 'ejemplo', 'Letra H', 'H', 'A1', 11),
    ('fase-1-abecedario', 'ejemplo', 'Letra I', 'I', 'A1', 12),
    ('fase-1-abecedario', 'ejemplo', 'Letra J', 'J', 'A1', 13),
    ('fase-1-abecedario', 'ejemplo', 'Letra K', 'K', 'A1', 14),
    ('fase-1-abecedario', 'ejemplo', 'Letra L', 'L', 'A1', 15),
    ('fase-1-abecedario', 'ejemplo', 'Letra M', 'M', 'A1', 16),
    ('fase-1-abecedario', 'ejemplo', 'Letra N', 'N', 'A1', 17),
    ('fase-1-abecedario', 'ejemplo', 'Letra O', 'O', 'A1', 18),
    ('fase-1-abecedario', 'ejemplo', 'Letra P', 'P', 'A1', 19),
    ('fase-1-abecedario', 'ejemplo', 'Letra Q', 'Q', 'A1', 20),
    ('fase-1-abecedario', 'ejemplo', 'Letra R', 'R', 'A1', 21),
    ('fase-1-abecedario', 'ejemplo', 'Letra S', 'S', 'A1', 22),
    ('fase-1-abecedario', 'ejemplo', 'Letra T', 'T', 'A1', 23),
    ('fase-1-abecedario', 'ejemplo', 'Letra U', 'U', 'A1', 24),
    ('fase-1-abecedario', 'ejemplo', 'Letra V', 'V', 'A1', 25),
    ('fase-1-abecedario', 'ejemplo', 'Letra W', 'W', 'A1', 26),
    ('fase-1-abecedario', 'ejemplo', 'Letra X', 'X', 'A1', 27),
    ('fase-1-abecedario', 'ejemplo', 'Letra Y', 'Y', 'A1', 28),
    ('fase-1-abecedario', 'ejemplo', 'Letra Z', 'Z', 'A1', 29)
) AS x(subtema_slug, tipo, texto_es, texto_en, nivel_cefr, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
