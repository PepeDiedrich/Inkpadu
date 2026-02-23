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
class TranslationsNl extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsNl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.nl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <nl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsNl _root = this; // ignore: unused_field

	@override 
	TranslationsNl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsNl(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppNl app = _TranslationsAppNl._(_root);
	@override late final _TranslationsCommonNl common = _TranslationsCommonNl._(_root);
	@override late final _TranslationsAuthNl auth = _TranslationsAuthNl._(_root);
	@override late final _TranslationsNavNl nav = _TranslationsNavNl._(_root);
	@override late final _TranslationsNotesNl notes = _TranslationsNotesNl._(_root);
	@override late final _TranslationsDrawingNl drawing = _TranslationsDrawingNl._(_root);
	@override late final _TranslationsPaperNl paper = _TranslationsPaperNl._(_root);
	@override late final _TranslationsAiNl ai = _TranslationsAiNl._(_root);
	@override late final _TranslationsPdfNl pdf = _TranslationsPdfNl._(_root);
	@override late final _TranslationsSettingsNl settings = _TranslationsSettingsNl._(_root);
	@override late final _TranslationsErrorsNl errors = _TranslationsErrorsNl._(_root);
	@override late final _TranslationsOnboardingNl onboarding = _TranslationsOnboardingNl._(_root);
	@override late final _TranslationsEditorNl editor = _TranslationsEditorNl._(_root);
	@override late final _TranslationsPdfDialogNl pdfDialog = _TranslationsPdfDialogNl._(_root);
}

// Path: app
class _TranslationsAppNl extends TranslationsAppDe {
	_TranslationsAppNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Jouw notities, jouw stijl';
}

// Path: common
class _TranslationsCommonNl extends TranslationsCommonDe {
	_TranslationsCommonNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get save => 'Opslaan';
	@override String get cancel => 'Annuleren';
	@override String get delete => 'Verwijderen';
	@override String get edit => 'Bewerken';
	@override String get close => 'Sluiten';
	@override String get confirm => 'Bevestigen';
	@override String get loading => 'Laden...';
	@override String get error => 'Fout';
	@override String get success => 'Succesvol';
	@override String get retry => 'Opnieuw proberen';
	@override String get search => 'Zoeken';
	@override String get settings => 'Instellingen';
	@override String get back => 'Terug';
	@override String get next => 'Volgende';
	@override String get done => 'Klaar';
	@override String get yes => 'Ja';
	@override String get no => 'Nee';
	@override String get apply => 'Toepassen';
	@override String get loggedOut => 'Uitgelogd';
	@override String get justNow => 'Net nu';
	@override String minutesAgo({required Object count}) => 'vor ${count} minuut(en)';
	@override String hoursAgo({required Object count}) => 'vor ${count} uur(en)';
	@override String get yesterday => 'Gisteren';
}

// Path: auth
class _TranslationsAuthNl extends TranslationsAuthDe {
	_TranslationsAuthNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get login => 'Inloggen';
	@override String get logout => 'Uitloggen';
	@override String get register => 'Registreren';
	@override String get email => 'E-mail';
	@override String get password => 'Wachtwoord';
	@override String get forgotPassword => 'Wachtwoord vergeten?';
	@override String get welcomeBack => 'Welkom terug!';
	@override String get createAccount => 'Account aanmaken';
	@override String get loginWithGoogle => 'Inloggen met Google';
	@override String get loginWithApple => 'Inloggen met Apple';
}

// Path: nav
class _TranslationsNavNl extends TranslationsNavDe {
	_TranslationsNavNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notities';
	@override String get settings => 'Instellingen';
}

// Path: notes
class _TranslationsNotesNl extends TranslationsNotesDe {
	_TranslationsNotesNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notities';
	@override String get newNote => 'Nieuwe notitie';
	@override String get untitled => 'Zonder titel';
	@override String get unnamed => 'Onbenoemde notitie';
	@override String get noContent => 'Nog geen inhoud';
	@override String get noteDate => 'Notitie';
	@override String get lastEdited => 'Laatst bewerkt';
	@override String get deleteNote => 'Notitie verwijderen';
	@override String deleteNoteConfirm({required Object title}) => 'Weet je zeker dat je "${title}" wilt verwijderen?';
	@override String get deleteNoteTooltip => 'Notitie verwijderen';
	@override String get noNotes => 'Nog geen handgeschreven notities';
	@override String get createFirst => 'Maak je eerste notitie';
	@override String get createNew => 'Nieuwe notitie maken';
	@override String get export => 'Exporteren';
	@override String get share => 'Delen';
	@override String get duplicate => 'Dupliceren';
	@override String get openNote => 'Notitie openen';
	@override String get adjustTitlePaper => 'Titel & papier aanpassen';
	@override String get emptyNote => 'Lege notitie';
	@override String get emptyNoteSubtitle => 'Begin met een lege pagina';
}

