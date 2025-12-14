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
class TranslationsIt extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsIt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.it,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <it>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsIt _root = this; // ignore: unused_field

	@override 
	TranslationsIt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsIt(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppIt app = _TranslationsAppIt._(_root);
	@override late final _TranslationsCommonIt common = _TranslationsCommonIt._(_root);
	@override late final _TranslationsAuthIt auth = _TranslationsAuthIt._(_root);
	@override late final _TranslationsNavIt nav = _TranslationsNavIt._(_root);
	@override late final _TranslationsNotesIt notes = _TranslationsNotesIt._(_root);
	@override late final _TranslationsDrawingIt drawing = _TranslationsDrawingIt._(_root);
	@override late final _TranslationsPaperIt paper = _TranslationsPaperIt._(_root);
	@override late final _TranslationsAiIt ai = _TranslationsAiIt._(_root);
	@override late final _TranslationsPdfIt pdf = _TranslationsPdfIt._(_root);
	@override late final _TranslationsSettingsIt settings = _TranslationsSettingsIt._(_root);
	@override late final _TranslationsErrorsIt errors = _TranslationsErrorsIt._(_root);
	@override late final _TranslationsOnboardingIt onboarding = _TranslationsOnboardingIt._(_root);
	@override late final _TranslationsEditorIt editor = _TranslationsEditorIt._(_root);
	@override late final _TranslationsPdfDialogIt pdfDialog = _TranslationsPdfDialogIt._(_root);
}

// Path: app
class _TranslationsAppIt extends TranslationsAppDe {
	_TranslationsAppIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Le tue note, il tuo modo';
}

// Path: common
class _TranslationsCommonIt extends TranslationsCommonDe {
	_TranslationsCommonIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get save => 'Salva';
	@override String get cancel => 'Annulla';
	@override String get delete => 'Elimina';
	@override String get edit => 'Modifica';
	@override String get close => 'Chiudi';
	@override String get confirm => 'Conferma';
	@override String get loading => 'Caricamento...';
	@override String get error => 'Errore';
	@override String get success => 'Successo';
	@override String get retry => 'Riprova';
	@override String get search => 'Cerca';
	@override String get settings => 'Impostazioni';
	@override String get back => 'Indietro';
	@override String get next => 'Avanti';
	@override String get done => 'Fatto';
	@override String get yes => 'Sì';
	@override String get no => 'No';
	@override String get apply => 'Applica';
	@override String get loggedOut => 'Disconnesso';
	@override String get justNow => 'Appena adesso';
	@override String minutesAgo({required Object count}) => 'fa ${count} minuto(i)';
	@override String hoursAgo({required Object count}) => 'fa ${count} ora(e)';
	@override String get yesterday => 'Ieri';
}

// Path: auth
class _TranslationsAuthIt extends TranslationsAuthDe {
	_TranslationsAuthIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get login => 'Accedi';
	@override String get logout => 'Disconnetti';
	@override String get register => 'Registrati';
	@override String get email => 'E-Mail';
	@override String get password => 'Password';
	@override String get forgotPassword => 'Hai dimenticato la password?';
	@override String get welcomeBack => 'Bentornato!';
	@override String get createAccount => 'Crea un account';
	@override String get loginWithGoogle => 'Accedi con Google';
	@override String get loginWithApple => 'Accedi con Apple';
}

// Path: nav
class _TranslationsNavIt extends TranslationsNavDe {
	_TranslationsNavIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Note';
	@override String get settings => 'Impostazioni';
}

// Path: notes
class _TranslationsNotesIt extends TranslationsNotesDe {
	_TranslationsNotesIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Note';
	@override String get newNote => 'Nuova nota';
	@override String get untitled => 'Senza titolo';
	@override String get unnamed => 'Nota senza titolo';
	@override String get noContent => 'Ancora nessun contenuto';
	@override String get noteDate => 'Nota';
	@override String get lastEdited => 'Ultima modifica';
	@override String get deleteNote => 'Elimina nota';
	@override String deleteNoteConfirm({required Object title}) => 'Sei sicuro di voler eliminare "${title}"?';
	@override String get deleteNoteTooltip => 'Elimina nota';
	@override String get noNotes => 'Nessuna nota a mano ancora';
	@override String get createFirst => 'Crea la tua prima nota';
	@override String get createNew => 'Crea nuova nota';
	@override String get export => 'Esporta';
	@override String get share => 'Condividi';
	@override String get duplicate => 'Duplica';
	@override String get openNote => 'Apri nota';
	@override String get adjustTitlePaper => 'Regola titolo e carta';
	@override String get emptyNote => 'Nota vuota';
	@override String get emptyNoteSubtitle => 'Inizia con una pagina vuota';
}

