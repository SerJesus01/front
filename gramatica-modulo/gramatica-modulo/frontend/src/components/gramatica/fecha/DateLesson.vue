<script setup>
import { computed, ref } from 'vue';

const props = defineProps({ completado: { type: Boolean, default: false } });
const emit = defineEmits(['practicar', 'hablar']);

const leccion = ref(1);
const mes = ref(7);
const dia = ref(23);
const anio = ref(2026);
const mesFin = ref(8);
const diaFin = ref(5);
const conectorRango = ref('from');
const respuestas = ref({});

const meses = ['January','February','March','April','May','June','July','August','September','October','November','December'];
const reglas = [
  { clave: 'on', uso: 'Día o fecha', ejemplo: 'on Monday · on August 23rd' },
  { clave: 'in', uso: 'Mes, año o periodo', ejemplo: 'in August · in 2026' },
  { clave: 'at', uso: 'Hora exacta', ejemplo: 'at 9:00' },
  { clave: 'from…to', uso: 'Inicio y final', ejemplo: 'from Monday to Friday' },
  { clave: 'between…and', uso: 'Entre dos fechas', ejemplo: 'between May and June' },
  { clave: 'until', uso: 'Hasta un límite', ejemplo: 'until December' },
  { clave: 'through', uso: 'Incluye el último día', ejemplo: 'Monday through Friday' },
];
const preguntas = [
  { id: 1, antes: 'The exam is', hueco: 'on', despues: 'August 23rd.' },
  { id: 2, antes: 'Classes start', hueco: 'in', despues: 'September.' },
  { id: 3, antes: 'The movie starts', hueco: 'at', despues: '9:00.' },
];

function sufijo(numero) {
  const resto100 = numero % 100;
  if (resto100 >= 11 && resto100 <= 13) return 'th';
  return ({ 1: 'st', 2: 'nd', 3: 'rd' })[numero % 10] || 'th';
}
function fechaTexto(indiceMes, numeroDia, numeroAnio = anio.value) {
  return `${meses[indiceMes]} ${numeroDia}${sufijo(numeroDia)}, ${numeroAnio}`;
}
const fechaAmericana = computed(() => fechaTexto(mes.value, dia.value));
const fechaBritanica = computed(() => `${dia.value}${sufijo(dia.value)} ${meses[mes.value]} ${anio.value}`);
const rangoTexto = computed(() => {
  const inicio = fechaTexto(mes.value, dia.value, anio.value);
  const fin = fechaTexto(mesFin.value, diaFin.value, anio.value);
  if (conectorRango.value === 'between') return `between ${inicio} and ${fin}`;
  if (conectorRango.value === 'until') return `until ${fin}`;
  if (conectorRango.value === 'through') return `${inicio} through ${fin}`;
  return `from ${inicio} to ${fin}`;
});

function diasDelMes(indice) {
  return new Date(anio.value, Number(indice) + 1, 0).getDate();
}
function responder(id, opcion) {
  respuestas.value = { ...respuestas.value, [id]: opcion };
}
</script>

