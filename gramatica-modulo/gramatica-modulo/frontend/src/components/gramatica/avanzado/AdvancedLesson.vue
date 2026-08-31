<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({ slug: { type: String, required: true }, completado: { type: Boolean, default: false } });
const emit = defineEmits(['hablar', 'practicar']);
const modulos = import.meta.glob('./modules/*.js', { eager: true, import: 'default' });
const catalogo = Object.values(modulos).reduce((mapa, modulo) => ({ ...mapa, [modulo.slug]: modulo }), {});
const leccion = computed(() => catalogo[props.slug]);
const paso = ref(1);
const fichaId = ref(0);
const retoId = ref(0);
const respuesta = ref(null);
const aciertos = ref(new Set());
const ficha = computed(() => leccion.value?.fichas[fichaId.value]);
const reto = computed(() => leccion.value?.retos[retoId.value]);
const correcta = computed(() => respuesta.value === reto.value?.correcta);

function responder(opcion) {
  respuesta.value = opcion;
  if (opcion === reto.value.correcta) aciertos.value = new Set([...aciertos.value, retoId.value]);
}
function siguiente() {
  retoId.value = (retoId.value + 1) % leccion.value.retos.length;
  respuesta.value = null;
}
function hablar(texto) { emit('hablar', texto, 1); }
watch(() => props.slug, () => {
  paso.value = 1; fichaId.value = 0; retoId.value = 0; respuesta.value = null; aciertos.value = new Set();
});
</script>

