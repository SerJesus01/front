<script setup>
import { computed, onUnmounted, ref } from 'vue';
import { useGrammarAudio } from '../../../composables/useGrammarAudio.js';

const emit = defineEmits(['salir', 'alimento']);
const { reproducirTexto, reiniciarAudio } = useGrammarAudio();

const retos = [
  { icono: '💪', frase: 'She can draws very well.', error: 'draws', opciones: ['draw', 'drawing', 'draws'], correcta: 'draw', explicacion: 'Después de can usamos el verbo base: can draw.' },
  { icono: '📚', frase: 'There is three books on the table.', error: 'is', opciones: ['are', 'has', 'is'], correcta: 'are', explicacion: 'Three books es plural: usamos there are.' },
  { icono: '📅', frase: 'I have visited the museum yesterday.', error: 'have visited', opciones: ['visited', 'visit', 'was visiting'], correcta: 'visited', explicacion: 'Yesterday es un tiempo pasado terminado: usamos pasado simple.' },
  { icono: '🍎', frase: 'Do we have some apples?', error: 'some', opciones: ['any', 'much', 'an'], correcta: 'any', explicacion: 'En una pregunta general usamos normalmente any.' },
  { icono: '⏰', frase: 'The class begins in nine o’clock.', error: 'in', opciones: ['at', 'on', 'during'], correcta: 'at', explicacion: 'Usamos at con una hora exacta.' },
  { icono: '🌱', frase: 'This plant is more small than that one.', error: 'more small', opciones: ['smaller', 'smallest', 'less small'], correcta: 'smaller', explicacion: 'Con un adjetivo corto usamos -er: smaller than.' },
  { icono: '🗣️', frase: 'Could you tell me where is the library?', error: 'is the library', opciones: ['the library is', 'does the library', 'the library does'], correcta: 'the library is', explicacion: 'La pregunta indirecta conserva el orden afirmativo.' },
  { icono: '🌍', frase: 'If we will reuse paper, we protect trees.', error: 'will reuse', opciones: ['reuse', 'reused', 'are reusing'], correcta: 'reuse', explicacion: 'En esta condición usamos presente simple después de if.' },
];

const indice = ref(0);
const seleccion = ref('');
const estado = ref('');
const reparadas = ref(0);
const intentos = ref(0);
const terminado = computed(() => indice.value >= retos.length);
const reto = computed(() => retos[indice.value] || null);
const progreso = computed(() => Math.round((Math.min(indice.value, retos.length) / retos.length) * 100));
const partes = computed(() => reto.value?.frase.split(reto.value.error) || []);
const fraseCorrecta = computed(() => reto.value?.frase.replace(reto.value.error, reto.value.correcta) || '');

function reparar(opcion) {
  if (!reto.value || estado.value === 'correcto') return;
  seleccion.value = opcion;
  intentos.value += 1;
  if (opcion === reto.value.correcta) {
    estado.value = 'correcto';
    reparadas.value += 1;
    emit('alimento', 1);
    reproducirTexto(fraseCorrecta.value);
  } else {
    estado.value = 'incorrecto';
  }
}

function siguiente() {
  indice.value += 1;
  seleccion.value = '';
  estado.value = '';
  reiniciarAudio();
}

function reiniciar() {
  indice.value = 0;
  seleccion.value = '';
  estado.value = '';
  reparadas.value = 0;
  intentos.value = 0;
}

onUnmounted(reiniciarAudio);
</script>

