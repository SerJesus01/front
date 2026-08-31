<script setup>
import { computed, ref, watch } from 'vue';
import { CHILD_MISSIONS } from './childMissionData.js';

const props = defineProps({ slug: { type: String, required: true } });
const emit = defineEmits(['hablar', 'volver']);
const paso = ref(1);
const inicioId = ref(0);
const accionId = ref(0);
const finalId = ref(0);
const retoId = ref(0);
const respuesta = ref(null);
const aciertos = ref(new Set());
const mision = computed(() => CHILD_MISSIONS[props.slug]);
const reto = computed(() => mision.value.retos[retoId.value]);
const correcta = computed(() => respuesta.value === reto.value.correcta);
const frase = computed(() => [mision.value.constructor.inicios[inicioId.value], mision.value.constructor.acciones[accionId.value], mision.value.constructor.finales[finalId.value]].join(' '));

function hablar(texto) { emit('hablar', texto, 1); }
function responder(opcion) {
  respuesta.value = opcion;
  if (opcion === reto.value.correcta) aciertos.value = new Set([...aciertos.value, retoId.value]);
}
function siguiente() { retoId.value = (retoId.value + 1) % mision.value.retos.length; respuesta.value = null; }
watch(() => props.slug, () => { paso.value = 1; inicioId.value = 0; accionId.value = 0; finalId.value = 0; retoId.value = 0; respuesta.value = null; aciertos.value = new Set(); });
</script>

<template>
  <section class="child-mission" :style="{ '--accent': mision.color, '--soft': mision.suave }">
    <button class="back" @click="emit('volver')">← Volver al camino</button>
    <header class="hero"><span>{{ mision.icono }}</span><div><small>STUDENTBOOK 9–15 · {{ mision.zona }}</small><h1>{{ mision.titulo }}</h1><p>{{ mision.bajada }}</p></div><strong>⭐ {{ mision.valor }}</strong></header>
    <nav><button v-for="(tab,index) in ['Historia', 'Construye', 'Misión final']" :key="tab" :class="{ active: paso === index + 1 }" @click="paso = index + 1"><b>0{{ index + 1 }}</b><span>{{ tab }}</span></button></nav>

    <main v-if="paso === 1">
      <div class="section-head"><small>LEE Y ESCUCHA</small><h2>Una historia en cinco momentos</h2><p>Selecciona cada escena para escucharla en inglés.</p></div>
      <div class="story"><button v-for="(escena,index) in mision.historia" :key="escena.texto" @click="hablar(escena.texto)"><span>{{ escena.emoji }}</span><small>{{ String(index + 1).padStart(2,'0') }}</small><p>{{ escena.texto }}</p><b>🔊</b></button></div>
      <aside class="words"><article v-for="item in mision.palabras" :key="item.en"><span>{{ item.emoji }}</span><b>{{ item.en }}</b><small>{{ item.es }}</small><button @click="hablar(item.en)">🔊</button></article></aside>
    </main>

    <main v-else-if="paso === 2">
      <div class="section-head"><small>BLOQUES DE FRASE</small><h2>Combina las tres piezas</h2><p>Prueba distintas combinaciones y revisa cuál expresa mejor tu idea.</p></div>
      <div class="builder">
        <section><small>1 · INICIO</small><button v-for="(item,index) in mision.constructor.inicios" :key="item" :class="{ active: inicioId === index }" @click="inicioId = index">{{ item }}</button></section>
        <section><small>2 · ACCIÓN</small><button v-for="(item,index) in mision.constructor.acciones" :key="item" :class="{ active: accionId === index }" @click="accionId = index">{{ item }}</button></section>
        <section><small>3 · FINAL</small><button v-for="(item,index) in mision.constructor.finales" :key="item" :class="{ active: finalId === index }" @click="finalId = index">{{ item }}</button></section>
      </div>
      <article class="result"><small>TU FRASE</small><strong>{{ frase }}</strong><button @click="hablar(frase)">🔊 Escuchar</button></article>
    </main>

    <main v-else>
      <div class="challenge-head"><div><small>RETO FINAL</small><h2>Usa lo que aprendiste</h2><p>Si te equivocas, recibirás una pista para intentarlo otra vez.</p></div><b>{{ aciertos.size }}/{{ mision.retos.length }}</b></div>
      <article class="challenge"><span>{{ mision.icono }}</span><button class="prompt" @click="hablar(reto.frase.replace('___',reto.correcta))">{{ reto.frase }} 🔊</button><div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: respuesta && opcion === reto.correcta, bad: respuesta === opcion && opcion !== reto.correcta }" @click="responder(opcion)">{{ opcion }}</button></div><p v-if="respuesta"><b>{{ correcta ? '✓ Buena estrategia' : '↻ La pista te acerca' }}</b> {{ reto.ayuda }}</p><button v-if="correcta" class="next" @click="siguiente">Siguiente reto →</button></article>
      <section class="uses"><header><small>SALIDA DE APRENDIZAJE</small><h3>¿Dónde lo aplico?</h3><p>Estas son situaciones reales donde puedes usar lo aprendido.</p></header><div><article v-for="uso in mision.aplicaciones" :key="uso.titulo"><span>{{ uso.emoji }}</span><b>{{ uso.titulo }}</b><p>{{ uso.texto }}</p></article></div></section>
      <aside v-if="aciertos.size === mision.retos.length" class="complete"><span>✈️</span><div><small>MISIÓN COMPLETADA</small><b>Tu avioncito puede seguir al siguiente punto.</b></div></aside>
    </main>
  </section>
