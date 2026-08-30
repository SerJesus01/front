<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  items: { type: Array, default: () => [] },
  reproduciendoId: { type: [Number, String], default: null },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['reproducir', 'hablar', 'practicar']);

const leccion = ref(1);
const momento = ref('morning');
const tono = ref('neutral');
const escenarioActual = ref(0);
const respuestaElegida = ref(null);
const aciertos = ref(new Set());
const despedidaTono = ref('warm');
const proximoEncuentro = ref('tomorrow');

const momentos = [
  { id: 'morning', icono: '🌅', nombre: 'Mañana', rango: '05:00–11:59' },
  { id: 'afternoon', icono: '☀️', nombre: 'Tarde', rango: '12:00–16:59' },
  { id: 'evening', icono: '🌇', nombre: 'Noche al llegar', rango: '17:00–21:00' },
  { id: 'anytime', icono: '👋', nombre: 'Cualquier hora', rango: 'Casual' },
];
const tonos = [
  { id: 'formal', nombre: 'Formal', icono: '🤝', pista: 'Cliente, entrevista o persona nueva' },
  { id: 'neutral', nombre: 'Neutral', icono: '🙂', pista: 'Seguro en casi cualquier situación' },
  { id: 'casual', nombre: 'Casual', icono: '😄', pista: 'Amigos y compañeros cercanos' },
];
const saludos = {
  morning: { formal: 'Good morning.', neutral: 'Good morning!', casual: 'Morning!' },
  afternoon: { formal: 'Good afternoon.', neutral: 'Good afternoon!', casual: 'Hi!' },
  evening: { formal: 'Good evening.', neutral: 'Good evening!', casual: 'Hey!' },
  anytime: { formal: 'Hello. Nice to meet you.', neutral: 'Hello!', casual: "Hey! What's up?" },
};
const contextoSaludo = computed(() => momentos.find((item) => item.id === momento.value));
const tonoSaludo = computed(() => tonos.find((item) => item.id === tono.value));
const saludoActual = computed(() => saludos[momento.value][tono.value]);

const escenarios = [
  {
    icono: '💼', lugar: 'Primer día de trabajo', situacion: 'Son las 9:00 a. m. y conocés a tu supervisora.',
    frase: 'Good morning. Nice to meet you.', respuesta: 'Good morning. Nice to meet you, too.',
    opciones: ['Good morning. Nice to meet you, too.', "Hey! What's up?", 'Good night.'],
    explicacion: 'La hora y una relación nueva piden un saludo formal o neutral.',
  },
  {
    icono: '🎒', lugar: 'Entre amigos', situacion: 'Tu amigo llega al parque por la tarde.',
    frase: "Hey! What's up?", respuesta: 'Not much. How about you?',
    opciones: ['Goodbye forever.', 'Not much. How about you?', 'Good morning, sir.'],
    explicacion: "What's up? suele responderse de forma breve y casual.",
  },
  {
    icono: '🌆', lugar: 'Evento profesional', situacion: 'Llegás a una reunión a las 7:00 p. m.',
    frase: 'Good evening. How are you?', respuesta: "I'm very well, thank you.",
    opciones: ["I'm very well, thank you.", 'Good night yesterday.', 'See you morning.'],
    explicacion: 'Good evening saluda; Good night normalmente despide.',
  },
  {
    icono: '🚪', lugar: 'Al salir de clase', situacion: 'Verás a tu compañera mañana.',
    frase: 'Bye! See you tomorrow.', respuesta: 'See you tomorrow!',
    opciones: ['Nice to meet yesterday.', 'See you tomorrow!', 'Good morning!'],
    explicacion: 'See you tomorrow confirma cuándo volverán a verse.',
  },
];
const escenario = computed(() => escenarios[escenarioActual.value]);
const respuestaCorrecta = computed(() => respuestaElegida.value === escenario.value.respuesta);

const despedidas = {
  quick: { soon: 'See you soon!', tomorrow: 'See you tomorrow!', unknown: 'Bye!' },
  warm: { soon: 'Take care. See you soon!', tomorrow: 'Take care. See you tomorrow!', unknown: 'Take care. Have a good one!' },
  formal: { soon: 'Goodbye. See you soon.', tomorrow: 'Goodbye. See you tomorrow.', unknown: 'Goodbye. It was a pleasure speaking with you.' },
};
const despedidaActual = computed(() => despedidas[despedidaTono.value][proximoEncuentro.value]);

const totalAciertos = computed(() => aciertos.value.size);

function normalizar(texto) {
  return String(texto || '').toLowerCase().replace(/[^a-z]/g, '');
}

function escuchar(texto) {
  const referencia = props.items.find((item) => normalizar(item.texto_en) === normalizar(texto));
  if (referencia?.audio_key) emit('reproducir', referencia);
  else emit('hablar', texto, 1);
}

