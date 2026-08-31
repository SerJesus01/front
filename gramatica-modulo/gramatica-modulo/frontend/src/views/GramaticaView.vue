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
import { computed, nextTick, ref, watch } from 'vue';
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
import ModalLesson from '../components/gramatica/modales/ModalLesson.vue';
import LocationLesson from '../components/gramatica/ubicacion/LocationLesson.vue';
import QuestionLesson from '../components/gramatica/preguntas/QuestionLesson.vue';
import GerundInfinitiveLesson from '../components/gramatica/gerundio/GerundInfinitiveLesson.vue';
import PossessiveLesson from '../components/gramatica/posesivos/PossessiveLesson.vue';
import AdvancedLesson from '../components/gramatica/avanzado/AdvancedLesson.vue';
import GrammarGameHub from '../components/gramatica/games/GrammarGameHub.vue';
import { useGrammarAudio } from '../composables/useGrammarAudio.js';
import { gramaticaApi } from '../services/gramaticaApi.js';

const pantallaActual = ref('perfiles'); // 'perfiles' | 'fases' | 'subtemas' | 'infantil-preview' | 'estudio' | 'ejercicios' | 'fin' | 'cruces'
const perfilStudentbook = ref(null); // 'adulto' | 'nino'

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
const modoModal = computed(() => ({
  'fase-8-can-could': 'can',
  'fase-8-must-have-to': 'obligation',
  'fase-8-should': 'should',
  'fase-8-would-like': 'would',
  'fase-8-imperativo': 'imperative',
})[subtemaActual.value?.slug] || null);
const modoUbicacion = computed(() => ({
  'fase-9-there-is-there-are': 'existence',
  'fase-9-ubicacion-basica': 'location',
})[subtemaActual.value?.slug] || null);
const modoPregunta = computed(() => ({
  'fase-10-wh-questions': 'wh',
  'fase-10-question-tags': 'tags',
  'fase-10-preguntas-indirectas': 'indirect',
})[subtemaActual.value?.slug] || null);
const modoGerundio = computed(() => ({
  'fase-11-verbo-ing': 'ing',
  'fase-11-verbo-to': 'to',
})[subtemaActual.value?.slug] || null);
const modoPosesivo = computed(() => ({
  'fase-12-reflexivos': 'reflexive',
  'fase-12-whose-mine-yours': 'pronouns',
  'fase-12-posesivo-s': 'apostrophe',
})[subtemaActual.value?.slug] || null);
const slugLeccionAvanzada = computed(() => /^fase-(1[3-7])-/.test(subtemaActual.value?.slug || '') ? subtemaActual.value.slug : null);
const usaLeccionEspecializada = computed(() => Boolean(
  esAbecedario.value || esNumeros.value || esFecha.value || esHora.value
  || esSaludos.value || esFamilia.value || esAbreviaturas.value || esFrutas.value
  || esToBe.value || esPronombres.value || esPresenteSimple.value
  || esPresenteContinuo.value || esContrastePresente.value || modoPasado.value
  || modoPerfecto.value || modoPasiva.value || modoFuturo.value || modoModal.value
  || modoUbicacion.value || modoPregunta.value || modoGerundio.value || modoPosesivo.value || slugLeccionAvanzada.value,
));

const _CAPITULOS = [
  { id: 'inicio', nombre: 'Primeros pasos', lema: 'Construí una base sólida', icono: '🌱', desde: 1, hasta: 4 },
  { id: 'tiempo', nombre: 'Moverse en el tiempo', lema: 'Conectá pasado, presente y futuro', icono: '⏳', desde: 5, hasta: 8 },
  { id: 'conexion', nombre: 'Ideas que se conectan', lema: 'Preguntá, ubicá y enlazá acciones', icono: '🧭', desde: 9, hasta: 13 },
  { id: 'fluidez', nombre: 'Expresión con fluidez', lema: 'Dale precisión y naturalidad a tus frases', icono: '✨', desde: 14, hasta: 17 },
];
const _CAPITULOS_NINO = [
  { id: 'inicio', nombre: 'Campamento de inicio', lema: 'Prepará tu mochila de palabras', icono: '⛺', desde: 1, hasta: 4 },
  { id: 'tiempo', nombre: 'Túnel del tiempo', lema: 'Viajá entre ayer, hoy y mañana', icono: '🚂', desde: 5, hasta: 8 },
  { id: 'conexion', nombre: 'Puente de las ideas', lema: 'Uní preguntas, lugares y acciones', icono: '🌉', desde: 9, hasta: 13 },
  { id: 'fluidez', nombre: 'Montaña de la fluidez', lema: 'Llegá a la cima con frases increíbles', icono: '🏔️', desde: 14, hasta: 17 },
];
const _ICONOS_FASE = ['🔤', '👋', '☀️', '📖', '🌉', '🔄', '🔮', '💬', '📍', '❓', '🧲', '🏷️', '🧺', '🎯', '🎨', '🔗', '🗺️'];
const _DESCRIPCIONES_FASE = [
  'Sonidos, números y palabras para empezar.', 'Personas, identidad y el verbo esencial.', 'Hábitos y acciones que ocurren ahora.',
  'Historias, recuerdos y acciones anteriores.', 'Experiencias que conectan con el presente.', 'Cambiá el foco de quien hace la acción.',
  'Planes, decisiones y posibilidades.', 'Habilidad, consejos, deseos y obligaciones.', 'Objetos, lugares y posiciones cotidianas.',
  'Preguntas naturales para conversar mejor.', 'Acciones como actividades o intenciones.', 'Personas, pertenencias y relaciones.',
  'Objetos que se cuentan o se miden.', 'Distancia, grupos y cantidades.', 'Descripciones, comparaciones y hábitos.',
  'Uní ideas y construí mensajes más completos.', 'Tiempo, espacio y movimiento.',
];
const _DESCRIPCIONES_NINO = [
  'Letras, números y primeras palabras mágicas.', 'Conocé a los personajes y contá quiénes son.', 'Descubrí hábitos y acciones en movimiento.',
  'Abrí el libro de los recuerdos.', 'Construí un puente entre antes y ahora.', 'Cambiá el protagonista de la historia.',
  'Imaginá planes y aventuras futuras.', 'Desbloqueá poderes, consejos y deseos.', 'Encontrá objetos escondidos en cada lugar.',
  'Usá preguntas para resolver misterios.', 'Jugá con acciones, gustos e intenciones.', 'Descubrí de quién es cada tesoro.',
  'Clasificá lo que podés contar y medir.', 'Señalá, elegí y compará cantidades.', 'Pintá tus frases con más detalles.',
  'Construí puentes entre una idea y otra.', 'Seguí pistas de tiempo, lugar y dirección.',
];
const _COLORES_FASE = [
  ['#b15f3b', '#fff0e7'], ['#39766a', '#e8f7f2'], ['#356f92', '#e8f4fa'], ['#735b9b', '#f2edfb'],
  ['#b06b33', '#fff3e4'], ['#39766a', '#e8f7f2'], ['#356f92', '#e8f4fa'], ['#735b9b', '#f2edfb'],
  ['#b15f3b', '#fff0e7'], ['#39766a', '#e8f7f2'], ['#356f92', '#e8f4fa'], ['#735b9b', '#f2edfb'],
  ['#b06b33', '#fff3e4'], ['#39766a', '#e8f7f2'], ['#356f92', '#e8f4fa'], ['#735b9b', '#f2edfb'], ['#b15f3b', '#fff0e7'],
];
const capitulosActivos = computed(() => perfilStudentbook.value === 'nino' ? _CAPITULOS_NINO : _CAPITULOS);
const capitulosFases = computed(() => capitulosActivos.value.map((capitulo) => ({
  ...capitulo,
  fases: fases.value.filter((fase) => fase.orden >= capitulo.desde && fase.orden <= capitulo.hasta),
})).filter((capitulo) => capitulo.fases.length));
const fasesCompletadas = computed(() => fases.value.filter((fase) => fase.completado).length);
const avanceFases = computed(() => fases.value.length ? Math.round((fasesCompletadas.value / fases.value.length) * 100) : 0);
const subtemasCompletados = computed(() => subtemas.value.filter((subtema) => subtema.completado).length);
const avanceSubtemas = computed(() => subtemas.value.length ? Math.round((subtemasCompletados.value / subtemas.value.length) * 100) : 0);

