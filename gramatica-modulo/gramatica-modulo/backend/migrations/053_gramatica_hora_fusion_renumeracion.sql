-- Pedido en vivo: Hora 1 (en punto/media) y Hora 2 (cuarto/minutos) eran
-- "casi lo mismo" -- se fusionan en un solo subtema (se reusa el tema
-- fase-1-hora-1, que se queda con las 4 variantes de estilo) con
-- exactamente 8 ejercicios (los 8 reloj_visual ya sembrados, 2 por
-- estilo, migración 047) -- el listening (audio_secuencia, migración 043/048)
-- y el cloze viejo ('quarter', migración 032) se retiran al tema
-- "cementerio" (fase-1-hora-fecha, mismo que ya quedó vacío tras la
-- migración 050) en vez de borrarse -- mismo criterio de "nunca borrar
-- ejercicios" ya usado en esa migración.
--
-- Renumeración: partes del día (fase-1-hora-3) pasa a ser "Hora 2",
-- conversaciones (fase-1-hora-4) pasa a ser "Hora 3" -- los slugs NO se
-- tocan (evita romper cualquier referencia externa), solo nombre/orden.

-- 1) Mover las 8 fichas de referencia (cuarto/minutos) a Hora 1.
UPDATE gramatica_contenido gc
SET tema_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE gc.tema_id = origen.id AND origen.slug = 'fase-1-hora-2'
  AND gc.tipo = 'referencia' AND destino.slug = 'fase-1-hora-1';

-- 2) La regla/ejemplo propios de Hora 2 quedan reemplazados por el
-- contenido unificado de Hora 1 (ver paso 4) -- se borran, no se
-- necesitan (mismo criterio que la regla combinada vieja en migración 050).
DELETE FROM gramatica_contenido gc
USING gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-hora-2' AND gc.tipo IN ('regla', 'ejemplo');

-- 3) Renombrar Hora 1 para reflejar que ahora cubre las 4 formas.
UPDATE gramatica_temas SET nombre = 'Hora 1: decir la hora' WHERE slug = 'fase-1-hora-1';

-- 4) Recordatorio pedido en vivo: también se puede leer la hora contando
-- los minutos directo (estilo "reloj digital"), y AM/PM para desambiguar
-- mañana/tarde en un formato de 24 horas.
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'regla', 'También podés decir la hora contando los minutos directo (estilo reloj digital), en vez de ''past''/''to''. Para aclarar mañana o tarde/noche, se usa AM/PM.', 'It''s nine forty-five. The meeting is at three PM, not three AM.', 'A2', 20
FROM gramatica_temas t WHERE t.slug = 'fase-1-hora-1' AND t.parent_id IS NOT NULL;

-- 5) Ejercicios: quedan solo los 8 reloj_visual en Hora 1 -- se mueven los
-- 4 reloj_visual de Hora 2 (los otros 4 ya estaban en Hora 1).
UPDATE ejercicios e
SET tema_gramatica_id = destino.id
FROM gramatica_temas origen, gramatica_temas destino
WHERE e.tema_gramatica_id = origen.id AND origen.slug = 'fase-1-hora-2'
  AND e.formato = 'reloj_visual' AND destino.slug = 'fase-1-hora-1';

-- 6) El listening (audio_secuencia, en ambos temas) y el cloze viejo
-- ('quarter', en Hora 2) se retiran al cementerio -- no cuentan para los
-- "8 reactivos" pedidos.
UPDATE ejercicios e
SET tema_gramatica_id = cementerio.id
FROM gramatica_temas origen, gramatica_temas cementerio
WHERE e.tema_gramatica_id = origen.id AND origen.slug IN ('fase-1-hora-1', 'fase-1-hora-2')
  AND (e.formato = 'audio_secuencia' OR e.respuesta_esperada = 'quarter')
  AND cementerio.slug = 'fase-1-hora-fecha';

-- 7) Renumerar: partes del día -> "Hora 2", conversaciones -> "Hora 3".
UPDATE gramatica_temas SET nombre = 'Hora 2: partes del día', orden = 5 WHERE slug = 'fase-1-hora-3';
UPDATE gramatica_temas SET nombre = 'Hora 3: conversaciones', orden = 6 WHERE slug = 'fase-1-hora-4';
