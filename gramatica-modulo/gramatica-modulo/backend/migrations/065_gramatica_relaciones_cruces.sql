-- Fase 6 del plan de dinamismo pedagógico (mapa "VS" de cruces, ver
-- memoria del proyecto): tabla chica y curada a mano de relaciones entre
-- subtemas -- NO un grafo dinámico, 12 filas fijas. `tipo_relacion`
-- distingue 'contraste' (confusión típica entre dos reglas, ej. perfecto
-- vs pasado), 'progresion' (mismo concepto, cambia el tiempo verbal) y
-- 'combinacion' (se usan naturalmente juntos en la misma oración).
CREATE TABLE gramatica_relaciones (
    id            SERIAL PRIMARY KEY,
    tema_a_id     INTEGER NOT NULL REFERENCES gramatica_temas(id),
    tema_b_id     INTEGER NOT NULL REFERENCES gramatica_temas(id),
    tipo_relacion VARCHAR(20) NOT NULL CHECK (tipo_relacion IN ('contraste', 'progresion', 'combinacion')),
    texto_es      TEXT NOT NULL,
    CHECK (tema_a_id <> tema_b_id)
);

-- Curadas contra los subtemas que YA existen con contenido real (Fases
-- 1-9 + Camino 0) -- nada de relaciones hacia Fases 10-18 todavía sin
-- sembrar (Fase 8 del plan general).
INSERT INTO gramatica_relaciones (tema_a_id, tema_b_id, tipo_relacion, texto_es)
SELECT ta.id, tb.id, x.tipo_relacion, x.texto_es
FROM (VALUES
    ('fase-5-perfecto-intro', 'fase-4-pasado-simple', 'contraste',
     'El cruce más confundido de todos: si el momento exacto importa o se menciona, pasado simple. Si lo que importa es el resultado ahora, presente perfecto.'),
    ('fase-3-presente-simple', 'fase-3-presente-continuo', 'contraste',
     'Rutina/hábito general vs. algo pasando ahora mismo -- la misma acción cambia de forma según cuál de las dos preguntes.'),
    ('fase-4-was-were', 'fase-4-pasado-simple', 'contraste',
     '''was''/''were'' son SOLO el pasado del verbo ''to be'' -- para cualquier otro verbo en pasado, se usa pasado simple regular o irregular.'),
    ('fase-8-must-have-to', 'fase-8-should', 'contraste',
     'must/have to es obligación real (fuerte o externa); should es solo una recomendación -- confundirlos hace sonar una sugerencia como una orden, o al revés.'),
    ('fase-8-can-could', 'fase-8-must-have-to', 'contraste',
     'can/could hablan de habilidad o permiso; must/have to hablan de obligación -- categorías de modales distintas que se pisan seguido en la cabeza.'),
    ('fase-7-going-to', 'fase-7-will-shall', 'contraste',
     'going to es un plan ya decidido antes de hablar; will es una decisión que se toma en el momento mismo de hablar.'),
    ('fase-7-going-to', 'fase-7-continuo-futuro', 'progresion',
     'Ambos hablan de planes futuros, pero el continuo agrega más certeza -- ya está agendado con hora/fecha concreta, no solo decidido.'),
    ('fase-6-pasiva-presente', 'fase-6-pasiva-pasado', 'progresion',
     'Misma estructura (foco en quien recibe la acción), la única diferencia real es el tiempo verbal del verbo ''to be'' que la arma.'),
    ('fase-9-there-is-there-are', 'fase-9-ubicacion-basica', 'combinacion',
     'Casi nunca aparecen separados en una oración real: ''there is/are'' anuncia que algo existe, la preposición de lugar dice dónde exactamente.'),
    ('fase-5-just-already-yet', 'fase-5-ever-how-long', 'contraste',
     'Ambos acompañan al presente perfecto pero cumplen roles distintos: just/already/yet hablan de CUÁNDO dentro de un marco reciente, ever/how long preguntan por experiencia o duración total.'),
    ('fase-5-for-since-ago', 'fase-5-perfecto-vs-pasado', 'contraste',
     'El marcador temporal es la pista más rápida para elegir el tiempo: ''for''/''since'' casi siempre acompañan presente perfecto, ''ago'' casi siempre pasado simple.'),
    ('fase-2-pronombres-sujeto-objeto', 'fase-2-to-be-afirmativo', 'combinacion',
     'Los pronombres sujeto (I/you/he...) son literalmente lo primero que necesitás para armar cualquier oración con el verbo ''to be'' -- se aprenden juntos por una razón.')
) AS x(subtema_a_slug, subtema_b_slug, tipo_relacion, texto_es)
JOIN gramatica_temas ta ON ta.slug = x.subtema_a_slug AND ta.parent_id IS NOT NULL
JOIN gramatica_temas tb ON tb.slug = x.subtema_b_slug AND tb.parent_id IS NOT NULL;
