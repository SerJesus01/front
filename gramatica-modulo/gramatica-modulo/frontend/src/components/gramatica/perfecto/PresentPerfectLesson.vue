<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({ mode: { type: String, required: true }, completado: { type: Boolean, default: false } });
const emit = defineEmits(['hablar', 'practicar']);

const paso = ref(1);
const sujetoId = ref('i');
const accionId = ref('finish');
const marcadorId = ref('already');
const duracionId = ref('two-years');
const retoIdx = ref(0);
const elegida = ref(null);
const aciertos = ref(new Set());

const sujetos = [
  { id: 'i', texto: 'I', auxiliar: 'have', icono: '🙋' },
  { id: 'you', texto: 'You', auxiliar: 'have', icono: '👉' },
  { id: 'she', texto: 'She', auxiliar: 'has', icono: '👩' },
  { id: 'he', texto: 'He', auxiliar: 'has', icono: '👨' },
  { id: 'we', texto: 'We', auxiliar: 'have', icono: '👥' },
  { id: 'they', texto: 'They', auxiliar: 'have', icono: '🧑‍🤝‍🧑' },
];
const acciones = [
  { id: 'finish', base: 'finish', participio: 'finished', objeto: 'the report', icono: '✅' },
  { id: 'eat', base: 'eat', participio: 'eaten', objeto: 'the apple', icono: '🍎' },
  { id: 'write', base: 'write', participio: 'written', objeto: 'the email', icono: '✉️' },
  { id: 'see', base: 'see', participio: 'seen', objeto: 'that movie', icono: '🎬' },
  { id: 'go', base: 'go', participio: 'gone', objeto: 'home', icono: '🏠' },
  { id: 'deploy', base: 'deploy', participio: 'deployed', objeto: 'the app', icono: '🚀' },
];
const marcadores = [
  { id: 'just', texto: 'just', pista: 'hace un instante', posicion: 'medio', icono: '⚡' },
  { id: 'already', texto: 'already', pista: 'antes de lo esperado', posicion: 'medio', icono: '✅' },
  { id: 'yet', texto: 'yet', pista: 'hasta ahora (pregunta/negativa)', posicion: 'final', icono: '⏳' },
];
const duraciones = [
  { id: 'two-years', valor: 'two years', inicio: '2024', icono: '🗓️' },
  { id: 'six-months', valor: 'six months', inicio: 'February', icono: '🌱' },
  { id: 'three-hours', valor: 'three hours', inicio: '9 a.m.', icono: '⏱️' },
];

const sujeto = computed(() => sujetos.find((x) => x.id === sujetoId.value));
const accion = computed(() => acciones.find((x) => x.id === accionId.value));
const marcador = computed(() => marcadores.find((x) => x.id === marcadorId.value));
const duracion = computed(() => duraciones.find((x) => x.id === duracionId.value));
const fraseBase = computed(() => `${sujeto.value.texto} ${sujeto.value.auxiliar} ${accion.value.participio} ${accion.value.objeto}.`);
const fraseMarcador = computed(() => marcador.value.posicion === 'medio'
  ? `${sujeto.value.texto} ${sujeto.value.auxiliar} ${marcador.value.texto} ${accion.value.participio} ${accion.value.objeto}.`
  : `${sujeto.value.auxiliar === 'has' ? 'Has' : 'Have'} ${sujeto.value.texto.toLowerCase()} ${accion.value.participio} ${accion.value.objeto} ${marcador.value.texto}?`);

