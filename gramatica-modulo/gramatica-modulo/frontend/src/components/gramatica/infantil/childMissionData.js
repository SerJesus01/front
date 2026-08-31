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
