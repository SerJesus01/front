-- Mismo caso que el abecedario (migración 033): "fase-1-numeros" solo
-- tenía 1 regla + 2 ejemplos hablando SOBRE cardinales/ordinales, nunca
-- los números en sí. Se agregan los cardinales del 1 al 20 (base real
-- para contar en inglés, con audio individual) -- mismo tratamiento que
-- las 26 letras del abecedario, a pedido explícito del dueño ("son
-- prácticamente igual"). tipo 'ejemplo' (ya existe una 'regla' general
-- del tema, ver migración 031), texto_en es la palabra del número sola
-- para que el TTS la lea de forma aislada y clara.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, x.nivel_cefr, x.orden
FROM (VALUES
    ('fase-1-numeros', 'ejemplo', 'Número 1', 'one', 'A1', 4),
    ('fase-1-numeros', 'ejemplo', 'Número 2', 'two', 'A1', 5),
    ('fase-1-numeros', 'ejemplo', 'Número 3', 'three', 'A1', 6),
    ('fase-1-numeros', 'ejemplo', 'Número 4', 'four', 'A1', 7),
    ('fase-1-numeros', 'ejemplo', 'Número 5', 'five', 'A1', 8),
    ('fase-1-numeros', 'ejemplo', 'Número 6', 'six', 'A1', 9),
    ('fase-1-numeros', 'ejemplo', 'Número 7', 'seven', 'A1', 10),
    ('fase-1-numeros', 'ejemplo', 'Número 8', 'eight', 'A1', 11),
    ('fase-1-numeros', 'ejemplo', 'Número 9', 'nine', 'A1', 12),
    ('fase-1-numeros', 'ejemplo', 'Número 10', 'ten', 'A1', 13),
    ('fase-1-numeros', 'ejemplo', 'Número 11', 'eleven', 'A1', 14),
    ('fase-1-numeros', 'ejemplo', 'Número 12', 'twelve', 'A1', 15),
    ('fase-1-numeros', 'ejemplo', 'Número 13', 'thirteen', 'A1', 16),
    ('fase-1-numeros', 'ejemplo', 'Número 14', 'fourteen', 'A1', 17),
    ('fase-1-numeros', 'ejemplo', 'Número 15', 'fifteen', 'A1', 18),
    ('fase-1-numeros', 'ejemplo', 'Número 16', 'sixteen', 'A1', 19),
    ('fase-1-numeros', 'ejemplo', 'Número 17', 'seventeen', 'A1', 20),
    ('fase-1-numeros', 'ejemplo', 'Número 18', 'eighteen', 'A1', 21),
    ('fase-1-numeros', 'ejemplo', 'Número 19', 'nineteen', 'A1', 22),
    ('fase-1-numeros', 'ejemplo', 'Número 20', 'twenty', 'A1', 23)
) AS x(subtema_slug, tipo, texto_es, texto_en, nivel_cefr, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
