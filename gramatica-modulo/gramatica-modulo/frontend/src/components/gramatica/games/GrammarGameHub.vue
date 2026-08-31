<script setup>
import { computed, onMounted, ref } from 'vue';
import { useGrammarAudio } from '../../../composables/useGrammarAudio.js';
import { gramaticaApi } from '../../../services/gramaticaApi.js';
import BuildingSentencesGame from './BuildingSentencesGame.vue';
import GrammarSortGame from './GrammarSortGame.vue';

const props = defineProps({
  evolucion: {
    type: Object,
    default: null,
  },
});

const emit = defineEmits(['volver', 'abrir-caminos']);

const { reproduciendoSecuencia, reproducirSecuencia, reiniciarAudio } = useGrammarAudio();
const pantalla = ref('hub');
const puzzles = ref([]);
const indice = ref(0);
const respuesta = ref('');
const intentos = ref(3);
const alimentoGanado = ref(0);
const estado = ref('');
const cargando = ref(false);
const inputPuzzle = ref(null);

const puzzle = computed(() => puzzles.value[indice.value] || null);
const casillas = computed(() => {
  const longitud = puzzle.value?.longitud || 0;
  return Array.from({ length: longitud }, (_, index) => respuesta.value[index]?.toUpperCase() || '');
});
const energia = computed(() => Math.min(100, (props.evolucion?.pct_dominado || 0) + alimentoGanado.value * 5));

async function cargarJuego() {
  cargando.value = true; estado.value = '';
  try { puzzles.value = await gramaticaApi.obtenerBuildingWords(); pantalla.value = 'juego'; setTimeout(() => inputPuzzle.value?.focus(), 0); }
  catch { estado.value = 'No se pudo cargar el juego.'; }
  finally { cargando.value = false; }
}

function escribir(event) {
  if (!puzzle.value || estado.value === 'correcto') return;
  respuesta.value = event.target.value.replace(/[^a-zA-Z]/g, '').slice(0, puzzle.value.longitud);
}

async function comprobar() {
  if (!puzzle.value || respuesta.value.length !== puzzle.value.longitud) return;
  try {
    const data = await gramaticaApi.evaluarEjercicio({ ejercicio_id: puzzle.value.id, respuesta_usuario: respuesta.value.toLowerCase(), confianza: 'creo', tiempo_respuesta_ms: 5000 });
    if (data.correcto) { estado.value = 'correcto'; alimentoGanado.value += puzzle.value.alimento || 1; }
    else { intentos.value -= 1; estado.value = intentos.value <= 0 ? 'agotado' : 'incorrecto'; respuesta.value = ''; setTimeout(() => inputPuzzle.value?.focus(), 0); }
  } catch { estado.value = 'error'; }
}

function siguiente() {
  if (indice.value + 1 >= puzzles.value.length) {
    pantalla.value = 'hub';
    indice.value = 0;
  } else {
    indice.value += 1;
  }
  respuesta.value = '';
  intentos.value = 3;
  estado.value = '';
  reiniciarAudio();
  setTimeout(() => inputPuzzle.value?.focus(), 0);
}

function abrirBuildingSentences() {
  pantalla.value = 'frases';
  estado.value = '';
  reiniciarAudio();
}

function abrirGrammarSort() {
  pantalla.value = 'portales';
  estado.value = '';
  reiniciarAudio();
}

onMounted(() => reiniciarAudio());
</script>

