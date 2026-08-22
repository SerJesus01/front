-- Pedido en vivo (04/ago/2026): preparar el espacio/código para recibir
-- imágenes en los ejemplos de Fase 1 (Fundamentos) -- se elige UN
-- ejemplo por subtema, el más concreto/visualizable, dejando afuera
-- Abecedario/Números/Hora-Fecha (abstractos o ya con su propio widget
-- visual, ver mini-reloj CSS). Los archivos reales todavía no existen
-- (ver imagenes_gramatica/PROMPTS_PENDIENTES.md) -- esto solo deja el
-- imagen_key ya asignado, mismo patrón que escena_puertas_entre.

-- tipo='ejemplo' explícito: varios subtemas reusan el mismo texto_en en
-- su fila 'regla' (primer ejemplo citado como muestra) -- el frontend
-- solo pinta <img> en las cards de tipo 'ejemplo' (ver
-- contenidoEjemplos en GramaticaView.vue), así que setear imagen_key en
-- la regla no haría nada pero conviene no dejar el dato ahí igual.
UPDATE gramatica_contenido gc SET imagen_key = 'escena_saludo_oficina'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-saludos' AND gc.tipo = 'ejemplo' AND gc.texto_en = 'Good morning! How are you?';

UPDATE gramatica_contenido gc SET imagen_key = 'escena_despedida_oficina'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-saludos' AND gc.tipo = 'ejemplo' AND gc.texto_en = 'Bye! See you tomorrow.';

UPDATE gramatica_contenido gc SET imagen_key = 'escena_familia_playa'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-familia-coloquial' AND gc.tipo = 'ejemplo' AND gc.texto_en = 'My grandma and grandpa live near the beach.';

UPDATE gramatica_contenido gc SET imagen_key = 'escena_frutero'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-frutas' AND gc.tipo = 'ejemplo' AND gc.texto_en = 'Can I get an apple and a banana, please?';

UPDATE gramatica_contenido gc SET imagen_key = 'escena_taxi_calle'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-1-abreviaturas' AND gc.tipo = 'ejemplo' AND gc.texto_en = 'Can you call me a cab?';