// Path: drawing
class _TranslationsDrawingNl extends TranslationsDrawingDe {
	_TranslationsDrawingNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Pen';
	@override String get pencil => 'Potlood';
	@override String get highlighter => 'Marker';
	@override String get eraser => 'Gum';
	@override String get select => 'Selecteren';
	@override String get lasso => 'Lasso';
	@override String get undo => 'Ongedaan maken';
	@override String get redo => 'Opnieuw doen';
	@override String get clear => 'Wissen';
	@override String get clearConfirm => 'Alle tekeningen wissen?';
	@override String get color => 'Kleur';
	@override String get colorWheel => 'Kleurwiel';
	@override String get symbol => 'Symbool';
	@override String get strokeWidth => 'Dikte van de lijn';
	@override String get zoomIn => 'Inzoomen';
	@override String get zoomOut => 'Uitzoomen';
	@override String get markerMode => 'Marker-modus (doorzichtig)';
	@override String get pressureDetection => 'Drukdetectie';
	@override String customizeTool({required Object name}) => '${name} aanpassen';
	@override String get fineliner => 'Fineliner';
	@override String get inkRoller => 'Inktroller';
	@override String get fountainPen => 'Vulpen';
	@override String get marker => 'Marker';
	@override String get neon => 'Neon';
}

// Path: paper
class _TranslationsPaperNl extends TranslationsPaperDe {
	_TranslationsPaperNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Onbedrukt';
	@override String get lined => 'Geruit';
	@override String get grid => 'Ruitjes';
	@override String get dotted => 'Gestippeld';
}

// Path: ai
class _TranslationsAiNl extends TranslationsAiDe {
	_TranslationsAiNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI-functies';
	@override String get assistant => 'AI-assistent';
	@override String get recognize => 'Tekst herkennen';
	@override String get recognizing => 'Herkennen...';
	@override String get summarize => 'Samenvatten';
	@override String get extractTasks => 'Taken extraheren';
	@override String get translate => 'Vertalen';
	@override String get noTextFound => 'Geen tekst gevonden';
	@override String get helpMe => 'Help mij';
	@override String get helpMeTitle => 'AI-antwoord';
	@override String get analyzingSelection => 'Selectie analyseren…';
	@override String get noSelection => 'Selecteer eerst iets met de lasso.';
	@override String get helpMeNotConfigured => 'AI is nog niet geconfigureerd.';
	@override String get persona => 'AI-assistent persona';
	@override String get personaSubtitle => 'Kies de stijl van de assistent';
}

// Path: pdf
class _TranslationsPdfNl extends TranslationsPdfDe {
	_TranslationsPdfNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get import => 'PDF importeren';
	@override String get importSubtitle => 'Tekst wordt automatisch geëxtraheerd';
	@override String get export => 'Als PDF exporteren';
	@override String get exporting => 'PDF wordt aangemaakt...';
	@override String exportFailed({required Object error}) => 'PDF-export mislukt: ${error}';
	@override String get page => 'Pagina';
	@override String get of => 'van';
}

