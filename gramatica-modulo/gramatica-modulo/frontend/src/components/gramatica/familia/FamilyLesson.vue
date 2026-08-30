<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  items: { type: Array, default: () => [] },
  reproduciendoId: { type: [Number, String], default: null },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['reproducir', 'hablar', 'practicar']);

const leccion = ref(1);
const personaActiva = ref('maya');
const perspectiva = ref('alex');
const retoActual = ref(0);
const respuestaElegida = ref(null);
const aciertos = ref(new Set());
const albumPersona = ref('mom');

const personas = [
  { id: 'grandpa', nombre: 'George', rol: 'Grandpa', formal: 'grandfather', icono: '👴', nivel: 'grandparents' },
  { id: 'grandma', nombre: 'Rosa', rol: 'Grandma', formal: 'grandmother', icono: '👵', nivel: 'grandparents' },
  { id: 'dad', nombre: 'David', rol: 'Dad', formal: 'father', icono: '👨', nivel: 'parents' },
  { id: 'mom', nombre: 'Lisa', rol: 'Mom', formal: 'mother', icono: '👩', nivel: 'parents' },
  { id: 'uncle', nombre: 'Mark', rol: 'Uncle', formal: 'uncle', icono: '🧔', nivel: 'parents' },
  { id: 'auntie', nombre: 'Ana', rol: 'Auntie', formal: 'aunt', icono: '👩‍🦱', nivel: 'parents' },
  { id: 'alex', nombre: 'Alex', rol: 'Bro', formal: 'brother', icono: '🧑', nivel: 'kids' },
  { id: 'maya', nombre: 'Maya', rol: 'Sis', formal: 'sister', icono: '👧', nivel: 'kids' },
  { id: 'leo', nombre: 'Leo', rol: 'Cousin', formal: 'cousin', icono: '👦', nivel: 'kids' },
];

const relaciones = {
  alex: { grandpa: 'grandpa', grandma: 'grandma', dad: 'dad', mom: 'mom', maya: 'sis', uncle: 'uncle', auntie: 'auntie', leo: 'cousin', alex: 'me' },
  maya: { grandpa: 'grandpa', grandma: 'grandma', dad: 'dad', mom: 'mom', alex: 'bro', uncle: 'uncle', auntie: 'auntie', leo: 'cousin', maya: 'me' },
  grandma: { grandpa: 'husband', dad: 'son', mom: 'daughter-in-law', uncle: 'son', auntie: 'daughter-in-law', alex: 'grandkid', maya: 'grandkid', leo: 'grandkid', grandma: 'me' },
};

const seleccionada = computed(() => personas.find((item) => item.id === personaActiva.value));
const relacionActual = computed(() => relaciones[perspectiva.value]?.[personaActiva.value] || seleccionada.value?.rol.toLowerCase());
const presentacion = computed(() => {
  if (personaActiva.value === perspectiva.value) return `I'm ${seleccionada.value.nombre}.`;
  return `This is my ${relacionActual.value}, ${seleccionada.value.nombre}.`;
});

const vocabulario = [
  { id: 'mom', formal: 'mother', casual: 'mom', icono: '👩', nota: 'La forma cotidiana más común' },
  { id: 'dad', formal: 'father', casual: 'dad', icono: '👨', nota: 'Cotidiano y afectuoso' },
  { id: 'grandma', formal: 'grandmother', casual: 'grandma', icono: '👵', nota: 'Muy común en familia' },
  { id: 'grandpa', formal: 'grandfather', casual: 'grandpa', icono: '👴', nota: 'Muy común en familia' },
  { id: 'bro', formal: 'brother', casual: 'bro', icono: '🧑', nota: 'Muy informal' },
  { id: 'sis', formal: 'sister', casual: 'sis', icono: '👧', nota: 'Muy informal' },
  { id: 'auntie', formal: 'aunt', casual: 'auntie', icono: '👩‍🦱', nota: 'Cariñoso' },
  { id: 'grandkids', formal: 'grandchildren', casual: 'grandkids', icono: '🧒', nota: 'Cotidiano' },
];
const albumActiva = computed(() => vocabulario.find((item) => item.id === albumPersona.value));

