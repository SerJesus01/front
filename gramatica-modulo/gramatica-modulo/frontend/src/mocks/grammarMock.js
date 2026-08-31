const originalFetch = window.fetch.bind(window);
const NativeAudio = window.Audio;

const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

const fases = [
  { id: 1, nombre: 'Fundamentos', slug: 'fase-1-fundamentos', orden: 1, disponible: true, completado: false },
  { id: 2, nombre: 'Verbo to be y pronombres básicos', slug: 'fase-2-to-be-pronombres', orden: 2, disponible: true, completado: false },
  { id: 3, nombre: 'Presente', slug: 'fase-3-presente', orden: 3, disponible: true, completado: false },
  { id: 4, nombre: 'Pasado', slug: 'fase-4-pasado', orden: 4, disponible: true, completado: false },
  { id: 5, nombre: 'Presente perfecto', slug: 'fase-5-presente-perfecto', orden: 5, disponible: true, completado: false },
];

const subtemasPorFase = {
  'fase-1-fundamentos': [
    { id: 101, nombre: 'Abecedario y deletreo', slug: 'fase-1-abecedario', orden: 1, completado: false },
    { id: 102, nombre: 'Números', slug: 'fase-1-numeros', orden: 2, completado: false },
    { id: 103, nombre: 'Fecha', slug: 'fase-1-fecha', orden: 3, completado: false },
    { id: 104, nombre: 'Hora', slug: 'fase-1-hora', orden: 4, completado: false },
    { id: 105, nombre: 'Saludos y despedidas', slug: 'fase-1-saludos', orden: 5, completado: false },
    { id: 106, nombre: 'Familia coloquial', slug: 'fase-1-familia-coloquial', orden: 6, completado: false },
    { id: 107, nombre: 'Abreviaturas', slug: 'fase-1-abreviaturas', orden: 7, completado: false },
    { id: 108, nombre: 'Frutas', slug: 'fase-1-frutas', orden: 8, completado: false },
  ],
  'fase-2-to-be-pronombres': [
    { id: 201, nombre: 'Verbo to be (afirmativo)', slug: 'fase-2-to-be-afirmativo', orden: 1, completado: false },
    { id: 202, nombre: 'Pronombres sujeto y objeto', slug: 'fase-2-pronombres-sujeto-objeto', orden: 2, completado: false },
  ],
  'fase-3-presente': [
    { id: 301, nombre: 'Presente simple', slug: 'fase-3-presente-simple', orden: 1, completado: false },
    { id: 302, nombre: 'Presente continuo', slug: 'fase-3-presente-continuo', orden: 2, completado: false },
    { id: 303, nombre: 'Presente simple vs. presente continuo', slug: 'fase-3-simple-vs-continuo', orden: 3, completado: false },
  ],
  'fase-4-pasado': [
    { id: 401, nombre: 'was / were', slug: 'fase-4-was-were', orden: 1, completado: false },
    { id: 402, nombre: 'Pasado simple', slug: 'fase-4-pasado-simple', orden: 2, completado: false },
    { id: 403, nombre: 'Pasado continuo', slug: 'fase-4-pasado-continuo', orden: 3, completado: false },
  ],
  'fase-5-presente-perfecto': [
    { id: 501, nombre: 'Presente perfecto (introducción)', slug: 'fase-5-perfecto-intro', orden: 1, completado: false },
    { id: 502, nombre: 'just / already / yet', slug: 'fase-5-just-already-yet', orden: 2, completado: false },
    { id: 503, nombre: 'ever / how long', slug: 'fase-5-ever-how-long', orden: 3, completado: false },
    { id: 504, nombre: 'for / since / ago', slug: 'fase-5-for-since-ago', orden: 4, completado: false },
    { id: 505, nombre: 'Presente perfecto vs. pasado simple', slug: 'fase-5-perfecto-vs-pasado', orden: 5, completado: false },
  ],
};

