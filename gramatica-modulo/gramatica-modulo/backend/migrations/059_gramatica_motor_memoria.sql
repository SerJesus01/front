-- Motor de Memoria (Fase 1 del plan de dinamismo pedagógico, ver memoria
-- del proyecto): repetición espaciada tipo Leitner + señales de
-- confianza/tiempo de respuesta para decidir el movimiento de caja.
--
-- Diseño deliberadamente simple (Leitner, no SM-2): con el volumen actual
-- de ejercicios de Gramática, un algoritmo con pesos calibrados sería
-- sobre-ingeniería -- SM-2 recién se justifica por encima de ~600-1000
-- ítems activos. Disparo por PULL (GET /gramatica/repaso), nunca por cron
-- -- consistente con "cero procesamiento en vivo" del resto del módulo,
-- ya que esto es solo una consulta a demanda, no un job en segundo plano.
--
-- `identidad_id`/`modulo` (no solo `ejercicio_id`) porque esta tabla está
-- pensada para ser reusada por Vocabulario más adelante (reemplazando su
-- heurística actual de "orden por último intento"), no exclusiva de
-- Gramática.
CREATE TABLE repaso_programado (
    identidad_id   INTEGER NOT NULL,
    modulo         VARCHAR(20) NOT NULL,
    ejercicio_id   INTEGER NOT NULL REFERENCES ejercicios(id),
    caja           SMALLINT NOT NULL DEFAULT 1,
    proxima_fecha  DATE NOT NULL DEFAULT CURRENT_DATE,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (identidad_id, modulo, ejercicio_id)
);

CREATE INDEX idx_repaso_programado_vencidos ON repaso_programado (identidad_id, modulo, proxima_fecha);

-- Señales para la tabla de decisión de movimiento de caja (ver
-- routers/gramatica.py::_calcular_movimiento_caja): tiempo de respuesta en
-- milisegundos (medido en el frontend, render->submit) y confianza
-- autoreportada por el alumno ANTES de revelar si acertó. Ambas nullable
-- -- un intento sin estas señales (ej. mientras el frontend viejo no las
-- mande todavía) se trata como "sin señal" (confianza intermedia, sin
-- dato de velocidad), nunca rompe el flujo existente.
ALTER TABLE intentos_gramatica ADD COLUMN tiempo_respuesta_ms INTEGER;
ALTER TABLE intentos_gramatica ADD COLUMN confianza VARCHAR(20);
ALTER TABLE intentos_gramatica ADD CONSTRAINT chk_intentos_gramatica_confianza
    CHECK (confianza IS NULL OR confianza IN ('seguro', 'creo', 'adivine'));
