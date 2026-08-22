# Escenas curadas de Gramática

Imágenes pregeneradas offline (curadas a mano o creadas con una
herramienta de imagen como paso de autoría de contenido) para el
StudentBook de Gramática -- referenciadas por `gramatica_contenido.imagen_key`
y servidas tal cual por `GET /gramatica/imagen/{imagen_key}` (ver
`routers/gramatica.py`), nunca generadas en el camino de request.

Convención de nombre de archivo: `{imagen_key}.png` o `{imagen_key}.webp`
(el endpoint prueba `.webp` primero, después `.png`). `imagen_key` solo
puede tener letras/números/guiones (ver `_CLAVE_ARCHIVO_VALIDA`).

Este directorio se copia tal cual a la imagen Docker (`COPY
imagenes_gramatica/ imagenes_gramatica/` en el `Dockerfile`) -- a
diferencia de `CACHE_TTS_DIR`, este es arte original versionado en el
repo, no contenido regenerable por hash.

Pendiente: generar `escena_oficina_prep_lugar.{png,webp}` (preposiciones
de lugar, Fase 17) -- prompt ya consensuado con el dueño, ver la memoria
del proyecto.
