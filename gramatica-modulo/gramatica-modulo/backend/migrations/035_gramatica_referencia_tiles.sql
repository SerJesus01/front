-- Feedback real del dueño probando abecedario/números en vivo: las 26
-- letras y 20 números (migraciones 033-034) se veían como tarjetas
-- completas (misma tarjeta que una regla/ejemplo con oración), una por
-- una, con un botón 🔊 aparte -- pidió que en cambio se vean como una
-- grilla compacta de fichas tocables (mismo patrón visual que los
-- botones cuadrados de Fase/subtema), donde tocar la ficha ES reproducir
-- el audio, sin ícono de parlante separado.
--
-- Se agrega el tipo 'referencia' para distinguir este contenido "ficha
-- suelta" (una letra, un número) de 'regla' (explicación) y 'ejemplo'
-- (oración de ejemplo completa) -- el frontend decide el layout según el
-- tipo, no según heurísticas de longitud de texto.
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_tipo;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_tipo
    CHECK (tipo IN ('regla', 'ejemplo', 'referencia'));

-- Las 26 letras (migración 033) y los 20 cardinales (migración 034) ya
-- sembrados pasan de 'ejemplo' a 'referencia' -- mismo contenido, tipo
-- corregido retroactivamente (no hace falta re-generar audio, el
-- audio_key ya calculado sigue siendo válido, la clave depende del
-- texto/voz/velocidad, no del tipo).
UPDATE gramatica_contenido gc
SET tipo = 'referencia'
FROM gramatica_temas t
WHERE gc.tema_id = t.id
  AND t.slug IN ('fase-1-abecedario', 'fase-1-numeros')
  AND gc.tipo = 'ejemplo'
  AND (gc.texto_es LIKE 'Letra %' OR gc.texto_es LIKE 'Número %');

-- Números grandes pedidos explícitamente (a diferencia del 1-20, estos
-- son "hitos" redondos, no una secuencia continua -- no hace falta
-- sembrar cada número entre 21 y 999999).
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('Número 100', 'one hundred', 24),
    ('Número 10.000', 'ten thousand', 25),
    ('Número 1.000.000', 'one million', 26)
) AS x(texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = 'fase-1-numeros' AND t.parent_id IS NOT NULL;
