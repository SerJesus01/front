<script setup>
import { computed, ref, watch } from 'vue';

const props = defineProps({
  items: {
    type: Array,
    default: () => [],
  },
  reproduciendoId: {
    type: [Number, String],
    default: null,
  },
});

const emit = defineEmits(['reproducir', 'reproducir-lento', 'practicar']);

const letraActivaId = ref(null);
const letrasEscuchadas = ref(new Set());

watch(
  () => props.items,
  (items) => {
    if (!items.length) {
      letraActivaId.value = null;
      letrasEscuchadas.value = new Set();
      return;
    }

    if (!items.some((item) => item.id === letraActivaId.value)) {
      letraActivaId.value = items[0].id;
    }
  },
  { immediate: true },
);

const letraActiva = computed(
  () => props.items.find((item) => item.id === letraActivaId.value) || props.items[0] || null,
);

const progreso = computed(() => {
  if (!props.items.length) return 0;
  return Math.round((letrasEscuchadas.value.size / props.items.length) * 100);
});

function seleccionarLetra(item) {
  letraActivaId.value = item.id;
  letrasEscuchadas.value = new Set([...letrasEscuchadas.value, item.id]);
  emit('reproducir', item);
}
</script>

<template>
  <section class="alphabet-lesson" aria-labelledby="alphabet-lesson-title">
    <header class="alphabet-lesson__header">
      <div>
        <span class="alphabet-lesson__eyebrow">DESCUBRE Y ESCUCHA</span>
        <h2 id="alphabet-lesson-title">Escuchá, repetí y reconocé cada letra</h2>
        <p>Tocá una letra y repetila en voz alta. Avanzá en grupos cortos, sin intentar memorizar las 26 de una vez.</p>
      </div>
      <div class="alphabet-lesson__progress" aria-live="polite">
        <strong>{{ progreso }}%</strong>
        <span>{{ letrasEscuchadas.size }} de {{ items.length }} escuchadas</span>
      </div>
    </header>

    <div v-if="letraActiva" class="alphabet-lesson__stage">
      <div class="alphabet-lesson__letter">{{ letraActiva.texto_en }}</div>
      <div class="alphabet-lesson__actions">
        <span class="alphabet-lesson__eyebrow">ASÍ SUENA</span>
        <strong>Letra {{ letraActiva.texto_en }}</strong>
        <div>
          <button
            class="alphabet-lesson__play"
            :disabled="reproduciendoId === letraActiva.id"
            @click="emit('reproducir', letraActiva)"
          >🔊 Escuchar de nuevo</button>
          <button
            class="alphabet-lesson__slow"
            :disabled="reproduciendoId === letraActiva.id"
            @click="emit('reproducir-lento', letraActiva)"
          >Más lento</button>
        </div>
      </div>
    </div>

    <div class="alphabet-lesson__tip">
      <span aria-hidden="true">💡</span>
      <p><strong>Práctica eficaz:</strong> escuchá cinco letras, tapá la pantalla e intentá decirlas en el mismo orden.</p>
    </div>

    <div class="alphabet-lesson__grid" aria-label="Abecedario interactivo">
      <button
        v-for="item in items"
        :key="item.id"
        class="alphabet-lesson__tile"
        :class="{
          'alphabet-lesson__tile--active': letraActiva?.id === item.id,
          'alphabet-lesson__tile--heard': letrasEscuchadas.has(item.id),
        }"
        :disabled="!item.audio_key || reproduciendoId === item.id"
        :aria-pressed="letraActiva?.id === item.id"
        :title="item.audio_key ? `Escuchar letra ${item.texto_en}` : 'Audio no generado todavía'"
        @click="seleccionarLetra(item)"
      >
        {{ item.texto_en }}
        <small aria-hidden="true">{{ letrasEscuchadas.has(item.id) ? '✓' : '🔊' }}</small>
      </button>
    </div>

    <button class="alphabet-lesson__practice" @click="emit('practicar')">
      Practicar ejercicios <span aria-hidden="true">→</span>
    </button>
  </section>
</template>

