<script setup>
// Studentbook + workbook de Gramática: 5 "pantallas" en memoria (mismo
// patrón que VocabularioView.vue, sin sub-rutas propias porque el examen
// comparte estado con la pantalla de estudio). A diferencia de
// vocabulario, acá el audio es un archivo REAL pregenerado
// (/gramatica/audio/{audio_key}, servido tal cual desde CACHE_TTS_DIR,
// ver routers/gramatica.py) -- nunca JSON con base64, así que se
// reproduce con un <audio src> directo en vez de decodificar una
// respuesta. Los ejercicios de un subtema son una lista chica y fija (2
// por subtema en la siembra inicial) -- se traen todos de una vez, sin el
// endpoint "/siguiente" con repetición espaciada que sí tiene vocabulario.
import { computed, ref } from 'vue';
import AbecedarioLesson from '../components/gramatica/abecedario/AbecedarioLesson.vue';
import NumbersLesson from '../components/gramatica/numeros/NumbersLesson.vue';
import DateLesson from '../components/gramatica/fecha/DateLesson.vue';
import TimeLesson from '../components/gramatica/hora/TimeLesson.vue';
import GreetingLesson from '../components/gramatica/saludos/GreetingLesson.vue';
import FamilyLesson from '../components/gramatica/familia/FamilyLesson.vue';
import AbbreviationLesson from '../components/gramatica/abreviaturas/AbbreviationLesson.vue';
import FruitLesson from '../components/gramatica/frutas/FruitLesson.vue';
import ToBeLesson from '../components/gramatica/tobe/ToBeLesson.vue';
import PronounLesson from '../components/gramatica/pronombres/PronounLesson.vue';
import PresentSimpleLesson from '../components/gramatica/presente/PresentSimpleLesson.vue';
import PresentContinuousLesson from '../components/gramatica/presente/PresentContinuousLesson.vue';
import PresentContrastLesson from '../components/gramatica/presente/PresentContrastLesson.vue';
import PastLesson from '../components/gramatica/pasado/PastLesson.vue';
import PresentPerfectLesson from '../components/gramatica/perfecto/PresentPerfectLesson.vue';
import PassiveVoiceLesson from '../components/gramatica/pasiva/PassiveVoiceLesson.vue';
import FutureLesson from '../components/gramatica/futuro/FutureLesson.vue';
import GrammarGameHub from '../components/gramatica/games/GrammarGameHub.vue';
import { useGrammarAudio } from '../composables/useGrammarAudio.js';
import { gramaticaApi } from '../services/gramaticaApi.js';

const pantallaActual = ref('fases'); // 'fases' | 'subtemas' | 'estudio' | 'ejercicios' | 'fin' | 'cruces'

const fases = ref([]);
const faseActual = ref(null);
const subtemas = ref([]);
const subtemaActual = ref(null);

const contenido = ref([]);

const {
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
} = useGrammarAudio();

// Anclaje visual (Fase 5 del plan de dinamismo): mismo ícono SIEMPRE para
// toda regla de la misma familia gramatical -- la repetición es lo que
// ancla, no la novedad. Por subtema (no por fila individual) porque el
// anclaje es al CONCEPTO completo, no a un ejemplo puntual. Curado a mano,
// no todos los subtemas necesitan uno.
const _ICONOS_ANCLAJE = {
  'fase-5-perfecto-intro': '🌉',        // puente pasado-presente
  'fase-5-just-already-yet': '🌉',
  'fase-5-ever-how-long': '🌉',
  'fase-5-for-since-ago': '🌉',
  'fase-5-perfecto-vs-pasado': '🌉',
  'fase-6-pasiva-presente': '🔄',       // el objeto pasa al frente, foco invertido
  'fase-6-pasiva-pasado': '🔄',
  'fase-8-must-have-to': '🔒',          // obligación
  'fase-13-contables-incontables': '🖐️', // "se cuenta con los dedos" vs. se mide/sirve
};
const iconoAnclajeActual = computed(() => _ICONOS_ANCLAJE[subtemaActual.value?.slug] || null);

// Orden pedido en vivo: regla(s) primero, después la grilla de fichas
// (referencia), después el botón de ejercicios, y los ejemplos al final
// de todo -- por eso reglas/ejemplos se separan en dos listas en vez de
// una sola "contenidoCards" (antes se mostraban mezclados, en el orden
// que viniera de `orden`).
const contenidoReglas = computed(() => contenido.value.filter((c) => c.tipo === 'regla'));
const contenidoEjemplos = computed(() => contenido.value.filter((c) => c.tipo === 'ejemplo'));

// Predicción (Fase 2 del plan de dinamismo, tipo='prediccion', ver
// migración 061): se muestra ANTES de la regla -- el ejemplo + 3
// hipótesis pre-escritas, el alumno elige una sin saber cuál es correcta
// todavía. metadata = {opciones: [...], correcta: <indice>}. Puramente
// de comprensión (pretesting) -- no toca el Motor de Memoria ni Leitner.
const contenidoPredicciones = computed(() => contenido.value.filter((c) => c.tipo === 'prediccion'));
const prediccionElegida = ref(null); // índice elegido por el alumno para la predicción actual

// tipo 'referencia' (letra/número suelto, ver migración 035) se muestra
// como grilla de fichas tocables -- tocar la ficha ES reproducir el
// audio, sin ícono de parlante aparte.
const contenidoReferencias = computed(() => contenido.value.filter((c) => c.tipo === 'referencia'));
const esAbecedario = computed(() => subtemaActual.value?.slug === 'fase-1-abecedario');
const esNumeros = computed(() => subtemaActual.value?.slug === 'fase-1-numeros');
const esFecha = computed(() => {
  const slug = subtemaActual.value?.slug || '';
  const nombre = (subtemaActual.value?.nombre || '').trim().toLowerCase();
  return slug === 'fase-1-fecha' || nombre === 'fecha';
});
const esHora = computed(() => {
  const slug = subtemaActual.value?.slug || '';
  const nombre = (subtemaActual.value?.nombre || '').trim().toLowerCase();
  return slug === 'fase-1-hora' || slug.startsWith('fase-1-hora-') || nombre === 'hora';
});
const esSaludos = computed(() => subtemaActual.value?.slug === 'fase-1-saludos');
const esFamilia = computed(() => subtemaActual.value?.slug === 'fase-1-familia-coloquial');
const esAbreviaturas = computed(() => subtemaActual.value?.slug === 'fase-1-abreviaturas');
const esFrutas = computed(() => subtemaActual.value?.slug === 'fase-1-frutas');
const esToBe = computed(() => subtemaActual.value?.slug === 'fase-2-to-be-afirmativo');
const esPronombres = computed(() => subtemaActual.value?.slug === 'fase-2-pronombres-sujeto-objeto');
const esPresenteSimple = computed(() => subtemaActual.value?.slug === 'fase-3-presente-simple');
const esPresenteContinuo = computed(() => subtemaActual.value?.slug === 'fase-3-presente-continuo');
const esContrastePresente = computed(() => subtemaActual.value?.slug === 'fase-3-simple-vs-continuo');
const modoPasado = computed(() => ({
  'fase-4-was-were': 'was-were',
  'fase-4-pasado-simple': 'simple',
  'fase-4-pasado-continuo': 'continuous',
})[subtemaActual.value?.slug] || null);
const modoPerfecto = computed(() => ({
  'fase-5-perfecto-intro': 'intro',
  'fase-5-just-already-yet': 'markers',
  'fase-5-ever-how-long': 'experience',
  'fase-5-for-since-ago': 'duration',
  'fase-5-perfecto-vs-pasado': 'contrast',
})[subtemaActual.value?.slug] || null);
const modoPasiva = computed(() => ({
  'fase-6-pasiva-presente': 'present',
  'fase-6-pasiva-pasado': 'past',
})[subtemaActual.value?.slug] || null);
const modoFuturo = computed(() => ({
  'fase-7-going-to': 'going',
  'fase-7-will-shall': 'will',
  'fase-7-continuo-futuro': 'arrangement',
})[subtemaActual.value?.slug] || null);
const usaLeccionEspecializada = computed(() => Boolean(
  esAbecedario.value || esNumeros.value || esFecha.value || esHora.value
  || esSaludos.value || esFamilia.value || esAbreviaturas.value || esFrutas.value
  || esToBe.value || esPronombres.value || esPresenteSimple.value
  || esPresenteContinuo.value || esContrastePresente.value || modoPasado.value
  || modoPerfecto.value || modoPasiva.value || modoFuturo.value,
));

// Grilla de fichas cuadradas (abecedario: una letra por ficha, sin
// overflow posible) -- se usa solo cuando NO hay variante 'ordinal' NI
// ninguna de las variantes con módulo propio en juego. Números, Fecha y
// Hora renderizan sus referencias dentro de componentes especializados,
// evitando mostrar la misma ficha una segunda vez en la grilla genérica.
const _VARIANTES_CON_SECCION_PROPIA = new Set([
  'ordinal', 'en_punto', 'media', 'cuarto', 'minutos', 'parte_dia', 'fecha_especifica', 'fecha_relativa', 'fecha_casual',
  'pron_sujeto', 'pron_objeto', 'pron_posesivo_adj', 'pron_posesivo_pron',
  'tobe_pasado', 'there_forma',
]);