function metaFase(fase) {
  const indice = Math.max(0, (fase.orden || 1) - 1);
  return {
    icono: _ICONOS_FASE[indice] || '📘',
    descripcion: (perfilStudentbook.value === 'nino' ? _DESCRIPCIONES_NINO : _DESCRIPCIONES_FASE)[indice] || 'Una nueva parada en tu recorrido.',
    color: _COLORES_FASE[indice]?.[0] || '#356f92',
    suave: _COLORES_FASE[indice]?.[1] || '#e8f4fa',
  };
}

function elegirStudentbook(perfil) {
  perfilStudentbook.value = perfil;
  document.documentElement.dataset.studentbookTheme = perfil === 'nino' ? 'child' : 'adult';
  pantallaActual.value = 'fases';
}

function cambiarStudentbook() {
  perfilStudentbook.value = null;
  document.documentElement.dataset.studentbookTheme = 'adult';
  pantallaActual.value = 'perfiles';
}

async function elegirLeccionSegunPerfil(subtema) {
  if (perfilStudentbook.value === 'nino') {
    subtemaActual.value = subtema;
    pantallaActual.value = 'infantil-preview';
    return;
  }
  await elegirSubtema(subtema);
}

function iconoLeccion(slug = '') {
  const pistas = [
    [/abecedario|abreviaturas/, '🔤'], [/numeros|much-many|little-few|contables/, '🔢'], [/fecha|tiempo/, '🗓️'],
    [/hora/, '🕐'], [/saludos/, '👋'], [/familia|pronombres|reflexivos/, '👥'], [/frutas/, '🍎'], [/to-be|was-were/, '✨'],
    [/presente/, '☀️'], [/pasado/, '📖'], [/perfecto/, '🌉'], [/pasiva/, '🔄'], [/futuro|going-to|will-shall/, '🔮'],
    [/can-could|must|should|would|imperativo/, '💬'], [/ubicacion|there-is/, '📍'], [/preguntas|question|wh-questions/, '❓'],
    [/gerundio|verbo-ing/, '🧲'], [/verbo-to/, '🧭'], [/whose|posesivo/, '🏷️'], [/a-an-the/, '🎟️'], [/some-any/, '🫙'],
    [/this-that/, '📌'], [/every-all/, '🎯'], [/both-either/, '⚖️'], [/adjetivos|comparativos|superlativos/, '🎨'],
    [/adverbios/, '🎬'], [/conectores/, '🔗'], [/condicionales/, '🔀'], [/clausulas/, '🧷'], [/preposiciones/, '🗺️'],
  ];
  return pistas.find(([patron]) => patron.test(slug))?.[1] || '📘';
}

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
const avanceEjercicios = computed(() => ejercicios.value.length ? Math.round(((indice.value + 1) / ejercicios.value.length) * 100) : 0);

