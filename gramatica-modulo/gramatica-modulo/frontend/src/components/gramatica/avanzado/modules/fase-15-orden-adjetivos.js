export default {
  slug: 'fase-15-orden-adjetivos', icono: '🧩', sobre: 'DESCRIBIR CON ORDEN', titulo: 'Orden de adjetivos', bajada: 'Acomodá las características para que la descripción suene natural.', formula: 'opinión → tamaño → edad → color → objeto', color: '#a05c43', suave: '#fff0e8', pregunta: '¿Qué impresión va primero y qué detalle va después?',
  fichas: [
    { palabra: 'beautiful small garden', uso: 'opinión + tamaño', ejemplo: 'They have a beautiful small garden.', nota: 'La opinión suele aparecer antes del tamaño.', emoji: '🌷' },
    { palabra: 'big old house', uso: 'tamaño + edad', ejemplo: 'We visited a big old house.', nota: 'El tamaño va antes de la edad.', emoji: '🏚️' },
    { palabra: 'lovely blue dress', uso: 'opinión + color', ejemplo: 'She wore a lovely blue dress.', nota: 'La impresión personal precede al color.', emoji: '👗' },
    { palabra: 'small round table', uso: 'tamaño + forma', ejemplo: 'I need a small round table.', nota: 'El tamaño suele ir antes de la forma.', emoji: '🟠' },
  ],
  consejo: 'No hace falta memorizar una lista enorme: empezá con opinión antes de datos físicos.', actividad: 'Ordená una descripción breve', ruta: [{ etiqueta: 'OPINIÓN', texto: 'beautiful' }, { etiqueta: 'COLOR', texto: 'red' }, { etiqueta: 'OBJETO', texto: 'scarf' }], resultado: 'She bought a beautiful red scarf.',
  retos: [
    { frase: 'It’s a ___ sofa.', correcta: 'comfortable new', opciones: ['new comfortable', 'comfortable new', 'sofa comfortable'], ayuda: 'La opinión comfortable va antes de la edad new.' },
    { frase: 'He has a ___ dog.', correcta: 'big black', opciones: ['black big', 'big black', 'dog big black'], ayuda: 'El tamaño va antes del color.' },
    { frase: 'We sat at a ___ table.', correcta: 'small wooden', opciones: ['wooden small', 'small wooden', 'table small'], ayuda: 'El tamaño va antes del material.' },
    { frase: 'She found a ___ box.', correcta: 'lovely old', opciones: ['old lovely', 'lovely old', 'box lovely'], ayuda: 'La opinión va antes de la edad.' },
  ],
};