<template>
  <section class="repair-game">
    <header>
      <button @click="emit('salir')">← Centro de juegos</button>
      <span>REPARA LA FRASE</span>
      <b>🔧 {{ reparadas }} reparadas</b>
    </header>
    <div class="repair-progress"><i :style="{ width: progreso + '%' }"></i></div>

    <div v-if="terminado" class="repair-finish">
      <span>🛠️</span>
      <small>MISIÓN COMPLETADA</small>
      <h2>¡Taller en orden!</h2>
      <p>Reparaste {{ reparadas }} frases en {{ intentos }} intentos. Cada corrección refuerza una regla diferente.</p>
      <div><button class="secondary" @click="emit('salir')">Volver al centro</button><button class="primary" @click="reiniciar">Jugar otra vez</button></div>
    </div>

    <template v-else>
      <div class="repair-status"><span>Frase {{ indice + 1 }} de {{ retos.length }}</span><small>Elige la pieza que corrige el error</small></div>
      <main>
        <span class="repair-icon">{{ reto.icono }}</span>
        <small>FRASE CON UNA PIEZA DAÑADA</small>
        <p class="broken-sentence">
          {{ partes[0] }}<mark>{{ reto.error }}</mark>{{ partes[1] }}
          <button :aria-label="`Escuchar: ${reto.frase}`" @click="reproducirTexto(reto.frase)">🔊</button>
        </p>
        <div class="repair-tools">
          <button
            v-for="opcion in reto.opciones"
            :key="opcion"
            :class="{ correct: estado === 'correcto' && opcion === reto.correcta, wrong: estado === 'incorrecto' && seleccion === opcion }"
            :disabled="estado === 'correcto'"
            @click="reparar(opcion)"
          >
            <span>🧩</span>{{ opcion }}
          </button>
        </div>
      </main>

      <div v-if="estado" class="repair-feedback" :class="estado === 'correcto' ? 'ok' : 'retry'">
        <b>{{ estado === 'correcto' ? '✓ ¡Frase reparada!' : '↻ Esa pieza todavía no corrige la regla' }}</b>
        <span>{{ reto.explicacion }}</span>
      </div>
      <footer>
        <button class="secondary" @click="emit('salir')">Salir</button>
        <button v-if="estado === 'correcto'" class="primary" @click="siguiente">Siguiente reparación →</button>
      </footer>
    </template>
  </section>
</template>

<style scoped>
.repair-game{padding:1.2rem;border:1px solid var(--color-borde);border-radius:20px;background:#fff;box-shadow:var(--sombra-card)}header{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.7rem}header button{border:0;background:none;color:var(--color-azul);text-align:left}header span{font-size:.67rem;font-weight:900;letter-spacing:.08em;color:#b45b39}header b{text-align:right;color:#7655a5}.repair-progress{height:7px;margin:.7rem 0 1rem;border-radius:99px;background:#ece9e7;overflow:hidden}.repair-progress i{display:block;height:100%;border-radius:99px;background:linear-gradient(90deg,#dc754c,#7655a5);transition:.3s}.repair-status{display:flex;justify-content:space-between;padding:.65rem .8rem;border-radius:10px;background:#fff4ec;font-size:.75rem}.repair-status small{color:var(--color-texto-tenue)}main{display:flex;flex-direction:column;align-items:center;margin-top:.8rem;padding:1.4rem;border-radius:18px;background:linear-gradient(145deg,#fff5e9,#f1effb);text-align:center}.repair-icon{font-size:3rem}main>small,.repair-finish small{font-size:.62rem;font-weight:900;letter-spacing:.08em;color:#a34f30}.broken-sentence{margin:.7rem 0;font:italic 1.35rem Georgia,serif}.broken-sentence mark{padding:.2rem .35rem;border-radius:7px;background:#ffd3c2;color:#9b371b;text-decoration:line-through}.broken-sentence button{border:0;background:transparent}.repair-tools{display:grid;grid-template-columns:repeat(3,1fr);gap:.6rem;width:min(100%,620px)}.repair-tools button{display:flex;align-items:center;justify-content:center;gap:.35rem;padding:.75rem;border:2px solid #ded4e8;border-radius:12px;background:#fff;font-weight:800}.repair-tools button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.repair-tools button.wrong{border-color:var(--color-rojo);background:var(--color-rojo-suave);animation:shake .25s}.repair-feedback{display:flex;flex-direction:column;margin-top:.8rem;padding:.75rem;border-radius:11px}.repair-feedback.ok{background:var(--color-verde-suave);color:var(--color-verde)}.repair-feedback.retry{background:var(--color-rojo-suave);color:var(--color-rojo)}footer,.repair-finish>div{display:flex;justify-content:center;gap:.7rem;margin-top:1rem}footer button,.repair-finish button{min-width:170px;padding:.75rem;border-radius:var(--radio-boton);font-weight:800}.primary{border:0;background:#7655a5;color:#fff}.secondary{border:1px solid var(--color-borde);background:#fff}.repair-finish{display:flex;flex-direction:column;align-items:center;padding:2rem;border-radius:18px;background:linear-gradient(145deg,#e8f7ef,#fff3dd);text-align:center}.repair-finish>span{font-size:4rem}.repair-finish h2{margin:.3rem}.repair-finish p{max-width:560px}@keyframes shake{25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}
@media(max-width:620px){.repair-game{padding:.8rem}header{grid-template-columns:1fr auto}header span{grid-row:2;grid-column:1/-1}.repair-status{flex-direction:column}.repair-tools{grid-template-columns:1fr}.broken-sentence{font-size:1.08rem}footer,.repair-finish>div{flex-direction:column;width:100%}footer button,.repair-finish button{width:100%}}
</style>
