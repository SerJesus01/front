-- Fase 3 del plan de dinamismo pedagógico (auto-explicación con LLM, ver
-- memoria del proyecto): el plan original decía "columna
-- intentos_gramatica.evaluacion JSONB", pero esa tabla exige
-- `ejercicio_id` NOT NULL (es por-ejercicio) -- la auto-explicación es
-- por SUBTEMA, no por ejercicio, forzarla ahí hubiera necesitado un
-- ejercicio_id inventado sin sentido real. Tabla propia, más simple y
-- honesta con el modelo de datos real.
CREATE TABLE gramatica_autoexplicaciones (
    id                  SERIAL PRIMARY KEY,
    identidad_id        INTEGER NOT NULL,
    tema_id             INTEGER NOT NULL REFERENCES gramatica_temas(id),
    explicacion_usuario TEXT NOT NULL,
    evaluacion          JSONB NOT NULL,
    creado_en           TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_gramatica_autoexplicaciones_identidad_tema ON gramatica_autoexplicaciones (identidad_id, tema_id);
