<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({
  mode: { type: String, required: true },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['hablar', 'practicar']);

const paso = ref(1);
const verboId = ref(0);
const accionId = ref(0);
const retoId = ref(0);
const respuesta = ref(null);
const aciertos = ref(new Set());

const datos = {
  ing: {
    icono: '🧲',
    sobre: 'ACCIONES COMO EXPERIENCIAS',
    titulo: 'Verbo + -ing',
    bajada: 'Algunos verbos atraen una acción terminada en -ing.',
    enlace: '-ing',
    color: '#a05c43',
    suave: '#fff0e8',
    verbos: [
      { verbo: 'enjoy', significado: 'disfrutar', acciones: ['reading', 'cooking', 'walking'] },
      { verbo: 'avoid', significado: 'evitar', acciones: ['eating late', 'driving at night', 'spending too much'] },
      { verbo: 'finish', significado: 'terminar', acciones: ['cleaning', 'washing the dishes', 'packing'] },
      { verbo: 'keep', significado: 'seguir', acciones: ['practicing', 'trying', 'smiling'] },
      { verbo: 'suggest', significado: 'sugerir', acciones: ['taking the bus', 'visiting the park', 'staying home'] },
      { verbo: 'mind', significado: 'molestar', acciones: ['waiting', 'opening the window', 'sitting here'] },
    ],
    retos: [
      { frase: 'I enjoy ___ before bed.', correcta: 'reading', opciones: ['to read', 'reading', 'read'], ayuda: 'Después de enjoy usamos -ing.' },
      { frase: 'We finished ___ the kitchen.', correcta: 'cleaning', opciones: ['cleaning', 'to clean', 'clean'], ayuda: 'Finish atrae una acción en -ing.' },
      { frase: 'She suggested ___ the bus.', correcta: 'taking', opciones: ['take', 'to take', 'taking'], ayuda: 'Después de suggest usamos -ing.' },
      { frase: 'Do you mind ___ a moment?', correcta: 'waiting', opciones: ['to wait', 'waiting', 'wait'], ayuda: 'Mind va seguido de -ing.' },
    ],
  },
  to: {
    icono: '🧭',
    sobre: 'INTENCIONES Y PLANES',
    titulo: 'Verbo + to',
    bajada: 'Algunos verbos apuntan hacia otra acción con to.',
    enlace: 'to',
    color: '#3d7468',
    suave: '#e9f6f1',
    verbos: [
      { verbo: 'want', significado: 'querer', acciones: ['travel', 'buy groceries', 'learn Italian'] },
      { verbo: 'need', significado: 'necesitar', acciones: ['rest', 'call Ana', 'leave early'] },
      { verbo: 'decide', significado: 'decidir', acciones: ['cook', 'stay home', 'walk'] },
      { verbo: 'plan', significado: 'planear', acciones: ['visit my family', 'go to the beach', 'make dinner'] },
      { verbo: 'promise', significado: 'prometer', acciones: ['call', 'help', 'return'] },
      { verbo: 'hope', significado: 'esperar', acciones: ['see you soon', 'find my keys', 'feel better'] },
    ],
    retos: [
      { frase: 'I want ___ this weekend.', correcta: 'to travel', opciones: ['traveling', 'to travel', 'travel'], ayuda: 'Want apunta a otra acción con to.' },
      { frase: 'They decided ___ at home.', correcta: 'to stay', opciones: ['staying', 'stay', 'to stay'], ayuda: 'Después de decide usamos to + verbo.' },
      { frase: 'We plan ___ my family.', correcta: 'to visit', opciones: ['to visit', 'visiting', 'visit'], ayuda: 'Plan va seguido de to + verbo.' },
      { frase: 'She hopes ___ better soon.', correcta: 'to feel', opciones: ['feeling', 'feel', 'to feel'], ayuda: 'Hope conecta con la siguiente acción mediante to.' },
    ],
  },
};

const leccion = computed(() => datos[props.mode]);
const verbo = computed(() => leccion.value.verbos[verboId.value]);
const accion = computed(() => verbo.value.acciones[accionId.value % verbo.value.acciones.length]);
const frase = computed(() => `I ${verbo.value.verbo} ${props.mode === 'ing' ? accion.value : `to ${accion.value}`}.`);
const reto = computed(() => leccion.value.retos[retoId.value]);
const esCorrecta = computed(() => respuesta.value === reto.value.correcta);

function elegirVerbo(index) {
  verboId.value = index;
  accionId.value = 0;
}
function responder(opcion) {
  respuesta.value = opcion;
  if (opcion === reto.value.correcta) aciertos.value = new Set([...aciertos.value, retoId.value]);
}
function siguiente() {
  retoId.value = (retoId.value + 1) % leccion.value.retos.length;
  respuesta.value = null;
}
function escuchar(texto) {
  emit('hablar', texto, 1);
}

watch(() => props.mode, () => {
  paso.value = 1;
  verboId.value = 0;
  accionId.value = 0;
  retoId.value = 0;
  respuesta.value = null;
  aciertos.value = new Set();
});
</script>

<template>
  <section class="gerund" :style="{ '--accent': leccion.color, '--soft': leccion.suave }">
    <aside class="hero">
      <span>{{ leccion.icono }}</span>
      <div>
        <small>ADULTO ESTÁNDAR · {{ leccion.sobre }}</small>
        <h2>{{ leccion.titulo }}</h2>
        <p>{{ leccion.bajada }}</p>
      </div>
      <div class="hero-formula"><b>VERB</b><i>＋</i><strong>{{ leccion.enlace }}</strong></div>
    </aside>

    <nav>
      <button v-for="(tab, index) in ['Armá la frase', 'Mapa de verbos', 'Reto rápido']" :key="tab" :class="{ active: paso === index + 1 }" @click="paso = index + 1">
        <b>0{{ index + 1 }}</b><span>{{ tab }}</span>
      </button>
    </nav>

    <main v-if="paso === 1">
      <header><small>IMÁN DE FRASES</small><h3>Uní las dos acciones</h3><p>Elegí el verbo inicial y después la actividad.</p></header>
      <div class="builder">
        <section>
          <small>1 · PRIMER VERBO</small>
          <div class="chips">
            <button v-for="(item, index) in leccion.verbos" :key="item.verbo" :class="{ active: verboId === index }" @click="elegirVerbo(index)">
              <b>{{ item.verbo }}</b><span>{{ item.significado }}</span>
            </button>
          </div>
        </section>
        <div class="magnet"><span>{{ verbo.verbo }}</span><b>{{ leccion.enlace }}</b><strong>{{ accion }}</strong></div>
        <section>
          <small>2 · SEGUNDA ACCIÓN</small>
          <div class="actions">
            <button v-for="(item, index) in verbo.acciones" :key="item" :class="{ active: accionId === index }" @click="accionId = index">{{ item }}</button>
          </div>
        </section>
      </div>
      <article class="result"><small>TU FRASE</small><strong>{{ frase }}</strong><button @click="escuchar(frase)">🔊 Escuchar</button></article>
    </main>

    <main v-else-if="paso === 2">
      <header><small>MEMORIA VISUAL</small><h3>Recordá la familia completa</h3><p>No hay una regla universal: conviene aprender estos verbos como grupo.</p></header>
      <div class="verb-map">
        <article v-for="item in leccion.verbos" :key="item.verbo">
          <span>{{ props.mode === 'ing' ? '🧲' : '🧭' }}</span>
          <b>{{ item.verbo }}</b><i>＋ {{ leccion.enlace }}</i>
          <small>{{ item.significado }}</small>
          <p>{{ item.verbo }} {{ props.mode === 'ing' ? item.acciones[0] : `to ${item.acciones[0]}` }}</p>
        </article>
      </div>
      <aside class="tip"><b>Atajo mental:</b> aprendé la pareja completa — “{{ verbo.verbo }} {{ leccion.enlace }}”—, no solo el verbo aislado.</aside>
    </main>

    <main v-else>
      <header class="challenge-head"><div><small>{{ leccion.sobre }} · RETO</small><h3>Elegí la conexión natural</h3><p>Completá la frase como la dirías en una conversación.</p></div><b>{{ aciertos.size }}/{{ leccion.retos.length }}</b></header>
      <article class="challenge">
        <span>{{ props.mode === 'ing' ? '🧲' : '🧭' }}</span>
        <button @click="escuchar(reto.frase.replace('___', reto.correcta))">{{ reto.frase }} 🔊</button>
        <div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: respuesta && opcion === reto.correcta, bad: respuesta === opcion && opcion !== reto.correcta }" @click="responder(opcion)">{{ opcion }}</button></div>
        <p v-if="respuesta"><b>{{ esCorrecta ? '✓ Suena natural' : '↻ Probá otra conexión' }}</b> {{ reto.ayuda }}</p>
        <button v-if="esCorrecta" class="next" @click="siguiente">Siguiente frase →</button>
      </article>
    </main>

    <button class="practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.gerund{display:grid;gap:1rem}.hero,main{padding:1rem;border:1px solid var(--color-borde);border-radius:var(--radio-panel);background:var(--color-superficie)}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.9rem;background:linear-gradient(135deg,var(--soft),var(--color-superficie))}.hero>span{font-size:2.8rem}.hero h2,main h3{margin:.15rem 0}.hero p,main header p{margin:.25rem 0;color:var(--color-texto-secundario)}small{font-size:.64rem;font-weight:900;letter-spacing:.08em;color:var(--accent)}.hero-formula{display:flex;align-items:center;gap:.35rem;padding:.7rem;border:1px dashed var(--accent);border-radius:12px}.hero-formula strong{padding:.25rem .45rem;border-radius:7px;background:var(--accent);color:#fff}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}nav button{display:flex;gap:.5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:12px;background:var(--color-superficie);text-align:left}nav button b{color:var(--accent)}nav button.active,.chips button.active,.actions button.active{border-color:var(--accent)!important;background:var(--soft)!important}.builder{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.8rem}.chips,.actions{display:grid;grid-template-columns:repeat(2,1fr);gap:.4rem;margin-top:.45rem}.chips button,.actions button{padding:.55rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie)}.chips button{display:flex;flex-direction:column}.chips span{font-size:.65rem;color:var(--color-texto-tenue)}.magnet{display:flex;flex-direction:column;align-items:center;min-width:150px;overflow:hidden;border:2px solid var(--accent);border-radius:18px;background:var(--soft)}.magnet span,.magnet strong{width:100%;padding:.6rem;text-align:center}.magnet b{width:100%;padding:.3rem;background:var(--accent);color:#fff;text-align:center}.result{display:flex;flex-direction:column;align-items:center;gap:.35rem;margin-top:.8rem;padding:1rem;border-radius:15px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.result strong{font:italic 1.25rem Georgia}.result button{padding:.5rem .8rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.verb-map{display:grid;grid-template-columns:repeat(3,1fr);gap:.6rem}.verb-map article{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.35rem;padding:.8rem;border:1px solid var(--color-borde);border-radius:13px}.verb-map article>span{grid-row:1/3;font-size:1.6rem}.verb-map article>i{color:var(--accent);font-weight:800}.verb-map article>small,.verb-map article>p{grid-column:2/4}.verb-map article>p{margin:.15rem 0;font:italic .85rem Georgia}.tip{margin-top:.7rem;padding:.7rem;border-left:4px solid var(--accent);border-radius:8px;background:var(--soft);font-size:.78rem}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:50px;height:50px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:650px;margin:auto;padding:1rem;border-radius:16px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.challenge>span{font-size:2.8rem}.challenge>button{display:block;margin:.45rem auto;border:0;background:transparent;font:italic 1.1rem Georgia}.challenge>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.45rem}.challenge>div button{padding:.65rem;border:1px solid var(--color-borde);border-radius:9px;background:var(--color-superficie)}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:var(--color-rojo);background:var(--color-rojo-suave)}.next{padding:.55rem .8rem!important;background:var(--accent)!important;color:#fff!important}.practice{width:100%;padding:.85rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff;font-weight:800}.practice:disabled{background:var(--color-verde)}
@media(max-width:720px){.hero{grid-template-columns:auto 1fr}.hero-formula{grid-column:1/-1;justify-content:center}.builder{grid-template-columns:1fr}.magnet{width:100%;box-sizing:border-box}.verb-map{grid-template-columns:1fr 1fr}}@media(max-width:520px){nav,.verb-map,.challenge>div{grid-template-columns:1fr}.chips,.actions{grid-template-columns:1fr 1fr}}
</style>
