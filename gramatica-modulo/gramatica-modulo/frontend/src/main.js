import { createApp } from 'vue';
import App from './App.vue';
import './styles/base.css';

if (import.meta.env.DEV && import.meta.env.VITE_USE_GRAMMAR_MOCK === 'true') {
  const { installGrammarMock } = await import('./mocks/grammarMock.js');
  installGrammarMock();
}

createApp(App).mount('#app');
