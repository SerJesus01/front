-- Fase 8 del plan de dinamismo pedagógico (expansión de Fases faltantes,
-- ver memoria del proyecto): siembra el contenido real (regla+2 ejemplos)
-- + 2 ejercicios iniciales para las 30 subtemas de Fases 10-17, cuya
-- taxonomía ya existía vacía desde el diseño original (migración 030).
-- Densidad inicial de 2 ejercicios por subtema, igual que el bootstrap
-- original de Fases 1-9 (migración 032) -- ampliar a ~6 es un paso
-- posterior explícito (mismo criterio que ya se aplicó con la Fase 4).
--
-- Orden de siembra acordado con el dueño (por densidad real de error en
-- hispanohablantes, no por orden del libro): preguntas/negación (10) ->
-- artículos/contables (13) -> gerundio/infinitivo (11) -> conectores
-- avanzados (16) -> preposiciones (17) -> determinantes/adjetivos (14+15).
-- Fase 12 (pronombres, profundización) y Fase 18 (vocabulario situacional,
-- eliminada de la taxonomía por decisión ya tomada) completan el resto.

-- ─── Reglas + ejemplos ───

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    -- Fase 10: Preguntas y negación
    ('fase-10-wh-questions', 'regla', 'Las preguntas Wh- (what/where/when/why/who/how) van seguidas de auxiliar+sujeto+verbo: ''What do you do?'', ''Where is the server?''. Si la palabra Wh- ES el sujeto (who/what), no se invierte: ''Who broke the build?'' (no ''Who did break the build?'').', 'Why did the deploy fail? Who pushed to main?', 1),
    ('fase-10-wh-questions', 'ejemplo', 'Preguntar por la razón de un error', 'Why did the deploy fail?', 2),
    ('fase-10-wh-questions', 'ejemplo', 'Preguntar quién hizo algo (Wh- como sujeto, sin auxiliar)', 'Who pushed to main?', 3),

    ('fase-10-question-tags', 'regla', 'Las question tags son una mini-pregunta al final para confirmar o buscar acuerdo: afirmativa+tag negativo (''You tested this, didn''t you?''), negativa+tag afirmativo (''It isn''t ready, is it?''). El verbo del tag repite el auxiliar (o do/does/did si no hay).', 'You already deployed it, didn''t you?', 1),
    ('fase-10-question-tags', 'ejemplo', 'Confirmar algo que ya creés cierto', 'You already deployed it, didn''t you?', 2),
    ('fase-10-question-tags', 'ejemplo', 'Pedir confirmación en negativo', 'This isn''t working, is it?', 3),

    ('fase-10-preguntas-indirectas', 'regla', 'Las preguntas indirectas (''Could you tell me...'', ''I wonder if...'') suenan más educadas -- después de la palabra Wh-/if, el orden vuelve a ser sujeto+verbo (sin invertir): ''Where is the server?'' -> ''Do you know where the server is?''.', 'Could you tell me when the meeting starts?', 1),
    ('fase-10-preguntas-indirectas', 'ejemplo', 'Preguntar algo de forma más educada en una reunión', 'Could you tell me when the meeting starts?', 2),
    ('fase-10-preguntas-indirectas', 'ejemplo', 'Preguntar indirectamente con ''if''', 'I wonder if the fix is ready.', 3),

    -- Fase 13: Artículos y contables/incontables
    ('fase-13-a-an-the', 'regla', '''a''/''an'' se usan para algo no específico mencionado por primera vez (a: sonido consonante, an: sonido vocal). ''the'' se usa cuando ya se sabe de qué se habla (mencionado antes, o único en el contexto).', 'I found a bug in the login flow.', 1),
    ('fase-13-a-an-the', 'ejemplo', 'Mencionar algo por primera vez', 'I found a bug in the login flow.', 2),
    ('fase-13-a-an-the', 'ejemplo', 'Referirse a algo ya mencionado/específico', 'The bug I found yesterday is still there.', 3),

    ('fase-13-contables-incontables', 'regla', 'Los sustantivos contables tienen plural (one bug, two bugs). Los incontables no tienen plural y se miden con otra palabra (some information, a piece of advice) -- error muy común: ''informations''/''advices''/''furnitures'' NO existen en inglés.', 'Can you give me some information about the deploy?', 1),
    ('fase-13-contables-incontables', 'ejemplo', 'Pedir información (incontable, sin plural)', 'Can you give me some information about the deploy?', 2),
    ('fase-13-contables-incontables', 'ejemplo', 'Hablar de consejos (incontable)', 'She gave me some good advice.', 3),

    ('fase-13-some-any', 'regla', '''some'' se usa en afirmativas y ofrecimientos (''There are some bugs'', ''Would you like some coffee?''). ''any'' se usa en negativas y preguntas (''There aren''t any bugs'', ''Are there any updates?'').', 'Would you like some coffee? Are there any updates?', 1),
    ('fase-13-some-any', 'ejemplo', 'Ofrecer algo', 'Would you like some coffee?', 2),
    ('fase-13-some-any', 'ejemplo', 'Preguntar si hay algo (pregunta, any)', 'Are there any updates on the ticket?', 3),

    -- Fase 11: Gerundio vs. infinitivo
    ('fase-11-verbo-ing', 'regla', 'Ciertos verbos siempre van seguidos de gerundio (verbo+ing), nunca infinitivo: enjoy, avoid, finish, keep, suggest, mind, consider. ''I enjoy coding'' (correcto), NO ''I enjoy to code''.', 'I finished writing the report.', 1),
    ('fase-11-verbo-ing', 'ejemplo', 'Decir que terminaste algo', 'I finished writing the report.', 2),
    ('fase-11-verbo-ing', 'ejemplo', 'Sugerir algo (verbo que pide gerundio)', 'I suggest reviewing the code first.', 3),

    ('fase-11-verbo-to', 'regla', 'Otros verbos siempre van seguidos de infinitivo con ''to'': want, need, decide, plan, promise, agree, hope. ''I want to fix this'' (correcto), NO ''I want fixing this''.', 'We decided to migrate the database.', 1),
    ('fase-11-verbo-to', 'ejemplo', 'Decir un plan futuro', 'We decided to migrate the database.', 2),
    ('fase-11-verbo-to', 'ejemplo', 'Expresar una necesidad', 'I need to talk to you about the deploy.', 3),

    -- Fase 16: Conectores y cláusulas
    ('fase-16-conectores-adicion', 'regla', 'Conectores de adición suman ideas en la misma dirección: ''and'' (neutro), ''also''/''in addition'' (más formal), ''as well as''.', 'The fix was fast and effective. In addition, we updated the docs.', 1),
    ('fase-16-conectores-adicion', 'ejemplo', 'Sumar una idea de forma neutra', 'The fix was fast and effective.', 2),
    ('fase-16-conectores-adicion', 'ejemplo', 'Sumar formalmente al inicio', 'In addition, we updated the documentation.', 3),

    ('fase-16-conectores-causales', 'regla', 'Conectores causales explican el porqué: ''because'' + oración completa, ''because of'' + sustantivo, ''since''/''as'' (más formal, causa ya conocida).', 'The service went down because the disk was full.', 1),
    ('fase-16-conectores-causales', 'ejemplo', 'Explicar la causa de un incidente', 'The service went down because the disk was full.', 2),
    ('fase-16-conectores-causales', 'ejemplo', 'Causa con sustantivo (because of)', 'The deploy failed because of a missing env variable.', 3),

    ('fase-16-conectores-contraste', 'regla', 'Conectores de contraste marcan una idea opuesta: ''but'' (neutro), ''however'' (formal, con coma después), ''although''/''even though'' (+ oración completa).', 'The fix worked, but it was risky.', 1),
    ('fase-16-conectores-contraste', 'ejemplo', 'Contraste neutro', 'The fix worked, but it was risky.', 2),
    ('fase-16-conectores-contraste', 'ejemplo', 'Contraste formal con however', 'The tests passed. However, we found a new issue.', 3),

    ('fase-16-conectores-secuenciales', 'regla', 'Los conectores secuenciales ordenan pasos, como en una receta: ''first'' (primero), ''then''/''next'' (después), ''after that'' (luego de eso), ''finally'' (por último).', 'First, pull the latest changes. Finally, restart the service.', 1),
    ('fase-16-conectores-secuenciales', 'ejemplo', 'Describir el primer paso de un proceso', 'First, pull the latest changes.', 2),
    ('fase-16-conectores-secuenciales', 'ejemplo', 'Describir el último paso', 'Finally, restart the service.', 3),

    ('fase-16-condicionales-if', 'regla', 'Condicional tipo 1 (real/posible): if + presente simple, will + verbo -- ''If the test fails, we will roll back''. Condicional tipo 0 (siempre verdadero): if + presente simple, presente simple -- ''If you restart the server, it clears the cache''.', 'If the build fails, we will notify the team.', 1),
    ('fase-16-condicionales-if', 'ejemplo', 'Condicional tipo 1 (posible en el futuro)', 'If the build fails, we will notify the team.', 2),
    ('fase-16-condicionales-if', 'ejemplo', 'Condicional tipo 0 (siempre cierto)', 'If you restart the server, the cache clears.', 3),

    ('fase-16-clausulas-relativas', 'regla', 'Las cláusulas relativas agregan info sobre un sustantivo con ''who'' (personas), ''which''/''that'' (cosas), ''where'' (lugares): ''The developer who fixed the bug is on vacation'', ''The server that crashed is back up''.', 'The developer who fixed the bug is on vacation.', 1),
    ('fase-16-clausulas-relativas', 'ejemplo', 'Agregar info sobre una persona (who)', 'The developer who fixed the bug is on vacation.', 2),
    ('fase-16-clausulas-relativas', 'ejemplo', 'Agregar info sobre un lugar (where)', 'This is the server room where the incident started.', 3),

    -- Fase 17: Preposiciones
    ('fase-17-preposiciones-tiempo', 'regla', '''at'' para horas exactas (at 3pm), ''on'' para días/fechas (on Monday, on July 4th), ''in'' para meses/años/períodos largos (in July, in 2020, in the morning).', 'The meeting starts at 9am. We deploy on Fridays.', 1),
    ('fase-17-preposiciones-tiempo', 'ejemplo', 'Hora exacta (at)', 'The meeting starts at 9am.', 2),
    ('fase-17-preposiciones-tiempo', 'ejemplo', 'Día específico (on)', 'We deploy on Fridays.', 3),

    ('fase-17-preposiciones-lugar', 'regla', '''in'' para espacios cerrados/ciudades/países (in the office), ''on'' para superficies (on the desk), ''at'' para puntos específicos, ''behind''/''in front of''/''next to''/''between'' para posiciones relativas.', 'The keyboard is on the desk, in front of the monitor.', 1),
    ('fase-17-preposiciones-lugar', 'ejemplo', 'Ubicación con on (superficie) y in front of', 'The keyboard is on the desk, in front of the monitor.', 2),
    ('fase-17-preposiciones-lugar', 'ejemplo', 'Ubicación entre dos cosas', 'The meeting room is between the kitchen and the elevator.', 3),

    ('fase-17-preposiciones-direccion', 'regla', '''to'' indica movimiento hacia un lugar (go to the office), ''into'' indica entrar en un espacio (walk into the room), ''through'' indica atravesar (go through the tunnel/process).', 'How can I go to the mall from here?', 1),
    ('fase-17-preposiciones-direccion', 'ejemplo', 'Movimiento hacia un lugar (to)', 'How can I go to the mall from here?', 2),
    ('fase-17-preposiciones-direccion', 'ejemplo', 'Entrar a un espacio (into)', 'She walked into the meeting room.', 3),

    -- Fase 14: Determinantes y cuantificadores
    ('fase-14-this-that', 'regla', '''this''/''these'' señalan algo cerca (tiempo/espacio); ''that''/''those'' señalan algo más lejos. ''this''/''that'' son singulares, ''these''/''those'' son plurales.', 'This bug is blocking the release. That issue from last week is still open.', 1),
    ('fase-14-this-that', 'ejemplo', 'Señalar algo cercano ahora mismo', 'This bug is blocking the release.', 2),
    ('fase-14-this-that', 'ejemplo', 'Referirse a algo mencionado antes (más lejos)', 'That issue from last week is still open.', 3),

    ('fase-14-every-all', 'regla', '''every'' + sustantivo singular habla de cada elemento individualmente (''every test passed''). ''all'' + sustantivo plural habla del grupo completo (''all tests passed'').', 'Every test passed this time. All the tests passed this time.', 1),
    ('fase-14-every-all', 'ejemplo', 'Hablar de cada elemento individualmente', 'Every test passed this time.', 2),
    ('fase-14-every-all', 'ejemplo', 'Hablar del grupo completo', 'All the tests passed this time.', 3),

    ('fase-14-both-either-neither', 'regla', '''both'' habla de los dos elementos juntos (''both servers are down''). ''either'' es uno u otro de dos (''either server works''). ''neither'' es ninguno de los dos (''neither server is responding'').', 'Both servers are down. Neither option works for this case.', 1),
    ('fase-14-both-either-neither', 'ejemplo', 'Hablar de los dos elementos juntos', 'Both servers are down.', 2),
    ('fase-14-both-either-neither', 'ejemplo', 'Decir que ninguno de los dos funciona', 'Neither option works for this case.', 3),

    ('fase-14-much-many', 'regla', '''much'' se usa con sustantivos incontables (much time, much information). ''many'' se usa con sustantivos contables plurales (many bugs, many tickets).', 'We don''t have much time left. How many tickets are still open?', 1),
    ('fase-14-much-many', 'ejemplo', 'Preguntar cantidad de algo incontable', 'We don''t have much time left.', 2),
    ('fase-14-much-many', 'ejemplo', 'Preguntar cantidad de algo contable', 'How many tickets are still open?', 3),

    ('fase-14-little-few', 'regla', '''a little'' con incontables (a little time = un poco de tiempo). ''a few'' con contables plurales (a few bugs = unos pocos bugs). Sin el ''a'', el significado se vuelve negativo: ''little time'' (casi nada de tiempo).', 'We have a little time before the demo. There are a few bugs left to fix.', 1),
    ('fase-14-little-few', 'ejemplo', 'Decir que queda algo de tiempo (incontable)', 'We have a little time before the demo.', 2),
    ('fase-14-little-few', 'ejemplo', 'Decir que quedan unos pocos bugs (contable)', 'There are a few bugs left to fix.', 3),

    -- Fase 15: Adjetivos y adverbios
    ('fase-15-orden-adjetivos', 'regla', 'Con varios adjetivos antes de un sustantivo, el orden típico es opinión-tamaño-edad-color-origen (ej. ''a great, small, old, blue, German car''). No es 100% estricta, pero seguirla suena mucho más natural.', 'It''s a great American tool. She has a small, blue laptop.', 1),
    ('fase-15-orden-adjetivos', 'ejemplo', 'Describir algo con opinión+origen', 'It''s a great American tool.', 2),
    ('fase-15-orden-adjetivos', 'ejemplo', 'Describir con tamaño+color', 'She has a small, blue laptop.', 3),

    ('fase-15-comparativos', 'regla', 'Adjetivos cortos agregan ''-er'' (faster, bigger); adjetivos largos usan ''more'' (more efficient). Comparación completa con ''than'': ''This server is faster than that one''.', 'This server is faster than the old one.', 1),
    ('fase-15-comparativos', 'ejemplo', 'Comparar velocidad (adjetivo corto)', 'This server is faster than the old one.', 2),
    ('fase-15-comparativos', 'ejemplo', 'Comparar con adjetivo largo', 'This solution is more efficient than the previous one.', 3),

    ('fase-15-superlativos', 'regla', 'Adjetivos cortos agregan ''-est'' con ''the'' (the fastest); adjetivos largos usan ''the most'' (the most efficient). Comparan contra TODO un grupo, no solo dos cosas.', 'This is the fastest server we have.', 1),
    ('fase-15-superlativos', 'ejemplo', 'Decir cuál es el mejor de todos (corto)', 'This is the fastest server we have.', 2),
    ('fase-15-superlativos', 'ejemplo', 'Decir cuál es el mejor de todos (largo)', 'This is the most efficient algorithm we''ve tested.', 3),

    ('fase-15-adverbios-modo', 'regla', 'Los adverbios de modo describen CÓMO se hace algo, formados agregando ''-ly'' al adjetivo (quick -> quickly, careful -> carefully). Van después del verbo/objeto: ''She fixed it quickly''.', 'He fixed the bug quickly.', 1),
    ('fase-15-adverbios-modo', 'ejemplo', 'Describir cómo se hizo algo, rápido', 'He fixed the bug quickly.', 2),
    ('fase-15-adverbios-modo', 'ejemplo', 'Describir cómo se hizo algo, con cuidado', 'Please review this carefully.', 3),

    ('fase-15-adverbios-frecuencia', 'regla', 'Los adverbios de frecuencia (always, usually, often, sometimes, rarely, never) van ANTES del verbo principal, pero DESPUÉS del verbo ''to be'': ''I usually deploy on Mondays'', ''She is always on time''.', 'I usually deploy on Mondays. She is always on time for standup.', 1),
    ('fase-15-adverbios-frecuencia', 'ejemplo', 'Decir con qué frecuencia hacés algo (antes del verbo)', 'I usually deploy on Mondays.', 2),
    ('fase-15-adverbios-frecuencia', 'ejemplo', 'Frecuencia con el verbo ''to be'' (después)', 'She is always on time for standup.', 3),

    -- Fase 12: Pronombres y posesivos (profundización)
    ('fase-12-reflexivos', 'regla', 'Los pronombres reflexivos (myself, yourself, himself, herself, itself, ourselves, yourselves, themselves) se usan cuando sujeto y objeto son la misma persona (''I fixed it myself''), o para enfatizar que alguien lo hizo sin ayuda.', 'I debugged this myself. The script fixes itself automatically.', 1),
    ('fase-12-reflexivos', 'ejemplo', 'Decir que hiciste algo sin ayuda', 'I debugged this myself.', 2),
    ('fase-12-reflexivos', 'ejemplo', 'Hablar de un sistema que se corrige solo', 'The script fixes itself automatically.', 3),

    ('fase-12-whose-mine-yours', 'regla', '''whose'' pregunta de quién es algo (''Whose laptop is this?''). Los pronombres posesivos (mine, yours, his, hers, ours, theirs) reemplazan al sustantivo completo: ''This is my laptop'' -> ''This is mine''.', 'Whose keyboard is this? Is this laptop yours?', 1),
    ('fase-12-whose-mine-yours', 'ejemplo', 'Preguntar de quién es un objeto', 'Whose keyboard is this?', 2),
    ('fase-12-whose-mine-yours', 'ejemplo', 'Decir que algo es tuyo, sin repetir el sustantivo', 'Is this laptop yours?', 3),

    ('fase-12-posesivo-s', 'regla', 'El posesivo ''s se agrega al final de un sustantivo para indicar pertenencia: ''the manager''s laptop''. Si el sustantivo ya termina en ''s'' (plural), solo se agrega el apóstrofo: ''the developers'' meeting''.', 'That''s the manager''s decision.', 1),
    ('fase-12-posesivo-s', 'ejemplo', 'Decir de quién es algo usando ''s', 'That''s the manager''s decision.', 2),
    ('fase-12-posesivo-s', 'ejemplo', 'Posesivo con sustantivo plural terminado en s', 'This is the developers'' shared repository.', 3)

) AS x(subtema_slug, tipo, texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;

-- Cierra el prompt de escena pendiente (ver imagenes_gramatica/PROMPTS_PENDIENTES.md,
-- diseñado con el dueño para preposiciones de lugar) -- estos 2 ejemplos
-- son exactamente los que se pensaron para esa imagen.
UPDATE gramatica_contenido gc
SET imagen_key = 'escena_oficina_prep_lugar'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-17-preposiciones-lugar' AND gc.tipo = 'ejemplo';

-- ─── Ejercicios (2 por subtema, cloze+opciones -- densidad inicial, ver Fase 4 para ampliar después) ───

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES
    ('fase-10-wh-questions', 'Completá la pregunta Wh-.', '___ did you fix the bug?', 'How', ARRAY['How','Who','What','Where']),
    ('fase-10-wh-questions', 'Completá la pregunta Wh- (sujeto, sin auxiliar).', '___ broke the build?', 'Who', ARRAY['Who','Who did','What did','Whom']),

    ('fase-10-question-tags', 'Completá la question tag.', 'You reviewed the PR, ___?', 'didn''t you', ARRAY['didn''t you','did you','don''t you','aren''t you']),
    ('fase-10-question-tags', 'Completá la question tag (negativa+afirmativa).', 'It isn''t deployed yet, ___?', 'is it', ARRAY['is it','isn''t it','does it','is it not']),

    ('fase-10-preguntas-indirectas', 'Completá la pregunta indirecta (sujeto+verbo, sin invertir).', 'Do you know ___?', 'where the server is', ARRAY['where the server is','where is the server','where the server','is where the server']),
    ('fase-10-preguntas-indirectas', 'Completá la pregunta indirecta educada.', 'Could you tell me ___?', 'what time it is', ARRAY['what time it is','what time is it','what is the time','is it what time']),

    ('fase-13-a-an-the', 'Completá con a/an/the.', 'I need ___ hour to finish this.', 'an', ARRAY['an','a','the','']),
    ('fase-13-a-an-the', 'Completá con a/an/the (ya mencionado antes).', 'I opened a ticket. ___ ticket is still open.', 'The', ARRAY['The','A','An','']),

    ('fase-13-contables-incontables', 'Elegí la forma correcta (incontable, sin plural).', 'I need more ___ before deciding.', 'information', ARRAY['information','informations','an information','the informations']),
    ('fase-13-contables-incontables', 'Elegí la forma correcta (incontable).', 'He gave me useful ___ about the interview.', 'advice', ARRAY['advice','advices','an advice','advice''s']),

    ('fase-13-some-any', 'Completá con some/any (afirmativa).', 'There are ___ open tickets.', 'some', ARRAY['some','any','a','the']),
    ('fase-13-some-any', 'Completá con some/any (negativa).', 'We don''t have ___ tests for this yet.', 'any', ARRAY['any','some','a','the']),

    ('fase-11-verbo-ing', 'Completá con gerundio (verbo que siempre lo pide).', 'I really enjoy ___ (code).', 'coding', ARRAY['coding','to code','code','coded']),
    ('fase-11-verbo-ing', 'Completá con gerundio.', 'We should avoid ___ (deploy) on Fridays.', 'deploying', ARRAY['deploying','to deploy','deploy','deployed']),

    ('fase-11-verbo-to', 'Completá con infinitivo (verbo que siempre lo pide).', 'I want ___ (fix) this before the demo.', 'to fix', ARRAY['to fix','fixing','fix','fixed']),
    ('fase-11-verbo-to', 'Completá con infinitivo.', 'She promised ___ (review) my code today.', 'to review', ARRAY['to review','reviewing','review','reviewed']),

    ('fase-16-conectores-adicion', 'Elegí el conector de adición correcto (formal).', 'The deploy was fast. ___, it was stable.', 'In addition', ARRAY['In addition','However','Because','Although']),
    ('fase-16-conectores-adicion', 'Elegí el conector de adición correcto.', 'She reviewed the code ___ tested it herself.', 'and', ARRAY['and','but','so','because']),

    ('fase-16-conectores-causales', 'Elegí el conector causal correcto (+ sustantivo).', 'The build failed ___ a missing dependency.', 'because of', ARRAY['because of','because','since','so']),
    ('fase-16-conectores-causales', 'Elegí el conector causal correcto (+ oración).', 'We rolled back ___ the error rate spiked.', 'because', ARRAY['because','because of','so','but']),

    ('fase-16-conectores-contraste', 'Elegí el conector de contraste correcto (formal).', 'The deploy succeeded. ___, performance dropped.', 'However', ARRAY['However','Because','So','And']),
    ('fase-16-conectores-contraste', 'Elegí el conector de contraste correcto (+ oración completa).', '___ the fix was quick, it introduced a new bug.', 'Although', ARRAY['Although','However','Because','So']),

    ('fase-16-conectores-secuenciales', 'Elegí el conector secuencial correcto (primer paso).', '___, run the tests locally.', 'First', ARRAY['First','Finally','Then','After']),
    ('fase-16-conectores-secuenciales', 'Elegí el conector secuencial correcto (último paso).', '___, deploy to production.', 'Finally', ARRAY['Finally','First','Then','Next']),

    ('fase-16-condicionales-if', 'Completá el condicional tipo 1.', 'If the tests fail, we ___ (not/deploy).', 'will not deploy', ARRAY['will not deploy','don''t deploy','won''t deployed','not will deploy']),
    ('fase-16-condicionales-if', 'Completá el condicional tipo 0 (siempre cierto).', 'If you ___ (restart) the server, the cache clears.', 'restart', ARRAY['restart','will restart','restarted','restarts']),

    ('fase-16-clausulas-relativas', 'Completá la cláusula relativa (persona).', 'The engineer ___ wrote this code left the company.', 'who', ARRAY['who','which','where','whose']),
    ('fase-16-clausulas-relativas', 'Completá la cláusula relativa (cosa).', 'The server ___ crashed is back online.', 'that', ARRAY['that','who','where','whom']),

    ('fase-17-preposiciones-tiempo', 'Completá con la preposición de tiempo correcta (hora).', 'The standup is ___ 9am.', 'at', ARRAY['at','on','in','since']),
    ('fase-17-preposiciones-tiempo', 'Completá con la preposición de tiempo correcta (mes).', 'We released the update ___ July.', 'in', ARRAY['in','on','at','since']),

    ('fase-17-preposiciones-lugar', 'Elegí la preposición de lugar correcta.', 'The server rack is ___ the data center.', 'in', ARRAY['in','on','at','between']),
    ('fase-17-preposiciones-lugar', 'Elegí la preposición de lugar correcta.', 'The monitor is ___ the desk.', 'on', ARRAY['on','in','at','behind']),

    ('fase-17-preposiciones-direccion', 'Completá con la preposición de dirección correcta.', 'How do I get ___ the main office?', 'to', ARRAY['to','into','through','at']),
    ('fase-17-preposiciones-direccion', 'Completá con la preposición de dirección correcta (entrar en).', 'He walked ___ the server room.', 'into', ARRAY['into','to','through','at']),

    ('fase-14-this-that', 'Completá con this/that/these/those (singular, cerca).', '___ commit fixed the issue.', 'This', ARRAY['This','That','These','Those']),
    ('fase-14-this-that', 'Completá con this/that/these/those (plural, lejos).', '___ bugs from last sprint are still open.', 'Those', ARRAY['Those','These','That','This']),

    ('fase-14-every-all', 'Completá con every/all (singular).', '___ commit needs a review.', 'Every', ARRAY['Every','All','Both','Each of']),
    ('fase-14-every-all', 'Completá con every/all (plural).', '___ developers attended the standup.', 'All', ARRAY['All','Every','Each','Both']),

    ('fase-14-both-either-neither', 'Completá con both/either/neither (los dos).', '___ tests failed.', 'Both', ARRAY['Both','Either','Neither','All']),
    ('fase-14-both-either-neither', 'Completá con both/either/neither (ninguno de los dos).', '___ solution fixes the root cause.', 'Neither', ARRAY['Neither','Either','Both','Every']),

    ('fase-14-much-many', 'Completá con much/many (incontable).', 'We don''t have ___ information yet.', 'much', ARRAY['much','many','a lot','few']),
    ('fase-14-much-many', 'Completá con much/many (contable).', 'How ___ bugs are left?', 'many', ARRAY['many','much','a little','few']),

    ('fase-14-little-few', 'Completá con a little/a few (incontable).', 'I have ___ experience with Kubernetes.', 'a little', ARRAY['a little','a few','much','many']),
    ('fase-14-little-few', 'Completá con a little/a few (contable).', 'There are ___ tickets left in the sprint.', 'a few', ARRAY['a few','a little','much','little']),

    ('fase-15-orden-adjetivos', 'Elegí el orden correcto de adjetivos.', 'It''s a ___ tool.', 'great new', ARRAY['great new','new great','tool great new','great tool new']),
    ('fase-15-orden-adjetivos', 'Elegí el orden correcto de adjetivos.', 'She bought a ___ laptop.', 'small blue', ARRAY['small blue','blue small','laptop small blue','small laptop blue']),

    ('fase-15-comparativos', 'Completá el comparativo (adjetivo corto).', 'The new API is ___ (fast) than the old one.', 'faster', ARRAY['faster','more fast','fastest','most fast']),
    ('fase-15-comparativos', 'Completá el comparativo (adjetivo largo).', 'This approach is ___ (efficient) than before.', 'more efficient', ARRAY['more efficient','efficienter','most efficient','more efficienter']),

    ('fase-15-superlativos', 'Completá el superlativo (adjetivo corto).', 'This is the ___ (big) bug we''ve found this year.', 'biggest', ARRAY['biggest','more big','most big','bigger']),
    ('fase-15-superlativos', 'Completá el superlativo (adjetivo largo).', 'It''s the ___ (complex) system I''ve worked on.', 'most complex', ARRAY['most complex','complexest','more complex','most complexer']),

    ('fase-15-adverbios-modo', 'Completá con el adverbio de modo correcto.', 'She debugged the issue ___ (quick).', 'quickly', ARRAY['quickly','quick','quickness','more quick']),
    ('fase-15-adverbios-modo', 'Completá con el adverbio de modo correcto.', 'Please handle this data ___ (careful).', 'carefully', ARRAY['carefully','careful','care','more careful']),

    ('fase-15-adverbios-frecuencia', 'Elegí dónde va el adverbio de frecuencia (antes del verbo principal).', 'I ___ deploy on Fridays.', 'rarely', ARRAY['rarely','deploy rarely','am rarely','rarely am']),
    ('fase-15-adverbios-frecuencia', 'Elegí dónde va el adverbio de frecuencia (después de ''to be'').', 'She is ___ late for meetings.', 'never', ARRAY['never','never is','is never','late never']),

    ('fase-12-reflexivos', 'Completá con el reflexivo correcto.', 'She wrote the whole report ___.', 'herself', ARRAY['herself','himself','itself','myself']),
    ('fase-12-reflexivos', 'Completá con el reflexivo correcto.', 'The server restarts ___ every night.', 'itself', ARRAY['itself','himself','herself','themselves']),

    ('fase-12-whose-mine-yours', 'Completá la pregunta con ''whose''.', '___ commit broke the build?', 'Whose', ARRAY['Whose','Who''s','Who','Which']),
    ('fase-12-whose-mine-yours', 'Completá con el pronombre posesivo correcto.', 'This desk is mine, that one is ___.', 'yours', ARRAY['yours','your','you','yourself']),

    ('fase-12-posesivo-s', 'Completá con el posesivo correcto.', 'Have you seen the ___ (team) new dashboard?', 'team''s', ARRAY['team''s','teams','teams''','team']),
    ('fase-12-posesivo-s', 'Completá con el posesivo correcto (sustantivo plural en -s).', 'It''s the ___ (users) main complaint.', 'users''', ARRAY['users''','user''s','users','user'])
) AS x(subtema_slug, consigna_es, contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
