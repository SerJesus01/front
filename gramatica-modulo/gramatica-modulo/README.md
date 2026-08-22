# Gramática — módulo extraído

Extracción del módulo de Gramática del repo `pronunciation-scorer` (score) a
un repo aparte, para poder ver y trabajar el contenido sin el resto de la
app. Copiado desde `/home/orangepi/pronunciation-scorer` el 2026-08-22
(rama `feature/stripe-elements-modal`, HEAD incluye ya toda la rama
`worktree-gramatica-modulo`, 47 commits del módulo).

**Este repo NO funciona como app completa.** El frontend se puede levantar
solo (ver abajo) para ver la UI, pero sus llamadas a `/gramatica/*` van a
fallar porque no hay backend real corriendo. El backend se copió como
referencia de código y no es ejecutable tal cual (ver sección Backend).

## Qué es "Gramática" en score

Studentbook (reglas + ejemplos, con audio real pregenerado y algunas
imágenes) + workbook (ejercicios cloze/multiple-choice/detectar-error
evaluados de forma determinista, sin LLM salvo la autoexplicación
opt-in al cerrar un subtema). Organizado en Fases → Subtemas. Incluye
además "El Gusanito" (mascota/gamificación que evoluciona con el
% dominado) y un Motor de Memoria estilo Leitner para el repaso espaciado.

Ver también la memoria del proyecto original:
`project_gramatica_score.md` y `project_gusanito_gamificacion.md`.

## Frontend (funciona standalone)

`frontend/` es un mini-proyecto Vite + Vue 3 que monta directamente
`GramaticaView.vue` — el componente real de score, copiado tal cual
(2100 líneas, autocontenido: solo importa `vue`, sin router ni
composables externos). Trae también `styles/tokens.css` y
`styles/base.css` para que se vea con los mismos colores/tipografía.

```
cd frontend
npm install
npm run dev
```

Al abrir la URL que imprime Vite vas a ver la pantalla de Fases, pero
vacía / en estado de error, porque los `fetch` a `/gramatica/fases`,
`/gramatica/audio/...`, etc. no tienen backend que responda. Para verlo
con datos reales hay dos caminos:
- Mockear las respuestas de esos endpoints (interceptando `fetch` o con
  un servidor mock) usando como referencia los shapes de
  `backend/routers/gramatica.py`.
- Levantar el backend real de `pronunciation-scorer` (ver abajo).

## Backend (referencia, no ejecutable standalone)

- `backend/routers/gramatica.py` — todos los endpoints `/gramatica/*`:
  `GET /fases`, `GET /fases/{slug}/subtemas`,
  `GET /subtemas/{slug}/contenido`, `GET /audio/{audio_key}`,
  `GET /imagen/{imagen_key}`, `GET /subtemas/{slug}/ejercicios`,
  `POST /ejercicios/evaluar`, `GET /repaso`, `POST /subtemas/completar`,
  `POST /subtemas/{slug}/autoexplicacion`, `GET /relaciones`,
  `GET /relaciones/{id}/ejercicios`, `GET /gusanito/evolucion`,
  `GET /gusanito/{fase_slug}`.
- `backend/gramatica/autoexplicacion.py` — arma el prompt y llama al LLM
  para la autoexplicación al cerrar un subtema (refuerzo positivo, sin
  "te falta").
- `backend/migrations/` — las 44 migraciones SQL que crean el schema y
  siembran todo el contenido (Fases, subtemas, reglas, ejemplos,
  ejercicios, relaciones/cruces, studentbook dinámico, Motor de Memoria,
  personaje/voz, imágenes).
- `backend/imagenes_gramatica/` — la única imagen real generada hasta
  ahora (escritorio/preposiciones de lugar) + `PROMPTS_PENDIENTES.md`
  con los prompts de escena para el resto de las Fases.

Lo que **falta** para que esto corra solo (no se copió, porque es
compartido con el resto de score y traerlo íntegro hubiera sido
duplicar casi todo el repo): `auth/`, `dependencies.py`,
`gamificacion.py`, `motor_memoria.py`, `llm/`, la conexión a Postgres, y
`scripts/generar_audio_gramatica.py` (genera el audio real que sirve
`GET /audio/{audio_key}`). Para correrlo de verdad, lo más simple es
usar el repo original.

## Repo original

`/home/orangepi/pronunciation-scorer` (GitLab:
`couper/pronunciation-scorer`). El trabajo de Gramática vive repartido
en 47 commits (ver `git log --oneline -- gramatica/ routers/gramatica.py
migrations/*gramatica*` ahí) que ya están incluidos en la rama que se
usó como fuente para esta extracción.
