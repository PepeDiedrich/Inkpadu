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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppEn app = _TranslationsAppEn._(_root);
	@override late final _TranslationsCommonEn common = _TranslationsCommonEn._(_root);
	@override late final _TranslationsAuthEn auth = _TranslationsAuthEn._(_root);
	@override late final _TranslationsNavEn nav = _TranslationsNavEn._(_root);
	@override late final _TranslationsNotesEn notes = _TranslationsNotesEn._(_root);
	@override late final _TranslationsDrawingEn drawing = _TranslationsDrawingEn._(_root);
	@override late final _TranslationsPaperEn paper = _TranslationsPaperEn._(_root);
	@override late final _TranslationsAiEn ai = _TranslationsAiEn._(_root);
	@override late final _TranslationsPdfEn pdf = _TranslationsPdfEn._(_root);
	@override late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	@override late final _TranslationsErrorsEn errors = _TranslationsErrorsEn._(_root);
	@override late final _TranslationsOnboardingEn onboarding = _TranslationsOnboardingEn._(_root);
	@override late final _TranslationsEditorEn editor = _TranslationsEditorEn._(_root);
	@override late final _TranslationsPdfDialogEn pdfDialog = _TranslationsPdfDialogEn._(_root);
}

// Path: app
class _TranslationsAppEn extends TranslationsAppDe {
	_TranslationsAppEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Your notes, your way';
}

// Path: common
class _TranslationsCommonEn extends TranslationsCommonDe {
	_TranslationsCommonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get save => 'Save';
	@override String get cancel => 'Cancel';
	@override String get delete => 'Delete';
	@override String get edit => 'Edit';
	@override String get close => 'Close';
	@override String get confirm => 'Confirm';
	@override String get loading => 'Loading...';
	@override String get error => 'Error';
	@override String get success => 'Success';
	@override String get retry => 'Retry';
	@override String get search => 'Search';
	@override String get settings => 'Settings';
	@override String get back => 'Back';
	@override String get next => 'Next';
	@override String get done => 'Done';
	@override String get yes => 'Yes';
	@override String get no => 'No';
	@override String get apply => 'Apply';
	@override String get loggedOut => 'Logged out';
	@override String get justNow => 'Just now';
	@override String minutesAgo({required Object count}) => '${count} minute(s) ago';
	@override String hoursAgo({required Object count}) => '${count} hour(s) ago';
	@override String get yesterday => 'Yesterday';
}

// Path: auth
class _TranslationsAuthEn extends TranslationsAuthDe {
	_TranslationsAuthEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get login => 'Log in';
	@override String get logout => 'Log out';
	@override String get register => 'Register';
	@override String get email => 'Email';
	@override String get password => 'Password';
	@override String get forgotPassword => 'Forgot password?';
	@override String get welcomeBack => 'Welcome back!';
	@override String get createAccount => 'Create account';
	@override String get loginWithGoogle => 'Log in with Google';
	@override String get loginWithApple => 'Log in with Apple';
}

// Path: nav
class _TranslationsNavEn extends TranslationsNavDe {
	_TranslationsNavEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notes';
	@override String get settings => 'Settings';
}

// Path: notes
class _TranslationsNotesEn extends TranslationsNotesDe {
	_TranslationsNotesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notes';
	@override String get newNote => 'New note';
	@override String get createSubNote => 'Create sub-note';
	@override String get untitled => 'Untitled';
	@override String get unnamed => 'Unnamed note';
	@override String get noContent => 'No content yet';
	@override String get noteDate => 'Note';
	@override String get lastEdited => 'Last edited';
	@override String get deleteNote => 'Delete note';
	@override String deleteNoteConfirm({required Object title}) => 'Are you sure you want to delete "${title}"?';
	@override String get deleteNoteTooltip => 'Delete note';
	@override String get noNotes => 'No handwritten notes yet';
	@override String get createFirst => 'Create your first note';
	@override String get createNew => 'Create new note';
	@override String get export => 'Export';
	@override String get share => 'Share';
	@override String get duplicate => 'Duplicate';
	@override String get openNote => 'Open note';
	@override String get adjustTitlePaper => 'Adjust title & paper';
	@override String get chooseBackground => 'Choose background';
	@override String get emptyNote => 'Empty note';
	@override String get emptyNoteSubtitle => 'Start with a blank page';
}

