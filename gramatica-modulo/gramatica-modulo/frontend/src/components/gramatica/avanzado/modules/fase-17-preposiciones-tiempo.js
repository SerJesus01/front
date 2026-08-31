export default {
  slug: 'fase-17-preposiciones-tiempo', icono: '🗓️', sobre: 'UBICAR MOMENTOS', titulo: 'Preposiciones de tiempo', bajada: 'Elegí at, on o in según la precisión del momento.', formula: 'at = punto · on = día · in = periodo', color: '#a05c43', suave: '#fff0e8', pregunta: '¿Es una hora, un día o un periodo amplio?',
  fichas: [
    { palabra: 'at', uso: 'hora o punto exacto', ejemplo: 'Dinner is at seven.', nota: 'Señala un punto preciso.', emoji: '🕖' },
    { palabra: 'on', uso: 'día o fecha', ejemplo: 'We’re meeting on Saturday.', nota: 'Señala un día del calendario.', emoji: '📅' },
    { palabra: 'in', uso: 'mes, año o parte del día', ejemplo: 'My birthday is in November.', nota: 'Señala un periodo amplio.', emoji: '🍂' },
    { palabra: 'sin preposición', uso: 'today, tomorrow, last, next', ejemplo: 'I’ll call you next week.', nota: 'Estas expresiones ya ubican el momento.', emoji: '➡️' },
  ],
  consejo: 'Imaginá un zoom: in muestra el periodo, on acerca al día y at apunta a la hora.', actividad: 'Acercate desde el mes hasta la hora', ruta: [{ etiqueta: 'PERIODO', texto: 'in June' }, { etiqueta: 'DÍA', texto: 'on Friday' }, { etiqueta: 'HORA', texto: 'at six' }], resultado: 'The party is in June, on Friday, at six.',
  retos: [
    { frase: 'The movie starts ___ 8:30.', correcta: 'at', opciones: ['in', 'on', 'at'], ayuda: 'Una hora exacta usa at.' },
    { frase: 'We have lunch together ___ Sundays.', correcta: 'on', opciones: ['at', 'on', 'in'], ayuda: 'Un día de la semana usa on.' },
    { frase: 'The weather is warm ___ summer.', correcta: 'in', opciones: ['in', 'on', 'at'], ayuda: 'Una estación es un periodo amplio.' },
    { frase: 'I’m leaving ___ tomorrow morning.', correcta: '—', opciones: ['on', 'in', '—'], ayuda: 'Tomorrow no necesita preposición.' },
  ],
};
