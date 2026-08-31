<script setup>
import GramaticaView from './views/GramaticaView.vue';
</script>

<template>
  <div class="wrap">
    <GramaticaView />
  </div>
</template>

<style scoped>
.wrap {
  max-width: var(--ancho-contenido);
  margin: 0 auto;
  padding: var(--espacio-pagina) 1rem 5rem;
}
</style>