<template>
  <section class="pet-games">
    <button class="pet-games__back" @click="emit('volver')">← Gramática</button>

    <div class="pet-games__pet-card">
      <div class="pet-games__worm" :class="{ 'pet-games__worm--happy': estado === 'correcto' }" aria-label="Mascota Gusanito">
        <span>🐛</span>
        <i v-if="estado === 'correcto'">🍎</i>
      </div>
      <div class="pet-games__pet-info">
        <span class="pet-games__eyebrow">TU COMPAÑERO DE PRÁCTICA</span>
        <h1>Alimenta al Gusanito</h1>
        <p>Cada palabra construida le da alimento y lo ayuda a crecer.</p>
        <div class="pet-games__energy"><i :style="{ width: energia + '%' }"></i></div>
        <small>{{ energia }}% de energía · {{ alimentoGanado }} alimentos ganados hoy</small>
      </div>
    </div>

    <template v-if="pantalla === 'hub'">
      <header class="pet-games__heading">
        <div><span class="pet-games__eyebrow">CENTRO DE JUEGOS</span><h2>¿Qué querés practicar?</h2></div>
      </header>
      <div class="pet-games__catalog">
        <button class="pet-games__game-card pet-games__game-card--active" :disabled="cargando" @click="cargarJuego">
          <span class="pet-games__game-icon">Ab</span>
          <span><strong>Building Words</strong><small>Escuchá el deletreo y construí la palabra.</small></span>
          <b>{{ cargando ? 'Cargando…' : 'Jugar →' }}</b>
        </button>
        <button class="pet-games__game-card pet-games__game-card--active" @click="abrirBuildingSentences">
          <span class="pet-games__game-icon">1·4</span>
          <span><strong>Building Sentences</strong><small>Ordená vocabulario conocido con números, toque o arrastre.</small></span>
          <b>Jugar →</b>
        </button>
        <button class="pet-games__game-card pet-games__game-card--active" @click="abrirGrammarSort">
          <span class="pet-games__game-icon">1→4</span>
          <span><strong>Grammar Sort</strong><small>Mandá cada frase al portal correcto con teclas, toque o arrastre.</small></span>
          <b>Jugar →</b>
        </button>
        <button class="pet-games__game-card" @click="emit('abrir-caminos')">
          <span class="pet-games__game-icon">🐾</span>
          <span><strong>Caminos de gramática</strong><small>Practicá por fases y alcanzá la meta.</small></span>
          <b>Abrir →</b>
        </button>
      </div>
      <p v-if="estado" class="pet-games__message">{{ estado }}</p>
    </template>

    <BuildingSentencesGame
      v-else-if="pantalla === 'frases'"
      @salir="pantalla = 'hub'"
      @alimento="alimentoGanado += $event"
    />

    <GrammarSortGame
      v-else-if="pantalla === 'portales'"
      @salir="pantalla = 'hub'"
      @alimento="alimentoGanado += $event"
    />

    <template v-else-if="pantalla === 'juego' && puzzle">
      <div class="word-game">
        <header class="word-game__header">
          <div><span class="pet-games__eyebrow">BUILDING WORDS · {{ indice + 1 }} DE {{ puzzles.length }}</span><h2>Construí la palabra</h2></div>
          <span class="word-game__food">+{{ puzzle.alimento || 1 }} 🍎</span>
        </header>
        <div class="word-game__progress"><i :style="{ width: ((indice + 1) / puzzles.length * 100) + '%' }"></i></div>

        <button class="word-game__listen" :disabled="reproduciendoSecuencia" @click="reproducirSecuencia(puzzle)">
          {{ reproduciendoSecuencia ? '🔊 Reproduciendo…' : '▶ Escuchar deletreo' }}
        </button>
        <p>Escuchá las letras y escribí la palabra completa.</p>

        <div class="word-game__slots" @click="inputPuzzle?.focus()">
          <span v-for="(_, index) in casillas" :key="index" :class="{ filled: casillas[index] }">{{ casillas[index] }}</span>
        </div>
        <input
          ref="inputPuzzle"
          class="word-game__hidden-input"
          :value="respuesta"
          :disabled="estado === 'correcto' || estado === 'agotado'"
          :aria-label="`Escribir palabra de ${puzzle.longitud} letras`"
          autocomplete="off"
          @input="escribir"
          @keyup.enter="comprobar"
        />

        <div class="word-game__meta">
          <span>💡 {{ puzzle.pista }}</span>
          <span>{{ '❤️'.repeat(intentos) }}{{ '♡'.repeat(3 - intentos) }}</span>
        </div>

        <div v-if="estado === 'correcto'" class="word-game__feedback word-game__feedback--ok">¡Excelente! Alimentaste al Gusanito.</div>
        <div v-else-if="estado === 'incorrecto'" class="word-game__feedback word-game__feedback--wrong">Casi. Escuchá otra vez y probá sin prisa.</div>
        <div v-else-if="estado === 'agotado'" class="word-game__feedback word-game__feedback--wrong">Se terminaron los intentos. Pasemos a otra palabra.</div>
        <div v-else-if="estado === 'error'" class="word-game__feedback word-game__feedback--wrong">No se pudo evaluar la respuesta.</div>

        <div class="word-game__actions">
          <button class="word-game__secondary" @click="pantalla = 'hub'; reiniciarAudio()">Salir</button>
          <button v-if="estado === 'correcto' || estado === 'agotado'" class="word-game__primary" @click="siguiente">Siguiente palabra →</button>
          <button v-else class="word-game__primary" :disabled="respuesta.length !== puzzle.longitud" @click="comprobar">Comprobar</button>
        </div>
      </div>
    </template>
  </section>
</template>

