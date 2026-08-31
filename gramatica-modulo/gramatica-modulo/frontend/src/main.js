import { createApp } from 'vue';
import App from './App.vue';
import './styles/base.css';

// Tema visual provisional. Puede cambiarse con VITE_STUDENTBOOK_THEME y,
// cuando exista el selector, bastará con actualizar este mismo atributo.
const studentbookThemes = new Set(['child', 'adult', 'professional']);
const configuredTheme = import.meta.env.VITE_STUDENTBOOK_THEME || 'adult';
document.documentElement.dataset.studentbookTheme = studentbookThemes.has(configuredTheme)
  ? configuredTheme
  : 'adult';

if (import.meta.env.DEV && import.meta.env.VITE_USE_GRAMMAR_MOCK === 'true') {
  const { installGrammarMock } = await import('./mocks/grammarMock.js');
  installGrammarMock();
}

createApp(App).mount('#app');