// Path: drawing
class _TranslationsDrawingEn extends TranslationsDrawingDe {
	_TranslationsDrawingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Pen';
	@override String get pencil => 'Pencil';
	@override String get highlighter => 'Highlighter';
	@override String get eraser => 'Eraser';
	@override String get select => 'Select';
	@override String get undo => 'Undo';
	@override String get redo => 'Redo';
	@override String get clear => 'Clear';
	@override String get clearConfirm => 'Clear all drawings?';
	@override String get color => 'Color';
	@override String get colorWheel => 'Color wheel';
	@override String get symbol => 'Symbol';
	@override String get strokeWidth => 'Stroke width';
	@override String get zoomIn => 'Zoom in';
	@override String get zoomOut => 'Zoom out';
	@override String get markerMode => 'Marker mode (transparent)';
	@override String get pressureDetection => 'Pressure detection';
	@override String customizeTool({required Object name}) => 'Customize ${name}';
	@override String get fineliner => 'Fineliner';
	@override String get inkRoller => 'Ink roller';
	@override String get fountainPen => 'Fountain pen';
	@override String get marker => 'Marker';
	@override String get neon => 'Neon';
}

// Path: paper
class _TranslationsPaperEn extends TranslationsPaperDe {
	_TranslationsPaperEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Plain';
	@override String get lined => 'Lined';
	@override String get grid => 'Grid';
	@override String get dotted => 'Dotted';
}

// Path: ai
class _TranslationsAiEn extends TranslationsAiDe {
	_TranslationsAiEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Features';
	@override String get assistant => 'AI Assistant';
	@override String get recognize => 'Recognize text';
	@override String get recognizing => 'Recognizing...';
	@override String get summarize => 'Summarize';
	@override String get extractTasks => 'Extract tasks';
	@override String get translate => 'Translate';
	@override String get noTextFound => 'No text found';
	@override String get persona => 'AI Assistant Persona';
	@override String get personaSubtitle => 'Choose assistant style';
}

// Path: pdf
class _TranslationsPdfEn extends TranslationsPdfDe {
	_TranslationsPdfEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get import => 'Import PDF';
	@override String get importSubtitle => 'Text will be extracted automatically';
	@override String get export => 'Export as PDF';
	@override String get exporting => 'Creating PDF...';
	@override String exportFailed({required Object error}) => 'PDF export failed: ${error}';
	@override String get page => 'Page';
	@override String get of => 'of';
}

// Path: settings
class _TranslationsSettingsEn extends TranslationsSettingsDe {
	_TranslationsSettingsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get general => 'General';
	@override String get theme => 'Theme';
	@override String get themeSubtitle => 'Light · Dark · System';
	@override String get darkMode => 'Dark mode';
	@override String get lightMode => 'Light mode';
	@override String get systemMode => 'System default';
	@override String get language => 'Language';
	@override String get languageSubtitle => 'German (beta)';
	@override String get sync => 'Sync';
	@override String get syncEnabled => 'Sync enabled';
	@override String get syncDisabled => 'Sync disabled';
	@override String get account => 'Account';
	@override String get about => 'About';
	@override String get version => 'Version';
	@override String get privacy => 'Privacy';
	@override String get terms => 'Terms of service';
	@override String get input => 'Input';
	@override String get inputDevices => 'Input devices';
	@override String get inputDeviceSubtitle => 'Pen · Touch · Mouse';
	@override String get automation => 'Automation';
	@override String get unlockPen => 'Unlock pen';
	@override String get pen => 'Pen';
	@override String get touch => 'Touch';
	@override String get mouse => 'Mouse';
	@override String get autoLockOnStylus => 'Automatically lock on stylus';
	@override String get editorSettings => 'Editor settings';
	@override String get noteEditor => 'Note editor';
	@override String get noteEditorSubtitle => 'Side panel left · right';
	@override String get strokeWidths => 'Stroke widths';
	@override String get strokeWidthsSubtitle => 'Thin · Medium · Bold';
	@override String get palmRejection => 'Palm rejection';
	@override String get palmRejectionSubtitle => 'Prevents unwanted input';
	@override String get assistPanel => 'Assist panel';
	@override String get leftRightHanded => 'Left · Right-handed';
	@override String get rightLeftHanded => 'Right · Left-handed';
	@override String get drawingArea => 'Drawing area';
	@override String get debugMode => 'Enable debug mode';
	@override String get cloud => 'Cloud & Sync';
	@override String get storageTarget => 'Storage target';
	@override String get storageSubtitle => 'Inkpadu Cloud (free)';
	@override String get encryption => 'Encryption';
	@override String get encryptionSubtitle => 'End-to-end active';
}

