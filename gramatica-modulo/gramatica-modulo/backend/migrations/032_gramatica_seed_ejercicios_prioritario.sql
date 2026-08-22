-- ===========================================================================
-- Workbook: ejercicios (2 por subtema, tipo cloze con `opciones` de
-- multiple choice -- mismo patrón que la migración 023) para las Fases
-- 1-9 ya sembradas con contenido en 031. Todos deterministas (comparación
-- exacta contra respuesta_esperada, sin LLM) -- cuelgan de
-- tema_gramatica_id, nunca de vocabulario_id/vocabulario_forma_id (ver
-- CHECK de exclusividad mutua de la migración 029).
-- ===========================================================================

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, x.nivel_cefr, 'en'
FROM (VALUES
    -- Fase 1
    ('fase-1-abecedario', 'Completá la pregunta con el verbo correcto.', 'Could you ___ that, please?', 'spell', ARRAY['spell','say','tell','speak'], 'A1'),
    ('fase-1-abecedario', 'Completá la pregunta con el verbo correcto.', 'How do you ___ your last name?', 'spell', ARRAY['spell','spelling','spelt','spells'], 'A1'),
    ('fase-1-numeros', 'Completá con el ordinal correcto (3°).', 'She finished ___ in the race.', 'third', ARRAY['three','third','threeth','3rd time'], 'A1'),
    ('fase-1-numeros', 'Completá con el número correcto (12).', 'There are ___ people in the meeting.', 'twelve', ARRAY['twelve','twelfth','twelveth','tenth'], 'A1'),
    ('fase-1-hora-fecha', 'Completá la hora 3:45.', 'It''s a ___ to four.', 'quarter', ARRAY['quarter','half','third','fifteen'], 'A1'),
    ('fase-1-hora-fecha', 'Completá con la preposición correcta para el día.', 'The meeting is ___ Monday, July 4th.', 'on', ARRAY['on','in','at','of'], 'A1'),

    -- Fase 2
    ('fase-2-to-be-afirmativo', 'Completá con la forma correcta de ''to be''.', 'I ___ a software developer.', 'am', ARRAY['am','is','are','be'], 'A1'),
    ('fase-2-to-be-afirmativo', 'Completá con la forma correcta de ''to be''.', 'The server ___ down right now.', 'is', ARRAY['is','am','are','be'], 'A1'),
    ('fase-2-to-be-negativo', 'Completá con la forma negativa correcta.', 'The build ___ ready yet.', 'isn''t', ARRAY['isn''t','aren''t','don''t','not is'], 'A1'),
    ('fase-2-to-be-negativo', 'Completá con la forma negativa correcta.', 'I ___ available this afternoon.', 'am not', ARRAY['am not','is not','aren''t','don''t'], 'A1'),
    ('fase-2-to-be-preguntas', 'Completá la pregunta.', '___ you free tomorrow?', 'Are', ARRAY['Are','Is','Do','Am'], 'A1'),
    ('fase-2-to-be-preguntas', 'Completá la pregunta con la palabra Wh- correcta.', '___ is the staging server?', 'Where', ARRAY['Where','What','Who','When'], 'A1'),
    ('fase-2-pronombres-sujeto-objeto', 'Completá con el pronombre objeto correcto.', 'Can you help ___ with this bug?', 'me', ARRAY['me','I','my','mine'], 'A1'),
    ('fase-2-pronombres-sujeto-objeto', 'Completá con el pronombre objeto correcto.', 'I talked to ___ about the deploy.', 'him', ARRAY['him','he','his','he''s'], 'A1'),
    ('fase-2-posesivos-basicos', 'Completá con el posesivo correcto.', 'I pushed ___ branch this morning.', 'my', ARRAY['my','mine','I','me'], 'A1'),
    ('fase-2-posesivos-basicos', 'Completá con el posesivo correcto.', '___ repository has better test coverage.', 'Their', ARRAY['Their','They','Them','Theirs'], 'A1'),

    -- Fase 3
    ('fase-3-presente-simple', 'Completá con la forma correcta de ''run'' en presente simple.', 'The pipeline ___ every night at midnight.', 'runs', ARRAY['run','runs','running','ran'], 'A1'),
    ('fase-3-presente-simple', 'Completá con la forma correcta de ''check'' en presente simple.', 'I ___ my emails every morning.', 'check', ARRAY['check','checks','checking','checked'], 'A1'),
    ('fase-3-presente-continuo', 'Completá con la forma correcta de ''review'' en presente continuo.', 'I ___ your pull request right now.', 'am reviewing', ARRAY['am reviewing','review','reviewed','reviews'], 'A1'),
    ('fase-3-presente-continuo', 'Completá con la forma correcta de ''migrate'' en presente continuo.', 'We ___ the database this week.', 'are migrating', ARRAY['are migrating','migrate','migrated','migrates'], 'A1'),
    ('fase-3-simple-vs-continuo', 'Completá con la forma correcta (excepción temporal).', 'She usually takes the bus, but today she ___.', 'is driving', ARRAY['is driving','drives','drove','drive'], 'A2'),
    ('fase-3-simple-vs-continuo', 'Completá con la forma correcta (verbo de estado).', 'I ___ the answer.', 'know', ARRAY['know','am knowing','knows','knew'], 'A2'),

    -- Fase 4
    ('fase-4-was-were', 'Completá con was o were.', 'I ___ at the office yesterday.', 'was', ARRAY['was','were','am','is'], 'A1'),
    ('fase-4-was-were', 'Completá con was o were.', 'The tests ___ failing all morning.', 'were', ARRAY['were','was','are','is'], 'A1'),
    ('fase-4-pasado-simple', 'Completá con la forma correcta de ''fix'' en pasado simple.', 'I ___ the bug yesterday.', 'fixed', ARRAY['fixed','fix','fixes','fixing'], 'A2'),
    ('fase-4-pasado-simple', 'Completá con la forma correcta de ''merge'' en pasado simple.', 'We ___ the pull request last Friday.', 'merged', ARRAY['merged','merge','merges','merging'], 'A2'),
    ('fase-4-pasado-continuo', 'Completá con la forma correcta de ''review'' en pasado continuo.', 'I ___ the code when the alert went off.', 'was reviewing', ARRAY['was reviewing','reviewed','review','were reviewing'], 'A2'),
    ('fase-4-pasado-continuo', 'Completá con la forma correcta de ''deploy'' en pasado continuo.', 'We ___ when the database connection dropped.', 'were deploying', ARRAY['were deploying','deployed','was deploying','deploy'], 'A2'),

    -- Fase 5
    ('fase-5-perfecto-intro', 'Completá con la forma correcta de ''deploy'' en presente perfecto.', 'I ___ the new version.', 'have deployed', ARRAY['have deployed','deployed','deploy','am deploying'], 'B1'),
    ('fase-5-perfecto-intro', 'Completá con la forma correcta de ''review'' en presente perfecto.', 'She ___ your PR already.', 'has reviewed', ARRAY['has reviewed','reviewed','reviews','is reviewing'], 'B1'),
    ('fase-5-just-already-yet', 'Completá con la palabra que indica que pasó hace muy poco.', 'I''ve ___ pushed the hotfix.', 'just', ARRAY['just','yet','already','ever'], 'B1'),
    ('fase-5-just-already-yet', 'Completá la pregunta con la palabra correcta.', 'Has she reviewed the PR ___?', 'yet', ARRAY['yet','already','just','ever'], 'B1'),
    ('fase-5-ever-how-long', 'Completá la pregunta de experiencia.', 'Have you ___ deployed to production on a Friday?', 'ever', ARRAY['ever','already','yet','just'], 'B1'),
    ('fase-5-ever-how-long', 'Completá la pregunta de duración.', '___ have you known about this bug?', 'How long', ARRAY['How long','How much','How many','Since when'], 'B1'),
    ('fase-5-for-since-ago', 'Completá con for o since.', 'I''ve used this framework ___ six months.', 'for', ARRAY['for','since','ago','in'], 'B1'),
    ('fase-5-for-since-ago', 'Completá con for o since.', 'The service has been down ___ 2pm.', 'since', ARRAY['since','for','ago','from'], 'B1'),
    ('fase-5-perfecto-vs-pasado', 'Completá con la forma correcta (momento específico).', 'We ___ the fix at 4pm yesterday.', 'deployed', ARRAY['deployed','have deployed','deploy','are deploying'], 'B1'),
    ('fase-5-perfecto-vs-pasado', 'Completá con la forma correcta (resultado presente).', 'We ___ the fix, so the issue should be gone now.', 'have deployed', ARRAY['have deployed','deployed','deploy','are deploying'], 'B1'),

    -- Fase 6
    ('fase-6-pasiva-presente', 'Completá con la voz pasiva correcta de ''review''.', 'The code ___ before it''s merged.', 'is reviewed', ARRAY['is reviewed','reviews','reviewed','is reviewing'], 'B1'),
    ('fase-6-pasiva-presente', 'Completá con la voz pasiva correcta de ''log''.', 'Errors ___ automatically.', 'are logged', ARRAY['are logged','log','logged','are logging'], 'B1'),
    ('fase-6-pasiva-pasado', 'Completá con la voz pasiva correcta de ''cause'' en pasado.', 'The outage ___ by a misconfigured load balancer.', 'was caused', ARRAY['was caused','caused','is caused','causes'], 'B1'),
    ('fase-6-pasiva-pasado', 'Completá con la voz pasiva correcta de ''update'' en pasado.', 'The API ___ last release.', 'was updated', ARRAY['was updated','updated','is updated','updates'], 'B1'),

    -- Fase 7
    ('fase-7-going-to', 'Completá con la estructura ''going to'' correcta.', 'We ___ deploy this on Friday.', 'are going to', ARRAY['are going to','will','are','go to'], 'A2'),
    ('fase-7-going-to', 'Completá con la estructura ''going to'' correcta.', 'I''m ___ refactor this module next sprint.', 'going to', ARRAY['going to','go to','will to','gonna to'], 'A2'),
    ('fase-7-will-shall', 'Completá con will para una decisión tomada ahora mismo.', 'The build failed — I ___ rerun the pipeline.', 'will', ARRAY['will','am going to','am','would'], 'A2'),
    ('fase-7-will-shall', 'Completá con will para una promesa.', 'I ___ have the PR ready by tomorrow.', 'will', ARRAY['will','am','going to','would'], 'A2'),
    ('fase-7-continuo-futuro', 'Completá con el presente continuo con valor de futuro.', 'We ___ to production tomorrow morning.', 'are deploying', ARRAY['are deploying','deploy','will deploy','deployed'], 'B1'),
    ('fase-7-continuo-futuro', 'Completá con el presente continuo con valor de futuro.', 'I ___ the demo at 10am.', 'am presenting', ARRAY['am presenting','present','will present','presented'], 'B1'),

    -- Fase 8
    ('fase-8-can-could', 'Completá con la forma más educada de pedir algo.', '___ you review my PR when you have a moment?', 'Could', ARRAY['Could','Must','Should','Would like'], 'A2'),
    ('fase-8-can-could', 'Completá expresando habilidad.', 'She ___ write Python and Go fluently.', 'can', ARRAY['can','could','must','should'], 'A2'),
    ('fase-8-must-have-to', 'Completá con la obligación correcta.', 'You ___ run the tests before merging.', 'have to', ARRAY['have to','must not','don''t have to','should not'], 'A2'),
    ('fase-8-must-have-to', 'Completá con la prohibición correcta.', 'You ___ push directly to main.', 'mustn''t', ARRAY['mustn''t','don''t have to','should','can'], 'A2'),
    ('fase-8-should', 'Completá con la recomendación correcta.', 'You ___ add a test for this edge case.', 'should', ARRAY['should','must','can','would'], 'A2'),
    ('fase-8-should', 'Completá con la recomendación correcta.', 'We ___ document this API before releasing it.', 'should', ARRAY['should','must','can','will'], 'A2'),
    ('fase-8-would-like', 'Completá con la forma educada de expresar un deseo.', 'I ___ to request access to the staging environment.', 'would like', ARRAY['would like','like','am liking','will like'], 'A2'),
    ('fase-8-would-like', 'Completá el ofrecimiento educado.', '___ you like me to review that PR?', 'Would', ARRAY['Would','Will','Do','Are'], 'A2'),
    ('fase-8-imperativo', 'Completá con el imperativo correcto.', '___ the repo, install the dependencies, and run the tests.', 'Clone', ARRAY['Clone','You clone','Cloning','Cloned'], 'A1'),
    ('fase-8-imperativo', 'Completá con el imperativo negativo correcto.', '___ merge without at least one approval.', 'Don''t', ARRAY['Don''t','Not','Doesn''t','No'], 'A1'),

    -- Fase 9
    ('fase-9-there-is-there-are', 'Completá con there is/there are (singular).', '___ a memory leak in this service.', 'There''s', ARRAY['There''s','It is','This is','Has'], 'A1'),
    ('fase-9-there-is-there-are', 'Completá con there is/there are (plural).', '___ two monitors on the desk.', 'There are', ARRAY['There are','There''s','They are','Have'], 'A1'),
    ('fase-9-ubicacion-basica', 'Completá con la preposición correcta (superficie).', 'The keyboard is ___ the desk.', 'on', ARRAY['on','in','at','behind'], 'A1'),
    ('fase-9-ubicacion-basica', 'Completá con la preposición correcta (detrás).', 'The chair is ___ the desk.', 'behind', ARRAY['behind','on','in front of','between'], 'A1')
) AS x(subtema_slug, consigna_es, contexto_en, respuesta_esperada, opciones, nivel_cefr)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
