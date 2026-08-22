-- Separa el imagen_key compartido `escena_oficina_prep_lugar` (nunca llegó
-- a tener archivo real, ver imagenes_gramatica/README.md) en dos escenas
-- simples independientes, una por relación espacial (ver la corrección de
-- simplicidad del 04/ago/2026 en PROMPTS_PENDIENTES.md). La primera ya
-- tiene archivo real (imagenes_gramatica/escena_escritorio_lugar.png); la
-- segunda (escena_puertas_entre, para "between") sigue pendiente de
-- generar, se deja el key asignado desde ya para no requerir otra
-- migración cuando llegue.
UPDATE gramatica_contenido
SET imagen_key = 'escena_escritorio_lugar'
WHERE texto_en = 'The keyboard is on the desk, in front of the monitor.';

UPDATE gramatica_contenido
SET imagen_key = 'escena_puertas_entre'
WHERE texto_en = 'The meeting room is between the kitchen and the elevator.';