// Pedido en vivo (04/ago/2026): la ficha cuadrada (pensada para una
// letra/número suelto) no funciona para frases o palabras con
// traducción -- el texto se corta, y la traducción (texto_es) ni
// siquiera se mostraba. Estos subtemas puntuales pasan a una tabla de
// 2 columnas (palabra + audio | traducción, ver
// gramatica-view__tabla-numeros--referencia); el resto (abecedario,
// familia coloquial, etc.) se queda con la ficha cuadrada, que para una
// letra o palabra corta funciona bien y no se tocó.
const _SUBTEMAS_TABLA_TRADUCCION = new Set(['fase-1-saludos', 'fase-1-abreviaturas', 'fase-1-frutas']);
const usaTablaTraduccion = computed(() => _SUBTEMAS_TABLA_TRADUCCION.has(subtemaActual.value?.slug));

// Saludos y despedidas (migración 071 las fusionó en un solo subtema,
// migración 072 les puso variante 'saludo'/'despedida') -- se muestran
// como dos tablas separadas, no mezcladas en una sola.
const _GRUPOS_SALUDO = { saludo: 'Saludos', despedida: 'Despedidas' };

const gruposReferencias = computed(() => {
  if (contenidoReferencias.value.some((c) => _VARIANTES_CON_SECCION_PROPIA.has(c.variante))) return [];
  const tieneGruposSaludo = contenidoReferencias.value.some((c) => c.variante in _GRUPOS_SALUDO);
  if (tieneGruposSaludo) {
    return Object.entries(_GRUPOS_SALUDO)
      .map(([variante, titulo]) => ({ titulo, items: contenidoReferencias.value.filter((c) => c.variante === variante) }))
      .filter((grupo) => grupo.items.length > 0);
  }
  return contenidoReferencias.value.length > 0 ? [{ titulo: null, items: contenidoReferencias.value }] : [];
});

// Los "hitos" redondos (100/1.000/10.000/100.000/1.000.000, ver migración
// 036) tienen texto_es como numeral puro (a diferencia de "Letra A" o
// "Número 1"..20) -- se muestra como subtítulo bajo la palabra en inglés.
function esNumeralPuro(texto) {
  return /^[\d.,]+$/.test(texto.trim());
}

// Extrae el numeral "1".."20"/"100" a partir de texto_es -- reaprovecha
// los formatos ya sembrados ("Número 1", "1º", "100") en vez de agregar
// una columna solo para esto (ver migraciones 034/035/036/039).
function _numeralDe(item) {
  const conPrefijo = item.texto_es.match(/^Número (\d+)$/);
  if (conPrefijo) return conPrefijo[1];
  const ordinal = item.texto_es.match(/^(\d+)º$/);
  if (ordinal) return ordinal[1];
  return esNumeralPuro(item.texto_es) ? item.texto_es : null;
}

// Pedido en vivo del dueño: en vez de dos grillas de fichas cuadradas
// (cardinales/ordinales) que hacían overflow con palabras largas, una
// sola lista de filas -- cada fila alinea numeral + cardinal + ordinal
// del mismo número (1, one, first), con el texto en un solo renglón. El
// match cardinal<->ordinal es por el numeral extraído (no por posición
// en el array), así los 5 hitos de miles (sin ordinal sembrado) quedan
// con la celda de ordinal vacía en vez de desalinear todo lo demás.
//
// Sin sort propio: NO ordenar con Number(numeral) acá -- "1.000.000"
// tiene dos puntos y Number() lo vuelve NaN, "1.000"/"10.000" se leen
// como decimales (Number("1.000") === 1) y todo el orden se rompe (bug
// real visto en vivo). El array ya viene ordenado por `orden` desde el
// backend (ver /gramatica/subtemas/{slug}/contenido, ORDER BY gc.orden,
// que sí codifica 1..20 y luego los 5 hitos en secuencia numérica real,
// ver migración 036) -- alcanza con preservarlo (filter/map no reordenan).
const filasNumeros = computed(() => {
  const ordinales = contenidoReferencias.value.filter((c) => c.variante === 'ordinal');
  if (ordinales.length === 0) return null;
  const cardinales = contenidoReferencias.value.filter((c) => c.variante !== 'ordinal');
  const ordinalPorNumeral = new Map(ordinales.map((o) => [_numeralDe(o), o]));
  return cardinales.map((c) => ({
    numeral: _numeralDe(c),
    cardinal: c,
    ordinal: ordinalPorNumeral.get(_numeralDe(c)) || null,
  }));
});

// Pedido en vivo: "Pronombres y posesivos" (migración 058) -- tabla de 4
// columnas (sujeto/objeto/posesivo adjetivo/posesivo pronombre), mismo
// patrón que filasNumeros pero el join entre columnas es por `orden`
// (1..7 = I/you/he/she/it/we/they) en vez de por numeral extraído --
// acá texto_es cambia en cada columna, no hay un valor común que parsear.
const filasPronombres = computed(() => {
  const sujetos = contenidoReferencias.value.filter((c) => c.variante === 'pron_sujeto');
  if (sujetos.length === 0) return null;
  const porOrden = (variante) => new Map(
    contenidoReferencias.value.filter((c) => c.variante === variante).map((c) => [c.orden, c]),
  );
  const objetos = porOrden('pron_objeto');
  const posesivosAdj = porOrden('pron_posesivo_adj');
  const posesivosPron = porOrden('pron_posesivo_pron');
  return sujetos.map((s) => ({
    sujeto: s,
    objeto: objetos.get(s.orden) || null,
    posesivoAdj: posesivosAdj.get(s.orden) || null,
    posesivoPron: posesivosPron.get(s.orden) || null,
  }));
});

// "was/were" (Fase 2 del plan, migración 062) -- tabla de 2 columnas
// (pronombre/forma), mismo patrón de join por `orden` que filasPronombres
// pero con 'pron_sujeto' sembrado DENTRO de este subtema (no se puede
// cruzar con el de fase-2-pronombres-sujeto-objeto -- el frontend solo
// tiene cargado el contenido del subtema actual). Exigir 'formas' no
// vacío también (no solo 'sujetos') -- fase-2-pronombres-sujeto-objeto
// TAMBIÉN tiene sus propios pron_sujeto (para la tabla de posesivos), así
// que sin este chequeo esta tabla se colaba vacía (columna was/were en
// blanco) en la pantalla de Pronombres (hallazgo real del dueño,
// 04/ago/2026).
const filasTobePasado = computed(() => {
  const sujetos = contenidoReferencias.value.filter((c) => c.variante === 'pron_sujeto');
  const formas = new Map(
    contenidoReferencias.value.filter((c) => c.variante === 'tobe_pasado').map((c) => [c.orden, c]),
  );
  if (sujetos.length === 0 || formas.size === 0) return null;
  return sujetos.map((s) => ({ sujeto: s, forma: formas.get(s.orden) || null }));
});

// "there is/there are" (migración 062) -- solo 2 filas (forma/uso), sin
// necesidad de join por `orden` (no hay una segunda columna que alinear).
const filasThereForma = computed(() => contenidoReferencias.value.filter((c) => c.variante === 'there_forma'));

const ejercicios = ref([]);
const indice = ref(0);
const respuestaSeleccionada = ref(null);
const marcarIncorrecta = ref(null);
const respondido = ref(false);
const comprobando = ref(false);
const correctasCount = ref(0);
const estadoExamen = ref('');

// Motor de Memoria (ver routers/gramatica.py::_calcular_movimiento_caja):
// confianza autoreportada ANTES de revelar si acertó + tiempo de
// respuesta medido en el cliente (render del ejercicio -> submit). Ambos
// viajan junto con la respuesta, nunca bloquean el flujo si el backend
// los ignora (son opcionales del lado del servidor).
const confianzaSeleccionada = ref(null);
const tiempoInicioMs = ref(null);
const totalVencidosRepaso = ref(0);

// Auto-explicación con LLM (Fase 3 del plan de dinamismo, opt-in, una
// sola llamada al llegar a "fin" -- ver POST /gramatica/subtemas/{slug}/
// autoexplicacion). Nunca bloquea "Volver a fases": el botón sigue
// disponible aunque el alumno no escriba nada.
const autoexplicacionTexto = ref('');
const autoexplicacionResultado = ref(null);
const autoexplicacionEnviando = ref(false);
const autoexplicacionError = ref('');

const OPCIONES_CONFIANZA = [
  { valor: 'seguro', etiqueta: '🟢 Seguro' },
  { valor: 'creo', etiqueta: '🟡 Creo que sí' },
  { valor: 'adivine', etiqueta: '🔴 Adiviné' },
];

const ETIQUETAS_TIPO = { cloze: 'Completar', transformacion: 'Transformar', conector: 'Conector' };

const itemActual = computed(() => ejercicios.value[indice.value] || null);

const contextoPartes = computed(() => {
  const item = itemActual.value;
  if (!item) return { antes: '', hueco: false, despues: '' };
  // Nunca v-html: contexto_en es texto interpolado (Vue lo escapa), el
  // hueco es un <span> separado -- mismo criterio de seguridad que
  // VocabularioView.vue.
  const match = item.contexto_en.match(/___+/);
  if (!match) return { antes: item.contexto_en, hueco: false, despues: '' };
  return {
    antes: item.contexto_en.slice(0, match.index),
    hueco: true,
    despues: item.contexto_en.slice(match.index + match[0].length),
  };
});

