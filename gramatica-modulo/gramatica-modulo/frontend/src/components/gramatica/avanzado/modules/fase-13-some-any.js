export default {
  slug: 'fase-13-some-any', icono: '🫙', sobre: 'CANTIDADES SIN NÚMERO EXACTO', titulo: 'some / any', bajada: 'Hablá de una cantidad abierta en afirmaciones, preguntas y negativas.', formula: 'some ✓ · any ? / not', color: '#735b9b', suave: '#f2edfb', pregunta: '¿Afirmás, preguntás o negás?',
  fichas: [
    { palabra: 'some', uso: 'afirmación', ejemplo: 'There are some cookies.', nota: 'Hay una cantidad, pero no importa el número exacto.', emoji: '🍪' },
    { palabra: 'any', uso: 'pregunta abierta', ejemplo: 'Do we have any milk?', nota: 'Todavía no sabemos si hay leche.', emoji: '🥛' },
    { palabra: 'any', uso: 'negación', ejemplo: 'We don’t have any sugar.', nota: 'La cantidad es cero.', emoji: '🚫' },
    { palabra: 'some', uso: 'ofrecimiento', ejemplo: 'Would you like some tea?', nota: 'Esperamos o invitamos una respuesta positiva.', emoji: '🍵' },
  ],
  consejo: 'Some suele afirmar; any abre una pregunta o acompaña una negación. En ofertas amables, some suena natural.', actividad: 'Pasá de una afirmación a una pregunta', ruta: [{ etiqueta: 'AFIRMACIÓN', texto: 'some fruit' }, { etiqueta: 'PREGUNTA', texto: 'any fruit?' }, { etiqueta: 'RESPUESTA', texto: 'Yes, there is some.' }], resultado: 'Is there any fruit? Yes, there is some.',
  retos: [
    { frase: 'I bought ___ bananas.', correcta: 'some', opciones: ['some', 'any', 'an'], ayuda: 'Es una afirmación con cantidad abierta.' },
    { frase: 'Are there ___ clean towels?', correcta: 'any', opciones: ['some', 'any', 'a'], ayuda: 'Es una pregunta abierta.' },
    { frase: 'There isn’t ___ coffee left.', correcta: 'any', opciones: ['some', 'any', 'many'], ayuda: 'Any acompaña la negación.' },
    { frase: 'Would you like ___ cake?', correcta: 'some', opciones: ['some', 'any', 'a few'], ayuda: 'En un ofrecimiento amable usamos some.' },
  ],
};
