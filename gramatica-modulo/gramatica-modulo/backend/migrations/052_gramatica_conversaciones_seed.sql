-- 5 diálogos cortos (2 hablantes, ~4 turnos c/u) que mezclan preguntas de
-- HORA y de FECHA -- 3 terminan preguntando la hora, 2 preguntando el
-- día, para reforzar ambos temas de la Fase 1 con el mismo mecanismo
-- (metadata.turnos, ver migración 051). "voz" es la voz Kokoro real que
-- usa cada hablante (A=af_heart, B=am_michael, consistente en las 5
-- conversaciones para que se aprenda a reconocer "quién habla" por la
-- voz). contexto_en acá SÍ se muestra (a diferencia del placeholder de
-- audio_secuencia): es la pregunta de comprensión que el alumno responde
-- después de escuchar el diálogo completo.
INSERT INTO ejercicios (tipo, formato, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, metadata, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', 'conversacion_audio', 'Escuchá la conversación y respondé la pregunta.', x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, x.metadata, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    (
        'What time does the movie start?', 'eight o''clock',
        ARRAY['seven o''clock', 'eight o''clock', 'seven thirty', 'nine o''clock'],
        '{"turnos": [
            {"hablante": "A", "voz": "af_heart", "texto_en": "Are you free on Saturday? Do you want to go to the movies?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Sure! What time does it start?"},
            {"hablante": "A", "voz": "af_heart", "texto_en": "It starts at eight o''clock."},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Great, let''s meet at seven thirty then."}
        ]}'::jsonb, 'A1'
    ),
    (
        'What day are they meeting for coffee?', 'Tuesday',
        ARRAY['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
        '{"turnos": [
            {"hablante": "A", "voz": "af_heart", "texto_en": "Let''s grab a coffee this week. Are you free on Tuesday?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Tuesday works for me. What time?"},
            {"hablante": "A", "voz": "af_heart", "texto_en": "How about half past nine, in the morning?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Perfect, see you Tuesday at half past nine."}
        ]}'::jsonb, 'A1'
    ),
    (
        'What time should the friend arrive for dinner?', 'quarter past seven',
        ARRAY['seven o''clock', 'quarter to seven', 'quarter past seven', 'half past seven'],
        '{"turnos": [
            {"hablante": "A", "voz": "af_heart", "texto_en": "Are you free for dinner on Friday, August 14th?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Yes! What time should I come over?"},
            {"hablante": "A", "voz": "af_heart", "texto_en": "Come at quarter past seven."},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Okay, quarter past seven works for me."}
        ]}'::jsonb, 'A2'
    ),
    (
        'What day are they working out together?', 'Monday',
        ARRAY['Sunday', 'Monday', 'Wednesday', 'Saturday'],
        '{"turnos": [
            {"hablante": "A", "voz": "af_heart", "texto_en": "Do you want to work out together this week?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Sure, how about Monday? What time do you usually go?"},
            {"hablante": "A", "voz": "af_heart", "texto_en": "I go at quarter to six in the morning."},
            {"hablante": "B", "voz": "am_michael", "texto_en": "That''s early! Monday at quarter to six then."}
        ]}'::jsonb, 'A2'
    ),
    (
        'What time does the flight leave?', 'ten to four',
        ARRAY['ten past four', 'ten to four', 'ten to five', 'four o''clock'],
        '{"turnos": [
            {"hablante": "A", "voz": "af_heart", "texto_en": "What time does your flight leave on Sunday?"},
            {"hablante": "B", "voz": "am_michael", "texto_en": "It leaves at ten to four in the afternoon."},
            {"hablante": "A", "voz": "af_heart", "texto_en": "Okay, I''ll pick you up an hour before."},
            {"hablante": "B", "voz": "am_michael", "texto_en": "Thanks, that would be around ten to three."}
        ]}'::jsonb, 'B1'
    )
) AS x(contexto_en, respuesta_esperada, opciones, metadata, nivel_cefr)
JOIN gramatica_temas t ON t.slug = 'fase-1-hora-4' AND t.parent_id IS NOT NULL;