// Ejercicios heredados formato='reloj_visual'. La lección y sus fichas ya
// viven en TimeLesson; este cálculo permanece aquí hasta extraer también
// el render genérico de ejercicios en una fase posterior.
const anguloReloj = computed(() => {
  const item = itemActual.value;
  if (!item || item.formato !== 'reloj_visual' || !item.metadata) return null;
  return {
    horas: (item.metadata.hora % 12) * 30 + item.metadata.minuto * 0.5,
    minutos: item.metadata.minuto * 6,
  };
});

function claseOpcion(opcion) {
  if (respondido.value) return opcion === itemActual.value?.opciones_correctas ? 'correcta' : '';
  if (opcion === respuestaSeleccionada.value) return 'seleccionada';
  if (opcion === marcarIncorrecta.value) return 'incorrecta';
  return '';
}

function elegirOpcion(opcion) {
  if (respondido.value) return;
  respuestaSeleccionada.value = opcion;
  marcarIncorrecta.value = null;
}

async function cargarFases() { try { fases.value = await gramaticaApi.obtenerFases(); } catch { fases.value = []; } }

// Mapa "VS" de cruces (Fase 6 del plan de dinamismo) -- tarjetas de
// contraste curadas a mano, no un grafo dinámico. "Practicar el cruce"
// reusa la misma pantalla 'ejercicios'/'fin' que un subtema normal, pero
// con `modoCruce=true` para que siguienteEjercicio no intente marcar un
// subtema real como completado (una relación no es un subtema).
const cruces = ref([]);
const cruceActual = ref(null);
const modoCruce = ref(false);

async function cargarCruces() { try { cruces.value = await gramaticaApi.obtenerRelaciones(); } catch { cruces.value = []; } }

async function practicarCruce(cruce) {
  cruceActual.value = cruce; modoCruce.value = true; modoGusanito.value = false; estadoExamen.value = '';
  try { const lista = await gramaticaApi.obtenerEjerciciosRelacion(cruce.id); ejercicios.value = lista.map((ej) => ({ ...ej, opciones: _mezclar(ej.opciones || []) })); } catch { ejercicios.value = []; }
  indice.value = 0; correctasCount.value = 0; respondido.value = false; respuestaSeleccionada.value = null; marcarIncorrecta.value = null; confianzaSeleccionada.value = null; tiempoInicioMs.value = Date.now(); pantallaActual.value = 'ejercicios';
}

// El Gusanito (Fase 9 del plan de dinamismo) -- arranca con 2 Fases
// habilitadas (mismo criterio que el backend, ver _FASES_GUSANITO_HABILITADAS
// en routers/gramatica.py). "Jugar un nodo" reusa la pantalla 'ejercicios'
// existente (modoGusanito=true, mismo patrón que modoCruce) -- los
// ejercicios vienen de /gusanito/{fase}/{subtema}/ejercicios (concepto 0 +
// vencidos), la evaluación sigue siendo POST /ejercicios/evaluar tal cual.
const FASES_GUSANITO = [
  { slug: 'fase-1-fundamentos', nombre: 'Fundamentos' },
  { slug: 'fase-2-to-be-pronombres', nombre: 'Verbo to be y pronombres básicos' },
];
const gusanitoFaseActual = ref(null);
const gusanitoNodos = ref([]);
const gusanitoPosicion = ref(0);
const gusanitoMetaAlcanzada = ref(false);
const gusanitoNodoActual = ref(null);
const modoGusanito = ref(false);
// Evolución del gusano (Fase 10): tier global calculado como % de
// ejercicios de gramática dominados sobre el total existente -- se
// recarga cada vez que se entra a elegir camino, para reflejar el
// progreso justo después de jugar una ronda.
const gusanitoEvolucion = ref(null);

async function cargarEvolucionGusanito() { try { gusanitoEvolucion.value = await gramaticaApi.obtenerEvolucionGusanito(); } catch { gusanitoEvolucion.value = null; } }

async function abrirCentroJuegos() {
  pantallaActual.value = 'gusanito-juegos';
  await cargarEvolucionGusanito();
}

async function irAGusanitoFases() {
  pantallaActual.value = 'gusanito-fases';
  await cargarEvolucionGusanito();
}

async function abrirGusanito(fase) {
  gusanitoFaseActual.value = fase;
  pantallaActual.value = 'gusanito-camino';
  await cargarEstadoGusanito();
}

async function cargarEstadoGusanito() {
  try { const data = await gramaticaApi.obtenerCaminoGusanito(gusanitoFaseActual.value.slug); gusanitoNodos.value = data.nodos || []; gusanitoPosicion.value = data.posicion || 0; gusanitoMetaAlcanzada.value = Boolean(data.meta_alcanzada); } catch { gusanitoNodos.value = []; }
}

async function jugarNodoGusanito(nodo) {
  gusanitoNodoActual.value = nodo; modoGusanito.value = true; modoCruce.value = false; estadoExamen.value = '';
  try { const lista = await gramaticaApi.obtenerEjerciciosGusanito(gusanitoFaseActual.value.slug, nodo.slug); ejercicios.value = lista.map((ej) => ({ ...ej, opciones: _mezclar(ej.opciones || []) })); } catch { ejercicios.value = []; }
  indice.value = 0; correctasCount.value = 0; respondido.value = false; respuestaSeleccionada.value = null; marcarIncorrecta.value = null; confianzaSeleccionada.value = null; tiempoInicioMs.value = Date.now(); pantallaActual.value = 'ejercicios';
}

async function elegirFase(fase) { faseActual.value = fase; pantallaActual.value = 'subtemas'; subtemas.value = []; try { subtemas.value = await gramaticaApi.obtenerSubtemas(fase.slug); } catch { subtemas.value = []; } }

async function elegirSubtema(subtema) { subtemaActual.value = subtema; pantallaActual.value = 'estudio'; contenido.value = []; prediccionElegida.value = null; try { contenido.value = await gramaticaApi.obtenerContenido(subtema.slug); } catch { contenido.value = []; } }

function _mezclar(array) {
  const copia = [...array];
  for (let i = copia.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copia[i], copia[j]] = [copia[j], copia[i]];
  }
  return copia;
}

async function empezarEjercicios() {
  modoCruce.value = false; modoGusanito.value = false; indice.value = 0; correctasCount.value = 0; estadoExamen.value = 'Cargando ejercicios...'; ejercicios.value = [];
  try { const lista = await gramaticaApi.obtenerEjercicios(subtemaActual.value.slug); ejercicios.value = lista.map((ej) => ({ ...ej, opciones: _mezclar(ej.opciones || []) })); estadoExamen.value = ''; } catch { estadoExamen.value = 'Error de red al cargar los ejercicios.'; }
  respondido.value = false; respuestaSeleccionada.value = null; marcarIncorrecta.value = null; reiniciarAudio(); confianzaSeleccionada.value = null; tiempoInicioMs.value = Date.now(); pantallaActual.value = 'ejercicios';
}

async function comprobarRespuesta() {
  const item = itemActual.value; if (!item || !respuestaSeleccionada.value || !confianzaSeleccionada.value) return; comprobando.value = true; estadoExamen.value = '';
  try { const data = await gramaticaApi.evaluarEjercicio({ ejercicio_id: item.id, respuesta_usuario: respuestaSeleccionada.value, confianza: confianzaSeleccionada.value, tiempo_respuesta_ms: Date.now() - tiempoInicioMs.value });
    if (data.correcto) { respondido.value = true; item.opciones_correctas = data.respuesta_esperada; correctasCount.value++; } else { marcarIncorrecta.value = respuestaSeleccionada.value; respuestaSeleccionada.value = null; if (data.error_consolidado) estadoExamen.value = 'Estabas muy seguro y no era -- puede valer la pena repasar la regla de nuevo.'; confianzaSeleccionada.value = null; tiempoInicioMs.value = Date.now(); }
  } catch { estadoExamen.value = 'Error de red al evaluar.'; } finally { comprobando.value = false; }
}

async function siguienteEjercicio() {
  if (indice.value + 1 < ejercicios.value.length) {
    indice.value++;
    respondido.value = false;
    respuestaSeleccionada.value = null;
    marcarIncorrecta.value = null;
    reiniciarAudio();
    confianzaSeleccionada.value = null;
    tiempoInicioMs.value = Date.now();
    estadoExamen.value = '';
    return;
  }
  if (!modoCruce.value && !modoGusanito.value) {
    await gramaticaApi.completarSubtema(subtemaActual.value.slug);
  }
  if (modoGusanito.value) {
    await cargarEstadoGusanito();
  }
  autoexplicacionTexto.value = '';
  autoexplicacionResultado.value = null;
  autoexplicacionError.value = '';
  pantallaActual.value = 'fin';
}

async function enviarAutoexplicacion() {
  if (!autoexplicacionTexto.value.trim() || autoexplicacionEnviando.value) return; autoexplicacionEnviando.value = true; autoexplicacionError.value = '';
  try { autoexplicacionResultado.value = await gramaticaApi.enviarAutoexplicacion(subtemaActual.value.slug, autoexplicacionTexto.value.trim()); }
  catch (error) { autoexplicacionError.value = error.status === 429 ? 'Ya usaste varias veces esto en el último minuto, esperá un poco.' : 'No se pudo evaluar tu explicación, intentá de nuevo.'; }
  finally { autoexplicacionEnviando.value = false; }
}

