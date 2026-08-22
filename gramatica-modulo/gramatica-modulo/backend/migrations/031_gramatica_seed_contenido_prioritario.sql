-- ===========================================================================
-- Studentbook: contenido real (regla + ejemplos) para las Fases 1-9 --
-- prioridad pedagógica confirmada con Fable (segunda ronda, 02/ago/2026):
-- Gramática es la única parte de la app que explica el POR QUÉ de la
-- estructura (vocabulario técnico usa tiempo_verbal como ETIQUETA de una
-- forma ya conjugada -- "have deployed" en un ejercicio de cloze -- nunca
-- como la explicación de la regla). Fases 10-18 quedan con su taxonomía
-- ya sembrada (ver 030) pero sin contenido todavía -- expansión iterativa
-- (Task 10 del roadmap), no bloquea sacar esto a producción.
--
-- `audio_key` queda NULL a propósito -- lo llena el script batch de
-- síntesis (gramatica/generar_audio.py, ver Task 5) reusando el mismo
-- caché por hash que ya usa audio_pipeline.obtener_audio_patron, nunca
-- una ruta de archivo fija (ver corrección de Fable en la migración 029).
-- ===========================================================================

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, x.nivel_cefr, x.orden
FROM (VALUES
    -- ─── Fase 1: Fundamentos ───
    ('fase-1-abecedario', 'regla', 'El abecedario en inglés tiene 26 letras. Para deletrear (spell) tu nombre o una palabra poco común, se dice cada letra por su nombre en inglés. Se usa mucho al dar tu nombre por teléfono o confirmar cómo se escribe algo.', 'Could you spell that, please? — Yes, it''s J-O-H-N.', 'A1', 1),
    ('fase-1-abecedario', 'ejemplo', 'Preguntar cómo se escribe un apellido', 'How do you spell your last name?', 'A1', 2),
    ('fase-1-abecedario', 'ejemplo', 'Deletrear un email', 'My email is j-smith, all lowercase, at gmail dot com.', 'A1', 3),

    ('fase-1-numeros', 'regla', 'Los números cardinales (one, two, three...) cuentan cantidad; los ordinales (first, second, third...) indican posición u orden. A partir de four, los ordinales se forman agregando -th (four -> fourth), con excepciones irregulares en first/second/third.', 'one, two, three... / first, second, third...', 'A1', 1),
    ('fase-1-numeros', 'ejemplo', 'Contar personas en una reunión', 'There are twelve people in the meeting.', 'A1', 2),
    ('fase-1-numeros', 'ejemplo', 'Dar una posición en una carrera o ranking', 'She finished third in the competition.', 'A1', 3),

    ('fase-1-hora-fecha', 'regla', 'Para decir la hora se usa ''It''s'' + hora, con ''half past'' (y media), ''quarter past'' (y cuarto) y ''quarter to'' (menos cuarto). Para la fecha, se usa ''on'' antes del día: ''on Monday'', ''on July 4th''.', 'It''s half past three. The meeting is on Monday, July 4th.', 'A1', 1),
    ('fase-1-hora-fecha', 'ejemplo', 'Preguntar la hora', 'What time is it? — It''s a quarter to nine.', 'A1', 2),
    ('fase-1-hora-fecha', 'ejemplo', 'Dar la fecha de un evento', 'The deploy is scheduled for Friday, August 14th.', 'A1', 3),

    -- ─── Fase 2: Verbo to be y pronombres básicos ───
    ('fase-2-to-be-afirmativo', 'regla', 'El verbo ''to be'' (ser/estar) tiene 3 formas en presente: ''am'' (con I), ''is'' (con he/she/it), ''are'' (con you/we/they). Es el verbo más usado del inglés: describe identidad, estado, profesión, edad, nacionalidad.', 'I am, you are, he/she/it is, we are, they are.', 'A1', 1),
    ('fase-2-to-be-afirmativo', 'ejemplo', 'Presentarte por tu profesión', 'I am a software developer.', 'A1', 2),
    ('fase-2-to-be-afirmativo', 'ejemplo', 'Describir el estado de un sistema', 'The server is down right now.', 'A1', 3),

    ('fase-2-to-be-negativo', 'regla', 'El negativo de ''to be'' se forma agregando ''not'' después del verbo: am not, is not (isn''t), are not (aren''t). Las formas contraídas (isn''t/aren''t) son mucho más comunes en el habla natural que decir la forma completa.', 'I''m not sure. The build isn''t ready yet.', 'A1', 1),
    ('fase-2-to-be-negativo', 'ejemplo', 'Decir que algo no está listo', 'The deploy isn''t finished yet.', 'A1', 2),
    ('fase-2-to-be-negativo', 'ejemplo', 'Negar tu disponibilidad', 'I''m not available this afternoon.', 'A1', 3),

    ('fase-2-to-be-preguntas', 'regla', 'Para preguntar con ''to be'', el verbo se invierte con el sujeto: en vez de ''You are ready'' se dice ''Are you ready?''. Con palabras interrogativas (Wh-) van primero: ''Where are you?'', ''What is this?''.', 'Are you ready? Where is the meeting?', 'A1', 1),
    ('fase-2-to-be-preguntas', 'ejemplo', 'Preguntar si alguien está libre', 'Are you free tomorrow?', 'A1', 2),
    ('fase-2-to-be-preguntas', 'ejemplo', 'Preguntar la ubicación de algo', 'Where is the staging server?', 'A1', 3),

    ('fase-2-pronombres-sujeto-objeto', 'regla', 'Los pronombres sujeto (I, you, he, she, it, we, they) van antes del verbo, como quien hace la acción. Los pronombres objeto (me, you, him, her, it, us, them) van después del verbo o de una preposición, como quien recibe la acción.', 'She sent the file to me, not to I.', 'A1', 1),
    ('fase-2-pronombres-sujeto-objeto', 'ejemplo', 'Pedir ayuda a alguien', 'Can you help me with this bug?', 'A1', 2),
    ('fase-2-pronombres-sujeto-objeto', 'ejemplo', 'Hablar de un compañero de trabajo', 'I talked to him about the deploy.', 'A1', 3),

    ('fase-2-posesivos-basicos', 'regla', 'Los adjetivos posesivos (my, your, his, her, its, our, their) van antes de un sustantivo para indicar a quién pertenece: ''my laptop'', ''her branch''. No confundir con los pronombres posesivos (mine, yours, his, hers...) que reemplazan al sustantivo por completo.', 'This is my laptop. That one is hers.', 'A1', 1),
    ('fase-2-posesivos-basicos', 'ejemplo', 'Hablar de tu propia rama de git', 'I pushed my branch this morning.', 'A1', 2),
    ('fase-2-posesivos-basicos', 'ejemplo', 'Referirte al código de otro equipo', 'Their repository has better test coverage.', 'A1', 3),

    -- ─── Fase 3: Presente ───
    ('fase-3-presente-simple', 'regla', 'El presente simple describe hábitos, rutinas o hechos generales (no lo que pasa en este momento). Se agrega ''-s''/''-es'' al verbo con he/she/it: ''He works'', ''She watches''. Se usa mucho para describir cómo funciona un sistema o proceso habitual.', 'The pipeline runs every night at midnight.', 'A1', 1),
    ('fase-3-presente-simple', 'ejemplo', 'Describir una rutina de trabajo', 'I check my emails every morning.', 'A1', 2),
    ('fase-3-presente-simple', 'ejemplo', 'Explicar cómo funciona un sistema', 'The server restarts automatically after a crash.', 'A1', 3),

    ('fase-3-presente-continuo', 'regla', 'El presente continuo (am/is/are + verbo-ing) describe una acción que está pasando AHORA, en este momento, o algo temporal en curso estos días.', 'I am reviewing your pull request right now.', 'A1', 1),
    ('fase-3-presente-continuo', 'ejemplo', 'Decir qué estás haciendo ahora mismo', 'I''m debugging a production issue at the moment.', 'A1', 2),
    ('fase-3-presente-continuo', 'ejemplo', 'Describir algo temporal en curso', 'We are migrating the database this week.', 'A1', 3),

    ('fase-3-simple-vs-continuo', 'regla', 'La confusión más común: presente simple = siempre/habitualmente, presente continuo = ahora mismo/temporalmente. Ciertos verbos de estado (know, believe, want, like) casi nunca se usan en continuo.', 'I usually work in the office, but I''m working from home this week.', 'A2', 1),
    ('fase-3-simple-vs-continuo', 'ejemplo', 'Contrastar rutina vs. excepción', 'She usually takes the bus, but today she''s driving.', 'A2', 2),
    ('fase-3-simple-vs-continuo', 'ejemplo', 'Verbo de estado que no va en continuo', 'I know the answer (not: I am knowing the answer).', 'A2', 3),

    -- ─── Fase 4: Pasado ───
    ('fase-4-was-were', 'regla', '''was'' y ''were'' son el pasado del verbo ''to be''. ''was'' se usa con I/he/she/it, ''were'' con you/we/they. Describen cómo era algo o alguien en el pasado, o dónde estabas.', 'I was at the office yesterday. They were in a meeting.', 'A1', 1),
    ('fase-4-was-were', 'ejemplo', 'Explicar dónde estabas ayer', 'I was on vacation last week.', 'A1', 2),
    ('fase-4-was-were', 'ejemplo', 'Describir un estado pasado', 'The tests were failing all morning.', 'A1', 3),

    ('fase-4-pasado-simple', 'regla', 'El pasado simple describe una acción terminada en un momento específico del pasado. Los verbos regulares agregan ''-ed'' (worked, fixed), pero hay muchos irregulares con forma propia (go -> went, break -> broke).', 'I fixed the bug yesterday. The server crashed twice last night.', 'A2', 1),
    ('fase-4-pasado-simple', 'ejemplo', 'Contar qué pasó en un incidente', 'The deploy failed at 3am and woke up the whole team.', 'A2', 2),
    ('fase-4-pasado-simple', 'ejemplo', 'Describir una acción terminada', 'We merged the pull request last Friday.', 'A2', 3),

    ('fase-4-pasado-continuo', 'regla', 'El pasado continuo (was/were + verbo-ing) describe una acción en curso en un momento del pasado, muchas veces interrumpida por otra acción en pasado simple. Muy común en postmortems.', 'I was reviewing the code when the alert went off.', 'A2', 1),
    ('fase-4-pasado-continuo', 'ejemplo', 'Explicar qué estabas haciendo cuando algo pasó', 'We were deploying when the database connection dropped.', 'A2', 2),
    ('fase-4-pasado-continuo', 'ejemplo', 'Describir el contexto de un incidente', 'The service was running fine until the traffic spiked.', 'A2', 3),

    -- ─── Fase 5: Presente perfecto ───
    ('fase-5-perfecto-intro', 'regla', 'El presente perfecto (have/has + participio pasado) conecta el pasado con el presente: una acción pasada con relevancia AHORA, sin decir exactamente cuándo pasó. Distinto del pasado simple, que sí ubica la acción en un momento concreto ya cerrado.', 'I have deployed the new version. (It''s live now — that''s what matters.)', 'B1', 1),
    ('fase-5-perfecto-intro', 'ejemplo', 'Reportar en un standup', 'I have finished the migration script.', 'B1', 2),
    ('fase-5-perfecto-intro', 'ejemplo', 'Dar una noticia con relevancia actual', 'She has already reviewed your PR.', 'B1', 3),

    ('fase-5-just-already-yet', 'regla', 'Con presente perfecto: ''just'' = pasó hace muy poco (''I''ve just pushed the fix''), ''already'' = pasó antes de lo esperado (''I''ve already tested it''), ''yet'' se usa en negativas/preguntas para "hasta ahora" (''Have you deployed it yet?'', ''I haven''t tested it yet'').', 'I''ve just merged the branch. Have you tested it yet?', 'B1', 1),
    ('fase-5-just-already-yet', 'ejemplo', 'Avisar que acabás de hacer algo', 'I''ve just pushed the hotfix.', 'B1', 2),
    ('fase-5-just-already-yet', 'ejemplo', 'Preguntar si algo ya se hizo', 'Has she reviewed the PR yet?', 'B1', 3),

    ('fase-5-ever-how-long', 'regla', '''ever'' (alguna vez) se usa en preguntas con presente perfecto para preguntar por experiencia de vida. ''How long have you...?'' pregunta por la duración de algo que sigue siendo cierto ahora.', 'Have you ever debugged a memory leak? How long have you been on this team?', 'B1', 1),
    ('fase-5-ever-how-long', 'ejemplo', 'Preguntar por experiencia', 'Have you ever deployed to production on a Friday?', 'B1', 2),
    ('fase-5-ever-how-long', 'ejemplo', 'Preguntar por duración de algo actual', 'How long have you known about this bug?', 'B1', 3),

    ('fase-5-for-since-ago', 'regla', '''for'' + duración (for three years) se usa con presente perfecto para decir CUÁNTO tiempo. ''since'' + punto en el tiempo (since 2020) indica DESDE CUÁNDO. ''ago'' (hace) se usa con pasado simple, no presente perfecto.', 'I''ve worked here for three years, since 2023. I started three years ago.', 'B1', 1),
    ('fase-5-for-since-ago', 'ejemplo', 'Decir cuánto tiempo llevás en algo', 'I''ve used this framework for six months.', 'B1', 2),
    ('fase-5-for-since-ago', 'ejemplo', 'Decir desde cuándo pasa algo', 'The service has been down since 2pm.', 'B1', 3),

    ('fase-5-perfecto-vs-pasado', 'regla', 'Si el momento exacto importa o se menciona (yesterday, last week, in 2020), se usa pasado simple. Si lo que importa es el resultado presente y no se dice cuándo pasó exactamente, se usa presente perfecto.', 'I fixed the bug yesterday. / I have fixed the bug, so you can deploy now.', 'B1', 1),
    ('fase-5-perfecto-vs-pasado', 'ejemplo', 'Momento específico -> pasado simple', 'We deployed the fix at 4pm yesterday.', 'B1', 2),
    ('fase-5-perfecto-vs-pasado', 'ejemplo', 'Resultado presente -> presente perfecto', 'We have deployed the fix, so the issue should be gone now.', 'B1', 3),

    -- ─── Fase 6: Voz pasiva ───
    ('fase-6-pasiva-presente', 'regla', 'La voz pasiva (am/is/are + participio pasado) se usa cuando importa más la acción o quien la recibe que quien la hace -- muy común en descripciones técnicas impersonales. El sujeto de la oración pasiva es quien RECIBE la acción.', 'The image is built and scanned before every deploy.', 'B1', 1),
    ('fase-6-pasiva-presente', 'ejemplo', 'Describir un paso de un pipeline sin decir quién lo hace', 'The code is reviewed before it''s merged.', 'B1', 2),
    ('fase-6-pasiva-presente', 'ejemplo', 'Describir un proceso impersonal', 'Errors are logged automatically.', 'B1', 3),

    ('fase-6-pasiva-pasado', 'regla', 'La voz pasiva en pasado se forma con was/were + participio pasado. Se usa para hechos ya terminados cuando no importa (o no se sabe) quién los hizo.', 'The outage was caused by a misconfigured load balancer.', 'B1', 1),
    ('fase-6-pasiva-pasado', 'ejemplo', 'Explicar la causa de un incidente sin nombrar culpables', 'The database was corrupted during the migration.', 'B1', 2),
    ('fase-6-pasiva-pasado', 'ejemplo', 'Describir un cambio ya aplicado', 'The API was updated last release.', 'B1', 3),

    -- ─── Fase 7: Futuro ───
    ('fase-7-going-to', 'regla', '''be going to'' + verbo se usa para planes ya decididos o predicciones basadas en evidencia presente.', 'We are going to deploy this on Friday.', 'A2', 1),
    ('fase-7-going-to', 'ejemplo', 'Anunciar un plan ya decidido', 'I''m going to refactor this module next sprint.', 'A2', 2),
    ('fase-7-going-to', 'ejemplo', 'Predecir algo por evidencia actual', 'Look at these logs — the server is going to crash soon.', 'A2', 3),

    ('fase-7-will-shall', 'regla', '''will'' + verbo se usa para decisiones tomadas EN EL MOMENTO de hablar (no planeadas antes), promesas, y predicciones sin evidencia concreta. ''shall'' es formal y poco usado hoy salvo en ofrecimientos.', 'I''ll take a look at that bug right now.', 'A2', 1),
    ('fase-7-will-shall', 'ejemplo', 'Decidir algo en el momento', 'The build failed — I''ll rerun the pipeline.', 'A2', 2),
    ('fase-7-will-shall', 'ejemplo', 'Hacer una promesa', 'I''ll have the PR ready by tomorrow.', 'A2', 3),

    ('fase-7-continuo-futuro', 'regla', 'El presente continuo también se usa para planes futuros ya organizados, con hora/fecha concreta -- muy parecido a ''going to'' pero con más certeza de que ya está agendado.', 'We''re deploying to production tomorrow morning.', 'B1', 1),
    ('fase-7-continuo-futuro', 'ejemplo', 'Hablar de una reunión ya agendada', 'I''m presenting the demo at 10am.', 'B1', 2),
    ('fase-7-continuo-futuro', 'ejemplo', 'Confirmar un plan con fecha fija', 'The team is migrating the database this weekend.', 'B1', 3),

    -- ─── Fase 8: Modales e imperativo ───
    ('fase-8-can-could', 'regla', '''can'' expresa habilidad o permiso en presente. ''could'' es su versión más educada/formal o el pasado de ''can''. ''Could you...?'' es la forma más común y educada de pedir algo.', 'Could you review my PR when you have a moment?', 'A2', 1),
    ('fase-8-can-could', 'ejemplo', 'Pedir algo educadamente', 'Could you send me the logs?', 'A2', 2),
    ('fase-8-can-could', 'ejemplo', 'Expresar habilidad', 'She can write Python and Go fluently.', 'A2', 3),

    ('fase-8-must-have-to', 'regla', '''must'' y ''have to'' expresan obligación. ''must'' suena a regla impuesta por quien habla (más fuerte); ''have to'' es más neutral, obligación externa. En negativo son MUY distintos: ''must not'' = prohibido, ''don''t have to'' = no es necesario.', 'You must not commit secrets to the repo. You don''t have to attend every meeting.', 'A2', 1),
    ('fase-8-must-have-to', 'ejemplo', 'Expresar una regla obligatoria', 'You have to run the tests before merging.', 'A2', 2),
    ('fase-8-must-have-to', 'ejemplo', 'Contrastar prohibición vs. no-necesidad', 'You mustn''t push directly to main, but you don''t have to squash your commits.', 'A2', 3),

    ('fase-8-should', 'regla', '''should'' expresa recomendación o consejo (no obligación estricta). Es el modal típico del code review, donde se sugiere sin imponer.', 'You should add a test for this edge case.', 'A2', 1),
    ('fase-8-should', 'ejemplo', 'Dar una recomendación en un code review', 'You should extract this into a separate function.', 'A2', 2),
    ('fase-8-should', 'ejemplo', 'Sugerir una buena práctica', 'We should document this API before releasing it.', 'A2', 3),

    ('fase-8-would-like', 'regla', '''would like'' (querría/me gustaría) es la forma educada de expresar un deseo, más formal que ''want''. Se usa mucho para pedidos y ofrecimientos.', 'I would like to discuss the architecture before we start.', 'A2', 1),
    ('fase-8-would-like', 'ejemplo', 'Pedir algo formalmente', 'I''d like to request access to the staging environment.', 'A2', 2),
    ('fase-8-would-like', 'ejemplo', 'Ofrecer ayuda educadamente', 'Would you like me to review that PR?', 'A2', 3),

    ('fase-8-imperativo', 'regla', 'El imperativo usa el verbo en su forma base, sin sujeto, para dar órdenes, instrucciones o consejos directos. Es la forma típica de instrucciones técnicas paso a paso.', 'Clone the repo, install the dependencies, and run the tests.', 'A1', 1),
    ('fase-8-imperativo', 'ejemplo', 'Dar instrucciones técnicas', 'Restart the server after applying the config change.', 'A1', 2),
    ('fase-8-imperativo', 'ejemplo', 'Dar una advertencia directa', 'Don''t merge without at least one approval.', 'A1', 3),

    -- ─── Fase 9: There is / there are y ubicación ───
    ('fase-9-there-is-there-are', 'regla', '''There is'' (singular) y ''there are'' (plural) se usan para decir que algo EXISTE en un lugar, sin ser el foco principal de la oración (a diferencia de ''it is'').', 'There''s a chair behind the desk. There are two monitors on it.', 'A1', 1),
    ('fase-9-there-is-there-are', 'ejemplo', 'Describir qué hay en un lugar', 'There''s a whiteboard in the meeting room.', 'A1', 2),
    ('fase-9-there-is-there-are', 'ejemplo', 'Reportar un problema que existe', 'There''s a memory leak in this service.', 'A1', 3),

    ('fase-9-ubicacion-basica', 'regla', 'Preposiciones de lugar básicas: ''in'' (dentro de un espacio cerrado/ciudad/país), ''on'' (sobre una superficie), ''at'' (en un punto específico), ''behind'' (detrás), ''in front of'' (delante), ''next to''/''beside'' (al lado), ''between'' (entre dos cosas).', 'The chair is behind the desk, next to the window.', 'A1', 1),
    ('fase-9-ubicacion-basica', 'ejemplo', 'Describir dónde está un objeto', 'The keyboard is on the desk, in front of the monitor.', 'A1', 2),
    ('fase-9-ubicacion-basica', 'ejemplo', 'Dar indicaciones dentro de una oficina', 'The meeting room is between the kitchen and the elevator.', 'A1', 3)
) AS x(subtema_slug, tipo, texto_es, texto_en, nivel_cefr, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
