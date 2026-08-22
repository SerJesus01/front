# Prompts de imágenes pendientes de generar

Vas corriendo estos con Nano Banana (o el generador que uses) cuando
tengas un rato, guardás el resultado en este mismo directorio como
`{imagen_key}.png` o `.webp`, y avisame -- yo hago el wiring (migración +
UPDATE de `imagen_key` en el contenido correspondiente).

**Regla de simplicidad** (corregido el 04/ago/2026 -- la primera versión
de estos prompts tenía demasiados elementos por escena, difícil de
generar bien y de leer de un vistazo): máximo 2-3 objetos por imagen, una
sola relación/concepto por escena. Si un subtema necesita ilustrar dos
relaciones distintas (ej. "on/in front of" y "between"), son DOS
imágenes simples, no una sola imagen cargada.

## Prefijo de estilo (repetir siempre, para que todas las escenas se vean consistentes)

```
Flat vector illustration, isometric perspective, minimalist clean lines,
soft pastel color palette (blues, grays, one warm accent color),
no text or labels anywhere in the image, no photorealistic detail,
consistent with modern educational app illustrations. Square 1:1 aspect ratio.
```

## Pendientes

### 1. `escena_escritorio_lugar` -- Fase 17, preposiciones de lugar (on / in front of)

Reemplaza a la versión anterior de `escena_oficina_prep_lugar` (tenía
también una sala de reuniones, cocina y ascensor de fondo -- de más).
Solo 2 objetos:

```
[prefijo de estilo] +

A desk viewed from a slightly elevated angle. A keyboard sits on top of
the desk, positioned directly in front of a computer monitor placed
further back on the same desk. Nothing else in the scene.
```

Va con: "The keyboard is on the desk, in front of the monitor."

### 2. `escena_puertas_entre` -- Fase 17, preposiciones de lugar (between)

Segunda imagen para el mismo subtema (antes estaba mezclada con la de
arriba). Solo 3 objetos:

```
[prefijo de estilo] +

Three identical plain doors in a row along a hallway wall, viewed
head-on. The middle door is centered directly between the other two.
Nothing else in the scene.
```

Va con: "The middle room is between the other two."

### 3. `escena_lampara_libros` -- Fase 9, there is / there are

Solo 2 objetos, cantidad clara de un vistazo (uno vs. varios):

```
[prefijo de estilo] +

A single small lamp on the left. On the right, two books stacked on top
of each other. Both sit on a plain flat surface, otherwise empty
background.
```

Va con: "There is a lamp. There are two books."

### 4. `escena_brazo_telefono` -- Fase 6, voz pasiva (presente y pasado)

El énfasis visual está en la ACCIÓN que recibe el objeto, no en quién la
hace -- justo la idea central de la voz pasiva. Personaje asociado: Sam
(tech), ya vinculado por voz a este subtema. Solo 2 elementos:

```
[prefijo de estilo] +

A robotic arm lowering a single component onto a smartphone resting on a
plain flat surface. Nothing else in the scene, empty background.
```

Va con: "The phone is assembled by the robot."

### 5. `escena_puente_temporal` -- Fase 5, presente perfecto (intro y vs. pasado simple)

El ícono de anclaje ya usado en el frontend para esta familia es 🌉
(puente) -- esta escena lo hace literal. Solo 2 elementos (el puente
mismo cuenta como uno):

```
[prefijo de estilo] +

A simple stone bridge connects two plain riverbanks. The left bank is
rendered in cool, muted blue-gray tones. The right bank is rendered in
warm, vivid tones. No people, no trees, no other objects.
```

Va con la idea de que el presente perfecto conecta el pasado (orilla
fría) con el presente (orilla cálida).

### 6. `escena_candado_regla` -- Fase 8, must / have to

Distingue obligación interna (must, propia) de obligación externa (have
to, impuesta) -- calza con el ícono 🔒 ya usado en el frontend. Sin
personas, sin escenas divididas: solo 2 candados, contraste directo:

```
[prefijo de estilo] +

Two padlocks side by side on a plain background. The left padlock is
small and simple, attached to a small personal notebook. The right
padlock is large and heavy-duty, attached to a tall metal gate. Nothing
else in the scene.
```

Va con: "I must finish this (my own decision)." / "I have to wear a
uniform (an external rule)."

### 7. `escena_manzanas_agua` -- Fase 13, contables / incontables

Calza con el ícono 🖐️ ya usado en el frontend. Un solo par de objetos,
no una alacena completa:

```
[prefijo de estilo] +

On the left, three individual apples, each clearly separate. On the
right, a jug of water shown as a single continuous liquid with no
visible units. Both on a plain flat surface, otherwise empty background.
```

Va con: "three apples" (contable) vs. "some water" (incontable).

### 8. `escena_edificios_comparacion` -- Fase 15, comparativos y superlativos

Tres edificios de altura creciente -- ya era simple (3 objetos, 1 idea),
se mantiene igual, solo se recorta el detalle de fondo:

```
[prefijo de estilo] +

Three simple buildings side by side on a plain flat surface, viewed
head-on. The one on the left is short. The one in the middle is taller.
The one on the right is the tallest. No sky detail, no clouds, no other
objects.
```

Va con: "taller than" (comparativo) / "the tallest" (superlativo).

### 9. `escena_bifurcacion_condicional` -- Fase 16, condicionales con if

Un cartel en una bifurcación -- se saca la figura caminando, queda solo
el cartel y los dos caminos:

