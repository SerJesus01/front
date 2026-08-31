<script setup>
import { computed, ref } from 'vue';

const props = defineProps({ items: { type: Array, default: () => [] }, reproduciendoId: { type: [Number, String], default: null }, completado: { type: Boolean, default: false } });
const emit = defineEmits(['reproducir', 'hablar', 'practicar']);

const leccion = ref(1);
const palabraActiva = ref(0);
const mensajeActivo = ref(0);
const abreviaturaAbierta = ref(null);
const retoActual = ref(0);
const respuestaElegida = ref(null);
const aciertos = ref(new Set());

const palabras = [
  { corta: 'fridge', larga: 'refrigerator', significado: 'refrigerador', icono: '🧊', tipo: 'palabra recortada' },
  { corta: 'app', larga: 'application', significado: 'aplicación', icono: '📱', tipo: 'palabra recortada' },
  { corta: 'info', larga: 'information', significado: 'información', icono: 'ℹ️', tipo: 'palabra recortada' },
  { corta: 'photo', larga: 'photograph', significado: 'foto', icono: '📷', tipo: 'palabra recortada' },
  { corta: 'gym', larga: 'gymnasium', significado: 'gimnasio', icono: '🏋️', tipo: 'palabra recortada' },
  { corta: 'cab', larga: 'taxicab', significado: 'taxi', icono: '🚕', tipo: 'palabra cotidiana' },
  { corta: 'TV', larga: 'television', significado: 'televisión', icono: '📺', tipo: 'iniciales' },
];
const palabra = computed(() => palabras[palabraActiva.value]);

const diccionario = {
  FYI: { expansion: 'for your information', significado: 'para tu información', voz: 'F Y I', tono: 'neutral' },
  ASAP: { expansion: 'as soon as possible', significado: 'lo antes posible', voz: 'A S A P', tono: 'urgente' },
  ATM: { expansion: 'automated teller machine', significado: 'cajero automático', voz: 'A T M', tono: 'neutral' },
  BTW: { expansion: 'by the way', significado: 'por cierto', voz: 'B T W', tono: 'casual' },
  IDK: { expansion: "I don't know", significado: 'no sé', voz: 'I D K', tono: 'muy casual' },
  TV: { expansion: 'television', significado: 'televisión', voz: 'T V', tono: 'neutral' },
};
const mensajes = [
  { icono: '🍽️', contexto: 'Plan entre amigos', texto: ['FYI', ', dinner moved to 8 PM. Please reply ', 'ASAP', '.'], traduccion: 'Para tu información, la cena cambió a las 8. Respondé lo antes posible.' },
  { icono: '💬', contexto: 'Chat entre amigos', texto: ['BTW', ', the new ', 'app', ' is great. ', 'IDK', ' if it works on my phone.'], traduccion: 'Por cierto, la nueva aplicación es genial. No sé si funciona en mi teléfono.' },
  { icono: '🏙️', contexto: 'En la ciudad', texto: ['Can you stop by the ', 'ATM', ' before we call a ', 'cab', '?'], traduccion: '¿Podés pasar por el cajero antes de que pidamos un taxi?' },
];
const mensaje = computed(() => mensajes[mensajeActivo.value]);

const retos = [
  { icono: '⏰', contexto: 'Necesitás una respuesta con urgencia.', frase: 'Please reply ___.', respuesta: 'ASAP', opciones: ['ATM', 'ASAP', 'TV', 'FYI'], explicacion: 'ASAP comunica “as soon as possible”.' },
  { icono: 'ℹ️', contexto: 'Compartís un dato útil, sin pedir acción.', frase: '___, tomorrow is a holiday.', respuesta: 'FYI', opciones: ['FYI', 'IDK', 'cab', 'app'], explicacion: 'FYI introduce información que conviene conocer.' },
  { icono: '💵', contexto: 'Buscás dónde retirar efectivo.', frase: 'Is there an ___ near here?', respuesta: 'ATM', opciones: ['info', 'ATM', 'ASAP', 'photo'], explicacion: 'ATM es la sigla habitual para cajero automático.' },
  { icono: '📸', contexto: 'Pedís una imagen en un chat.', frase: 'Send me the ___, please.', respuesta: 'photo', opciones: ['fridge', 'gym', 'photo', 'FYI'], explicacion: 'Photo es la forma cotidiana abreviada de photograph.' },
  { icono: '🏋️', contexto: 'Contás adónde vas a entrenar.', frase: "I'm going to the ___.", respuesta: 'gym', opciones: ['TV', 'gym', 'ATM', 'info'], explicacion: 'Gym viene de gymnasium, pero la forma larga casi no se usa aquí.' },
];
const reto = computed(() => retos[retoActual.value]);
const respuestaCorrecta = computed(() => respuestaElegida.value === reto.value.respuesta);
const totalAciertos = computed(() => aciertos.value.size);

