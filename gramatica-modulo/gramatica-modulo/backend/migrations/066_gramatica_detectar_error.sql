-- Fase 7 del plan de dinamismo pedagógico (formato "Detectá el error", ver
-- memoria del proyecto): 3 oraciones candidatas, una tiene un error
-- típico de hispanohablante -- el alumno toca cuál. Reusa el evaluador
-- determinista existente tal cual (tipo='cloze', comparación exacta
-- contra respuesta_esperada) -- las 3 oraciones viajan en `opciones`
-- (igual que cualquier multiple choice), `metadata.categoria_error` se
-- muestra como feedback recién DESPUÉS de responder (no se pide elegir
-- categoría, simplifica la interacción sin perder el valor pedagógico:
-- entender POR QUÉ estaba mal). Cero mecanismo de evaluación nuevo.
ALTER TABLE ejercicios DROP CONSTRAINT chk_ejercicios_formato;
ALTER TABLE ejercicios ADD CONSTRAINT chk_ejercicios_formato
    CHECK (formato IN ('texto', 'audio_secuencia', 'conteo_visual', 'reloj_visual', 'conversacion_audio', 'audio_frase', 'detectar_error'));

-- 4 casos reales curados a mano (calcos típicos del español al inglés),
-- ligados a subtemas ya sembrados -- prueba de concepto del formato, no
-- un rollout exhaustivo (eso es trabajo editorial continuo, no esta Fase).
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'detectar_error', x.consigna_es, '', x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata::jsonb, t.id, 'A1', 'en'
FROM (VALUES
    ('fase-2-to-be-afirmativo',
     'Tocá la oración que tiene un error típico de hispanohablante.',
     'I have 20 years.',
     ARRAY['I have 20 years.', 'I am 20 years old.', 'I am tired.'],
     '{"categoria_error": "Calco del español (''tener años'') -- en inglés se usa ''to be'' + edad, nunca ''have''.", "oraciones": [{"texto": "I have 20 years.", "correcta": false}, {"texto": "I am 20 years old.", "correcta": true}, {"texto": "I am tired.", "correcta": true}]}'),
    ('fase-2-to-be-afirmativo',
     'Tocá la oración que tiene un error típico de hispanohablante.',
     'I am agree with the plan.',
     ARRAY['I am agree with the plan.', 'I agree with the plan.', 'I am sure about this.'],
     '{"categoria_error": "''agree'' ya es un verbo en inglés (''estar de acuerdo'') -- no lleva ''to be'' adelante, a diferencia de un adjetivo.", "oraciones": [{"texto": "I am agree with the plan.", "correcta": false}, {"texto": "I agree with the plan.", "correcta": true}, {"texto": "I am sure about this.", "correcta": true}]}'),
    ('fase-3-presente-simple',
     'Tocá la oración que tiene un error típico de hispanohablante.',
     'She work remotely.',
     ARRAY['She work remotely.', 'She works remotely.', 'They work remotely.'],
     '{"categoria_error": "Tercera persona singular (he/she/it) necesita ''-s'' en presente simple: ''works'', no ''work''.", "oraciones": [{"texto": "She work remotely.", "correcta": false}, {"texto": "She works remotely.", "correcta": true}, {"texto": "They work remotely.", "correcta": true}]}'),
    ('fase-8-must-have-to',
     'Tocá la oración que tiene un error típico de hispanohablante.',
     'You don''t must touch production.',
     ARRAY['You don''t must touch production.', 'You must not touch production.', 'You don''t have to touch it.'],
     '{"categoria_error": "''must'' no se niega con ''don''t'' -- la negación correcta es ''must not'' (prohibido).", "oraciones": [{"texto": "You don''t must touch production.", "correcta": false}, {"texto": "You must not touch production.", "correcta": true}, {"texto": "You don''t have to touch it.", "correcta": true}]}')
) AS x(subtema_slug, consigna_es, respuesta_esperada, opciones, metadata)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
