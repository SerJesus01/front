<script setup>
import { computed, nextTick, onMounted, onUnmounted, ref } from 'vue';
import { useGrammarAudio } from '../../../composables/useGrammarAudio.js';

const emit = defineEmits(['salir', 'alimento']);
const { reproduciendoSecuencia, reproducirTexto, reiniciarAudio } = useGrammarAudio();

const banco = [
  { grupo: 'Familia + to be', icono: '👩‍👧', pista: 'Ella es mi hermana.', palabras: ['She', 'is', 'my', 'sister.'] },
  { grupo: 'Familia + to be', icono: '👨‍👦', pista: 'Él es mi padre.', palabras: ['He', 'is', 'my', 'father.'] },
  { grupo: 'Frutas + números', icono: '🍎🍎🍎', pista: 'Hay tres manzanas.', palabras: ['There', 'are', 'three', 'apples.'] },
  { grupo: 'Frutas + to be', icono: '🍌', pista: 'La banana es amarilla.', palabras: ['The', 'banana', 'is', 'yellow.'] },
  { grupo: 'Números + familia', icono: '👨‍👩‍👧‍👦', pista: 'Tengo dos hermanos.', palabras: ['I', 'have', 'two', 'brothers.'] },
  { grupo: 'Saludos', icono: '👋☀️', pista: 'Buenos días, abuela.', palabras: ['Good', 'morning,', 'Grandma.'] },
  { grupo: 'Hora + to be', icono: '🕒', pista: 'Son las tres en punto.', palabras: ['It', 'is', 'three', "o'clock."] },
  { grupo: 'Fecha + to be', icono: '📅', pista: 'Hoy es lunes.', palabras: ['Today', 'is', 'Monday.'] },
  { grupo: 'Pronombres + to be', icono: '🙋', pista: 'Yo soy estudiante.', palabras: ['I', 'am', 'a', 'student.'] },
  { grupo: 'Pregunta con to be', icono: '❓😊', pista: '¿Estás feliz?', palabras: ['Are', 'you', 'happy?'] },
];

const ronda = ref(0);
const disponibles = ref([]);
const respuesta = ref([]);
const vidas = ref(3);
const estado = ref('');
const racha = ref(0);
const ganadas = ref(0);
const arrastrando = ref(null);
const toqueInicio = ref(null);
const ejercicio = computed(() => banco[ronda.value % banco.length]);
const frase = computed(() => ejercicio.value.palabras.join(' '));
const progreso = computed(() => Math.round(((ronda.value + 1) / banco.length) * 100));

function barajar(palabras) {
  const fichas = palabras.map((texto, indice) => ({ id: `${ronda.value}-${indice}`, texto, orden: indice }));
  for (let i = fichas.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [fichas[i], fichas[j]] = [fichas[j], fichas[i]];
  }
  if (fichas.every((ficha, indice) => ficha.orden === indice) && fichas.length > 1) [fichas[0], fichas[1]] = [fichas[1], fichas[0]];
  fichas.forEach((ficha, indice) => { ficha.tecla = indice + 1; });
  disponibles.value = fichas;
}

function preparar() {
  respuesta.value = [];
  estado.value = '';
  arrastrando.value = null;
  barajar(ejercicio.value.palabras);
}

function agregar(id) {
  if (estado.value === 'correcto') return;
  const ficha = disponibles.value.find((item) => item.id === id);
  if (!ficha) return;
  disponibles.value = disponibles.value.filter((item) => item.id !== id);
  respuesta.value = [...respuesta.value, ficha];
  if (respuesta.value.length === ejercicio.value.palabras.length) nextTick(verificar);
}

function devolver(id) {
  if (estado.value === 'correcto') return;
  const ficha = respuesta.value.find((item) => item.id === id);
  if (!ficha) return;
  respuesta.value = respuesta.value.filter((item) => item.id !== id);
  disponibles.value = [...disponibles.value, ficha];
  estado.value = '';
}

async function verificar() {
  if (respuesta.value.length !== ejercicio.value.palabras.length) return;
  const correcta = respuesta.value.every((ficha, indice) => ficha.orden === indice);
  if (correcta) {
    estado.value = 'correcto';
    racha.value += 1;
    ganadas.value += 1;
    emit('alimento', 1);
    await reproducirTexto(frase.value);
  } else {
    estado.value = 'incorrecto';
    vidas.value -= 1;
    racha.value = 0;
    window.setTimeout(() => {
      respuesta.value = [];
      barajar(ejercicio.value.palabras);
      if (vidas.value <= 0) estado.value = 'agotado';
      else estado.value = '';
    }, 850);
  }
}

