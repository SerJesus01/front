export default {
  slug: 'fase-16-clausulas-relativas', icono: '🧷', sobre: 'AÑADIR INFORMACIÓN', titulo: 'Cláusulas relativas', bajada: 'Describí una persona, cosa o lugar sin empezar otra oración.', formula: 'person who · thing that · place where', color: '#3d7468', suave: '#e9f6f1', pregunta: '¿Describís una persona, una cosa o un lugar?',
  fichas: [
    { palabra: 'who', uso: 'persona', ejemplo: 'The woman who lives next door is friendly.', nota: 'Who conecta información sobre una persona.', emoji: '👩' },
    { palabra: 'that', uso: 'cosa o animal', ejemplo: 'The book that you lent me is wonderful.', nota: 'That conecta información sobre una cosa.', emoji: '📖' },
    { palabra: 'where', uso: 'lugar', ejemplo: 'This is the café where we met.', nota: 'Where conecta información sobre un lugar.', emoji: '☕' },
    { palabra: 'whose', uso: 'pertenencia', ejemplo: 'I know the girl whose dog is missing.', nota: 'Whose indica de quién es algo.', emoji: '🐕' },
  ],
  consejo: 'Elegí el puente mirando la palabra anterior: persona, cosa, lugar o dueño.', actividad: 'Uní dos frases sobre la misma cosa', ruta: [{ etiqueta: 'BASE', texto: 'I found the keys.' }, { etiqueta: 'PUENTE', texto: 'that' }, { etiqueta: 'DETALLE', texto: 'you lost yesterday' }], resultado: 'I found the keys that you lost yesterday.',
  retos: [
    { frase: 'The man ___ helped us was very kind.', correcta: 'who', opciones: ['who', 'where', 'whose'], ayuda: 'Describimos a una persona.' },
    { frase: 'This is the song ___ I love.', correcta: 'that', opciones: ['who', 'that', 'where'], ayuda: 'Describimos una cosa.' },
    { frase: 'That’s the park ___ we play tennis.', correcta: 'where', opciones: ['that', 'whose', 'where'], ayuda: 'Describimos un lugar.' },
    { frase: 'She is the neighbor ___ cat visits us.', correcta: 'whose', opciones: ['who', 'whose', 'where'], ayuda: 'El gato pertenece a la vecina.' },
  ],
};