async function cargarRepaso() { try { const data = await gramaticaApi.obtenerRepaso(); totalVencidosRepaso.value = data.total_vencidos; } catch { /* El hub sigue siendo usable sin este dato. */ } }

cargarFases();
cargarRepaso();
cargarCruces();
</script>

<template>
  <div class="gramatica-view">
    <div v-if="pantallaActual === 'fases'">
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">📖 Gramática</h1>
        <p class="gramatica-view__subtitulo">Aprendé cómo se compone el inglés, fase por fase -- reglas, ejemplos y ejercicios de práctica.</p>
      </div>
      <div v-if="totalVencidosRepaso > 0" class="gramatica-view__card-repaso">
        🔁 Repaso de hoy: {{ totalVencidosRepaso }}
      </div>
      <button class="gramatica-view__link-cruces" @click="abrirCentroJuegos">🐛 Alimentar y jugar con el Gusanito →</button>
      <button v-if="cruces.length > 0" class="gramatica-view__link-cruces" @click="pantallaActual = 'cruces'">🔀 Ver cruces entre reglas →</button>
      <p v-if="fases.length === 0" class="gramatica-view__subtitulo">Todavía no hay fases con contenido cargado.</p>
      <div v-else class="gramatica-view__grid">
        <button
          v-for="f in fases"
          :key="f.slug"
          class="gramatica-view__btn-item"
          :class="{ 'gramatica-view__btn-item--completado': f.completado, 'gramatica-view__btn-item--proximamente': !f.disponible }"
          :disabled="!f.disponible"
          @click="elegirFase(f)"
        >{{ f.nombre }}<span v-if="!f.disponible" class="gramatica-view__etiqueta-proximamente">Próximamente</span></button>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'subtemas'">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'fases'">← Fases</button>
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">{{ faseActual?.nombre }}</h1>
      </div>
      <div class="gramatica-view__grid">
        <button
          v-for="s in subtemas"
          :key="s.slug"
          class="gramatica-view__btn-item"
          :class="{ 'gramatica-view__btn-item--completado': s.completado }"
          @click="elegirSubtema(s)"
        >{{ s.nombre }}</button>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'estudio'">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'subtemas'">← Subtemas</button>
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">
          <span v-if="iconoAnclajeActual" class="gramatica-view__icono-anclaje">{{ iconoAnclajeActual }}</span>{{ subtemaActual?.nombre }}
        </h1>
        <p class="gramatica-view__subtitulo">Studentbook -- leé la regla y los ejemplos antes de pasar a los ejercicios.</p>
      </div>

      <div v-for="p in (usaLeccionEspecializada ? [] : contenidoPredicciones)" :key="p.id" class="gramatica-view__contenido-card gramatica-view__contenido-card--prediccion">
        <span class="gramatica-view__contenido-tipo">¿Qué creés?</span>
        <p class="gramatica-view__contenido-texto-en">{{ p.texto_en }}</p>
        <p class="gramatica-view__contenido-texto-es">{{ p.texto_es }}</p>
        <div class="gramatica-view__opciones-prediccion">
          <button
            v-for="(opcion, idx) in p.metadata.opciones"
            :key="idx"
            class="gramatica-view__btn-prediccion"
            :class="{
              'gramatica-view__btn-prediccion--correcta': prediccionElegida !== null && idx === p.metadata.correcta,
              'gramatica-view__btn-prediccion--incorrecta': prediccionElegida === idx && idx !== p.metadata.correcta,
            }"
            :disabled="prediccionElegida !== null"
            @click="prediccionElegida = idx"
          >{{ opcion }}</button>
        </div>
        <p v-if="prediccionElegida !== null" class="gramatica-view__feedback" :class="prediccionElegida === p.metadata.correcta ? 'gramatica-view__feedback--correcto' : 'gramatica-view__feedback--incorrecto'">
          {{ prediccionElegida === p.metadata.correcta ? '✓ ¡Tu intuición era correcta!' : 'La razón real es otra -- fijate en la regla de abajo.' }}
        </p>
      </div>

      <div v-if="contenidoReglas.length > 0 && !esSaludos && !esFamilia && !esAbreviaturas && !esFrutas && !esToBe && !esPronombres && !esPresenteSimple && !esPresenteContinuo && !esContrastePresente && !modoPasado && !modoPerfecto && !modoPasiva && !modoFuturo" class="gramatica-view__lista-contenido">
        <div v-for="c in contenidoReglas" :key="c.id" class="gramatica-view__contenido-card gramatica-view__contenido-card--regla">
          <span class="gramatica-view__contenido-tipo">Regla</span>
          <p class="gramatica-view__contenido-texto-es">{{ c.texto_es }}</p>
          <p class="gramatica-view__contenido-texto-en">
            {{ c.texto_en }}
            <button
              v-if="c.audio_key"
              class="gramatica-view__btn-audio"
              :disabled="reproduciendoId === c.id"
              title="Escuchar"
              @click="reproducirAudio(c)"
            >🔊</button>
          </p>
        </div>
      </div>

      <GreetingLesson
        v-if="esSaludos"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <FamilyLesson
        v-else-if="esFamilia"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <AbbreviationLesson
        v-else-if="esAbreviaturas"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <FruitLesson
        v-else-if="esFrutas"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <ToBeLesson
        v-else-if="esToBe"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PronounLesson
        v-else-if="esPronombres"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PresentSimpleLesson
        v-else-if="esPresenteSimple"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PresentContinuousLesson
        v-else-if="esPresenteContinuo"
        :items="contenidoReferencias"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PresentContrastLesson
        v-else-if="esContrastePresente"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PastLesson
        v-else-if="modoPasado"
        :mode="modoPasado"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PresentPerfectLesson
        v-else-if="modoPerfecto"
        :mode="modoPerfecto"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PassiveVoiceLesson
        v-else-if="modoPasiva"
        :mode="modoPasiva"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <FutureLesson
        v-else-if="modoFuturo"
        :mode="modoFuturo"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <DateLesson
        v-else-if="esFecha"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <TimeLesson
        v-else-if="esHora"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <NumbersLesson
        v-else-if="esNumeros && contenidoReferencias.length > 0"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @reproducir-lento="reproducirAudioLento"
        @practicar="empezarEjercicios"
      />

      <div v-else-if="filasNumeros" class="gramatica-view__tabla-numeros">
        <div class="gramatica-view__fila-numero gramatica-view__fila-numero--encabezado">
          <span class="gramatica-view__numero-celda">Nº</span>
          <span class="gramatica-view__numero-celda">Cardinal</span>
          <span class="gramatica-view__numero-celda">Ordinal</span>
        </div>
        <div v-for="fila in filasNumeros" :key="fila.numeral" class="gramatica-view__fila-numero">
          <span class="gramatica-view__numero-celda gramatica-view__numero-numeral">{{ fila.numeral }}</span>
          <button
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.cardinal.id }"
            :disabled="!fila.cardinal.audio_key || reproduciendoId === fila.cardinal.id"
            :title="fila.cardinal.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.cardinal)"
          >{{ fila.cardinal.texto_en }}</button>
          <button
            v-if="fila.ordinal"
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.ordinal.id }"
            :disabled="!fila.ordinal.audio_key || reproduciendoId === fila.ordinal.id"
            :title="fila.ordinal.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.ordinal)"
          >{{ fila.ordinal.texto_en }}</button>
          <span v-else class="gramatica-view__numero-celda"></span>
        </div>
      </div>

      <AbecedarioLesson
        v-else-if="esAbecedario && contenidoReferencias.length > 0"
        :items="contenidoReferencias"
        :reproduciendo-id="reproduciendoId"
        :completado="Boolean(subtemaActual?.completado)"
        @reproducir="reproducirAudio"
        @reproducir-lento="reproducirAudioLento"
        @practicar="empezarEjercicios"
      />

      <div v-else-if="gruposReferencias.length > 0" class="gramatica-view__grupos-referencias">
        <div v-for="grupo in gruposReferencias" :key="grupo.titulo || 'unico'" class="gramatica-view__grupo-referencia">
          <h3 v-if="grupo.titulo" class="gramatica-view__grupo-titulo">{{ grupo.titulo }}</h3>

          <div v-if="usaTablaTraduccion" class="gramatica-view__tabla-numeros gramatica-view__tabla-numeros--referencia">
            <div v-for="c in grupo.items" :key="c.id" class="gramatica-view__fila-numero">
              <button
                class="gramatica-view__numero-celda gramatica-view__numero-palabra"
                :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === c.id }"
                :disabled="!c.audio_key || reproduciendoId === c.id"
                :title="c.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
                @click="reproducirAudio(c)"
              >{{ c.texto_en }}</button>
              <span class="gramatica-view__numero-celda gramatica-view__referencia-traduccion">{{ c.texto_es }}</span>
            </div>
          </div>

          <div v-else class="gramatica-view__grid-referencias">
            <button
              v-for="c in grupo.items"
              :key="c.id"
              class="gramatica-view__btn-referencia"
              :class="{ 'gramatica-view__btn-referencia--sonando': reproduciendoId === c.id }"
              :disabled="!c.audio_key || reproduciendoId === c.id"
              :title="c.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
              @click="reproducirAudio(c)"
            >{{ c.texto_en }}<span v-if="esNumeralPuro(c.texto_es)" class="gramatica-view__referencia-numeral">{{ c.texto_es }}</span></button>
          </div>
        </div>
      </div>

      <div v-if="filasPronombres && !esPronombres" class="gramatica-view__tabla-numeros gramatica-view__tabla-numeros--pronombres">
        <div class="gramatica-view__fila-numero gramatica-view__fila-numero--encabezado">
          <span class="gramatica-view__numero-celda">Sujeto</span>
          <span class="gramatica-view__numero-celda">Objeto</span>
          <span class="gramatica-view__numero-celda">Posesivo</span>
          <span class="gramatica-view__numero-celda">Pron. posesivo</span>
        </div>
        <div v-for="fila in filasPronombres" :key="fila.sujeto.id" class="gramatica-view__fila-numero">
          <button
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.sujeto.id }"
            :disabled="!fila.sujeto.audio_key || reproduciendoId === fila.sujeto.id"
            :title="fila.sujeto.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.sujeto)"
          >{{ fila.sujeto.texto_en }}</button>
          <button
            v-if="fila.objeto"
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.objeto.id }"
            :disabled="!fila.objeto.audio_key || reproduciendoId === fila.objeto.id"
            :title="fila.objeto.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.objeto)"
          >{{ fila.objeto.texto_en }}</button>
          <span v-else class="gramatica-view__numero-celda"></span>
          <button
            v-if="fila.posesivoAdj"
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.posesivoAdj.id }"
            :disabled="!fila.posesivoAdj.audio_key || reproduciendoId === fila.posesivoAdj.id"
            :title="fila.posesivoAdj.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.posesivoAdj)"
          >{{ fila.posesivoAdj.texto_en }}</button>
          <span v-else class="gramatica-view__numero-celda"></span>
          <button
            v-if="fila.posesivoPron"
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.posesivoPron.id }"
            :disabled="!fila.posesivoPron.audio_key || reproduciendoId === fila.posesivoPron.id"
            :title="fila.posesivoPron.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.posesivoPron)"
          >{{ fila.posesivoPron.texto_en }}</button>
          <span v-else class="gramatica-view__numero-celda"></span>
        </div>
      </div>

      <div v-if="filasTobePasado" class="gramatica-view__tabla-numeros">
        <div class="gramatica-view__fila-numero gramatica-view__fila-numero--encabezado">
          <span class="gramatica-view__numero-celda">Pronombre</span>
          <span class="gramatica-view__numero-celda">was/were</span>
        </div>
        <div v-for="fila in filasTobePasado" :key="fila.sujeto.id" class="gramatica-view__fila-numero">
          <button
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.sujeto.id }"
            :disabled="!fila.sujeto.audio_key || reproduciendoId === fila.sujeto.id"
            :title="fila.sujeto.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.sujeto)"
          >{{ fila.sujeto.texto_en }}</button>
          <button
            v-if="fila.forma"
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.forma.id }"
            :disabled="!fila.forma.audio_key || reproduciendoId === fila.forma.id"
            :title="fila.forma.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila.forma)"
          >{{ fila.forma.texto_en }}</button>
          <span v-else class="gramatica-view__numero-celda"></span>
        </div>
      </div>

      <div v-if="filasThereForma.length > 0" class="gramatica-view__tabla-numeros">
        <div class="gramatica-view__fila-numero gramatica-view__fila-numero--encabezado">
          <span class="gramatica-view__numero-celda">Cantidad</span>
          <span class="gramatica-view__numero-celda">Forma</span>
        </div>
        <div v-for="fila in filasThereForma" :key="fila.id" class="gramatica-view__fila-numero">
          <span class="gramatica-view__numero-celda">{{ fila.texto_es }}</span>
          <button
            class="gramatica-view__numero-celda gramatica-view__numero-palabra"
            :class="{ 'gramatica-view__numero-palabra--sonando': reproduciendoId === fila.id }"
            :disabled="!fila.audio_key || reproduciendoId === fila.id"
            :title="fila.audio_key ? 'Escuchar' : 'Audio no generado todavía'"
            @click="reproducirAudio(fila)"
          >{{ fila.texto_en }}</button>
        </div>
      </div>

      <button
        v-if="!usaLeccionEspecializada"
        class="gramatica-view__btn-empezar-ejercicios"
        :disabled="subtemaActual?.completado"
        @click="empezarEjercicios"
      >{{ subtemaActual?.completado ? '✓ Ejercicios ya acreditados' : 'Practicar ejercicios →' }}</button>

      <div v-if="contenidoEjemplos.length > 0 && !usaLeccionEspecializada" class="gramatica-view__lista-contenido">
        <div v-for="c in contenidoEjemplos" :key="c.id" class="gramatica-view__contenido-card gramatica-view__contenido-card--ejemplo">
          <span class="gramatica-view__contenido-tipo">Ejemplo</span>
          <img
            v-if="c.imagen_key"
            class="gramatica-view__imagen-escena"
            :src="`/gramatica/imagen/${encodeURIComponent(c.imagen_key)}`"
            :alt="c.texto_es"
            loading="lazy"
          />
          <p class="gramatica-view__contenido-texto-es">{{ c.texto_es }}</p>
          <p class="gramatica-view__contenido-texto-en">
            {{ c.texto_en }}
            <button
              v-if="c.audio_key"
              class="gramatica-view__btn-audio"
              :disabled="reproduciendoId === c.id"
              title="Escuchar"
              @click="reproducirAudio(c)"
            >🔊</button>
            <span v-if="c.personaje_nombre" class="gramatica-view__personaje-etiqueta">con {{ c.personaje_nombre }}</span>
          </p>
        </div>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'ejercicios'">
      <h1 class="gramatica-view__titulo">✏️ {{ subtemaActual?.nombre }}</h1>
      <p class="gramatica-view__progreso-examen">Ejercicio {{ indice + 1 }} de {{ ejercicios.length }}</p>

      <div v-if="itemActual" class="gramatica-view__tarjeta">
        <span class="gramatica-view__tarjeta-tipo">{{ itemActual.formato === 'detectar_error' ? 'Detectá el error' : (ETIQUETAS_TIPO[itemActual.tipo] || itemActual.tipo) }}</span>
        <p class="gramatica-view__tarjeta-consigna">{{ itemActual.consigna_es }}</p>

        <p v-if="itemActual.formato === 'texto'" class="gramatica-view__tarjeta-contexto">{{ contextoPartes.antes }}<span v-if="contextoPartes.hueco" class="gramatica-view__hueco">&nbsp;</span>{{ contextoPartes.despues }}</p>
        <div v-else-if="itemActual.formato === 'audio_secuencia'" class="gramatica-view__deletreo">
          <button
            class="gramatica-view__btn-deletreo"
            :disabled="reproduciendoSecuencia"
            @click="reproducirSecuencia(itemActual)"
          >{{ reproduciendoSecuencia ? '🔊 Reproduciendo...' : '🔊 Escuchar' }}</button>
        </div>
        <div v-else-if="itemActual.formato === 'conteo_visual'" class="gramatica-view__conteo">
          <span v-for="n in itemActual.metadata.cantidad" :key="n" class="gramatica-view__conteo-emoji">{{ itemActual.metadata.emoji }}</span>
        </div>
        <div v-else-if="itemActual.formato === 'reloj_visual'" class="gramatica-view__reloj">
          <div class="gramatica-view__reloj-esfera">
            <span
              v-for="n in 12"
              :key="n"
              class="gramatica-view__reloj-marca"
              :style="{ transform: `rotate(${n * 30}deg)` }"
            ></span>
            <div class="gramatica-view__reloj-aguja gramatica-view__reloj-aguja--hora" :style="{ transform: `translateX(-50%) rotate(${anguloReloj.horas}deg)` }"></div>
            <div class="gramatica-view__reloj-aguja gramatica-view__reloj-aguja--minuto" :style="{ transform: `translateX(-50%) rotate(${anguloReloj.minutos}deg)` }"></div>
            <div class="gramatica-view__reloj-centro"></div>
          </div>
        </div>
        <div v-else-if="itemActual.formato === 'conversacion_audio'" class="gramatica-view__conversacion">
          <button
            class="gramatica-view__btn-deletreo"
            :disabled="reproduciendoSecuencia"
            @click="reproducirConversacion(itemActual)"
          >{{ reproduciendoSecuencia ? '🔊 Reproduciendo...' : '▶ Escuchar conversación' }}</button>
          <div class="gramatica-view__chat">
            <button
              v-for="(turno, idx) in itemActual.metadata.turnos"
              :key="idx"
              class="gramatica-view__burbuja"
              :class="[
                turno.hablante === 'A' ? 'gramatica-view__burbuja--a' : 'gramatica-view__burbuja--b',
                { 'gramatica-view__burbuja--sonando': turnoIndiceSonando === idx },
              ]"
              :disabled="!turno.audio_key || reproduciendoSecuencia"
              title="Escuchar este turno"
              @click="reproducirTurno(itemActual, idx)"
            >{{ turno.texto_en }}</button>
          </div>
          <p class="gramatica-view__tarjeta-contexto gramatica-view__pregunta-conversacion">{{ itemActual.contexto_en }}</p>
        </div>
        <div v-else-if="itemActual.formato === 'audio_frase'" class="gramatica-view__conversacion">
          <button
            class="gramatica-view__btn-deletreo"
            :disabled="reproduciendoSecuencia"
            @click="reproducirFrase(itemActual)"
          >{{ reproduciendoSecuencia ? '🔊 Reproduciendo...' : '🔊 Escuchar' }}</button>
          <p class="gramatica-view__tarjeta-contexto gramatica-view__pregunta-conversacion">{{ itemActual.contexto_en }}</p>
        </div>
        <p v-else-if="itemActual.formato === 'detectar_error'" class="gramatica-view__detectar-error-etiqueta">
          🔎 Una de estas tiene un error típico de hispanohablante -- tocá cuál.
        </p>

        <div class="gramatica-view__opciones">
          <button
            v-for="(opcion, idx) in itemActual.opciones"
            :key="idx"
            class="gramatica-view__btn-opcion"
            :class="claseOpcion(opcion)"
            :disabled="respondido"
            @click="elegirOpcion(opcion)"
          >{{ opcion }}</button>
        </div>

        <div v-if="!respondido && respuestaSeleccionada" class="gramatica-view__confianza">
          <span class="gramatica-view__confianza-etiqueta">¿Qué tan seguro estás?</span>
          <button
            v-for="op in OPCIONES_CONFIANZA"
            :key="op.valor"
            class="gramatica-view__btn-confianza"
            :class="{ 'gramatica-view__btn-confianza--activo': confianzaSeleccionada === op.valor }"
            @click="confianzaSeleccionada = op.valor"
          >{{ op.etiqueta }}</button>
        </div>

        <template v-if="respondido">
          <div class="gramatica-view__feedback gramatica-view__feedback--correcto">✓ ¡Correcto!</div>
          <div v-if="itemActual.metadata?.categoria_error" class="gramatica-view__feedback">💡 {{ itemActual.metadata.categoria_error }}</div>
        </template>
        <div v-else-if="marcarIncorrecta" class="gramatica-view__feedback gramatica-view__feedback--incorrecto">✗ No es correcta, probá de nuevo.</div>

        <button
          v-if="!respondido"
          class="gramatica-view__btn-comprobar"
          :disabled="!respuestaSeleccionada || !confianzaSeleccionada || comprobando"
          @click="comprobarRespuesta"
        >Comprobar</button>
        <button v-else class="gramatica-view__btn-comprobar" @click="siguienteEjercicio">
          {{ indice + 1 < ejercicios.length ? 'Siguiente →' : 'Terminar' }}
        </button>
      </div>

      <div class="gramatica-view__estado-examen">{{ estadoExamen }}</div>
    </div>

    <div v-else-if="pantallaActual === 'fin'" class="gramatica-view__fin">
      <h1 class="gramatica-view__titulo">{{ modoGusanito ? '🐛 ¡Ronda jugada!' : (modoCruce ? '✓ ¡Cruce practicado!' : '✓ ¡Subtema completado!') }}</h1>
      <div class="gramatica-view__resumen-final">{{ correctasCount }} de {{ ejercicios.length }} correctas al primer intento</div>
      <p class="gramatica-view__subtitulo">{{ modoGusanito ? 'Tu gusano se movió según cómo respondiste.' : (modoCruce ? 'Sumaste puntos por cada ejercicio.' : 'Sumaste puntos para tu nivel general.') }}</p>

      <template v-if="!modoCruce && !modoGusanito">
        <div v-if="!autoexplicacionResultado" class="gramatica-view__autoexplicacion">
          <p class="gramatica-view__autoexplicacion-etiqueta">Opcional: explicá con tus palabras cuándo usarías esto.</p>
          <textarea
            v-model="autoexplicacionTexto"
            class="gramatica-view__autoexplicacion-textarea"
            maxlength="500"
            placeholder="Ej: se usa para conectar algo que pasó antes con ahora..."
            :disabled="autoexplicacionEnviando"
          ></textarea>
          <button
            class="gramatica-view__btn-autoexplicacion"
            :disabled="!autoexplicacionTexto.trim() || autoexplicacionEnviando"
            @click="enviarAutoexplicacion"
          >{{ autoexplicacionEnviando ? 'Evaluando...' : 'Enviar' }}</button>
          <p v-if="autoexplicacionError" class="gramatica-view__feedback gramatica-view__feedback--incorrecto">{{ autoexplicacionError }}</p>
        </div>
        <div v-else class="gramatica-view__autoexplicacion-resultado">
          <p v-if="autoexplicacionResultado.coincide.length > 0" class="gramatica-view__feedback gramatica-view__feedback--correcto">
            <strong>Coincidís en:</strong> {{ autoexplicacionResultado.coincide.join('; ') }}
          </p>
          <p v-else class="gramatica-view__feedback gramatica-view__feedback--correcto">
            ¡Gracias por explicarlo con tus palabras! Eso ayuda a fijar el concepto.
          </p>
        </div>
      </template>

      <button v-if="modoGusanito" class="btn btn-primario" @click="pantallaActual = 'gusanito-camino'">Volver al camino</button>
      <button v-else class="btn btn-primario" @click="modoCruce = false; pantallaActual = 'fases'">Volver a fases</button>
    </div>

    <GrammarGameHub
      v-else-if="pantallaActual === 'gusanito-juegos'"
      :evolucion="gusanitoEvolucion"
      @volver="pantallaActual = 'fases'"
      @abrir-caminos="irAGusanitoFases"
    />

    <div v-else-if="pantallaActual === 'gusanito-fases'">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'fases'">← Fases</button>
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">🐛 El Gusanito</h1>
        <p class="gramatica-view__subtitulo">Elegí un camino para jugar.</p>
      </div>
      <div v-if="gusanitoEvolucion" class="gramatica-view__card-repaso gramatica-view__card-evolucion">
        {{ gusanitoEvolucion.emoji }} Tu gusano: {{ gusanitoEvolucion.pct_dominado }}% dominado ({{ gusanitoEvolucion.dominados }} de {{ gusanitoEvolucion.total }} ejercicios de gramática)
      </div>
      <div class="gramatica-view__grid">
        <button
          v-for="f in FASES_GUSANITO"
          :key="f.slug"
          class="gramatica-view__btn-item"
          @click="abrirGusanito(f)"
        >{{ f.nombre }}</button>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'gusanito-camino'">
      <button class="gramatica-view__link-volver" @click="irAGusanitoFases">← Caminos</button>
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">🐛 {{ gusanitoFaseActual?.nombre }}</h1>
        <p class="gramatica-view__subtitulo">{{ gusanitoMetaAlcanzada ? '¡Meta alcanzada! Podés seguir repasando cuando quieras.' : 'Tocá un nodo para jugar.' }}</p>
      </div>
      <p v-if="gusanitoNodos.length === 0" class="gramatica-view__subtitulo">Todavía no hay ejercicios cargados para este camino.</p>
      <div v-else class="gramatica-view__camino-gusanito">
        <div
          v-for="(nodo, idx) in gusanitoNodos"
          :key="nodo.slug"
          class="gramatica-view__nodo-gusanito"
          :class="`gramatica-view__nodo-gusanito--${nodo.estado}`"
        >
          <span v-if="idx === gusanitoPosicion" class="gramatica-view__gusano-marcador">🐛</span>
          <button class="gramatica-view__btn-nodo-gusanito" @click="jugarNodoGusanito(nodo)">
            {{ nodo.estado === 'dominado' ? '✓' : '' }} {{ nodo.nombre }}
          </button>
        </div>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'cruces'">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'fases'">← Fases</button>
      <div class="gramatica-view__cabecera">
        <h1 class="gramatica-view__titulo">🔀 Cruces</h1>
        <p class="gramatica-view__subtitulo">Las reglas que más se confunden entre sí, una al lado de la otra.</p>
      </div>
      <p v-if="cruces.length === 0" class="gramatica-view__subtitulo">Todavía no hay cruces cargados.</p>
      <div v-else class="gramatica-view__lista-contenido">
        <div v-for="c in cruces" :key="c.id" class="gramatica-view__contenido-card gramatica-view__contenido-card--cruce">
          <span class="gramatica-view__contenido-tipo">{{ c.tipo_relacion }}</span>
          <div class="gramatica-view__cruce-vs">
            <span class="gramatica-view__cruce-tema">{{ c.tema_a_nombre }}</span>
            <span class="gramatica-view__cruce-vs-texto">VS</span>
            <span class="gramatica-view__cruce-tema">{{ c.tema_b_nombre }}</span>
          </div>
          <p class="gramatica-view__contenido-texto-es">{{ c.texto_es }}</p>
          <button class="gramatica-view__btn-comprobar" @click="practicarCruce(c)">Practicar el cruce →</button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.gramatica-view {
  max-width: 100%;
}