<template>
  <section v-if="leccion" class="advanced" :style="{ '--accent': leccion.color, '--soft': leccion.suave }">
    <aside class="hero">
      <span>{{ leccion.icono }}</span>
      <div><small>ADULTO ESTÁNDAR · {{ leccion.sobre }}</small><h2>{{ leccion.titulo }}</h2><p>{{ leccion.bajada }}</p></div>
      <strong>{{ leccion.formula }}</strong>
    </aside>
    <nav>
      <button v-for="(tab, index) in ['Explorá', 'Construí', 'Reto rápido']" :key="tab" :class="{ active: paso === index + 1 }" @click="paso = index + 1"><b>0{{ index + 1 }}</b><span>{{ tab }}</span></button>
    </nav>

    <main v-if="paso === 1">
      <header><small>MAPA DE USO</small><h3>{{ leccion.pregunta }}</h3><p>Tocá cada opción para verla dentro de una frase cotidiana.</p></header>
      <div class="explore">
        <div class="cards">
          <button v-for="(item, index) in leccion.fichas" :key="item.palabra" :class="{ active: fichaId === index }" @click="fichaId = index"><b>{{ item.palabra }}</b><span>{{ item.uso }}</span></button>
        </div>
        <article class="focus"><span>{{ ficha.emoji || leccion.icono }}</span><small>{{ ficha.uso }}</small><strong>{{ ficha.ejemplo }}</strong><p>{{ ficha.nota }}</p><button @click="hablar(ficha.ejemplo)">🔊 Escuchar</button></article>
      </div>
      <aside class="tip"><b>Atajo mental:</b> {{ leccion.consejo }}</aside>
    </main>

    <main v-else-if="paso === 2">
      <header><small>IDEA EN MOVIMIENTO</small><h3>{{ leccion.actividad }}</h3><p>Seguí las piezas en orden y escuchá el resultado completo.</p></header>
      <div class="route">
        <template v-for="(item, index) in leccion.ruta" :key="item.etiqueta">
          <article :class="{ arrival: index === leccion.ruta.length - 1 }"><small>{{ index + 1 }} · {{ item.etiqueta }}</small><strong>{{ item.texto }}</strong></article><i v-if="index < leccion.ruta.length - 1">→</i>
        </template>
      </div>
      <article class="result"><small>RESULTADO NATURAL</small><strong>{{ leccion.resultado }}</strong><button @click="hablar(leccion.resultado)">🔊 Escuchar frase</button></article>
      <div class="examples"><button v-for="(item, index) in leccion.fichas.slice(0, 4)" :key="item.ejemplo" @click="hablar(item.ejemplo)"><span>0{{ index + 1 }}</span><p>{{ item.ejemplo }}</p><b>🔊</b></button></div>
    </main>

    <main v-else>
      <header class="challenge-head"><div><small>PRÁCTICA COTIDIANA</small><h3>Elegí la pieza correcta</h3><p>Usá el patrón que acabás de explorar.</p></div><b>{{ aciertos.size }}/{{ leccion.retos.length }}</b></header>
      <article class="challenge"><span>{{ leccion.icono }}</span><button class="prompt" @click="hablar(reto.frase.replace('___', reto.correcta))">{{ reto.frase }} 🔊</button><div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: respuesta && opcion === reto.correcta, bad: respuesta === opcion && opcion !== reto.correcta }" @click="responder(opcion)">{{ opcion }}</button></div><p v-if="respuesta"><b>{{ correcta ? '✓ Muy bien' : '↻ Probá otra opción' }}</b> {{ reto.ayuda }}</p><button v-if="correcta" class="next" @click="siguiente">Siguiente frase →</button></article>
    </main>
    <button class="practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.advanced{display:grid;gap:1rem}.hero,main{padding:1rem;border:1px solid var(--color-borde);border-radius:var(--radio-panel);background:var(--color-superficie)}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.9rem;background:linear-gradient(135deg,var(--soft),var(--color-superficie))}.hero>span{font-size:2.8rem}.hero h2,main h3{margin:.15rem 0}.hero p,main header p{margin:.25rem 0;color:var(--color-texto-secundario)}small{font-size:.64rem;font-weight:900;letter-spacing:.08em;color:var(--accent)}.hero>strong{max-width:240px;padding:.7rem;border:1px dashed var(--accent);border-radius:12px;color:var(--accent);text-align:center}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}nav button{display:flex;gap:.5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:12px;background:var(--color-superficie);text-align:left}nav button b{color:var(--accent)}nav button.active,.cards button.active{border-color:var(--accent);background:var(--soft)}.explore{display:grid;grid-template-columns:1.25fr .75fr;gap:.8rem}.cards{display:grid;grid-template-columns:repeat(2,1fr);gap:.45rem}.cards button{display:flex;flex-direction:column;padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie);text-align:left}.cards button b{color:var(--accent);font-size:1rem}.cards button span{font-size:.7rem;color:var(--color-texto-secundario)}.focus{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:.4rem;padding:1rem;border:2px solid var(--accent);border-radius:16px;background:var(--soft);text-align:center}.focus>span{font-size:2.6rem}.focus>strong,.result>strong{font:italic 1.12rem Georgia}.focus p{margin:.1rem 0;color:var(--color-texto-secundario);font-size:.76rem}.focus button,.result button{padding:.5rem .75rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.tip{margin-top:.7rem;padding:.7rem;border-left:4px solid var(--accent);border-radius:8px;background:var(--soft);font-size:.8rem}.route{display:grid;grid-template-columns:repeat(5,auto);align-items:center;justify-content:center;gap:.5rem;margin:1rem 0}.route article{display:flex;min-width:140px;min-height:76px;flex-direction:column;align-items:center;justify-content:center;padding:.65rem;border:1px solid var(--color-borde);border-radius:12px;text-align:center}.route i{color:var(--accent);font-size:1.5rem}.route .arrival{border-color:var(--accent);background:var(--soft);color:var(--accent)}.result{display:flex;flex-direction:column;align-items:center;gap:.4rem;padding:1rem;border-radius:15px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.examples{display:grid;grid-template-columns:repeat(2,1fr);gap:.45rem;margin-top:.7rem}.examples button{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.5rem;padding:.6rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie);text-align:left}.examples span{color:var(--accent);font-weight:900}.examples p{margin:0}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:50px;height:50px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:650px;margin:auto;padding:1rem;border-radius:16px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.challenge>span{font-size:2.8rem}.prompt{display:block;margin:.45rem auto;border:0;background:transparent;font:italic 1.1rem Georgia}.challenge>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.45rem}.challenge>div button{padding:.65rem;border:1px solid var(--color-borde);border-radius:9px;background:var(--color-superficie)}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:var(--color-rojo);background:var(--color-rojo-suave)}.next{padding:.55rem .8rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.practice{width:100%;padding:.85rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff;font-weight:800}.practice:disabled{background:var(--color-verde)}
@media(max-width:720px){.hero{grid-template-columns:auto 1fr}.hero>strong{grid-column:1/-1;max-width:none}.explore{grid-template-columns:1fr}.route{grid-template-columns:1fr}.route i{transform:rotate(90deg);text-align:center}.examples{grid-template-columns:1fr}}
@media(max-width:520px){nav,.cards,.challenge>div{grid-template-columns:1fr}}
</style>