```
[prefijo de estilo] +

A single path splits into two directions at a wooden signpost. The left
path leads toward a small sunny area. The right path leads toward a
small rainy area under one gray cloud. No people, no other objects.
```

Va con: "If it rains, I will stay home."

### 10. `escena_tunel_camino` -- Fase 17, preposiciones de dirección

Antes tenía 5 tramos distintos (túnel, puente, río, campo, bosque) en
una sola imagen -- se recorta a un solo tramo, una sola preposición:

```
[prefijo de estilo] +

A single path entering the dark entrance of a small tunnel through a
hill, viewed from a slightly elevated angle. Nothing else in the scene.
```

Va con: "The path goes into the tunnel." (si más adelante se quiere
ilustrar "through", "across", "over" por separado, son imágenes propias
igual de simples, no la misma escena recargada).

### 11. `escena_persona_trotando` -- Fase 3, presente simple (rutinas)

Antes era un tríptico de 3 viñetas -- se recorta a una sola escena,
personaje asociado: Ana (parque), ya vinculada por voz a este subtema:

```
[prefijo de estilo] +

A single person jogging along a path in a park, viewed from the side.
Soft morning light. Nothing else in the scene.
```

Va con: "She jogs in the park every morning." (rutina, no una acción en
curso -- para eso ya existe contraste textual con presente continuo, no
hace falta que la imagen cargue las dos ideas a la vez).

### 12. `escena_gato_mesa` -- Fase 9, ubicación básica (under)

De la ronda de contenido nuevo del 04/ago/2026 (migración 070, ver
memoria del proyecto) que diferenció Fase 9 de Fase 17. Solo 2 objetos:

```
[prefijo de estilo] +

A cat curled up underneath a small table, viewed from the side. Nothing
else in the scene.
```

Va con: "The cat is under the table."

### 13. `escena_llaves_cajon` -- Fase 9, ubicación básica (in)

```
[prefijo de estilo] +

A single open drawer with a few keys resting inside it, viewed from a
slightly elevated angle. Nothing else in the scene.
```

Va con: "The keys are in the drawer."

### 14. `escena_cuadro_sofa` -- Fase 9, ubicación básica (above)

```
[prefijo de estilo] +

A single framed picture hanging on a plain wall, positioned directly
above a sofa placed against that wall. Nothing else in the scene.
```

Va con: "The picture is above the sofa."

### 15. `escena_farmacia_banco` -- Fase 17, preposiciones de lugar (across from)

Dos edificios simples enfrentados por una calle -- para distinguirla
visualmente de la 17 (opposite, más abajo) uso un rasgo arquitectónico
distinto en cada par de edificios (nunca texto/símbolos):

```
[prefijo de estilo] +

Two small buildings facing each other across a narrow street, viewed
head-on. The building on the left has a simple striped awning over its
entrance. The building on the right has a few steps leading up to columns
at its entrance. Nothing else in the scene.
```

Va con: "The pharmacy is across from the bank."

### 16. `escena_cojin_almohadas` -- Fase 17, preposiciones de lugar (among)

```
[prefijo de estilo] +

A single round cushion surrounded by several square pillows, all
clustered together on a plain sofa. Nothing else in the scene.
```

Va con: "The cushion is among the pillows on the sofa."

### 17. `escena_gimnasio_super` -- Fase 17, preposiciones de lugar (opposite)

Mismo patrón compositivo que `escena_farmacia_banco` (dos edificios
enfrentados por una calle) pero con rasgos arquitectónicos distintos,
para que ambas imágenes no se vean intercambiables:

```
[prefijo de estilo] +

Two small buildings facing each other across a narrow street, viewed
head-on. The building on the left has large front windows with simple
exercise equipment silhouettes visible inside. The building on the right
has a covered entrance with a shopping cart parked outside. Nothing else
in the scene.
```

Va con: "The gym is opposite the supermarket."

### 18. `escena_saludo_oficina` -- Fase 1, Saludos

```
[prefijo de estilo] +

Two coworkers waving at each other in a simple office setting, soft
morning light. Nothing else in the scene.
```

Va con: "Good morning! How are you?"

### 19. `escena_despedida_oficina` -- Fase 1, Despedidas

Mismo entorno de oficina que la de saludos, pero con luz e idea
opuesta (alguien yéndose, no llegando) para que se puedan comparar
entre sí:

```
[prefijo de estilo] +

A single person waving goodbye while walking out through an office
doorway, soft evening light. Nothing else in the scene.
```

Va con: "Bye! See you tomorrow."

### 20. `escena_familia_playa` -- Fase 1, Familia (coloquial)

```
[prefijo de estilo] +

Two simple elderly figures (a grandmother and a grandfather) standing
in front of a small beach house, with the ocean visible behind them.
Nothing else in the scene.
```

Va con: "My grandma and grandpa live near the beach."

### 21. `escena_frutero` -- Fase 1, Frutas

Excepción a la regla de 2-3 objetos: acá el propósito es distinto (no
un concepto gramatical con una sola relación, sino reconocimiento de
vocabulario) -- varias frutas juntas en un frutero, para asociar cada
nombre con su forma real de un vistazo:

```
[prefijo de estilo] +

A woven fruit basket sitting on a table, containing a few whole fruits:
an apple, a banana, and an orange. Nothing else in the scene.
```

Va con: "Can I get an apple and a banana, please?"

### 22. `escena_taxi_calle` -- Fase 1, Abreviaturas ("cab")

```
[prefijo de estilo] +

A single yellow cab parked on a city street, viewed from the side.
Nothing else in the scene.
```

Va con: "Can you call me a cab?"