const meta = computed(() => ({
  intro: { icono: '🌉', sobre: 'PASADO + PRESENTE', titulo: 'Presente perfecto: el puente', bajada: 'Algo ocurrió antes y su resultado importa ahora.', tabs: ['Construí el puente', 'Mapa de participios', 'Reto have / has'] },
  markers: { icono: '⚡', sobre: 'SEÑALES DE TIEMPO', titulo: 'Just, already y yet', bajada: 'Tres palabras pequeñas cambian el momento de la historia.', tabs: ['Laboratorio temporal', '¿Dónde se coloca?', 'Reto de señales'] },
  experience: { icono: '🧭', sobre: 'EXPERIENCIA Y DURACIÓN', titulo: 'Ever y how long', bajada: 'Preguntá si pasó alguna vez o desde hace cuánto continúa.', tabs: ['Radar de experiencias', 'Regla visual', 'Reto explorador'] },
  duration: { icono: '⏳', sobre: 'DURACIÓN Y ORIGEN', titulo: 'For, since y ago', bajada: 'Duración, punto de inicio o pasado terminado.', tabs: ['Línea de vida', 'Tres pistas', 'Reto del tiempo'] },
  contrast: { icono: '⚖️', sobre: 'ELEGÍ EL TIEMPO', titulo: 'Perfecto vs. pasado simple', bajada: 'Resultado vigente o momento pasado cerrado.', tabs: ['Detector temporal', 'Dos caminos', 'Reto de contraste'] },
}[props.mode]));

const retos = computed(() => ({
  intro: [
    { frase: 'She ___ finished the report.', respuesta: 'has', opciones: ['have', 'has', 'did', 'is'], ayuda: 'She usa has.' },
    { frase: 'We have ___ the email.', respuesta: 'written', opciones: ['wrote', 'write', 'written', 'writing'], ayuda: 'Después de have usamos el participio.' },
    { frase: 'I ___ seen that movie.', respuesta: 'have', opciones: ['am', 'did', 'has', 'have'], ayuda: 'I usa have.' },
  ],
  markers: [
    { frase: "I've ___ finished. It happened seconds ago.", respuesta: 'just', opciones: ['yet', 'ever', 'just', 'since'], ayuda: 'Just señala algo muy reciente.' },
    { frase: 'Have you eaten ___?', respuesta: 'yet', opciones: ['already', 'yet', 'just', 'for'], ayuda: 'Yet suele ir al final de preguntas.' },
    { frase: "She's ___ sent it, so don't send it again.", respuesta: 'already', opciones: ['ago', 'yet', 'already', 'ever'], ayuda: 'Already indica que ya ocurrió.' },
  ],
  experience: [
    { frase: 'Have you ___ visited London?', respuesta: 'ever', opciones: ['ever', 'for', 'ago', 'yet'], ayuda: 'Ever pregunta por una experiencia.' },
    { frase: '___ have you known her?', respuesta: 'How long', opciones: ['How many', 'When', 'How long', 'How often'], ayuda: 'How long pregunta duración.' },
    { frase: 'How long ___ he worked here?', respuesta: 'has', opciones: ['did', 'has', 'is', 'have'], ayuda: 'He usa has.' },
  ],
  duration: [
    { frase: "I've studied English ___ two years.", respuesta: 'for', opciones: ['since', 'ago', 'for', 'yet'], ayuda: 'For + cantidad de tiempo.' },
    { frase: "She's lived here ___ 2024.", respuesta: 'since', opciones: ['for', 'since', 'ago', 'just'], ayuda: 'Since + punto de inicio.' },
    { frase: 'We met three years ___.', respuesta: 'ago', opciones: ['for', 'since', 'ago', 'already'], ayuda: 'Ago acompaña al pasado simple.' },
  ],
  contrast: [
    { frase: 'I ___ the report yesterday.', respuesta: 'finished', opciones: ['have finished', 'finished', 'has finished', 'finish'], ayuda: 'Yesterday cierra el momento: pasado simple.' },
    { frase: "I've ___ the report, so we can send it now.", respuesta: 'finished', opciones: ['finish', 'finishing', 'finished', 'wrote'], ayuda: 'El resultado importa ahora: have + participio.' },
    { frase: 'She ___ the team in 2020.', respuesta: 'joined', opciones: ['has joined', 'joined', 'joins', 'have joined'], ayuda: 'In 2020 es un momento cerrado.' },
  ],
}[props.mode]));
const reto = computed(() => retos.value[retoIdx.value]);
const correcta = computed(() => elegida.value === reto.value.respuesta);