// Path: drawing
class _TranslationsDrawingIt extends TranslationsDrawingDe {
	_TranslationsDrawingIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Penna';
	@override String get pencil => 'Matita';
	@override String get highlighter => 'Evidenziatore';
	@override String get eraser => 'Gomma';
	@override String get select => 'Seleziona';
	@override String get undo => 'Annulla';
	@override String get redo => 'Ripeti';
	@override String get clear => 'Cancella';
	@override String get clearConfirm => 'Vuoi eliminare tutti i disegni?';
	@override String get color => 'Colore';
	@override String get colorWheel => 'Ruota dei colori';
	@override String get symbol => 'Simbolo';
	@override String get strokeWidth => 'Spessore tratto';
	@override String get zoomIn => 'Ingrandisci';
	@override String get zoomOut => 'Riduci';
	@override String get markerMode => 'Modalità marker (trasparente)';
	@override String get pressureDetection => 'Rilevamento pressione';
	@override String customizeTool({required Object name}) => 'Personalizza ${name}';
	@override String get fineliner => 'Penna fine';
	@override String get inkRoller => 'Rullo d\'inchiostro';
	@override String get fountainPen => 'Penne stilografiche';
	@override String get marker => 'Marker';
	@override String get neon => 'Neon';
}

// Path: paper
class _TranslationsPaperIt extends TranslationsPaperDe {
	_TranslationsPaperIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Semplice';
	@override String get lined => 'Rigato';
	@override String get grid => 'A quadretti';
	@override String get dotted => 'Puntinato';
}

// Path: ai
class _TranslationsAiIt extends TranslationsAiDe {
	_TranslationsAiIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Funzioni AI';
	@override String get assistant => 'Assistente IA';
	@override String get recognize => 'Riconoscere testo';
	@override String get recognizing => 'Riconoscimento...';
	@override String get summarize => 'Riassumere';
	@override String get extractTasks => 'Estrarre attività';
	@override String get translate => 'Tradurre';
	@override String get noTextFound => 'Nessun testo trovato';
	@override String get persona => 'Persona assistente AI';
	@override String get personaSubtitle => 'Scegli lo stile dell\'assistente';
}

// Path: pdf
class _TranslationsPdfIt extends TranslationsPdfDe {
	_TranslationsPdfIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get import => 'Importa PDF';
	@override String get importSubtitle => 'Il testo verrà estratto automaticamente';
	@override String get export => 'Esporta come PDF';
	@override String get exporting => 'Creazione PDF in corso...';
	@override String exportFailed({required Object error}) => 'Esportazione PDF fallita: ${error}';
	@override String get page => 'Pagina';
	@override String get of => 'di';
}

