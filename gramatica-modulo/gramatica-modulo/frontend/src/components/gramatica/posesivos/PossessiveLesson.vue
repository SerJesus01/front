<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({
  mode: { type: String, required: true },
  completado: { type: Boolean, default: false },
});
const emit = defineEmits(['hablar', 'practicar']);

const paso = ref(1);
const tarjetaId = ref(0);
const retoId = ref(0);
const respuesta = ref(null);
const aciertos = ref(new Set());

const datos = {
  reflexive: {
    icono: '🪞',
    sobre: 'LA ACCIÓN REGRESA A LA PERSONA',
    titulo: 'Pronombres reflexivos',
    bajada: 'Usalos cuando alguien hace algo para sí o sin ayuda.',
    formula: 'persona → misma persona',
    color: '#a05c43',
    suave: '#fff0e8',
    tarjetas: [
      { frente: 'I', puente: 'myself', frase: 'I made breakfast myself.', ayuda: 'yo mismo/a' },
      { frente: 'you', puente: 'yourself', frase: 'You can help yourself.', ayuda: 'tú mismo/a' },
      { frente: 'he', puente: 'himself', frase: 'He cut himself shaving.', ayuda: 'él mismo' },
      { frente: 'she', puente: 'herself', frase: 'She painted the room herself.', ayuda: 'ella misma' },
      { frente: 'it', puente: 'itself', frase: 'The door closes by itself.', ayuda: 'por sí solo' },
      { frente: 'we', puente: 'ourselves', frase: 'We made the cake ourselves.', ayuda: 'nosotros mismos' },
      { frente: 'you', puente: 'yourselves', frase: 'Make yourselves at home.', ayuda: 'ustedes mismos' },
      { frente: 'they', puente: 'themselves', frase: 'They introduced themselves.', ayuda: 'ellos mismos' },
    ],
    escena: { inicio: 'She', accion: 'made the dress', final: 'herself', frase: 'She made the dress herself.' },
    nota: 'Si sujeto y objeto son personas distintas, no usamos reflexivo: “She called him”.',
    retos: [
      { frase: 'I fixed the shelf ___.', correcta: 'myself', opciones: ['myself', 'herself', 'ourselves'], ayuda: 'I se refleja en myself.' },
      { frase: 'They enjoyed ___ at the party.', correcta: 'themselves', opciones: ['ourselves', 'themselves', 'itself'], ayuda: 'They se refleja en themselves.' },
      { frase: 'Be careful! Don’t hurt ___.', correcta: 'yourself', opciones: ['himself', 'myself', 'yourself'], ayuda: 'Le hablamos directamente a una persona: yourself.' },
      { frase: 'We prepared everything ___.', correcta: 'ourselves', opciones: ['themselves', 'ourselves', 'yourselves'], ayuda: 'We se refleja en ourselves.' },
    ],
  },
  pronouns: {
    icono: '🏷️',
    sobre: 'DE QUIÉN ES CADA COSA',
    titulo: 'Whose, mine y yours',
    bajada: 'Preguntá por el dueño y evitá repetir el objeto.',
    formula: 'Whose...? → It’s mine.',
    color: '#3d7468',
    suave: '#e9f6f1',
    tarjetas: [
      { frente: 'my bag', puente: 'mine', frase: 'This bag is mine.', ayuda: 'mi bolsa → mía' },
      { frente: 'your keys', puente: 'yours', frase: 'Are these keys yours?', ayuda: 'tus llaves → tuyas' },
      { frente: 'his jacket', puente: 'his', frase: 'The blue jacket is his.', ayuda: 'su chamarra → suya' },
      { frente: 'her seat', puente: 'hers', frase: 'That seat is hers.', ayuda: 'su asiento → suyo' },
      { frente: 'our table', puente: 'ours', frase: 'The table by the window is ours.', ayuda: 'nuestra mesa → nuestra' },
      { frente: 'their dog', puente: 'theirs', frase: 'The small dog is theirs.', ayuda: 'su perro → suyo' },
    ],
    escena: { inicio: 'Whose umbrella', accion: 'is this?', final: 'It’s mine.', frase: 'Whose umbrella is this? It’s mine.' },
    nota: 'Mine, yours, his, hers, ours y theirs van solos: nunca decimos “mine bag”.',
    retos: [
      { frase: '___ phone is ringing?', correcta: 'Whose', opciones: ['Who', 'Whose', 'Who’s'], ayuda: 'Whose pregunta a quién pertenece algo.' },
      { frase: 'This cup is not mine. Is it ___?', correcta: 'yours', opciones: ['your', 'yours', 'yourself'], ayuda: 'Yours reemplaza “your cup”.' },
      { frase: 'Our seats are here. Those are ___.', correcta: 'theirs', opciones: ['their', 'theirs', 'them'], ayuda: 'Theirs reemplaza “their seats”.' },
      { frase: 'That scarf belongs to Ana. It’s ___.', correcta: 'hers', opciones: ['her', 'hers', 'she'], ayuda: 'Hers va solo y reemplaza el objeto.' },
    ],
  },
  apostrophe: {
    icono: '🔗',
    sobre: 'CONECTÁ AL DUEÑO CON SU OBJETO',
    titulo: "Posesivo con ’s",
    bajada: 'Poné primero a la persona y después aquello que le pertenece.',
    formula: "dueño + ’s + objeto",
    color: '#735b9b',
    suave: '#f2edfb',
    tarjetas: [
      { frente: 'Ana + bicycle', puente: "Ana’s bicycle", frase: 'Ana’s bicycle is outside.', ayuda: 'la bicicleta de Ana' },
      { frente: 'my brother + room', puente: "my brother’s room", frase: 'My brother’s room is upstairs.', ayuda: 'el cuarto de mi hermano' },
      { frente: 'the baby + toy', puente: "the baby’s toy", frase: 'The baby’s toy is on the floor.', ayuda: 'el juguete del bebé' },
      { frente: 'my parents + house', puente: "my parents’ house", frase: 'My parents’ house has a garden.', ayuda: 'la casa de mis padres' },
      { frente: 'the girls + bags', puente: "the girls’ bags", frase: 'The girls’ bags are by the door.', ayuda: 'las bolsas de las chicas' },
      { frente: 'Carlos + birthday', puente: "Carlos’s birthday", frase: 'Carlos’s birthday is on Friday.', ayuda: 'el cumpleaños de Carlos' },
    ],
    escena: { inicio: 'my neighbor', accion: '＋ bicycle', final: "my neighbor’s bicycle", frase: 'My neighbor’s bicycle is red.' },
    nota: 'Con un plural que ya termina en s, agregamos solo el apóstrofo: “my friends’ house”.',
    retos: [
      { frase: 'This is ___ jacket. (Laura)', correcta: "Laura’s", opciones: ['Lauras', "Laura’s", "Lauras’"], ayuda: 'Una persona: nombre + ’s.' },
      { frase: 'We are at my ___ house. (parents)', correcta: "parents’", opciones: ["parent’s", "parents’", 'parents'], ayuda: 'Parents ya es plural y termina en s: solo agregamos el apóstrofo.' },
      { frase: 'The ___ food is in the kitchen. (dog)', correcta: "dog’s", opciones: ["dogs’", 'dogs', "dog’s"], ayuda: 'Un perro: dog + ’s.' },
      { frase: 'Those are the ___ bicycles. (children)', correcta: "children’s", opciones: ["childrens’", "children’s", "child’s"], ayuda: 'Children es plural irregular: agregamos ’s.' },
    ],
  },
};

