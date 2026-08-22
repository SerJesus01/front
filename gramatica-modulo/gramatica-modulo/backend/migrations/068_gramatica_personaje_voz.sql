-- Fase 5 del plan de dinamismo pedagógico (voz-personaje, ver memoria del
-- proyecto): reusa las voces de Kokoro ya curadas para personajes_conversacion
-- en vez de la voz genérica de siempre -- cero lógica de escena nueva,
-- solo una referencia a qué voz usar al generar el audio offline
-- (scripts/generar_audio_gramatica.py). `personaje_slug` es opcional
-- (nullable): la mayoría del contenido sigue sin personaje, esto es un
-- refuerzo puntual de anclaje, no un rediseño completo.
ALTER TABLE gramatica_contenido ADD COLUMN personaje_slug VARCHAR(50) REFERENCES personajes_conversacion(slug);

-- Prueba de concepto sobre contenido ya sembrado y real (no un rollout
-- exhaustivo): Sam (tech, geek entusiasta) narra los ejemplos de voz
-- pasiva (descripciones técnicas impersonales, encaje directo con su
-- perfil); Ana (parque, "tranquila, aire libre, rutinas") narra presente
-- simple/rutinas; Emma (viajes, "aventurera, cuentacuentos") narra
-- ever/how-long (preguntas de experiencia de vida, encaja con su rol de
-- narradora de historias).
UPDATE gramatica_contenido gc SET personaje_slug = 'tech'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug IN ('fase-6-pasiva-presente', 'fase-6-pasiva-pasado') AND gc.tipo = 'ejemplo';

UPDATE gramatica_contenido gc SET personaje_slug = 'parque'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-3-presente-simple' AND gc.tipo = 'ejemplo';

UPDATE gramatica_contenido gc SET personaje_slug = 'viajes'
FROM gramatica_temas t
WHERE gc.tema_id = t.id AND t.slug = 'fase-5-ever-how-long' AND gc.tipo = 'ejemplo';

-- Estas 8 filas ya pueden tener audio_key de una corrida anterior de
-- generar_audio_gramatica.py (con la voz genérica, de antes de que
-- existiera personaje_slug) -- lo reseteamos para que la próxima corrida
-- las tome de nuevo y las regenere con la voz del personaje. En un
-- entorno fresco esto es un no-op (audio_key ya es NULL).
UPDATE gramatica_contenido SET audio_key = NULL WHERE personaje_slug IS NOT NULL;