// Path: settings
class _TranslationsSettingsNl extends TranslationsSettingsDe {
	_TranslationsSettingsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Instellingen';
	@override String get general => 'Algemeen';
	@override String get theme => 'Thema';
	@override String get themeSubtitle => 'Licht · Donker · Systeem';
	@override String get darkMode => 'Donkere modus';
	@override String get lightMode => 'Lichte modus';
	@override String get systemMode => 'Systeemstandaard';
	@override String get language => 'Taal';
	@override String get languageSubtitle => 'Nederlands (beta)';
	@override String get sync => 'Synchronisatie';
	@override String get syncEnabled => 'Synchronisatie ingeschakeld';
	@override String get syncDisabled => 'Synchronisatie uitgeschakeld';
	@override String get account => 'Account';
	@override String get about => 'Over';
	@override String get version => 'Versie';
	@override String get privacy => 'Privacy';
	@override String get terms => 'Gebruiksvoorwaarden';
	@override String get input => 'Invoer';
	@override String get inputDevices => 'Invoerapparaten';
	@override String get inputDeviceSubtitle => 'Pen · Touch · Muis';
	@override String get automation => 'Automatisering';
	@override String get unlockPen => 'Pen vergrendeling opheffen';
	@override String get pen => 'Pen';
	@override String get touch => 'Touch';
	@override String get mouse => 'Muis';
	@override String get autoLockOnStylus => 'Automatisch vergrendelen op stylus';
	@override String get editorSettings => 'Editor-instellingen';
	@override String get noteEditor => 'Notitie-editor';
	@override String get noteEditorSubtitle => 'Zijpaneel links · rechts';
	@override String get strokeWidths => 'Dikte pen';
	@override String get strokeWidthsSubtitle => 'Dun · Medium · Dik';
	@override String get palmRejection => 'Handpalmherkenning';
	@override String get palmRejectionSubtitle => 'Voorkomt ongewenste invoer';
	@override String get assistPanel => 'Assistentie-panel';
	@override String get leftRightHanded => 'Links · Rechtshandig';
	@override String get rightLeftHanded => 'Rechts · Linkshandig';
	@override String get drawingArea => 'Tekenoppervlak';
	@override String get debugMode => 'Debug-modus inschakelen';
	@override String get cloud => 'Cloud & Synchronisatie';
	@override String get storageTarget => 'Opslagdoel';
	@override String get storageSubtitle => 'Inkpadu Cloud (gratis)';
	@override String get encryption => 'Versleuteling';
	@override String get encryptionSubtitle => 'Eind-tot-eind actief';
}

// Path: errors
class _TranslationsErrorsNl extends TranslationsErrorsDe {
	_TranslationsErrorsNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Netwerkfout. Controleer je verbinding.';
	@override String get unknownError => 'Er is een onbekende fout opgetreden.';
	@override String get authError => 'Inlogfout. Probeer het opnieuw.';
	@override String get saveError => 'Opslaan mislukt.';
	@override String get loadError => 'Laden mislukt.';
	@override String get exportError => 'Export mislukt.';
	@override String loginFailed({required Object provider}) => 'Inloggen (${provider}) mislukt';
}

// Path: onboarding
class _TranslationsOnboardingNl extends TranslationsOnboardingDe {
	_TranslationsOnboardingNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Welkom bij Inkpadu';
	@override String get description => 'Schets ideeën, schrijf notities en organiseer je gedachten met natuurlijke handschrift.';
	@override String get digitalNotebook => 'Jouw digitale notitieboek';
	@override String get digitalNotebookDescription => 'Een handschriftelijke ervaring, geoptimaliseerd voor creativiteit en focus – helemaal zonder afleiding.';
	@override String get connecting => 'Verbinden…';
	@override String get loginWithGitHub => 'Aanmelden met GitHub';
	@override String get loginWithGoogle => 'Aanmelden met Google';
}