function escuchar(texto) { emit('hablar', texto, 1); }
function responder(opcion) {
  elegida.value = opcion;
  if (opcion === reto.value.respuesta) aciertos.value = new Set([...aciertos.value, retoIdx.value]);
}
function siguiente() { retoIdx.value = (retoIdx.value + 1) % retos.value.length; elegida.value = null; }
watch(() => props.mode, () => { paso.value = 1; retoIdx.value = 0; elegida.value = null; aciertos.value = new Set(); });
</script>

<template>
  <section class="perfect">
    <aside class="hero"><span>{{ meta.icono }}</span><div><small>{{ meta.sobre }}</small><h2>{{ meta.titulo }}</h2><p>{{ meta.bajada }}</p></div><div class="bridge"><b>PAST</b><i>━━━</i><span>NOW</span></div></aside>
    <nav><button v-for="(tab, i) in meta.tabs" :key="tab" :class="{ active: paso === i + 1 }" @click="paso = i + 1"><b>0{{ i + 1 }}</b><span>{{ tab }}</span></button></nav>

    <main v-if="paso === 1 && mode === 'intro'"><header><small>PUENTE 1</small><h3>Constructor de resultados</h3><p>Combiná persona y acción. El participio cruza del pasado hasta ahora.</p></header><div class="picker"><section><button v-for="x in sujetos" :key="x.id" :class="{ active: sujetoId === x.id }" @click="sujetoId = x.id">{{ x.icono }} <b>{{ x.texto }}</b></button></section><section><button v-for="x in acciones" :key="x.id" :class="{ active: accionId === x.id }" @click="accionId = x.id">{{ x.icono }} <b>{{ x.participio }}</b></button></section></div><article class="result"><span>{{ sujeto.icono }} ━━ {{ accion.icono }} ━━ ✨</span><small>RESULTADO VIGENTE</small><strong>{{ fraseBase }}</strong><button @click="escuchar(fraseBase)">🔊 Escuchar</button></article></main>
    <main v-else-if="paso === 1 && mode === 'markers'"><header><small>SEÑALES 1</small><h3>Control del tiempo</h3><p>Elegí una señal y mirá cómo encuentra su lugar en la oración.</p></header><div class="marker-grid"><button v-for="x in marcadores" :key="x.id" :class="{ active: marcadorId === x.id }" @click="marcadorId = x.id"><span>{{ x.icono }}</span><b>{{ x.texto }}</b><small>{{ x.pista }}</small></button></div><article class="result"><span>{{ marcador.icono }} {{ accion.icono }}</span><strong>{{ fraseMarcador }}</strong><button @click="escuchar(fraseMarcador)">🔊 Escuchar</button></article></main>
    <main v-else-if="paso === 1 && mode === 'experience'"><header><small>RADAR 1</small><h3>¿Experiencia o duración?</h3><p>Dos preguntas abren puertas diferentes.</p></header><div class="doors"><button @click="escuchar('Have you ever seen that movie?')"><span>🧭</span><small>ALGUNA VEZ</small><b>Have you ever…?</b><em>experiencia de vida</em></button><button @click="escuchar('How long have you studied English?')"><span>⏱️</span><small>DESDE HACE CUÁNTO</small><b>How long have you…?</b><em>continúa hasta ahora</em></button></div><aside class="note"><b>Have/Has</b> + sujeto + participio. Con <b>how long</b>, la respuesta suele usar for o since.</aside></main>
    <main v-else-if="paso === 1 && mode === 'duration'"><header><small>TIEMPO 1</small><h3>Línea de vida</h3><p>Elegí una duración para ver la diferencia entre cuánto y desde cuándo.</p></header><div class="duration-picker"><button v-for="x in duraciones" :key="x.id" :class="{ active: duracionId === x.id }" @click="duracionId = x.id">{{ x.icono }} {{ x.valor }}</button></div><div class="life-line"><span>{{ duracion.inicio }}</span><i>━━━━━━━━━━━━━━▶</i><b>NOW</b></div><div class="twins"><button @click="escuchar(`I have studied English for ${duracion.valor}.`)"><small>DURACIÓN</small><b>I have studied English <mark>for {{ duracion.valor }}</mark>.</b> 🔊</button><button @click="escuchar(`I have studied English since ${duracion.inicio}.`)"><small>INICIO</small><b>I have studied English <mark>since {{ duracion.inicio }}</mark>.</b> 🔊</button></div></main>
    <main v-else-if="paso === 1 && mode === 'contrast'"><header><small>DETECTOR 1</small><h3>Buscá la pista temporal</h3><p>La pista decide qué camino tomar.</p></header><div class="detector"><article><span>📍</span><small>MOMENTO CERRADO</small><b>yesterday · last week · in 2020</b><strong>PAST SIMPLE</strong></article><i>VS</i><article><span>✨</span><small>RESULTADO AHORA</small><b>already · yet · since · no exact time</b><strong>PRESENT PERFECT</strong></article></div><div class="twins"><button @click="escuchar('I fixed the bug yesterday.')"><b>I fixed the bug <mark>yesterday</mark>.</b> 🔊</button><button @click="escuchar('I have fixed the bug, so it works now.')"><b>I have fixed the bug, <mark>so it works now</mark>.</b> 🔊</button></div></main>

    <main v-else-if="paso === 2"><header><small>{{ meta.sobre }} · MAPA</small><h3>{{ meta.tabs[1] }}</h3><p>Una referencia visual rápida para decidir sin memorizar párrafos.</p></header><div v-if="mode === 'intro'" class="formula"><b>subject</b><i>＋</i><strong>have / has</strong><i>＋</i><b>past participle</b></div><div v-if="mode === 'intro'" class="participle-grid"><span v-for="x in acciones" :key="x.id"><b>{{ x.base }}</b><i>→</i><strong>{{ x.participio }}</strong></span></div><div v-else-if="mode === 'markers'" class="position-map"><span><b>have / has</b></span><mark>just / already</mark><span><b>participle</b></span><i>…</i><mark>yet?</mark></div><div v-else-if="mode === 'experience'" class="formula vertical"><b>Have you <mark>ever</mark> + participle?</b><strong>How long have you + participle?</strong></div><div v-else-if="mode === 'duration'" class="clue-grid"><article><b>FOR</b><span>una cantidad</span><small>for two hours</small></article><article><b>SINCE</b><span>un punto inicial</span><small>since Monday</small></article><article><b>AGO</b><span>pasado cerrado</span><small>two hours ago</small></article></div><div v-else class="detector compact"><article><span>📅</span><b>¿Dice cuándo?</b><strong>Past simple</strong></article><article><span>🌉</span><b>¿Importa el resultado ahora?</b><strong>Present perfect</strong></article></div><aside class="note"><b>Atajo:</b> leé primero la señal temporal; después elegí la estructura.</aside></main>

    <main v-else><header class="challenge-head"><div><small>{{ meta.sobre }} · RETO</small><h3>{{ meta.tabs[2] }}</h3><p>Leé la pista antes de elegir.</p></div><b>{{ aciertos.size }}/{{ retos.length }}</b></header><article class="challenge"><span>{{ meta.icono }}</span><button @click="escuchar(reto.frase.replace('___', reto.respuesta))">{{ reto.frase }} 🔊</button><div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: elegida && opcion === reto.respuesta, bad: elegida === opcion && opcion !== reto.respuesta }" @click="responder(opcion)">{{ opcion }}</button></div><p v-if="elegida"><b>{{ correcta ? '✓ Puente conectado' : '↻ Mirá la señal otra vez' }}</b> {{ reto.ayuda }}</p><button v-if="correcta" class="next" @click="siguiente">Siguiente desafío →</button></article></main>

    <button class="practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.perfect{display:grid;gap:1rem;--accent:#7656a8;--soft:#f3edff;--mint:#e8f8f1}.hero,main{padding:1rem;border:1px solid #d9c9eb;border-radius:18px;background:#fff}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.8rem;background:linear-gradient(135deg,var(--soft),var(--mint))}.hero>span{font-size:2.7rem}.hero h2,main h3{margin:.15rem 0}.hero p,main header p{margin:.25rem 0;color:var(--color-texto-secundario)}small{font-size:.62rem;font-weight:900;letter-spacing:.08em;color:var(--accent)}.bridge{display:flex;align-items:center;gap:.3rem;padding:.6rem;border:1px dashed var(--accent);border-radius:11px;color:var(--accent);font-size:.65rem}.bridge i{color:#c18f43}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}nav button{display:flex;gap:.5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:12px;background:#fff;text-align:left}nav button b{color:var(--accent)}nav button.active{border-color:var(--accent);background:var(--soft)}.picker{display:grid;gap:.6rem}.picker section{display:flex;flex-wrap:wrap;gap:.4rem}.picker button,.duration-picker button{padding:.5rem .65rem;border:1px solid var(--color-borde);border-radius:9px;background:#fff}.active{border-color:var(--accent)!important;background:var(--soft)!important}.result{display:flex;flex-direction:column;align-items:center;gap:.25rem;margin-top:.8rem;padding:1rem;border-radius:15px;background:linear-gradient(145deg,var(--soft),var(--mint));text-align:center}.result>span{font-size:2rem}.result strong{font:italic 1.2rem Georgia}.result button,.next{padding:.5rem .75rem;border:0;border-radius:8px;background:var(--accent);color:#fff}.marker-grid,.doors,.twins{display:grid;grid-template-columns:repeat(3,1fr);gap:.6rem}.marker-grid button,.doors button,.twins button{display:flex;flex-direction:column;gap:.25rem;padding:.8rem;border:1px solid var(--color-borde);border-radius:12px;background:#fff;text-align:left}.marker-grid span,.doors span{font-size:1.8rem}.doors{grid-template-columns:1fr 1fr}.doors button{background:linear-gradient(145deg,#fff,var(--soft))}.doors em{font-size:.7rem;color:var(--color-texto-secundario)}.note{margin-top:.7rem;padding:.7rem;border-left:4px solid var(--accent);border-radius:8px;background:var(--soft);font-size:.75rem}.duration-picker{display:flex;flex-wrap:wrap;gap:.4rem}.life-line{display:flex;align-items:center;justify-content:center;gap:.6rem;margin:.8rem 0;padding:1rem;border-radius:14px;background:var(--mint);color:var(--accent)}.life-line i{flex:1;text-align:center}.twins{grid-template-columns:1fr 1fr}.twins mark,.position-map mark,.vertical mark{padding:.1rem .25rem;border-radius:5px;background:#ffe4a8}.detector{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.6rem}.detector article{display:flex;flex-direction:column;gap:.3rem;padding:1rem;border-radius:14px;background:var(--soft);text-align:center}.detector article>span{font-size:2rem}.detector article>strong{color:var(--accent)}.formula,.position-map{display:flex;align-items:center;justify-content:center;gap:.7rem;padding:1rem;border-radius:14px;background:var(--mint)}.formula strong{font:italic 1.3rem Georgia;color:var(--accent)}.vertical{flex-direction:column}.participle-grid,.clue-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem;margin:.7rem 0}.participle-grid span,.clue-grid article{display:flex;flex-direction:column;padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;text-align:center}.participle-grid i{color:var(--accent)}.clue-grid article b{font-size:1.2rem;color:var(--accent)}.compact{grid-template-columns:1fr 1fr;margin-bottom:.7rem}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:650px;margin:auto;padding:1rem;border-radius:16px;background:linear-gradient(145deg,var(--soft),var(--mint));text-align:center}.challenge>span{font-size:2.7rem}.challenge>button{display:block;margin:.4rem auto;border:0;background:transparent;font:italic 1.15rem Georgia}.challenge>div{display:grid;grid-template-columns:1fr 1fr;gap:.4rem}.challenge>div button{padding:.6rem;border:1px solid var(--color-borde);border-radius:9px;background:#fff}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:#d26b54;background:#fff0ea}.practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff;font-weight:800}.practice:disabled{background:var(--color-verde)}
@media(max-width:650px){.hero{grid-template-columns:auto 1fr}.bridge{grid-column:1/-1;justify-content:center}nav,.marker-grid,.doors,.twins,.participle-grid,.clue-grid,.detector,.compact,.challenge>div{grid-template-columns:1fr}.detector>i{text-align:center}.position-map{flex-wrap:wrap}.life-line{font-size:.72rem}}
</style>