// Path: errors
class _TranslationsErrorsEn extends TranslationsErrorsDe {
	_TranslationsErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Network error. Check your connection.';
	@override String get unknownError => 'An unknown error occurred.';
	@override String get authError => 'Authentication error. Please try again.';
	@override String get saveError => 'Save failed.';
	@override String get loadError => 'Load failed.';
	@override String get exportError => 'Export failed.';
	@override String loginFailed({required Object provider}) => 'Login (${provider}) failed';
}

// Path: onboarding
class _TranslationsOnboardingEn extends TranslationsOnboardingDe {
	_TranslationsOnboardingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Welcome to Inkpadu';
	@override String get description => 'Sketch ideas, write notes and organize your thoughts with natural handwriting.';
	@override String get digitalNotebook => 'Your digital notebook';
	@override String get digitalNotebookDescription => 'A handwriting experience optimized for creativity and focus – distraction-free.';
	@override String get connecting => 'Connecting…';
	@override String get loginWithGitHub => 'Log in with GitHub';
	@override String get loginWithGoogle => 'Log in with Google';
}

// Path: editor
class _TranslationsEditorEn extends TranslationsEditorDe {
	_TranslationsEditorEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'New note';
	@override String get editNote => 'Edit note';
	@override String get title => 'Title';
	@override String get writeNote => 'Write your note...';
	@override String get assistPanel => 'Assist panel';
	@override String get leftRightHanded => 'Left · Right-handed';
	@override String get rightLeftHanded => 'Right · Left-handed';
	@override String get handednessHint => 'Right-handers find the tools more comfortable on the left. Left-handers choose the right side.';
	@override String get drawingArea => 'Drawing area';
	@override String get enableDebugMode => 'Enable debug mode';
	@override String get debugModeHint => 'Shows bounding boxes and convex hulls in editor and AI assistant.';
	@override String get useLineSimplifier => 'Use line simplifier';
	@override String get lineSimplifierHint => 'Automatically smooths your strokes for calm lines.';
	@override String smoothingIntensity({required Object value}) => 'Smoothing intensity (${value})';
	@override String get smoothingHint => 'Lower values preserve more detail, higher values smooth more.';
	@override String minTolerance({required Object value}) => 'Minimum tolerance (${value} px)';
	@override String get minToleranceHint => 'Sets the lower limit for smoothing – higher values filter tiny bumps.';
	@override String get aiPersona => 'AI Assistant Persona';
	@override String get choosePersonaStyle => 'Choose your AI assistant\'s style';
	@override String get personaStyleHint => 'The persona determines how the assistant communicates with you.';
	@override String get strictTrainer => 'Strict trainer';
	@override String get strictTrainerHint => 'Direct, harsh criticism like a Russian Olympic trainer';
	@override String get encouragingMentor => 'Encouraging mentor';
	@override String get encouragingMentorHint => 'Positive reinforcement and motivating feedback';
	@override String get customPersona => 'Custom';
	@override String get customPersonaHint => 'Define your own system prompt';
	@override String get yourSystemPrompt => 'Your system prompt';
	@override String get systemPromptPlaceholder => 'Describe how the assistant should behave…';
	@override String get systemPromptHint => 'The system prompt defines the assistant\'s personality and behavior for all requests.';
	@override String get currentStyle => 'Current style';
	@override String get strictTrainerDescription => 'The assistant gives you hard, direct feedback. It accepts no mediocrity and motivates you to peak performance through constructive criticism.';
	@override String get encouragingMentorDescription => 'The assistant praises your progress and gives you encouraging feedback. Mistakes are presented as learning opportunities.';
	@override String get customPersonaDescription => 'The assistant behaves according to your own system prompt.';
}