// Path: editor
class _TranslationsEditorNl extends TranslationsEditorDe {
	_TranslationsEditorNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nieuwe notitie';
	@override String get editNote => 'Notitie bewerken';
	@override String get title => 'Titel';
	@override String get writeNote => 'Schrijf je notitie...';
	@override String get assistPanel => 'Hulppanel';
	@override String get leftRightHanded => 'Links · Rechtshandig';
	@override String get rightLeftHanded => 'Rechts · Linkshandig';
	@override String get handednessHint => 'Rechtshandigen bereiken de gereedschappen gemakkelijker als het paneel links zit. Linkshandigen kiezen daarentegen de rechterkant.';
	@override String get drawingArea => 'Tekenruimte';
	@override String get enableDebugMode => 'Debug-modus inschakelen';
	@override String get debugModeHint => 'Toont bounding-boxen en convexe hulzen in de editor en in de AI-assistent.';
	@override String get useLineSimplifier => 'Lijn-simplifier gebruiken';
	@override String get lineSimplifierHint => 'Maakt je lijnen automatisch glad voor een rustigere uitstraling.';
	@override String smoothingIntensity({required Object value}) => 'Gladheidsintensiteit (${value})';
	@override String get smoothingHint => 'Lage waarden behouden meer details, hoge waarden maken sterker glad.';
	@override String minTolerance({required Object value}) => 'Minimale tolerantiewaarde (${value} px)';
	@override String get minToleranceHint => 'Stelt de ondergrens voor het gladmaken in – hogere waarden filteren kleine tandjes.';
	@override String get aiPersona => 'AI-assistent persona';
	@override String get choosePersonaStyle => 'Kies de stijl van je AI-assistent';
	@override String get personaStyleHint => 'De persona bepaalt hoe de assistent met je communiceert.';
	@override String get strictTrainer => 'Strenge trainer';
	@override String get strictTrainerHint => 'Directe, harde kritiek zoals een Russische Olympische trainer';
	@override String get encouragingMentor => 'Bemoedigende mentor';
	@override String get encouragingMentorHint => 'Positieve versterking en motiverende feedback';
	@override String get customPersona => 'Aangepaste';
	@override String get customPersonaHint => 'Stel je eigen systeem-prompt in';
	@override String get yourSystemPrompt => 'Jouw systeem-prompt';
	@override String get systemPromptPlaceholder => 'Beschrijf hoe de assistent zich moet gedragen…';
	@override String get systemPromptHint => 'De systeem-prompt definieert de persoonlijkheid en het gedrag van de assistent bij alle verzoeken.';
	@override String get currentStyle => 'Huidige stijl';
	@override String get strictTrainerDescription => 'De assistent geeft je harde, directe feedback. Hij accepteert geen middelmatigheid en motiveert je door constructieve kritiek tot topprestaties.';
	@override String get encouragingMentorDescription => 'De assistent prijst je vorderingen en biedt bemoedigende feedback. Fouten worden gepresenteerd als leermogelijkheden.';
	@override String get customPersonaDescription => 'De assistent gedraagt zich volgens je eigen systeem-prompt.';
}

// Path: pdfDialog
class _TranslationsPdfDialogNl extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogNl._(TranslationsNl root) : this._root = root, super.internal(root);

	final TranslationsNl _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'PDF selecteren';
	@override String get analyzePdf => 'PDF analyseren';
	@override String get ready => 'Klaar';
	@override String get processPdf => 'PDF verwerken';
	@override String get importComplete => 'Importeren voltooid';
	@override String get selectPdfFile => 'Kies een PDF-bestand...';
	@override String get analyzingPdf => 'PDF wordt geanalyseerd...';
	@override String pagesFound({required Object count}) => '${count} pagina\'s gevonden';
	@override String get textExtractionBackground => 'Textextractie vindt op de achtergrond plaats.';
	@override String get couldNotReadPdf => 'De PDF-bestand kon niet gelezen worden.';
	@override String pagesImported({required Object count}) => '${count} pagina\'s geïmporteerd';
	@override String charactersExtracted({required Object count}) => '~${count}k tekens geëxtraheerd';
	@override String get extractedTextContext => 'De geëxtraheerde tekst wordt als context voor de AI-assistent gebruikt.';
	@override String get textExtractionDuration => 'De textextractie kan enkele seconden per pagina duren.';
	@override String renderingPage({required Object current, required Object total}) => 'Pagina ${current} van ${total} aan het renderen...';
	@override String extractingPage({required Object current, required Object total}) => 'Tekst van pagina ${current} van ${total} aan het extraheren...';
	@override String get recognizingTasks => 'Taken aan het herkennen...';
}