// Path: settings
class _TranslationsSettingsIt extends TranslationsSettingsDe {
	_TranslationsSettingsIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Impostazioni';
	@override String get general => 'Generale';
	@override String get theme => 'Tema';
	@override String get themeSubtitle => 'Chiaro · Scuro · Sistema';
	@override String get darkMode => 'Modalità scura';
	@override String get lightMode => 'Modalità chiara';
	@override String get systemMode => 'Modalità di sistema';
	@override String get language => 'Lingua';
	@override String get languageSubtitle => 'Italiano';
	@override String get sync => 'Sincronizzazione';
	@override String get syncEnabled => 'Sincronizzazione attivata';
	@override String get syncDisabled => 'Sincronizzazione disattivata';
	@override String get account => 'Account';
	@override String get about => 'Informazioni';
	@override String get version => 'Versione';
	@override String get privacy => 'Privacy';
	@override String get terms => 'Termini di utilizzo';
	@override String get input => 'Inserimento';
	@override String get inputDevices => 'Dispositivi di input';
	@override String get inputDeviceSubtitle => 'Stilo · Touch · Mouse';
	@override String get automation => 'Automazione';
	@override String get unlockPen => 'Sblocca penna';
	@override String get pen => 'Penna';
	@override String get touch => 'Tocco';
	@override String get mouse => 'Mouse';
	@override String get autoLockOnStylus => 'Blocco automatico su stilo';
	@override String get editorSettings => 'Impostazioni editor';
	@override String get noteEditor => 'Editor di note';
	@override String get noteEditorSubtitle => 'Pannello laterale sinistro · destro';
	@override String get strokeWidths => 'Spessori della penna';
	@override String get strokeWidthsSubtitle => 'Sottile · Medio · Spesso';
	@override String get palmRejection => 'Rifiuto del palmo';
	@override String get palmRejectionSubtitle => 'Previene inserimenti non intenzionali';
	@override String get assistPanel => 'Pannello assistenza';
	@override String get leftRightHanded => 'Mancino · Destro';
	@override String get rightLeftHanded => 'Destro · Mancino';
	@override String get drawingArea => 'Area di disegno';
	@override String get debugMode => 'Abilita modalità debug';
	@override String get cloud => 'Cloud e sincronizzazione';
	@override String get storageTarget => 'Obiettivo di archiviazione';
	@override String get storageSubtitle => 'Inkpadu Cloud (gratuito)';
	@override String get encryption => 'Crittografia';
	@override String get encryptionSubtitle => 'Fine a fine attiva';
}

// Path: errors
class _TranslationsErrorsIt extends TranslationsErrorsDe {
	_TranslationsErrorsIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Errore di rete. Controlla la tua connessione.';
	@override String get unknownError => 'Si è verificato un errore sconosciuto.';
	@override String get authError => 'Errore di accesso. Riprova.';
	@override String get saveError => 'Salvataggio fallito.';
	@override String get loadError => 'Caricamento fallito.';
	@override String get exportError => 'Esportazione fallita.';
	@override String loginFailed({required Object provider}) => 'Accesso (${provider}) fallito';
}

// Path: onboarding
class _TranslationsOnboardingIt extends TranslationsOnboardingDe {
	_TranslationsOnboardingIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Benvenuto in Inkpadu';
	@override String get description => 'Schizza idee, scrivi note e organizza i tuoi pensieri con una scrittura naturale.';
	@override String get digitalNotebook => 'Il tuo quaderno digitale';
	@override String get digitalNotebookDescription => 'Un\'esperienza scritta a mano, ottimizzata per creatività e concentrazione – senza distrazioni.';
	@override String get connecting => 'Collegando…';
	@override String get loginWithGitHub => 'Accedi con GitHub';
	@override String get loginWithGoogle => 'Accedi con Google';
}

