<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
  items: { type: Array, default: () => [] },
  reproduciendoId: { type: [Number, String], default: null },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['reproducir', 'hablar', 'practicar']);

const leccion = ref(1);
const hora = ref(9);
const minuto = ref(0);
const horaInicio = ref(9);
const minutoInicio = ref(0);
const horaFin = ref(11);
const minutoFin = ref(30);
const respuestas = ref({});

const numeros = ['twelve','one','two','three','four','five','six','seven','eight','nine','ten','eleven','twelve','thirteen','fourteen','fifteen','sixteen','seventeen','eighteen','nineteen','twenty','twenty-one','twenty-two','twenty-three','twenty-four','twenty-five','twenty-six','twenty-seven','twenty-eight','twenty-nine'];
const reglas = [
  { clave: 'at', uso: 'Hora exacta', ejemplo: 'at 9:00' },
  { clave: 'o’clock', uso: 'En punto', ejemplo: "It's nine o'clock." },
  { clave: 'past', uso: 'Minutos después', ejemplo: 'ten past nine' },
  { clave: 'to', uso: 'Minutos antes', ejemplo: 'ten to ten' },
  { clave: 'from…to', uso: 'Rango horario', ejemplo: 'from 9:00 to 11:00' },
  { clave: 'in', uso: 'Mañana o tarde', ejemplo: 'in the morning' },
  { clave: 'at night', uso: 'Durante la noche', ejemplo: 'at night' },
];
const momentos = [
  { desde: 5, hasta: 11, icono: '🌅', nombre: 'morning', frase: 'in the morning' },
  { desde: 12, hasta: 16, icono: '☀️', nombre: 'afternoon', frase: 'in the afternoon' },
  { desde: 17, hasta: 20, icono: '🌇', nombre: 'evening', frase: 'in the evening' },
  { desde: 21, hasta: 23, icono: '🌙', nombre: 'night', frase: 'at night' },
  { desde: 0, hasta: 4, icono: '🌌', nombre: 'early morning', frase: 'in the early morning' },
];
const preguntas = [
  { id: 1, texto: 'The class starts ___ 9:00.', respuesta: 'at', opciones: ['at','on','in'] },
  { id: 2, texto: 'I study ___ the morning.', respuesta: 'in', opciones: ['at','on','in'] },
  { id: 3, texto: 'The store is open ___ 8:00 ___ 4:00.', respuesta: 'from / to', opciones: ['at / at','from / to','in / on'] },
];

const angulos = computed(() => ({ horas: (hora.value % 12) * 30 + minuto.value * .5, minutos: minuto.value * 6 }));
function hora12(valor) { return valor % 12 || 12; }
function periodo(valor) { return valor < 12 ? 'a.m.' : 'p.m.'; }
function digital(h, m) { return `${String(hora12(h)).padStart(2,'0')}:${String(m).padStart(2,'0')} ${periodo(h)}`; }
function horaNatural(h, m) {
  const actual = numeros[hora12(h)];
  const siguiente = numeros[hora12(h + 1)];
  if (m === 0) return `${actual} o'clock`;
  if (m === 15) return `a quarter past ${actual}`;
  if (m === 30) return `half past ${actual}`;
  if (m === 45) return `a quarter to ${siguiente}`;
  if (m < 30) return `${numeros[m]} past ${actual}`;
  return `${numeros[60 - m]} to ${siguiente}`;
}
const horaEnIngles = computed(() => `It's ${horaNatural(hora.value, minuto.value)}.`);
const momentoActual = computed(() => momentos.find((item) => hora.value >= item.desde && hora.value <= item.hasta) || momentos[0]);
const conversacion = computed(() => ({
  pregunta: 'What time does the class start?',
  respuesta: `The class starts at ${digital(horaInicio.value, minutoInicio.value)}.`,
  rango: `It runs from ${digital(horaInicio.value, minutoInicio.value)} to ${digital(horaFin.value, minutoFin.value)}.`,
}));
const referenciasReloj = computed(() => props.items.filter((item) => ['en_punto','media','cuarto','minutos'].includes(item.variante)));
const partesDia = computed(() => props.items.filter((item) => item.variante === 'parte_dia'));

