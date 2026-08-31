export default {
  slug: 'fase-17-preposiciones-lugar', icono: '🗺️', sobre: 'UBICAR EN EL ESPACIO', titulo: 'Preposiciones de lugar', bajada: 'Describí dónde está algo respecto a su entorno.', formula: 'in · on · under · next to · between', color: '#3d7468', suave: '#e9f6f1', pregunta: '¿Está dentro, encima, debajo o junto a algo?',
  fichas: [
    { palabra: 'in', uso: 'dentro', ejemplo: 'The keys are in my bag.', nota: 'El objeto está contenido.', emoji: '👜' },
    { palabra: 'on', uso: 'sobre una superficie', ejemplo: 'The book is on the table.', nota: 'El objeto toca la superficie.', emoji: '📖' },
    { palabra: 'under', uso: 'debajo', ejemplo: 'The cat is under the chair.', nota: 'Está en un nivel inferior.', emoji: '🐈' },
    { palabra: 'next to', uso: 'al lado', ejemplo: 'The bakery is next to the bank.', nota: 'Los dos lugares son vecinos.', emoji: '🥐' },
    { palabra: 'between', uso: 'en medio de dos', ejemplo: 'The lamp is between the sofas.', nota: 'Hay un elemento a cada lado.', emoji: '💡' },
    { palabra: 'behind', uso: 'detrás', ejemplo: 'The garden is behind the house.', nota: 'La casa queda delante.', emoji: '🌳' },
  ],
  consejo: 'Tomá un objeto como referencia y dibujá mentalmente la relación espacial.', actividad: 'Ubicá un objeto dentro de una escena', ruta: [{ etiqueta: 'OBJETO', texto: 'the plant' }, { etiqueta: 'RELACIÓN', texto: 'next to' }, { etiqueta: 'REFERENCIA', texto: 'the window' }], resultado: 'The plant is next to the window.',
  retos: [
    { frase: 'The milk is ___ the fridge.', correcta: 'in', opciones: ['in', 'on', 'between'], ayuda: 'Está dentro del refrigerador.' },
    { frase: 'Your glasses are ___ the newspaper.', correcta: 'on', opciones: ['under', 'on', 'behind'], ayuda: 'Están sobre la superficie del periódico.' },
    { frase: 'The pharmacy is ___ the café and the hotel.', correcta: 'between', opciones: ['next to', 'between', 'in'], ayuda: 'Está en medio de dos lugares.' },
    { frase: 'The shoes are ___ the bed.', correcta: 'under', opciones: ['on', 'under', 'in'], ayuda: 'Están debajo de la cama.' },
  ],
};
