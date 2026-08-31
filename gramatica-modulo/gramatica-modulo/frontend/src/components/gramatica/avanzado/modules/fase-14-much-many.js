export default {
  slug: 'fase-14-much-many', icono: '📊', sobre: 'PREGUNTAR POR CANTIDAD', titulo: 'much / many', bajada: 'Elegí según puedas contar unidades o medir una cantidad.', formula: 'many + contables · much + incontables', color: '#735b9b', suave: '#f2edfb', pregunta: '¿Contás piezas o medís una cantidad?',
  fichas: [
    { palabra: 'many', uso: 'contables plurales', ejemplo: 'How many oranges do we need?', nota: 'Podemos contar las naranjas.', emoji: '🍊' },
    { palabra: 'much', uso: 'incontables', ejemplo: 'How much juice is left?', nota: 'Medimos el jugo.', emoji: '🧃' },
    { palabra: 'not many', uso: 'pocos contables', ejemplo: 'There aren’t many chairs.', nota: 'Cantidad pequeña de unidades.', emoji: '🪑' },
    { palabra: 'not much', uso: 'poco incontable', ejemplo: 'There isn’t much time.', nota: 'Cantidad pequeña que no contamos por piezas.', emoji: '⏳' },
  ],
  consejo: 'Many camina con plurales; much con nombres que normalmente no llevan plural.', actividad: 'Formá una pregunta de cantidad', ruta: [{ etiqueta: 'PREGUNTA', texto: 'How' }, { etiqueta: 'TIPO', texto: 'many + plates' }, { etiqueta: 'ACCIÓN', texto: 'do we need?' }], resultado: 'How many plates do we need?',
  retos: [
    { frase: 'How ___ people are coming?', correcta: 'many', opciones: ['much', 'many', 'little'], ayuda: 'People representa personas contables.' },
    { frase: 'We don’t have ___ time.', correcta: 'much', opciones: ['many', 'much', 'few'], ayuda: 'Time es incontable.' },
    { frase: 'Are there ___ shops nearby?', correcta: 'many', opciones: ['much', 'many', 'a little'], ayuda: 'Shops es plural contable.' },
    { frase: 'How ___ rice should I cook?', correcta: 'much', opciones: ['many', 'much', 'a few'], ayuda: 'Rice se mide, no se cuenta directamente.' },
  ],
};