function responder(id, opcion) { respuestas.value = { ...respuestas.value, [id]: opcion }; }
function usarEjemplo(item) {
  const match = item.texto_es?.match(/^(\d{1,2}):(\d{2})$/);
  if (match) { hora.value = Number(match[1]); minuto.value = Number(match[2]); }
  emit('reproducir', item);
}
</script>

<template>
  <section class="time-lesson">
    <aside class="time-summary">
      <header><span>🕒</span><div><small>RESUMEN RÁPIDO</small><h2>Decir la hora y hablar de horarios</h2></div></header>
      <p><b>Clave:</b> usamos <b>at</b> antes de una hora exacta: <i>at 9:00</i>.</p>
      <div><article v-for="regla in reglas" :key="regla.clave"><strong>{{ regla.clave }}</strong><span>{{ regla.uso }}</span><small>{{ regla.ejemplo }}</small></article></div>
    </aside>

    <nav class="time-tabs">
      <button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero">
        <b>0{{ numero }}</b><span>Hora {{ numero }}</span><small>{{ numero === 1 ? 'Leer el reloj' : numero === 2 ? 'Partes del día' : 'Conversaciones' }}</small>
      </button>
    </nav>

    <section v-if="leccion === 1" class="time-panel">
      <header><small>HORA 1</small><h3>Mové las manecillas</h3><p>Elegí una hora y compará la forma digital con la expresión conversacional.</p></header>
      <div class="clock-lab">
        <div class="clock" aria-label="Reloj interactivo">
          <i v-for="marca in 12" :key="marca" :style="{ transform: `rotate(${marca * 30}deg)` }"></i>
          <span class="hand hour" :style="{ transform: `translateX(-50%) rotate(${angulos.horas}deg)` }"></span>
          <span class="hand minute" :style="{ transform: `translateX(-50%) rotate(${angulos.minutos}deg)` }"></span><b></b>
        </div>
        <div class="clock-controls">
          <label>Hour<select v-model.number="hora"><option v-for="numero in 24" :key="numero - 1" :value="numero - 1">{{ String(numero - 1).padStart(2,'0') }}</option></select></label>
          <label>Minutes<select v-model.number="minuto"><option v-for="valor in [0,5,10,15,20,25,30,35,40,45,50,55]" :key="valor" :value="valor">{{ String(valor).padStart(2,'0') }}</option></select></label>
          <div class="time-result"><small>{{ digital(hora, minuto) }}</small><strong>{{ horaEnIngles }}</strong><button @click="emit('hablar', horaEnIngles, 1)">🔊 Escuchar</button></div>
        </div>
      </div>
      <div v-if="referenciasReloj.length" class="time-examples"><button v-for="item in referenciasReloj" :key="item.id" :disabled="reproduciendoId === item.id" @click="usarEjemplo(item)"><b>{{ item.texto_es }}</b><span>{{ item.texto_en }}</span></button></div>
    </section>

    <section v-else-if="leccion === 2" class="time-panel">
      <header><small>HORA 2</small><h3>Partes del día</h3><p>La preposición cambia: <b>in</b> the morning, pero <b>at</b> night.</p></header>
      <div class="day-line"><article v-for="item in momentos" :key="item.nombre" :class="{ active: momentoActual.nombre === item.nombre }"><span>{{ item.icono }}</span><strong>{{ item.nombre }}</strong><small>{{ item.frase }}</small><i>{{ String(item.desde).padStart(2,'0') }}:00–{{ item.hasta }}:59</i></article></div>
      <div class="day-picker"><label>Explorá una hora<input v-model.number="hora" type="range" min="0" max="23"><b>{{ digital(hora, 0) }}</b></label><div><span>{{ momentoActual.icono }}</span><strong>{{ momentoActual.frase }}</strong><button @click="emit('hablar', `It's ${digital(hora, 0)} ${momentoActual.frase}.`, 1)">🔊</button></div></div>
      <div v-if="partesDia.length" class="time-examples"><button v-for="item in partesDia" :key="item.id" @click="emit('reproducir', item)"><span>{{ item.texto_en }}</span></button></div>
    </section>

    <section v-else class="time-panel">
      <header><small>HORA 3</small><h3>Conversaciones y horarios</h3><p>Armá un horario y usalo para responder preguntas reales.</p></header>
      <div class="schedule-builder">
        <label>Start<select v-model.number="horaInicio"><option v-for="numero in 24" :key="numero - 1" :value="numero - 1">{{ String(numero - 1).padStart(2,'0') }}</option></select><select v-model.number="minutoInicio"><option v-for="valor in [0,15,30,45]" :key="valor" :value="valor">{{ String(valor).padStart(2,'0') }}</option></select></label>
        <label>End<select v-model.number="horaFin"><option v-for="numero in 24" :key="numero - 1" :value="numero - 1">{{ String(numero - 1).padStart(2,'0') }}</option></select><select v-model.number="minutoFin"><option v-for="valor in [0,15,30,45]" :key="valor" :value="valor">{{ String(valor).padStart(2,'0') }}</option></select></label>
      </div>
      <div class="time-chat"><button @click="emit('hablar', conversacion.pregunta, 1)">👤 {{ conversacion.pregunta }} 🔊</button><button @click="emit('hablar', conversacion.respuesta, 1)">👤 {{ conversacion.respuesta }} 🔊</button><button @click="emit('hablar', conversacion.rango, 1)">👤 {{ conversacion.rango }} 🔊</button></div>
      <div class="time-quiz"><article v-for="pregunta in preguntas" :key="pregunta.id"><p>{{ pregunta.texto }}</p><button v-for="opcion in pregunta.opciones" :key="opcion" :class="{ correct: respuestas[pregunta.id] && opcion === pregunta.respuesta, wrong: respuestas[pregunta.id] === opcion && opcion !== pregunta.respuesta }" @click="responder(pregunta.id, opcion)">{{ opcion }}</button><small v-if="respuestas[pregunta.id]">{{ respuestas[pregunta.id] === pregunta.respuesta ? '✓ Correcto' : `La respuesta es “${pregunta.respuesta}”.` }}</small></article></div>
    </section>

    <button class="time-practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.time-lesson{display:grid;gap:1rem}.time-summary{padding:1rem;border:1px solid #bad7e7;border-left:5px solid var(--color-azul);border-radius:16px;background:linear-gradient(135deg,#f1f8fd,#fffaf0)}.time-summary header{display:flex;align-items:center;gap:.7rem}.time-summary header>span{font-size:2rem}.time-summary h2,.time-panel h3{margin:.15rem 0}.time-summary small,.time-panel header>small{font-size:.65rem;font-weight:900;letter-spacing:.08em;color:var(--color-azul)}.time-summary>p{padding:.55rem;border-radius:9px;background:white;font-size:.82rem}.time-summary>div{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:.45rem}.time-summary article{display:flex;flex-direction:column;padding:.55rem;border-radius:10px;background:white}.time-summary article strong{color:var(--color-azul)}.time-summary article span{font-size:.72rem}.time-summary article small{margin-top:.2rem;color:var(--color-texto-tenue);letter-spacing:0}.time-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.time-tabs button{display:grid;grid-template-columns:32px 1fr;border:1px solid var(--color-borde);border-radius:12px;background:white;padding:.65rem;text-align:left}.time-tabs b{grid-row:1/3;color:var(--color-azul)}.time-tabs small{color:var(--color-texto-tenue)}.time-tabs button.active{border-color:var(--color-azul);background:#eef7fd}.time-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:16px;background:white}.time-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.clock-lab{display:grid;grid-template-columns:190px 1fr;align-items:center;gap:1.2rem}.clock{position:relative;width:180px;height:180px;border:4px solid var(--color-azul);border-radius:50%;background:white}.clock>i{position:absolute;top:6px;left:calc(50% - 1px);width:2px;height:9px;background:#78909c;transform-origin:50% 81px}.hand{position:absolute;bottom:50%;left:50%;transform-origin:50% 100%;border-radius:5px}.hand.hour{width:6px;height:48px;background:var(--color-azul)}.hand.minute{width:4px;height:67px;background:#ef8b32}.clock>b{position:absolute;top:50%;left:50%;width:12px;height:12px;transform:translate(-50%,-50%);border-radius:50%;background:var(--color-azul)}.clock-controls{display:grid;grid-template-columns:1fr 1fr;gap:.55rem}.clock-controls label,.schedule-builder label{display:flex;flex-direction:column;gap:.25rem;font-size:.72rem;font-weight:800}select{padding:.6rem;border:1px solid var(--color-borde);border-radius:9px;background:white}.time-result{grid-column:1/-1;display:flex;flex-direction:column;align-items:center;gap:.3rem;padding:.8rem;border-radius:12px;background:#eef7fd;text-align:center}.time-result strong{font-size:1.2rem}.time-result button,.day-picker button{border:0;border-radius:8px;background:var(--color-azul);color:white;padding:.45rem .65rem}.time-examples{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:.4rem;margin-top:.8rem}.time-examples button{display:flex;flex-direction:column;padding:.55rem;border:1px solid var(--color-borde);border-radius:9px;background:white}.time-examples span{font-size:.75rem}.day-line{display:grid;grid-template-columns:repeat(5,1fr);gap:.4rem}.day-line article{display:flex;flex-direction:column;align-items:center;padding:.55rem;border:1px solid var(--color-borde);border-radius:10px;text-align:center}.day-line article.active{border-color:var(--color-azul);background:#eef7fd}.day-line article>span{font-size:1.7rem}.day-line small,.day-line i{font-size:.65rem}.day-picker{display:grid;grid-template-columns:1fr 1fr;align-items:center;gap:.8rem;margin-top:.8rem;padding:.8rem;border-radius:12px;background:#f7f9f7}.day-picker label{display:flex;flex-direction:column}.day-picker>div{display:flex;align-items:center;justify-content:center;gap:.5rem}.day-picker>div>span{font-size:2rem}.schedule-builder{display:grid;grid-template-columns:1fr 1fr;gap:.7rem}.schedule-builder label{display:grid;grid-template-columns:1fr 1fr}.schedule-builder label:first-letter{grid-column:1/-1}.time-chat{display:flex;flex-direction:column;gap:.45rem;margin-top:.8rem}.time-chat button{max-width:82%;padding:.7rem;border:0;border-radius:13px;background:#e8f3ff;text-align:left}.time-chat button:nth-child(even){align-self:flex-end;background:#fff1de}.time-quiz{display:grid;gap:.5rem;margin-top:.8rem}.time-quiz article{padding:.6rem;border:1px solid var(--color-borde);border-radius:9px}.time-quiz p{margin:0 0 .4rem}.time-quiz button{margin-right:.3rem;padding:.35rem .55rem;border:1px solid var(--color-borde);border-radius:7px;background:white}.time-quiz button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.time-quiz button.wrong{border-color:#bf5b40;background:#fff0e8}.time-quiz small{display:block;margin-top:.35rem}.time-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:var(--color-azul);color:white;font-weight:800}.time-practice:disabled{background:var(--color-verde)}@media(max-width:650px){.time-tabs,.clock-lab,.schedule-builder{grid-template-columns:1fr}.clock{margin:auto}.time-summary>div{grid-template-columns:1fr 1fr}.day-line{grid-template-columns:repeat(2,1fr)}.day-picker{grid-template-columns:1fr}.time-chat button{max-width:100%}}
</style>
