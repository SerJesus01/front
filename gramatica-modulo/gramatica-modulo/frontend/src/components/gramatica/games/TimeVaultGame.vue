<script setup>
import { computed, onUnmounted, ref } from 'vue';
import { useGrammarAudio } from '../../../composables/useGrammarAudio.js';

const emit = defineEmits(['salir', 'alimento']);
const { reproducirTexto, reiniciarAudio } = useGrammarAudio();

const verbos = [
  { es: 'cortar', tiempo: 'pasado', respuesta: 'cut', pista: 'Es irregular y no cambia.' },
  { es: 'pensar', tiempo: 'pasado', respuesta: 'thought', pista: 'Comienza con th y termina con -ought.' },
  { es: 'escribir', tiempo: 'pasado', respuesta: 'wrote', pista: 'Es el pasado irregular de write.' },
  { es: 'hacer', tiempo: 'pasado', respuesta: 'made', pista: 'Es el pasado irregular de make.' },
  { es: 'traer', tiempo: 'pasado', respuesta: 'brought', pista: 'Se parece a thought, pero comienza con br.' },
];
const numeroEnIngles = { 0: 'zero', 1: 'one', 2: 'two', 3: 'three', 4: 'four', 5: 'five', 6: 'six', 7: 'seven', 8: 'eight', 9: 'nine' };
const palabraANumero = Object.fromEntries(Object.entries(numeroEnIngles).map(([numero, palabra]) => [palabra, Number(numero)]));

const indice = ref(0);
const respuesta = ref('');
const codigo = ref(Array(verbos.length).fill(null));
const protegida = ref(null);
const estado = ref('');
const alertas = ref(0);
const escuchando = ref(false);
const transcripcion = ref('');
const estadoVoz = ref('');
const abierta = ref(false);
const codigoManual = ref('');
let reconocimiento = null;

const verbo = computed(() => verbos[indice.value] || null);
const verbosResueltos = computed(() => codigo.value.filter((valor) => valor !== null).length);
const combinacionLista = computed(() => verbosResueltos.value === verbos.length);
const combinacion = computed(() => codigo.value.join(''));
const fraseCodigo = computed(() => codigo.value.map((numero) => numeroEnIngles[numero]).join(', '));
const reconocimientoDisponible = computed(() => Boolean(window.SpeechRecognition || window.webkitSpeechRecognition));

function normalizar(texto) {
  return texto.trim().toLowerCase().replace(/[^a-z]/g, '');
}

function comprobar() {
  if (!verbo.value || estado.value === 'correcto') return;
  if (normalizar(respuesta.value) === verbo.value.respuesta) {
    codigo.value[indice.value] = verbo.value.respuesta.length;
    protegida.value = null;
    estado.value = 'correcto';
    reproducirTexto(verbo.value.respuesta);
  } else {
    alertas.value += 1;
    protegida.value = indice.value > 0 ? indice.value - 1 : null;
    estado.value = 'detectado';
  }
}

function siguiente() {
  indice.value += 1;
  respuesta.value = '';
  estado.value = '';
  protegida.value = null;
}

function extraerDigitos(texto) {
  const limpio = texto.toLowerCase().replace(/-/g, ' ');
  const tokens = limpio.match(/[a-z]+|\d/g) || [];
  return tokens.map((token) => /^\d$/.test(token) ? Number(token) : palabraANumero[token]).filter((valor) => valor !== undefined);
}

function validarVoz(texto) {
  const escuchado = extraerDigitos(texto);
  const correcto = escuchado.length === codigo.value.length && escuchado.every((numero, posicion) => numero === codigo.value[posicion]);
  if (correcto) abrirBoveda();
  else estadoVoz.value = 'No se escuchó toda la combinación con claridad. Puedes repetirla sin perder el intento.';
}

function escucharCodigo() {
  if (!reconocimientoDisponible.value || escuchando.value) return;
  const Constructor = window.SpeechRecognition || window.webkitSpeechRecognition;
  reconocimiento = new Constructor();
  reconocimiento.lang = 'en-US';
  reconocimiento.interimResults = false;
  reconocimiento.maxAlternatives = 1;
  escuchando.value = true;
  estadoVoz.value = '';
  reconocimiento.onresult = (evento) => {
    transcripcion.value = evento.results[0][0].transcript;
    validarVoz(transcripcion.value);
  };
  reconocimiento.onerror = () => { estadoVoz.value = 'No fue posible escuchar el código. Intenta nuevamente o usa la alternativa escrita.'; };
  reconocimiento.onend = () => { escuchando.value = false; };
  reconocimiento.start();
}

function validarManual() {
  if (codigoManual.value.replace(/\D/g, '') === combinacion.value) abrirBoveda();
  else estadoVoz.value = 'La combinación escrita no coincide. Revisa los cinco dígitos; tu progreso sigue guardado.';
}

function abrirBoveda() {
  if (abierta.value) return;
  abierta.value = true;
  estadoVoz.value = '¡Combinación confirmada!';
  emit('alimento', 5);
}