const contenidoAbecedario = [
  {
    id: 1000,
    tipo: 'regla',
    texto_es: 'El abecedario en inglés tiene 26 letras. Para deletrear tu nombre o una palabra poco común, se dice cada letra por su nombre en inglés.',
    texto_en: "Could you spell that, please? — Yes, it's J-O-H-N.",
    nivel_cefr: 'A1',
    orden: 1,
  },
  ...letters.map((letter, index) => ({
    id: 1100 + index,
    tipo: 'referencia',
    texto_es: `Letra ${letter}`,
    texto_en: letter,
    audio_key: `mock-letter-${letter}`,
    nivel_cefr: 'A1',
    orden: 10 + index,
  })),
  {
    id: 1200,
    tipo: 'ejemplo',
    texto_es: 'Preguntar cómo se escribe un apellido',
    texto_en: 'How do you spell your last name?',
    audio_key: 'mock-phrase-How do you spell your last name',
    nivel_cefr: 'A1',
    orden: 40,
  },
  {
    id: 1201,
    tipo: 'ejemplo',
    texto_es: 'Deletrear un email',
    texto_en: 'My email is j-smith, all lowercase, at gmail dot com.',
    audio_key: 'mock-phrase-My email is j smith at gmail dot com',
    nivel_cefr: 'A1',
    orden: 41,
  },
];

const cardinales = [
  'one','two','three','four','five','six','seven','eight','nine','ten',
  'eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty',
];
const ordinales = [
  'first','second','third','fourth','fifth','sixth','seventh','eighth','ninth','tenth',
  'eleventh','twelfth','thirteenth','fourteenth','fifteenth','sixteenth','seventeenth','eighteenth','nineteenth','twentieth',
];
const grandes = [
  ['100','one hundred'], ['1.000','one thousand'], ['10.000','ten thousand'],
  ['100.000','one hundred thousand'], ['1.000.000','one million'],
];
const contenidoNumeros = [
  ...cardinales.map((word, index) => ({
    id: 3000 + index, tipo: 'referencia', variante: 'cardinal',
    texto_es: `Número ${index + 1}`, texto_en: word,
    audio_key: `mock-number-${word.replaceAll(' ', '-')}`, orden: index + 1,
  })),
  ...grandes.map(([value, word], index) => ({
    id: 3100 + index, tipo: 'referencia', variante: 'cardinal',
    texto_es: value, texto_en: word,
    audio_key: `mock-number-${word.replaceAll(' ', '-')}`, orden: 24 + index,
  })),
  ...ordinales.map((word, index) => ({
    id: 3200 + index, tipo: 'referencia', variante: 'ordinal',
    texto_es: `${index + 1}º`, texto_en: word,
    audio_key: `mock-number-${word.replaceAll(' ', '-')}`, orden: 30 + index,
  })),
];

const contenidoHora = [
  ['9:00', "It's nine o'clock.", 'en_punto'],
  ['12:30', "It's half past twelve.", 'media'],
  ['3:15', "It's a quarter past three.", 'cuarto'],
  ['6:45', "It's a quarter to seven.", 'cuarto'],
  ['8:20', "It's twenty past eight.", 'minutos'],
  ['10:50', "It's ten to eleven.", 'minutos'],
].map(([texto_es, texto_en, variante], index) => ({
  id: 4000 + index, tipo: 'referencia', variante, texto_es, texto_en,
  audio_key: `mock-phrase-${texto_en.replaceAll(' ', '-')}`, orden: index + 1,
}));
contenidoHora.push(
  ...[
    ['por la mañana', 'in the morning'],
    ['por la tarde', 'in the afternoon'],
    ['por la tarde-noche', 'in the evening'],
    ['por la noche', 'at night'],
    ['al mediodía', 'at noon'],
    ['a medianoche', 'at midnight'],
  ].map(([texto_es, texto_en], index) => ({
    id: 4100 + index, tipo: 'referencia', variante: 'parte_dia', texto_es, texto_en,
    audio_key: `mock-phrase-${texto_en.replaceAll(' ', '-')}`, orden: 20 + index,
  })),
);