/// The flat map containing all translations for locale <nl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsNl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Jouw notities, jouw stijl',
			'common.save' => 'Opslaan',
			'common.cancel' => 'Annuleren',
			'common.delete' => 'Verwijderen',
			'common.edit' => 'Bewerken',
			'common.close' => 'Sluiten',
			'common.confirm' => 'Bevestigen',
			'common.loading' => 'Laden...',
			'common.error' => 'Fout',
			'common.success' => 'Succesvol',
			'common.retry' => 'Opnieuw proberen',
			'common.search' => 'Zoeken',
			'common.settings' => 'Instellingen',
			'common.back' => 'Terug',
			'common.next' => 'Volgende',
			'common.done' => 'Klaar',
			'common.yes' => 'Ja',
			'common.no' => 'Nee',
			'common.apply' => 'Toepassen',
			'common.loggedOut' => 'Uitgelogd',
			'common.justNow' => 'Net nu',
			'common.minutesAgo' => ({required Object count}) => 'vor ${count} minuut(en)',
			'common.hoursAgo' => ({required Object count}) => 'vor ${count} uur(en)',
			'common.yesterday' => 'Gisteren',
			'auth.login' => 'Inloggen',
			'auth.logout' => 'Uitloggen',
			'auth.register' => 'Registreren',
			'auth.email' => 'E-mail',
			'auth.password' => 'Wachtwoord',
			'auth.forgotPassword' => 'Wachtwoord vergeten?',
			'auth.welcomeBack' => 'Welkom terug!',
			'auth.createAccount' => 'Account aanmaken',
			'auth.loginWithGoogle' => 'Inloggen met Google',
			'auth.loginWithApple' => 'Inloggen met Apple',
			'nav.notes' => 'Notities',
			'nav.settings' => 'Instellingen',
			'notes.title' => 'Notities',
			'notes.newNote' => 'Nieuwe notitie',
			'notes.untitled' => 'Zonder titel',
			'notes.unnamed' => 'Onbenoemde notitie',
			'notes.noContent' => 'Nog geen inhoud',
			'notes.noteDate' => 'Notitie',
			'notes.lastEdited' => 'Laatst bewerkt',
			'notes.deleteNote' => 'Notitie verwijderen',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Weet je zeker dat je "${title}" wilt verwijderen?',
			'notes.deleteNoteTooltip' => 'Notitie verwijderen',
			'notes.noNotes' => 'Nog geen handgeschreven notities',
			'notes.createFirst' => 'Maak je eerste notitie',
			'notes.createNew' => 'Nieuwe notitie maken',
			'notes.export' => 'Exporteren',
			'notes.share' => 'Delen',
			'notes.duplicate' => 'Dupliceren',
			'notes.openNote' => 'Notitie openen',
			'notes.adjustTitlePaper' => 'Titel & papier aanpassen',
			'notes.emptyNote' => 'Lege notitie',
			'notes.emptyNoteSubtitle' => 'Begin met een lege pagina',
			'drawing.pen' => 'Pen',
			'drawing.pencil' => 'Potlood',
			'drawing.highlighter' => 'Marker',
			'drawing.eraser' => 'Gum',
			'drawing.select' => 'Selecteren',
			'drawing.lasso' => 'Lasso',
			'drawing.undo' => 'Ongedaan maken',
			'drawing.redo' => 'Opnieuw doen',
			'drawing.clear' => 'Wissen',
			'drawing.clearConfirm' => 'Alle tekeningen wissen?',
			'drawing.color' => 'Kleur',
			'drawing.colorWheel' => 'Kleurwiel',
			'drawing.symbol' => 'Symbool',
			'drawing.strokeWidth' => 'Dikte van de lijn',
			'drawing.zoomIn' => 'Inzoomen',
			'drawing.zoomOut' => 'Uitzoomen',
			'drawing.markerMode' => 'Marker-modus (doorzichtig)',
			'drawing.pressureDetection' => 'Drukdetectie',
			'drawing.customizeTool' => ({required Object name}) => '${name} aanpassen',
			'drawing.fineliner' => 'Fineliner',
			'drawing.inkRoller' => 'Inktroller',
			'drawing.fountainPen' => 'Vulpen',
			'drawing.marker' => 'Marker',
			'drawing.neon' => 'Neon',
			'paper.plain' => 'Onbedrukt',
			'paper.lined' => 'Geruit',
			'paper.grid' => 'Ruitjes',
			'paper.dotted' => 'Gestippeld',
			'ai.title' => 'AI-functies',
			'ai.assistant' => 'AI-assistent',
			'ai.recognize' => 'Tekst herkennen',
			'ai.recognizing' => 'Herkennen...',
			'ai.summarize' => 'Samenvatten',
			'ai.extractTasks' => 'Taken extraheren',
			'ai.translate' => 'Vertalen',
			'ai.noTextFound' => 'Geen tekst gevonden',
			'ai.helpMe' => 'Help mij',
			'ai.helpMeTitle' => 'AI-antwoord',
			'ai.analyzingSelection' => 'Selectie analyseren…',
			'ai.noSelection' => 'Selecteer eerst iets met de lasso.',
			'ai.helpMeNotConfigured' => 'AI is nog niet geconfigureerd.',
			'ai.persona' => 'AI-assistent persona',
			'ai.personaSubtitle' => 'Kies de stijl van de assistent',
			'pdf.import' => 'PDF importeren',
			'pdf.importSubtitle' => 'Tekst wordt automatisch geëxtraheerd',
			'pdf.export' => 'Als PDF exporteren',
			'pdf.exporting' => 'PDF wordt aangemaakt...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF-export mislukt: ${error}',
			'pdf.page' => 'Pagina',
			'pdf.of' => 'van',
			'settings.title' => 'Instellingen',
			'settings.general' => 'Algemeen',
			'settings.theme' => 'Thema',
			'settings.themeSubtitle' => 'Licht · Donker · Systeem',
			'settings.darkMode' => 'Donkere modus',
			'settings.lightMode' => 'Lichte modus',
			'settings.systemMode' => 'Systeemstandaard',
			'settings.language' => 'Taal',
			'settings.languageSubtitle' => 'Nederlands (beta)',
			'settings.sync' => 'Synchronisatie',
			'settings.syncEnabled' => 'Synchronisatie ingeschakeld',
			'settings.syncDisabled' => 'Synchronisatie uitgeschakeld',
			'settings.account' => 'Account',
			'settings.about' => 'Over',
			'settings.version' => 'Versie',
			'settings.privacy' => 'Privacy',
			'settings.terms' => 'Gebruiksvoorwaarden',
			'settings.input' => 'Invoer',
			'settings.inputDevices' => 'Invoerapparaten',
			'settings.inputDeviceSubtitle' => 'Pen · Touch · Muis',
			'settings.automation' => 'Automatisering',
			'settings.unlockPen' => 'Pen vergrendeling opheffen',
			'settings.pen' => 'Pen',
			'settings.touch' => 'Touch',
			'settings.mouse' => 'Muis',
			'settings.autoLockOnStylus' => 'Automatisch vergrendelen op stylus',
			'settings.editorSettings' => 'Editor-instellingen',
			'settings.noteEditor' => 'Notitie-editor',
			'settings.noteEditorSubtitle' => 'Zijpaneel links · rechts',
			'settings.strokeWidths' => 'Dikte pen',
			'settings.strokeWidthsSubtitle' => 'Dun · Medium · Dik',
			'settings.palmRejection' => 'Handpalmherkenning',
			'settings.palmRejectionSubtitle' => 'Voorkomt ongewenste invoer',
			'settings.assistPanel' => 'Assistentie-panel',
			'settings.leftRightHanded' => 'Links · Rechtshandig',
			'settings.rightLeftHanded' => 'Rechts · Linkshandig',
			'settings.drawingArea' => 'Tekenoppervlak',
			'settings.debugMode' => 'Debug-modus inschakelen',
			'settings.cloud' => 'Cloud & Synchronisatie',
			'settings.storageTarget' => 'Opslagdoel',
			'settings.storageSubtitle' => 'Inkpadu Cloud (gratis)',
			'settings.encryption' => 'Versleuteling',
			'settings.encryptionSubtitle' => 'Eind-tot-eind actief',
			'errors.networkError' => 'Netwerkfout. Controleer je verbinding.',
			'errors.unknownError' => 'Er is een onbekende fout opgetreden.',
			'errors.authError' => 'Inlogfout. Probeer het opnieuw.',
			'errors.saveError' => 'Opslaan mislukt.',
			'errors.loadError' => 'Laden mislukt.',
			'errors.exportError' => 'Export mislukt.',
			'errors.loginFailed' => ({required Object provider}) => 'Inloggen (${provider}) mislukt',
			'onboarding.welcome' => 'Welkom bij Inkpadu',
			'onboarding.description' => 'Schets ideeën, schrijf notities en organiseer je gedachten met natuurlijke handschrift.',
			'onboarding.digitalNotebook' => 'Jouw digitale notitieboek',
			'onboarding.digitalNotebookDescription' => 'Een handschriftelijke ervaring, geoptimaliseerd voor creativiteit en focus – helemaal zonder afleiding.',
			'onboarding.connecting' => 'Verbinden…',
			'onboarding.loginWithGitHub' => 'Aanmelden met GitHub',
			'onboarding.loginWithGoogle' => 'Aanmelden met Google',
			'editor.newNote' => 'Nieuwe notitie',
			'editor.editNote' => 'Notitie bewerken',
			'editor.title' => 'Titel',
			'editor.writeNote' => 'Schrijf je notitie...',
			'editor.assistPanel' => 'Hulppanel',
			'editor.leftRightHanded' => 'Links · Rechtshandig',
			'editor.rightLeftHanded' => 'Rechts · Linkshandig',
			'editor.handednessHint' => 'Rechtshandigen bereiken de gereedschappen gemakkelijker als het paneel links zit. Linkshandigen kiezen daarentegen de rechterkant.',
			'editor.drawingArea' => 'Tekenruimte',
			'editor.enableDebugMode' => 'Debug-modus inschakelen',
			'editor.debugModeHint' => 'Toont bounding-boxen en convexe hulzen in de editor en in de AI-assistent.',
			'editor.useLineSimplifier' => 'Lijn-simplifier gebruiken',
			'editor.lineSimplifierHint' => 'Maakt je lijnen automatisch glad voor een rustigere uitstraling.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Gladheidsintensiteit (${value})',
			'editor.smoothingHint' => 'Lage waarden behouden meer details, hoge waarden maken sterker glad.',
			'editor.minTolerance' => ({required Object value}) => 'Minimale tolerantiewaarde (${value} px)',
			'editor.minToleranceHint' => 'Stelt de ondergrens voor het gladmaken in – hogere waarden filteren kleine tandjes.',
			'editor.aiPersona' => 'AI-assistent persona',
			'editor.choosePersonaStyle' => 'Kies de stijl van je AI-assistent',
			'editor.personaStyleHint' => 'De persona bepaalt hoe de assistent met je communiceert.',
			'editor.strictTrainer' => 'Strenge trainer',
			'editor.strictTrainerHint' => 'Directe, harde kritiek zoals een Russische Olympische trainer',
			'editor.encouragingMentor' => 'Bemoedigende mentor',
			'editor.encouragingMentorHint' => 'Positieve versterking en motiverende feedback',
			'editor.customPersona' => 'Aangepaste',
			'editor.customPersonaHint' => 'Stel je eigen systeem-prompt in',
			'editor.yourSystemPrompt' => 'Jouw systeem-prompt',
			'editor.systemPromptPlaceholder' => 'Beschrijf hoe de assistent zich moet gedragen…',
			'editor.systemPromptHint' => 'De systeem-prompt definieert de persoonlijkheid en het gedrag van de assistent bij alle verzoeken.',
			'editor.currentStyle' => 'Huidige stijl',
			'editor.strictTrainerDescription' => 'De assistent geeft je harde, directe feedback. Hij accepteert geen middelmatigheid en motiveert je door constructieve kritiek tot topprestaties.',
			'editor.encouragingMentorDescription' => 'De assistent prijst je vorderingen en biedt bemoedigende feedback. Fouten worden gepresenteerd als leermogelijkheden.',
			'editor.customPersonaDescription' => 'De assistent gedraagt zich volgens je eigen systeem-prompt.',
			'pdfDialog.selectPdf' => 'PDF selecteren',
			'pdfDialog.analyzePdf' => 'PDF analyseren',
			'pdfDialog.ready' => 'Klaar',
			'pdfDialog.processPdf' => 'PDF verwerken',
			'pdfDialog.importComplete' => 'Importeren voltooid',
			'pdfDialog.selectPdfFile' => 'Kies een PDF-bestand...',
			'pdfDialog.analyzingPdf' => 'PDF wordt geanalyseerd...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} pagina\'s gevonden',
			'pdfDialog.textExtractionBackground' => 'Textextractie vindt op de achtergrond plaats.',
			'pdfDialog.couldNotReadPdf' => 'De PDF-bestand kon niet gelezen worden.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} pagina\'s geïmporteerd',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k tekens geëxtraheerd',
			'pdfDialog.extractedTextContext' => 'De geëxtraheerde tekst wordt als context voor de AI-assistent gebruikt.',
			'pdfDialog.textExtractionDuration' => 'De textextractie kan enkele seconden per pagina duren.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Pagina ${current} van ${total} aan het renderen...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Tekst van pagina ${current} van ${total} aan het extraheren...',
			'pdfDialog.recognizingTasks' => 'Taken aan het herkennen...',
			_ => null,
		};
	}
}
