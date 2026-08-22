-- Ronda de limpieza pedida por el dueño revisando la app en vivo
-- (04/ago/2026, ver memoria del proyecto): tres fusiones de contenido
-- duplicado o mal ubicado. NO incluye going-to/will-shall (ya tienen una
-- tarjeta de contraste curada a propósito, gramatica_relaciones id 7 --
-- fusionarlos borraría esa distinción) ni una fusión completa de
-- a/an/the + contables/incontables + some/any (son conceptos
-- relacionados pero distintos, cada uno con su propia regla -- en vez de
-- fusionar se agregan tarjetas de relación abajo, mismo mecanismo que
-- going-to/will-shall).

-- ============================================================
-- A. Saludos + Despedidas (Fase 1) -- es vocabulario, no tiene sentido
-- separarlos en dos pantallas.
-- ============================================================
UPDATE gramatica_temas SET nombre = 'Saludos y despedidas' WHERE slug = 'fase-1-saludos';

UPDATE gramatica_contenido
SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-1-saludos'),
    orden = orden + 100
WHERE tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-1-despedidas');

UPDATE ejercicios
SET tema_gramatica_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-1-saludos')
WHERE tema_gramatica_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-1-despedidas');

DELETE FROM gramatica_temas WHERE slug = 'fase-1-despedidas';

-- ============================================================
-- B. Wh-questions: sacar de "to be" (Fase 2) y llevar a Wh-questions
-- (Fase 10), que estaba casi vacío (1 regla + 2 ejemplos, sin tabla de
-- palabras). La regla vieja (id 214, específica de "WH + to be") se
-- borra por redundante -- la regla que ya tiene Fase 10 (id 333) cubre
-- lo mismo de forma general, con un ejemplo de 'to be' incluido
-- ("Where is the server?"). audio_key ya generado se conserva intacto
-- (mismo texto, solo cambia tema_id/orden, no hace falta regenerar
-- audio).
-- ============================================================
DELETE FROM gramatica_contenido WHERE id = 214;

UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 1 WHERE id = 215;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 2 WHERE id = 216;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 3 WHERE id = 217;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 4 WHERE id = 218;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 5 WHERE id = 219;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 6 WHERE id = 220;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 4 WHERE id = 221;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 5 WHERE id = 222;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 6 WHERE id = 223;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 7 WHERE id = 224;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 8 WHERE id = 225;
UPDATE gramatica_contenido SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions'), orden = 9 WHERE id = 226;

-- Los ejercicios que prueban ELEGIR la palabra WH correcta se mueven con
-- el contenido (pertenecen temáticamente a Wh-questions). Los que
-- prueban conjugación de to-be (833-836, 838) y detectar-error
-- (1076-1077) se quedan en Fase 2, son legítimamente de "to be".
UPDATE ejercicios SET tema_gramatica_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-10-wh-questions')
WHERE id IN (837, 946, 947, 948, 949);

-- ============================================================
-- C. much/many + a little/a few (Fase 14) -- mismo concepto exacto
-- (contable/incontable) en distinta escala de cantidad, sin ninguna
-- tarjeta de contraste ya diseñada que se pierda.
-- ============================================================
UPDATE gramatica_temas SET nombre = 'much/many, a little/a few' WHERE slug = 'fase-14-much-many';

UPDATE gramatica_contenido
SET tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-14-much-many'),
    orden = orden + 10
WHERE tema_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-14-little-few');

UPDATE ejercicios
SET tema_gramatica_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-14-much-many')
WHERE tema_gramatica_id = (SELECT id FROM gramatica_temas WHERE slug = 'fase-14-little-few');

DELETE FROM gramatica_temas WHERE slug = 'fase-14-little-few';

-- ============================================================
-- D. a/an/the -- Contables/incontables -- some/any (Fase 13): NO se
-- fusionan (son reglas distintas), pero sí están relacionados -- se
-- agregan 2 tarjetas de relación (mismo mecanismo que going-to/will-
-- shall) usando "Contables e incontables" como nodo bisagra, que es
-- justo el concepto del que dependen los otros dos para elegir bien.
-- ============================================================
INSERT INTO gramatica_relaciones (tema_a_id, tema_b_id, tipo_relacion, texto_es)
SELECT ta.id, tb.id, 'combinacion',
       'Antes de elegir a/an o the, primero hay que saber si el sustantivo es contable o incontable -- a/an solo funciona con contables en singular.'
FROM gramatica_temas ta, gramatica_temas tb
WHERE ta.slug = 'fase-13-a-an-the' AND tb.slug = 'fase-13-contables-incontables'
UNION ALL
SELECT ta.id, tb.id, 'combinacion',
       'some/any dependen de si el sustantivo es contable plural o incontable -- la misma distinción que ya aprendiste para elegir el artículo correcto.'
FROM gramatica_temas ta, gramatica_temas tb
WHERE ta.slug = 'fase-13-contables-incontables' AND tb.slug = 'fase-13-some-any';