watch(pantallaActual, async () => {
  await nextTick();
  window.scrollTo({ top: 0, behavior: 'auto' });
});

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
    <section v-if="pantallaActual === 'perfiles'" class="gramatica-view__selector">
      <header><span>STUDENTBOOK</span><h1>¿Quién comienza la aventura?</h1><p>Elegí una experiencia. Podrás cambiarla cuando quieras sin perder tu recorrido.</p></header>
      <div class="gramatica-view__perfiles">
        <button class="gramatica-view__perfil gramatica-view__perfil--nino" @click="elegirStudentbook('nino')">
          <span class="gramatica-view__perfil-escena"><i>☁️</i><b>🛩️</b><em>🌈</em></span>
          <small>AVENTURA INFANTIL</small><strong>Studentbook para niños</strong><p>Misiones cortas, caminos visuales y recompensas.</p><span class="gramatica-view__perfil-accion">Explorar el mapa →</span>
        </button>
        <button class="gramatica-view__perfil gramatica-view__perfil--adulto" @click="elegirStudentbook('adulto')">
          <span class="gramatica-view__perfil-escena"><i>☕</i><b>🧭</b><em>📘</em></span>
          <small>APRENDIZAJE COTIDIANO</small><strong>Adulto estándar</strong><p>Ejemplos naturales, práctica guiada y progreso claro.</p><span class="gramatica-view__perfil-accion">Continuar el recorrido →</span>
        </button>
      </div>
      <aside>Los contenidos infantiles todavía están en construcción; este recorrido permite probar desde ahora toda su navegación exterior.</aside>
    </section>

    <div v-else-if="pantallaActual === 'fases'" :class="{ 'gramatica-view__modo-infantil': perfilStudentbook === 'nino' }">
      <button class="gramatica-view__cambiar-perfil" @click="cambiarStudentbook">↔ Cambiar Studentbook</button>
      <div class="gramatica-view__mapa-hero">
        <div><span class="gramatica-view__sobre">{{ perfilStudentbook === 'nino' ? 'MISIÓN: APRENDER INGLÉS' : 'TU AVENTURA EN INGLÉS' }}</span><h1>{{ perfilStudentbook === 'nino' ? 'El gran mapa de las palabras' : 'El mapa de la gramática' }}</h1><p>{{ perfilStudentbook === 'nino' ? 'Seguí el camino, superá misiones y hacé volar tu avioncito.' : 'Avanzá a tu ritmo. Cada parada abre una forma nueva de expresarte.' }}</p></div>
        <div class="gramatica-view__brujula"><span>🧭</span><b>{{ avanceFases }}%</b><small>del viaje</small></div>
      </div>
      <div v-if="totalVencidosRepaso > 0" class="gramatica-view__card-repaso">
        🔁 Repaso de hoy: {{ totalVencidosRepaso }}
      </div>
      <button class="gramatica-view__link-cruces" @click="abrirCentroJuegos">🐛 Alimentar y jugar con el Gusanito →</button>
      <button v-if="cruces.length > 0" class="gramatica-view__link-cruces" @click="pantallaActual = 'cruces'">🔀 Ver cruces entre reglas →</button>
      <p v-if="fases.length === 0" class="gramatica-view__subtitulo">Todavía no hay fases con contenido cargado.</p>
      <div v-else class="gramatica-view__mapa">
        <section v-for="(capitulo, capituloIndex) in capitulosFases" :key="capitulo.id" class="gramatica-view__capitulo">
          <header><span>{{ capitulo.icono }}</span><div><small>{{ perfilStudentbook === 'nino' ? 'ZONA' : 'CAPÍTULO' }} {{ String(capituloIndex + 1).padStart(2, '0') }}</small><h2>{{ capitulo.nombre }}</h2><p>{{ capitulo.lema }}</p></div></header>
          <div class="gramatica-view__sendero">
            <button
              v-for="f in capitulo.fases"
              :key="f.slug"
              class="gramatica-view__parada"
              :class="{ 'gramatica-view__parada--completada': f.completado, 'gramatica-view__parada--bloqueada': !f.disponible }"
              :style="{ '--item-accent': metaFase(f).color, '--item-soft': metaFase(f).suave }"
              :disabled="!f.disponible"
              :aria-label="`Abrir fase ${f.orden}: ${f.nombre}`"
              @click="elegirFase(f)"
            >
              <span class="gramatica-view__parada-numero">{{ String(f.orden).padStart(2, '0') }}</span>
              <span class="gramatica-view__parada-icono">{{ f.completado ? '✈️' : metaFase(f).icono }}</span>
              <span class="gramatica-view__parada-contenido"><small>{{ f.completado ? 'RUTA COMPLETADA' : (perfilStudentbook === 'nino' ? 'NUEVA MISIÓN' : 'SIGUIENTE PARADA') }}</small><strong>{{ f.nombre }}</strong><em>{{ metaFase(f).descripcion }}</em></span>
              <span class="gramatica-view__parada-flecha">{{ f.disponible ? '→' : '🔒' }}</span>
            </button>
          </div>
        </section>
      </div>
    </div>

    <div v-else-if="pantallaActual === 'subtemas'">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'fases'">← Fases</button>
      <div class="gramatica-view__lecciones-hero" :class="{ 'gramatica-view__lecciones-hero--infantil': perfilStudentbook === 'nino' }" :style="{ '--item-accent': metaFase(faseActual || {}).color, '--item-soft': metaFase(faseActual || {}).suave }">
        <span>{{ metaFase(faseActual || {}).icono }}</span>
        <div><small>{{ perfilStudentbook === 'nino' ? 'ZONA' : 'FASE' }} {{ String(faseActual?.orden || 0).padStart(2, '0') }}</small><h1>{{ faseActual?.nombre }}</h1><p>{{ metaFase(faseActual || {}).descripcion }}</p></div>
        <div class="gramatica-view__mini-progreso"><b>{{ subtemasCompletados }}/{{ subtemas.length }}</b><span><i :style="{ width: `${avanceSubtemas}%` }"></i></span><small>lecciones completas</small></div>
      </div>
      <div class="gramatica-view__ruta-lecciones" :style="{ '--item-accent': metaFase(faseActual || {}).color, '--item-soft': metaFase(faseActual || {}).suave }">
        <button
          v-for="(s, index) in subtemas"
          :key="s.slug"
          class="gramatica-view__leccion-parada"
          :class="{ 'gramatica-view__leccion-parada--completada': s.completado }"
          :aria-label="`Abrir ${perfilStudentbook === 'nino' ? 'misión' : 'lección'} ${index + 1}: ${s.nombre}`"
          @click="elegirLeccionSegunPerfil(s)"
        >
          <span class="gramatica-view__leccion-nodo">{{ s.completado ? '✈️' : iconoLeccion(s.slug) }}</span>
          <span class="gramatica-view__leccion-card"><small>{{ perfilStudentbook === 'nino' ? 'MISIÓN' : 'LECCIÓN' }} {{ String(index + 1).padStart(2, '0') }}</small><strong>{{ s.nombre }}</strong><em>{{ s.completado ? 'Lista para repasar' : (perfilStudentbook === 'nino' ? 'Una parada corta para aprender jugando' : 'Explorá, construí y practicá') }}</em></span>
          <span class="gramatica-view__leccion-accion">{{ s.completado ? 'Repasar' : (perfilStudentbook === 'nino' ? 'Ver misión' : 'Comenzar') }} →</span>
        </button>
      </div>
    </div>

    <section v-else-if="pantallaActual === 'infantil-preview'" class="gramatica-view__mision-preview">
      <button class="gramatica-view__link-volver" @click="pantallaActual = 'subtemas'">← Volver al camino</button>
      <article>
        <span>{{ iconoLeccion(subtemaActual?.slug) }}</span><small>MISIÓN EN PREPARACIÓN</small><h1>{{ subtemaActual?.nombre }}</h1><p>El camino y la entrada ya están listos. En la siguiente etapa construiremos aquí la explicación, el juego y el workbook especiales para niños.</p><div><b>🗺️ Ruta conectada</b><b>🎨 Tema infantil activo</b><b>🔒 Sin contenido adulto</b></div>
      </article>
    </section>

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

      <div v-if="contenidoReglas.length > 0 && !esSaludos && !esFamilia && !esAbreviaturas && !esFrutas && !esToBe && !esPronombres && !esPresenteSimple && !esPresenteContinuo && !esContrastePresente && !modoPasado && !modoPerfecto && !modoPasiva && !modoFuturo && !modoModal && !modoUbicacion && !modoPregunta && !modoGerundio && !modoPosesivo && !slugLeccionAvanzada" class="gramatica-view__lista-contenido">
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

      <ModalLesson
        v-else-if="modoModal"
        :mode="modoModal"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <LocationLesson
        v-else-if="modoUbicacion"
        :mode="modoUbicacion"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <QuestionLesson
        v-else-if="modoPregunta"
        :mode="modoPregunta"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <GerundInfinitiveLesson
        v-else-if="modoGerundio"
        :mode="modoGerundio"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <PossessiveLesson
        v-else-if="modoPosesivo"
        :mode="modoPosesivo"
        :completado="Boolean(subtemaActual?.completado)"
        @hablar="reproducirTexto"
        @practicar="empezarEjercicios"
      />

      <AdvancedLesson
        v-else-if="slugLeccionAvanzada"
        :slug="slugLeccionAvanzada"
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

    <section v-else-if="pantallaActual === 'ejercicios'" class="gramatica-view__workbook">
      <button v-if="!modoCruce && !modoGusanito" class="gramatica-view__link-volver gramatica-view__workbook-volver" @click="pantallaActual = 'estudio'">← Volver al Studentbook</button>
      <header class="gramatica-view__workbook-hero">
        <span class="gramatica-view__workbook-icono">✏️</span>
        <div><small>WORKBOOK · PRÁCTICA GUIADA</small><h1>{{ subtemaActual?.nombre }}</h1><p>Elegí tu respuesta y marcá qué tan seguro estás antes de comprobar.</p></div>
        <strong>{{ indice + 1 }}<i>/{{ ejercicios.length }}</i></strong>
      </header>
      <div class="gramatica-view__barra-examen"><i :style="{ width: `${avanceEjercicios}%` }"></i><span>{{ avanceEjercicios }}% del cuestionario</span></div>

      <div v-if="itemActual" class="gramatica-view__tarjeta">
        <div class="gramatica-view__pregunta-cabecera"><span class="gramatica-view__tarjeta-tipo">{{ itemActual.formato === 'detectar_error' ? 'Detectá el error' : (ETIQUETAS_TIPO[itemActual.tipo] || itemActual.tipo) }}</span><small>PREGUNTA {{ String(indice + 1).padStart(2, '0') }}</small></div>
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
          ><span class="gramatica-view__opcion-letra">{{ String.fromCharCode(65 + idx) }}</span><span>{{ opcion }}</span><span class="gramatica-view__opcion-marca">{{ respuestaSeleccionada === opcion ? '●' : '○' }}</span></button>
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

        <div class="gramatica-view__acciones-workbook">
          <span v-if="!respuestaSeleccionada">Elegí una opción para continuar</span>
          <span v-else-if="!confianzaSeleccionada && !respondido">Ahora indicá tu confianza</span>
          <span v-else>{{ respondido ? 'Respuesta registrada' : 'Todo listo para comprobar' }}</span>
          <button
            v-if="!respondido"
            class="gramatica-view__btn-comprobar"
            :disabled="!respuestaSeleccionada || !confianzaSeleccionada || comprobando"
            @click="comprobarRespuesta"
          >{{ comprobando ? 'Comprobando...' : 'Comprobar respuesta →' }}</button>
          <button v-else class="gramatica-view__btn-comprobar" @click="siguienteEjercicio">
            {{ indice + 1 < ejercicios.length ? 'Siguiente ejercicio →' : 'Terminar práctica ✓' }}
          </button>
        </div>
      </div>

      <div class="gramatica-view__estado-examen">{{ estadoExamen }}</div>
    </section>

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

