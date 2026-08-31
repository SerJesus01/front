<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({ mode: { type: String, required: true }, completado: { type: Boolean, default: false } });
const emit = defineEmits(['hablar', 'practicar']);

const paso = ref(1);
const escenaId = ref('bread');
const retoIdx = ref(0);
const elegida = ref(null);
const aciertos = ref(new Set());
const mostrarAgente = ref(false);

const escenas = [
  { id: 'bread', icono: '🍞', objeto: 'The bread', singular: true, participio: 'baked', agente: 'my mother', presente: 'every morning', pasado: 'this morning', activaPresente: 'My mother bakes the bread every morning.', activaPasado: 'My mother baked the bread this morning.' },
  { id: 'rooms', icono: '🛏️', objeto: 'The rooms', singular: false, participio: 'cleaned', agente: 'the family', presente: 'every day', pasado: 'yesterday', activaPresente: 'The family cleans the rooms every day.', activaPasado: 'The family cleaned the rooms yesterday.' },
  { id: 'mail', icono: '📬', objeto: 'The mail', singular: true, participio: 'delivered', agente: 'Ana', presente: 'at noon', pasado: 'at noon yesterday', activaPresente: 'Ana delivers the mail at noon.', activaPasado: 'Ana delivered the mail at noon yesterday.' },
  { id: 'oranges', icono: '🍊', objeto: 'Oranges', singular: false, participio: 'grown', agente: 'my grandparents', presente: 'in their garden', pasado: 'in their garden', activaPresente: 'My grandparents grow oranges in their garden.', activaPasado: 'My grandparents grew oranges in their garden.' },
  { id: 'car', icono: '🚗', objeto: 'The car', singular: true, participio: 'washed', agente: 'Leo', presente: 'every Saturday', pasado: 'last Saturday', activaPresente: 'Leo washes the car every Saturday.', activaPasado: 'Leo washed the car last Saturday.' },
];

const escena = computed(() => escenas.find((item) => item.id === escenaId.value));
const auxiliar = computed(() => props.mode === 'present'
  ? (escena.value.singular ? 'is' : 'are')
  : (escena.value.singular ? 'was' : 'were'));
const momento = computed(() => props.mode === 'present' ? escena.value.presente : escena.value.pasado);
const activa = computed(() => props.mode === 'present' ? escena.value.activaPresente : escena.value.activaPasado);
const pasiva = computed(() => `${escena.value.objeto} ${auxiliar.value} ${escena.value.participio} ${mostrarAgente.value ? `by ${escena.value.agente} ` : ''}${momento.value}.`);
const meta = computed(() => props.mode === 'present'
  ? { icono: '🔄', sobre: 'HÁBITOS Y PROCESOS', titulo: 'Voz pasiva en presente', bajada: 'El foco pasa de quien hace la acción a quien la recibe.', tabs: ['Cambiá el foco', 'Mapa is / are', 'Reto del presente'] }
  : { icono: '📜', sobre: 'HECHOS TERMINADOS', titulo: 'Voz pasiva en pasado', bajada: 'Contá qué ocurrió aunque no sepas o no importe quién lo hizo.', tabs: ['Reconstruí el hecho', 'Mapa was / were', 'Reto del pasado'] });