const leccion = computed(() => datos[props.mode]);
const tarjeta = computed(() => leccion.value.tarjetas[tarjetaId.value]);
const reto = computed(() => leccion.value.retos[retoId.value]);
const esCorrecta = computed(() => respuesta.value === reto.value.correcta);

function elegirTarjeta(index) {
  tarjetaId.value = index;
}
function responder(opcion) {
  respuesta.value = opcion;
  if (opcion === reto.value.correcta) aciertos.value = new Set([...aciertos.value, retoId.value]);
}
function siguiente() {
  retoId.value = (retoId.value + 1) % leccion.value.retos.length;
  respuesta.value = null;
}
function escuchar(texto) {
  emit('hablar', texto, 1);
}

watch(() => props.mode, () => {
  paso.value = 1;
  tarjetaId.value = 0;
  retoId.value = 0;
  respuesta.value = null;
  aciertos.value = new Set();
});
</script>

<template>
  <section class="possessive" :style="{ '--accent': leccion.color, '--soft': leccion.suave }">
    <aside class="hero">
      <span>{{ leccion.icono }}</span>
      <div><small>ADULTO ESTÁNDAR · {{ leccion.sobre }}</small><h2>{{ leccion.titulo }}</h2><p>{{ leccion.bajada }}</p></div>
      <strong>{{ leccion.formula }}</strong>
    </aside>

    <nav>
      <button v-for="(tab, index) in ['Descubrí el patrón', 'Usalo en contexto', 'Reto rápido']" :key="tab" :class="{ active: paso === index + 1 }" @click="paso = index + 1">
        <b>0{{ index + 1 }}</b><span>{{ tab }}</span>
      </button>
    </nav>

    <main v-if="paso === 1">
      <header><small>MAPA VISUAL</small><h3>Tocá una pareja y mirá cómo cambia</h3><p>Aprendé la expresión completa con una escena cotidiana.</p></header>
      <div class="lesson-grid">
        <div class="cards">
          <button v-for="(item, index) in leccion.tarjetas" :key="`${item.frente}-${index}`" :class="{ active: tarjetaId === index }" @click="elegirTarjeta(index)">
            <span>{{ item.frente }}</span><b>→ {{ item.puente }}</b>
          </button>
        </div>
        <article class="focus">
          <span>{{ leccion.icono }}</span><small>{{ tarjeta.ayuda }}</small><strong>{{ tarjeta.frase }}</strong>
          <button @click="escuchar(tarjeta.frase)">🔊 Escuchar</button>
        </article>
      </div>
      <aside class="tip"><b>Clave:</b> {{ leccion.nota }}</aside>
    </main>

    <main v-else-if="paso === 2">
      <header><small>FRASE EN MOVIMIENTO</small><h3>Seguí el recorrido de la idea</h3><p>De la persona o pregunta llegamos a la forma natural en inglés.</p></header>
      <div class="route">
        <article><small>1 · PUNTO DE PARTIDA</small><strong>{{ leccion.escena.inicio }}</strong></article>
        <i>→</i>
        <article><small>2 · CONEXIÓN</small><strong>{{ leccion.escena.accion }}</strong></article>
        <i>→</i>
        <article class="arrival"><small>3 · RESULTADO</small><strong>{{ leccion.escena.final }}</strong></article>
      </div>
      <article class="result"><small>ASÍ SUENA EN UNA CONVERSACIÓN</small><strong>{{ leccion.escena.frase }}</strong><button @click="escuchar(leccion.escena.frase)">🔊 Escuchar frase</button></article>
      <div class="examples">
        <button v-for="(item, index) in leccion.tarjetas.slice(0, 4)" :key="item.frase" @click="escuchar(item.frase)"><span>0{{ index + 1 }}</span><p>{{ item.frase }}</p><b>🔊</b></button>
      </div>
    </main>

    <main v-else>
      <header class="challenge-head"><div><small>PRÁCTICA COTIDIANA</small><h3>Elegí la pieza que completa la frase</h3><p>Recibís una pista breve después de cada elección.</p></div><b>{{ aciertos.size }}/{{ leccion.retos.length }}</b></header>
      <article class="challenge">
        <span>{{ leccion.icono }}</span>
        <button class="prompt" @click="escuchar(reto.frase.replace('___', reto.correcta))">{{ reto.frase }} 🔊</button>
        <div><button v-for="opcion in reto.opciones" :key="opcion" :class="{ ok: respuesta && opcion === reto.correcta, bad: respuesta === opcion && opcion !== reto.correcta }" @click="responder(opcion)">{{ opcion }}</button></div>
        <p v-if="respuesta"><b>{{ esCorrecta ? '✓ Muy bien' : '↻ Mirá la pista y probá otra vez' }}</b> {{ reto.ayuda }}</p>
        <button v-if="esCorrecta" class="next" @click="siguiente">Siguiente frase →</button>
      </article>
    </main>

    <button class="practice" :disabled="completado" @click="emit('practicar')">{{ completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios del workbook →' }}</button>
  </section>
</template>

<style scoped>
.possessive{display:grid;gap:1rem}.hero,main{padding:1rem;border:1px solid var(--color-borde);border-radius:var(--radio-panel);background:var(--color-superficie)}.hero{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.9rem;background:linear-gradient(135deg,var(--soft),var(--color-superficie))}.hero>span{font-size:2.8rem}.hero h2,main h3{margin:.15rem 0}.hero p,main header p{margin:.25rem 0;color:var(--color-texto-secundario)}small{font-size:.64rem;font-weight:900;letter-spacing:.08em;color:var(--accent)}.hero>strong{padding:.7rem;border:1px dashed var(--accent);border-radius:12px;color:var(--accent)}nav{display:grid;grid-template-columns:repeat(3,1fr);gap:.5rem}nav button{display:flex;gap:.5rem;padding:.7rem;border:1px solid var(--color-borde);border-radius:12px;background:var(--color-superficie);text-align:left}nav button b{color:var(--accent)}nav button.active,.cards button.active{border-color:var(--accent);background:var(--soft)}.lesson-grid{display:grid;grid-template-columns:1.35fr .65fr;gap:.8rem}.cards{display:grid;grid-template-columns:repeat(2,1fr);gap:.45rem}.cards button{display:flex;justify-content:space-between;gap:.5rem;padding:.65rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie);text-align:left}.cards button b{color:var(--accent)}.focus{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:.5rem;padding:1rem;border:2px solid var(--accent);border-radius:16px;background:var(--soft);text-align:center}.focus>span{font-size:2.7rem}.focus>strong,.result>strong{font:italic 1.15rem Georgia}.focus button,.result button{padding:.5rem .75rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.tip{margin-top:.7rem;padding:.7rem;border-left:4px solid var(--accent);border-radius:8px;background:var(--soft);font-size:.8rem}.route{display:grid;grid-template-columns:1fr auto 1fr auto 1fr;align-items:center;gap:.5rem;margin:1rem 0}.route article{display:flex;min-height:82px;flex-direction:column;justify-content:center;align-items:center;padding:.7rem;border:1px solid var(--color-borde);border-radius:13px;text-align:center}.route i{color:var(--accent);font-size:1.5rem}.route .arrival{border-color:var(--accent);background:var(--soft);color:var(--accent)}.result{display:flex;flex-direction:column;align-items:center;gap:.4rem;padding:1rem;border-radius:15px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.examples{display:grid;grid-template-columns:repeat(2,1fr);gap:.45rem;margin-top:.7rem}.examples button{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.5rem;padding:.6rem;border:1px solid var(--color-borde);border-radius:10px;background:var(--color-superficie);text-align:left}.examples span{color:var(--accent);font-weight:900}.examples p{margin:0}.challenge-head{display:flex;justify-content:space-between}.challenge-head>b{display:grid;place-items:center;width:50px;height:50px;border-radius:50%;background:var(--soft);color:var(--accent)}.challenge{max-width:650px;margin:auto;padding:1rem;border-radius:16px;background:linear-gradient(145deg,var(--soft),var(--color-superficie));text-align:center}.challenge>span{font-size:2.8rem}.challenge .prompt{display:block;margin:.45rem auto;border:0;background:transparent;font:italic 1.1rem Georgia}.challenge>div{display:grid;grid-template-columns:repeat(3,1fr);gap:.45rem}.challenge>div button{padding:.65rem;border:1px solid var(--color-borde);border-radius:9px;background:var(--color-superficie)}.challenge .ok{border-color:var(--color-verde);background:var(--color-verde-suave)}.challenge .bad{border-color:var(--color-rojo);background:var(--color-rojo-suave)}.next{padding:.55rem .8rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff}.practice{width:100%;padding:.85rem;border:0;border-radius:var(--radio-boton);background:var(--accent);color:#fff;font-weight:800}.practice:disabled{background:var(--color-verde)}
@media(max-width:720px){.hero{grid-template-columns:auto 1fr}.hero>strong{grid-column:1/-1;text-align:center}.lesson-grid{grid-template-columns:1fr}.route{grid-template-columns:1fr}.route i{transform:rotate(90deg);text-align:center}.examples{grid-template-columns:1fr}}
@media(max-width:520px){nav,.cards,.challenge>div{grid-template-columns:1fr}}
</style>