<style scoped>
.alphabet-lesson {
  width: 100%;
  padding: 1.25rem;
  border: 1px solid #dbe9df;
  border-radius: 18px;
  background: white;
  box-shadow: 0 8px 28px rgba(25, 72, 53, 0.07);
}

.alphabet-lesson__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
}

.alphabet-lesson__header h2 {
  margin: 0.2rem 0 0.35rem;
  font-size: 1.15rem;
}

.alphabet-lesson__header p {
  max-width: 620px;
  margin: 0;
  color: var(--color-texto-secundario);
  font-size: 0.84rem;
  line-height: 1.55;
}

.alphabet-lesson__eyebrow {
  color: var(--color-verde);
  font-size: 0.68rem;
  font-weight: 800;
  letter-spacing: 0.08em;
}

.alphabet-lesson__progress {
  display: flex;
  flex-direction: column;
  min-width: 130px;
  text-align: right;
}

.alphabet-lesson__progress strong {
  color: var(--color-verde);
  font-size: 1.45rem;
}

.alphabet-lesson__progress span {
  color: var(--color-texto-tenue);
  font-size: 0.72rem;
}

.alphabet-lesson__stage {
  display: grid;
  grid-template-columns: 125px 1fr;
  align-items: center;
  gap: 1.25rem;
  margin: 1rem 0;
  padding: 1rem 1.25rem;
  border-radius: 16px;
  background: linear-gradient(135deg, var(--color-verde-suave), #fff8e7);
}

.alphabet-lesson__letter {
  color: var(--color-verde);
  font-family: Georgia, serif;
  font-size: 5rem;
  font-weight: 700;
  line-height: 1;
  text-align: center;
}

.alphabet-lesson__actions {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}

.alphabet-lesson__play,
.alphabet-lesson__slow {
  border-radius: var(--radio-boton);
  padding: 0.65rem 0.9rem;
  cursor: pointer;
  font-weight: 700;
}

.alphabet-lesson__play {
  border: 0;
  background: var(--color-verde);
  color: white;
}

.alphabet-lesson__slow {
  margin-left: 0.4rem;
  border: 1px solid var(--color-borde);
  background: white;
  color: var(--color-texto-secundario);
}

.alphabet-lesson__tip {
  display: flex;
  align-items: center;
  gap: 0.55rem;
  margin-bottom: 1rem;
  padding: 0.7rem 0.85rem;
  border-radius: 12px;
  background: #f7faf7;
}

.alphabet-lesson__tip p {
  margin: 0;
  font-size: 0.78rem;
  line-height: 1.45;
}

.alphabet-lesson__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(58px, 1fr));
  gap: 0.5rem;
}

.alphabet-lesson__tile {
  min-height: 58px;
  border: 2px solid var(--color-borde);
  border-radius: var(--radio-card);
  background: white;
  font-size: 1.1rem;
  font-weight: 800;
  cursor: pointer;
}

.alphabet-lesson__tile small {
  display: block;
  margin-top: 0.12rem;
  color: var(--color-verde);
  font-size: 0.6rem;
}

.alphabet-lesson__tile--active {
  border-color: var(--color-verde);
  background: var(--color-verde);
  color: white;
  transform: translateY(-2px);
}

.alphabet-lesson__tile--active small {
  color: white;
}

.alphabet-lesson__tile:disabled {
  cursor: wait;
  opacity: 0.45;
}

.alphabet-lesson__practice {
  width: 100%;
  margin-top: 1rem;
  padding: 0.85rem;
  border: 0;
  border-radius: var(--radio-boton);
  background: var(--color-azul);
  color: white;
  font-size: 1rem;
  cursor: pointer;
}

.alphabet-lesson__practice span {
  float: right;
}

@media (max-width: 620px) {
  .alphabet-lesson__header {
    flex-direction: column;
  }

  .alphabet-lesson__progress {
    text-align: left;
  }

  .alphabet-lesson__stage {
    grid-template-columns: 82px 1fr;
    padding: 0.9rem;
  }

  .alphabet-lesson__letter {
    font-size: 3.8rem;
  }

  .alphabet-lesson__play,
  .alphabet-lesson__slow {
    width: 100%;
  }

  .alphabet-lesson__slow {
    margin: 0.4rem 0 0;
  }
}
</style>