<template>
  <section class="date-lesson">
    <aside class="date-summary">
      <header><span>🗓️</span><div><small>RESUMEN RÁPIDO</small><h2>Fechas, horas y rangos</h2></div></header>
      <p class="date-summary__warning"><b>Recordá:</b> una fecha usa <b>on</b>; una hora exacta usa <b>at</b>.</p>
      <div class="date-summary__grid">
        <article v-for="regla in reglas" :key="regla.clave">
          <strong>{{ regla.clave }}</strong><span>{{ regla.uso }}</span><small>{{ regla.ejemplo }}</small>
        </article>
      </div>
    </aside>

    <nav class="date-tabs" aria-label="Lecciones de fecha">
      <button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero">
        <b>0{{ numero }}</b><span>Fecha {{ numero }}</span>
        <small>{{ numero === 1 ? 'Construir' : numero === 2 ? 'Conversar' : 'Rangos y preposiciones' }}</small>
      </button>
    </nav>

    <section v-if="leccion === 1" class="date-panel">
      <header><small>FECHA 1</small><h3>Construí una fecha</h3><p>Elegí sus partes y observá cómo cambia el orden en inglés.</p></header>
      <div class="date-builder">
        <label>Month<select v-model.number="mes" @change="dia = Math.min(dia, diasDelMes(mes))"><option v-for="(nombre,index) in meses" :key="nombre" :value="index">{{ nombre }}</option></select></label>
        <label>Day<select v-model.number="dia"><option v-for="numero in diasDelMes(mes)" :key="numero" :value="numero">{{ numero }}{{ sufijo(numero) }}</option></select></label>
        <label>Year<input v-model.number="anio" type="number" min="1900" max="2100"></label>
      </div>
      <div class="date-result"><small>AMERICAN ENGLISH</small><strong>{{ fechaAmericana }}</strong><button @click="emit('hablar', fechaAmericana, 1)">🔊 Escuchar</button></div>
      <div class="date-compare"><span><b>US</b> {{ String(mes + 1).padStart(2,'0') }}/{{ String(dia).padStart(2,'0') }}/{{ anio }}</span><span><b>UK</b> {{ String(dia).padStart(2,'0') }}/{{ String(mes + 1).padStart(2,'0') }}/{{ anio }}</span></div>
      <p class="date-note">En Reino Unido también se dice <b>{{ fechaBritanica }}</b>.</p>
    </section>

    <section v-else-if="leccion === 2" class="date-panel">
      <header><small>FECHA 2</small><h3>Preguntar y responder</h3><p>Usá la fecha que construiste en una conversación real.</p></header>
      <div class="date-chat">
        <button @click="emit('hablar', `What's the date today?`, 1)">👤 What’s the date today? 🔊</button>
        <button @click="emit('hablar', `Today is ${fechaAmericana}.`, 1)">👤 Today is {{ fechaAmericana }}. 🔊</button>
      </div>
      <div class="date-pattern"><span>What’s the date <b>today</b>?</span><span>Today is <b>{{ fechaAmericana }}</b>.</span></div>
      <p class="date-note"><b>Otros ejemplos:</b> What date is the party? · When is your birthday?</p>
    </section>

    <section v-else class="date-panel">
      <header><small>FECHA 3</small><h3>Rangos y preposiciones</h3><p>Construí un periodo y después elegí entre <b>at</b>, <b>on</b> e <b>in</b>.</p></header>
      <div class="range-builder">
        <label>Conector<select v-model="conectorRango"><option value="from">from…to</option><option value="between">between…and</option><option value="until">until</option><option value="through">through</option></select></label>
        <label>Inicio<select v-model.number="mes"><option v-for="(nombre,index) in meses" :key="nombre" :value="index">{{ nombre }}</option></select><select v-model.number="dia"><option v-for="numero in diasDelMes(mes)" :key="numero">{{ numero }}</option></select></label>
        <label>Final<select v-model.number="mesFin"><option v-for="(nombre,index) in meses" :key="nombre" :value="index">{{ nombre }}</option></select><select v-model.number="diaFin"><option v-for="numero in diasDelMes(mesFin)" :key="numero">{{ numero }}</option></select></label>
      </div>
      <div class="date-result"><small>RANGO CONSTRUIDO</small><strong>{{ rangoTexto }}</strong><button @click="emit('hablar', rangoTexto, 1)">🔊 Escuchar</button></div>
      <div class="prep-quiz">
        <article v-for="pregunta in preguntas" :key="pregunta.id">
          <p>{{ pregunta.antes }} <b>___</b> {{ pregunta.despues }}</p>
          <div><button v-for="opcion in ['at','on','in']" :key="opcion" :class="{ selected: respuestas[pregunta.id] === opcion, correct: respuestas[pregunta.id] && opcion === pregunta.hueco, wrong: respuestas[pregunta.id] === opcion && opcion !== pregunta.hueco }" @click="responder(pregunta.id, opcion)">{{ opcion }}</button></div>
          <small v-if="respuestas[pregunta.id]">{{ respuestas[pregunta.id] === pregunta.hueco ? '✓ Correcto' : `Usá “${pregunta.hueco}” en este caso.` }}</small>
        </article>
      </div>
    </section>

    <button class="date-practice" :disabled="props.completado" @click="emit('practicar')">{{ props.completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.date-lesson{display:grid;gap:1rem}.date-summary{padding:1rem;border:1px solid #b9ddc6;border-left:5px solid var(--color-verde);border-radius:16px;background:linear-gradient(135deg,#f1fbf4,#fffaf0)}.date-summary header{display:flex;align-items:center;gap:.7rem}.date-summary header>span{font-size:2rem}.date-summary h2,.date-panel h3{margin:.15rem 0}.date-summary small,.date-panel header>small{font-size:.65rem;font-weight:900;letter-spacing:.08em;color:var(--color-verde)}.date-summary__warning{padding:.55rem;border-radius:9px;background:white;font-size:.82rem}.date-summary__grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(145px,1fr));gap:.45rem}.date-summary article{display:flex;flex-direction:column;padding:.55rem;border-radius:10px;background:white}.date-summary article strong{color:var(--color-verde)}.date-summary article span{font-size:.72rem}.date-summary article small{margin-top:.2rem;color:var(--color-texto-tenue);letter-spacing:0}.date-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.date-tabs button{display:grid;grid-template-columns:32px 1fr;border:1px solid var(--color-borde);border-radius:12px;background:white;padding:.65rem;text-align:left}.date-tabs b{grid-row:1/3;color:var(--color-verde)}.date-tabs small{color:var(--color-texto-tenue)}.date-tabs button.active{border-color:var(--color-verde);background:var(--color-verde-suave)}.date-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:16px;background:white}.date-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.date-builder,.range-builder{display:grid;grid-template-columns:repeat(3,1fr);gap:.6rem}.date-builder label,.range-builder label{display:flex;flex-direction:column;gap:.25rem;font-size:.72rem;font-weight:800}.range-builder label{flex-wrap:wrap}.range-builder label select+select{margin-top:.25rem}select,input{min-width:0;padding:.6rem;border:1px solid var(--color-borde);border-radius:9px;background:white}.date-result{display:flex;flex-direction:column;align-items:center;gap:.35rem;margin-top:.8rem;padding:1rem;border-radius:12px;background:var(--color-verde-suave);text-align:center}.date-result strong{font-size:1.3rem}.date-result button{border:0;border-radius:9px;background:var(--color-verde);color:white;padding:.5rem .7rem}.date-compare,.date-pattern{display:flex;justify-content:center;gap:1rem;margin-top:.7rem}.date-compare span,.date-pattern span{padding:.5rem .7rem;border-radius:9px;background:#f5f7f5}.date-note{padding:.65rem;border-radius:9px;background:#fff8e7;font-size:.8rem}.date-chat{display:flex;flex-direction:column;gap:.6rem}.date-chat button{max-width:80%;padding:.75rem;border:0;border-radius:14px;background:#e8f3ff;text-align:left}.date-chat button+button{align-self:flex-end;background:#fff1de}.prep-quiz{display:grid;gap:.55rem;margin-top:.8rem}.prep-quiz article{padding:.65rem;border:1px solid var(--color-borde);border-radius:10px}.prep-quiz p{margin:0 0 .45rem}.prep-quiz button{margin-right:.35rem;padding:.4rem .65rem;border:1px solid var(--color-borde);border-radius:8px;background:white}.prep-quiz button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.prep-quiz button.wrong{border-color:#c65a3a;background:#fff0e8}.prep-quiz article>small{display:block;margin-top:.4rem}.date-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--color-azul);color:white;font-weight:800}.date-practice:disabled{background:var(--color-verde)}@media(max-width:650px){.date-tabs,.date-builder,.range-builder{grid-template-columns:1fr}.date-summary__grid{grid-template-columns:1fr 1fr}.date-compare,.date-pattern{flex-direction:column}.date-chat button{max-width:100%}}
</style>
