<script setup>
import { computed, ref } from 'vue';

const props = defineProps({ items: { type: Array, default: () => [] }, reproduciendoId: { type: [Number, String], default: null }, completado: { type: Boolean, default: false } });
const emit = defineEmits(['reproducir', 'hablar', 'practicar']);

const leccion = ref(1);
const sujetoId = ref('i');
const complemento = ref('a software developer');
const usarContraccion = ref(true);
const estados = ref({ server: true, tests: false, user: true, team: false });
const preguntaActual = ref(0);
const respuestaElegida = ref(null);
const aciertos = ref(new Set());

const sujetos = [
  { id: 'i', sujeto: 'I', icono: '🙋', be: 'am', corto: "I'm" },
  { id: 'you', sujeto: 'You', icono: '👉', be: 'are', corto: "You're" },
  { id: 'he', sujeto: 'He', icono: '👨', be: 'is', corto: "He's" },
  { id: 'she', sujeto: 'She', icono: '👩', be: 'is', corto: "She's" },
  { id: 'it', sujeto: 'It', icono: '💻', be: 'is', corto: "It's" },
  { id: 'we', sujeto: 'We', icono: '👥', be: 'are', corto: "We're" },
  { id: 'they', sujeto: 'They', icono: '👨‍👩‍👧', be: 'are', corto: "They're" },
];
const complementos = [
  { valor: 'a software developer', icono: '💻', tipo: 'profesión' },
  { valor: 'ready', icono: '✅', tipo: 'estado' },
  { valor: 'from Mexico', icono: '🇲🇽', tipo: 'origen' },
  { valor: 'at home', icono: '🏠', tipo: 'ubicación' },
  { valor: 'tired', icono: '😴', tipo: 'estado' },
];
const sujeto = computed(() => sujetos.find((item) => item.id === sujetoId.value));
const detalle = computed(() => complementos.find((item) => item.valor === complemento.value));
const fraseAfirmativa = computed(() => `${usarContraccion.value ? sujeto.value.corto : `${sujeto.value.sujeto} ${sujeto.value.be}`} ${complemento.value}.`);

const tarjetasEstado = [
  { id: 'server', icono: '🖥️', sujeto: 'The server', be: 'is', positivo: 'online', negativo: "isn't online" },
  { id: 'tests', icono: '🧪', sujeto: 'The tests', be: 'are', positivo: 'ready', negativo: "aren't ready" },
  { id: 'user', icono: '🙋', sujeto: 'I', be: 'am', positivo: 'available', negativo: "am not available" },
  { id: 'team', icono: '👥', sujeto: 'The team', be: 'is', positivo: 'in the office', negativo: "isn't in the office" },
];
function fraseEstado(item) { return `${item.sujeto} ${estados.value[item.id] ? `${item.be} ${item.positivo}` : item.negativo}.`; }

const preguntas = [
  { icono: '🗓️', afirmacion: 'You are free tomorrow.', pregunta: 'Are you free tomorrow?', respuesta: 'Are you free tomorrow?', opciones: ['Are you free tomorrow?', 'You are free tomorrow?', 'Do you are free tomorrow?'], pista: 'Sí/no: to be pasa antes del sujeto.' },
  { icono: '📍', afirmacion: 'The meeting is in Room 4.', pregunta: 'Where is the meeting?', respuesta: 'Where is the meeting?', opciones: ['Where the meeting is?', 'Where is the meeting?', 'Where does the meeting is?'], pista: 'WH + to be + sujeto.' },
  { icono: '📊', afirmacion: 'The project is going well.', pregunta: 'How is the project going?', respuesta: 'How is the project going?', opciones: ['How the project is going?', 'How does the project is going?', 'How is the project going?'], pista: 'How va primero; is queda antes del sujeto.' },
  { icono: '⚠️', afirmacion: 'The server is down.', pregunta: 'Why is the server down?', respuesta: 'Why is the server down?', opciones: ['Why is the server down?', 'Why the server is down?', 'Why does the server down?'], pista: 'Why + is + the server + complemento.' },
  { icono: '⏰', afirmacion: 'The deploy is at 5 PM.', pregunta: 'When is the deploy?', respuesta: 'When is the deploy?', opciones: ['When the deploy is?', 'When does the deploy is?', 'When is the deploy?'], pista: 'When pregunta por el momento.' },
];
const pregunta = computed(() => preguntas[preguntaActual.value]);
const respuestaCorrecta = computed(() => respuestaElegida.value === pregunta.value.respuesta);
const totalAciertos = computed(() => aciertos.value.size);