function elegirRespuesta(opcion) {
  respuestaElegida.value = opcion;
  if (opcion === escenario.value.respuesta) {
    const nuevos = new Set(aciertos.value);
    nuevos.add(escenarioActual.value);
    aciertos.value = nuevos;
  }
}

function siguienteEscenario() {
  escenarioActual.value = (escenarioActual.value + 1) % escenarios.length;
  respuestaElegida.value = null;
}
</script>

<template>
  <section class="greeting-lesson">
    <aside class="greeting-summary">
      <header><span>👋</span><div><small>MAPA RÁPIDO</small><h2>Saludar, responder y despedirte</h2></div></header>
      <p>Elegí la frase con tres pistas: <b>hora</b>, <b>confianza</b> y si estás <b>llegando o saliendo</b>.</p>
      <div class="summary-rules">
        <article><b>Good morning</b><span>Saludo antes del mediodía</span></article>
        <article><b>Good evening</b><span>Saludo al llegar por la noche</span></article>
        <article><b>Good night</b><span>Despedida al final del día</span></article>
        <article><b>Hi / Hello / Hey</b><span>De neutral a muy casual</span></article>
      </div>
    </aside>

    <nav class="greeting-tabs" aria-label="Microlecciones de saludos">
      <button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero">
        <b>0{{ numero }}</b>
        <span>{{ numero === 1 ? 'Elegí el saludo' : numero === 2 ? 'Respondé' : 'Despedite' }}</span>
        <small>{{ numero === 1 ? 'Hora + confianza' : numero === 2 ? 'Conversación real' : 'Tono + próximo encuentro' }}</small>
      </button>
    </nav>

    <section v-if="leccion === 1" class="greeting-panel">
      <header><small>SALUDOS 1</small><h3>Laboratorio de contexto</h3><p>Combiná el momento del día con el nivel de confianza.</p></header>
      <div class="context-lab">
        <div class="context-controls">
          <span class="control-label">1 · ¿Cuándo?</span>
          <div class="moment-options">
            <button v-for="item in momentos" :key="item.id" :class="{ active: momento === item.id }" @click="momento = item.id">
              <span>{{ item.icono }}</span><b>{{ item.nombre }}</b><small>{{ item.rango }}</small>
            </button>
          </div>
          <span class="control-label">2 · ¿Con quién?</span>
          <div class="tone-options">
            <button v-for="item in tonos" :key="item.id" :class="{ active: tono === item.id }" @click="tono = item.id">
              <span>{{ item.icono }}</span><b>{{ item.nombre }}</b><small>{{ item.pista }}</small>
            </button>
          </div>
        </div>
        <div class="greeting-result" :class="momento">
          <span class="result-scene">{{ contextoSaludo.icono }} {{ tonoSaludo.icono }}</span>
          <small>UNA OPCIÓN NATURAL ES</small>
          <strong>{{ saludoActual }}</strong>
          <p>{{ contextoSaludo.nombre }} · {{ tonoSaludo.nombre }}</p>
          <button @click="escuchar(saludoActual)">🔊 Escuchar y repetir</button>
        </div>
      </div>
      <div class="contrast-card"><span>💡</span><p><b>Good evening</b> = saludo al llegar. <b>Good night</b> = despedida al irte o antes de dormir.</p></div>
    </section>

    <section v-else-if="leccion === 2" class="greeting-panel">
      <header class="challenge-header"><div><small>SALUDOS 2</small><h3>¿Qué responderías?</h3><p>Leé la situación, escuchá a la otra persona y elegí una respuesta natural.</p></div><strong>{{ totalAciertos }}/{{ escenarios.length }}</strong></header>
      <div class="scenario-card">
        <div class="scenario-title"><span>{{ escenario.icono }}</span><div><small>ESCENARIO {{ escenarioActual + 1 }}</small><h4>{{ escenario.lugar }}</h4><p>{{ escenario.situacion }}</p></div></div>
        <button class="speech-bubble incoming" @click="escuchar(escenario.frase)"><span>Alex</span><b>“{{ escenario.frase }}”</b><i>🔊</i></button>
        <div class="reply-options">
          <button
            v-for="opcion in escenario.opciones" :key="opcion"
            :class="{ correct: respuestaElegida && opcion === escenario.respuesta, wrong: respuestaElegida === opcion && opcion !== escenario.respuesta }"
            :disabled="respuestaCorrecta" @click="elegirRespuesta(opcion)"
          ><span>{{ opcion }}</span><i>→</i></button>
        </div>
        <div v-if="respuestaElegida" class="scenario-feedback" :class="respuestaCorrecta ? 'ok' : 'retry'">
          <b>{{ respuestaCorrecta ? '✓ ¡Suena natural!' : '↻ Probá otra opción' }}</b><span>{{ escenario.explicacion }}</span>
        </div>
        <button v-if="respuestaCorrecta" class="next-challenge" @click="siguienteEscenario">Siguiente situación →</button>
      </div>
    </section>

    <section v-else class="greeting-panel">
      <header><small>SALUDOS 3</small><h3>Estudio de despedidas</h3><p>Construí una despedida que coincida con la relación y el próximo encuentro.</p></header>
      <div class="farewell-builder">
        <div class="farewell-controls">
          <label><span>1 · Elegí el tono</span><select v-model="despedidaTono"><option value="quick">Rápido y casual</option><option value="warm">Cálido y amistoso</option><option value="formal">Formal</option></select></label>
          <label><span>2 · ¿Cuándo se ven otra vez?</span><select v-model="proximoEncuentro"><option value="soon">Pronto</option><option value="tomorrow">Mañana</option><option value="unknown">No lo sabés</option></select></label>
        </div>
        <div class="farewell-result"><span>🚪</span><small>TU DESPEDIDA</small><strong>{{ despedidaActual }}</strong><button @click="escuchar(despedidaActual)">🔊 Escuchar</button></div>
      </div>
      <div class="farewell-memory">
        <article><span>🌙</span><div><b>Good night</b><small>Al despedirte de noche</small></div></article>
        <article><span>🫶</span><div><b>Take care</b><small>Añade calidez</small></div></article>
        <article><span>📅</span><div><b>See you tomorrow</b><small>Próximo encuentro definido</small></div></article>
      </div>
    </section>

    <button class="greeting-practice" :disabled="completado" @click="emit('practicar')">
      {{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}
    </button>
  </section>
</template>

<style scoped>
.greeting-lesson{display:grid;gap:1rem}.greeting-summary{padding:1rem;border:1px solid #ffd1ad;border-left:5px solid #f28b39;border-radius:18px;background:linear-gradient(135deg,#fff8ee,#f2fbf7)}.greeting-summary header{display:flex;align-items:center;gap:.7rem}.greeting-summary header>span{font-size:2.2rem}.greeting-summary h2,.greeting-panel h3{margin:.15rem 0}.greeting-summary header small,.greeting-panel header>small,.challenge-header small{font-size:.65rem;font-weight:900;letter-spacing:.09em;color:#c96721}.greeting-summary>p{margin:.7rem 0;padding:.6rem;border-radius:10px;background:#fff;font-size:.84rem}.summary-rules{display:grid;grid-template-columns:repeat(4,1fr);gap:.45rem}.summary-rules article{display:flex;flex-direction:column;padding:.6rem;border:1px solid #f5e5d7;border-radius:11px;background:#fff}.summary-rules b{color:#a64f1f}.summary-rules span{margin-top:.2rem;font-size:.68rem;color:var(--color-texto-tenue)}.greeting-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.greeting-tabs button{display:grid;grid-template-columns:34px 1fr;border:1px solid var(--color-borde);border-radius:13px;background:#fff;padding:.7rem;text-align:left;transition:.2s}.greeting-tabs button:hover{transform:translateY(-2px)}.greeting-tabs b{grid-row:1/3;color:#d16b24}.greeting-tabs small{color:var(--color-texto-tenue)}.greeting-tabs button.active{border-color:#f28b39;background:#fff4e8;box-shadow:0 4px 12px #d56c1e1a}.greeting-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:18px;background:#fff}.greeting-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.context-lab{display:grid;grid-template-columns:1.4fr .8fr;gap:1rem}.context-controls{display:grid;gap:.55rem}.control-label{font-size:.68rem;font-weight:900;letter-spacing:.06em;color:var(--color-texto-tenue)}.moment-options{display:grid;grid-template-columns:repeat(4,1fr);gap:.4rem}.moment-options button,.tone-options button{display:flex;flex-direction:column;align-items:center;gap:.15rem;padding:.55rem;border:1px solid var(--color-borde);border-radius:11px;background:#fff}.moment-options button>span{font-size:1.5rem}.moment-options small,.tone-options small{font-size:.6rem;color:var(--color-texto-tenue)}.moment-options button.active,.tone-options button.active{border-color:#f28b39;background:#fff4e8;box-shadow:0 2px 0 #f4c9a7}.tone-options{display:grid;grid-template-columns:repeat(3,1fr);gap:.4rem}.tone-options button{display:grid;grid-template-columns:28px 1fr;text-align:left;align-items:center}.tone-options button>span{grid-row:1/3;font-size:1.25rem}.greeting-result{display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:250px;padding:1rem;border-radius:17px;text-align:center;background:linear-gradient(145deg,#fff0cb,#edf9f1)}.greeting-result.afternoon{background:linear-gradient(145deg,#e6f6ff,#fff3c8)}.greeting-result.evening{background:linear-gradient(145deg,#ffe0cb,#ebe4ff)}.greeting-result.anytime{background:linear-gradient(145deg,#e7f8ed,#eaf4ff)}.result-scene{font-size:2.8rem}.greeting-result>small{margin-top:.6rem;font-size:.62rem;font-weight:900;letter-spacing:.08em}.greeting-result strong{margin:.4rem 0;font:italic 1.45rem Georgia,serif;color:#8a451d}.greeting-result p{margin:0 0 .65rem;font-size:.72rem}.greeting-result button,.farewell-result button{border:0;border-radius:9px;background:#e2782d;color:#fff;padding:.5rem .7rem;font-weight:800}.contrast-card{display:flex;align-items:center;gap:.6rem;margin-top:.8rem;padding:.65rem;border-radius:11px;background:#fff8e7}.contrast-card p{margin:0;font-size:.78rem}.challenge-header{display:flex;justify-content:space-between}.challenge-header>strong{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:#fff0de;color:#b85c1c}.scenario-card{max-width:720px;margin:auto;padding:1rem;border-radius:16px;background:#f7faf7}.scenario-title{display:flex;align-items:center;gap:.65rem}.scenario-title>span{font-size:2rem}.scenario-title h4,.scenario-title p{margin:.1rem 0}.scenario-title small{font-size:.6rem;font-weight:900;color:#c96721}.scenario-title p{font-size:.75rem;color:var(--color-texto-tenue)}.speech-bubble{display:grid;grid-template-columns:42px 1fr 30px;align-items:center;gap:.5rem;width:min(90%,620px);margin:1rem 0;padding:.8rem;border:0;border-radius:14px;background:#e9f4ff;text-align:left}.speech-bubble span{font-size:.7rem;font-weight:900}.speech-bubble b{font:italic 1rem Georgia,serif}.speech-bubble i{font-style:normal}.reply-options{display:grid;gap:.45rem;margin-left:10%}.reply-options button{display:flex;justify-content:space-between;padding:.65rem .8rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff;text-align:left}.reply-options button:hover{border-color:#f28b39}.reply-options button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.reply-options button.wrong{border-color:#c96543;background:#fff0ea}.reply-options i{font-style:normal}.scenario-feedback{display:flex;flex-direction:column;margin:.65rem 0 0 10%;padding:.65rem;border-radius:10px;font-size:.75rem}.scenario-feedback.ok{background:var(--color-verde-suave);color:#236843}.scenario-feedback.retry{background:#fff0ea;color:#984228}.next-challenge{display:block;margin:.65rem 0 0 auto;border:0;border-radius:9px;background:#e2782d;color:#fff;padding:.55rem .8rem;font-weight:800}.farewell-builder{display:grid;grid-template-columns:1fr 1fr;gap:1rem;padding:1rem;border-radius:16px;background:#f7faf7}.farewell-controls{display:grid;gap:.7rem}.farewell-controls label{display:flex;flex-direction:column;gap:.3rem}.farewell-controls label>span{font-size:.7rem;font-weight:900}.farewell-controls select{padding:.65rem;border:1px solid var(--color-borde);border-radius:9px;background:#fff}.farewell-result{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:1rem;border-radius:14px;background:linear-gradient(145deg,#e8eefb,#f4e9ff);text-align:center}.farewell-result>span{font-size:2.2rem}.farewell-result small{font-size:.6rem;font-weight:900;letter-spacing:.08em}.farewell-result strong{margin:.5rem 0;font:italic 1.25rem Georgia,serif}.farewell-memory{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem;margin-top:.8rem}.farewell-memory article{display:flex;align-items:center;gap:.5rem;padding:.65rem;border:1px solid var(--color-borde);border-radius:10px}.farewell-memory article>span{font-size:1.35rem}.farewell-memory div{display:flex;flex-direction:column}.farewell-memory small{font-size:.62rem;color:var(--color-texto-tenue)}.greeting-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:#e2782d;color:#fff;font-weight:800}.greeting-practice:disabled{background:var(--color-verde)}
@media(max-width:760px){.summary-rules{grid-template-columns:1fr 1fr}.context-lab,.farewell-builder{grid-template-columns:1fr}.moment-options{grid-template-columns:1fr 1fr}.greeting-result{min-height:190px}.farewell-memory{grid-template-columns:1fr}.speech-bubble{width:100%}.reply-options,.scenario-feedback{margin-left:0}}
@media(max-width:520px){.greeting-tabs{grid-template-columns:1fr}.summary-rules,.tone-options{grid-template-columns:1fr}.tone-options button{grid-template-columns:28px 1fr}.moment-options button{padding:.45rem}.greeting-panel{padding:.75rem}}
</style>
