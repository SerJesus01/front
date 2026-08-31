export default {
  slug: 'fase-16-conectores-adicion', icono: '➕', sobre: 'SUMAR IDEAS', titulo: 'Conectores de adición', bajada: 'Uní información que apunta en la misma dirección.', formula: 'and · also · too · in addition', color: '#356f92', suave: '#e8f4fa', pregunta: '¿Cómo agregás una segunda idea?',
  fichas: [
    { palabra: 'and', uso: 'unión directa', ejemplo: 'We bought bread and cheese.', nota: 'Une palabras o ideas de forma simple.', emoji: '🥖' },
    { palabra: 'also', uso: 'antes del verbo principal', ejemplo: 'I also invited Marta.', nota: 'Suma una acción o dato.', emoji: '✉️' },
    { palabra: 'too', uso: 'al final', ejemplo: 'Her sister is coming too.', nota: 'Suena natural al cierre de la idea.', emoji: '👭' },
    { palabra: 'in addition', uso: 'nueva oración', ejemplo: 'The room is bright. In addition, it has a balcony.', nota: 'Agrega un punto completo.', emoji: '🏡' },
  ],
  consejo: 'And conecta dentro de una oración; too suele cerrar; in addition abre una idea nueva.', actividad: 'Sumá un segundo beneficio', ruta: [{ etiqueta: 'IDEA 1', texto: 'The park is quiet.' }, { etiqueta: 'PUENTE', texto: 'In addition,' }, { etiqueta: 'IDEA 2', texto: 'it is beautiful.' }], resultado: 'The park is quiet. In addition, it is beautiful.',
  retos: [
    { frase: 'We need tomatoes ___ onions.', correcta: 'and', opciones: ['and', 'but', 'because'], ayuda: 'Sumamos dos elementos.' },
    { frase: 'I ___ brought some juice.', correcta: 'also', opciones: ['too', 'also', 'however'], ayuda: 'Also va antes del verbo principal brought.' },
    { frase: 'Carlos wants to come ___.', correcta: 'too', opciones: ['also', 'too', 'because'], ayuda: 'Too suena natural al final.' },
    { frase: 'The café is cozy. ___, it is inexpensive.', correcta: 'In addition', opciones: ['However', 'In addition', 'Because'], ayuda: 'La segunda idea agrega otra ventaja.' },
  ],
};
