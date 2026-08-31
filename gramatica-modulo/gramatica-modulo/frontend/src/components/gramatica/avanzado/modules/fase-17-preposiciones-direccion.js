export default {
  slug: 'fase-17-preposiciones-direccion', icono: '🧭', sobre: 'MOVIMIENTO Y RECORRIDOS', titulo: 'Preposiciones de dirección', bajada: 'Contá hacia dónde se mueve alguien y qué camino sigue.', formula: 'to · into · out of · across · through', color: '#356f92', suave: '#e8f4fa', pregunta: '¿Cuál es el destino o cómo se cruza el espacio?',
  fichas: [
    { palabra: 'to', uso: 'hacia un destino', ejemplo: 'We walked to the station.', nota: 'Marca el destino general.', emoji: '🚉' },
    { palabra: 'into', uso: 'hacia el interior', ejemplo: 'She went into the shop.', nota: 'Hay movimiento de afuera hacia adentro.', emoji: '🏪' },
    { palabra: 'out of', uso: 'hacia el exterior', ejemplo: 'He came out of the house.', nota: 'Hay movimiento de adentro hacia afuera.', emoji: '🚪' },
    { palabra: 'across', uso: 'de un lado al otro', ejemplo: 'They ran across the street.', nota: 'Cruza una superficie abierta.', emoji: '🛣️' },
    { palabra: 'through', uso: 'por dentro de un espacio', ejemplo: 'We walked through the park.', nota: 'El recorrido atraviesa el interior.', emoji: '🌳' },
    { palabra: 'along', uso: 'siguiendo una línea', ejemplo: 'Walk along the river.', nota: 'El recorrido sigue el borde o camino.', emoji: '🏞️' },
  ],
  consejo: 'Into y out of cruzan un límite; across cruza una superficie; through atraviesa el interior.', actividad: 'Trazá un recorrido sencillo', ruta: [{ etiqueta: 'INICIO', texto: 'the café' }, { etiqueta: 'CAMINO', texto: 'across the square' }, { etiqueta: 'DESTINO', texto: 'to the museum' }], resultado: 'Walk across the square to the museum.',
  retos: [
    { frase: 'We’re going ___ the beach.', correcta: 'to', opciones: ['to', 'into', 'through'], ayuda: 'Beach es el destino.' },
    { frase: 'The children ran ___ the room.', correcta: 'into', opciones: ['to', 'into', 'across'], ayuda: 'Se mueven hacia el interior del cuarto.' },
    { frase: 'She walked ___ the bridge.', correcta: 'across', opciones: ['across', 'into', 'out of'], ayuda: 'Cruza de un lado al otro.' },
    { frase: 'We drove ___ the tunnel.', correcta: 'through', opciones: ['along', 'to', 'through'], ayuda: 'El recorrido atraviesa el interior del túnel.' },
  ],
};