function reiniciar() {
  reconocimiento?.abort?.();
  indice.value = 0;
  respuesta.value = '';
  codigo.value = Array(verbos.length).fill(null);
  protegida.value = null;
  estado.value = '';
  alertas.value = 0;
  escuchando.value = false;
  transcripcion.value = '';
  estadoVoz.value = '';
  abierta.value = false;
  codigoManual.value = '';
}

onUnmounted(() => { reconocimiento?.abort?.(); reiniciarAudio(); });
</script>

<template>
  <section class="vault-game">
    <header>
      <button @click="emit('salir')">← Centro de juegos</button>
      <span>LA BÓVEDA DEL TIEMPO</span>
      <b>⚠️ Alerta {{ alertas }}</b>
    </header>
    <div class="vault-progress"><i :style="{ width: (verbosResueltos / verbos.length * 100) + '%' }"></i></div>

    <div class="vault-stage" :class="{ open: abierta }">
      <div class="vault-door"><span>{{ abierta ? '🔓' : '🔐' }}</span><b>{{ abierta ? 'ABIERTA' : 'BÓVEDA' }}</b></div>
      <div class="vault-content">
        <small>COMBINACIÓN DE CINCO DÍGITOS</small>
        <div class="vault-code" aria-label="Combinación descubierta">
          <span v-for="(digito, posicion) in codigo" :key="posicion" :class="{ solved: digito !== null, protected: protegida === posicion }">
            {{ protegida === posicion ? '🔒' : (digito ?? '•') }}
          </span>
        </div>
        <p>Cada respuesta correcta revela la cantidad de letras del verbo en inglés.</p>
      </div>
    </div>

    <div v-if="!combinacionLista" class="verb-panel">
      <div class="verb-heading"><span>{{ indice + 1 }}</span><div><small>VERBO {{ indice + 1 }} DE {{ verbos.length }}</small><h2>{{ verbo.es }}</h2></div><b>{{ verbo.tiempo }}</b></div>
      <label>
        Escríbelo en inglés
        <input v-model="respuesta" type="text" autocomplete="off" :disabled="estado === 'correcto'" @keyup.enter="comprobar">
      </label>
      <p v-if="estado === 'detectado'" class="vault-feedback detected"><b>¡Te detectaron!</b> Una pista quedó protegida temporalmente. Corrige el verbo para volver a verla. <small>💡 {{ verbo.pista }}</small></p>
      <p v-else-if="estado === 'correcto'" class="vault-feedback correct"><b>✓ Verbo correcto:</b> {{ verbo.respuesta }} tiene {{ verbo.respuesta.length }} letras. La pista está visible y tu progreso continúa.</p>
      <div class="vault-actions"><button class="secondary" @click="emit('salir')">Salir</button><button v-if="estado === 'correcto'" class="primary" @click="siguiente">Siguiente verbo →</button><button v-else class="primary" :disabled="!respuesta.trim()" @click="comprobar">Probar verbo</button></div>
    </div>

    <div v-else-if="!abierta" class="voice-panel">
      <span>🎙️</span><small>CLAVE ORAL FINAL</small><h2>Di la combinación en inglés</h2>
      <button class="listen-code" @click="reproducirTexto(fraseCodigo)">🔊 Escuchar modelo</button>
      <p>{{ fraseCodigo }}</p>
      <button v-if="reconocimientoDisponible" class="voice-button" :class="{ listening: escuchando }" :disabled="escuchando" @click="escucharCodigo">{{ escuchando ? '🎙️ Escuchando…' : '🎙️ Pronunciar combinación' }}</button>
      <p v-if="transcripcion" class="transcript">Escuché: <b>{{ transcripcion }}</b></p>
      <details>
        <summary>Usar alternativa sin micrófono</summary>
        <div class="manual-code"><input v-model="codigoManual" inputmode="numeric" maxlength="5" placeholder="5 dígitos" @input="codigoManual = codigoManual.replace(/\D/g, '').slice(0, 5)"><button :disabled="codigoManual.length !== 5" @click="validarManual">Validar</button></div>
      </details>
      <p v-if="estadoVoz" class="voice-feedback">{{ estadoVoz }}</p>
    </div>

    <div v-else class="vault-win">
      <span>🏆</span><small>MISIÓN COMPLETADA</small><h2>¡Abriste la Bóveda del Tiempo!</h2>
      <p>Conservaste tu progreso, recuperaste las pistas protegidas y confirmaste la combinación.</p>
      <div><button class="secondary" @click="emit('salir')">Volver al centro</button><button class="primary" @click="reiniciar">Nueva combinación</button></div>
    </div>
  </section>
</template>

