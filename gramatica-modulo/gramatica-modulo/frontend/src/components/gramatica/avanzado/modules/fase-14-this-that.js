export default {
  slug: 'fase-14-this-that', icono: '📍', sobre: 'DISTANCIA Y CANTIDAD', titulo: 'this / that / these / those', bajada: 'Señalá una o varias cosas según estén cerca o lejos.', formula: 'this/these cerca · that/those lejos', color: '#356f92', suave: '#e8f4fa', pregunta: '¿Está cerca o lejos? ¿Es una cosa o varias?',
  fichas: [
    { palabra: 'this', uso: 'una cosa cerca', ejemplo: 'This chair is comfortable.', nota: 'Singular al alcance.', emoji: '🪑' },
    { palabra: 'that', uso: 'una cosa lejos', ejemplo: 'That house is beautiful.', nota: 'Singular a cierta distancia.', emoji: '🏠' },
    { palabra: 'these', uso: 'varias cosas cerca', ejemplo: 'These strawberries are sweet.', nota: 'Plural al alcance.', emoji: '🍓' },
    { palabra: 'those', uso: 'varias cosas lejos', ejemplo: 'Those mountains are amazing.', nota: 'Plural a la distancia.', emoji: '⛰️' },
  ],
  consejo: 'La terminación ayuda: this/that son singular; these/those son plural.', actividad: 'Ubicá el objeto en tu mapa mental', ruta: [{ etiqueta: 'CANTIDAD', texto: 'several books' }, { etiqueta: 'DISTANCIA', texto: 'near me' }, { etiqueta: 'ELECCIÓN', texto: 'these books' }], resultado: 'These books are mine.',
  retos: [
    { frase: '___ cup in my hand is hot.', correcta: 'This', opciones: ['This', 'That', 'Those'], ayuda: 'Una taza cerca: this.' },
    { frase: 'Look at ___ birds over there.', correcta: 'those', opciones: ['this', 'that', 'those'], ayuda: 'Varias aves lejos: those.' },
    { frase: '___ shoes here are on sale.', correcta: 'These', opciones: ['These', 'That', 'This'], ayuda: 'Varios zapatos cerca: these.' },
    { frase: 'Who lives in ___ apartment across the street?', correcta: 'that', opciones: ['these', 'this', 'that'], ayuda: 'Un departamento lejos: that.' },
  ],
};
