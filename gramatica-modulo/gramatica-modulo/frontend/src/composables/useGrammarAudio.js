import { ref } from 'vue';

/**
 * Centraliza la reproducción de todos los formatos de audio de Gramática.
 * Los componentes no conocen URLs, velocidad ni coordinación de estados.
 */
export function useGrammarAudio() {
  const reproduciendoId = ref(null);
  const reproduciendoSecuencia = ref(false);
  const turnoIndiceSonando = ref(null);

  function reproducirAudioKey(audioKey, velocidad = 1) {
    if (!audioKey) return Promise.resolve();

    const audio = new Audio(`/gramatica/audio/${encodeURIComponent(audioKey)}`);
    audio.playbackRate = velocidad;

    return new Promise((resolve) => {
      audio.onended = resolve;
      audio.onerror = resolve;
      audio.play().catch(resolve);
    });
  }

  async function reproducirAudio(item, velocidad = 1) {
    if (!item?.audio_key) return;

    reproduciendoId.value = item.id;
    try {
      await reproducirAudioKey(item.audio_key, velocidad);
    } finally {
      reproduciendoId.value = null;
    }
  }

  function reproducirAudioLento(item) {
    return reproducirAudio(item, 0.7);
  }

  function reproducirTexto(texto, velocidad = 1) {
    if (!texto || !window.speechSynthesis || !window.SpeechSynthesisUtterance) return Promise.resolve();
    window.speechSynthesis.cancel();
    reproduciendoSecuencia.value = true;
    return new Promise((resolve) => {
      const voz = new SpeechSynthesisUtterance(texto);
      voz.lang = 'en-US';
      voz.rate = Math.max(0.5, Math.min(1, velocidad));
      const terminar = () => { reproduciendoSecuencia.value = false; resolve(); };
      voz.onend = terminar;
      voz.onerror = terminar;
      window.speechSynthesis.speak(voz);
    });
  }

  async function reproducirSecuencia(item) {
    if (!item?.secuencia_audio || reproduciendoSecuencia.value) return;

    reproduciendoSecuencia.value = true;
    try {
      for (const paso of item.secuencia_audio) {
        if (paso.audio_key) await reproducirAudioKey(paso.audio_key);
      }
    } finally {
      reproduciendoSecuencia.value = false;
    }
  }

  async function reproducirTurno(item, index) {
    const turno = item?.metadata?.turnos?.[index];
    if (!turno?.audio_key || reproduciendoSecuencia.value) return;

    turnoIndiceSonando.value = index;
    try {
      await reproducirAudioKey(turno.audio_key);
    } finally {
      turnoIndiceSonando.value = null;
    }
  }

  async function reproducirConversacion(item) {
    if (!item?.metadata?.turnos || reproduciendoSecuencia.value) return;

    reproduciendoSecuencia.value = true;
    try {
      for (let index = 0; index < item.metadata.turnos.length; index++) {
        const turno = item.metadata.turnos[index];
        if (!turno.audio_key) continue;

        turnoIndiceSonando.value = index;
        await reproducirAudioKey(turno.audio_key);
      }
    } finally {
      turnoIndiceSonando.value = null;
      reproduciendoSecuencia.value = false;
    }
  }

  async function reproducirFrase(item) {
    if (!item?.metadata?.audio_key || reproduciendoSecuencia.value) return;

    reproduciendoSecuencia.value = true;
    try {
      await reproducirAudioKey(item.metadata.audio_key);
    } finally {
      reproduciendoSecuencia.value = false;
    }
  }

  function reiniciarAudio() {
    reproduciendoId.value = null;
    reproduciendoSecuencia.value = false;
    turnoIndiceSonando.value = null;
  }

  return {
    reproduciendoId,
    reproduciendoSecuencia,
    turnoIndiceSonando,
    reproducirAudio,
    reproducirAudioLento,
    reproducirTexto,
    reproducirSecuencia,
    reproducirTurno,
    reproducirConversacion,
    reproducirFrase,
    reiniciarAudio,
  };
}