</template>

<style scoped>
.child-mission{display:grid;gap:1rem}.back{justify-self:start;border:0;background:transparent;color:var(--color-azul);cursor:pointer}.hero,main{padding:1rem;border:2px solid var(--color-borde);border-radius:var(--radio-panel);background:var(--color-superficie)}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:1rem;background:linear-gradient(135deg,var(--soft),var(--color-superficie))}.hero>span{display:grid;place-items:center;width:64px;height:64px;border-radius:20px;background:var(--accent);font-size:2rem}.hero h1,.section-head h2,.challenge-head h2{margin:.15rem 0}.hero p,.section-head p,.challenge-head p{margin:.2rem 0;color:var(--color-texto-secundario)}small{color:var(--accent);font-size:.62rem;font-weight:900;letter-spacing:.09em}.hero>strong{max-width:190px;padding:.65rem;border:1px dashed var(--accent);border-radius:12px;color:var(--accent);font-size:.72rem;text-align:center}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}nav button{display:flex;gap:.55rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:13px;background:var(--color-superficie);text-align:left}nav b{color:var(--accent)}nav button.active,.builder button.active{border-color:var(--accent);background:var(--soft)}.story{display:grid;gap:.5rem}.story button{display:grid;grid-template-columns:auto auto 1fr auto;align-items:center;gap:.7rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:13px;background:var(--color-superficie);text-align:left}.story button>span{font-size:1.6rem}.story button>p{margin:0}.words{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem;margin-top:.8rem}.words article{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.4rem;padding:.65rem;border-radius:13px;background:var(--soft)}.words article>span{grid-row:1/3;font-size:1.4rem}.words article>small{grid-column:2}.words article>button{grid-row:1/3;grid-column:3;border:0;background:transparent}.builder{display:grid;grid-template-columns:repeat(3,1fr);gap:.7rem}.builder section{display:flex;flex-direction:column;gap:.4rem}.builder button{padding:.65rem;border:1px solid var(--color-borde);border-radius:11px;background:var(--color-superficie);text-align:left}.result{display:flex;flex-direction:column;align-items:center;gap:.45rem;margin-top:.8rem;padding:1rem;border-radius:16px;background:linear-gradient(135deg,var(--soft),#fff);text-align:center}.result strong{font:italic 1.15rem Georgia}.result button,.next{padding:.55rem .8rem;border:0;border-radius:10px;background:var(--accent);color:#fff}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:50px;height:50px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:620px;margin:auto;padding:1rem;border-radius:17px;background:var(--soft);text-align:center}.challenge>span{font-size:2.8rem}.prompt{display:block;margin:.4rem auto;border:0;background:transparent;font:italic 1.1rem Georgia}.challenge>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}.challenge>div button{padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:var(--color-rojo);background:var(--color-rojo-suave)}.uses{margin-top:1rem;padding-top:1rem;border-top:1px solid var(--color-borde)}.uses header{text-align:center}.uses h3{margin:.15rem 0}.uses header p{margin:.2rem 0 .7rem;color:var(--color-texto-secundario)}.uses>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.uses article{display:grid;grid-template-columns:auto 1fr;gap:.25rem .5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:13px;background:var(--color-superficie)}.uses article>span{grid-row:1/3;font-size:1.4rem}.uses article>p{margin:0;color:var(--color-texto-secundario);font-size:.78rem}.complete{display:flex;align-items:center;justify-content:center;gap:.7rem;margin-top:.8rem;padding:.8rem;border:2px solid var(--color-verde);border-radius:16px;background:var(--color-verde-suave)}.complete>span{font-size:2rem}.complete div{display:flex;flex-direction:column}.complete small{color:var(--color-verde)}
@media(max-width:720px){.hero{grid-template-columns:auto 1fr}.hero>strong{grid-column:1/-1;max-width:none}.words{grid-template-columns:repeat(2,1fr)}.builder,.uses>div{grid-template-columns:1fr}.challenge>div{grid-template-columns:1fr}}
@media(max-width:480px){nav,.words{grid-template-columns:1fr}.story button{grid-template-columns:auto 1fr auto}.story button>small{display:none}.hero{grid-template-columns:1fr;text-align:center}.hero>span{margin:auto}}
</style>
