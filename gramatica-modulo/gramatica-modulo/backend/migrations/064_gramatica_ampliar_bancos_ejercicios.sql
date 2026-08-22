-- Fase 4 del plan de dinamismo pedagógico (ampliar bancos existentes, ver
-- memoria del proyecto): los subtemas de Fases 2-9 (más los 5 de Camino
-- 0, migración 060) se sembraron originalmente con solo 2 ejercicios cada
-- uno (migración 032) o quedaron en 2 al agregarse (migración 060) --
-- bloqueante antes del Motor de Memoria (Fase 1) y el Gusanito (Fase 9)
-- tengan con qué trabajar de verdad. Este archivo lleva cada subtema
-- afectado a ~6 ejercicios (4 nuevos cada uno, 2 para pronombres que ya
-- tenía 4). Todos tipo='cloze' con `opciones` -- mismo patrón que 032,
-- variando el escenario técnico (standup/incidente/deploy/code review)
-- para no repetir el mismo verbo/contexto que los 2 ya sembrados.
--
-- Fases 1/hora-fecha/números/abecedario NO se tocan acá -- ya están por
-- encima de 6 ejercicios (la rama activa las amplió con formatos propios:
-- audio_secuencia/conteo_visual/reloj_visual).

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES

    -- ─── Fase 2: pronombres y posesivos (4 -> 6) ───
    ('fase-2-pronombres-sujeto-objeto', 'Elegí el pronombre objeto correcto.', 'The lead reviewed my PR and gave ___ some feedback.', 'me', ARRAY['me','I','mine','my']),
    ('fase-2-pronombres-sujeto-objeto', 'Elegí el posesivo correcto.', '___ laptop crashed during the demo.', 'My', ARRAY['My','Mine','I','Me']),

    -- ─── Fase 3: Presente (2 -> 6 cada uno) ───
    ('fase-3-presente-simple', 'Completá con la forma correcta en presente simple.', 'The CI pipeline ___ (run) every time someone pushes to main.', 'runs', ARRAY['runs','run','running','ran']),
    ('fase-3-presente-simple', 'Completá con la forma correcta en presente simple.', 'She ___ (review) all pull requests before lunch.', 'reviews', ARRAY['reviews','review','reviewing','reviewed']),
    ('fase-3-presente-simple', 'Completá la pregunta en presente simple.', '___ you usually deploy on Fridays?', 'Do', ARRAY['Do','Does','Are','Is']),
    ('fase-3-presente-simple', 'Completá la negación en presente simple.', 'The database ___ (not/store) passwords in plain text.', 'doesn''t store', ARRAY['doesn''t store','don''t store','not stores','isn''t store']),

    ('fase-3-presente-continuo', 'Completá con la forma correcta en presente continuo.', 'Right now, the team ___ (fix) a critical bug.', 'is fixing', ARRAY['is fixing','fixes','fix','are fixing']),
    ('fase-3-presente-continuo', 'Completá con la forma correcta en presente continuo.', 'I ___ (write) the postmortem at the moment.', 'am writing', ARRAY['am writing','write','writes','was writing']),
    ('fase-3-presente-continuo', 'Completá con la forma correcta en presente continuo.', 'They ___ (migrate) the database this week.', 'are migrating', ARRAY['are migrating','migrate','is migrating','migrated']),
    ('fase-3-presente-continuo', 'Completá la pregunta en presente continuo.', '___ you working on the new feature today?', 'Are', ARRAY['Are','Do','Is','Does']),

    ('fase-3-simple-vs-continuo', 'Elegí presente simple o continuo (verbo de estado, no se usa en continuo).', 'She ___ (know) the answer already -- no need to explain.', 'knows', ARRAY['knows','is knowing','know','is know']),
    ('fase-3-simple-vs-continuo', 'Elegí presente simple o continuo (acción en curso ahora mismo).', 'We ___ (deploy) right now, don''t touch the server.', 'are deploying', ARRAY['are deploying','deploy','deploys','deployed']),
    ('fase-3-simple-vs-continuo', 'Elegí presente simple o continuo (rutina/hábito).', 'He ___ (work) remotely every Friday.', 'works', ARRAY['works','is working','work','working']),
    ('fase-3-simple-vs-continuo', 'Elegí presente simple o continuo (verbo de estado).', 'I ___ (want) to fix this before the demo.', 'want', ARRAY['want','am wanting','wants','wanting']),

    -- ─── Fase 4: Pasado (2 -> 6 cada uno) ───
    ('fase-4-was-were', 'Completá con la forma correcta de ''to be'' en pasado.', '___ you at the standup this morning?', 'Were', ARRAY['Were','Was','Are','Did']),
    ('fase-4-was-were', 'Completá con la forma correcta de ''to be'' en pasado.', 'The deploy ___ successful last night.', 'was', ARRAY['was','were','is','are']),
    ('fase-4-was-were', 'Completá con la forma correcta de ''to be'' en pasado.', 'They ___ in a meeting when the alert fired.', 'were', ARRAY['were','was','are','is']),
    ('fase-4-was-were', 'Completá con la forma correcta de ''to be'' en pasado.', 'I ___ not ready to present yet.', 'was', ARRAY['was','were','am','is']),

    ('fase-4-pasado-simple', 'Completá con el pasado simple correcto.', 'The bug ___ (appear) after the last deploy.', 'appeared', ARRAY['appeared','appear','appears','appearing']),
    ('fase-4-pasado-simple', 'Completá con el pasado simple correcto (verbo irregular).', 'She ___ (go) home right after the incident was resolved.', 'went', ARRAY['went','goed','go','gone']),
    ('fase-4-pasado-simple', 'Completá con el pasado simple correcto (verbo irregular).', 'The pipeline ___ (break) twice yesterday.', 'broke', ARRAY['broke','breaked','break','broken']),
    ('fase-4-pasado-simple', 'Completá la negación en pasado simple.', 'I ___ (not/test) that edge case before release.', 'didn''t test', ARRAY['didn''t test','not tested','didn''t tested','don''t test']),

    ('fase-4-pasado-continuo', 'Completá con el pasado continuo correcto.', 'We ___ (deploy) when the database crashed.', 'were deploying', ARRAY['were deploying','deployed','was deploying','deploy']),
    ('fase-4-pasado-continuo', 'Completá con el pasado continuo correcto.', 'I ___ (write) the report when you called.', 'was writing', ARRAY['was writing','were writing','wrote','write']),
    ('fase-4-pasado-continuo', 'Completá con el pasado continuo correcto (acción interrumpida).', 'While she ___ (debug) the issue, a second alert fired.', 'was debugging', ARRAY['was debugging','were debugging','debugged','debugs']),
    ('fase-4-pasado-continuo', 'Completá con el pasado continuo correcto.', 'They ___ (monitor) the servers all night during the incident.', 'were monitoring', ARRAY['were monitoring','was monitoring','monitored','monitor']),

    -- ─── Fase 5: Presente perfecto (2 -> 6 cada uno) ───
    ('fase-5-perfecto-intro', 'Completá con presente perfecto.', 'I ___ (finish) the report, so we can start the meeting.', 'have finished', ARRAY['have finished','finished','has finished','finish']),
    ('fase-5-perfecto-intro', 'Completá con presente perfecto.', 'The team ___ (resolve) the incident.', 'has resolved', ARRAY['has resolved','have resolved','resolved','resolve']),
    ('fase-5-perfecto-intro', 'Completá con presente perfecto.', 'We ___ (never/see) this error before.', 'have never seen', ARRAY['have never seen','has never seen','never saw','never see']),
    ('fase-5-perfecto-intro', 'Completá con presente perfecto.', 'He ___ (update) the documentation.', 'has updated', ARRAY['has updated','have updated','updated','updates']),

    ('fase-5-just-already-yet', 'Elegí el adverbio correcto (pasó hace muy poco).', 'I''ve ___ merged the PR -- give me a second to push.', 'just', ARRAY['just','already','yet','ever']),
    ('fase-5-just-already-yet', 'Elegí el adverbio correcto (pregunta, hasta ahora).', 'Have you tested the new build ___?', 'yet', ARRAY['yet','already','just','ever']),
    ('fase-5-just-already-yet', 'Elegí el adverbio correcto (antes de lo esperado).', 'She''s ___ reviewed my code, so I can move on.', 'already', ARRAY['already','yet','just','since']),
    ('fase-5-just-already-yet', 'Elegí el adverbio correcto (negativa, hasta ahora).', 'We haven''t deployed to production ___.', 'yet', ARRAY['yet','already','just','ago']),

    ('fase-5-ever-how-long', 'Completá la pregunta con presente perfecto.', '___ you ever worked with Kubernetes?', 'Have', ARRAY['Have','Has','Did','Do']),
    ('fase-5-ever-how-long', 'Completá la pregunta de duración.', 'How long ___ you been on this team?', 'have', ARRAY['have','has','did','do']),
    ('fase-5-ever-how-long', 'Elegí la palabra correcta (experiencia de vida).', 'Have you ___ seen a memory leak like this?', 'ever', ARRAY['ever','since','for','already']),
    ('fase-5-ever-how-long', 'Completá la pregunta de duración.', 'How long ___ the server been running without a restart?', 'has', ARRAY['has','have','did','is']),

    ('fase-5-for-since-ago', 'Elegí for/since/ago (duración).', 'I''ve worked here ___ three years.', 'for', ARRAY['for','since','ago','just']),
    ('fase-5-for-since-ago', 'Elegí for/since/ago (punto de partida).', 'She''s been on call ___ Monday.', 'since', ARRAY['since','for','ago','yet']),
    ('fase-5-for-since-ago', 'Elegí for/since/ago (con pasado simple).', 'We fixed that bug two hours ___.', 'ago', ARRAY['ago','for','since','yet']),
    ('fase-5-for-since-ago', 'Elegí for/since/ago (duración).', 'He''s been debugging this ___ hours.', 'for', ARRAY['for','since','ago','just']),

    ('fase-5-perfecto-vs-pasado', 'Elegí presente perfecto o pasado simple (momento exacto mencionado).', 'I ___ (finish) the report yesterday.', 'finished', ARRAY['finished','have finished','finish','has finished']),
    ('fase-5-perfecto-vs-pasado', 'Elegí presente perfecto o pasado simple (resultado presente).', 'We ___ (already/deploy) this -- it''s live now.', 'have already deployed', ARRAY['have already deployed','already deployed','has already deployed','deploy already']),
    ('fase-5-perfecto-vs-pasado', 'Elegí presente perfecto o pasado simple (momento exacto).', 'She ___ (join) the team in 2020.', 'joined', ARRAY['joined','has joined','join','have joined']),
    ('fase-5-perfecto-vs-pasado', 'Elegí presente perfecto o pasado simple (relevancia ahora).', 'The bug ___ (exist) since the last release -- we''re still fixing it.', 'has existed', ARRAY['has existed','existed','have existed','exist']),

    -- ─── Fase 6: Voz pasiva (2 -> 6 cada uno) ───
    ('fase-6-pasiva-presente', 'Completá en voz pasiva presente.', 'The image ___ (build) automatically on every push.', 'is built', ARRAY['is built','builds','are built','build']),
    ('fase-6-pasiva-presente', 'Completá en voz pasiva presente.', 'Passwords ___ (encrypt) before they''re stored.', 'are encrypted', ARRAY['are encrypted','is encrypted','encrypt','encrypts']),
    ('fase-6-pasiva-presente', 'Completá en voz pasiva presente.', 'The tests ___ (run) automatically by the CI pipeline.', 'are run', ARRAY['are run','run','is run','runs']),
    ('fase-6-pasiva-presente', 'Completá en voz pasiva presente.', 'The API key ___ (store) in Vault, never in code.', 'is stored', ARRAY['is stored','stores','are stored','store']),

    ('fase-6-pasiva-pasado', 'Completá en voz pasiva pasado.', 'The bug ___ (fix) last night.', 'was fixed', ARRAY['was fixed','fixed','were fixed','fix']),
    ('fase-6-pasiva-pasado', 'Completá en voz pasiva pasado.', 'The servers ___ (restart) during the maintenance window.', 'were restarted', ARRAY['were restarted','was restarted','restarted','restart']),
    ('fase-6-pasiva-pasado', 'Completá en voz pasiva pasado.', 'The report ___ (write) by the on-call engineer.', 'was written', ARRAY['was written','were written','wrote','write']),
    ('fase-6-pasiva-pasado', 'Completá en voz pasiva pasado.', 'The credentials ___ (leak) in an old commit.', 'were leaked', ARRAY['were leaked','was leaked','leaked','leak']),

    -- ─── Fase 7: Futuro (2 -> 6 cada uno) ───
    ('fase-7-going-to', 'Completá con ''going to'' (plan ya decidido).', 'We ___ (release) the new version next week.', 'are going to release', ARRAY['are going to release','will release','going to release','are go to release']),
    ('fase-7-going-to', 'Completá con ''going to'' (predicción con evidencia).', 'Look at those logs -- the server ___ (crash).', 'is going to crash', ARRAY['is going to crash','will crash','going to crash','crashes']),
    ('fase-7-going-to', 'Completá con ''going to'' (plan ya decidido).', 'She ___ (present) the results tomorrow.', 'is going to present', ARRAY['is going to present','will present','going to present','presents']),
    ('fase-7-going-to', 'Completá la negación con ''going to''.', 'I ___ (not/finish) this today, it''s too big.', 'am not going to finish', ARRAY['am not going to finish','will not finish','not going to finish','don''t going to finish']),

    ('fase-7-will-shall', 'Completá con ''will'' (decisión en el momento).', 'The phone is ringing -- I ___ (answer) it.', 'will answer', ARRAY['will answer','am going to answer','answer','answering']),
    ('fase-7-will-shall', 'Completá con ''will'' (promesa).', 'I promise I ___ (send) the report by Friday.', 'will send', ARRAY['will send','am going to send','send','sending']),
    ('fase-7-will-shall', 'Completá con ''will'' (predicción sin evidencia concreta).', 'I think it ___ (rain) later.', 'will rain', ARRAY['will rain','is going to rain','rains','raining']),
    ('fase-7-will-shall', 'Completá con ''shall'' (ofrecimiento formal).', '___ we start the meeting?', 'Shall', ARRAY['Shall','Will','Going','Do']),

    ('fase-7-continuo-futuro', 'Completá con presente continuo de valor futuro.', 'I ___ (meet) the client at 10am tomorrow.', 'am meeting', ARRAY['am meeting','will meet','meet','going meet']),
    ('fase-7-continuo-futuro', 'Completá con presente continuo de valor futuro.', 'We ___ (launch) the feature on Monday, it''s already scheduled.', 'are launching', ARRAY['are launching','will launch','launch','launched']),
    ('fase-7-continuo-futuro', 'Completá con presente continuo de valor futuro.', 'She ___ (fly) to the conference next week.', 'is flying', ARRAY['is flying','will fly','flies','flew']),
    ('fase-7-continuo-futuro', 'Completá la pregunta con presente continuo de valor futuro.', '___ you working late tonight?', 'Are', ARRAY['Are','Will','Do','Is']),

    -- ─── Fase 8: Modales e imperativo (2 -> 6 cada uno) ───
    ('fase-8-can-could', 'Elegí can/could (pedido educado).', '___ you help me with this bug?', 'Could', ARRAY['Could','Can','Must','Should']),
    ('fase-8-can-could', 'Elegí can/could (habilidad).', 'I ___ (fix) this in under an hour.', 'can fix', ARRAY['can fix','could fix','must fix','should fix']),
    ('fase-8-can-could', 'Elegí can/could (habilidad en pasado, negativa).', 'When I started, I ___ (not/write) a single line of Python.', 'couldn''t write', ARRAY['couldn''t write','can''t write','didn''t write','doesn''t write']),
    ('fase-8-can-could', 'Elegí can/could (permiso).', '___ I use your laptop for the demo?', 'Can', ARRAY['Can','Must','Should','Would']),

    ('fase-8-must-have-to', 'Elegí must/have to (prohibido).', 'You ___ touch production without approval.', 'must not', ARRAY['must not','don''t have to','mustn''t have','not must']),
    ('fase-8-must-have-to', 'Elegí must/have to (no es necesario).', 'You ___ (not/come) to the meeting if you''re sick, it''s optional.', 'don''t have to come', ARRAY['don''t have to come','must not come','mustn''t come','doesn''t have to come']),
    ('fase-8-must-have-to', 'Elegí must/have to (regla del equipo).', 'All commits ___ (pass) the linter before merging.', 'must pass', ARRAY['must pass','have to passes','has to pass','must to pass']),
    ('fase-8-must-have-to', 'Elegí must/have to (obligación externa).', 'She ___ (have to/renew) her certificate every year.', 'has to renew', ARRAY['has to renew','must to renew','have to renew','must renews']),

    ('fase-8-should', 'Elegí should (recomendación).', 'You ___ (add) more tests before merging this.', 'should add', ARRAY['should add','must add','should to add','shoulds add']),
    ('fase-8-should', 'Elegí should en negativo (recomendación).', 'We ___ (not/hardcode) credentials in the source code.', 'shouldn''t hardcode', ARRAY['shouldn''t hardcode','mustn''t hardcode','don''t should hardcode','shouldn''t hardcodes']),
    ('fase-8-should', 'Completá la pregunta con should.', '___ we refactor this before adding new features?', 'Should', ARRAY['Should','Must','Can','Will']),
    ('fase-8-should', 'Elegí should (consejo de code review).', 'He ___ (document) this function, it''s confusing.', 'should document', ARRAY['should document','must document','should to document','shoulds document']),

    ('fase-8-would-like', 'Elegí would like (pedido educado).', 'I ___ (like/review) your PR before you merge it.', 'would like to review', ARRAY['would like to review','like to review','would like review','will like to review']),
    ('fase-8-would-like', 'Completá la pregunta con would like.', '___ you like some help with the deploy?', 'Would', ARRAY['Would','Do','Will','Should']),
    ('fase-8-would-like', 'Elegí would like (ofrecimiento).', 'We ___ (like/schedule) a call for tomorrow.', 'would like to schedule', ARRAY['would like to schedule','like to schedule','would like schedule','will like schedule']),
    ('fase-8-would-like', 'Elegí would like (deseo educado).', 'She ___ (like/know) the status of the ticket.', 'would like to know', ARRAY['would like to know','like to know','would like knowing','will like to know']),

    ('fase-8-imperativo', 'Completá la instrucción en imperativo.', '___ (restart) the server before you continue.', 'Restart', ARRAY['Restart','Restarts','To restart','Restarting']),
    ('fase-8-imperativo', 'Completá la instrucción negativa en imperativo.', '___ (not/push) directly to main.', 'Don''t push', ARRAY['Don''t push','Not push','Doesn''t push','No push']),
    ('fase-8-imperativo', 'Completá la instrucción en imperativo.', '___ (check) the logs first.', 'Check', ARRAY['Check','Checks','Checking','To check']),
    ('fase-8-imperativo', 'Completá la instrucción en imperativo.', '___ (always/back up) the database before a migration.', 'Always back up', ARRAY['Always back up','Always backs up','To always back up','Always backing up']),

    -- ─── Fase 9: There is/are y ubicación (2 -> 6 cada uno) ───
    ('fase-9-there-is-there-are', 'Completá con there is/there are (singular).', '___ a typo in line 42.', 'There''s', ARRAY['There''s','It''s','This is','They''re']),
    ('fase-9-there-is-there-are', 'Completá con there is/there are (plural).', '___ three open tickets assigned to you.', 'There are', ARRAY['There are','There is','They are','It is']),
    ('fase-9-there-is-there-are', 'Completá la pregunta con there is/there are.', '___ any coffee left in the kitchen?', 'Is there', ARRAY['Is there','There is','Is it','It is']),
    ('fase-9-there-is-there-are', 'Completá con there is/there are (negativa).', '___ no internet connection right now.', 'There''s', ARRAY['There''s','It''s','This has','They have']),

    ('fase-9-ubicacion-basica', 'Elegí la preposición de lugar correcta.', 'The server rack is ___ the server room.', 'in', ARRAY['in','on','at','between']),
    ('fase-9-ubicacion-basica', 'Elegí la preposición de lugar correcta.', 'The logo is ___ the top of the page.', 'at', ARRAY['at','in','on','between']),
    ('fase-9-ubicacion-basica', 'Elegí la preposición de lugar correcta.', 'The mouse is ___ the keyboard.', 'next to', ARRAY['next to','in','between','at']),
    ('fase-9-ubicacion-basica', 'Elegí la preposición de lugar correcta.', 'The router is ___ the desk and the wall.', 'between', ARRAY['between','next to','in front of','behind']),

    -- ─── Camino 0 (migración 060): 2 -> 6 cada uno ───
    ('fase-1-saludos', 'Elegí el saludo formal para un cliente nuevo.', '___, it''s a pleasure to meet you.', 'Good afternoon', ARRAY['Good afternoon','Hey','What''s up','Bye']),
    ('fase-1-saludos', 'Elegí el saludo más neutro.', '___, everyone.', 'Hello', ARRAY['Hello','Hey','Good evening','Bye']),
    ('fase-1-saludos', 'Elegí el saludo informal para alguien que ves seguido.', '___! Long time no see.', 'Hi', ARRAY['Hi','Good morning','Goodbye','FYI']),
    ('fase-1-saludos', 'Elegí la pregunta típica al saludar.', 'Hi! ___?', 'How are you', ARRAY['How are you','What''s up','Good night','See you']),

    ('fase-1-despedidas', 'Elegí la despedida más neutra.', 'I have to go now. ___!', 'Bye', ARRAY['Bye','Take care','Good morning','ASAP']),
    ('fase-1-despedidas', 'Elegí la despedida formal/definitiva.', 'This is my last day here. ___.', 'Goodbye', ARRAY['Goodbye','Bye','See you soon','Good night']),
    ('fase-1-despedidas', 'Elegí cómo despedirte diciendo que seguirán en contacto pronto.', '___, I''ll text you.', 'Talk to you later', ARRAY['Talk to you later','Good night','Goodbye','Take care']),
    ('fase-1-despedidas', 'Elegí la despedida para cuando alguien se va de vacaciones.', '___! Enjoy your trip.', 'Have a good one', ARRAY['Have a good one','Good night','Goodbye','See you later']),

    ('fase-1-familia-coloquial', 'Elegí la palabra para "primo".', 'My ___ is visiting from another city.', 'cousin', ARRAY['cousin','uncle','bro','grandkids']),
    ('fase-1-familia-coloquial', 'Elegí la palabra para "tío".', 'My ___ taught me how to code.', 'uncle', ARRAY['uncle','auntie','cousin','dad']),
    ('fase-1-familia-coloquial', 'Elegí la palabra para "hermana" de forma informal.', 'This is my ___, she''s older than me.', 'sis', ARRAY['sis','bro','mom','auntie']),
    ('fase-1-familia-coloquial', 'Elegí la palabra para "nietos".', 'My grandparents love spending time with their ___.', 'grandkids', ARRAY['grandkids','cousins','siblings','uncles']),

    ('fase-1-abreviaturas', 'Elegí qué significa "fridge".', 'Put the milk back in the ___.', 'fridge', ARRAY['fridge','gym','cab','ATM']),
    ('fase-1-abreviaturas', 'Elegí dónde sacarías dinero en efectivo.', 'I need to stop by the ___ first.', 'ATM', ARRAY['ATM','gym','app','TV']),
    ('fase-1-abreviaturas', 'Elegí la palabra para "gimnasio".', 'I go to the ___ every morning.', 'gym', ARRAY['gym','cab','fridge','info']),
    ('fase-1-abreviaturas', 'Elegí cómo avisar algo "para tu información".', '___, the meeting moved to 3pm.', 'FYI', ARRAY['FYI','ASAP','ATM','TV']),

    ('fase-1-frutas', 'Elegí la palabra para "naranja".', 'Can I have an ___?', 'orange', ARRAY['orange','apple','pear','cherry']),
    ('fase-1-frutas', 'Elegí la palabra para "durazno".', 'This ___ is really sweet.', 'peach', ARRAY['peach','pear','grape','cherry']),
    ('fase-1-frutas', 'Elegí la palabra para "pera".', 'I packed a ___ for lunch.', 'pear', ARRAY['pear','peach','apple','banana']),
    ('fase-1-frutas', 'Elegí la palabra para "cereza".', 'The cake has a ___ on top.', 'cherry', ARRAY['cherry','grape','strawberry','orange'])

) AS x(subtema_slug, consigna_es, contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
