export default {
  slug: 'fase-16-conectores-secuenciales', icono: '🥣', sobre: 'PASOS EN ORDEN', titulo: 'Conectores secuenciales', bajada: 'Guiá una receta, una rutina o una explicación paso a paso.', formula: 'first → next → then → finally', color: '#b06b33', suave: '#fff3e4', pregunta: '¿En qué momento de la secuencia estás?',
  fichas: [
    { palabra: 'first', uso: 'primer paso', ejemplo: 'First, wash the vegetables.', nota: 'Abre el proceso.', emoji: '🥬' },
    { palabra: 'next', uso: 'paso siguiente', ejemplo: 'Next, cut the tomatoes.', nota: 'Mueve la acción al paso que sigue.', emoji: '🍅' },
    { palabra: 'then', uso: 'continuación', ejemplo: 'Then, add a little salt.', nota: 'Continúa la secuencia.', emoji: '🧂' },
    { palabra: 'finally', uso: 'último paso', ejemplo: 'Finally, serve the salad.', nota: 'Cierra el proceso.', emoji: '🥗' },
  ],
  consejo: 'Pensá en cuatro estaciones: inicio, siguiente paso, continuación y cierre.', actividad: 'Armá una limonada paso a paso', ruta: [{ etiqueta: 'FIRST', texto: 'cut the lemons' }, { etiqueta: 'THEN', texto: 'add water' }, { etiqueta: 'FINALLY', texto: 'serve with ice' }], resultado: 'First, cut the lemons. Then, add water. Finally, serve with ice.',
  retos: [
    { frase: '___, turn on the oven.', correcta: 'First', opciones: ['Finally', 'First', 'Then'], ayuda: 'Es el paso que inicia el proceso.' },
    { frase: 'Next, mix the flour. ___, add the milk.', correcta: 'Then', opciones: ['First', 'Finally', 'Then'], ayuda: 'La acción continúa después de next.' },
    { frase: '___, take the cake out and let it cool.', correcta: 'Finally', opciones: ['First', 'Next', 'Finally'], ayuda: 'Es el cierre de la receta.' },
    { frase: 'First, choose a book. ___, find a quiet place.', correcta: 'Next', opciones: ['Next', 'Finally', 'Before'], ayuda: 'Es el segundo paso.' },
  ],
};