// Path: editor
class _TranslationsEditorIt extends TranslationsEditorDe {
	_TranslationsEditorIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nuova nota';
	@override String get editNote => 'Modifica nota';
	@override String get title => 'Titolo';
	@override String get writeNote => 'Scrivi la tua nota...';
	@override String get assistPanel => 'Pannello assistenza';
	@override String get leftRightHanded => 'Mano sinistra · Destra';
	@override String get rightLeftHanded => 'Mano destra · Sinistra';
	@override String get handednessHint => 'I destrorsi possono raggiungere gli strumenti più comodamente con il pannello a sinistra. I mancini, invece, scelgono il lato destro.';
	@override String get drawingArea => 'Area di disegno';
	@override String get enableDebugMode => 'Attiva modalità debug';
	@override String get debugModeHint => 'Mostra bounding box e involucri convessi nell\'editor e nell\'assistente IA.';
	@override String get useLineSimplifier => 'Usa semplificatore di linee';
	@override String get lineSimplifierHint => 'Appiana automaticamente le tue linee per ottenere tratti più puliti.';
	@override String smoothingIntensity({required Object value}) => 'Intensità di smussamento (${value})';
	@override String get smoothingHint => 'Valori bassi conservano più dettagli, valori alti smussano di più.';
	@override String minTolerance({required Object value}) => 'Tolleranza minima (${value} px)';
	@override String get minToleranceHint => 'Imposta la soglia per la smussatura – valori più alti filtrano piccole irregolarità.';
	@override String get aiPersona => 'Persona assistente IA';
	@override String get choosePersonaStyle => 'Scegli lo stile del tuo assistente IA';
	@override String get personaStyleHint => 'La persona determina come l\'assistente comunica con te.';
	@override String get strictTrainer => 'Allenatore severo';
	@override String get strictTrainerHint => 'Critiche dirette e severe come un allenatore olimpionico russo';
	@override String get encouragingMentor => 'Mentore incoraggiante';
	@override String get encouragingMentorHint => 'Rinforzo positivo e feedback motivante';
	@override String get customPersona => 'Personalizzato';
	@override String get customPersonaHint => 'Imposta il tuo prompt di sistema';
	@override String get yourSystemPrompt => 'Il tuo prompt di sistema';
	@override String get systemPromptPlaceholder => 'Descrivi come dovrebbe comportarsi l\'assistente…';
	@override String get systemPromptHint => 'Il prompt di sistema definisce la personalità e il comportamento dell\'assistente per tutte le richieste.';
	@override String get currentStyle => 'Stile attuale';
	@override String get strictTrainerDescription => 'L\'assistente ti fornisce feedback duro e diretto. Non accetta la mediocrità e ti motiva a dare il massimo con critiche costruttive.';
	@override String get encouragingMentorDescription => 'L\'assistente loda i tuoi progressi e ti offre feedback incoraggiante. Gli errori vengono presentati come opportunità di apprendimento.';
	@override String get customPersonaDescription => 'L\'assistente si comporta secondo il tuo prompt di sistema.';
}

// Path: pdfDialog
class _TranslationsPdfDialogIt extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogIt._(TranslationsIt root) : this._root = root, super.internal(root);

	final TranslationsIt _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Seleziona PDF';
	@override String get analyzePdf => 'Analizza PDF';
	@override String get ready => 'Pronto';
	@override String get processPdf => 'Elabora PDF';
	@override String get importComplete => 'Importazione completata';
	@override String get selectPdfFile => 'Seleziona un file PDF...';
	@override String get analyzingPdf => 'Analizzando PDF...';
	@override String pagesFound({required Object count}) => '${count} pagina(e) trovata(e)';
	@override String get textExtractionBackground => 'Estrazione del testo in corso in background.';
	@override String get couldNotReadPdf => 'Impossibile leggere il file PDF.';
	@override String pagesImported({required Object count}) => '${count} pagina(e) importata(e)';
	@override String charactersExtracted({required Object count}) => '~${count}k caratteri estratti';
	@override String get extractedTextContext => 'Il testo estratto viene utilizzato come contesto per l\'assistente IA.';
	@override String get textExtractionDuration => 'L\'estrazione del testo può richiedere alcuni secondi per pagina.';
	@override String renderingPage({required Object current, required Object total}) => 'Rendering pagina ${current} di ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Estrazione testo da pagina ${current} di ${total}...';
	@override String get recognizingTasks => 'Riconosco compiti...';
}