function normalizar(texto) { return String(texto || '').toLowerCase().replace(/[^a-z]/g, ''); }
function escuchar(texto) { const referencia = props.items.find((item) => normalizar(item.texto_en) === normalizar(texto)); if (referencia?.audio_key) emit('reproducir', referencia); else emit('hablar', texto, 1); }
function cambiarEstado(id) { estados.value = { ...estados.value, [id]: !estados.value[id] }; const item = tarjetasEstado.find((tarjeta) => tarjeta.id === id); escuchar(fraseEstado(item)); }
function responder(opcion) { respuestaElegida.value = opcion; if (opcion === pregunta.value.respuesta) { const nuevos = new Set(aciertos.value); nuevos.add(preguntaActual.value); aciertos.value = nuevos; } }
function siguientePregunta() { preguntaActual.value = (preguntaActual.value + 1) % preguntas.length; respuestaElegida.value = null; }
</script>

<template>
  <section class="tobe-lesson">
    <aside class="tobe-summary"><header><span>🔗</span><div><small>MAPA RÁPIDO</small><h2>To be conecta quién sos con cómo estás</h2></div></header><p>En presente solo elegís entre <b>am</b>, <b>is</b> y <b>are</b>. Para negar agregás <b>not</b>; para preguntar, movés <b>to be</b> antes del sujeto.</p><div><article><b>I → am</b><span>I am / I'm</span></article><article><b>he · she · it → is</b><span>is / isn't</span></article><article><b>you · we · they → are</b><span>are / aren't</span></article><article><b>Pregunta</b><span>Are you…? / Where is…?</span></article></div></aside>
    <nav class="tobe-tabs"><button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero"><b>0{{ numero }}</b><span>{{ numero === 1 ? 'Conectá' : numero === 2 ? 'Cambiá el estado' : 'Transformá en pregunta' }}</span><small>{{ numero === 1 ? 'am · is · are' : numero === 2 ? 'not y contracciones' : 'Inversión + WH' }}</small></button></nav>

    <section v-if="leccion === 1" class="tobe-panel"><header><small>TO BE 1</small><h3>El conector correcto</h3><p>Elegí una persona y una idea. El verbo cambia automáticamente.</p></header><div class="connector-lab"><div class="subject-picker"><button v-for="item in sujetos" :key="item.id" :class="{ active: sujetoId === item.id }" @click="sujetoId = item.id"><span>{{ item.icono }}</span><b>{{ item.sujeto }}</b><small>{{ item.be }}</small></button></div><div class="connector-stage"><span class="person-icon">{{ sujeto.icono }}</span><div class="sentence-parts"><b>{{ sujeto.sujeto }}</b><strong>{{ sujeto.be }}</strong><span>{{ complemento }}</span></div><small>{{ detalle.icono }} {{ detalle.tipo }}</small><button @click="escuchar(fraseAfirmativa)">🔊 {{ fraseAfirmativa }}</button></div></div><div class="complement-picker"><button v-for="item in complementos" :key="item.valor" :class="{ active: complemento === item.valor }" @click="complemento = item.valor"><span>{{ item.icono }}</span>{{ item.valor }}</button></div><label class="contraction-toggle"><input v-model="usarContraccion" type="checkbox"><span>Usar forma natural contraída</span><b>{{ usarContraccion ? sujeto.corto : `${sujeto.sujeto} ${sujeto.be}` }}</b></label></section>

    <section v-else-if="leccion === 2" class="tobe-panel"><header><small>TO BE 2</small><h3>Panel de estados</h3><p>Encendé o apagá cada estado para practicar afirmación y negación.</p></header><div class="status-board"><article v-for="item in tarjetasEstado" :key="item.id" :class="{ negative: !estados[item.id] }"><span>{{ item.icono }}</span><small>{{ estados[item.id] ? 'AFFIRMATIVE' : 'NEGATIVE' }}</small><strong>{{ fraseEstado(item) }}</strong><button class="status-switch" :aria-label="`Cambiar estado de ${item.sujeto}`" @click="cambiarEstado(item.id)"><i></i></button><button class="status-audio" @click="escuchar(fraseEstado(item))">🔊 Escuchar</button></article></div><div class="negative-rule"><span>🧲</span><p>El <b>not</b> siempre se pega después de <b>to be</b>: <i>is not → isn't</i>, <i>are not → aren't</i>. Con <b>I</b> decimos <i>I'm not</i>.</p></div></section>

    <section v-else class="tobe-panel"><header class="question-head"><div><small>TO BE 3</small><h3>La máquina de preguntas</h3><p>Encontrá la transformación que respeta el orden del inglés.</p></div><strong>{{ totalAciertos }}/{{ preguntas.length }}</strong></header><div class="question-machine"><span class="question-icon">{{ pregunta.icono }}</span><small>AFIRMACIÓN</small><p>{{ pregunta.afirmacion }}</p><div class="swap-animation"><b>WH</b><i>＋</i><b>TO BE</b><i>＋</i><b>SUJETO</b><i>＋</i><b>…?</b></div><button class="question-audio" @click="escuchar(pregunta.pregunta)">🔊 Escuchar la pregunta</button><div class="question-options"><button v-for="opcion in pregunta.opciones" :key="opcion" :class="{ correct: respuestaElegida && opcion === pregunta.respuesta, wrong: respuestaElegida === opcion && opcion !== pregunta.respuesta }" :disabled="respuestaCorrecta" @click="responder(opcion)">{{ opcion }}</button></div><div v-if="respuestaElegida" class="question-feedback" :class="respuestaCorrecta ? 'ok' : 'retry'"><b>{{ respuestaCorrecta ? '✓ ¡Orden correcto!' : '↻ El verbo y el sujeto están en otro orden' }}</b><span>{{ pregunta.pista }}</span></div><button v-if="respuestaCorrecta" class="next-question" @click="siguientePregunta">Siguiente transformación →</button></div></section>

    <button class="tobe-practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.tobe-lesson{display:grid;gap:1rem}.tobe-summary{padding:1rem;border:1px solid #c8c8ef;border-left:5px solid #6655c7;border-radius:18px;background:linear-gradient(135deg,#f3f1ff,#eaf8f5)}.tobe-summary header{display:flex;align-items:center;gap:.7rem}.tobe-summary header>span{font-size:2.2rem}.tobe-summary h2,.tobe-panel h3{margin:.15rem 0}.tobe-summary small,.tobe-panel header>small,.question-head small{font-size:.65rem;font-weight:900;letter-spacing:.09em;color:#5545b5}.tobe-summary>p{margin:.7rem 0;padding:.6rem;border-radius:10px;background:#fff;font-size:.83rem}.tobe-summary>div{display:grid;grid-template-columns:repeat(4,1fr);gap:.45rem}.tobe-summary article{display:flex;flex-direction:column;padding:.6rem;border-radius:10px;background:#fff}.tobe-summary article b{color:#5545b5}.tobe-summary article span{font-size:.65rem;color:var(--color-texto-tenue)}.tobe-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.tobe-tabs button{display:grid;grid-template-columns:34px 1fr;border:1px solid var(--color-borde);border-radius:13px;background:#fff;padding:.7rem;text-align:left;transition:.2s}.tobe-tabs button:hover{transform:translateY(-2px)}.tobe-tabs b{grid-row:1/3;color:#6655c7}.tobe-tabs small{color:var(--color-texto-tenue)}.tobe-tabs button.active{border-color:#6655c7;background:#f1efff;box-shadow:0 4px 12px #6655c71a}.tobe-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:18px;background:#fff}.tobe-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.connector-lab{display:grid;grid-template-columns:1.2fr .8fr;gap:1rem}.subject-picker{display:grid;grid-template-columns:repeat(4,1fr);gap:.45rem}.subject-picker button{display:flex;flex-direction:column;align-items:center;padding:.6rem;border:1px solid var(--color-borde);border-radius:11px;background:#fff}.subject-picker button>span{font-size:1.6rem}.subject-picker button small{color:#6655c7;font-weight:900}.subject-picker button.active{border-color:#6655c7;background:#f1efff}.connector-stage{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:1rem;border-radius:16px;background:linear-gradient(145deg,#eeeaff,#e9f8f4);text-align:center}.person-icon{font-size:2.8rem}.sentence-parts{display:flex;align-items:center;gap:.35rem;margin:.4rem}.sentence-parts b,.sentence-parts strong,.sentence-parts span{padding:.35rem .5rem;border-radius:8px;background:#fff}.sentence-parts strong{background:#6655c7;color:#fff}.connector-stage>small{font-size:.68rem}.connector-stage>button{margin-top:.55rem;border:0;border-radius:9px;background:#6655c7;color:#fff;padding:.5rem .7rem;font-weight:800}.complement-picker{display:flex;flex-wrap:wrap;gap:.4rem;margin-top:.75rem}.complement-picker button{display:flex;align-items:center;gap:.3rem;border:1px solid var(--color-borde);border-radius:9px;background:#fff;padding:.45rem .6rem}.complement-picker button.active{border-color:#6655c7;background:#f1efff}.contraction-toggle{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.55rem;margin-top:.75rem;padding:.65rem;border-radius:11px;background:#f7f6ff}.contraction-toggle input{accent-color:#6655c7}.contraction-toggle span{font-size:.75rem}.contraction-toggle b{color:#5545b5}.status-board{display:grid;grid-template-columns:repeat(2,1fr);gap:.65rem}.status-board article{position:relative;display:grid;grid-template-columns:42px 1fr auto;align-items:center;gap:.4rem;padding:.8rem;border:1px solid #b8decf;border-radius:14px;background:#effaf6}.status-board article.negative{border-color:#e8b6a5;background:#fff2ed}.status-board article>span{grid-row:1/3;font-size:1.8rem}.status-board article>small{font-size:.57rem;font-weight:900;color:#23835d}.status-board article.negative>small{color:#b45234}.status-board article>strong{font:italic .95rem Georgia,serif}.status-switch{grid-row:1/3;grid-column:3;width:42px;height:24px;border:0;border-radius:99px;background:#2d9a70;padding:3px}.status-switch i{display:block;width:18px;height:18px;border-radius:50%;background:#fff;transform:translateX(18px);transition:.2s}.negative .status-switch{background:#ce7658}.negative .status-switch i{transform:translateX(0)}.status-audio{grid-column:2;border:0;background:transparent;text-align:left;color:#6655c7}.negative-rule{display:flex;gap:.55rem;margin-top:.8rem;padding:.65rem;border-radius:11px;background:#f4f2ff}.negative-rule p{margin:0;font-size:.76rem}.question-head{display:flex;justify-content:space-between}.question-head>strong{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:#eeeaff;color:#5545b5}.question-machine{max-width:720px;margin:auto;padding:1.1rem;border-radius:17px;background:linear-gradient(145deg,#f1efff,#eef9f6);text-align:center}.question-icon{font-size:2.8rem}.question-machine>small{display:block;font-size:.6rem;font-weight:900;color:#5545b5}.question-machine>p{font:italic 1.1rem Georgia,serif}.swap-animation{display:flex;justify-content:center;align-items:center;gap:.3rem;flex-wrap:wrap}.swap-animation b{padding:.4rem .55rem;border-radius:8px;background:#fff;border:1px solid #d7d2f4;font-size:.7rem;color:#5545b5}.swap-animation i{font-style:normal}.question-audio{margin:.65rem;border:0;background:transparent;color:#5545b5;font-weight:800}.question-options{display:grid;gap:.45rem}.question-options button{padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff}.question-options button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.question-options button.wrong{border-color:#c96543;background:#fff0ea}.question-feedback{display:flex;flex-direction:column;margin-top:.65rem;padding:.65rem;border-radius:10px;font-size:.75rem;text-align:left}.question-feedback.ok{background:var(--color-verde-suave);color:#236843}.question-feedback.retry{background:#fff0ea;color:#984228}.next-question{display:block;margin:.65rem 0 0 auto;border:0;border-radius:9px;background:#6655c7;color:#fff;padding:.55rem .8rem;font-weight:800}.tobe-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:#6655c7;color:#fff;font-weight:800}.tobe-practice:disabled{background:var(--color-verde)}
@media(max-width:760px){.tobe-summary>div{grid-template-columns:1fr 1fr}.connector-lab{grid-template-columns:1fr}.subject-picker{grid-template-columns:repeat(4,1fr)}}
@media(max-width:520px){.tobe-tabs{grid-template-columns:1fr}.tobe-summary>div,.status-board{grid-template-columns:1fr}.subject-picker{grid-template-columns:1fr 1fr}.sentence-parts{flex-wrap:wrap;justify-content:center}.contraction-toggle{grid-template-columns:auto 1fr}.contraction-toggle b{grid-column:1/-1}.tobe-panel{padding:.75rem}}
</style>