const ejercicios = [
  ['cat', ['cat', 'cap', 'can', 'hat'], ['C', 'A', 'T']],
  ['apple', ['apple', 'rice', 'grape', 'table'], ['A', 'P', 'P', 'L', 'E']],
  ['monkey', ['monkey', 'donkey', 'turkey', 'rabbit'], ['M', 'O', 'N', 'K', 'E', 'Y']],
  ['elephant', ['elephant', 'alligator', 'dinosaur', 'butterfly'], ['E', 'L', 'E', 'P', 'H', 'A', 'N', 'T']],
  ['helicopter', ['helicopter', 'television', 'restaurant', 'motorcycle'], ['H', 'E', 'L', 'I', 'C', 'O', 'P', 'T', 'E', 'R']],
].map(([respuesta, opciones, secuencia], index) => ({
  id: 2000 + index,
  tipo: 'cloze',
  formato: 'audio_secuencia',
  consigna_es: 'Escuchá el deletreo y elegí la palabra correcta.',
  contexto_en: secuencia.map(() => '_').join(' '),
  opciones,
  secuencia_audio: secuencia.map((letter) => ({ token: letter, audio_key: `mock-letter-${letter}` })),
}));

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function mockResponse(url, options = {}) {
  const parsed = new URL(typeof url === 'string' ? url : url.url, window.location.origin);
  const path = parsed.pathname;

  if (path === '/gramatica/fases') return json({ fases });
  const faseMatch = path.match(/^\/gramatica\/fases\/([^/]+)\/subtemas$/);
  if (faseMatch && subtemasPorFase[faseMatch[1]]) return json({ subtemas: subtemasPorFase[faseMatch[1]] });
  if (path === '/gramatica/subtemas/fase-1-abecedario/contenido') return json({ contenido: contenidoAbecedario });
  if (path === '/gramatica/subtemas/fase-1-numeros/contenido') return json({ contenido: contenidoNumeros });
  if (path === '/gramatica/subtemas/fase-1-fecha/contenido') return json({ contenido: [] });
  if (path === '/gramatica/subtemas/fase-1-hora/contenido') return json({ contenido: contenidoHora });
  if (/^\/gramatica\/subtemas\/[^/]+\/contenido$/.test(path)) return json({ contenido: [] });
  if (path === '/gramatica/subtemas/fase-1-abecedario/ejercicios') return json({ ejercicios });
  if (/^\/gramatica\/subtemas\/[^/]+\/ejercicios$/.test(path)) return json({ ejercicios });
  if (path === '/gramatica/repaso') return json({ total_vencidos: 0 });
  if (path === '/gramatica/relaciones') return json({ relaciones: [] });
  if (path === '/gramatica/gusanito/evolucion') {
    return json({ emoji: '🐛', pct_dominado: 20, dominados: 1, total: 5 });
  }
  if (path === '/gramatica/building-words') {
    const pistas = ['Un animal que dice meow', 'Una fruta', 'Un animal que vive en los árboles', 'El animal terrestre más grande', 'Un medio de transporte que vuela'];
    return json({
      puzzles: ejercicios.map((item, index) => ({
        id: item.id,
        longitud: item.secuencia_audio.length,
        pista: pistas[index],
        alimento: index < 2 ? 1 : 2,
        secuencia_audio: item.secuencia_audio,
        nivel_cefr: index < 2 ? 'A1' : 'A2',
      })),
    });
  }
  if (path === '/gramatica/subtemas/completar' && options.method === 'POST') return json({ ok: true });

  if (path === '/gramatica/ejercicios/evaluar' && options.method === 'POST') {
    const body = JSON.parse(options.body || '{}');
    const exercise = ejercicios.find((item) => item.id === body.ejercicio_id);
    const respuesta = exercise
      ? ['cat', 'apple', 'monkey', 'elephant', 'helicopter'][exercise.id - 2000]
      : null;
    return json({
      correcto: body.respuesta_usuario === respuesta,
      respuesta_esperada: respuesta,
      error_consolidado: false,
    });
  }

  return null;
}

class MockGrammarAudio {
  constructor(src) {
    this.src = src;
    this.playbackRate = 1;
    this.onended = null;
    this.onerror = null;
  }

  play() {
    const key = decodeURIComponent(this.src.split('/').pop() || '');
    const text = key.replace(/^mock-letter-/, '').replace(/^mock-phrase-/, '').replace(/^mock-number-/, '').replaceAll('-', ' ');
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.lang = 'en-US';
    utterance.rate = Math.max(0.5, Math.min(1, this.playbackRate));
    utterance.onend = () => this.onended?.();
    utterance.onerror = () => this.onerror?.();
    window.speechSynthesis.cancel();
    window.speechSynthesis.speak(utterance);
    return Promise.resolve();
  }
}

export function installGrammarMock() {
  window.fetch = async (url, options = {}) => mockResponse(url, options) || originalFetch(url, options);
  window.Audio = function GrammarAudio(src) {
    return String(src).includes('/gramatica/audio/mock-') ? new MockGrammarAudio(src) : new NativeAudio(src);
  };
  console.info('[Gramática] Mock local activado');
}