.gramatica-view__cabecera {
  text-align: center;
  padding: 0.5rem 0 1rem;
}

.gramatica-view__titulo {
  font-size: 1.2rem;
  margin: 0.25rem 0;
}

.gramatica-view__subtitulo {
  color: var(--color-texto-secundario);
  font-size: 0.85rem;
  margin-bottom: 1rem;
}

.gramatica-view__link-volver {
  color: var(--color-azul);
  text-decoration: none;
  font-size: 0.85rem;
  cursor: pointer;
  background: none;
  border: none;
  padding: 0;
}

.gramatica-view__grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 0.6rem;
  margin: 1rem auto 0;
}

.gramatica-view__btn-item {
  background: white;
  border: 2px solid var(--color-borde);
  border-radius: var(--radio-card);
  padding: 0.9rem 0.6rem;
  font-size: 0.9rem;
  cursor: pointer;
  text-align: center;
}

.gramatica-view__btn-item:hover {
  border-color: #90caf9;
}

.gramatica-view__btn-item--completado {
  border-color: var(--color-verde);
  background: var(--color-verde-suave);
}

.gramatica-view__btn-item--proximamente {
  cursor: default;
  opacity: 0.6;
}

.gramatica-view__btn-item--proximamente:hover {
  border-color: var(--color-borde);
}

