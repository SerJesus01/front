-- Fase 2 del plan de dinamismo pedagógico (StudentBook dinámico, ver
-- memoria del proyecto): predicción antes de revelar la regla + tablas de
-- asociación más ricas + escenas curadas offline.
--
-- `metadata` (JSONB, igual que ya tiene `ejercicios` desde la migración
-- 038) guarda las 3 hipótesis de una fila tipo='prediccion'
-- ({"opciones": [...], "correcta": <indice>}) -- no hace falta una tabla
-- nueva, mismo criterio de "ortogonal a tipo" que ya se usa en ejercicios.
--
-- `imagen_key` (mismo patrón que `audio_key`): referencia a una imagen
-- pregenerada UNA VEZ offline (curada a mano o generada con una
-- herramienta de imagen como paso de autoría de contenido, nunca en
-- runtime) y servida tal cual desde disco -- cero generación de imágenes
-- en el camino de request, mismo principio que el audio.
ALTER TABLE gramatica_contenido ADD COLUMN metadata JSONB;
ALTER TABLE gramatica_contenido ADD COLUMN imagen_key VARCHAR(128);

ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_tipo;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_tipo
    CHECK (tipo IN ('regla', 'ejemplo', 'referencia', 'prediccion'));

-- 'tobe_pasado' (was/were, ver migración 062) y 'there_forma' (there
-- is/there are) -- mismo mecanismo de columnas alineadas por `orden` que
-- ya usa 'pron_sujeto'/'pron_objeto'/etc. (migración 058).
ALTER TABLE gramatica_contenido DROP CONSTRAINT chk_gramatica_contenido_variante;
ALTER TABLE gramatica_contenido ADD CONSTRAINT chk_gramatica_contenido_variante
    CHECK (variante IS NULL OR variante IN (
        'cardinal', 'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia',
        'fecha_especifica', 'fecha_relativa', 'fecha_casual',
        'pron_sujeto', 'pron_objeto', 'pron_posesivo_adj', 'pron_posesivo_pron',
        'tobe_pasado', 'there_forma'
    ));
