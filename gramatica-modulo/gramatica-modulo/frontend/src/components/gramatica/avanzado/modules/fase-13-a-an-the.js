export default {
  slug: 'fase-13-a-an-the', icono: '🎟️', sobre: 'PRESENTAR Y RECONOCER', titulo: 'a / an / the', bajada: 'Presentá algo por primera vez y señalá lo que ya conocemos.', formula: 'a/an = uno · the = ese conocido', color: '#a05c43', suave: '#fff0e8', pregunta: '¿Es algo nuevo o ya sabemos cuál es?',
  fichas: [
    { palabra: 'a', uso: 'sonido de consonante', ejemplo: 'I saw a movie last night.', nota: 'Primera mención: todavía no sabemos qué película.', emoji: '🎬' },
    { palabra: 'an', uso: 'sonido de vocal', ejemplo: 'She ate an orange.', nota: 'Elegimos por el sonido inicial, no solo por la letra.', emoji: '🍊' },
    { palabra: 'the', uso: 'algo identificado', ejemplo: 'The movie was really funny.', nota: 'Ahora ambos sabemos de qué película hablamos.', emoji: '👉' },
    { palabra: 'sin artículo', uso: 'idea general', ejemplo: 'Music helps me relax.', nota: 'Hablamos de la música en general.', emoji: '🎵' },
  ],
  consejo: 'Primera mención: a/an. Segunda mención o algo único en la escena: the.', actividad: 'Presentá algo y volvé a mencionarlo', ruta: [{ etiqueta: 'NUEVO', texto: 'a restaurant' }, { etiqueta: 'YA CONOCIDO', texto: 'the restaurant' }, { etiqueta: 'DETALLE', texto: 'was cozy' }], resultado: 'We found a restaurant. The restaurant was cozy.',
  retos: [
    { frase: 'I need ___ umbrella.', correcta: 'an', opciones: ['a', 'an', 'the'], ayuda: 'Umbrella comienza con sonido de vocal.' },
    { frase: 'We saw a dog. ___ dog was friendly.', correcta: 'The', opciones: ['A', 'An', 'The'], ayuda: 'Ya mencionamos al perro.' },
    { frase: 'He bought ___ new jacket.', correcta: 'a', opciones: ['a', 'an', 'the'], ayuda: 'Es la primera mención y jacket inicia con sonido de consonante.' },
    { frase: 'Please close ___ door.', correcta: 'the', opciones: ['a', 'an', 'the'], ayuda: 'La situación deja claro cuál puerta.' },
  ],
};
