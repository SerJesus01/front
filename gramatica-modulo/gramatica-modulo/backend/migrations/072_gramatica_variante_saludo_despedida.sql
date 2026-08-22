-- Pedido en vivo (04/ago/2026): tras fusionar Saludos+Despedidas en un
-- solo subtema (migración 071), el dueño pidió mostrarlos como DOS
-- tablas separadas (una por grupo), no mezcladas en una sola grilla.
-- Se etiquetan las filas de referencia con variante='saludo'/'despedida'
-- para que el frontend las agrupe (mismo mecanismo que ya usan
-- gruposReloj/gruposFrases con sus propias variantes).
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
  CHECK (variante IS NULL OR variante IN (
    'cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos',
    'parte_dia', 'fecha_especifica', 'fecha_relativa', 'fecha_casual',
    'pron_sujeto', 'pron_objeto', 'pron_posesivo_adj', 'pron_posesivo_pron',
    'tobe_pasado', 'there_forma', 'saludo', 'despedida'
  ));

UPDATE gramatica_contenido SET variante = 'saludo'
WHERE id IN (269, 270, 271, 272, 273, 274, 275, 276);

UPDATE gramatica_contenido SET variante = 'despedida'
WHERE id IN (277, 278, 279, 280, 281, 282, 283, 284);