.gramatica-view__etiqueta-proximamente {
  display: block;
  font-size: 0.65rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-texto-tenue);
  margin-top: 0.3rem;
}

.gramatica-view__lista-contenido {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  margin: 1rem 0;
}

.gramatica-view__contenido-card {
  background: white;
  border: 1px solid var(--color-borde);
  border-radius: var(--radio-card);
  padding: 0.8rem 1rem;
}

.gramatica-view__contenido-card--regla {
  border-left: 4px solid var(--color-azul);
}

.gramatica-view__contenido-card--prediccion {
  border-left: 4px solid #ffa726;
  background: #fff8ec;
  margin-bottom: 0.6rem;
}

.gramatica-view__opciones-prediccion {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  margin-top: 0.5rem;
}

.gramatica-view__btn-prediccion {
  text-align: left;
  background: white;
  border: 1px solid var(--color-borde);
  border-radius: var(--radio-boton);
  padding: 0.5rem 0.7rem;
  font-size: 0.88rem;
  cursor: pointer;
}

.gramatica-view__btn-prediccion:disabled {
  cursor: default;
}

.gramatica-view__btn-prediccion--correcta {
  border-color: var(--color-verde);
  background: var(--color-verde-suave);
}

.gramatica-view__btn-prediccion--incorrecta {
  border-color: var(--color-rojo);
  background: var(--color-rojo-suave);
}

