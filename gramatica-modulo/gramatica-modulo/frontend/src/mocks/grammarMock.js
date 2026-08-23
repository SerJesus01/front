const originalFetch = window.fetch.bind(window);
const NativeAudio = window.Audio;

const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

const fases = [
  { id: 1, nombre: 'Fundamentos', slug: 'fase-1-fundamentos', orden: 1, disponible: true, completado: false },
];

const subtemas = [
  { id: 101, nombre: 'Abecedario y deletreo', slug: 'fase-1-abecedario', orden: 1, completado: false },
  { id: 102, nombre: 'Números', slug: 'fase-1-numeros', orden: 2, completado: false },
  { id: 103, nombre: 'Hora y fecha', slug: 'fase-1-hora-fecha', orden: 3, completado: false },
];

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
  if (path === '/gramatica/fases/fase-1-fundamentos/subtemas') return json({ subtemas });
  if (path === '/gramatica/subtemas/fase-1-abecedario/contenido') return json({ contenido: contenidoAbecedario });
  if (path === '/gramatica/subtemas/fase-1-abecedario/ejercicios') return json({ ejercicios });
  if (path === '/gramatica/repaso') return json({ total_vencidos: 0 });
  if (path === '/gramatica/relaciones') return json({ relaciones: [] });
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
    const text = key.replace(/^mock-letter-/, '').replace(/^mock-phrase-/, '').replaceAll('-', ' ');
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