/// The flat map containing all translations for locale <it>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsIt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Le tue note, il tuo modo',
			'common.save' => 'Salva',
			'common.cancel' => 'Annulla',
			'common.delete' => 'Elimina',
			'common.edit' => 'Modifica',
			'common.close' => 'Chiudi',
			'common.confirm' => 'Conferma',
			'common.loading' => 'Caricamento...',
			'common.error' => 'Errore',
			'common.success' => 'Successo',
			'common.retry' => 'Riprova',
			'common.search' => 'Cerca',
			'common.settings' => 'Impostazioni',
			'common.back' => 'Indietro',
			'common.next' => 'Avanti',
			'common.done' => 'Fatto',
			'common.yes' => 'Sì',
			'common.no' => 'No',
			'common.apply' => 'Applica',
			'common.loggedOut' => 'Disconnesso',
			'common.justNow' => 'Appena adesso',
			'common.minutesAgo' => ({required Object count}) => 'fa ${count} minuto(i)',
			'common.hoursAgo' => ({required Object count}) => 'fa ${count} ora(e)',
			'common.yesterday' => 'Ieri',
			'auth.login' => 'Accedi',
			'auth.logout' => 'Disconnetti',
			'auth.register' => 'Registrati',
			'auth.email' => 'E-Mail',
			'auth.password' => 'Password',
			'auth.forgotPassword' => 'Hai dimenticato la password?',
			'auth.welcomeBack' => 'Bentornato!',
			'auth.createAccount' => 'Crea un account',
			'auth.loginWithGoogle' => 'Accedi con Google',
			'auth.loginWithApple' => 'Accedi con Apple',
			'nav.notes' => 'Note',
			'nav.settings' => 'Impostazioni',
			'notes.title' => 'Note',
			'notes.newNote' => 'Nuova nota',
			'notes.untitled' => 'Senza titolo',
			'notes.unnamed' => 'Nota senza titolo',
			'notes.noContent' => 'Ancora nessun contenuto',
			'notes.noteDate' => 'Nota',
			'notes.lastEdited' => 'Ultima modifica',
			'notes.deleteNote' => 'Elimina nota',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Sei sicuro di voler eliminare "${title}"?',
			'notes.deleteNoteTooltip' => 'Elimina nota',
			'notes.noNotes' => 'Nessuna nota a mano ancora',
			'notes.createFirst' => 'Crea la tua prima nota',
			'notes.createNew' => 'Crea nuova nota',
			'notes.export' => 'Esporta',
			'notes.share' => 'Condividi',
			'notes.duplicate' => 'Duplica',
			'notes.openNote' => 'Apri nota',
			'notes.adjustTitlePaper' => 'Regola titolo e carta',
			'notes.emptyNote' => 'Nota vuota',
			'notes.emptyNoteSubtitle' => 'Inizia con una pagina vuota',
			'drawing.pen' => 'Penna',
			'drawing.pencil' => 'Matita',
			'drawing.highlighter' => 'Evidenziatore',
			'drawing.eraser' => 'Gomma',
			'drawing.select' => 'Seleziona',
			'drawing.undo' => 'Annulla',
			'drawing.redo' => 'Ripeti',
			'drawing.clear' => 'Cancella',
			'drawing.clearConfirm' => 'Vuoi eliminare tutti i disegni?',
			'drawing.color' => 'Colore',
			'drawing.colorWheel' => 'Ruota dei colori',
			'drawing.symbol' => 'Simbolo',
			'drawing.strokeWidth' => 'Spessore tratto',
			'drawing.zoomIn' => 'Ingrandisci',
			'drawing.zoomOut' => 'Riduci',
			'drawing.markerMode' => 'Modalità marker (trasparente)',
			'drawing.pressureDetection' => 'Rilevamento pressione',
			'drawing.customizeTool' => ({required Object name}) => 'Personalizza ${name}',
			'drawing.fineliner' => 'Penna fine',
			'drawing.inkRoller' => 'Rullo d\'inchiostro',
			'drawing.fountainPen' => 'Penne stilografiche',
			'drawing.marker' => 'Marker',
			'drawing.neon' => 'Neon',
			'paper.plain' => 'Semplice',
			'paper.lined' => 'Rigato',
			'paper.grid' => 'A quadretti',
			'paper.dotted' => 'Puntinato',
			'ai.title' => 'Funzioni AI',
			'ai.assistant' => 'Assistente IA',
			'ai.recognize' => 'Riconoscere testo',
			'ai.recognizing' => 'Riconoscimento...',
			'ai.summarize' => 'Riassumere',
			'ai.extractTasks' => 'Estrarre attività',
			'ai.translate' => 'Tradurre',
			'ai.noTextFound' => 'Nessun testo trovato',
			'ai.persona' => 'Persona assistente AI',
			'ai.personaSubtitle' => 'Scegli lo stile dell\'assistente',
			'pdf.import' => 'Importa PDF',
			'pdf.importSubtitle' => 'Il testo verrà estratto automaticamente',
			'pdf.export' => 'Esporta come PDF',
			'pdf.exporting' => 'Creazione PDF in corso...',
			'pdf.exportFailed' => ({required Object error}) => 'Esportazione PDF fallita: ${error}',
			'pdf.page' => 'Pagina',
			'pdf.of' => 'di',
			'settings.title' => 'Impostazioni',
			'settings.general' => 'Generale',
			'settings.theme' => 'Tema',
			'settings.themeSubtitle' => 'Chiaro · Scuro · Sistema',
			'settings.darkMode' => 'Modalità scura',
			'settings.lightMode' => 'Modalità chiara',
			'settings.systemMode' => 'Modalità di sistema',
			'settings.language' => 'Lingua',
			'settings.languageSubtitle' => 'Italiano',
			'settings.sync' => 'Sincronizzazione',
			'settings.syncEnabled' => 'Sincronizzazione attivata',
			'settings.syncDisabled' => 'Sincronizzazione disattivata',
			'settings.account' => 'Account',
			'settings.about' => 'Informazioni',
			'settings.version' => 'Versione',
			'settings.privacy' => 'Privacy',
			'settings.terms' => 'Termini di utilizzo',
			'settings.input' => 'Inserimento',
			'settings.inputDevices' => 'Dispositivi di input',
			'settings.inputDeviceSubtitle' => 'Stilo · Touch · Mouse',
			'settings.automation' => 'Automazione',
			'settings.unlockPen' => 'Sblocca penna',
			'settings.pen' => 'Penna',
			'settings.touch' => 'Tocco',
			'settings.mouse' => 'Mouse',
			'settings.autoLockOnStylus' => 'Blocco automatico su stilo',
			'settings.editorSettings' => 'Impostazioni editor',
			'settings.noteEditor' => 'Editor di note',
			'settings.noteEditorSubtitle' => 'Pannello laterale sinistro · destro',
			'settings.strokeWidths' => 'Spessori della penna',
			'settings.strokeWidthsSubtitle' => 'Sottile · Medio · Spesso',
			'settings.palmRejection' => 'Rifiuto del palmo',
			'settings.palmRejectionSubtitle' => 'Previene inserimenti non intenzionali',
			'settings.assistPanel' => 'Pannello assistenza',
			'settings.leftRightHanded' => 'Mancino · Destro',
			'settings.rightLeftHanded' => 'Destro · Mancino',
			'settings.drawingArea' => 'Area di disegno',
			'settings.debugMode' => 'Abilita modalità debug',
			'settings.cloud' => 'Cloud e sincronizzazione',
			'settings.storageTarget' => 'Obiettivo di archiviazione',
			'settings.storageSubtitle' => 'Inkpadu Cloud (gratuito)',
			'settings.encryption' => 'Crittografia',
			'settings.encryptionSubtitle' => 'Fine a fine attiva',
			'errors.networkError' => 'Errore di rete. Controlla la tua connessione.',
			'errors.unknownError' => 'Si è verificato un errore sconosciuto.',
			'errors.authError' => 'Errore di accesso. Riprova.',
			'errors.saveError' => 'Salvataggio fallito.',
			'errors.loadError' => 'Caricamento fallito.',
			'errors.exportError' => 'Esportazione fallita.',
			'errors.loginFailed' => ({required Object provider}) => 'Accesso (${provider}) fallito',
			'onboarding.welcome' => 'Benvenuto in Inkpadu',
			'onboarding.description' => 'Schizza idee, scrivi note e organizza i tuoi pensieri con una scrittura naturale.',
			'onboarding.digitalNotebook' => 'Il tuo quaderno digitale',
			'onboarding.digitalNotebookDescription' => 'Un\'esperienza scritta a mano, ottimizzata per creatività e concentrazione – senza distrazioni.',
			'onboarding.connecting' => 'Collegando…',
			'onboarding.loginWithGitHub' => 'Accedi con GitHub',
			'onboarding.loginWithGoogle' => 'Accedi con Google',
			'editor.newNote' => 'Nuova nota',
			'editor.editNote' => 'Modifica nota',
			'editor.title' => 'Titolo',
			'editor.writeNote' => 'Scrivi la tua nota...',
			'editor.assistPanel' => 'Pannello assistenza',
			'editor.leftRightHanded' => 'Mano sinistra · Destra',
			'editor.rightLeftHanded' => 'Mano destra · Sinistra',
			'editor.handednessHint' => 'I destrorsi possono raggiungere gli strumenti più comodamente con il pannello a sinistra. I mancini, invece, scelgono il lato destro.',
			'editor.drawingArea' => 'Area di disegno',
			'editor.enableDebugMode' => 'Attiva modalità debug',
			'editor.debugModeHint' => 'Mostra bounding box e involucri convessi nell\'editor e nell\'assistente IA.',
			'editor.useLineSimplifier' => 'Usa semplificatore di linee',
			'editor.lineSimplifierHint' => 'Appiana automaticamente le tue linee per ottenere tratti più puliti.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Intensità di smussamento (${value})',
			'editor.smoothingHint' => 'Valori bassi conservano più dettagli, valori alti smussano di più.',
			'editor.minTolerance' => ({required Object value}) => 'Tolleranza minima (${value} px)',
			'editor.minToleranceHint' => 'Imposta la soglia per la smussatura – valori più alti filtrano piccole irregolarità.',
			'editor.aiPersona' => 'Persona assistente IA',
			'editor.choosePersonaStyle' => 'Scegli lo stile del tuo assistente IA',
			'editor.personaStyleHint' => 'La persona determina come l\'assistente comunica con te.',
			'editor.strictTrainer' => 'Allenatore severo',
			'editor.strictTrainerHint' => 'Critiche dirette e severe come un allenatore olimpionico russo',
			'editor.encouragingMentor' => 'Mentore incoraggiante',
			'editor.encouragingMentorHint' => 'Rinforzo positivo e feedback motivante',
			'editor.customPersona' => 'Personalizzato',
			'editor.customPersonaHint' => 'Imposta il tuo prompt di sistema',
			'editor.yourSystemPrompt' => 'Il tuo prompt di sistema',
			'editor.systemPromptPlaceholder' => 'Descrivi come dovrebbe comportarsi l\'assistente…',
			'editor.systemPromptHint' => 'Il prompt di sistema definisce la personalità e il comportamento dell\'assistente per tutte le richieste.',
			'editor.currentStyle' => 'Stile attuale',
			'editor.strictTrainerDescription' => 'L\'assistente ti fornisce feedback duro e diretto. Non accetta la mediocrità e ti motiva a dare il massimo con critiche costruttive.',
			'editor.encouragingMentorDescription' => 'L\'assistente loda i tuoi progressi e ti offre feedback incoraggiante. Gli errori vengono presentati come opportunità di apprendimento.',
			'editor.customPersonaDescription' => 'L\'assistente si comporta secondo il tuo prompt di sistema.',
			'pdfDialog.selectPdf' => 'Seleziona PDF',
			'pdfDialog.analyzePdf' => 'Analizza PDF',
			'pdfDialog.ready' => 'Pronto',
			'pdfDialog.processPdf' => 'Elabora PDF',
			'pdfDialog.importComplete' => 'Importazione completata',
			'pdfDialog.selectPdfFile' => 'Seleziona un file PDF...',
			'pdfDialog.analyzingPdf' => 'Analizzando PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} pagina(e) trovata(e)',
			'pdfDialog.textExtractionBackground' => 'Estrazione del testo in corso in background.',
			'pdfDialog.couldNotReadPdf' => 'Impossibile leggere il file PDF.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} pagina(e) importata(e)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k caratteri estratti',
			'pdfDialog.extractedTextContext' => 'Il testo estratto viene utilizzato come contesto per l\'assistente IA.',
			'pdfDialog.textExtractionDuration' => 'L\'estrazione del testo può richiedere alcuni secondi per pagina.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Rendering pagina ${current} di ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Estrazione testo da pagina ${current} di ${total}...',
			'pdfDialog.recognizingTasks' => 'Riconosco compiti...',
			_ => null,
		};
	}
}