// Path: pdfDialog
class _TranslationsPdfDialogEn extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Select PDF';
	@override String get analyzePdf => 'Analyze PDF';
	@override String get ready => 'Ready';
	@override String get processPdf => 'Process PDF';
	@override String get importComplete => 'Import complete';
	@override String get selectPdfFile => 'Please select a PDF file...';
	@override String get analyzingPdf => 'Analyzing PDF...';
	@override String pagesFound({required Object count}) => '${count} page(s) found';
	@override String get textExtractionBackground => 'Text extraction happens in background.';
	@override String get couldNotReadPdf => 'The PDF file could not be read.';
	@override String pagesImported({required Object count}) => '${count} page(s) imported';
	@override String charactersExtracted({required Object count}) => '~${count}k characters extracted';
	@override String get extractedTextContext => 'The extracted text is used as context for the AI assistant.';
	@override String get textExtractionDuration => 'Text extraction may take a few seconds per page.';
	@override String renderingPage({required Object current, required Object total}) => 'Rendering page ${current} of ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Extracting text from page ${current} of ${total}...';
	@override String get recognizingTasks => 'Recognizing tasks...';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Your notes, your way',
			'common.save' => 'Save',
			'common.cancel' => 'Cancel',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.close' => 'Close',
			'common.confirm' => 'Confirm',
			'common.loading' => 'Loading...',
			'common.error' => 'Error',
			'common.success' => 'Success',
			'common.retry' => 'Retry',
			'common.search' => 'Search',
			'common.settings' => 'Settings',
			'common.back' => 'Back',
			'common.next' => 'Next',
			'common.done' => 'Done',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.apply' => 'Apply',
			'common.loggedOut' => 'Logged out',
			'common.justNow' => 'Just now',
			'common.minutesAgo' => ({required Object count}) => '${count} minute(s) ago',
			'common.hoursAgo' => ({required Object count}) => '${count} hour(s) ago',
			'common.yesterday' => 'Yesterday',
			'auth.login' => 'Log in',
			'auth.logout' => 'Log out',
			'auth.register' => 'Register',
			'auth.email' => 'Email',
			'auth.password' => 'Password',
			'auth.forgotPassword' => 'Forgot password?',
			'auth.welcomeBack' => 'Welcome back!',
			'auth.createAccount' => 'Create account',
			'auth.loginWithGoogle' => 'Log in with Google',
			'auth.loginWithApple' => 'Log in with Apple',
			'nav.notes' => 'Notes',
			'nav.settings' => 'Settings',
			'notes.title' => 'Notes',
			'notes.newNote' => 'New note',
			'notes.createSubNote' => 'Create sub-note',
			'notes.untitled' => 'Untitled',
			'notes.unnamed' => 'Unnamed note',
			'notes.noContent' => 'No content yet',
			'notes.noteDate' => 'Note',
			'notes.lastEdited' => 'Last edited',
			'notes.deleteNote' => 'Delete note',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Are you sure you want to delete "${title}"?',
			'notes.deleteNoteTooltip' => 'Delete note',
			'notes.noNotes' => 'No handwritten notes yet',
			'notes.createFirst' => 'Create your first note',
			'notes.createNew' => 'Create new note',
			'notes.export' => 'Export',
			'notes.share' => 'Share',
			'notes.duplicate' => 'Duplicate',
			'notes.openNote' => 'Open note',
			'notes.adjustTitlePaper' => 'Adjust title & paper',
			'notes.chooseBackground' => 'Choose background',
			'notes.emptyNote' => 'Empty note',
			'notes.emptyNoteSubtitle' => 'Start with a blank page',
			'drawing.pen' => 'Pen',
			'drawing.pencil' => 'Pencil',
			'drawing.highlighter' => 'Highlighter',
			'drawing.eraser' => 'Eraser',
			'drawing.select' => 'Select',
			'drawing.undo' => 'Undo',
			'drawing.redo' => 'Redo',
			'drawing.clear' => 'Clear',
			'drawing.clearConfirm' => 'Clear all drawings?',
			'drawing.color' => 'Color',
			'drawing.colorWheel' => 'Color wheel',
			'drawing.symbol' => 'Symbol',
			'drawing.strokeWidth' => 'Stroke width',
			'drawing.zoomIn' => 'Zoom in',
			'drawing.zoomOut' => 'Zoom out',
			'drawing.markerMode' => 'Marker mode (transparent)',
			'drawing.pressureDetection' => 'Pressure detection',
			'drawing.customizeTool' => ({required Object name}) => 'Customize ${name}',
			'drawing.fineliner' => 'Fineliner',
			'drawing.inkRoller' => 'Ink roller',
			'drawing.fountainPen' => 'Fountain pen',
			'drawing.marker' => 'Marker',
			'drawing.neon' => 'Neon',
			'paper.plain' => 'Plain',
			'paper.lined' => 'Lined',
			'paper.grid' => 'Grid',
			'paper.dotted' => 'Dotted',
			'ai.title' => 'AI Features',
			'ai.assistant' => 'AI Assistant',
			'ai.recognize' => 'Recognize text',
			'ai.recognizing' => 'Recognizing...',
			'ai.summarize' => 'Summarize',
			'ai.extractTasks' => 'Extract tasks',
			'ai.translate' => 'Translate',
			'ai.noTextFound' => 'No text found',
			'ai.persona' => 'AI Assistant Persona',
			'ai.personaSubtitle' => 'Choose assistant style',
			'pdf.import' => 'Import PDF',
			'pdf.importSubtitle' => 'Text will be extracted automatically',
			'pdf.export' => 'Export as PDF',
			'pdf.exporting' => 'Creating PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF export failed: ${error}',
			'pdf.page' => 'Page',
			'pdf.of' => 'of',
			'settings.title' => 'Settings',
			'settings.general' => 'General',
			'settings.theme' => 'Theme',
			'settings.themeSubtitle' => 'Light · Dark · System',
			'settings.darkMode' => 'Dark mode',
			'settings.lightMode' => 'Light mode',
			'settings.systemMode' => 'System default',
			'settings.language' => 'Language',
			'settings.languageSubtitle' => 'German (beta)',
			'settings.sync' => 'Sync',
			'settings.syncEnabled' => 'Sync enabled',
			'settings.syncDisabled' => 'Sync disabled',
			'settings.account' => 'Account',
			'settings.about' => 'About',
			'settings.version' => 'Version',
			'settings.privacy' => 'Privacy',
			'settings.terms' => 'Terms of service',
			'settings.input' => 'Input',
			'settings.inputDevices' => 'Input devices',
			'settings.inputDeviceSubtitle' => 'Pen · Touch · Mouse',
			'settings.automation' => 'Automation',
			'settings.unlockPen' => 'Unlock pen',
			'settings.pen' => 'Pen',
			'settings.touch' => 'Touch',
			'settings.mouse' => 'Mouse',
			'settings.autoLockOnStylus' => 'Automatically lock on stylus',
			'settings.editorSettings' => 'Editor settings',
			'settings.noteEditor' => 'Note editor',
			'settings.noteEditorSubtitle' => 'Side panel left · right',
			'settings.strokeWidths' => 'Stroke widths',
			'settings.strokeWidthsSubtitle' => 'Thin · Medium · Bold',
			'settings.palmRejection' => 'Palm rejection',
			'settings.palmRejectionSubtitle' => 'Prevents unwanted input',
			'settings.assistPanel' => 'Assist panel',
			'settings.leftRightHanded' => 'Left · Right-handed',
			'settings.rightLeftHanded' => 'Right · Left-handed',
			'settings.drawingArea' => 'Drawing area',
			'settings.debugMode' => 'Enable debug mode',
			'settings.cloud' => 'Cloud & Sync',
			'settings.storageTarget' => 'Storage target',
			'settings.storageSubtitle' => 'Inkpadu Cloud (free)',
			'settings.encryption' => 'Encryption',
			'settings.encryptionSubtitle' => 'End-to-end active',
			'errors.networkError' => 'Network error. Check your connection.',
			'errors.unknownError' => 'An unknown error occurred.',
			'errors.authError' => 'Authentication error. Please try again.',
			'errors.saveError' => 'Save failed.',
			'errors.loadError' => 'Load failed.',
			'errors.exportError' => 'Export failed.',
			'errors.loginFailed' => ({required Object provider}) => 'Login (${provider}) failed',
			'onboarding.welcome' => 'Welcome to Inkpadu',
			'onboarding.description' => 'Sketch ideas, write notes and organize your thoughts with natural handwriting.',
			'onboarding.digitalNotebook' => 'Your digital notebook',
			'onboarding.digitalNotebookDescription' => 'A handwriting experience optimized for creativity and focus – distraction-free.',
			'onboarding.connecting' => 'Connecting…',
			'onboarding.loginWithGitHub' => 'Log in with GitHub',
			'onboarding.loginWithGoogle' => 'Log in with Google',
			'editor.newNote' => 'New note',
			'editor.editNote' => 'Edit note',
			'editor.title' => 'Title',
			'editor.writeNote' => 'Write your note...',
			'editor.assistPanel' => 'Assist panel',
			'editor.leftRightHanded' => 'Left · Right-handed',
			'editor.rightLeftHanded' => 'Right · Left-handed',
			'editor.handednessHint' => 'Right-handers find the tools more comfortable on the left. Left-handers choose the right side.',
			'editor.drawingArea' => 'Drawing area',
			'editor.enableDebugMode' => 'Enable debug mode',
			'editor.debugModeHint' => 'Shows bounding boxes and convex hulls in editor and AI assistant.',
			'editor.useLineSimplifier' => 'Use line simplifier',
			'editor.lineSimplifierHint' => 'Automatically smooths your strokes for calm lines.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Smoothing intensity (${value})',
			'editor.smoothingHint' => 'Lower values preserve more detail, higher values smooth more.',
			'editor.minTolerance' => ({required Object value}) => 'Minimum tolerance (${value} px)',
			'editor.minToleranceHint' => 'Sets the lower limit for smoothing – higher values filter tiny bumps.',
			'editor.aiPersona' => 'AI Assistant Persona',
			'editor.choosePersonaStyle' => 'Choose your AI assistant\'s style',
			'editor.personaStyleHint' => 'The persona determines how the assistant communicates with you.',
			'editor.strictTrainer' => 'Strict trainer',
			'editor.strictTrainerHint' => 'Direct, harsh criticism like a Russian Olympic trainer',
			'editor.encouragingMentor' => 'Encouraging mentor',
			'editor.encouragingMentorHint' => 'Positive reinforcement and motivating feedback',
			'editor.customPersona' => 'Custom',
			'editor.customPersonaHint' => 'Define your own system prompt',
			'editor.yourSystemPrompt' => 'Your system prompt',
			'editor.systemPromptPlaceholder' => 'Describe how the assistant should behave…',
			'editor.systemPromptHint' => 'The system prompt defines the assistant\'s personality and behavior for all requests.',
			'editor.currentStyle' => 'Current style',
			'editor.strictTrainerDescription' => 'The assistant gives you hard, direct feedback. It accepts no mediocrity and motivates you to peak performance through constructive criticism.',
			'editor.encouragingMentorDescription' => 'The assistant praises your progress and gives you encouraging feedback. Mistakes are presented as learning opportunities.',
			'editor.customPersonaDescription' => 'The assistant behaves according to your own system prompt.',
			'pdfDialog.selectPdf' => 'Select PDF',
			'pdfDialog.analyzePdf' => 'Analyze PDF',
			'pdfDialog.ready' => 'Ready',
			'pdfDialog.processPdf' => 'Process PDF',
			'pdfDialog.importComplete' => 'Import complete',
			'pdfDialog.selectPdfFile' => 'Please select a PDF file...',
			'pdfDialog.analyzingPdf' => 'Analyzing PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} page(s) found',
			'pdfDialog.textExtractionBackground' => 'Text extraction happens in background.',
			'pdfDialog.couldNotReadPdf' => 'The PDF file could not be read.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} page(s) imported',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k characters extracted',
			'pdfDialog.extractedTextContext' => 'The extracted text is used as context for the AI assistant.',
			'pdfDialog.textExtractionDuration' => 'Text extraction may take a few seconds per page.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Rendering page ${current} of ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Extracting text from page ${current} of ${total}...',
			'pdfDialog.recognizingTasks' => 'Recognizing tasks...',
			_ => null,
		};
	}
}
