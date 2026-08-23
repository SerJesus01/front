const BASE_URL = '/gramatica';

export class GramaticaApiError extends Error {
  constructor(message, status) {
    super(message);
    this.name = 'GramaticaApiError';
    this.status = status;
  }
}

async function requestJson(path, options = {}) {
  const response = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers: {
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...options.headers,
    },
  });

  if (response.status === 401) {
    window.location.href = '/';
    throw new GramaticaApiError('Sesión expirada.', 401);
  }

  if (!response.ok) {
    throw new GramaticaApiError(
      `Error al consultar Gramática (${response.status}).`,
      response.status,
    );
  }

  if (response.status === 204) return null;
  return response.json();
}

function query(params) {
  return '?' + new URLSearchParams(params).toString();
}

export const gramaticaApi = {
  async obtenerFases(idioma = 'en') {
    const data = await requestJson('/fases' + query({ idioma }));
    return data.fases || [];
  },

  async obtenerSubtemas(faseSlug, idioma = 'en') {
    const data = await requestJson(
      `/fases/${encodeURIComponent(faseSlug)}/subtemas` + query({ idioma }),
    );
    return data.subtemas || [];
  },

  async obtenerContenido(subtemaSlug, idioma = 'en') {
    const data = await requestJson(
      `/subtemas/${encodeURIComponent(subtemaSlug)}/contenido` + query({ idioma }),
    );
    return data.contenido || [];
  },

  async obtenerEjercicios(subtemaSlug, idioma = 'en') {
    const data = await requestJson(
      `/subtemas/${encodeURIComponent(subtemaSlug)}/ejercicios` + query({ idioma }),
    );
    return data.ejercicios || [];
  },

  evaluarEjercicio(payload) {
    return requestJson('/ejercicios/evaluar', {
      method: 'POST',
      body: JSON.stringify(payload),
    });
  },

  completarSubtema(slug, idioma = 'en') {
    return requestJson('/subtemas/completar', {
      method: 'POST',
      body: JSON.stringify({ slug, idioma }),
    });
  },

  async obtenerRepaso(idioma = 'en') {
    return requestJson('/repaso' + query({ idioma }));
  },

  async obtenerRelaciones(idioma = 'en') {
    const data = await requestJson('/relaciones' + query({ idioma }));
    return data.relaciones || [];
  },

  async obtenerEjerciciosRelacion(relacionId, idioma = 'en') {
    const data = await requestJson(
      `/relaciones/${encodeURIComponent(relacionId)}/ejercicios` + query({ idioma }),
    );
    return data.ejercicios || [];
  },

  enviarAutoexplicacion(subtemaSlug, explicacion, idioma = 'en') {
    return requestJson(
      `/subtemas/${encodeURIComponent(subtemaSlug)}/autoexplicacion` + query({ idioma }),
      {
        method: 'POST',
        body: JSON.stringify({ explicacion }),
      },
    );
  },

  obtenerEvolucionGusanito() {
    return requestJson('/gusanito/evolucion');
  },

  async obtenerCaminoGusanito(faseSlug, idioma = 'en') {
    return requestJson(
      `/gusanito/${encodeURIComponent(faseSlug)}` + query({ idioma }),
    );
  },

  async obtenerEjerciciosGusanito(faseSlug, subtemaSlug, idioma = 'en') {
    const data = await requestJson(
      `/gusanito/${encodeURIComponent(faseSlug)}/${encodeURIComponent(subtemaSlug)}/ejercicios`
      + query({ idioma }),
    );
    return data.ejercicios || [];
  },

  async obtenerBuildingWords(idioma = 'en', limit = 10) {
    const data = await requestJson('/building-words' + query({ idioma, limit }));
    return data.puzzles || [];
  },
};