function normalizar(texto) { return String(texto || '').toLowerCase().replace(/[^a-z]/g, ''); }
function escuchar(texto, voz = null) {
  const referencia = props.items.find((item) => normalizar(item.texto_en) === normalizar(texto));
  if (referencia?.audio_key) emit('reproducir', referencia);
  else emit('hablar', voz || texto, 1);
}
function reproducirMensaje() {
  const limpio = mensaje.value.texto.map((parte) => diccionario[parte]?.voz || parte).join('');
  emit('hablar', limpio, 1);
}
function responder(opcion) {
  respuestaElegida.value = opcion;
  if (opcion === reto.value.respuesta) { const nuevos = new Set(aciertos.value); nuevos.add(retoActual.value); aciertos.value = nuevos; }
}
function siguienteReto() { retoActual.value = (retoActual.value + 1) % retos.length; respuestaElegida.value = null; }
</script>

<template>
  <section class="abbr-lesson">
    <aside class="abbr-summary">
      <header><span>⚡</span><div><small>DECODIFICADOR RÁPIDO</small><h2>El inglés cotidiano acorta todo</h2></div></header>
      <p>Hay dos patrones: <b>recortar palabras</b> (<i>application → app</i>) y usar <b>iniciales</b> (<i>for your information → FYI</i>).</p>
      <div><article><b>app / info / photo</b><span>Se pronuncian como palabras</span></article><article><b>FYI / ATM / TV</b><span>Se dicen letra por letra</span></article><article><b>ASAP</b><span>Puede oírse letra por letra o “ay-sap”</span></article></div>
    </aside>

    <nav class="abbr-tabs"><button v-for="numero in 3" :key="numero" :class="{ active: leccion === numero }" @click="leccion = numero"><b>0{{ numero }}</b><span>{{ numero === 1 ? 'Acortá la palabra' : numero === 2 ? 'Descifrá mensajes' : 'Elegí por contexto' }}</span><small>{{ numero === 1 ? 'Forma larga → corta' : numero === 2 ? 'Chats y trabajo' : 'Reto relámpago' }}</small></button></nav>

    <section v-if="leccion === 1" class="abbr-panel">
      <header><small>ABREVIATURAS 1</small><h3>La máquina de palabras cortas</h3><p>Elegí una palabra y mirá cómo se transforma en la conversación diaria.</p></header>
      <div class="word-machine">
        <div class="word-list"><button v-for="(item, indice) in palabras" :key="item.corta" :class="{ active: palabraActiva === indice }" @click="palabraActiva = indice"><span>{{ item.icono }}</span><b>{{ item.corta }}</b></button></div>
        <div class="machine-stage"><span class="machine-icon">{{ palabra.icono }}</span><div class="word-long"><small>FORMA COMPLETA</small><del>{{ palabra.larga }}</del></div><i>→</i><div class="word-short"><small>FORMA COTIDIANA</small><strong>{{ palabra.corta }}</strong></div><p>{{ palabra.significado }} · {{ palabra.tipo }}</p><button @click="escuchar(palabra.corta)">🔊 Escuchar {{ palabra.corta }}</button></div>
      </div>
      <div class="abbr-tip"><span>💡</span><p>No todas las palabras largas se pueden recortar libremente. Aprendé estas formas como vocabulario real, no como una regla para inventar palabras.</p></div>
    </section>

    <section v-else-if="leccion === 2" class="abbr-panel">
      <header><small>ABREVIATURAS 2</small><h3>Decodificador de mensajes</h3><p>Tocá cada abreviatura resaltada para revelar qué significa.</p></header>
      <div class="message-tabs"><button v-for="(item, indice) in mensajes" :key="item.contexto" :class="{ active: mensajeActivo === indice }" @click="mensajeActivo = indice; abreviaturaAbierta = null"><span>{{ item.icono }}</span>{{ item.contexto }}</button></div>
      <div class="message-decoder">
        <div class="phone-message"><span class="avatar">S</span><p><template v-for="(parte, indice) in mensaje.texto" :key="indice"><button v-if="diccionario[parte]" :class="{ open: abreviaturaAbierta === parte }" @click="abreviaturaAbierta = parte">{{ parte }}</button><b v-else>{{ parte }}</b></template></p><button class="play-message" @click="reproducirMensaje">🔊</button></div>
        <div class="decoder-card"><template v-if="abreviaturaAbierta"><small>SIGNIFICA</small><strong>{{ diccionario[abreviaturaAbierta].expansion }}</strong><span>{{ diccionario[abreviaturaAbierta].significado }}</span><i>Tono: {{ diccionario[abreviaturaAbierta].tono }}</i><button @click="escuchar(abreviaturaAbierta, diccionario[abreviaturaAbierta].voz)">🔊 Escuchar</button></template><template v-else><span class="decoder-placeholder">🔎</span><b>Tocá una palabra resaltada</b><small>Acá aparecerá su significado.</small></template></div>
      </div>
      <div class="translation-strip"><b>Mensaje completo:</b><span>{{ mensaje.traduccion }}</span></div>
    </section>

    <section v-else class="abbr-panel">
      <header class="abbr-challenge-head"><div><small>ABREVIATURAS 3</small><h3>Reto relámpago</h3><p>Elegí la forma que suena natural en cada situación.</p></div><strong>{{ totalAciertos }}/{{ retos.length }}</strong></header>
      <div class="abbr-challenge"><span class="challenge-icon">{{ reto.icono }}</span><small>CONTEXTO</small><h4>{{ reto.contexto }}</h4><button class="challenge-sentence" @click="escuchar(reto.frase.replace('___', reto.respuesta))">{{ reto.frase }} <i>🔊</i></button><div class="abbr-options"><button v-for="opcion in reto.opciones" :key="opcion" :class="{ correct: respuestaElegida && opcion === reto.respuesta, wrong: respuestaElegida === opcion && opcion !== reto.respuesta }" :disabled="respuestaCorrecta" @click="responder(opcion)">{{ opcion }}</button></div><div v-if="respuestaElegida" class="abbr-feedback" :class="respuestaCorrecta ? 'ok' : 'retry'"><b>{{ respuestaCorrecta ? '✓ ¡Mensaje decodificado!' : '↻ Esa opción no encaja aquí' }}</b><span>{{ reto.explicacion }}</span></div><button v-if="respuestaCorrecta" class="next-abbr" @click="siguienteReto">Siguiente mensaje →</button></div>
    </section>

    <button class="abbr-practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.abbr-lesson{display:grid;gap:1rem}.abbr-summary{padding:1rem;border:1px solid #bcd9ee;border-left:5px solid #2586c4;border-radius:18px;background:linear-gradient(135deg,#eef8ff,#fff8df)}.abbr-summary header{display:flex;align-items:center;gap:.7rem}.abbr-summary header>span{font-size:2.2rem}.abbr-summary h2,.abbr-panel h3{margin:.15rem 0}.abbr-summary small,.abbr-panel header>small,.abbr-challenge-head small{font-size:.65rem;font-weight:900;letter-spacing:.09em;color:#1475b1}.abbr-summary>p{margin:.7rem 0;padding:.6rem;border-radius:10px;background:#fff;font-size:.83rem}.abbr-summary>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.45rem}.abbr-summary article{display:flex;flex-direction:column;padding:.6rem;border-radius:10px;background:#fff}.abbr-summary article b{color:#176da3}.abbr-summary article span{font-size:.65rem;color:var(--color-texto-tenue)}.abbr-tabs{display:grid;grid-template-columns:repeat(3,1fr);gap:.55rem}.abbr-tabs button{display:grid;grid-template-columns:34px 1fr;border:1px solid var(--color-borde);border-radius:13px;background:#fff;padding:.7rem;text-align:left;transition:.2s}.abbr-tabs button:hover{transform:translateY(-2px)}.abbr-tabs b{grid-row:1/3;color:#1979b4}.abbr-tabs small{color:var(--color-texto-tenue)}.abbr-tabs button.active{border-color:#2586c4;background:#edf7fd;box-shadow:0 4px 12px #2586c41a}.abbr-panel{padding:1rem;border:1px solid var(--color-borde);border-radius:18px;background:#fff}.abbr-panel header p{margin:.25rem 0 1rem;color:var(--color-texto-secundario)}.word-machine{display:grid;grid-template-columns:150px 1fr;gap:1rem}.word-list{display:grid;grid-template-columns:1fr 1fr;gap:.4rem;align-content:start}.word-list button{display:flex;flex-direction:column;align-items:center;padding:.5rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff}.word-list button>span{font-size:1.35rem}.word-list button.active{border-color:#2586c4;background:#eaf6fd}.machine-stage{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.7rem;min-height:240px;padding:1.2rem;border-radius:17px;background:linear-gradient(145deg,#edf8ff,#fff4d8);text-align:center}.machine-icon{grid-column:1/-1;font-size:2.8rem}.word-long,.word-short{display:flex;flex-direction:column}.machine-stage small{font-size:.58rem;font-weight:900;color:#1475b1}.word-long del{font:1.05rem Georgia,serif;color:#73828a}.word-short strong{font:italic 1.65rem Georgia,serif;color:#176da3}.machine-stage>i{font-style:normal;font-size:1.4rem;color:#e59327}.machine-stage>p,.machine-stage>button{grid-column:1/-1}.machine-stage>p{margin:.2rem;font-size:.72rem}.machine-stage>button,.decoder-card button{justify-self:center;border:0;border-radius:9px;background:#2586c4;color:#fff;padding:.5rem .7rem;font-weight:800}.abbr-tip{display:flex;gap:.55rem;margin-top:.8rem;padding:.65rem;border-radius:11px;background:#fff7df}.abbr-tip p{margin:0;font-size:.75rem}.message-tabs{display:flex;gap:.45rem;margin-bottom:.75rem}.message-tabs button{display:flex;align-items:center;gap:.3rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff;padding:.5rem .7rem}.message-tabs button.active{border-color:#2586c4;background:#edf7fd}.message-decoder{display:grid;grid-template-columns:1.4fr .6fr;gap:1rem;padding:1rem;border-radius:17px;background:#f4f8fb}.phone-message{display:grid;grid-template-columns:38px 1fr 32px;align-items:start;gap:.6rem;padding:.8rem;border-radius:14px;background:#fff}.avatar{display:grid;place-items:center;width:36px;height:36px;border-radius:50%;background:#2586c4;color:#fff;font-weight:900}.phone-message p{margin:0;padding:.6rem;border-radius:0 12px 12px 12px;background:#eaf5fc;line-height:1.7}.phone-message p>b{font-weight:500}.phone-message p>button{margin:0 .1rem;border:0;border-radius:5px;background:#ffda7a;color:#654500;padding:.15rem .3rem;font-weight:900}.phone-message p>button.open{background:#2586c4;color:#fff}.play-message{border:0;background:transparent}.decoder-card{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:1rem;border:1px dashed #9ec6dd;border-radius:14px;background:#fff;text-align:center}.decoder-card>small{font-size:.58rem;font-weight:900;color:#1475b1}.decoder-card>strong{font:italic 1.05rem Georgia,serif}.decoder-card>span{font-size:.72rem}.decoder-card>i{margin:.4rem;font-size:.65rem;color:var(--color-texto-tenue)}.decoder-placeholder{font-size:2.2rem!important}.translation-strip{display:flex;gap:.45rem;margin-top:.7rem;padding:.65rem;border-radius:10px;background:#eef8ff;font-size:.73rem}.abbr-challenge-head{display:flex;justify-content:space-between}.abbr-challenge-head>strong{display:grid;place-items:center;width:48px;height:48px;border-radius:50%;background:#e7f4fb;color:#176da3}.abbr-challenge{max-width:650px;margin:auto;padding:1.2rem;border-radius:17px;background:linear-gradient(145deg,#edf8ff,#fff8e4);text-align:center}.challenge-icon{font-size:3rem}.abbr-challenge>small{display:block;font-size:.6rem;font-weight:900;color:#1475b1}.abbr-challenge h4{margin:.3rem}.challenge-sentence{border:0;background:transparent;font:italic 1.25rem Georgia,serif}.challenge-sentence i{font-style:normal;font-size:.8rem}.abbr-options{display:grid;grid-template-columns:1fr 1fr;gap:.45rem;margin:1rem 0}.abbr-options button{padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:#fff;font-weight:800}.abbr-options button.correct{border-color:var(--color-verde);background:var(--color-verde-suave)}.abbr-options button.wrong{border-color:#c96543;background:#fff0ea}.abbr-feedback{display:flex;flex-direction:column;padding:.65rem;border-radius:10px;font-size:.75rem;text-align:left}.abbr-feedback.ok{background:var(--color-verde-suave);color:#236843}.abbr-feedback.retry{background:#fff0ea;color:#984228}.next-abbr{display:block;margin:.65rem 0 0 auto;border:0;border-radius:9px;background:#2586c4;color:#fff;padding:.55rem .8rem;font-weight:800}.abbr-practice{width:100%;padding:.8rem;border:0;border-radius:var(--radio-boton);background:#2586c4;color:#fff;font-weight:800}.abbr-practice:disabled{background:var(--color-verde)}
@media(max-width:760px){.word-machine,.message-decoder{grid-template-columns:1fr}.word-list{grid-template-columns:repeat(4,1fr)}.abbr-summary>div{grid-template-columns:1fr}.decoder-card{min-height:150px}.translation-strip{flex-direction:column}}
@media(max-width:520px){.abbr-tabs{grid-template-columns:1fr}.word-list{grid-template-columns:1fr 1fr}.machine-stage{grid-template-columns:1fr}.machine-stage>i{transform:rotate(90deg)}.message-tabs{overflow:auto}.phone-message{grid-template-columns:32px 1fr}.play-message{grid-column:1/-1}.abbr-options{grid-template-columns:1fr}.abbr-panel{padding:.75rem}}
</style>
