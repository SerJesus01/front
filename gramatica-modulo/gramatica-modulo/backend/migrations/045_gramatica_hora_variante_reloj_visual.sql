-- Pedido en vivo: construir "Hora y fecha" (fase-1-hora-fecha, ya
-- scaffoldeado en el seed de temas -- migración 030 -- pero sin contenido
-- todavía). Dos bloques: reloj (o'clock/half past/quarter past-to/minutos
-- sueltos) y partes del día (at noon / in the morning / at night...).
--
-- `variante` (migración 039) ya distinguía cardinal/ordinal dentro de
-- tipo='referencia' -- es un sub-tag GENÉRICO, no específico de números,
-- así que se amplía el mismo CHECK en vez de agregar una columna nueva
-- por cada tema nuevo (misma lógica de extensibilidad pedida por el
-- dueño: "sin que quede harcodeado nada").
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN ('cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia'));

-- Nuevo formato visual 'reloj_visual' (ejercicios.formato, migración 038):
-- reloj analógico dibujado en CSS a partir de metadata.hora/metadata.minuto
-- -- mismo patrón que 'conteo_visual' (emoji + cantidad), el frontend
-- agrega un v-else-if nuevo, el evaluador no cambia.
ALTER TABLE ejercicios DROP CONSTRAINT chk_ejercicios_formato;
ALTER TABLE ejercicios ADD CONSTRAINT chk_ejercicios_formato
    CHECK (formato IN ('texto', 'audio_secuencia', 'conteo_visual', 'reloj_visual'));
