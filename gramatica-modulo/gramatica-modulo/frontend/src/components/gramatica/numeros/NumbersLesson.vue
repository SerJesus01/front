<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({
  items: { type: Array, default: () => [] },
  reproduciendoId: { type: [Number, String], default: null },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['reproducir', 'reproducir-lento', 'practicar']);

const leccion = ref(1);
const activoId = ref(null);
const escuchados = ref(new Set());

function numeral(item) {
  const simple = item.texto_es?.match(/^Número (\d+)$/);
  if (simple) return simple[1];
  const ordinal = item.texto_es?.match(/^(\d+)º$/);
  if (ordinal) return ordinal[1];
  return item.texto_es || '';
}

const cardinalesBasicos = computed(() =>
  props.items.filter((item) => item.variante === 'cardinal' && /^Número \d+$/.test(item.texto_es || '')),
);
const ordinales = computed(() => props.items.filter((item) => item.variante === 'ordinal'));
const grandes = computed(() =>
  props.items.filter((item) => item.variante === 'cardinal' && /^[\d.]+$/.test(item.texto_es || '')),
);
const ordinalPorNumero = computed(() =>
  new Map(ordinales.value.map((item) => [numeral(item), item])),
);
const filasNumero2 = computed(() => [
  ...cardinalesBasicos.value.map((cardinal) => ({
    numero: numeral(cardinal),
    cardinal,
    ordinal: ordinalPorNumero.value.get(numeral(cardinal)) || null,
  })),
  ...grandes.value.map((cardinal) => ({
    numero: numeral(cardinal),
    cardinal,
    ordinal: null,
  })),
]);
const activo = computed(() =>
  props.items.find((item) => item.id === activoId.value)
  || (leccion.value === 1 ? cardinalesBasicos.value[0] : filasNumero2.value[0]?.ordinal || filasNumero2.value[0]?.cardinal)
  || null,
);
const progreso = computed(() => {
  const total = leccion.value === 1 ? cardinalesBasicos.value.length : ordinales.value.length + grandes.value.length;
  const ids = new Set(leccion.value === 1
    ? cardinalesBasicos.value.map((item) => item.id)
    : [...ordinales.value, ...grandes.value].map((item) => item.id));
  const vistos = [...escuchados.value].filter((id) => ids.has(id)).length;
  return total ? Math.round((vistos / total) * 100) : 0;
});

watch(leccion, () => { activoId.value = null; });

function seleccionar(item) {
  if (!item) return;
  activoId.value = item.id;
  escuchados.value = new Set([...escuchados.value, item.id]);
  emit('reproducir', item);
}
</script>

<template>
  <section class="numbers-lesson">
    <div class="numbers-lesson__switch" role="tablist" aria-label="Lecciones de números">
      <button :class="{ active: leccion === 1 }" @click="leccion = 1">
        <span>01</span><strong>Números 1</strong><small>Cardinales del 1 al 20</small>
      </button>
      <button :class="{ active: leccion === 2 }" @click="leccion = 2">
        <span>02</span><strong>Números 2</strong><small>Ordinales y números grandes</small>
      </button>
    </div>

    <header class="numbers-lesson__header">
      <div>
        <span class="numbers-lesson__eyebrow">DESCUBRE Y ESCUCHA</span>
        <h2>{{ leccion === 1 ? 'Contar del 1 al 20' : 'Orden y cantidades grandes' }}</h2>
        <p>{{ leccion === 1 ? 'Tocá cada número, escuchá su nombre y repetilo en voz alta.' : 'Compará cardinales y ordinales; después explorá los hitos de miles.' }}</p>
      </div>
      <div class="numbers-lesson__progress"><strong>{{ progreso }}%</strong><small>escuchado</small></div>
    </header>

    <div v-if="activo" class="numbers-lesson__stage">
      <div class="numbers-lesson__numeral">{{ numeral(activo) }}</div>
      <div>
        <span class="numbers-lesson__eyebrow">{{ activo.variante === 'ordinal' ? 'ORDINAL' : 'CARDINAL' }}</span>
        <strong>{{ activo.texto_en }}</strong>
        <div>
          <button class="numbers-lesson__play" :disabled="reproduciendoId === activo.id" @click="emit('reproducir', activo)">🔊 Escuchar</button>
          <button class="numbers-lesson__slow" :disabled="reproduciendoId === activo.id" @click="emit('reproducir-lento', activo)">Más lento</button>
        </div>
      </div>
    </div>

    <div v-if="leccion === 1" class="numbers-lesson__grid">
      <button
        v-for="item in cardinalesBasicos"
        :key="item.id"
        :class="{ active: activo?.id === item.id, heard: escuchados.has(item.id) }"
        :disabled="!item.audio_key || reproduciendoId === item.id"
        @click="seleccionar(item)"
      ><b>{{ numeral(item) }}</b><span>{{ item.texto_en }}</span><small>{{ escuchados.has(item.id) ? '✓' : '🔊' }}</small></button>
    </div>

    <div v-else class="numbers-lesson__table">
      <div class="numbers-lesson__table-head"><span>Nº</span><span>Cardinal</span><span>Ordinal</span></div>
      <div v-for="fila in filasNumero2" :key="fila.numero" class="numbers-lesson__row">
        <b>{{ fila.numero }}</b>
        <button :disabled="!fila.cardinal.audio_key" @click="seleccionar(fila.cardinal)">{{ fila.cardinal.texto_en }}</button>
        <button v-if="fila.ordinal" :disabled="!fila.ordinal.audio_key" @click="seleccionar(fila.ordinal)">{{ fila.ordinal.texto_en }}</button>
        <span v-else>—</span>
      </div>
    </div>

    <div class="numbers-lesson__tip">💡 <span v-if="leccion === 1"><b>Patrón:</b> thirteen–nineteen terminan en <i>-teen</i>.</span><span v-else><b>Orden:</b> first, second y third son irregulares; después aparece <i>-th</i>.</span></div>

    <button class="numbers-lesson__practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar esta lección →' }}</button>
  </section>
</template>

<style scoped>
.numbers-lesson{padding:1.25rem;border:1px solid #dbe9df;border-radius:20px;background:white;box-shadow:0 8px 28px rgba(25,72,53,.07)}.numbers-lesson__switch{display:grid;grid-template-columns:1fr 1fr;gap:.65rem;margin-bottom:1.2rem}.numbers-lesson__switch button{display:grid;grid-template-columns:36px 1fr;column-gap:.6rem;border:1px solid var(--color-borde);border-radius:14px;background:#fafcf9;padding:.75rem;text-align:left}.numbers-lesson__switch button>span{grid-row:1/3;display:grid;place-items:center;border-radius:10px;background:#eaf5ee;color:var(--color-verde);font-weight:900}.numbers-lesson__switch small{color:var(--color-texto-tenue)}.numbers-lesson__switch button.active{border-color:var(--color-verde);background:var(--color-verde-suave)}.numbers-lesson__header{display:flex;justify-content:space-between;gap:1rem}.numbers-lesson__header h2{margin:.2rem 0}.numbers-lesson__header p{margin:.2rem 0;color:var(--color-texto-secundario);font-size:.84rem}.numbers-lesson__eyebrow{color:var(--color-verde);font-size:.67rem;font-weight:800;letter-spacing:.08em}.numbers-lesson__progress{text-align:right}.numbers-lesson__progress strong{display:block;color:var(--color-verde);font-size:1.4rem}.numbers-lesson__progress small{color:var(--color-texto-tenue)}.numbers-lesson__stage{display:grid;grid-template-columns:130px 1fr;align-items:center;gap:1.2rem;margin:1rem 0;padding:1rem;border-radius:16px;background:linear-gradient(135deg,var(--color-verde-suave),#fff8e7)}.numbers-lesson__numeral{font:700 3.8rem Georgia,serif;text-align:center;color:var(--color-verde)}.numbers-lesson__stage>div:last-child{display:flex;flex-direction:column;gap:.35rem}.numbers-lesson__stage strong{font-size:1.2rem}.numbers-lesson__play,.numbers-lesson__slow{padding:.6rem .8rem;border-radius:var(--radio-boton);font-weight:700}.numbers-lesson__play{border:0;background:var(--color-verde);color:white}.numbers-lesson__slow{margin-left:.35rem;border:1px solid var(--color-borde);background:white}.numbers-lesson__grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(82px,1fr));gap:.5rem}.numbers-lesson__grid button{position:relative;min-height:72px;border:1px solid var(--color-borde);border-radius:12px;background:white}.numbers-lesson__grid b,.numbers-lesson__grid span,.numbers-lesson__grid small{display:block}.numbers-lesson__grid b{font-size:1.2rem}.numbers-lesson__grid span{font-size:.75rem;color:var(--color-texto-secundario)}.numbers-lesson__grid small{color:var(--color-verde)}.numbers-lesson__grid button.active{border-color:var(--color-verde);background:var(--color-verde);color:white}.numbers-lesson__grid button.active span,.numbers-lesson__grid button.active small{color:white}.numbers-lesson__table{display:grid;grid-template-columns:minmax(60px,.5fr) 1fr 1fr;border:1px solid var(--color-borde);border-radius:14px;overflow:hidden}.numbers-lesson__table-head,.numbers-lesson__row{display:contents}.numbers-lesson__table span,.numbers-lesson__table b,.numbers-lesson__table button{padding:.62rem;border:0;border-bottom:1px solid var(--color-borde);background:white;text-align:left}.numbers-lesson__table-head span{background:#f4f7f4;font-size:.7rem;font-weight:800}.numbers-lesson__row button{color:var(--color-azul);cursor:pointer}.numbers-lesson__tip{margin-top:.8rem;padding:.7rem;border-radius:10px;background:#fff8e7;font-size:.8rem}.numbers-lesson__practice{width:100%;margin-top:.8rem;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--color-azul);color:white;font-weight:800}.numbers-lesson__practice:disabled{background:var(--color-verde);opacity:.8}@media(max-width:620px){.numbers-lesson__switch{grid-template-columns:1fr}.numbers-lesson__header{flex-direction:column}.numbers-lesson__progress{text-align:left}.numbers-lesson__stage{grid-template-columns:85px 1fr}.numbers-lesson__numeral{font-size:2.8rem}.numbers-lesson__table{font-size:.75rem}}
</style>
