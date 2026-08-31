export default {
  slug: 'fase-16-conectores-causales', icono: '🌱', sobre: 'EXPLICAR CAUSAS Y RESULTADOS', titulo: 'Conectores causales', bajada: 'Mostrá por qué ocurre algo o qué sucede como resultado.', formula: 'because + oración · because of + nombre · so + resultado', color: '#3d7468', suave: '#e9f6f1', pregunta: '¿Presentás una causa o su resultado?',
  fichas: [
    { palabra: 'because', uso: 'causa con oración', ejemplo: 'We stayed home because it was raining.', nota: 'Después viene sujeto + verbo.', emoji: '🌧️' },
    { palabra: 'because of', uso: 'causa con nombre', ejemplo: 'The picnic ended because of the rain.', nota: 'Después viene un sustantivo.', emoji: '☔' },
    { palabra: 'so', uso: 'resultado', ejemplo: 'It was late, so we took a taxi.', nota: 'La segunda parte muestra la consecuencia.', emoji: '🚕' },
    { palabra: 'since', uso: 'causa conocida', ejemplo: 'Since we were hungry, we made sandwiches.', nota: 'Introduce una razón de manera natural.', emoji: '🥪' },
  ],
  consejo: 'Because responde “por qué”; so responde “qué pasó entonces”.', actividad: 'Conectá una causa con su resultado', ruta: [{ etiqueta: 'CAUSA', texto: 'The bus was late' }, { etiqueta: 'PUENTE', texto: 'so' }, { etiqueta: 'RESULTADO', texto: 'we walked home' }], resultado: 'The bus was late, so we walked home.',
  retos: [
    { frase: 'I opened the window ___ it was hot.', correcta: 'because', opciones: ['because', 'because of', 'so'], ayuda: 'Después aparece una oración: it was hot.' },
    { frase: 'The game was canceled ___ the rain.', correcta: 'because of', opciones: ['because', 'because of', 'so'], ayuda: 'Después aparece el sustantivo the rain.' },
    { frase: 'We were tired, ___ we went home.', correcta: 'so', opciones: ['because', 'so', 'although'], ayuda: 'La segunda idea es el resultado.' },
    { frase: '___ it was Sunday, the shops closed early.', correcta: 'Since', opciones: ['So', 'Since', 'However'], ayuda: 'Since introduce la razón.' },
  ],
};
