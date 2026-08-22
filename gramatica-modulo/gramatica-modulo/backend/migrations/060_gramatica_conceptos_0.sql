-- "Camino 0" del Gusanito (ver memoria del proyecto): vocabulario básico
-- sin estructura gramatical -- saludos, despedidas, familia coloquial,
-- abreviaturas de uso diario y frutas. Pedido explícito del dueño: un
-- alumno tiene que poder jugar el Gusanito desde el primer día sin
-- necesitar ninguna regla de gramática todavía, algo que ningún subtema
-- de Fase 2 en adelante puede ofrecer (todos dependen de estructura de
-- oración). Vive dentro de "Fase 1: Fundamentos" (mismo criterio que
-- abecedario/números/hora/fecha, que tampoco requieren gramática) en vez
-- de en el módulo `vocabulario`: ese módulo modela vocabulario con forma
-- verbal obligatoria (`vocabulario_formas.tiempo_verbal`/`acto_comunicativo`
-- son NOT NULL), pensado para verbos técnicos conjugados -- no encaja con
-- palabras sueltas invariables como estas. El patrón real que sí encaja
-- 1:1 es el de fichas tocables (tipo='referencia', variante NULL) ya
-- usado y probado en abecedario/números (migraciones 033-035).
--
-- Cada subtema: 1 regla (matiz de uso/registro) + 2 ejemplo (frase real)
-- + fichas de referencia (palabra suelta, audio individual pendiente de
-- generar con scripts/generar_audio_gramatica.py, igual que el resto del
-- módulo -- esta migración no genera audio, solo siembra contenido).

INSERT INTO gramatica_temas (nombre, slug, parent_id, orden)
SELECT x.nombre, x.slug, f.id, x.orden
FROM (VALUES
    ('Saludos', 'fase-1-saludos', 7),
    ('Despedidas', 'fase-1-despedidas', 8),
    ('Familia (coloquial)', 'fase-1-familia-coloquial', 9),
    ('Abreviaturas comunes', 'fase-1-abreviaturas', 10),
    ('Frutas', 'fase-1-frutas', 11)
) AS x(nombre, slug, orden)
JOIN gramatica_temas f ON f.slug = 'fase-1-fundamentos' AND f.parent_id IS NULL;