.gramatica-view__imagen-escena {
  width: 100%;
  max-width: 320px;
  border-radius: var(--radio-card);
  margin-bottom: 0.5rem;
  display: block;
}

.gramatica-view__personaje-etiqueta {
  display: inline-block;
  font-size: 0.75rem;
  font-style: italic;
  color: var(--color-texto-tenue);
  margin-left: 0.3rem;
}

.gramatica-view__icono-anclaje {
  font-size: 1.3rem;
  margin-right: 0.4rem;
}

.gramatica-view__contenido-tipo {
  display: inline-block;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-texto-tenue);
  margin-bottom: 0.4rem;
}

.gramatica-view__contenido-texto-es {
  font-size: 0.9rem;
  color: var(--color-texto-secundario);
  margin: 0 0 0.5rem;
}

.gramatica-view__contenido-texto-en {
  font-size: 1rem;
  font-style: italic;
  margin: 0;
}

.gramatica-view__btn-audio {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 0.9rem;
  margin-left: 0.3rem;
  opacity: 0.7;
  vertical-align: middle;
}

.gramatica-view__btn-audio:hover {
  opacity: 1;
}

.gramatica-view__btn-audio:disabled {
  opacity: 0.3;
  cursor: wait;
}

.gramatica-view__tabla-numeros {
  /* Grilla ÚNICA compartida por todas las filas (antes cada fila tenía su
     propia grilla independiente -- el ancho de columna se calculaba fila
     por fila, así que el numeral de "1" y el de "1,000,000" terminaban en
     columnas de ancho distinto y las palabras no quedaban alineadas entre
     filas). Con una sola grilla, la columna del numeral se dimensiona
     considerando el contenido de TODAS las filas a la vez (incluida
     "1,000,000"), así todo alinea contra la fila más ancha. */
  display: grid;
  grid-template-columns: minmax(2.3rem, auto) minmax(0, 1fr) minmax(0, 1fr);
  column-gap: 0.6rem;
  margin: 1rem 0;
  background: white;
  border: 1px solid var(--color-borde);
  border-radius: var(--radio-card);
  overflow: hidden;
}

.gramatica-view__fila-numero {
  /* display:contents saca la fila del árbol de cajas: sus hijos (celdas)
     pasan a ser ítems directos de la grilla del padre, en vez de que cada
     fila arme su propia grilla chica -- esto es lo que logra la
     alineación real entre filas. */
  display: contents;
}

.gramatica-view__numero-celda {
  display: flex;
  align-items: center;
  padding: 0.6rem 0.5rem;
}

.gramatica-view__fila-numero--encabezado .gramatica-view__numero-celda {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-texto-tenue);
  padding-top: 0.4rem;
  padding-bottom: 0.4rem;
}

.gramatica-view__numero-numeral {
  font-weight: 700;
  color: var(--color-azul);
  justify-content: center;
  white-space: nowrap;
  gap: 0.4rem;
}

/* Tabla de palabra + traducción (saludos/despedidas, abreviaturas,
   frutas -- ver _SUBTEMAS_TABLA_TRADUCCION): 2 columnas iguales, misma
   grilla compartida que --pronombres/--reloj para que las filas alineen
   entre sí. */
.gramatica-view__tabla-numeros--referencia {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.gramatica-view__referencia-traduccion {
  color: var(--color-texto-tenue);
  font-size: 0.9rem;
}

/* Sujeto/objeto/posesivo/pron.posesivo -- 4 columnas iguales en vez de 3
   (números), mismo mecanismo de grilla única compartida. */
.gramatica-view__tabla-numeros--pronombres {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.gramatica-view__numero-palabra {
  background: none;
  border: none;
  text-align: left;
  font-size: 0.9rem;
  line-height: 1.25;
  cursor: pointer;
  min-width: 0;
  width: 100%;
  white-space: normal;
  overflow-wrap: break-word;
}

.gramatica-view__numero-palabra:disabled {
  opacity: 0.4;
  cursor: wait;
}

.gramatica-view__numero-palabra--sonando {
  color: var(--color-azul);
  font-weight: 700;
}

.gramatica-view__grupos-referencias {
  display: flex;
  flex-wrap: wrap;
  gap: 1.2rem;
  margin: 1rem 0;
}

.gramatica-view__grupo-referencia {
  flex: 1 1 220px;
  min-width: 200px;
}

.gramatica-view__grupo-titulo {
  font-size: 0.78rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-texto-tenue);
  margin: 0 0 0.5rem;
}

.gramatica-view__grid-referencias {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(64px, 1fr));
  gap: 0.5rem;
}

.gramatica-view__btn-referencia {
  background: white;
  border: 2px solid var(--color-borde);
  border-radius: var(--radio-card);
  padding: 0.7rem 0.4rem;
  font-size: 1.1rem;
  font-weight: 700;
  text-align: center;
  cursor: pointer;
}

.gramatica-view__btn-referencia:hover {
  border-color: #90caf9;
}

.gramatica-view__btn-referencia--sonando {
  border-color: var(--color-azul);
  background: #eef2f7;
}

.gramatica-view__btn-referencia:disabled {
  opacity: 0.4;
  cursor: wait;
}

.gramatica-view__referencia-numeral {
  display: block;
  font-size: 0.68rem;
  font-weight: 600;
  color: var(--color-azul);
  margin-top: 0.2rem;
}

.gramatica-view__btn-empezar-ejercicios {
  display: block;
  width: 100%;
  box-sizing: border-box;
  background: var(--color-azul);
  color: white;
  border: none;
  border-radius: var(--radio-boton);
  padding: 0.85rem;
  font-size: 1rem;
  cursor: pointer;
  margin-top: 0.5rem;
}

.gramatica-view__btn-empezar-ejercicios:disabled {
  background: var(--color-verde);
  opacity: 0.85;
  cursor: default;
}

.gramatica-view__progreso-examen {
  text-align: center;
  font-size: 0.8rem;
  color: var(--color-texto-tenue);
  margin-bottom: 0.5rem;
}

.gramatica-view__tarjeta {
  background: white;
  border-radius: 14px;
  border: 1px solid var(--color-borde);
  padding: 1.25rem;
  box-shadow: var(--sombra-card);
  max-width: 520px;
  margin: 0 auto;
}

.gramatica-view__tarjeta-tipo {
  display: inline-block;
  background: #eef2f7;
  color: var(--color-azul);
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  padding: 0.2rem 0.55rem;
  border-radius: 999px;
  margin-bottom: 0.6rem;
}

.gramatica-view__tarjeta-consigna {
  font-size: 0.85rem;
  color: var(--color-texto-secundario);
  margin: 0 0 0.6rem;
}

.gramatica-view__tarjeta-contexto {
  font-size: 1.15rem;
  line-height: 1.5;
  margin: 0 0 1rem;
}

.gramatica-view__hueco {
  display: inline-block;
  min-width: 3.5em;
  border-bottom: 2px solid var(--color-azul);
}

.gramatica-view__deletreo {
  text-align: center;
  margin: 0 0 1rem;
}

.gramatica-view__detectar-error-etiqueta {
  font-size: 0.88rem;
  color: var(--color-texto-tenue);
  margin: 0 0 0.75rem;
}