function siguiente() {
  if (ronda.value + 1 >= banco.length) ronda.value = 0;
  else ronda.value += 1;
  vidas.value = 3;
  reiniciarAudio();
  preparar();
}

function tecla(event) {
  if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) return;
  if (/^[1-9]$/.test(event.key)) {
    const ficha = disponibles.value.find((item) => item.tecla === Number(event.key));
    if (ficha) agregar(ficha.id);
  } else if (event.key === 'Backspace') {
    const ultima = respuesta.value.at(-1);
    if (ultima) devolver(ultima.id);
  }
}

function iniciarDrag(ficha, event) {
  arrastrando.value = ficha.id;
  event.dataTransfer?.setData('text/plain', ficha.id);
  if (event.dataTransfer) event.dataTransfer.effectAllowed = 'move';
}
function soltar(event) {
  const id = event.dataTransfer?.getData('text/plain') || arrastrando.value;
  if (id) agregar(id);
  arrastrando.value = null;
}
function iniciarToque(ficha, event) {
  const toque = event.touches?.[0];
  arrastrando.value = ficha.id;
  toqueInicio.value = toque ? { x: toque.clientX, y: toque.clientY } : null;
}
function terminarToque(event) {
  const toque = event.changedTouches?.[0];
  const destino = toque ? document.elementFromPoint(toque.clientX, toque.clientY)?.closest('[data-dropzone="answer"]') : null;
  const distancia = toque && toqueInicio.value
    ? Math.hypot(toque.clientX - toqueInicio.value.x, toque.clientY - toqueInicio.value.y)
    : Infinity;
  if ((destino || distancia < 12) && arrastrando.value) agregar(arrastrando.value);
  arrastrando.value = null;
  toqueInicio.value = null;
}

onMounted(() => { preparar(); window.addEventListener('keydown', tecla); });
onUnmounted(() => { window.removeEventListener('keydown', tecla); reiniciarAudio(); });
</script>

<template>
  <section class="sentence-game">
    <header class="sentence-game__header">
      <button class="sentence-game__back" @click="emit('salir')">← Centro de juegos</button>
      <span>BUILDING SENTENCES · {{ ronda + 1 }} DE {{ banco.length }}</span>
      <b>🔥 {{ racha }} · 🍎 {{ ganadas }}</b>
    </header>
    <div class="sentence-game__progress"><i :style="{ width: progreso + '%' }"></i></div>

    <div class="sentence-game__scene">
      <span>{{ ejercicio.icono }}</span>
      <div><small>{{ ejercicio.grupo }}</small><h2>Ordená la frase</h2><p>{{ ejercicio.pista }}</p></div>
      <button :disabled="reproduciendoSecuencia" @click="reproducirTexto(frase)">🔊 Escuchar</button>
    </div>

    <div class="sentence-game__instructions">
      <span>⌨️ Presioná el número</span><span>👆 Tocá una ficha</span><span>✋ O arrastrala al tablero</span>
    </div>

    <div
      class="sentence-game__answer"
      :class="{ correct: estado === 'correcto', wrong: estado === 'incorrecto' }"
      data-dropzone="answer"
      @dragover.prevent
      @drop.prevent="soltar"
    >
      <span v-if="respuesta.length === 0" class="sentence-game__placeholder">Soltá aquí la primera palabra…</span>
      <button v-for="(ficha, index) in respuesta" :key="ficha.id" @click="devolver(ficha.id)"><small>{{ index + 1 }}</small>{{ ficha.texto }}</button>
    </div>

    <div class="sentence-game__bank" data-dropzone="bank">
      <button
        v-for="(ficha, index) in disponibles"
        :key="ficha.id"
        draggable="true"
        :class="{ dragging: arrastrando === ficha.id }"
        @click="agregar(ficha.id)"
        @dragstart="iniciarDrag(ficha, $event)"
        @dragend="arrastrando = null"
        @touchstart.passive="iniciarToque(ficha, $event)"
        @touchend.prevent="terminarToque"
      ><small>{{ ficha.tecla }}</small><b>{{ ficha.texto }}</b></button>
    </div>

    <div class="sentence-game__meta"><span>{{ '❤️'.repeat(vidas) }}{{ '♡'.repeat(3 - vidas) }}</span><span>⌫ deshace la última ficha</span></div>
    <p v-if="estado === 'correcto'" class="sentence-game__feedback ok">✓ ¡Frase construida! El Gusanito ganó una manzana.</p>
    <p v-else-if="estado === 'incorrecto'" class="sentence-game__feedback retry">↻ El orden todavía no encaja. Las fichas volverán a mezclarse.</p>
    <p v-else-if="estado === 'agotado'" class="sentence-game__feedback retry">💡 Escuchá la frase y volvé a intentarlo sin prisa.</p>

    <footer>
      <button v-if="estado !== 'agotado'" class="secondary" @click="preparar">Mezclar de nuevo</button>
      <button v-if="estado === 'correcto' || estado === 'agotado'" class="primary" @click="siguiente">Siguiente frase →</button>
      <button v-else class="primary" :disabled="respuesta.length !== ejercicio.palabras.length" @click="verificar">Comprobar</button>
    </footer>
  </section>
