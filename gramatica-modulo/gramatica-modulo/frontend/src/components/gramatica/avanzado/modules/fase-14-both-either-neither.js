export default {
  slug: 'fase-14-both-either-neither', icono: '⚖️', sobre: 'ELEGIR ENTRE DOS', titulo: 'both / either / neither', bajada: 'Decí si elegís los dos, cualquiera de los dos o ninguno.', formula: 'both = 2 · either = 1 de 2 · neither = 0', color: '#3d7468', suave: '#e9f6f1', pregunta: 'De dos opciones, ¿cuántas funcionan?',
  fichas: [
    { palabra: 'both', uso: 'los dos', ejemplo: 'Both dresses look great.', nota: 'Las dos opciones cumplen.', emoji: '👗' },
    { palabra: 'either', uso: 'cualquiera de los dos', ejemplo: 'Either bus will take you downtown.', nota: 'Una u otra opción funciona.', emoji: '🚌' },
    { palabra: 'neither', uso: 'ninguno de los dos', ejemplo: 'Neither key opens the door.', nota: 'Cero opciones funcionan.', emoji: '🔑' },
    { palabra: 'either...or', uso: 'una opción u otra', ejemplo: 'We can eat either pizza or pasta.', nota: 'Presentamos dos alternativas.', emoji: '🍕' },
  ],
  consejo: 'Imaginá un marcador: both 2/2, either 1/2, neither 0/2.', actividad: 'Resolvé una elección de dos', ruta: [{ etiqueta: 'OPCIONES', texto: 'tea / coffee' }, { etiqueta: 'RESULTADO', texto: 'both are available' }, { etiqueta: 'ELECCIÓN', texto: 'either is fine' }], resultado: 'Both are available, so either is fine.',
  retos: [
    { frase: '___ windows are open.', correcta: 'Both', opciones: ['Both', 'Either', 'Neither'], ayuda: 'Las dos ventanas están abiertas.' },
    { frase: 'You can sit on ___ side.', correcta: 'either', opciones: ['both', 'either', 'neither'], ayuda: 'Cualquiera de los dos lados funciona.' },
    { frase: '___ answer is correct.', correcta: 'Neither', opciones: ['Both', 'Either', 'Neither'], ayuda: 'Ninguna de las dos respuestas funciona.' },
    { frase: 'We can go ___ today or tomorrow.', correcta: 'either', opciones: ['both', 'either', 'neither'], ayuda: 'Either...or presenta dos alternativas.' },
  ],
};
