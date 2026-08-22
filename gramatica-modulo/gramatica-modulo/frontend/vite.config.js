import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';

// Repo standalone solo para VER el módulo de Gramática (ver README.md).
// No hay backend real: los fetch de GramaticaView.vue van a fallar y la
// vista va a mostrar sus estados vacíos/error, no datos reales.
export default defineConfig({
  plugins: [vue()],
});