-- ─── Reglas + ejemplos (regla de uso/registro, no de estructura) ───

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, x.tipo, x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('fase-1-saludos', 'regla', 'El saludo cambia según el momento del día y qué tan formal es la situación. ''Hi''/''Hey'' son informales (amigos, compañeros); ''Good morning/afternoon/evening'' son más formales o para desconocidos.', 'Good morning, everyone!', 1),
    ('fase-1-saludos', 'ejemplo', 'Saludar a un compañero de trabajo por la mañana', 'Good morning! How are you?', 2),
    ('fase-1-saludos', 'ejemplo', 'Saludar informalmente a un amigo', 'Hey! What''s up?', 3),

    ('fase-1-despedidas', 'regla', 'Para despedirte, ''Bye''/''See you later'' son informales y de uso diario; ''Take care''/''Have a good one'' agregan calidez; ''Goodbye'' es más formal o definitivo.', 'Bye! See you tomorrow.', 1),
    ('fase-1-despedidas', 'ejemplo', 'Despedirte de un compañero al salir de la oficina', 'Bye! See you tomorrow.', 2),
    ('fase-1-despedidas', 'ejemplo', 'Despedida cálida e informal', 'Take care! Talk to you later.', 3),

    ('fase-1-familia-coloquial', 'regla', 'En inglés cotidiano, los términos de familia tienen versiones cariñosas/informales muy usadas en vez de la forma completa: ''mom''/''dad'' en vez de ''mother''/''father'', ''bro''/''sis'' entre hermanos.', 'This is my mom, and that''s my bro.', 1),
    ('fase-1-familia-coloquial', 'ejemplo', 'Presentar a un familiar informalmente', 'This is my mom, and that''s my bro.', 2),
    ('fase-1-familia-coloquial', 'ejemplo', 'Hablar de los abuelos', 'My grandma and grandpa live near the beach.', 3),

    ('fase-1-abreviaturas', 'regla', 'El inglés cotidiano usa muchas abreviaturas y siglas que no siempre se enseñan formalmente -- conocerlas evita confusiones comunes al leer mensajes o carteles.', 'Can you call me a cab?', 1),
    ('fase-1-abreviaturas', 'ejemplo', 'Pedir un taxi', 'Can you call me a cab?', 2),
    ('fase-1-abreviaturas', 'ejemplo', 'Pedir algo urgente', 'I need this ASAP, please.', 3),

    ('fase-1-frutas', 'regla', 'Vocabulario básico de frutas -- útil para pedir comida, hacer compras o simplemente describir qué estás comiendo.', 'My favorite fruit is watermelon.', 1),
    ('fase-1-frutas', 'ejemplo', 'Pedir fruta en un café', 'Can I get an apple and a banana, please?', 2),
    ('fase-1-frutas', 'ejemplo', 'Describir tu fruta favorita', 'My favorite fruit is watermelon.', 3)
) AS x(subtema_slug, tipo, texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;

-- ─── Fichas de referencia (palabra suelta, tocar = escuchar) ───

INSERT INTO gramatica_contenido (tema_id, tipo, texto_es, texto_en, nivel_cefr, orden)
SELECT t.id, 'referencia', x.texto_es, x.texto_en, 'A1', x.orden
FROM (VALUES
    ('fase-1-saludos', 'Hola (neutro)', 'Hello', 4),
    ('fase-1-saludos', 'Hola (informal)', 'Hi', 5),
    ('fase-1-saludos', 'Hola (muy informal)', 'Hey', 6),
    ('fase-1-saludos', 'Buenos días', 'Good morning', 7),
    ('fase-1-saludos', 'Buenas tardes', 'Good afternoon', 8),
    ('fase-1-saludos', 'Buenas noches (al saludar)', 'Good evening', 9),
    ('fase-1-saludos', '¿Cómo estás?', 'How are you?', 10),
    ('fase-1-saludos', '¿Qué onda?', 'What''s up?', 11),

    ('fase-1-despedidas', 'Adiós', 'Goodbye', 4),
    ('fase-1-despedidas', 'Chau', 'Bye', 5),
    ('fase-1-despedidas', 'Nos vemos luego', 'See you later', 6),
    ('fase-1-despedidas', 'Nos vemos pronto', 'See you soon', 7),
    ('fase-1-despedidas', 'Cuidate', 'Take care', 8),
    ('fase-1-despedidas', 'Que la pases bien', 'Have a good one', 9),
    ('fase-1-despedidas', 'Buenas noches (al despedirse)', 'Good night', 10),
    ('fase-1-despedidas', 'Hablamos luego', 'Talk to you later', 11),

    ('fase-1-familia-coloquial', 'Mamá', 'Mom', 4),
    ('fase-1-familia-coloquial', 'Papá', 'Dad', 5),
    ('fase-1-familia-coloquial', 'Abuela', 'Grandma', 6),
    ('fase-1-familia-coloquial', 'Abuelo', 'Grandpa', 7),
    ('fase-1-familia-coloquial', 'Hermano (informal)', 'Bro', 8),
    ('fase-1-familia-coloquial', 'Hermana (informal)', 'Sis', 9),
    ('fase-1-familia-coloquial', 'Tía (cariñoso)', 'Auntie', 10),
    ('fase-1-familia-coloquial', 'Tío', 'Uncle', 11),
    ('fase-1-familia-coloquial', 'Primo/Prima', 'Cousin', 12),
    ('fase-1-familia-coloquial', 'Nietos', 'Grandkids', 13),

    ('fase-1-abreviaturas', 'Taxi', 'Cab', 4),
    ('fase-1-abreviaturas', 'Heladera/refrigerador', 'Fridge', 5),
    ('fase-1-abreviaturas', 'Lo antes posible', 'ASAP', 6),
    ('fase-1-abreviaturas', 'Para tu información', 'FYI', 7),
    ('fase-1-abreviaturas', 'Cajero automático', 'ATM', 8),
    ('fase-1-abreviaturas', 'Gimnasio', 'Gym', 9),
    ('fase-1-abreviaturas', 'Información', 'Info', 10),
    ('fase-1-abreviaturas', 'Aplicación', 'App', 11),
    ('fase-1-abreviaturas', 'Televisión', 'TV', 12),
    ('fase-1-abreviaturas', 'Foto', 'Photo', 13),

    ('fase-1-frutas', 'Manzana', 'Apple', 4),
    ('fase-1-frutas', 'Banana', 'Banana', 5),
    ('fase-1-frutas', 'Naranja', 'Orange', 6),
    ('fase-1-frutas', 'Frutilla', 'Strawberry', 7),
    ('fase-1-frutas', 'Uva', 'Grape', 8),
    ('fase-1-frutas', 'Sandía', 'Watermelon', 9),
    ('fase-1-frutas', 'Ananá', 'Pineapple', 10),
    ('fase-1-frutas', 'Durazno', 'Peach', 11),
    ('fase-1-frutas', 'Pera', 'Pear', 12),
    ('fase-1-frutas', 'Cereza', 'Cherry', 13)
) AS x(subtema_slug, texto_es, texto_en, orden)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;

-- ─── Ejercicios (2 por subtema, cloze con opciones -- mismo patrón que 032) ───

INSERT INTO ejercicios (tipo, consigna_es, contexto_en, respuesta_esperada, respuestas_alternativas, opciones, tema_gramatica_id, nivel_cefr, idioma)
SELECT 'cloze', x.consigna_es, x.contexto_en, x.respuesta_esperada, ARRAY[]::varchar[], x.opciones, t.id, 'A1', 'en'
FROM (VALUES
    ('fase-1-saludos', 'Elegí el saludo correcto para la mañana en una reunión de trabajo.', '___, everyone. Let''s start the meeting.', 'Good morning', ARRAY['Good morning','Hey','What''s up','Bye']),
    ('fase-1-saludos', 'Elegí cómo saludarías informalmente a un amigo.', '___! Long time no see.', 'Hey', ARRAY['Hey','Good evening','Goodbye','FYI']),

    ('fase-1-despedidas', 'Elegí la despedida más cálida e informal.', 'It was great seeing you. ___!', 'Take care', ARRAY['Take care','Good morning','FYI','Cab']),
    ('fase-1-despedidas', 'Elegí cómo te despedís antes de dormir.', 'I''m heading to bed. ___!', 'Good night', ARRAY['Good night','Good afternoon','See you soon','Hey']),

    ('fase-1-familia-coloquial', 'Elegí cómo le decís a tu hermano de forma informal.', 'This is my ___, he''s visiting for the weekend.', 'bro', ARRAY['bro','uncle','cousin','grandpa']),
    ('fase-1-familia-coloquial', 'Elegí la palabra para "abuela".', 'My ___ makes the best apple pie.', 'grandma', ARRAY['grandma','auntie','sis','mom']),

    ('fase-1-abreviaturas', 'Elegí qué palabra significa "taxi" en inglés cotidiano.', 'I''ll just grab a ___ to the airport.', 'cab', ARRAY['cab','gym','fridge','app']),
    ('fase-1-abreviaturas', 'Elegí qué significa pedir algo "cuanto antes".', 'Please send me the report ___.', 'ASAP', ARRAY['ASAP','FYI','ATM','TV']),

    ('fase-1-frutas', 'Elegí la palabra para "sandía".', 'In summer, I love eating ___.', 'watermelon', ARRAY['watermelon','pineapple','cherry','pear']),
    ('fase-1-frutas', 'Elegí la palabra para "uva".', 'Can you pass me a ___?', 'grape', ARRAY['grape','peach','orange','strawberry'])
) AS x(subtema_slug, consigna_es, contexto_en, respuesta_esperada, opciones)
JOIN gramatica_temas t ON t.slug = x.subtema_slug AND t.parent_id IS NOT NULL;
