-- Feedback en vivo: los 5 ejercicios de conteo (migración 041) tenían
-- opciones en dígitos ("10", "11", "12", "13") -- contar estrellas y
-- elegir el dígito no practica nada de inglés, "no tiene chiste" (cita
-- textual del dueño). Se pasan respuesta_esperada + opciones a la
-- palabra en inglés del número (reusa el mismo vocabulario que la
-- grilla de cardinales, fase-1-numeros 1-20, ver migración 034) --
-- ahora el ejercicio es: contar + reconocer la palabra correcta, no
-- solo contar.
UPDATE ejercicios e
SET respuesta_esperada = x.nueva_respuesta, opciones = x.nuevas_opciones
FROM (VALUES
    ('4', 'four', ARRAY['three', 'four', 'five', 'six']),
    ('7', 'seven', ARRAY['six', 'seven', 'eight', 'nine']),
    ('11', 'eleven', ARRAY['ten', 'eleven', 'twelve', 'thirteen']),
    ('15', 'fifteen', ARRAY['fourteen', 'fifteen', 'sixteen', 'seventeen']),
    ('19', 'nineteen', ARRAY['seventeen', 'eighteen', 'nineteen', 'twenty'])
) AS x(vieja_respuesta, nueva_respuesta, nuevas_opciones),
    gramatica_temas t
WHERE e.tema_gramatica_id = t.id
  AND t.slug = 'fase-1-numeros'
  AND e.formato = 'conteo_visual'
  AND e.respuesta_esperada = x.vieja_respuesta;
