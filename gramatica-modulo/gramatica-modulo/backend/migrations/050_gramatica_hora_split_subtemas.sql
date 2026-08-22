-- Pedido en vivo: "Hora y fecha" (fase-1-hora-fecha) creció a 20
-- ejercicios (2 originales + 8 reloj_visual + 4 listening + 6 partes del
-- día, ver migraciones 032/047/048/049) -- demasiado para un solo examen
-- corto. Se divide en 4 subtemas nuevos, mismo criterio de estilo que ya
-- se usó para agrupar la tabla de referencia (variante en_punto/media ->
-- Hora 1, cuarto/minutos -> Hora 2, parte_dia -> Hora 3) + Fecha aparte.
--
-- El subtema viejo (fase-1-hora-fecha) NO se borra -- se queda sin
-- contenido propio y desaparece solo de /gramatica/fases/.../subtemas
-- (ese endpoint hace INNER JOIN contra gramatica_contenido, ver
-- routers/gramatica.py) una vez que se le reasigna todo. Mismo criterio
-- que "nunca borrar gramatica_temas" ya usado en el resto del módulo.
INSERT INTO gramatica_temas (nombre, slug, parent_id, orden)
SELECT x.nombre, x.slug, f.id, x.orden
FROM (VALUES
    ('fase-1-fundamentos', 'Fecha',                       'fase-1-fecha',  3),
    ('fase-1-fundamentos', 'Hora 1: en punto y media',     'fase-1-hora-1', 4),
    ('fase-1-fundamentos', 'Hora 2: cuarto y minutos',     'fase-1-hora-2', 5),
    ('fase-1-fundamentos', 'Hora 3: partes del día',       'fase-1-hora-3', 6)
) AS x(fase_slug, nombre, slug, orden)
JOIN gramatica_temas f ON f.slug = x.fase_slug AND f.parent_id IS NULL;

-- Regla/ejemplo propios por subtema (la regla vieja combinaba hora+fecha
-- en un solo párrafo, ver migración 031 -- se reemplaza por una regla
-- corta y específica por estilo, más fácil de leer de un vistazo).
INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('fase-1-fecha',  'regla',   'Para dar una fecha se usa ''on'' antes del día: ''on Monday'', ''on July 4th''.', 'The deploy is scheduled for Friday, August 14th.', 1),
    ('fase-1-fecha',  'ejemplo', 'Dar la fecha de un evento', 'The deploy is scheduled for Friday, August 14th.', 2),
    ('fase-1-hora-1', 'regla',   'Para las horas en punto se dice ''It''''s'' + número + ''o''''clock''. Para la media hora, ''half past'' + la hora que ya pasó.', 'It''s three o''clock. It''s half past four.', 1),
    ('fase-1-hora-1', 'ejemplo', 'Preguntar la hora', 'What time is it? — It''s half past nine.', 2),
    ('fase-1-hora-2', 'regla',   'Para el cuarto de hora se usa ''quarter past''/''quarter to''. Para minutos sueltos, ''<minutos> past/to'' + la hora.', 'It''s a quarter to nine. It''s twenty past three.', 1),
    ('fase-1-hora-2', 'ejemplo', 'Preguntar la hora', 'What time is it? — It''s a quarter to nine.', 2),
    ('fase-1-hora-3', 'regla',   'Para las partes del día se usa ''in the'' + morning/afternoon/evening, pero ''at'' + noon/night/midnight (excepciones que no siguen el patrón ''in the'').', 'I work in the morning. I sleep at night.', 1),
    ('fase-1-hora-3', 'ejemplo', 'Describir una rutina', 'I wake up early in the morning and go to bed at night.', 2)
) AS x(slug, tipo, texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = x.slug AND t.parent_id IS NOT NULL;

-- Reasignar las fichas de referencia (migración 046) por variante.
UPDATE gramatica_contenido gc
SET tema_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE gc.tema_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND gc.variante IN ('en_punto', 'media') AND nuevo.slug = 'fase-1-hora-1';

UPDATE gramatica_contenido gc
SET tema_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE gc.tema_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND gc.variante IN ('cuarto', 'minutos') AND nuevo.slug = 'fase-1-hora-2';

UPDATE gramatica_contenido gc
SET tema_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE gc.tema_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND gc.variante = 'parte_dia' AND nuevo.slug = 'fase-1-hora-3';

-- Reasignar ejercicios: los 2 originales (migración 032) por texto de
-- respuesta, los de reloj_visual/audio_secuencia/texto (migraciones
-- 047/048/049) por respuesta_esperada exacta (valores que se sembraron a
-- mano, sin ambigüedad).
UPDATE ejercicios e SET tema_gramatica_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE e.tema_gramatica_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND nuevo.slug = 'fase-1-fecha' AND e.respuesta_esperada = 'on';

UPDATE ejercicios e SET tema_gramatica_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE e.tema_gramatica_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND nuevo.slug = 'fase-1-hora-2' AND e.respuesta_esperada = 'quarter';

UPDATE ejercicios e SET tema_gramatica_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE e.tema_gramatica_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND nuevo.slug = 'fase-1-hora-1'
  AND e.respuesta_esperada IN ('three o''clock', 'nine o''clock', 'half past four', 'half past ten', 'twelve o''clock', 'half past one');

UPDATE ejercicios e SET tema_gramatica_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE e.tema_gramatica_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND nuevo.slug = 'fase-1-hora-2'
  AND e.respuesta_esperada IN ('quarter past two', 'quarter to seven', 'ten past five', 'twenty to ten', 'quarter to twelve', 'ten to four');

UPDATE ejercicios e SET tema_gramatica_id = nuevo.id
FROM gramatica_temas viejo, gramatica_temas nuevo
WHERE e.tema_gramatica_id = viejo.id AND viejo.slug = 'fase-1-hora-fecha'
  AND nuevo.slug = 'fase-1-hora-3' AND e.formato = 'texto' AND e.respuesta_esperada IN ('at', 'in');

-- La regla vieja (combinaba hora+fecha) y sus 2 ejemplos quedan
-- reemplazados por el contenido específico de arriba -- se borran para
-- que fase-1-hora-fecha quede sin NINGÚN contenido y desaparezca de
-- /gramatica/fases/.../subtemas (si no, seguiría listado con 0
-- ejercicios: regla/ejemplo visibles pero el botón "practicar" cargaría
-- un examen vacío).
DELETE FROM gramatica_contenido gc
USING gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-hora-fecha' AND t.parent_id IS NOT NULL;