const retos = [
  { icono: '🎂', pista: 'La mamá de mi mamá', frase: 'Rosa is my ___.', respuesta: 'grandma', opciones: ['grandma', 'auntie', 'sis', 'cousin'], explicacion: 'La madre de tu mamá o papá es tu grandma.' },
  { icono: '🎮', pista: 'Mi hermano, de forma muy casual', frase: 'This is my ___, Alex.', respuesta: 'bro', opciones: ['uncle', 'bro', 'dad', 'grandpa'], explicacion: 'Bro es una forma muy informal de brother.' },
  { icono: '🏖️', pista: 'El hijo de mi tía y mi tío', frase: 'Leo is my ___.', respuesta: 'cousin', opciones: ['grandkid', 'cousin', 'bro', 'uncle'], explicacion: 'Cousin funciona para primo y prima.' },
  { icono: '💐', pista: 'Mi tía, con cariño', frase: 'This is my ___ Ana.', respuesta: 'auntie', opciones: ['sis', 'mom', 'auntie', 'grandma'], explicacion: 'Auntie es una forma cariñosa de aunt.' },
  { icono: '🏡', pista: 'Cómo llama Rosa a Alex, Maya y Leo', frase: 'They are my ___.', respuesta: 'grandkids', opciones: ['cousins', 'grandkids', 'siblings', 'parents'], explicacion: 'Grandkids es la forma cotidiana de grandchildren.' },
];
const reto = computed(() => retos[retoActual.value]);
const respuestaCorrecta = computed(() => respuestaElegida.value === reto.value.respuesta);
const totalAciertos = computed(() => aciertos.value.size);

function normalizar(texto) { return String(texto || '').toLowerCase().replace(/[^a-z]/g, ''); }
function escuchar(texto) {
  const referencia = props.items.find((item) => normalizar(item.texto_en) === normalizar(texto));
  if (referencia?.audio_key) emit('reproducir', referencia);
  else emit('hablar', texto, 1);
}
function elegirPersona(id) { personaActiva.value = id; escuchar(personas.find((item) => item.id === id).rol); }
function responder(opcion) {
  respuestaElegida.value = opcion;
  if (opcion === reto.value.respuesta) { const nuevos = new Set(aciertos.value); nuevos.add(retoActual.value); aciertos.value = nuevos; }
}
function siguienteReto() { retoActual.value = (retoActual.value + 1) % retos.length; respuestaElegida.value = null; }
</script>

