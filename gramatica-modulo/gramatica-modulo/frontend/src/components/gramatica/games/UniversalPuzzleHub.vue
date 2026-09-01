<script setup>
import { ref } from 'vue';
import GrammarSortGame from './GrammarSortGame.vue';
import SentenceRepairGame from './SentenceRepairGame.vue';
import TimeVaultGame from './TimeVaultGame.vue';

const emit = defineEmits(['volver']);
const pantalla = ref('hub');
const puntos = ref(0);
const juegos = [
  { id: 'clasificador', icono: '🧭', etiqueta: 'OBSERVA Y DECIDE', titulo: 'Clasificador rápido', texto: 'Relaciona cada frase con la regla que realmente utiliza.', color: '#356f92', suave: '#e8f4fa' },
  { id: 'reparar', icono: '🔧', etiqueta: 'ENCUENTRA EL ERROR', titulo: 'Repara la frase', texto: 'Sustituye la pieza incorrecta y comprende por qué cambia.', color: '#b45b39', suave: '#fff0e8' },
  { id: 'boveda', icono: '🔐', etiqueta: 'VERBOS, NÚMEROS Y VOZ', titulo: 'La Bóveda del Tiempo', texto: 'Conjuga cinco verbos, descubre un código y pronúncialo en inglés.', color: '#654c83', suave: '#f2edfb' },
];
</script>

<template>
  <section class="puzzle-hub">
    <template v-if="pantalla === 'hub'">
      <button class="puzzle-hub__back" @click="emit('volver')">← Volver a Studentbooks</button>
      <header>
        <span>PRÁCTICA PARA TODOS</span>
        <h1>Centro de puzzles</h1>
        <p>Combina reglas de diferentes lecciones. Puedes practicar antes, durante o después de completar un Studentbook.</p>
        <b>⭐ {{ puntos }} puntos de práctica</b>
      </header>
      <div class="puzzle-hub__grid">
        <button v-for="juego in juegos" :key="juego.id" :style="{ '--puzzle-color': juego.color, '--puzzle-soft': juego.suave }" @click="pantalla = juego.id">
          <span>{{ juego.icono }}</span>
          <small>{{ juego.etiqueta }}</small>
          <strong>{{ juego.titulo }}</strong>
          <p>{{ juego.texto }}</p>
          <b>Comenzar →</b>
        </button>
      </div>
      <aside>No necesitas elegir una edad o recorrido. Los puzzles usan vocabulario cotidiano y ofrecen explicaciones después de cada respuesta.</aside>
    </template>

    <GrammarSortGame v-else-if="pantalla === 'clasificador'" @salir="pantalla = 'hub'" @alimento="puntos += $event" />
    <SentenceRepairGame v-else-if="pantalla === 'reparar'" @salir="pantalla = 'hub'" @alimento="puntos += $event" />
    <TimeVaultGame v-else-if="pantalla === 'boveda'" @salir="pantalla = 'hub'" @alimento="puntos += $event" />
  </section>
</template>

<style scoped>
.puzzle-hub{max-width:940px;margin:auto;padding:1rem}.puzzle-hub__back{border:0;background:none;color:var(--color-azul);cursor:pointer}.puzzle-hub>header{position:relative;margin:1rem 0;padding:1.5rem;border:1px solid #cbd9e4;border-radius:22px;background:linear-gradient(135deg,#eef7fb,#f6f1fb 62%,#fff6df)}.puzzle-hub>header>span{font-size:.65rem;font-weight:900;letter-spacing:.12em;color:#356f92}.puzzle-hub>header h1{margin:.2rem 0}.puzzle-hub>header p{max-width:680px;margin:.25rem 0;color:var(--color-texto-secundario)}.puzzle-hub>header b{position:absolute;right:1.2rem;top:1.2rem;padding:.5rem .7rem;border-radius:99px;background:#fff;color:#8b641e;font-size:.72rem}.puzzle-hub__grid{display:grid;grid-template-columns:repeat(3,1fr);gap:.8rem}.puzzle-hub__grid>button{display:flex;min-height:270px;flex-direction:column;align-items:flex-start;padding:1.1rem;border:2px solid color-mix(in srgb,var(--puzzle-color) 35%,white);border-radius:20px;background:linear-gradient(145deg,var(--puzzle-soft),#fff);color:inherit;cursor:pointer;text-align:left;transition:.2s}.puzzle-hub__grid>button:hover{transform:translateY(-4px);box-shadow:0 12px 25px #26354a16}.puzzle-hub__grid>button>span{display:grid;place-items:center;width:64px;height:64px;border-radius:18px;background:#fff;font-size:2.2rem}.puzzle-hub__grid small{margin-top:1rem;color:var(--puzzle-color);font-size:.58rem;font-weight:900;letter-spacing:.08em}.puzzle-hub__grid strong{margin:.25rem 0;font-size:1.08rem}.puzzle-hub__grid p{margin:0;color:var(--color-texto-secundario);font-size:.76rem}.puzzle-hub__grid b{align-self:stretch;margin-top:auto;padding-top:1rem;color:var(--puzzle-color);font-size:.75rem;text-align:right}.puzzle-hub>aside{margin-top:1rem;padding:.75rem;border-radius:12px;background:var(--color-fondo-suave);color:var(--color-texto-secundario);font-size:.72rem;text-align:center}
@media(max-width:760px){.puzzle-hub__grid{grid-template-columns:1fr}.puzzle-hub__grid>button{min-height:210px}.puzzle-hub>header b{position:static;display:inline-block;margin-top:.7rem}}@media(max-width:430px){.puzzle-hub{padding:.5rem}.puzzle-hub>header{padding:1rem}}
</style>