</template>

<style scoped>
.sentence-game{padding:1.2rem;border:1px solid var(--color-borde);border-radius:20px;background:#fff;box-shadow:var(--sombra-card)}.sentence-game__header{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.7rem}.sentence-game__header>span{font-size:.67rem;font-weight:900;letter-spacing:.08em;color:var(--color-verde)}.sentence-game__header>b{text-align:right;color:#9b641b}.sentence-game__back{border:0;background:none;color:var(--color-azul);text-align:left}.sentence-game__progress{height:7px;margin:.7rem 0 1rem;border-radius:99px;background:#e8eee9;overflow:hidden}.sentence-game__progress i{display:block;height:100%;border-radius:99px;background:#f5af45;transition:.3s}.sentence-game__scene{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:1rem;padding:1rem;border-radius:16px;background:linear-gradient(135deg,#e9f7ef,#fff4d9)}.sentence-game__scene>span{font-size:3rem}.sentence-game__scene small{font-size:.65rem;font-weight:900;letter-spacing:.07em;color:var(--color-verde)}.sentence-game__scene h2,.sentence-game__scene p{margin:.15rem 0}.sentence-game__scene button{padding:.55rem .7rem;border:0;border-radius:9px;background:var(--color-verde);color:#fff}.sentence-game__instructions{display:flex;justify-content:center;gap:1rem;padding:.7rem;font-size:.72rem;color:var(--color-texto-tenue)}.sentence-game__answer{display:flex;flex-wrap:wrap;align-items:center;justify-content:center;gap:.5rem;min-height:90px;padding:1rem;border:2px dashed #92b5a0;border-radius:16px;background:#f8fcf9;transition:.2s}.sentence-game__answer.correct{border-style:solid;border-color:var(--color-verde);background:var(--color-verde-suave)}.sentence-game__answer.wrong{border-color:#d56b4e;background:#fff2ec;animation:shake .25s}.sentence-game__placeholder{color:#809088}.sentence-game__answer button,.sentence-game__bank button{position:relative;min-width:90px;padding:.75rem .7rem;border:1px solid #b8c9be;border-radius:11px;background:#fff;box-shadow:0 3px 0 #dce7df;font-weight:800}.sentence-game__answer button small,.sentence-game__bank button small{position:absolute;top:-7px;left:-7px;display:grid;place-items:center;width:21px;height:21px;border-radius:50%;background:#174435;color:#fff;font-size:.65rem}.sentence-game__bank{display:flex;flex-wrap:wrap;justify-content:center;gap:.65rem;min-height:75px;padding:1.2rem .5rem}.sentence-game__bank button{cursor:grab;touch-action:none}.sentence-game__bank button:active{cursor:grabbing}.sentence-game__bank button.dragging{opacity:.45;transform:scale(.96)}.sentence-game__meta{display:flex;justify-content:space-between;padding:.65rem .9rem;border-radius:10px;background:#fff9e9;font-size:.75rem}.sentence-game__feedback{padding:.7rem;border-radius:10px;text-align:center;font-weight:800}.sentence-game__feedback.ok{background:var(--color-verde-suave);color:var(--color-verde)}.sentence-game__feedback.retry{background:#fff0e8;color:#aa4f27}.sentence-game footer{display:flex;justify-content:center;gap:.7rem;margin-top:1rem}.sentence-game footer button{min-width:170px;padding:.75rem;border-radius:var(--radio-boton);font-weight:800}.primary{border:0;background:var(--color-azul);color:#fff}.primary:disabled{opacity:.45}.secondary{border:1px solid var(--color-borde);background:#fff}@keyframes shake{25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}
@media(max-width:650px){.sentence-game{padding:.8rem}.sentence-game__header{grid-template-columns:1fr auto}.sentence-game__header>span{grid-row:2;grid-column:1/-1}.sentence-game__scene{grid-template-columns:auto 1fr}.sentence-game__scene button{grid-column:1/-1}.sentence-game__instructions{display:grid;grid-template-columns:1fr 1fr;gap:.35rem}.sentence-game__answer{min-height:115px}.sentence-game__answer button,.sentence-game__bank button{min-width:76px;padding:.7rem .55rem}.sentence-game footer{flex-direction:column}.sentence-game footer button{width:100%}}
</style>