<template>
  <section class="family-lesson">
    <aside class="family-summary">
      <header><span>🏡</span><div><small>MAPA RÁPIDO</small><h2>La familia como se dice en casa</h2></div></header>
      <p>Las formas cortas expresan cercanía: <b>mom</b>, <b>dad</b>, <b>grandma</b> y <b>grandpa</b> son cotidianas; <b>bro</b> y <b>sis</b> son mucho más informales.</p>
      <div><article><b>mother → mom</b><span>cotidiano</span></article><article><b>father → dad</b><span>cotidiano</span></article><article><b>brother → bro</b><span>muy casual</span></article><article><b>sister → sis</b><span>muy casual</span></article></div>
    </aside>

    <nav class="family-tabs">
      <button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero">
        <b>0{{ numero }}</b><span>{{ numero === 1 ? 'Árbol familiar' : numero === 2 ? 'Álbum coloquial' : '¿Quién es quién?' }}</span><small>{{ numero === 1 ? 'Cambiá la perspectiva' : numero === 2 ? 'Formal vs. cotidiano' : 'Reto por pistas' }}</small>
      </button>
    </nav>

    <section v-if="leccion === 1" class="family-panel">
      <header><small>FAMILIA 1</small><h3>Un árbol, distintas perspectivas</h3><p>Elegí quién cuenta la historia y tocá a otra persona para descubrir la relación.</p></header>
      <div class="perspective-picker"><span>Estoy viendo la familia como:</span><button v-for="id in ['alex','maya','grandma']" :key="id" :class="{ active: perspectiva === id }" @click="perspectiva = id; personaActiva = id"><span>{{ personas.find((p) => p.id === id).icono }}</span>{{ personas.find((p) => p.id === id).nombre }}</button></div>
      <div class="family-tree">
        <div v-for="nivel in ['grandparents','parents','kids']" :key="nivel" class="tree-level" :class="nivel">
          <button v-for="persona in personas.filter((item) => item.nivel === nivel)" :key="persona.id" :class="{ active: personaActiva === persona.id, narrator: perspectiva === persona.id }" @click="elegirPersona(persona.id)">
            <span>{{ persona.icono }}</span><b>{{ persona.nombre }}</b><small>{{ perspectiva === persona.id ? 'Yo' : relaciones[perspectiva]?.[persona.id] || persona.rol }}</small>
          </button>
        </div>
      </div>
      <div class="family-sentence"><span>{{ seleccionada.icono }}</span><div><small>ASÍ LO PRESENTÁS</small><strong>{{ presentacion }}</strong></div><button @click="escuchar(presentacion)">🔊 Escuchar</button></div>
    </section>

    <section v-else-if="leccion === 2" class="family-panel">
      <header><small>FAMILIA 2</small><h3>Álbum de palabras cotidianas</h3><p>Compará la forma completa con la que escucharás en una conversación familiar.</p></header>
      <div class="family-album">
        <div class="album-grid"><button v-for="item in vocabulario" :key="item.id" :class="{ active: albumPersona === item.id }" @click="albumPersona = item.id; escuchar(item.casual)"><span>{{ item.icono }}</span><b>{{ item.casual }}</b><small>{{ item.formal }}</small></button></div>
        <div class="album-card"><span>{{ albumActiva.icono }}</span><small>EN CONVERSACIÓN</small><strong>{{ albumActiva.casual }}</strong><p>{{ albumActiva.formal }} → {{ albumActiva.casual }}</p><i>{{ albumActiva.nota }}</i><button @click="escuchar(albumActiva.casual)">🔊 Escuchar</button></div>
      </div>
      <div class="family-warning"><span>🗣️</span><p><b>Mom / Dad</b> son naturales al hablar de tus padres. <b>Bro / Sis</b> son muy casuales: usalos con confianza y en contextos informales.</p></div>
    </section>

    <section v-else class="family-panel">
      <header class="family-challenge-head"><div><small>FAMILIA 3</small><h3>¿Quién es quién?</h3><p>Usá la pista y completá la frase.</p></div><strong>{{ totalAciertos }}/{{ retos.length }}</strong></header>
      <div class="family-challenge">
        <span class="challenge-icon">{{ reto.icono }}</span><small>PISTA</small><h4>{{ reto.pista }}</h4><button class="challenge-phrase" @click="escuchar(reto.frase.replace('___', reto.respuesta))">{{ reto.frase }} <i>🔊</i></button>
        <div class="family-options"><button v-for="opcion in reto.opciones" :key="opcion" :class="{ correct: respuestaElegida && opcion === reto.respuesta, wrong: respuestaElegida === opcion && opcion !== reto.respuesta }" :disabled="respuestaCorrecta" @click="responder(opcion)">{{ opcion }}</button></div>
        <div v-if="respuestaElegida" class="family-feedback" :class="respuestaCorrecta ? 'ok' : 'retry'"><b>{{ respuestaCorrecta ? '✓ ¡Encontraste la relación!' : '↻ Mirá otra vez la pista' }}</b><span>{{ reto.explicacion }}</span></div>
        <button v-if="respuestaCorrecta" class="next-family" @click="siguienteReto">Siguiente familia →</button>
      </div>
    </section>

    <button class="family-practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.family-lesson{display:grid;gap:1rem}.family-summary{padding:1rem;border:1px solid #bfe1cf;border-left:5px solid #2f9b68;border-radius:18px;background:linear-gradient(135deg,#effaf4,#fff8e8)}.family-summary header{display:flex;align-items:center;gap:.7rem}.family-summary header>span{font-size:2.2rem}.family-summary h2,.family-panel h3{margin:.15rem 0}.family-summary small,.family-panel header>small,.family-challenge-head small{font-size:.65rem;font-weight:900;letter-spacing:.09em;color:#21825a}.family-summary>p{margin:.7rem 0;padding:.6rem;border-radius:10px;background:#fff;font-size:.83rem}.family-summary>div{display:grid;grid-template-columns:repeat(4,1fr);gap:.45rem}.family-summary article{display:flex;flex-direction:column;padding:.6rem;border-radius:10px;background:#fff}.family-summary article b{color:#237a57}.family-summary article span{font-size:.65rem;color:var(--color-texto-tenue)}.family-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.family-tabs button{display:grid;grid-template-columns:34px 1fr;border:1px solid var(--color-borde);border-radius:13px;background:#fff;padding:.7rem;text-align:left;transition:.2s}.family-tabs button:hover{transform:translateY(-2px)}.family-tabs b{grid-row:1/3;color:#25855c}.family-tabs small{color:var(--color-texto-tenue)}.family-tabs button.active{border-color:#2f9b68;background:#edf9f2;box-shadow:0 4px 12px #2f9b681a}.family-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:18px;background:#fff}.family-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.perspective-picker{display:flex;align-items:center;gap:.4rem;padding:.55rem;border-radius:12px;background:#f4f8f5}.perspective-picker>span{margin-right:auto;font-size:.72rem;font-weight:800}.perspective-picker button{display:flex;align-items:center;gap:.25rem;border:1px solid var(--color-borde);border-radius:9px;background:#fff;padding:.4rem .55rem}.perspective-picker button.active{border-color:#2f9b68;background:#e5f5eb}.family-tree{display:grid;gap:.7rem;margin:1rem 0;padding:1rem;border-radius:17px;background:linear-gradient(#f5fbf6,#fffaf0)}.tree-level{position:relative;display:flex;justify-content:center;gap:.5rem}.tree-level:not(:last-child):after{content:'↓';position:absolute;bottom:-.75rem;color:#89af98}.tree-level button{min-width:92px;display:flex;flex-direction:column;align-items:center;padding:.5rem;border:1px solid #d5e4d9;border-radius:12px;background:#fff}.tree-level button>span{font-size:1.7rem}.tree-level button small{font-size:.62rem;color:#718078}.tree-level button.active{border-color:#2f9b68;background:#e9f7ee;transform:translateY(-2px)}.tree-level button.narrator{box-shadow:0 0 0 2px #f0b75e}.family-sentence{display:grid;grid-template-columns:42px 1fr auto;align-items:center;gap:.6rem;padding:.75rem;border-radius:13px;background:#e9f6ef}.family-sentence>span{font-size:2rem}.family-sentence div{display:flex;flex-direction:column}.family-sentence small{font-size:.6rem;font-weight:900;color:#237a57}.family-sentence strong{font:italic 1.05rem Georgia,serif}.family-sentence button,.album-card button{border:0;border-radius:9px;background:#2f9365;color:#fff;padding:.5rem .65rem}.family-album{display:grid;grid-template-columns:1.35fr .65fr;gap:1rem}.album-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:.45rem}.album-grid button{display:flex;flex-direction:column;align-items:center;padding:.6rem;border:1px solid var(--color-borde);border-radius:11px;background:#fff}.album-grid button>span{font-size:1.55rem}.album-grid button small{font-size:.63rem;color:var(--color-texto-tenue)}.album-grid button.active{border-color:#2f9b68;background:#edf9f2}.album-card{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:1rem;border-radius:15px;background:linear-gradient(145deg,#e6f6ec,#fff1d9);text-align:center}.album-card>span{font-size:2.8rem}.album-card>small{font-size:.6rem;font-weight:900;color:#237a57}.album-card strong{font:italic 1.7rem Georgia,serif}.album-card p{margin:.35rem}.album-card i{margin-bottom:.55rem;font-size:.7rem;color:var(--color-texto-tenue)}.family-warning{display:flex;gap:.55rem;margin-top:.8rem;padding:.65rem;border-radius:11px;background:#fff7e5}.family-warning p{margin:0;font-size:.76rem}.family-challenge-head{display:flex;justify-content:space-between}.family-challenge-head>strong{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:#e6f6ec;color:#237a57}.family-challenge{max-width:650px;margin:auto;padding:1.2rem;border-radius:17px;background:linear-gradient(145deg,#f3faf5,#fff9eb);text-align:center}.challenge-icon{font-size:3rem}.family-challenge>small{display:block;font-size:.6rem;font-weight:900;color:#25855c}.family-challenge h4{margin:.3rem}.challenge-phrase{border:0;background:transparent;font:italic 1.25rem Georgia,serif}.challenge-phrase i{font-style:normal;font-size:.8rem}.family-options{display:grid;grid-template-columns:1fr 1fr;gap:.45rem;margin:1rem 0}.family-options button{padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff;font-weight:800}.family-options button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.family-options button.wrong{border-color:#c96543;background:#fff0ea}.family-feedback{display:flex;flex-direction:column;padding:.65rem;border-radius:10px;font-size:.75rem;text-align:left}.family-feedback.ok{background:var(--color-verde-suave);color:#236843}.family-feedback.retry{background:#fff0ea;color:#984228}.next-family{display:block;margin:.65rem 0 0 auto;border:0;border-radius:9px;background:#2f9365;color:#fff;padding:.55rem .8rem;font-weight:800}.family-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:#2f9365;color:#fff;font-weight:800}.family-practice:disabled{background:var(--color-verde)}
@media(max-width:760px){.family-summary>div{grid-template-columns:1fr 1fr}.family-album{grid-template-columns:1fr}.album-grid{grid-template-columns:repeat(4,1fr)}.tree-level{flex-wrap:wrap}.perspective-picker{flex-wrap:wrap}.perspective-picker>span{width:100%}.family-sentence{grid-template-columns:36px 1fr}.family-sentence button{grid-column:1/-1}}
@media(max-width:520px){.family-tabs{grid-template-columns:1fr}.album-grid{grid-template-columns:1fr 1fr}.family-options{grid-template-columns:1fr}.family-summary>div{grid-template-columns:1fr}.tree-level button{min-width:78px}.family-panel{padding:.75rem}}
</style>
