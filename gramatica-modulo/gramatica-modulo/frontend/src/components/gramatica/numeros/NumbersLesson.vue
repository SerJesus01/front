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
const posiciones = [
  { etiqueta: 'CM', nombre: 'hundred thousands', valor: 100000 },
  { etiqueta: 'DM', nombre: 'ten thousands', valor: 10000 },
  { etiqueta: 'UM', nombre: 'thousands', valor: 1000 },
  { etiqueta: 'C', nombre: 'hundreds', valor: 100 },
  { etiqueta: 'D', nombre: 'tens', valor: 10 },
  { etiqueta: 'U', nombre: 'ones', valor: 1 },
];
const digitos = ref([0, 0, 0, 0, 0, 0]);
const objetivo = ref(null);
const estadoAbaco = ref('');

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
const activo = computed(() =>
  props.items.find((item) => item.id === activoId.value)
  || (leccion.value === 1 ? cardinalesBasicos.value[0] : ordinales.value[0])
  || null,
);
const numeroConstruido = computed(() =>
  digitos.value.reduce((total, digito, index) => total + digito * posiciones[index].valor, 0),
);
const numeroFormateado = computed(() => new Intl.NumberFormat('es-MX').format(numeroConstruido.value));
const objetivoEnIngles = computed(() => objetivo.value === null ? '' : numeroEnIngles(objetivo.value));
const progreso = computed(() => {
  const lista = leccion.value === 1 ? cardinalesBasicos.value : ordinales.value;
  const ids = new Set(lista.map((item) => item.id));
  const vistos = [...escuchados.value].filter((id) => ids.has(id)).length;
  return lista.length ? Math.round((vistos / lista.length) * 100) : 0;
});

const unidades = ['zero','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen'];
const decenas = ['', '', 'twenty','thirty','forty','fifty','sixty','seventy','eighty','ninety'];
function bloqueEnIngles(numero) {
  if (numero < 20) return unidades[numero];
  if (numero < 100) return decenas[Math.floor(numero / 10)] + (numero % 10 ? '-' + unidades[numero % 10] : '');
  return unidades[Math.floor(numero / 100)] + ' hundred' + (numero % 100 ? ' ' + bloqueEnIngles(numero % 100) : '');
}
function numeroEnIngles(numero) {
  if (numero < 1000) return bloqueEnIngles(numero);
  const miles = Math.floor(numero / 1000);
  const resto = numero % 1000;
  return bloqueEnIngles(miles) + ' thousand' + (resto ? ' ' + bloqueEnIngles(resto) : '');
}
const numeroConstruidoEnIngles = computed(() => numeroEnIngles(numeroConstruido.value));

watch(leccion, () => { activoId.value = null; estadoAbaco.value = ''; });

function seleccionar(item) {
  if (!item) return;
  activoId.value = item.id;
  escuchados.value = new Set([...escuchados.value, item.id]);
  emit('reproducir', item);
}
function cambiarDigito(index, cambio) {
  const copia = [...digitos.value];
  copia[index] = (copia[index] + cambio + 10) % 10;
  digitos.value = copia;
  estadoAbaco.value = '';
}
function nuevoReto() {
  objetivo.value = Math.floor(Math.random() * 999999) + 1;
  digitos.value = [0, 0, 0, 0, 0, 0];
  estadoAbaco.value = 'jugando';
}
function comprobarAbaco() {
  if (objetivo.value === null) {
    nuevoReto();
    return;
  }
  estadoAbaco.value = numeroConstruido.value === objetivo.value ? 'correcto' : 'incorrecto';
}
</script>