<style scoped>
.pet-games{max-width:850px;margin:auto}.pet-games__back{border:0;background:none;color:var(--color-azul);cursor:pointer}.pet-games__pet-card{display:flex;align-items:center;gap:1.5rem;margin:1rem 0;padding:1.4rem;border-radius:22px;background:linear-gradient(135deg,#174435,#267659);color:white}.pet-games__worm{position:relative;display:grid;place-items:center;width:120px;height:120px;border-radius:50%;background:#fff4d3;font-size:4.7rem;transition:.25s}.pet-games__worm--happy{transform:rotate(-6deg) scale(1.06)}.pet-games__worm i{position:absolute;right:-8px;top:3px;font-style:normal;font-size:2rem}.pet-games__pet-info{flex:1}.pet-games__eyebrow{font-size:.67rem;font-weight:800;letter-spacing:.09em;color:#58c98b}.pet-games__pet-card .pet-games__eyebrow{color:#a8e3c2}.pet-games__pet-info h1{margin:.2rem 0}.pet-games__pet-info p{margin:.3rem 0 .8rem;font-size:.84rem}.pet-games__energy{height:9px;border-radius:99px;background:#ffffff36;overflow:hidden}.pet-games__energy i,.word-game__progress i{display:block;height:100%;border-radius:99px;background:#f5af45;transition:.3s}.pet-games__pet-info small{display:block;margin-top:.4rem;color:#cdebd9}.pet-games__heading h2{margin:.25rem 0 1rem}.pet-games__catalog{display:grid;grid-template-columns:repeat(2,1fr);gap:.8rem}.pet-games__game-card{display:grid;grid-template-columns:50px 1fr auto;align-items:center;gap:.8rem;border:1px solid var(--color-borde);border-radius:17px;background:white;padding:1rem;text-align:left}.pet-games__game-card--active{border-color:#63bd89;box-shadow:0 6px 20px #17443512;cursor:pointer}.pet-games__game-card--locked{opacity:.55}.pet-games__game-icon{display:grid;place-items:center;width:48px;height:48px;border-radius:14px;background:var(--color-verde-suave);font-weight:900;color:var(--color-verde)}.pet-games__game-card span:nth-child(2){display:flex;flex-direction:column}.pet-games__game-card small{margin-top:.2rem;color:var(--color-texto-tenue)}.pet-games__game-card b{font-size:.75rem;color:var(--color-azul)}.word-game{padding:1.3rem;border:1px solid var(--color-borde);border-radius:20px;background:white;box-shadow:var(--sombra-card)}.word-game__header{display:flex;justify-content:space-between;align-items:center}.word-game__header h2{margin:.2rem 0}.word-game__food{padding:.45rem .7rem;border-radius:99px;background:#fff3d8;color:#9b641b;font-weight:800}.word-game__progress{height:7px;margin:.7rem 0 1.4rem;border-radius:99px;background:#e8eee9;overflow:hidden}.word-game__listen{display:block;width:115px;height:115px;margin:auto;border:9px solid #dff2e6;border-radius:50%;background:var(--color-verde);color:white;font-weight:800}.word-game>p{text-align:center;color:var(--color-texto-tenue);font-size:.8rem}.word-game__slots{display:flex;justify-content:center;gap:.45rem;margin:1.3rem 0}.word-game__slots span{display:grid;place-items:center;width:42px;height:50px;border-bottom:3px solid #9daaa2;font-size:1.4rem;font-weight:900}.word-game__slots span.filled{border-color:var(--color-verde);color:var(--color-verde)}.word-game__hidden-input{position:absolute;left:-9999px}.word-game__meta{display:flex;justify-content:space-between;margin:auto;max-width:580px;padding:.7rem 1rem;border-radius:12px;background:#fff9e9;font-size:.8rem}.word-game__feedback{max-width:580px;margin:.8rem auto;padding:.7rem;border-radius:10px;text-align:center;font-weight:700}.word-game__feedback--ok{background:var(--color-verde-suave);color:var(--color-verde)}.word-game__feedback--wrong{background:#fff0e8;color:#aa4f27}.word-game__actions{display:flex;justify-content:center;gap:.7rem;margin-top:1rem}.word-game__primary,.word-game__secondary{min-width:170px;padding:.75rem;border-radius:var(--radio-boton);font-weight:800}.word-game__primary{border:0;background:var(--color-azul);color:white}.word-game__primary:disabled{opacity:.45}.word-game__secondary{border:1px solid var(--color-borde);background:white}@media(max-width:650px){.pet-games__pet-card{align-items:flex-start}.pet-games__worm{width:82px;height:82px;font-size:3.1rem}.pet-games__catalog{grid-template-columns:1fr}.word-game__slots{gap:.2rem}.word-game__slots span{width:30px}.word-game__actions{flex-direction:column}.word-game__primary,.word-game__secondary{width:100%}}
</style>