const retos = computed(() => props.mode === 'present' ? [
  { icono: '🍞', frase: 'The bread ___ every morning.', respuesta: 'is baked', opciones: ['bakes', 'is baked', 'are baked', 'was baked'], ayuda: 'Bread es singular: is + baked.' },
  { icono: '🛏️', frase: 'The rooms ___ every day.', respuesta: 'are cleaned', opciones: ['clean', 'is cleaned', 'are cleaned', 'were cleaned'], ayuda: 'Rooms es plural: are + cleaned.' },
  { icono: '🍊', frase: 'Oranges ___ in their garden.', respuesta: 'are grown', opciones: ['grow', 'is grown', 'are grown', 'were grown'], ayuda: 'Oranges es plural; grow cambia a grown.' },
  { icono: '📬', frase: 'The mail ___ at noon.', respuesta: 'is delivered', opciones: ['delivers', 'is delivered', 'are delivered', 'was delivered'], ayuda: 'The mail es singular: is + delivered.' },
] : [
  { icono: '🎂', frase: 'The cake ___ yesterday.', respuesta: 'was made', opciones: ['made', 'is made', 'was made', 'were made'], ayuda: 'Cake es singular: was + made.' },
  { icono: '🧱', frase: 'The walls ___ last year.', respuesta: 'were painted', opciones: ['painted', 'was painted', 'were painted', 'are painted'], ayuda: 'Walls es plural: were + painted.' },
  { icono: '🔑', frase: 'The keys ___ under the sofa.', respuesta: 'were found', opciones: ['found', 'was found', 'were found', 'are found'], ayuda: 'Keys es plural: were + found.' },
  { icono: '🏠', frase: 'The roof ___ by the storm.', respuesta: 'was damaged', opciones: ['damaged', 'was damaged', 'were damaged', 'is damaged'], ayuda: 'Roof es singular: was + damaged.' },
]);
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
  <section class="passive" :class="`passive--${mode}`">
    <aside class="hero"><span>{{ meta.icono }}</span><div><small>ADULTO ESTÁNDAR · {{ meta.sobre }}</small><h2>{{ meta.titulo }}</h2><p>{{ meta.bajada }}</p></div><div class="focus-badge"><b>OBJETO</b><i>→</i><span>FOCO</span></div></aside>
    <nav><button v-for="(tab, index) in meta.tabs" :key="tab" :class="{ active: paso === index + 1 }" @click="paso = index + 1"><b>0{{ index + 1 }}</b><span>{{ tab }}</span></button></nav>

    <main v-if="paso === 1"><header><small>{{ mode === 'present' ? 'PASIVA PRESENTE 1' : 'PASIVA PASADO 1' }}</small><h3>La cámara cambia de protagonista</h3><p>Elegí una escena y observá cómo quien recibe la acción pasa al frente.</p></header><div class="scene-picker"><button v-for="item in escenas" :key="item.id" :class="{ active: escenaId === item.id }" @click="escenaId = item.id"><span>{{ item.icono }}</span><b>{{ item.objeto }}</b></button></div><div class="transform-stage"><article><small>VOZ ACTIVA</small><span>👤</span><b>{{ activa }}</b><em>Importa quién hace la acción</em></article><i>CAMBIAR FOCO<br>⇄</i><article class="passive-card"><small>VOZ PASIVA</small><span>{{ escena.icono }}</span><b>{{ pasiva }}</b><em>Importa lo que recibe la acción</em><button @click="escuchar(pasiva)">🔊 Escuchar</button></article></div><label class="agent-toggle"><input v-model="mostrarAgente" type="checkbox"><span>Mostrar quién realizó la acción con <b>by</b></span><strong>{{ mostrarAgente ? `by ${escena.agente}` : 'El agente se omite' }}</strong></label></main>

    <main v-else-if="paso === 2"><header><small>{{ mode === 'present' ? 'PASIVA PRESENTE 2' : 'PASIVA PASADO 2' }}</small><h3>{{ meta.tabs[1] }}</h3><p>El auxiliar concuerda con lo que ahora ocupa el primer lugar.</p></header><div class="formula"><b>receiver</b><i>＋</i><strong>{{ mode === 'present' ? 'am / is / are' : 'was / were' }}</strong><i>＋</i><b>past participle</b><i>＋</i><span>(by + agent)</span></div><div class="number-map"><article><span>☝️</span><small>SINGULAR</small><b>{{ mode === 'present' ? 'IS' : 'WAS' }}</b><p>The cake {{ mode === 'present' ? 'is made' : 'was made' }}.</p></article><article><span>✌️</span><small>PLURAL</small><b>{{ mode === 'present' ? 'ARE' : 'WERE' }}</b><p>The cakes {{ mode === 'present' ? 'are made' : 'were made' }}.</p></article></div><aside class="note"><b>“By” es opcional:</b> agregalo solo cuando saber quién hizo la acción aporta información importante.</aside></main>

    <main v-else><header class="challenge-head"><div><small>{{ meta.sobre }} · RETO</small><h3>{{ meta.tabs[2] }}</h3><p>Primero mirá si el nuevo sujeto es singular o plural.</p></div><b>{{ aciertos.size }}/{{ retos.length }}</b></header><article class="challenge"><span>{{ reto.icono }}</span><button @click="escuchar(reto.frase.replace('___', reto.respuesta))">{{ reto.frase }} 🔊</button><div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: elegida && opcion === reto.respuesta, bad: elegida === opcion && opcion !== reto.respuesta }" @click="responder(opcion)">{{ opcion }}</button></div><p v-if="elegida"><b>{{ correcta ? '✓ Foco correcto' : '↻ Revisá número y tiempo' }}</b> {{ reto.ayuda }}</p><button v-if="correcta" class="next" @click="siguiente">Siguiente escena →</button></article></main>

    <button class="practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.passive{display:grid;gap:1rem;--accent:#357267;--soft:#eaf6f2;--warm:#fff2df}.passive--past{--accent:#765a91;--soft:#f1ecf7;--warm:#edf4ff}.hero,main{padding:1rem;border:1px solid #cddfd9;border-radius:var(--radio-panel);background:var(--color-superficie)}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.8rem;background:linear-gradient(135deg,var(--soft),var(--warm))}.hero>span{font-size:2.7rem}.hero h2,main h3{margin:.15rem 0}.hero p,main header p{margin:.25rem 0;color:var(--color-texto-secundario)}small{font-size:.62rem;font-weight:900;letter-spacing:.08em;color:var(--accent)}.focus-badge{display:flex;align-items:center;gap:.35rem;padding:.6rem;border:1px dashed var(--accent);border-radius:10px;color:var(--accent);font-size:.64rem}.focus-badge i{font-size:1.1rem}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}nav button{display:flex;gap:.5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:12px;background:var(--color-superficie);text-align:left}nav button b{color:var(--accent)}nav button.active,.scene-picker button.active{border-color:var(--accent);background:var(--soft)}.scene-picker{display:grid;grid-template-columns:repeat(5,1fr);gap:.4rem}.scene-picker button{display:flex;flex-direction:column;align-items:center;padding:.55rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie)}.scene-picker button span{font-size:1.5rem}.scene-picker button b{font-size:.68rem}.transform-stage{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.7rem;margin-top:.8rem}.transform-stage article{display:flex;flex-direction:column;align-items:center;gap:.3rem;min-height:190px;justify-content:center;padding:1rem;border-radius:15px;background:var(--color-fondo-suave);text-align:center}.transform-stage article>span{font-size:2.2rem}.transform-stage article>b{font:italic 1rem Georgia,serif}.transform-stage article>em{font-size:.68rem;color:var(--color-texto-tenue)}.transform-stage>i{font-size:.62rem;font-weight:900;text-align:center;color:var(--accent)}.transform-stage .passive-card{background:linear-gradient(145deg,var(--soft),var(--warm));box-shadow:var(--sombra-card)}.passive-card button{padding:.45rem .7rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.agent-toggle{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.55rem;margin-top:.7rem;padding:.7rem;border-radius:11px;background:var(--soft);font-size:.75rem}.agent-toggle input{accent-color:var(--accent)}.agent-toggle strong{color:var(--accent)}.formula{display:flex;justify-content:center;align-items:center;gap:.6rem;padding:1rem;border-radius:14px;background:var(--soft);text-align:center}.formula strong{font:italic 1.2rem Georgia;color:var(--accent)}.number-map{display:grid;grid-template-columns:1fr 1fr;gap:.7rem;margin:.8rem 0}.number-map article{display:flex;flex-direction:column;align-items:center;padding:1rem;border:1px solid var(--color-borde);border-radius:14px;background:var(--color-superficie)}.number-map article>span{font-size:2rem}.number-map article>b{font-size:1.4rem;color:var(--accent)}.number-map p{margin:.3rem;font:italic .9rem Georgia}.note{padding:.7rem;border-left:4px solid var(--accent);border-radius:8px;background:var(--warm);font-size:.76rem}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:650px;margin:auto;padding:1rem;border-radius:16px;background:linear-gradient(145deg,var(--soft),var(--warm));text-align:center}.challenge>span{font-size:2.7rem}.challenge>button{display:block;margin:.4rem auto;border:0;background:transparent;font:italic 1.15rem Georgia}.challenge>div{display:grid;grid-template-columns:1fr 1fr;gap:.4rem}.challenge>div button{padding:.6rem;border:1px solid var(--color-borde);border-radius:9px;background:var(--color-superficie)}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:var(--color-rojo);background:var(--color-rojo-suave)}.next{padding:.55rem .8rem!important;background:var(--accent)!important;color:#fff!important}.practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff;font-weight:800}.practice:disabled{background:var(--color-verde)}
@media(max-width:680px){.scene-picker{grid-template-columns:repeat(3,1fr)}.transform-stage{grid-template-columns:1fr}.transform-stage>i{transform:rotate(90deg)}.formula{flex-wrap:wrap}}@media(max-width:500px){.hero{grid-template-columns:auto 1fr}.focus-badge{grid-column:1/-1;justify-content:center}nav,.number-map,.challenge>div{grid-template-columns:1fr}.scene-picker{grid-template-columns:1fr 1fr}.agent-toggle{grid-template-columns:auto 1fr}.agent-toggle strong{grid-column:1/-1}}
</style>