<template>
  <section class="numbers-lesson">
    <div class="numbers-lesson__switch" role="tablist" aria-label="Lecciones de números">
      <button :class="{ active: leccion === 1 }" @click="leccion = 1">
        <span>01</span><strong>Números 1</strong><small>Cardinales y ábaco posicional</small>
      </button>
      <button :class="{ active: leccion === 2 }" @click="leccion = 2">
        <span>02</span><strong>Números 2</strong><small>Números ordinales</small>
      </button>
    </div>

    <header class="numbers-lesson__header">
      <div>
        <span class="numbers-lesson__eyebrow">DESCUBRE Y PRACTICA</span>
        <h2>{{ leccion === 1 ? 'Cardinales y valor posicional' : 'Números ordinales' }}</h2>
        <p>{{ leccion === 1 ? 'Aprendé del 1 al 20 y construí cantidades grandes moviendo cada columna.' : 'Aprendé a expresar posiciones: first, second, third…' }}</p>
      </div>
      <div class="numbers-lesson__progress"><strong>{{ progreso }}%</strong><small>escuchado</small></div>
    </header>

    <div v-if="activo" class="numbers-lesson__stage">
      <div class="numbers-lesson__numeral">{{ numeral(activo) }}</div>
      <div class="numbers-lesson__stage-copy">
        <span class="numbers-lesson__eyebrow">{{ activo.variante === 'ordinal' ? 'ORDINAL' : 'CARDINAL' }}</span>
        <strong>{{ activo.texto_en }}</strong>
        <div class="numbers-lesson__audio-actions">
          <button class="numbers-lesson__play" :disabled="reproduciendoId === activo.id" @click="emit('reproducir', activo)">🔊 Escuchar</button>
          <button class="numbers-lesson__slow" :disabled="reproduciendoId === activo.id" @click="emit('reproducir-lento', activo)">Más lento</button>
        </div>
      </div>
    </div>

    <template v-if="leccion === 1">
      <div class="numbers-lesson__grid">
        <button v-for="item in cardinalesBasicos" :key="item.id"
          :class="{ active: activo?.id === item.id, heard: escuchados.has(item.id) }"
          :disabled="!item.audio_key || reproduciendoId === item.id" @click="seleccionar(item)">
          <b>{{ numeral(item) }}</b><span>{{ item.texto_en }}</span><small>{{ escuchados.has(item.id) ? '✓' : '🔊' }}</small>
        </button>
      </div>

      <section class="place-value">
        <header>
          <div><span class="numbers-lesson__eyebrow">ÁBACO DE VALOR POSICIONAL</span><h3>Construí el número</h3></div>
          <button class="place-value__challenge" @click="nuevoReto">{{ objetivo === null ? 'Iniciar reto' : 'Nuevo reto' }}</button>
        </header>
        <div v-if="objetivo !== null" class="place-value__target">
          <span>Escuchá mentalmente las posiciones y armá:</span>
          <strong lang="en">{{ objetivoEnIngles }}</strong>
        </div>
        <p v-else class="place-value__target">Mové las fichas para descubrir cómo se forman unidades, decenas, centenas y miles.</p>

        <div class="place-value__abacus">
          <div v-for="(posicion, index) in posiciones" :key="posicion.etiqueta" class="place-value__column">
            <span class="place-value__label">{{ posicion.etiqueta }}</span>
            <small>{{ posicion.nombre }}</small>
            <button aria-label="Aumentar" @click="cambiarDigito(index, 1)">+</button>
            <div class="place-value__rod">
              <i v-for="cuenta in digitos[index]" :key="cuenta"></i>
              <b>{{ digitos[index] }}</b>
            </div>
            <button aria-label="Disminuir" @click="cambiarDigito(index, -1)">−</button>
          </div>
        </div>

        <div class="place-value__result">
          <span>{{ numeroFormateado }}</span>
          <strong>{{ numeroConstruidoEnIngles }}</strong>
        </div>
        <div v-if="estadoAbaco === 'correcto'" class="place-value__feedback ok">✓ ¡Correcto! Construiste el número.</div>
        <div v-else-if="estadoAbaco === 'incorrecto'" class="place-value__feedback wrong">Revisá cada posición e intentá otra vez.</div>
        <button v-if="objetivo !== null" class="place-value__check" @click="comprobarAbaco">Comprobar número</button>
      </section>
    </template>

    <div v-else class="numbers-lesson__table">
      <div class="numbers-lesson__table-head"><span>Posición</span><span>Ordinal</span></div>
      <div v-for="item in ordinales" :key="item.id" class="numbers-lesson__row">
        <b>{{ numeral(item) }}</b>
        <button :disabled="!item.audio_key" @click="seleccionar(item)">{{ item.texto_en }}</button>
      </div>
    </div>

    <div class="numbers-lesson__tip">💡 <span v-if="leccion === 1"><b>Valor posicional:</b> cada columna vale diez veces la que está a su derecha.</span><span v-else><b>Orden:</b> first, second y third son irregulares; después suele aparecer <i>-th</i>.</span></div>
    <button class="numbers-lesson__practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.numbers-lesson{padding:1.25rem;border:1px solid #dbe9df;border-radius:20px;background:white;box-shadow:0 8px 28px rgba(25,72,53,.07)}.numbers-lesson__switch{display:grid;grid-template-columns:1fr 1fr;gap:.65rem;margin-bottom:1.2rem}.numbers-lesson__switch button{display:grid;grid-template-columns:36px 1fr;column-gap:.6rem;border:1px solid var(--color-borde);border-radius:14px;background:#fafcf9;padding:.75rem;text-align:left}.numbers-lesson__switch button>span{grid-row:1/3;display:grid;place-items:center;border-radius:10px;background:#eaf5ee;color:var(--color-verde);font-weight:900}.numbers-lesson__switch small{color:var(--color-texto-tenue)}.numbers-lesson__switch button.active{border-color:var(--color-verde);background:var(--color-verde-suave)}.numbers-lesson__header{display:flex;justify-content:space-between;gap:1rem}.numbers-lesson__header h2{margin:.2rem 0}.numbers-lesson__header p{margin:.2rem 0;color:var(--color-texto-secundario);font-size:.84rem}.numbers-lesson__eyebrow{color:var(--color-verde);font-size:.67rem;font-weight:800;letter-spacing:.08em}.numbers-lesson__progress{text-align:right}.numbers-lesson__progress strong{display:block;color:var(--color-verde);font-size:1.4rem}.numbers-lesson__progress small{color:var(--color-texto-tenue)}.numbers-lesson__stage{display:grid;grid-template-columns:minmax(100px,140px) minmax(0,1fr);align-items:center;gap:1.2rem;margin:1rem 0;padding:1rem;border-radius:16px;background:linear-gradient(135deg,var(--color-verde-suave),#fff8e7);overflow:hidden}.numbers-lesson__numeral{min-width:0;font:700 clamp(2.5rem,7vw,3.8rem) Georgia,serif;text-align:center;color:var(--color-verde);overflow-wrap:anywhere}.numbers-lesson__stage-copy{min-width:0;display:flex;flex-direction:column;gap:.45rem}.numbers-lesson__stage-copy>strong{font-size:1.2rem;overflow-wrap:anywhere}.numbers-lesson__audio-actions{display:flex;flex-wrap:wrap;gap:.35rem}.numbers-lesson__play,.numbers-lesson__slow{padding:.6rem .8rem;border-radius:var(--radio-boton);font-weight:700}.numbers-lesson__play{border:0;background:var(--color-verde);color:white}.numbers-lesson__slow{border:1px solid var(--color-borde);background:white}.numbers-lesson__grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(82px,1fr));gap:.5rem}.numbers-lesson__grid button{position:relative;min-height:72px;border:1px solid var(--color-borde);border-radius:12px;background:white}.numbers-lesson__grid b,.numbers-lesson__grid span,.numbers-lesson__grid small{display:block}.numbers-lesson__grid b{font-size:1.2rem}.numbers-lesson__grid span{font-size:.75rem;color:var(--color-texto-secundario)}.numbers-lesson__grid small{color:var(--color-verde)}.numbers-lesson__grid button.active{border-color:var(--color-verde);background:var(--color-verde);color:white}.numbers-lesson__grid button.active span,.numbers-lesson__grid button.active small{color:white}.place-value{margin-top:1rem;padding:1rem;border:1px solid #dbe9df;border-radius:16px;background:#fbfdfb}.place-value header{display:flex;justify-content:space-between;align-items:center;gap:.8rem}.place-value h3{margin:.2rem 0}.place-value__challenge,.place-value__check{border:0;border-radius:10px;background:var(--color-azul);color:white;padding:.65rem .85rem;font-weight:800}.place-value__target{display:flex;flex-direction:column;gap:.3rem;padding:.7rem;border-radius:10px;background:#fff8e7;text-align:center}.place-value__target span{font-size:.76rem;color:var(--color-texto-secundario)}.place-value__target strong{font-size:1.05rem;color:#744b13}.place-value__abacus{display:grid;grid-template-columns:repeat(6,1fr);gap:.4rem}.place-value__column{display:flex;min-width:0;flex-direction:column;align-items:center;gap:.25rem}.place-value__label{font-weight:900;color:var(--color-verde)}.place-value__column small{min-height:2.2em;text-align:center;font-size:.6rem;color:var(--color-texto-tenue)}.place-value__column button{width:32px;height:32px;border:1px solid var(--color-borde);border-radius:50%;background:white;font-size:1.1rem}.place-value__rod{position:relative;display:flex;width:40px;height:126px;flex-direction:column-reverse;align-items:center;justify-content:flex-start;gap:2px;padding:5px;border-radius:20px;background:linear-gradient(90deg,transparent 47%,#8a6842 47% 53%,transparent 53%)}.place-value__rod i{display:block;width:31px;height:9px;border-radius:99px;background:#f3a33b;box-shadow:0 1px 2px #8a5a20}.place-value__rod b{position:absolute;top:50%;left:50%;display:grid;width:27px;height:27px;place-items:center;transform:translate(-50%,-50%);border-radius:50%;background:white;border:1px solid var(--color-borde);color:var(--color-verde)}.place-value__result{display:flex;flex-direction:column;align-items:center;margin-top:.8rem;padding:.8rem;border-radius:12px;background:var(--color-verde-suave)}.place-value__result span{font-size:1.7rem;font-weight:900;color:var(--color-verde)}.place-value__result strong{text-align:center}.place-value__feedback{margin-top:.7rem;padding:.65rem;border-radius:10px;text-align:center;font-weight:800}.place-value__feedback.ok{background:#e5f6e9;color:#18713c}.place-value__feedback.wrong{background:#fff0e8;color:#aa4f27}.place-value__check{display:block;margin:.7rem auto 0}.numbers-lesson__table{display:grid;grid-template-columns:minmax(80px,.5fr) 1fr;border:1px solid var(--color-borde);border-radius:14px;overflow:hidden}.numbers-lesson__table-head,.numbers-lesson__row{display:contents}.numbers-lesson__table span,.numbers-lesson__table b,.numbers-lesson__table button{padding:.62rem;border:0;border-bottom:1px solid var(--color-borde);background:white;text-align:left}.numbers-lesson__table-head span{background:#f4f7f4;font-size:.7rem;font-weight:800}.numbers-lesson__row button{color:var(--color-azul);cursor:pointer}.numbers-lesson__tip{margin-top:.8rem;padding:.7rem;border-radius:10px;background:#fff8e7;font-size:.8rem}.numbers-lesson__practice{width:100%;margin-top:.8rem;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--color-azul);color:white;font-weight:800}.numbers-lesson__practice:disabled{background:var(--color-verde);opacity:.8}@media(max-width:620px){.numbers-lesson__switch{grid-template-columns:1fr}.numbers-lesson__header{flex-direction:column}.numbers-lesson__progress{text-align:left}.numbers-lesson__stage{grid-template-columns:85px minmax(0,1fr)}.numbers-lesson__numeral{font-size:2.5rem}.place-value__abacus{gap:.15rem}.place-value__rod{width:31px}.place-value__rod i{width:25px}.place-value__column small{font-size:.5rem}.place-value header{align-items:flex-start;flex-direction:column}.numbers-lesson__table{font-size:.78rem}}
</style>
