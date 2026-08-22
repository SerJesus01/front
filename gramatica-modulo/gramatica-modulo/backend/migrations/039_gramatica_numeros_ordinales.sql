-- Pedido del dueño: en "fase-1-numeros" mostrar los cardinales (ya
-- sembrados, migraciones 034/035/036) y los ordinales (1 -> one/first)
-- lado a lado en la misma pantalla, como dos grupos separados de fichas
-- -- no como un subtema aparte, porque son la misma tabla de contenido
-- del mismo tema, solo agrupados distinto en el frontend.
--
-- `variante` distingue el grupo dentro de tipo='referencia' -- NULL para
-- contenido donde no aplica (letras del abecedario, reglas, ejemplos).
-- El frontend agrupa por esta columna en vez de adivinar por texto
-- (mismo criterio de la migración 035: nunca heurísticas de string).
ALTER TABLE gramatica_contenido ADD COLUMN variante VARCHAR(20);
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN ('cardinal', 'ordinal'));

UPDATE gramatica_contenido gc
SET variante = 'cardinal'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-numeros' AND gc.tipo = 'referencia';

-- Ordinales 1-20 (mismo alcance que los cardinales sembrados, no se
-- extiende a los hitos de miles -- "hundredth"/"thousandth" quedan fuera
-- de este alcance por ahora). texto_es es el numeral ordinal en español
-- abreviado ("1º", "2º"...) -- el frontend ya sabe mostrar como subtítulo
-- cualquier texto_es que sea "numeral puro" (ver esNumeralPuro en
-- GramaticaView.vue, se extiende para aceptar el sufijo º).
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden, variante)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden, 'ordinal'
FROM (VALUES
    ('1º', 'first', 30),
    ('2º', 'second', 31),
    ('3º', 'third', 32),
    ('4º', 'fourth', 33),
    ('5º', 'fifth', 34),
    ('6º', 'sixth', 35),
    ('7º', 'seventh', 36),
    ('8º', 'eighth', 37),
    ('9º', 'ninth', 38),
    ('10º', 'tenth', 39),
    ('11º', 'eleventh', 40),
    ('12º', 'twelfth', 41),
    ('13º', 'thirteenth', 42),
    ('14º', 'fourteenth', 43),
    ('15º', 'fifteenth', 44),
    ('16º', 'sixteenth', 45),
    ('17º', 'seventeenth', 46),
    ('18º', 'eighteenth', 47),
    ('19º', 'nineteenth', 48),
    ('20º', 'twentieth', 49)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