.gramatica-view__selector { max-width: 820px; margin: 0 auto; padding: 1rem; }
.gramatica-view__selector > header { max-width: 610px; margin: 0 auto 1.25rem; text-align: center; }
.gramatica-view__selector > header > span { color: #356f92; font-size: .68rem; font-weight: 900; letter-spacing: .14em; }
.gramatica-view__selector > header h1 { margin: .25rem 0; font-size: clamp(1.5rem,4vw,2.15rem); }
.gramatica-view__selector > header p { margin: 0; color: var(--color-texto-secundario); }
.gramatica-view__perfiles { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: 1rem; }
.gramatica-view__perfil { display: flex; min-height: 300px; flex-direction: column; align-items: flex-start; overflow: hidden; padding: 1.2rem; border: 1px solid var(--color-borde); border-radius: 26px; color: inherit; cursor: pointer; text-align: left; box-shadow: 0 12px 30px rgba(49,68,85,.09); transition: transform .22s ease,box-shadow .22s ease; }
.gramatica-view__perfil:hover { box-shadow: 0 18px 35px rgba(49,68,85,.14); transform: translateY(-5px); }
.gramatica-view__perfil--nino { background: linear-gradient(145deg,#e8f8ff,#fff1c9 60%,#e5f8ed); }
.gramatica-view__perfil--adulto { background: linear-gradient(145deg,#e8f4fa,#f2edfb 60%,#fff); }
.gramatica-view__perfil-escena { position: relative; display: flex; align-items: center; justify-content: space-around; width: 100%; min-height: 118px; margin-bottom: 1rem; border-radius: 20px; background: rgba(255,255,255,.65); font-style: normal; }
.gramatica-view__perfil-escena::after { content: ''; position: absolute; right: 8%; bottom: 18px; left: 8%; height: 3px; border-radius: 4px; background: repeating-linear-gradient(90deg,rgba(53,111,146,.3) 0 9px,transparent 9px 15px); }
.gramatica-view__perfil-escena i,.gramatica-view__perfil-escena b,.gramatica-view__perfil-escena em { position: relative; z-index: 1; font-size: 2.2rem; font-style: normal; }
.gramatica-view__perfil-escena b { font-size: 3.2rem; animation: perfil-flota 2.8s ease-in-out infinite; }
@keyframes perfil-flota { 50% { transform: translateY(-7px) rotate(3deg); } }
.gramatica-view__perfil > small { color: #356f92; font-size: .61rem; font-weight: 900; letter-spacing: .1em; }
.gramatica-view__perfil > strong { margin: .2rem 0; font-size: 1.18rem; }
.gramatica-view__perfil > p { margin: 0; color: var(--color-texto-secundario); font-size: .78rem; }
.gramatica-view__perfil-accion { align-self: stretch; margin-top: auto; padding-top: 1rem; color: #356f92; font-size: .76rem; font-weight: 900; text-align: right; }
.gramatica-view__selector > aside { margin-top: 1rem; padding: .7rem; border-radius: 12px; background: var(--color-fondo-suave); color: var(--color-texto-secundario); font-size: .72rem; text-align: center; }
.gramatica-view__cambiar-perfil { margin-bottom: .7rem; padding: .42rem .7rem; border: 1px solid var(--color-borde); border-radius: 999px; background: var(--color-superficie); color: var(--color-texto-secundario); cursor: pointer; font-size: .7rem; }

.gramatica-view__modo-infantil .gramatica-view__mapa-hero { position: relative; background: radial-gradient(circle at 18% 25%,rgba(255,255,255,.95) 0 4px,transparent 5px),radial-gradient(circle at 78% 18%,rgba(255,255,255,.9) 0 7px,transparent 8px),linear-gradient(145deg,#dff7ff,#fff1c9 55%,#e5f8ed); }
.gramatica-view__modo-infantil .gramatica-view__mapa-hero::after { content: '🌳  🌲  🌳'; position: absolute; right: 1rem; bottom: -.3rem; opacity: .45; font-size: 1.45rem; letter-spacing: .35rem; }
.gramatica-view__modo-infantil .gramatica-view__capitulo { border-width: 2px; box-shadow: var(--sombra-card); }
.gramatica-view__modo-infantil .gramatica-view__capitulo > header { background: linear-gradient(90deg,#e5f8ed,rgba(255,255,255,.4)); }
.gramatica-view__modo-infantil .gramatica-view__parada { border-width: 2px; }
.gramatica-view__lecciones-hero--infantil { border-width: 2px; background: linear-gradient(135deg,var(--item-soft),#fff1c9 60%,#fff); }

.gramatica-view__mision-preview { max-width: 680px; margin: 0 auto; padding: .5rem 1rem 2rem; }
.gramatica-view__mision-preview article { display: flex; min-height: 430px; flex-direction: column; align-items: center; justify-content: center; margin-top: .8rem; padding: 1.5rem; border: 2px solid var(--color-borde); border-radius: 30px; background: radial-gradient(circle at 15% 18%,#fff 0 5px,transparent 6px),radial-gradient(circle at 84% 25%,#fff 0 8px,transparent 9px),linear-gradient(145deg,#dff7ff,#fff1c9 58%,#e5f8ed); box-shadow: var(--sombra-card); text-align: center; }
.gramatica-view__mision-preview article > span { display: grid; place-items: center; width: 100px; height: 100px; margin-bottom: .8rem; border: 4px solid white; border-radius: 50%; background: #3478e5; box-shadow: 0 0 0 3px #3478e5,0 12px 28px rgba(47,73,125,.2); font-size: 3rem; }
.gramatica-view__mision-preview article > small { color: #3478e5; font-size: .65rem; font-weight: 900; letter-spacing: .12em; }
.gramatica-view__mision-preview h1 { margin: .25rem 0; font-size: 1.55rem; }
.gramatica-view__mision-preview p { max-width: 520px; margin: .25rem 0 1rem; color: var(--color-texto-secundario); }
.gramatica-view__mision-preview article > div { display: flex; flex-wrap: wrap; justify-content: center; gap: .5rem; }
.gramatica-view__mision-preview article > div b { padding: .45rem .65rem; border: 1px solid rgba(52,120,229,.18); border-radius: 999px; background: rgba(255,255,255,.72); color: #2256ad; font-size: .7rem; }

.gramatica-view__mapa-hero {
  display: grid;
  grid-template-columns: 1fr auto;
  align-items: center;
  gap: 1rem;
  overflow: hidden;
  padding: 1.25rem;
  border: 1px solid var(--color-borde);
  border-radius: 24px;
  background:
    radial-gradient(circle at 15% 20%, rgba(255,255,255,.9) 0 2px, transparent 3px),
    radial-gradient(circle at 80% 70%, rgba(255,255,255,.8) 0 3px, transparent 4px),
    linear-gradient(135deg, #e8f4fa, #f2edfb 52%, #fff3e4);
}

.gramatica-view__sobre,
.gramatica-view__mapa-hero small {
  color: #356f92;
  font-size: .66rem;
  font-weight: 900;
  letter-spacing: .12em;
}

.gramatica-view__mapa-hero h1 {
  margin: .15rem 0;
  font-size: clamp(1.45rem, 4vw, 2.2rem);
}

.gramatica-view__mapa-hero p {
  max-width: 560px;
  margin: .2rem 0;
  color: var(--color-texto-secundario);
}

.gramatica-view__brujula {
  display: grid;
  place-items: center;
  width: 104px;
  height: 104px;
  border: 2px solid rgba(53,111,146,.25);
  border-radius: 50%;
  background: rgba(255,255,255,.72);
  box-shadow: 0 12px 30px rgba(53,111,146,.12);
}

.gramatica-view__brujula span { font-size: 1.7rem; line-height: 1; }
.gramatica-view__brujula b { color: #356f92; font-size: 1.2rem; line-height: 1; }
.gramatica-view__brujula small { font-size: .58rem; letter-spacing: .04em; }

.gramatica-view__mapa {
  display: grid;
  gap: 1.2rem;
  margin-top: 1.1rem;
}

.gramatica-view__capitulo {
  overflow: hidden;
  border: 1px solid var(--color-borde);
  border-radius: 22px;
  background: var(--color-superficie);
  box-shadow: 0 10px 30px rgba(49,68,85,.06);
}

.gramatica-view__capitulo > header {
  display: flex;
  align-items: center;
  gap: .75rem;
  padding: .9rem 1rem;
  border-bottom: 1px solid var(--color-borde);
  background: linear-gradient(90deg, rgba(53,111,146,.08), transparent);
}

.gramatica-view__capitulo > header > span { font-size: 2rem; }
.gramatica-view__capitulo header small { color: #356f92; font-size: .6rem; font-weight: 900; letter-spacing: .1em; }
.gramatica-view__capitulo h2 { margin: .08rem 0; font-size: 1rem; }
.gramatica-view__capitulo header p { margin: 0; color: var(--color-texto-secundario); font-size: .75rem; }

.gramatica-view__sendero {
  position: relative;
  display: grid;
  gap: .75rem;
  padding: 1rem;
}

.gramatica-view__sendero::before {
  content: '';
  position: absolute;
  top: 1rem;
  bottom: 1rem;
  left: 51px;
  width: 3px;
  border-radius: 3px;
  background: repeating-linear-gradient(to bottom, #b7cbd6 0 8px, transparent 8px 14px);
}

.gramatica-view__parada {
  --item-accent: #356f92;
  --item-soft: #e8f4fa;
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: 32px 58px 1fr auto;
  align-items: center;
  gap: .7rem;
  width: 100%;
  padding: .72rem .85rem;
  border: 1px solid var(--color-borde);
  border-radius: 17px;
  background: linear-gradient(105deg, var(--item-soft), var(--color-superficie) 58%);
  box-shadow: 0 6px 18px rgba(49,68,85,.06);
  color: inherit;
  cursor: pointer;
  text-align: left;
  transition: transform .2s ease, border-color .2s ease, box-shadow .2s ease;
}

.gramatica-view__parada:nth-child(even) { transform: translateX(16px); width: calc(100% - 16px); }
.gramatica-view__parada:hover { transform: translateY(-3px); border-color: var(--item-accent); box-shadow: 0 12px 24px rgba(49,68,85,.12); }
.gramatica-view__parada:nth-child(even):hover { transform: translate(16px,-3px); }
.gramatica-view__parada-numero { color: var(--item-accent); font-size: .72rem; font-weight: 900; }
.gramatica-view__parada-icono { display: grid; place-items: center; width: 52px; height: 52px; border: 3px solid var(--color-superficie); border-radius: 50%; background: var(--item-accent); box-shadow: 0 0 0 2px var(--item-accent); font-size: 1.45rem; }
.gramatica-view__parada-contenido { display: flex; min-width: 0; flex-direction: column; }
.gramatica-view__parada-contenido small { color: var(--item-accent); font-size: .57rem; font-weight: 900; letter-spacing: .08em; }
.gramatica-view__parada-contenido strong { margin: .1rem 0; font-size: .9rem; }
.gramatica-view__parada-contenido em { overflow: hidden; color: var(--color-texto-secundario); font-size: .7rem; font-style: normal; text-overflow: ellipsis; white-space: nowrap; }
.gramatica-view__parada-flecha { color: var(--item-accent); font-size: 1.1rem; font-weight: 900; }
.gramatica-view__parada--completada { border-color: var(--color-verde); background: linear-gradient(105deg, var(--color-verde-suave), var(--color-superficie)); }
.gramatica-view__parada--completada .gramatica-view__parada-icono { background: var(--color-verde); box-shadow: 0 0 0 2px var(--color-verde); animation: avion-aterriza .45s ease-out; }
.gramatica-view__parada--bloqueada { opacity: .55; cursor: default; }

@keyframes avion-aterriza {
  from { opacity: 0; transform: translate(18px,-12px) rotate(-12deg); }
  to { opacity: 1; transform: translate(0) rotate(0); }
}

.gramatica-view__lecciones-hero {
  display: grid;
  grid-template-columns: auto 1fr auto;
  align-items: center;
  gap: 1rem;
  margin-top: .8rem;
  padding: 1rem;
  border: 1px solid var(--color-borde);
  border-radius: 22px;
  background: linear-gradient(135deg, var(--item-soft), var(--color-superficie));
}

.gramatica-view__lecciones-hero > span { font-size: 2.8rem; }
.gramatica-view__lecciones-hero small { color: var(--item-accent); font-size: .62rem; font-weight: 900; letter-spacing: .1em; }
.gramatica-view__lecciones-hero h1 { margin: .1rem 0; font-size: 1.25rem; }
.gramatica-view__lecciones-hero p { margin: 0; color: var(--color-texto-secundario); font-size: .78rem; }
.gramatica-view__mini-progreso { display: grid; min-width: 130px; gap: .25rem; text-align: right; }
.gramatica-view__mini-progreso b { color: var(--item-accent); font-size: 1.1rem; }
.gramatica-view__mini-progreso > span { overflow: hidden; width: 130px; height: 7px; border-radius: 8px; background: rgba(49,68,85,.12); }
.gramatica-view__mini-progreso i { display: block; height: 100%; border-radius: inherit; background: var(--item-accent); transition: width .35s ease; }
.gramatica-view__mini-progreso small { letter-spacing: 0; }

.gramatica-view__ruta-lecciones {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: .85rem;
  margin: 1.2rem auto;
  padding: .25rem 0;
}

.gramatica-view__ruta-lecciones::before {
  content: '';
  position: absolute;
  top: 0;
  bottom: 0;
  left: 50%;
  width: 4px;
  border-radius: 4px;
  background: repeating-linear-gradient(to bottom, var(--item-accent, #8eb5c9) 0 10px, transparent 10px 17px);
  opacity: .35;
  transform: translateX(-50%);
}

.gramatica-view__leccion-parada {
  position: relative;
  z-index: 1;
  display: grid;
  grid-template-columns: auto 1fr;
  align-items: center;
  gap: .7rem;
  width: calc(50% - 30px);
  padding: .7rem;
  border: 1px solid var(--color-borde);
  border-radius: 17px;
  background: var(--color-superficie);
  box-shadow: 0 8px 20px rgba(49,68,85,.08);
  color: inherit;
  cursor: pointer;
  text-align: left;
  transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease;
}

.gramatica-view__leccion-parada:nth-child(even) { align-self: flex-end; }
.gramatica-view__leccion-parada::after { content: ''; position: absolute; top: 50%; right: -34px; width: 34px; height: 2px; background: var(--color-borde); }
.gramatica-view__leccion-parada:nth-child(even)::after { right: auto; left: -34px; }
.gramatica-view__leccion-parada:hover { border-color: var(--item-accent); box-shadow: 0 12px 25px rgba(49,68,85,.13); transform: translateY(-3px); }
.gramatica-view__leccion-nodo { display: grid; place-items: center; width: 48px; height: 48px; border-radius: 15px; background: var(--item-soft); font-size: 1.4rem; transform: rotate(-3deg); }
.gramatica-view__leccion-card { display: flex; min-width: 0; flex-direction: column; }
.gramatica-view__leccion-card small { color: var(--item-accent); font-size: .56rem; font-weight: 900; letter-spacing: .08em; }
.gramatica-view__leccion-card strong { margin: .12rem 0; font-size: .82rem; }
.gramatica-view__leccion-card em { color: var(--color-texto-secundario); font-size: .65rem; font-style: normal; }
.gramatica-view__leccion-accion { grid-column: 1/-1; color: var(--item-accent); font-size: .66rem; font-weight: 900; text-align: right; }
.gramatica-view__leccion-parada--completada { border-color: var(--color-verde); background: linear-gradient(135deg, var(--color-verde-suave), var(--color-superficie)); }
.gramatica-view__leccion-parada--completada .gramatica-view__leccion-nodo { background: var(--color-verde-suave); animation: avion-aterriza .45s ease-out; }

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

/* Workbook: una superficie propia, coherente con el mapa y el Studentbook. */
.gramatica-view__workbook { max-width: 780px; margin: 0 auto; padding: .25rem 1rem 2rem; }
.gramatica-view__workbook-volver { display: inline-flex; margin-bottom: .8rem; }
.gramatica-view__workbook-hero { display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: 1rem; padding: 1rem 1.15rem; border: 1px solid var(--color-borde); border-radius: 22px; background: linear-gradient(135deg,#e8f4fa,#f2edfb 55%,#fff3e4); }
.gramatica-view__workbook-icono { display: grid; place-items: center; width: 58px; height: 58px; border-radius: 18px; background: rgba(255,255,255,.78); box-shadow: 0 7px 20px rgba(49,68,85,.1); font-size: 1.75rem; transform: rotate(-3deg); }
.gramatica-view__workbook-hero small { color: #356f92; font-size: .62rem; font-weight: 900; letter-spacing: .1em; }
.gramatica-view__workbook-hero h1 { margin: .12rem 0; font-size: 1.25rem; }
.gramatica-view__workbook-hero p { margin: 0; color: var(--color-texto-secundario); font-size: .76rem; }
.gramatica-view__workbook-hero > strong { display: flex; align-items: baseline; justify-content: center; width: 60px; height: 60px; border: 2px solid rgba(53,111,146,.25); border-radius: 50%; background: rgba(255,255,255,.72); color: #356f92; font-size: 1.3rem; line-height: 60px; }
.gramatica-view__workbook-hero > strong i { font-size: .68rem; font-style: normal; }
.gramatica-view__barra-examen { position: relative; overflow: hidden; height: 9px; margin: .7rem .5rem 1rem; border-radius: 10px; background: rgba(53,111,146,.12); }
.gramatica-view__barra-examen i { display: block; height: 100%; border-radius: inherit; background: linear-gradient(90deg,#356f92,#735b9b); transition: width .35s ease; }
.gramatica-view__barra-examen span { position: absolute; overflow: hidden; width: 1px; height: 1px; clip: rect(0 0 0 0); }
.gramatica-view__workbook .gramatica-view__tarjeta { max-width: 680px; margin: 0 auto; padding: clamp(1rem,3vw,1.8rem); border-radius: 22px; background: var(--color-superficie); box-shadow: 0 14px 38px rgba(49,68,85,.09); }
.gramatica-view__pregunta-cabecera { display: flex; align-items: center; justify-content: space-between; gap: .7rem; margin-bottom: .85rem; }
.gramatica-view__pregunta-cabecera .gramatica-view__tarjeta-tipo { margin-bottom: 0; }
.gramatica-view__pregunta-cabecera > small { color: var(--color-texto-tenue); font-size: .6rem; font-weight: 900; letter-spacing: .09em; }
.gramatica-view__workbook .gramatica-view__tarjeta-consigna { max-width: 560px; margin: 0 0 1rem; color: var(--color-texto-secundario); font-size: .92rem; font-weight: 650; }
.gramatica-view__workbook .gramatica-view__tarjeta-contexto { padding: .85rem; border-radius: 14px; background: linear-gradient(135deg,#f6f9fb,#fff); font-size: 1.2rem; text-align: center; }
.gramatica-view__workbook .gramatica-view__opciones { display: grid; grid-template-columns: repeat(2,minmax(0,1fr)); gap: .65rem; margin: .4rem 0 1rem; }
.gramatica-view__workbook .gramatica-view__btn-opcion { display: grid; grid-template-columns: auto 1fr auto; align-items: center; gap: .7rem; min-height: 58px; padding: .65rem .75rem; border: 1px solid var(--color-borde); border-radius: 14px; background: var(--color-superficie); transition: transform .18s ease,border-color .18s ease,box-shadow .18s ease; }
.gramatica-view__workbook .gramatica-view__btn-opcion:hover:not(:disabled) { border-color: #90b8cd; box-shadow: 0 7px 17px rgba(49,68,85,.08); transform: translateY(-2px); }
.gramatica-view__opcion-letra { display: grid; place-items: center; width: 30px; height: 30px; border-radius: 9px; background: #eef2f7; color: var(--color-azul); font-size: .72rem; font-weight: 900; }
.gramatica-view__opcion-marca { color: #aab7be; font-size: .9rem; }
.gramatica-view__workbook .gramatica-view__btn-opcion.seleccionada { background: #f0f7fb; box-shadow: 0 0 0 2px rgba(53,111,146,.1); }
.gramatica-view__btn-opcion.seleccionada .gramatica-view__opcion-letra { background: var(--color-azul); color: white; }
.gramatica-view__btn-opcion.seleccionada .gramatica-view__opcion-marca { color: var(--color-azul); }
.gramatica-view__btn-opcion.correcta .gramatica-view__opcion-letra { background: var(--color-verde); color: white; }
.gramatica-view__btn-opcion.incorrecta .gramatica-view__opcion-letra { background: var(--color-rojo-fuerte); color: white; }
.gramatica-view__workbook .gramatica-view__confianza { display: grid; grid-template-columns: repeat(3,1fr); gap: .5rem; padding: .75rem; border: 1px solid var(--color-borde); border-radius: 14px; background: #f7f9fa; }
.gramatica-view__workbook .gramatica-view__confianza-etiqueta { grid-column: 1/-1; font-size: .72rem; font-weight: 800; }
.gramatica-view__workbook .gramatica-view__btn-confianza { min-height: 42px; border: 1px solid transparent; border-radius: 11px; }
.gramatica-view__workbook .gramatica-view__btn-confianza--activo { border-color: var(--color-azul); background: var(--color-superficie); box-shadow: 0 5px 14px rgba(49,68,85,.08); }
.gramatica-view__acciones-workbook { display: grid; grid-template-columns: 1fr auto; align-items: center; gap: .8rem; margin-top: .8rem; padding-top: .9rem; border-top: 1px solid var(--color-borde); }
.gramatica-view__acciones-workbook > span { color: var(--color-texto-tenue); font-size: .7rem; }
.gramatica-view__acciones-workbook .gramatica-view__btn-comprobar { width: auto; min-width: 220px; padding: .78rem 1rem; border-radius: 12px; font-weight: 800; }
.gramatica-view__acciones-workbook .gramatica-view__btn-comprobar:not(:disabled) { background: linear-gradient(135deg,#356f92,#735b9b); box-shadow: 0 8px 18px rgba(53,111,146,.2); }

@media (max-width: 720px) {
  .gramatica-view__selector { padding: .5rem; }
  .gramatica-view__perfiles { grid-template-columns: 1fr; }
  .gramatica-view__perfil { min-height: 245px; }
  .gramatica-view__perfil-escena { min-height: 90px; }
  .gramatica-view__workbook { padding-inline: .35rem; }
  .gramatica-view__workbook-hero { grid-template-columns: auto 1fr; padding: .85rem; }
  .gramatica-view__workbook-hero > strong { grid-column: 1/-1; width: 100%; height: auto; padding: .35rem 0; border-radius: 10px; line-height: 1; }
  .gramatica-view__workbook .gramatica-view__opciones { grid-template-columns: 1fr; }
  .gramatica-view__acciones-workbook { grid-template-columns: 1fr; }
  .gramatica-view__acciones-workbook .gramatica-view__btn-comprobar { width: 100%; min-width: 0; }
  .gramatica-view__mapa-hero { grid-template-columns: 1fr auto; padding: 1rem; }
  .gramatica-view__brujula { width: 82px; height: 82px; }
  .gramatica-view__parada:nth-child(even),
  .gramatica-view__parada:nth-child(even):hover { width: 100%; transform: translateY(-3px); }
  .gramatica-view__lecciones-hero { grid-template-columns: auto 1fr; }
  .gramatica-view__mini-progreso { grid-column: 1/-1; width: 100%; text-align: left; }
  .gramatica-view__mini-progreso > span { width: 100%; }
  .gramatica-view__ruta-lecciones::before { left: 26px; transform: none; }
  .gramatica-view__leccion-parada,
  .gramatica-view__leccion-parada:nth-child(even) { align-self: flex-end; width: calc(100% - 60px); }
  .gramatica-view__leccion-parada::after,
  .gramatica-view__leccion-parada:nth-child(even)::after { right: auto; left: -34px; }
}

@media (max-width: 480px) {
  .gramatica-view__selector > header p { font-size: .8rem; }
  .gramatica-view__perfil { padding: .9rem; }
  .gramatica-view__mision-preview { padding-inline: .35rem; }
  .gramatica-view__mision-preview article { min-height: 380px; padding: 1rem; }
  .gramatica-view__workbook-hero { grid-template-columns: 1fr; text-align: center; }
  .gramatica-view__workbook-icono { margin: auto; }
  .gramatica-view__workbook .gramatica-view__confianza { grid-template-columns: 1fr; }
  .gramatica-view__workbook .gramatica-view__confianza-etiqueta { grid-column: auto; }
  .gramatica-view__mapa-hero { grid-template-columns: 1fr; text-align: center; }
  .gramatica-view__brujula { margin: auto; }
  .gramatica-view__capitulo > header { align-items: flex-start; }
  .gramatica-view__sendero { padding: .75rem; }
  .gramatica-view__sendero::before { left: 40px; }
  .gramatica-view__parada { grid-template-columns: 24px 46px 1fr; gap: .55rem; padding: .62rem; }
  .gramatica-view__parada-icono { width: 40px; height: 40px; font-size: 1.15rem; }
  .gramatica-view__parada-flecha { display: none; }
  .gramatica-view__parada-contenido em { white-space: normal; }
  .gramatica-view__lecciones-hero > span { font-size: 2.2rem; }
  .gramatica-view__leccion-parada,
  .gramatica-view__leccion-parada:nth-child(even) { width: calc(100% - 48px); }
  .gramatica-view__leccion-card em { display: none; }
}
</style>