.gramatica-view__btn-deletreo {
  background: var(--color-azul);
  color: white;
  border: none;
  border-radius: var(--radio-boton);
  padding: 1rem 1.6rem;
  font-size: 1.15rem;
  cursor: pointer;
}

.gramatica-view__btn-deletreo:disabled {
  opacity: 0.7;
  cursor: wait;
}

.gramatica-view__conteo {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
  gap: 0.4rem;
  border: 2px dashed var(--color-borde);
  border-radius: var(--radio-card);
  padding: 1rem;
  margin: 0 0 1rem;
  min-height: 3rem;
}

.gramatica-view__conteo-emoji {
  font-size: 1.8rem;
  line-height: 1;
}

.gramatica-view__reloj {
  display: flex;
  justify-content: center;
  margin: 0 0 1rem;
}

.gramatica-view__reloj-esfera {
  position: relative;
  width: 150px;
  height: 150px;
  border-radius: 50%;
  background: white;
  border: 3px solid var(--color-azul);
  box-sizing: border-box;
}

.gramatica-view__reloj-marca {
  position: absolute;
  top: 6px;
  left: calc(50% - 1px);
  width: 2px;
  height: 8px;
  background: var(--color-texto-tenue);
  transform-origin: 50% 69px;
}

.gramatica-view__reloj-aguja {
  position: absolute;
  left: 50%;
  bottom: 50%;
  transform-origin: 50% 100%;
  border-radius: 3px;
}

.gramatica-view__reloj-aguja--hora {
  width: 5px;
  height: 40px;
  background: var(--color-azul);
}

.gramatica-view__reloj-aguja--minuto {
  width: 3px;
  height: 58px;
  background: var(--color-texto-secundario);
}

.gramatica-view__reloj-centro {
  position: absolute;
  top: 50%;
  left: 50%;
  width: 10px;
  height: 10px;
  transform: translate(-50%, -50%);
  border-radius: 50%;
  background: var(--color-azul);
}

.gramatica-view__conversacion {
  margin: 0 0 1rem;
  text-align: center;
}

.gramatica-view__chat {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin: 0.9rem 0;
  text-align: left;
}

.gramatica-view__burbuja {
  max-width: 82%;
  padding: 0.5rem 0.7rem;
  border-radius: 14px;
  border: none;
  font-size: 0.8rem;
  line-height: 1.3;
  cursor: pointer;
}

/* Un color por hablante (no verde/rojo -- ya significan correcto/incorrecto
   en el resto del módulo) para que se distinga de un vistazo quién habla,
   sin depender solo de la alineación izquierda/derecha. */
.gramatica-view__burbuja--a {
  align-self: flex-start;
  background: #e3f2fd;
  border-left: 3px solid var(--color-azul);
  border-bottom-left-radius: 4px;
}

.gramatica-view__burbuja--b {
  align-self: flex-end;
  background: #fff3e0;
  border-right: 3px solid #ef6c00;
  border-bottom-right-radius: 4px;
}

.gramatica-view__burbuja--sonando {
  outline: 2px solid var(--color-azul);
}

.gramatica-view__burbuja:disabled {
  opacity: 0.6;
  cursor: wait;
}

.gramatica-view__pregunta-conversacion {
  font-weight: 700;
  text-align: center;
}

.gramatica-view__opciones {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  margin-bottom: 0.75rem;
}

.gramatica-view__btn-opcion {
  width: 100%;
  box-sizing: border-box;
  text-align: left;
  padding: 0.7rem 0.9rem;
  font-size: 0.95rem;
  border: 2px solid var(--color-borde);
  border-radius: var(--radio-boton);
  background: white;
  cursor: pointer;
}

.gramatica-view__btn-opcion.seleccionada {
  border-color: var(--color-azul);
  background: #eef2f7;
}

.gramatica-view__btn-opcion:disabled {
  cursor: default;
}

.gramatica-view__btn-opcion.correcta {
  border-color: var(--color-verde);
  background: var(--color-verde-suave);
}

.gramatica-view__btn-opcion.incorrecta {
  border-color: var(--color-rojo-fuerte);
  background: var(--color-rojo-suave);
}

.gramatica-view__feedback {
  border-radius: var(--radio-boton);
  padding: 0.65rem 0.8rem;
  margin-bottom: 0.75rem;
  font-size: 0.9rem;
}

.gramatica-view__feedback--correcto {
  background: var(--color-verde-suave);
  border: 1px solid #a5d6a7;
  color: var(--color-verde);
}

.gramatica-view__feedback--incorrecto {
  background: var(--color-rojo-suave);
  border: 1px solid #f5c6cb;
  color: var(--color-rojo);
}

.gramatica-view__btn-comprobar {
  width: 100%;
  box-sizing: border-box;
  background: var(--color-azul);
  color: white;
  border: none;
  border-radius: var(--radio-boton);
  padding: 0.75rem;
  font-size: 0.95rem;
  cursor: pointer;
}

.gramatica-view__btn-comprobar:disabled {
  background: #90a4ae;
  cursor: default;
}

.gramatica-view__confianza {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.4rem;
  margin-bottom: 0.75rem;
}

.gramatica-view__confianza-etiqueta {
  font-size: 0.85rem;
  color: var(--color-texto-suave, #607d8b);
  width: 100%;
}

.gramatica-view__btn-confianza {
  background: var(--color-fondo-suave, #eceff1);
  border: 1px solid transparent;
  border-radius: var(--radio-boton);
  padding: 0.4rem 0.7rem;
  font-size: 0.85rem;
  cursor: pointer;
}

.gramatica-view__btn-confianza--activo {
  border-color: var(--color-azul);
  background: var(--color-azul-suave, #e3f2fd);
  font-weight: 600;
}

.gramatica-view__card-repaso {
  background: var(--color-azul-suave, #e3f2fd);
  border: 1px solid var(--color-azul);
  border-radius: var(--radio-boton);
  padding: 0.6rem 0.9rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
  font-weight: 600;
}

.gramatica-view__card-evolucion {
  background: #fff3e0;
  border-color: #ffa726;
  text-align: center;
}

.gramatica-view__link-cruces {
  display: block;
  width: 100%;
  box-sizing: border-box;
  text-align: left;
  background: none;
  border: 1px solid var(--color-borde);
  border-radius: var(--radio-boton);
  padding: 0.6rem 0.9rem;
  margin-bottom: 1rem;
  font-size: 0.9rem;
  cursor: pointer;
}

.gramatica-view__contenido-card--cruce {
  border-left: 4px solid #ab47bc;
}

.gramatica-view__cruce-vs {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  font-weight: 700;
  margin-bottom: 0.4rem;
}

.gramatica-view__cruce-vs-texto {
  color: #ab47bc;
  font-size: 0.8rem;
}

.gramatica-view__camino-gusanito {
  display: flex;
  flex-wrap: wrap;
  gap: 0.6rem;
  align-items: flex-end;
  padding: 1rem 0;
}

.gramatica-view__nodo-gusanito {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.2rem;
}

.gramatica-view__gusano-marcador {
  font-size: 1.4rem;
}

.gramatica-view__btn-nodo-gusanito {
  border: 2px solid var(--color-borde);
  border-radius: var(--radio-boton);
  padding: 0.6rem 0.8rem;
  font-size: 0.85rem;
  background: white;
  cursor: pointer;
  min-width: 110px;
}

.gramatica-view__nodo-gusanito--dominado .gramatica-view__btn-nodo-gusanito {
  border-color: var(--color-verde);
  background: var(--color-verde-suave);
}

.gramatica-view__nodo-gusanito--en_progreso .gramatica-view__btn-nodo-gusanito {
  border-color: #ffa726;
  background: #fff8ec;
}

.gramatica-view__nodo-gusanito--pendiente .gramatica-view__btn-nodo-gusanito {
  border-color: var(--color-borde);
  background: #f5f5f5;
}

.gramatica-view__estado-examen {
  min-height: 1.1rem;
  font-size: 0.85rem;
  color: var(--color-texto-secundario);
  text-align: center;
  margin-top: 0.5rem;
}

.gramatica-view__fin {
  text-align: center;
  padding: 2rem 1rem;
}

.gramatica-view__resumen-final {
  font-size: 1.4rem;
  font-weight: 700;
  margin: 0.5rem 0;
}

.gramatica-view__autoexplicacion {
  text-align: left;
  max-width: 480px;
  margin: 1rem auto;
}

.gramatica-view__autoexplicacion-etiqueta {
  font-size: 0.88rem;
  color: var(--color-texto-tenue);
  margin-bottom: 0.4rem;
}

.gramatica-view__autoexplicacion-textarea {
  width: 100%;
  box-sizing: border-box;
  min-height: 4.5rem;
  border: 1px solid var(--color-borde);
  border-radius: var(--radio-boton);
  padding: 0.6rem;
  font-family: inherit;
  font-size: 0.9rem;
  resize: vertical;
  margin-bottom: 0.5rem;
}

.gramatica-view__btn-autoexplicacion {
  background: var(--color-azul);
  color: white;
  border: none;
  border-radius: var(--radio-boton);
  padding: 0.6rem 1rem;
  font-size: 0.9rem;
  cursor: pointer;
}

.gramatica-view__btn-autoexplicacion:disabled {
  background: #90a4ae;
  cursor: default;
}

.gramatica-view__autoexplicacion-resultado {
  text-align: left;
  max-width: 480px;
  margin: 1rem auto;
}
</style>
