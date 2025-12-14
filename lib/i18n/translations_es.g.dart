///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'translations.g.dart';

// Path: <root>
class TranslationsEs extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEs({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEs _root = this; // ignore: unused_field

	@override 
	TranslationsEs $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEs(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppEs app = _TranslationsAppEs._(_root);
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsAuthEs auth = _TranslationsAuthEs._(_root);
	@override late final _TranslationsNavEs nav = _TranslationsNavEs._(_root);
	@override late final _TranslationsNotesEs notes = _TranslationsNotesEs._(_root);
	@override late final _TranslationsDrawingEs drawing = _TranslationsDrawingEs._(_root);
	@override late final _TranslationsPaperEs paper = _TranslationsPaperEs._(_root);
	@override late final _TranslationsAiEs ai = _TranslationsAiEs._(_root);
	@override late final _TranslationsPdfEs pdf = _TranslationsPdfEs._(_root);
	@override late final _TranslationsSettingsEs settings = _TranslationsSettingsEs._(_root);
	@override late final _TranslationsErrorsEs errors = _TranslationsErrorsEs._(_root);
	@override late final _TranslationsOnboardingEs onboarding = _TranslationsOnboardingEs._(_root);
	@override late final _TranslationsEditorEs editor = _TranslationsEditorEs._(_root);
	@override late final _TranslationsPdfDialogEs pdfDialog = _TranslationsPdfDialogEs._(_root);
}

// Path: app
class _TranslationsAppEs extends TranslationsAppDe {
	_TranslationsAppEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Tus notas, a tu manera';
}

// Path: common
class _TranslationsCommonEs extends TranslationsCommonDe {
	_TranslationsCommonEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
	@override String get delete => 'Eliminar';
	@override String get edit => 'Editar';
	@override String get close => 'Cerrar';
	@override String get confirm => 'Confirmar';
	@override String get loading => 'Cargando...';
	@override String get error => 'Error';
	@override String get success => 'Exitoso';
	@override String get retry => 'Reintentar';
	@override String get search => 'Buscar';
	@override String get settings => 'Configuraciones';
	@override String get back => 'Atrás';
	@override String get next => 'Siguiente';
	@override String get done => 'Hecho';
	@override String get yes => 'Sí';
	@override String get no => 'No';
	@override String get apply => 'Aplicar';
	@override String get loggedOut => 'Desconectado';
	@override String get justNow => 'Justo ahora';
	@override String minutesAgo({required Object count}) => 'hace ${count} minuto(s)';
	@override String hoursAgo({required Object count}) => 'hace ${count} hora(s)';
	@override String get yesterday => 'Ayer';
}

// Path: auth
class _TranslationsAuthEs extends TranslationsAuthDe {
	_TranslationsAuthEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get login => 'Iniciar sesión';
	@override String get logout => 'Cerrar sesión';
	@override String get register => 'Registrarse';
	@override String get email => 'Correo electrónico';
	@override String get password => 'Contraseña';
	@override String get forgotPassword => '¿Olvidaste tu contraseña?';
	@override String get welcomeBack => '¡Bienvenido de nuevo!';
	@override String get createAccount => 'Crear cuenta';
	@override String get loginWithGoogle => 'Iniciar sesión con Google';
	@override String get loginWithApple => 'Iniciar sesión con Apple';
}

// Path: nav
class _TranslationsNavEs extends TranslationsNavDe {
	_TranslationsNavEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notas';
	@override String get settings => 'Ajustes';
}

// Path: notes
class _TranslationsNotesEs extends TranslationsNotesDe {
	_TranslationsNotesEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notas';
	@override String get newNote => 'Nueva nota';
	@override String get untitled => 'Sin título';
	@override String get unnamed => 'Nota sin nombre';
	@override String get noContent => 'Sin contenido aún';
	@override String get noteDate => 'Nota';
	@override String get lastEdited => 'Última edición';
	@override String get deleteNote => 'Eliminar nota';
	@override String deleteNoteConfirm({required Object title}) => '¿Realmente quieres eliminar "${title}"?';
	@override String get deleteNoteTooltip => 'Eliminar nota';
	@override String get noNotes => 'Aún no hay notas manuscritas';
	@override String get createFirst => 'Crea tu primera nota';
	@override String get createNew => 'Crear nueva nota';
	@override String get export => 'Exportar';
	@override String get share => 'Compartir';
	@override String get duplicate => 'Duplicar';
	@override String get openNote => 'Abrir nota';
	@override String get adjustTitlePaper => 'Ajustar título y papel';
	@override String get emptyNote => 'Nota vacía';
	@override String get emptyNoteSubtitle => 'Comienza con una página en blanco';
}

// Path: drawing
class _TranslationsDrawingEs extends TranslationsDrawingDe {
	_TranslationsDrawingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Pluma';
	@override String get pencil => 'Lápiz';
	@override String get highlighter => 'Marcador';
	@override String get eraser => 'Borrador';
	@override String get select => 'Seleccionar';
	@override String get undo => 'Deshacer';
	@override String get redo => 'Rehacer';
	@override String get clear => 'Limpiar';
	@override String get clearConfirm => '¿Eliminar todos los dibujos?';
	@override String get color => 'Color';
	@override String get colorWheel => 'Rueda de colores';
	@override String get symbol => 'Símbolo';
	@override String get strokeWidth => 'Grosor de trazo';
	@override String get zoomIn => 'Acercar';
	@override String get zoomOut => 'Alejar';
	@override String get markerMode => 'Modo marcador (translúcido)';
	@override String get pressureDetection => 'Detección de presión';
	@override String customizeTool({required Object name}) => 'Personalizar ${name}';
	@override String get fineliner => 'Fina';
	@override String get inkRoller => 'Rodillo de tinta';
	@override String get fountainPen => 'Pluma fuentes';
	@override String get marker => 'Marcador';
	@override String get neon => 'Neón';
}

// Path: paper
class _TranslationsPaperEs extends TranslationsPaperDe {
	_TranslationsPaperEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Liso';
	@override String get lined => 'Con líneas';
	@override String get grid => 'Cuadrícula';
	@override String get dotted => 'Puntitos';
}

// Path: ai
class _TranslationsAiEs extends TranslationsAiDe {
	_TranslationsAiEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Funciones de IA';
	@override String get assistant => 'Asistente de IA';
	@override String get recognize => 'Reconocer texto';
	@override String get recognizing => 'Reconociendo...';
	@override String get summarize => 'Resumir';
	@override String get extractTasks => 'Extraer tareas';
	@override String get translate => 'Traducir';
	@override String get noTextFound => 'No se encontró texto';
	@override String get persona => 'Asistente IA Persona';
	@override String get personaSubtitle => 'Elige el estilo del asistente';
}

// Path: pdf
class _TranslationsPdfEs extends TranslationsPdfDe {
	_TranslationsPdfEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get import => 'Importar PDF';
	@override String get importSubtitle => 'El texto se extraerá automáticamente';
	@override String get export => 'Exportar como PDF';
	@override String get exporting => 'Creando PDF...';
	@override String exportFailed({required Object error}) => 'Error en la exportación a PDF: ${error}';
	@override String get page => 'Página';
	@override String get of => 'de';
}

// Path: settings
class _TranslationsSettingsEs extends TranslationsSettingsDe {
	_TranslationsSettingsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuraciones';
	@override String get general => 'General';
	@override String get theme => 'Tema';
	@override String get themeSubtitle => 'Claro · Oscuro · Sistema';
	@override String get darkMode => 'Modo oscuro';
	@override String get lightMode => 'Modo claro';
	@override String get systemMode => 'Predeterminado del sistema';
	@override String get language => 'Idioma';
	@override String get languageSubtitle => 'Español (beta)';
	@override String get sync => 'Sincronización';
	@override String get syncEnabled => 'Sincronización activada';
	@override String get syncDisabled => 'Sincronización desactivada';
	@override String get account => 'Cuenta';
	@override String get about => 'Acerca de';
	@override String get version => 'Versión';
	@override String get privacy => 'Privacidad';
	@override String get terms => 'Términos de uso';
	@override String get input => 'Entrada';
	@override String get inputDevices => 'Dispositivos de entrada';
	@override String get inputDeviceSubtitle => 'Lápiz · Toque · Ratón';
	@override String get automation => 'Automatización';
	@override String get unlockPen => 'Desbloquear pluma';
	@override String get pen => 'Pluma';
	@override String get touch => 'Táctil';
	@override String get mouse => 'Ratón';
	@override String get autoLockOnStylus => 'Bloquear automáticamente en pluma';
	@override String get editorSettings => 'Configuraciones del editor';
	@override String get noteEditor => 'Editor de notas';
	@override String get noteEditorSubtitle => 'Panel lateral a la izquierda · derecha';
	@override String get strokeWidths => 'Grosor de línea';
	@override String get strokeWidthsSubtitle => 'Delgado · Medio · Grueso';
	@override String get palmRejection => 'Rechazo de palma';
	@override String get palmRejectionSubtitle => 'Previene entradas no deseadas';
	@override String get assistPanel => 'Panel de asistencia';
	@override String get leftRightHanded => 'Zurdo · Diestro';
	@override String get rightLeftHanded => 'Diestro · Zurdo';
	@override String get drawingArea => 'Área de dibujo';
	@override String get debugMode => 'Activar modo de depuración';
	@override String get cloud => 'Nube y sincronización';
	@override String get storageTarget => 'Destino de almacenamiento';
	@override String get storageSubtitle => 'Nube Inkpadu (gratis)';
	@override String get encryption => 'Cifrado';
	@override String get encryptionSubtitle => 'Cifrado de extremo a extremo activado';
}

// Path: errors
class _TranslationsErrorsEs extends TranslationsErrorsDe {
	_TranslationsErrorsEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Error de red. Revisa tu conexión.';
	@override String get unknownError => 'Se ha producido un error desconocido.';
	@override String get authError => 'Error de inicio de sesión. Por favor, intenta de nuevo.';
	@override String get saveError => 'Error al guardar.';
	@override String get loadError => 'Error al cargar.';
	@override String get exportError => 'Error en la exportación.';
	@override String loginFailed({required Object provider}) => 'Falló el inicio de sesión (${provider})';
}

// Path: onboarding
class _TranslationsOnboardingEs extends TranslationsOnboardingDe {
	_TranslationsOnboardingEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bienvenido a Inkpadu';
	@override String get description => 'Esboza ideas, escribe notas y organiza tus pensamientos con escritura natural.';
	@override String get digitalNotebook => 'Tu cuaderno digital';
	@override String get digitalNotebookDescription => 'Una experiencia manuscrita, optimizada para la creatividad y el enfoque, sin distracciones.';
	@override String get connecting => 'Conectando...';
	@override String get loginWithGitHub => 'Iniciar sesión con GitHub';
	@override String get loginWithGoogle => 'Iniciar sesión con Google';
}

// Path: editor
class _TranslationsEditorEs extends TranslationsEditorDe {
	_TranslationsEditorEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nueva nota';
	@override String get editNote => 'Editar nota';
	@override String get title => 'Título';
	@override String get writeNote => 'Escribe tu nota...';
	@override String get assistPanel => 'Panel de asistencia';
	@override String get leftRightHanded => 'Mano izquierda · derecha';
	@override String get rightLeftHanded => 'Derecha · izquierda';
	@override String get handednessHint => 'Los diestros alcanzan las herramientas más cómodamente si el panel está a la izquierda. Los zurdos eligen el lado derecho.';
	@override String get drawingArea => 'Área de dibujo';
	@override String get enableDebugMode => 'Activar modo de depuración';
	@override String get debugModeHint => 'Muestra cajas de delimitación y envolturas convexas en el editor y en el asistente de IA.';
	@override String get useLineSimplifier => 'Usar simplificador de líneas';
	@override String get lineSimplifierHint => 'Suaviza tus trazos automáticamente para obtener líneas limpias.';
	@override String smoothingIntensity({required Object value}) => 'Intensidad de suavizado (${value})';
	@override String get smoothingHint => 'Valores bajos mantienen más detalles, valores altos suavizan más.';
	@override String minTolerance({required Object value}) => 'Tolerancia mínima (${value} px)';
	@override String get minToleranceHint => 'Establece el límite inferior para el suavizado; valores más altos filtran pequeñas irregularidades.';
	@override String get aiPersona => 'Persona de asistente de IA';
	@override String get choosePersonaStyle => 'Elige el estilo de tu asistente de IA';
	@override String get personaStyleHint => 'La persona determina cómo se comunica el asistente contigo.';
	@override String get strictTrainer => 'Entrenador estricto';
	@override String get strictTrainerHint => 'Crítica directa y dura como un entrenador olímpico ruso';
	@override String get encouragingMentor => 'Mentor motivador';
	@override String get encouragingMentorHint => 'Refuerzo positivo y retroalimentación motivacional';
	@override String get customPersona => 'Personalizado';
	@override String get customPersonaHint => 'Establecer un prompt del sistema propio';
	@override String get yourSystemPrompt => 'Tu prompt del sistema';
	@override String get systemPromptPlaceholder => 'Describe cómo debe comportarse el asistente...';
	@override String get systemPromptHint => 'El prompt del sistema define la personalidad y el comportamiento del asistente en todas las solicitudes.';
	@override String get currentStyle => 'Estilo actual';
	@override String get strictTrainerDescription => 'El asistente te brinda comentarios directos y duros. No acepta la mediocridad y te motiva a dar lo mejor de ti mediante críticas constructivas.';
	@override String get encouragingMentorDescription => 'El asistente elogia tus progresos y te proporciona retroalimentación alentadora. Los errores se presentan como oportunidades de aprendizaje.';
	@override String get customPersonaDescription => 'El asistente actúa según tu propio prompt del sistema.';
}

// Path: pdfDialog
class _TranslationsPdfDialogEs extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogEs._(TranslationsEs root) : this._root = root, super.internal(root);

	final TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Seleccionar PDF';
	@override String get analyzePdf => 'Analizar PDF';
	@override String get ready => 'Listo';
	@override String get processPdf => 'Procesar PDF';
	@override String get importComplete => 'Importación completa';
	@override String get selectPdfFile => 'Por favor selecciona un archivo PDF...';
	@override String get analyzingPdf => 'Analizando PDF...';
	@override String pagesFound({required Object count}) => '${count} página(s) encontrada(s)';
	@override String get textExtractionBackground => 'La extracción de texto se realiza en segundo plano.';
	@override String get couldNotReadPdf => 'No se pudo leer el archivo PDF.';
	@override String pagesImported({required Object count}) => '${count} página(s) importada(s)';
	@override String charactersExtracted({required Object count}) => '~${count}k caracteres extraídos';
	@override String get extractedTextContext => 'El texto extraído se utiliza como contexto para el asistente de IA.';
	@override String get textExtractionDuration => 'La extracción de texto puede tardar unos segundos por página.';
	@override String renderingPage({required Object current, required Object total}) => 'Renderizando página ${current} de ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Extrayendo texto de la página ${current} de ${total}...';
	@override String get recognizingTasks => 'Reconociendo tareas...';
}

/// The flat map containing all translations for locale <es>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEs {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Tus notas, a tu manera',
			'common.save' => 'Guardar',
			'common.cancel' => 'Cancelar',
			'common.delete' => 'Eliminar',
			'common.edit' => 'Editar',
			'common.close' => 'Cerrar',
			'common.confirm' => 'Confirmar',
			'common.loading' => 'Cargando...',
			'common.error' => 'Error',
			'common.success' => 'Exitoso',
			'common.retry' => 'Reintentar',
			'common.search' => 'Buscar',
			'common.settings' => 'Configuraciones',
			'common.back' => 'Atrás',
			'common.next' => 'Siguiente',
			'common.done' => 'Hecho',
			'common.yes' => 'Sí',
			'common.no' => 'No',
			'common.apply' => 'Aplicar',
			'common.loggedOut' => 'Desconectado',
			'common.justNow' => 'Justo ahora',
			'common.minutesAgo' => ({required Object count}) => 'hace ${count} minuto(s)',
			'common.hoursAgo' => ({required Object count}) => 'hace ${count} hora(s)',
			'common.yesterday' => 'Ayer',
			'auth.login' => 'Iniciar sesión',
			'auth.logout' => 'Cerrar sesión',
			'auth.register' => 'Registrarse',
			'auth.email' => 'Correo electrónico',
			'auth.password' => 'Contraseña',
			'auth.forgotPassword' => '¿Olvidaste tu contraseña?',
			'auth.welcomeBack' => '¡Bienvenido de nuevo!',
			'auth.createAccount' => 'Crear cuenta',
			'auth.loginWithGoogle' => 'Iniciar sesión con Google',
			'auth.loginWithApple' => 'Iniciar sesión con Apple',
			'nav.notes' => 'Notas',
			'nav.settings' => 'Ajustes',
			'notes.title' => 'Notas',
			'notes.newNote' => 'Nueva nota',
			'notes.untitled' => 'Sin título',
			'notes.unnamed' => 'Nota sin nombre',
			'notes.noContent' => 'Sin contenido aún',
			'notes.noteDate' => 'Nota',
			'notes.lastEdited' => 'Última edición',
			'notes.deleteNote' => 'Eliminar nota',
			'notes.deleteNoteConfirm' => ({required Object title}) => '¿Realmente quieres eliminar "${title}"?',
			'notes.deleteNoteTooltip' => 'Eliminar nota',
			'notes.noNotes' => 'Aún no hay notas manuscritas',
			'notes.createFirst' => 'Crea tu primera nota',
			'notes.createNew' => 'Crear nueva nota',
			'notes.export' => 'Exportar',
			'notes.share' => 'Compartir',
			'notes.duplicate' => 'Duplicar',
			'notes.openNote' => 'Abrir nota',
			'notes.adjustTitlePaper' => 'Ajustar título y papel',
			'notes.emptyNote' => 'Nota vacía',
			'notes.emptyNoteSubtitle' => 'Comienza con una página en blanco',
			'drawing.pen' => 'Pluma',
			'drawing.pencil' => 'Lápiz',
			'drawing.highlighter' => 'Marcador',
			'drawing.eraser' => 'Borrador',
			'drawing.select' => 'Seleccionar',
			'drawing.undo' => 'Deshacer',
			'drawing.redo' => 'Rehacer',
			'drawing.clear' => 'Limpiar',
			'drawing.clearConfirm' => '¿Eliminar todos los dibujos?',
			'drawing.color' => 'Color',
			'drawing.colorWheel' => 'Rueda de colores',
			'drawing.symbol' => 'Símbolo',
			'drawing.strokeWidth' => 'Grosor de trazo',
			'drawing.zoomIn' => 'Acercar',
			'drawing.zoomOut' => 'Alejar',
			'drawing.markerMode' => 'Modo marcador (translúcido)',
			'drawing.pressureDetection' => 'Detección de presión',
			'drawing.customizeTool' => ({required Object name}) => 'Personalizar ${name}',
			'drawing.fineliner' => 'Fina',
			'drawing.inkRoller' => 'Rodillo de tinta',
			'drawing.fountainPen' => 'Pluma fuentes',
			'drawing.marker' => 'Marcador',
			'drawing.neon' => 'Neón',
			'paper.plain' => 'Liso',
			'paper.lined' => 'Con líneas',
			'paper.grid' => 'Cuadrícula',
			'paper.dotted' => 'Puntitos',
			'ai.title' => 'Funciones de IA',
			'ai.assistant' => 'Asistente de IA',
			'ai.recognize' => 'Reconocer texto',
			'ai.recognizing' => 'Reconociendo...',
			'ai.summarize' => 'Resumir',
			'ai.extractTasks' => 'Extraer tareas',
			'ai.translate' => 'Traducir',
			'ai.noTextFound' => 'No se encontró texto',
			'ai.persona' => 'Asistente IA Persona',
			'ai.personaSubtitle' => 'Elige el estilo del asistente',
			'pdf.import' => 'Importar PDF',
			'pdf.importSubtitle' => 'El texto se extraerá automáticamente',
			'pdf.export' => 'Exportar como PDF',
			'pdf.exporting' => 'Creando PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Error en la exportación a PDF: ${error}',
			'pdf.page' => 'Página',
			'pdf.of' => 'de',
			'settings.title' => 'Configuraciones',
			'settings.general' => 'General',
			'settings.theme' => 'Tema',
			'settings.themeSubtitle' => 'Claro · Oscuro · Sistema',
			'settings.darkMode' => 'Modo oscuro',
			'settings.lightMode' => 'Modo claro',
			'settings.systemMode' => 'Predeterminado del sistema',
			'settings.language' => 'Idioma',
			'settings.languageSubtitle' => 'Español (beta)',
			'settings.sync' => 'Sincronización',
			'settings.syncEnabled' => 'Sincronización activada',
			'settings.syncDisabled' => 'Sincronización desactivada',
			'settings.account' => 'Cuenta',
			'settings.about' => 'Acerca de',
			'settings.version' => 'Versión',
			'settings.privacy' => 'Privacidad',
			'settings.terms' => 'Términos de uso',
			'settings.input' => 'Entrada',
			'settings.inputDevices' => 'Dispositivos de entrada',
			'settings.inputDeviceSubtitle' => 'Lápiz · Toque · Ratón',
			'settings.automation' => 'Automatización',
			'settings.unlockPen' => 'Desbloquear pluma',
			'settings.pen' => 'Pluma',
			'settings.touch' => 'Táctil',
			'settings.mouse' => 'Ratón',
			'settings.autoLockOnStylus' => 'Bloquear automáticamente en pluma',
			'settings.editorSettings' => 'Configuraciones del editor',
			'settings.noteEditor' => 'Editor de notas',
			'settings.noteEditorSubtitle' => 'Panel lateral a la izquierda · derecha',
			'settings.strokeWidths' => 'Grosor de línea',
			'settings.strokeWidthsSubtitle' => 'Delgado · Medio · Grueso',
			'settings.palmRejection' => 'Rechazo de palma',
			'settings.palmRejectionSubtitle' => 'Previene entradas no deseadas',
			'settings.assistPanel' => 'Panel de asistencia',
			'settings.leftRightHanded' => 'Zurdo · Diestro',
			'settings.rightLeftHanded' => 'Diestro · Zurdo',
			'settings.drawingArea' => 'Área de dibujo',
			'settings.debugMode' => 'Activar modo de depuración',
			'settings.cloud' => 'Nube y sincronización',
			'settings.storageTarget' => 'Destino de almacenamiento',
			'settings.storageSubtitle' => 'Nube Inkpadu (gratis)',
			'settings.encryption' => 'Cifrado',
			'settings.encryptionSubtitle' => 'Cifrado de extremo a extremo activado',
			'errors.networkError' => 'Error de red. Revisa tu conexión.',
			'errors.unknownError' => 'Se ha producido un error desconocido.',
			'errors.authError' => 'Error de inicio de sesión. Por favor, intenta de nuevo.',
			'errors.saveError' => 'Error al guardar.',
			'errors.loadError' => 'Error al cargar.',
			'errors.exportError' => 'Error en la exportación.',
			'errors.loginFailed' => ({required Object provider}) => 'Falló el inicio de sesión (${provider})',
			'onboarding.welcome' => 'Bienvenido a Inkpadu',
			'onboarding.description' => 'Esboza ideas, escribe notas y organiza tus pensamientos con escritura natural.',
			'onboarding.digitalNotebook' => 'Tu cuaderno digital',
			'onboarding.digitalNotebookDescription' => 'Una experiencia manuscrita, optimizada para la creatividad y el enfoque, sin distracciones.',
			'onboarding.connecting' => 'Conectando...',
			'onboarding.loginWithGitHub' => 'Iniciar sesión con GitHub',
			'onboarding.loginWithGoogle' => 'Iniciar sesión con Google',
			'editor.newNote' => 'Nueva nota',
			'editor.editNote' => 'Editar nota',
			'editor.title' => 'Título',
			'editor.writeNote' => 'Escribe tu nota...',
			'editor.assistPanel' => 'Panel de asistencia',
			'editor.leftRightHanded' => 'Mano izquierda · derecha',
			'editor.rightLeftHanded' => 'Derecha · izquierda',
			'editor.handednessHint' => 'Los diestros alcanzan las herramientas más cómodamente si el panel está a la izquierda. Los zurdos eligen el lado derecho.',
			'editor.drawingArea' => 'Área de dibujo',
			'editor.enableDebugMode' => 'Activar modo de depuración',
			'editor.debugModeHint' => 'Muestra cajas de delimitación y envolturas convexas en el editor y en el asistente de IA.',
			'editor.useLineSimplifier' => 'Usar simplificador de líneas',
			'editor.lineSimplifierHint' => 'Suaviza tus trazos automáticamente para obtener líneas limpias.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Intensidad de suavizado (${value})',
			'editor.smoothingHint' => 'Valores bajos mantienen más detalles, valores altos suavizan más.',
			'editor.minTolerance' => ({required Object value}) => 'Tolerancia mínima (${value} px)',
			'editor.minToleranceHint' => 'Establece el límite inferior para el suavizado; valores más altos filtran pequeñas irregularidades.',
			'editor.aiPersona' => 'Persona de asistente de IA',
			'editor.choosePersonaStyle' => 'Elige el estilo de tu asistente de IA',
			'editor.personaStyleHint' => 'La persona determina cómo se comunica el asistente contigo.',
			'editor.strictTrainer' => 'Entrenador estricto',
			'editor.strictTrainerHint' => 'Crítica directa y dura como un entrenador olímpico ruso',
			'editor.encouragingMentor' => 'Mentor motivador',
			'editor.encouragingMentorHint' => 'Refuerzo positivo y retroalimentación motivacional',
			'editor.customPersona' => 'Personalizado',
			'editor.customPersonaHint' => 'Establecer un prompt del sistema propio',
			'editor.yourSystemPrompt' => 'Tu prompt del sistema',
			'editor.systemPromptPlaceholder' => 'Describe cómo debe comportarse el asistente...',
			'editor.systemPromptHint' => 'El prompt del sistema define la personalidad y el comportamiento del asistente en todas las solicitudes.',
			'editor.currentStyle' => 'Estilo actual',
			'editor.strictTrainerDescription' => 'El asistente te brinda comentarios directos y duros. No acepta la mediocridad y te motiva a dar lo mejor de ti mediante críticas constructivas.',
			'editor.encouragingMentorDescription' => 'El asistente elogia tus progresos y te proporciona retroalimentación alentadora. Los errores se presentan como oportunidades de aprendizaje.',
			'editor.customPersonaDescription' => 'El asistente actúa según tu propio prompt del sistema.',
			'pdfDialog.selectPdf' => 'Seleccionar PDF',
			'pdfDialog.analyzePdf' => 'Analizar PDF',
			'pdfDialog.ready' => 'Listo',
			'pdfDialog.processPdf' => 'Procesar PDF',
			'pdfDialog.importComplete' => 'Importación completa',
			'pdfDialog.selectPdfFile' => 'Por favor selecciona un archivo PDF...',
			'pdfDialog.analyzingPdf' => 'Analizando PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} página(s) encontrada(s)',
			'pdfDialog.textExtractionBackground' => 'La extracción de texto se realiza en segundo plano.',
			'pdfDialog.couldNotReadPdf' => 'No se pudo leer el archivo PDF.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} página(s) importada(s)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k caracteres extraídos',
			'pdfDialog.extractedTextContext' => 'El texto extraído se utiliza como contexto para el asistente de IA.',
			'pdfDialog.textExtractionDuration' => 'La extracción de texto puede tardar unos segundos por página.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Renderizando página ${current} de ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Extrayendo texto de la página ${current} de ${total}...',
			'pdfDialog.recognizingTasks' => 'Reconociendo tareas...',
			_ => null,
		};
	}
}
