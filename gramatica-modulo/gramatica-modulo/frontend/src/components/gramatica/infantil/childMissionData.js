export const CHILD_MISSIONS = {
  'fase-1-abecedario': {
    slug: 'fase-1-abecedario', icono: '🔤', zona: 'COMUNICACIÓN CLARA', titulo: 'Deletrea y hazte entender',
    bajada: 'Reconoce las letras en inglés y deletrea nombres o palabras importantes.', color: '#b15f3b', suave: '#fff0e7', valor: 'Paciencia y comunicación respetuosa',
    historia: [
      { emoji: '🏫', texto: 'A new student joins the class.' },
      { emoji: '👋', texto: 'Hello! My name is Daniel.' },
      { emoji: '❓', texto: 'How do you spell your name?' },
      { emoji: '🔤', texto: 'D-A-N-I-E-L.' },
      { emoji: '😊', texto: 'Thank you. Now I can write it correctly.' },
    ],
    palabras: [
      { en: 'spell', es: 'deletrear', emoji: '🔤' }, { en: 'name', es: 'nombre', emoji: '🏷️' },
      { en: 'letter', es: 'letra', emoji: '✏️' }, { en: 'word', es: 'palabra', emoji: '💬' },
      { en: 'repeat', es: 'repetir', emoji: '🔁' }, { en: 'correctly', es: 'correctamente', emoji: '✅' },
    ],
    constructor: {
      inicios: ['Can you', 'Could you', 'Will you', 'Would you'],
      acciones: ['spell', 'repeat', 'say', 'write'],
      finales: ['your name?', 'that word?', 'the last letter?', 'my name.'],
    },
    retos: [
      { frase: 'How do you ___ your name?', correcta: 'spell', opciones: ['spell', 'count', 'draw'], ayuda: 'Spell significa deletrear.' },
      { frase: 'The word “book” begins with ___.', correcta: 'B', opciones: ['D', 'B', 'P'], ayuda: 'Book empieza con la letra B.' },
      { frase: 'Which letter comes after M?', correcta: 'N', opciones: ['L', 'O', 'N'], ayuda: 'En el alfabeto, N aparece después de M.' },
      { frase: 'D-A-N-I-E-L spells ___.', correcta: 'Daniel', opciones: ['David', 'Daniel', 'Diana'], ayuda: 'Une las letras en el mismo orden.' },
    ],
    aplicaciones: [
      { emoji: '🏫', titulo: 'En clase', texto: 'Deletrear tu nombre en una presentación.' },
      { emoji: '📚', titulo: 'Al estudiar', texto: 'Confirmar cómo se escribe una palabra nueva.' },
      { emoji: '📞', titulo: 'En una llamada', texto: 'Aclarar nombres o datos sin confusiones.' },
    ],
  },
  'fase-1-numeros': {
    slug: 'fase-1-numeros', icono: '🔢', zona: 'NÚMEROS EN ACCIÓN', titulo: 'Cuenta, ordena y compara',
    bajada: 'Usa números cardinales para cantidades y ordinales para posiciones.', color: '#39766a', suave: '#e8f7f2', valor: 'Orden, esfuerzo y juego limpio',
    historia: [
      { emoji: '🏃', texto: 'Today our class has a friendly race.' },
      { emoji: '1️⃣', texto: 'Sofia finishes first.' },
      { emoji: '2️⃣', texto: 'Mateo finishes second.' },
      { emoji: '3️⃣', texto: 'Emma finishes third.' },
      { emoji: '👏', texto: 'There are twelve students, and everyone celebrates the effort.' },
    ],
    palabras: [
      { en: 'one', es: 'uno', emoji: '1️⃣' }, { en: 'twelve', es: 'doce', emoji: '🔢' },
      { en: 'first', es: 'primero', emoji: '🥇' }, { en: 'second', es: 'segundo', emoji: '🥈' },
      { en: 'third', es: 'tercero', emoji: '🥉' }, { en: 'how many', es: 'cuántos', emoji: '❓' },
    ],
    constructor: {
      inicios: ['In my class, there are', 'In the library, there are', 'At home, there are', 'In the park, there are'],
      acciones: ['twelve', 'fifteen', 'eighteen', 'twenty'],
      finales: ['books.', 'chairs.', 'plants.', 'people.'],
    },
    retos: [
      { frase: 'The number 12 is ___.', correcta: 'twelve', opciones: ['twenty', 'twelve', 'second'], ayuda: 'Twelve es doce; twenty es veinte.' },
      { frase: 'Position 1 is ___.', correcta: 'first', opciones: ['one', 'first', 'third'], ayuda: 'First indica la primera posición.' },
      { frase: 'Position 3 is ___.', correcta: 'third', opciones: ['three', 'second', 'third'], ayuda: 'Third indica la tercera posición.' },
      { frase: 'There are ___ days in a week.', correcta: 'seven', opciones: ['six', 'seven', 'eleven'], ayuda: 'Una semana tiene seven days.' },
    ],
    aplicaciones: [
      { emoji: '📚', titulo: 'En la escuela', texto: 'Contar materiales y señalar posiciones.' },
      { emoji: '🏪', titulo: 'Al comprar', texto: 'Pedir cantidades y entender precios.' },
      { emoji: '🏅', titulo: 'En actividades', texto: 'Explicar resultados y turnos con respeto.' },
    ],
  },
  'fase-1-fecha': {
    slug: 'fase-1-fecha', icono: '📅', zona: 'ORGANIZA TU SEMANA', titulo: 'Fechas que importan',
    bajada: 'Expresa días, meses y fechas para organizar actividades importantes.', color: '#356f92', suave: '#e8f4fa', valor: 'Organización y responsabilidad',
    historia: [
      { emoji: '📋', texto: 'Our class is planning a science fair.' },
      { emoji: '📅', texto: 'The fair is on Friday, May tenth.' },
      { emoji: '🧪', texto: 'We prepare our project in April.' },
      { emoji: '⏰', texto: 'The final practice is at three o’clock.' },
      { emoji: '✅', texto: 'We write every date on the class calendar.' },
    ],
    palabras: [
      { en: 'today', es: 'hoy', emoji: '☀️' }, { en: 'tomorrow', es: 'mañana', emoji: '➡️' },
      { en: 'Monday', es: 'lunes', emoji: '📘' }, { en: 'Friday', es: 'viernes', emoji: '🎒' },
      { en: 'month', es: 'mes', emoji: '🗓️' }, { en: 'date', es: 'fecha', emoji: '📌' },
    ],
    constructor: {
      inicios: ['The activity is', 'The exam is', 'The game is', 'My birthday is'],
      acciones: ['on Monday,', 'on Friday,', 'on May tenth,', 'on June third,'],
      finales: ['this week.', 'next week.', 'this year.', 'as planned.'],
    },
    retos: [
      { frase: 'The class is ___ Monday.', correcta: 'on', opciones: ['at', 'on', 'in'], ayuda: 'Usamos on antes de un día específico.' },
      { frase: 'My birthday is ___ July.', correcta: 'in', opciones: ['on', 'at', 'in'], ayuda: 'Usamos in con meses.' },
      { frase: 'The day after Monday is ___.', correcta: 'Tuesday', opciones: ['Sunday', 'Tuesday', 'Friday'], ayuda: 'Tuesday es martes.' },
      { frase: 'December is a ___.', correcta: 'month', opciones: ['day', 'month', 'hour'], ayuda: 'December es un mes.' },
    ],
    aplicaciones: [
      { emoji: '📝', titulo: 'En la escuela', texto: 'Anotar exámenes, entregas y eventos.' },
      { emoji: '🎂', titulo: 'En familia', texto: 'Recordar cumpleaños y celebraciones.' },
      { emoji: '📅', titulo: 'Al organizarte', texto: 'Confirmar el día de una actividad.' },
    ],
  },
  'fase-1-hora': {
    slug: 'fase-1-hora', icono: '🕒', zona: 'TU DÍA A TIEMPO', titulo: '¿Qué hora es?',
    bajada: 'Pregunta y expresa la hora para seguir horarios y organizar tu día.', color: '#735b9b', suave: '#f2edfb', valor: 'Puntualidad y responsabilidad',
    historia: [
      { emoji: '⏰', texto: 'It is seven o’clock in the morning.' },
      { emoji: '🏫', texto: 'School starts at eight o’clock.' },
      { emoji: '🥪', texto: 'Lunch is at half past twelve.' },
      { emoji: '⚽', texto: 'Soccer practice is at a quarter past four.' },
      { emoji: '🌙', texto: 'I prepare my backpack before nine o’clock.' },
    ],
    palabras: [
      { en: 'o’clock', es: 'en punto', emoji: '🕐' }, { en: 'half past', es: 'y media', emoji: '🕧' },
      { en: 'quarter past', es: 'y cuarto', emoji: '🕒' }, { en: 'quarter to', es: 'menos cuarto', emoji: '🕘' },
      { en: 'morning', es: 'mañana', emoji: '🌅' }, { en: 'night', es: 'noche', emoji: '🌙' },
    ],
    constructor: {
      inicios: ['My class starts', 'Lunch begins', 'Practice starts', 'My day begins'],
      acciones: ['at seven', 'at eight', 'at half past twelve', 'at a quarter past four'],
      finales: ['in the morning.', 'every day.', 'on time.', 'as planned.'],
    },
    retos: [
      { frase: '7:00 is seven ___.', correcta: 'o’clock', opciones: ['past', 'o’clock', 'half'], ayuda: 'Para una hora exacta usamos o’clock.' },
      { frase: '3:30 is half ___ three.', correcta: 'past', opciones: ['to', 'past', 'at'], ayuda: 'Half past indica treinta minutos después.' },
      { frase: 'School starts ___ eight.', correcta: 'at', opciones: ['on', 'in', 'at'], ayuda: 'Usamos at antes de una hora.' },
      { frase: '8:45 is a quarter ___ nine.', correcta: 'to', opciones: ['past', 'to', 'on'], ayuda: 'Faltan quince minutos para las nueve.' },
    ],
    aplicaciones: [
      { emoji: '🏫', titulo: 'En la escuela', texto: 'Entender horarios de clases y descansos.' },
      { emoji: '⚽', titulo: 'En actividades', texto: 'Llegar puntualmente a prácticas o reuniones.' },
      { emoji: '🏠', titulo: 'En casa', texto: 'Organizar tareas, comidas y descanso.' },
    ],
  },
  'fase-1-saludos': {
    slug: 'fase-1-saludos', icono: '👋', zona: 'BUENAS CONVERSACIONES', titulo: 'Saluda con confianza',
    bajada: 'Elige un saludo o una despedida según el momento y la situación.', color: '#b06b33', suave: '#fff3e4', valor: 'Amabilidad y respeto',
    historia: [
      { emoji: '🌅', texto: 'Good morning, Ms. Green.' },
      { emoji: '👩‍🏫', texto: 'Good morning, Lucas. How are you?' },
      { emoji: '😊', texto: 'I am fine, thank you.' },
      { emoji: '👋', texto: 'Hi, Emma! Are you ready for class?' },
      { emoji: '🎒', texto: 'Yes! See you in the classroom.' },
    ],
    palabras: [
      { en: 'hello', es: 'hola', emoji: '👋' }, { en: 'good morning', es: 'buenos días', emoji: '🌅' },
      { en: 'how are you?', es: '¿cómo estás?', emoji: '🙂' }, { en: 'thank you', es: 'gracias', emoji: '🙏' },
      { en: 'see you', es: 'nos vemos', emoji: '➡️' }, { en: 'goodbye', es: 'adiós', emoji: '🎒' },
    ],
    constructor: {
      inicios: ['Good morning,', 'Hello,', 'Hi,', 'Good afternoon,'],
      acciones: ['Emma.', 'Lucas.', 'everyone.', 'my friend.'],
      finales: ['How are you?', 'Nice to see you.', 'Have a good day.', 'Are you ready?'],
    },
    retos: [
      { frase: 'At 8:00 a.m. we say ___.', correcta: 'Good morning', opciones: ['Good night', 'Good morning', 'Goodbye'], ayuda: 'Good morning se usa durante la mañana.' },
      { frase: 'A neutral way to say hola is ___.', correcta: 'Hello', opciones: ['Goodbye', 'Hello', 'See you'], ayuda: 'Hello funciona en muchas situaciones.' },
      { frase: 'To ask ¿cómo estás? say ___.', correcta: 'How are you?', opciones: ['Who are you?', 'How are you?', 'Where are you?'], ayuda: 'How are you? pregunta cómo está alguien.' },
      { frase: 'A friendly farewell is ___.', correcta: 'See you', opciones: ['Thank you', 'Good morning', 'See you'], ayuda: 'See you significa nos vemos.' },
    ],
    aplicaciones: [
      { emoji: '🏫', titulo: 'En la escuela', texto: 'Saludar a docentes y compañeros con respeto.' },
      { emoji: '🏠', titulo: 'En familia', texto: 'Iniciar y cerrar conversaciones amables.' },
      { emoji: '🤝', titulo: 'Al conocer a alguien', texto: 'Dar una primera impresión cordial.' },
    ],
  },
  'fase-1-abreviaturas': {
    slug: 'fase-1-abreviaturas', icono: '💬', zona: 'PALABRAS COTIDIANAS', titulo: 'Mensajes cortos y claros',
    bajada: 'Reconoce abreviaturas comunes sin perder claridad ni respeto al escribir.', color: '#39766a', suave: '#e8f7f2', valor: 'Claridad y uso responsable de mensajes',
    historia: [
      { emoji: '🔬', texto: 'Our science group needs information for a project.' },
      { emoji: '📱', texto: 'Sara writes: “FYI, the project is due on Friday.”' },
      { emoji: '📷', texto: 'Leo adds a photo from the science book.' },
      { emoji: 'ℹ️', texto: 'The school app has more info.' },
      { emoji: '✅', texto: 'Everyone understands the short and clear message.' },
    ],
    palabras: [
      { en: 'info', es: 'información', emoji: 'ℹ️' }, { en: 'app', es: 'aplicación', emoji: '📱' },
      { en: 'photo', es: 'fotografía', emoji: '📷' }, { en: 'TV', es: 'televisión', emoji: '📺' },
      { en: 'FYI', es: 'para tu información', emoji: '💡' }, { en: 'ASAP', es: 'lo antes posible', emoji: '⏱️' },
    ],
    constructor: {
      inicios: ['Please send', 'Please share', 'Please check', 'Please review'],
      acciones: ['the info', 'the photo', 'the app', 'the message'],
      finales: ['for our project.', 'with the group.', 'before class.', 'when you have time.'],
    },
    retos: [
      { frase: 'The short form of information is ___.', correcta: 'info', opciones: ['info', 'photo', 'TV'], ayuda: 'Info es una forma cotidiana de information.' },
      { frase: 'The short form of application is ___.', correcta: 'app', opciones: ['ASAP', 'app', 'FYI'], ayuda: 'App es la forma corta de application.' },
      { frase: '___ means “para tu información”.', correcta: 'FYI', opciones: ['TV', 'ASAP', 'FYI'], ayuda: 'FYI significa for your information.' },
      { frase: 'A picture taken with a camera is a ___.', correcta: 'photo', opciones: ['photo', 'fridge', 'app'], ayuda: 'Photo es la forma cotidiana de photograph.' },
    ],
    aplicaciones: [
      { emoji: '📚', titulo: 'En proyectos', texto: 'Compartir información de forma breve y clara.' },
      { emoji: '📱', titulo: 'En aplicaciones', texto: 'Comprender botones y mensajes frecuentes.' },
      { emoji: '💬', titulo: 'En mensajes', texto: 'Usar formas cortas sin escribir con descuido.' },
    ],
  },
  'fase-1-familia-coloquial': {
    slug: 'fase-1-familia-coloquial', icono: '🏡', zona: 'FAMILIA Y VIDA COTIDIANA', titulo: 'Mi familia y mi hogar',
    bajada: 'Aprende a presentar a tu familia y contar cómo colaboran en casa.', color: '#3478e5', suave: '#e8f2ff', valor: 'Amor, respeto y colaboración',
    historia: [
      { emoji: '👧', texto: 'My name is Mia. I live with my mom, my dad, and my brother Leo.' },
      { emoji: '📚', texto: 'My mom helps me with my homework.' },
      { emoji: '🥞', texto: 'My dad makes breakfast on Sunday.' },
      { emoji: '🧹', texto: 'Leo and I clean our room together.' },
      { emoji: '❤️', texto: 'We love, respect, and help each other.' },
    ],
    palabras: [
      { en: 'mom', es: 'mamá', emoji: '👩' }, { en: 'dad', es: 'papá', emoji: '👨' },
      { en: 'brother', es: 'hermano', emoji: '👦' }, { en: 'sister', es: 'hermana', emoji: '👧' },
      { en: 'grandparents', es: 'abuelos', emoji: '👵👴' }, { en: 'family', es: 'familia', emoji: '🏡' },
    ],
    constructor: {
      inicios: ['My brother and I', 'My parents and I', 'My family and I', 'We'],
      acciones: ['help', 'respect', 'love', 'listen to'],
      finales: ['one another.', 'our parents.', 'our grandparents.', 'our family.'],
    },
    retos: [
      { frase: 'My mother is my ___.', correcta: 'mom', opciones: ['mom', 'sister', 'grandma'], ayuda: 'Mom significa mamá.' },
      { frase: 'My father is my ___.', correcta: 'dad', opciones: ['brother', 'dad', 'grandpa'], ayuda: 'Dad significa papá.' },
      { frase: 'My brother and I ___ our room.', correcta: 'clean', opciones: ['cleans', 'clean', 'cleaning'], ayuda: 'Con “My brother and I” usamos clean.' },
      { frase: 'We help ___ other at home.', correcta: 'each', opciones: ['each', 'every', 'one'], ayuda: 'Each other significa mutuamente.' },
    ],
    aplicaciones: [
      { emoji: '🏫', titulo: 'En la escuela', texto: 'Presentar a tu familia en clase.' },
      { emoji: '🏠', titulo: 'En casa', texto: 'Contar cómo colaboran y se respetan.' },
      { emoji: '💬', titulo: 'En conversación', texto: 'Hablar de padres, hermanos y abuelos.' },
    ],
  },
  'fase-7-will-shall': {
    slug: 'fase-7-will-shall', icono: '🚀', zona: 'PLANES Y RESPONSABILIDAD', titulo: 'Mis planes para mañana',
    bajada: 'Usa will para expresar decisiones, promesas y acciones futuras.', color: '#735b9b', suave: '#f2edfb', valor: 'Responsabilidad y cumplimiento',
    historia: [
      { emoji: '🌅', texto: 'Tomorrow will be a busy day for Alex.' },
      { emoji: '📝', texto: 'I will do my homework after school.' },
      { emoji: '🌱', texto: 'Then I will help my dad water the plants.' },
      { emoji: '📞', texto: 'I will call my grandparents in the evening.' },
      { emoji: '⭐', texto: 'I will keep my promises and do my best.' },
    ],
    palabras: [
      { en: 'tomorrow', es: 'mañana', emoji: '🌅' }, { en: 'homework', es: 'tarea', emoji: '📝' },
      { en: 'promise', es: 'promesa', emoji: '🤝' }, { en: 'help', es: 'ayudar', emoji: '🙌' },
      { en: 'later', es: 'más tarde', emoji: '🕒' }, { en: 'will', es: 'acción futura', emoji: '➡️' },
    ],
    constructor: {
      inicios: ['Tomorrow, I', 'After school, I', 'This weekend, I', 'Later, I'],
      acciones: ['will start', 'will finish', 'will organize', 'will review'],
      finales: ['my homework.', 'my chores.', 'my plan.', 'my project.'],
    },
    retos: [
      { frase: 'Tomorrow I ___ do my homework.', correcta: 'will', opciones: ['will', 'am', 'did'], ayuda: 'Will + verbo expresa una acción futura.' },
      { frase: 'She will ___ her mom after school.', correcta: 'help', opciones: ['helps', 'help', 'helped'], ayuda: 'Después de will usamos el verbo sin cambios.' },
      { frase: 'We ___ visit our grandparents on Sunday.', correcta: 'will', opciones: ['are', 'will', 'were'], ayuda: 'Will presenta el plan futuro.' },
      { frase: 'I will keep my ___.', correcta: 'promise', opciones: ['promise', 'promised', 'promising'], ayuda: 'Keep my promise significa cumplir mi promesa.' },
    ],
    aplicaciones: [
      { emoji: '📚', titulo: 'Tareas', texto: 'Explicar qué harás después de clases.' },
      { emoji: '📅', titulo: 'Planes', texto: 'Organizar actividades para mañana.' },
      { emoji: '🤝', titulo: 'Compromisos', texto: 'Expresar una promesa y cumplirla.' },
    ],
  },
  'fase-16-condicionales-if': {
    slug: 'fase-16-condicionales-if', icono: '🌎', zona: 'GUARDIANES DE LA NATURALEZA', titulo: 'Si cuidamos, protegemos',
    bajada: 'Conecta una acción responsable con su resultado usando if.', color: '#31865b', suave: '#e5f8ed', valor: 'Respeto y cuidado del medio ambiente',
    historia: [
      { emoji: '🏫', texto: 'Our class has a plan to care for the environment.' },
      { emoji: '💧', texto: 'If we turn off the tap, we save water.' },
      { emoji: '📄', texto: 'If we reuse paper, we protect trees.' },
      { emoji: '🗑️', texto: 'If we pick up litter, our park stays clean.' },
      { emoji: '🌳', texto: 'Small actions can make a big difference.' },
    ],
    palabras: [
      { en: 'save water', es: 'ahorrar agua', emoji: '💧' }, { en: 'reuse', es: 'reutilizar', emoji: '♻️' },
      { en: 'protect', es: 'proteger', emoji: '🛡️' }, { en: 'trees', es: 'árboles', emoji: '🌳' },
      { en: 'clean', es: 'limpio', emoji: '✨' }, { en: 'environment', es: 'medio ambiente', emoji: '🌎' },
    ],
    constructor: {
      inicios: ['If we save water,', 'If we reuse paper,', 'If we care for animals,', 'If we pick up litter,'],
      acciones: ['we help protect', 'we take care of', 'we support', 'we make a difference for'],
      finales: ['our planet.', 'nature.', 'our community.', 'the world around us.'],
    },
    retos: [
      { frase: 'If we reuse paper, we ___ trees.', correcta: 'protect', opciones: ['protect', 'waste', 'cut'], ayuda: 'Reutilizar papel ayuda a proteger árboles.' },
      { frase: 'If you turn off the tap, you ___ water.', correcta: 'save', opciones: ['drop', 'save', 'lose'], ayuda: 'Save water significa ahorrar agua.' },
      { frase: 'If we ___ litter, the park stays clean.', correcta: 'pick up', opciones: ['leave', 'drop', 'pick up'], ayuda: 'Pick up litter significa recoger basura.' },
      { frase: 'If we care for nature, we ___ our home.', correcta: 'protect', opciones: ['protect', 'forget', 'waste'], ayuda: 'El planeta es nuestro hogar compartido.' },
    ],
    aplicaciones: [
      { emoji: '🏫', titulo: 'En la escuela', texto: 'Proponer acciones para un salón limpio.' },
      { emoji: '🏠', titulo: 'En casa', texto: 'Explicar cómo ahorrar agua y reutilizar.' },
      { emoji: '🌳', titulo: 'En comunidad', texto: 'Invitar a otros a cuidar parques y árboles.' },
    ],
  },
};

export const CHILD_MISSION_SLUGS = new Set(Object.keys(CHILD_MISSIONS));