<style scoped>
.vault-game{padding:1.2rem;border:1px solid #d8c89c;border-radius:20px;background:#fff;box-shadow:var(--sombra-card)}header{display:grid;grid-template-columns:1fr auto 1fr;align-items:center;gap:.7rem}header button{border:0;background:none;color:var(--color-azul);text-align:left}header span{font-size:.67rem;font-weight:900;letter-spacing:.1em;color:#8b641e}header b{text-align:right;color:#a85035}.vault-progress{height:7px;margin:.7rem 0 1rem;border-radius:99px;background:#eee8d9;overflow:hidden}.vault-progress i{display:block;height:100%;background:linear-gradient(90deg,#bd8a31,#654c83);transition:.3s}.vault-stage{display:grid;grid-template-columns:145px 1fr;align-items:center;gap:1rem;padding:1rem;border-radius:18px;background:linear-gradient(145deg,#26374a,#151f2d);color:#fff}.vault-stage.open{background:linear-gradient(145deg,#174435,#28775c)}.vault-door{display:grid;place-items:center;align-content:center;width:125px;height:125px;border:8px double #cfa950;border-radius:50%;background:#1f2a38;box-shadow:inset 0 0 0 7px #405267}.vault-door span{font-size:2.6rem}.vault-door b{font-size:.65rem;letter-spacing:.12em}.vault-content{text-align:center}.vault-content small,.voice-panel>small,.vault-win small{font-size:.6rem;font-weight:900;letter-spacing:.1em;color:#e4bd62}.vault-code{display:flex;justify-content:center;gap:.55rem;margin:.6rem}.vault-code span{display:grid;place-items:center;width:48px;height:56px;border:2px solid #8191a4;border-radius:10px;background:#111a25;font-size:1.5rem;font-weight:900}.vault-code span.solved{border-color:#e4bd62;color:#ffe39a}.vault-code span.protected{border-color:#d36f50;background:#5c2b24;font-size:1.1rem}.vault-content p{margin:.3rem;color:#cdd6df;font-size:.72rem}.verb-panel,.voice-panel,.vault-win{margin-top:1rem;padding:1.2rem;border-radius:18px;background:linear-gradient(145deg,#fff8e8,#f1eef8)}.verb-heading{display:grid;grid-template-columns:auto 1fr auto;align-items:center;gap:.8rem}.verb-heading>span{display:grid;place-items:center;width:50px;height:50px;border-radius:50%;background:#26374a;color:#fff;font-weight:900}.verb-heading small{font-size:.58rem;font-weight:900;color:#8b641e}.verb-heading h2{margin:.1rem 0;text-transform:capitalize}.verb-heading>b{padding:.4rem .65rem;border-radius:99px;background:#fff;color:#7655a5}.verb-panel label{display:flex;flex-direction:column;gap:.35rem;margin:1rem auto;max-width:520px;font-size:.72rem;font-weight:800}.verb-panel input{padding:.8rem;border:2px solid #cabd9d;border-radius:11px;background:#fff;font-size:1.1rem;text-align:center}.vault-feedback{display:flex;flex-direction:column;max-width:620px;margin:.8rem auto;padding:.75rem;border-radius:11px}.vault-feedback.detected{background:#fff0e8;color:#9d4325}.vault-feedback.correct{background:var(--color-verde-suave);color:var(--color-verde)}.vault-feedback small{margin-top:.25rem}.vault-actions,.vault-win>div{display:flex;justify-content:center;gap:.7rem;margin-top:1rem}.vault-actions button,.vault-win button{min-width:170px;padding:.75rem;border-radius:var(--radio-boton);font-weight:800}.primary{border:0;background:#654c83;color:#fff}.primary:disabled{opacity:.45}.secondary{border:1px solid var(--color-borde);background:#fff}.voice-panel,.vault-win{display:flex;flex-direction:column;align-items:center;text-align:center}.voice-panel>span,.vault-win>span{font-size:3.5rem}.voice-panel h2,.vault-win h2{margin:.25rem}.listen-code{border:0;background:none;color:#654c83;font-weight:800}.voice-panel>p{font-weight:800}.voice-button{padding:.85rem 1.2rem;border:0;border-radius:99px;background:#a85035;color:#fff;font-weight:900}.voice-button.listening{animation:pulse 1s infinite}.transcript{padding:.55rem .8rem;border-radius:9px;background:#fff}.voice-panel details{width:min(100%,480px);margin-top:.8rem}.voice-panel summary{cursor:pointer;color:var(--color-texto-tenue);font-size:.72rem}.manual-code{display:flex;gap:.5rem;margin-top:.6rem}.manual-code input{flex:1;min-width:0;padding:.65rem;border:1px solid var(--color-borde);border-radius:9px;text-align:center;letter-spacing:.25em}.manual-code button{padding:.65rem;border:0;border-radius:9px;background:#654c83;color:#fff}.voice-feedback{padding:.65rem;border-radius:9px;background:#fff0e8;color:#9d4325}@keyframes pulse{50%{transform:scale(1.04);box-shadow:0 0 0 8px #a8503520}}
@media(max-width:620px){.vault-game{padding:.8rem}header{grid-template-columns:1fr auto}header span{grid-row:2;grid-column:1/-1}.vault-stage{grid-template-columns:1fr}.vault-door{margin:auto;width:100px;height:100px}.vault-code{gap:.25rem}.vault-code span{width:38px;height:46px}.verb-heading{grid-template-columns:auto 1fr}.verb-heading>b{grid-column:1/-1;justify-self:start}.vault-actions,.vault-win>div{flex-direction:column;width:100%}.vault-actions button,.vault-win button{width:100%}}
</style>
