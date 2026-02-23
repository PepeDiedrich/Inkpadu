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
class TranslationsPl extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPl({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pl,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pl>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsPl _root = this; // ignore: unused_field

	@override 
	TranslationsPl $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPl(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppPl app = _TranslationsAppPl._(_root);
	@override late final _TranslationsCommonPl common = _TranslationsCommonPl._(_root);
	@override late final _TranslationsAuthPl auth = _TranslationsAuthPl._(_root);
	@override late final _TranslationsNavPl nav = _TranslationsNavPl._(_root);
	@override late final _TranslationsNotesPl notes = _TranslationsNotesPl._(_root);
	@override late final _TranslationsDrawingPl drawing = _TranslationsDrawingPl._(_root);
	@override late final _TranslationsPaperPl paper = _TranslationsPaperPl._(_root);
	@override late final _TranslationsAiPl ai = _TranslationsAiPl._(_root);
	@override late final _TranslationsPdfPl pdf = _TranslationsPdfPl._(_root);
	@override late final _TranslationsSettingsPl settings = _TranslationsSettingsPl._(_root);
	@override late final _TranslationsErrorsPl errors = _TranslationsErrorsPl._(_root);
	@override late final _TranslationsOnboardingPl onboarding = _TranslationsOnboardingPl._(_root);
	@override late final _TranslationsEditorPl editor = _TranslationsEditorPl._(_root);
	@override late final _TranslationsPdfDialogPl pdfDialog = _TranslationsPdfDialogPl._(_root);
}

// Path: app
class _TranslationsAppPl extends TranslationsAppDe {
	_TranslationsAppPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Twoje notatki, twój styl';
}

// Path: common
class _TranslationsCommonPl extends TranslationsCommonDe {
	_TranslationsCommonPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get save => 'Zapisz';
	@override String get cancel => 'Anuluj';
	@override String get delete => 'Usuń';
	@override String get edit => 'Edytuj';
	@override String get close => 'Zamknij';
	@override String get confirm => 'Potwierdź';
	@override String get loading => 'Ładowanie...';
	@override String get error => 'Błąd';
	@override String get success => 'Sukces';
	@override String get retry => 'Spróbuj ponownie';
	@override String get search => 'Szukaj';
	@override String get settings => 'Ustawienia';
	@override String get back => 'Cofnij';
	@override String get next => 'Dalej';
	@override String get done => 'Gotowe';
	@override String get yes => 'Tak';
	@override String get no => 'Nie';
	@override String get apply => 'Zastosuj';
	@override String get loggedOut => 'Wylogowano';
	@override String get justNow => 'Właśnie teraz';
	@override String minutesAgo({required Object count}) => 'przed ${count} minutami';
	@override String hoursAgo({required Object count}) => 'przed ${count} godzinami';
	@override String get yesterday => 'Wczoraj';
}

// Path: auth
class _TranslationsAuthPl extends TranslationsAuthDe {
	_TranslationsAuthPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get login => 'Zaloguj się';
	@override String get logout => 'Wyloguj się';
	@override String get register => 'Zarejestruj się';
	@override String get email => 'E-mail';
	@override String get password => 'Hasło';
	@override String get forgotPassword => 'Zapomniałeś hasła?';
	@override String get welcomeBack => 'Witaj ponownie!';
	@override String get createAccount => 'Stwórz konto';
	@override String get loginWithGoogle => 'Zaloguj się przez Google';
	@override String get loginWithApple => 'Zaloguj się przez Apple';
}

// Path: nav
class _TranslationsNavPl extends TranslationsNavDe {
	_TranslationsNavPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notatki';
	@override String get settings => 'Ustawienia';
}

// Path: notes
class _TranslationsNotesPl extends TranslationsNotesDe {
	_TranslationsNotesPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notatki';
	@override String get newNote => 'Nowa notatka';
	@override String get untitled => 'Bez tytułu';
	@override String get unnamed => 'Nieoznakowana notatka';
	@override String get noContent => 'Brak treści';
	@override String get noteDate => 'Notatka';
	@override String get lastEdited => 'Ostatnio edytowane';
	@override String get deleteNote => 'Usuń notatkę';
	@override String deleteNoteConfirm({required Object title}) => 'Czy na pewno chcesz usunąć "${title}"?';
	@override String get deleteNoteTooltip => 'Usuń notatkę';
	@override String get noNotes => 'Brak ręcznych notatek';
	@override String get createFirst => 'Stwórz swoją pierwszą notatkę';
	@override String get createNew => 'Utwórz nową notatkę';
	@override String get export => 'Eksportuj';
	@override String get share => 'Udostępnij';
	@override String get duplicate => 'Duplikuj';
	@override String get openNote => 'Otwórz notatkę';
	@override String get adjustTitlePaper => 'Dostosuj tytuł i papier';
	@override String get emptyNote => 'Pusta notatka';
	@override String get emptyNoteSubtitle => 'Rozpocznij na pustej stronie';
}

// Path: drawing
class _TranslationsDrawingPl extends TranslationsDrawingDe {
	_TranslationsDrawingPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Długopis';
	@override String get pencil => 'Ołówek';
	@override String get highlighter => 'Marker';
	@override String get eraser => 'Gumka';
	@override String get select => 'Wybierz';
	@override String get undo => 'Cofnij';
	@override String get redo => 'Ponów';
	@override String get clear => 'Wyczyść';
	@override String get clearConfirm => 'Czy na pewno chcesz usunąć wszystkie rysunki?';
	@override String get color => 'Kolor';
	@override String get colorWheel => 'Koło kolorów';
	@override String get symbol => 'Symbol';
	@override String get strokeWidth => 'Grubość kreski';
	@override String get zoomIn => 'Powiększ';
	@override String get zoomOut => 'Pomniejsz';
	@override String get markerMode => 'Tryb markera (przezroczysty)';
	@override String get pressureDetection => 'Wykrywanie siły nacisku';
	@override String customizeTool({required Object name}) => 'Dostosuj ${name}';
	@override String get fineliner => 'Długopis';
	@override String get inkRoller => 'Pióro';
	@override String get fountainPen => 'Pióro wieczne';
	@override String get marker => 'Marker';
	@override String get neon => 'Neon';
	@override String get lasso => 'Lasso';
}

// Path: paper
class _TranslationsPaperPl extends TranslationsPaperDe {
	_TranslationsPaperPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Czysta';
	@override String get lined => 'W linię';
	@override String get grid => 'W kratkę';
	@override String get dotted => 'W kropki';
}

// Path: ai
class _TranslationsAiPl extends TranslationsAiDe {
	_TranslationsAiPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Funkcje AI';
	@override String get assistant => 'Asystent AI';
	@override String get recognize => 'Rozpoznawanie tekstu';
	@override String get recognizing => 'Rozpoznawanie...';
	@override String get summarize => 'Podsumuj';
	@override String get extractTasks => 'Wyodrębnij zadania';
	@override String get translate => 'Tłumacz';
	@override String get noTextFound => 'Nie znaleziono tekstu';
	@override String get persona => 'Personalizacja asystenta AI';
	@override String get personaSubtitle => 'Wybierz styl asystenta';
	@override String get helpMe => 'Pomóż mi';
	@override String get helpMeTitle => 'Odpowiedź AI';
	@override String get analyzingSelection => 'Analizowanie zaznaczenia…';
	@override String get noSelection => 'Najpierw zaznacz coś lasssem.';
	@override String get helpMeNotConfigured => 'AI nie jest jeszcze skonfigurowane.';
}

// Path: pdf
class _TranslationsPdfPl extends TranslationsPdfDe {
	_TranslationsPdfPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get import => 'Importuj PDF';
	@override String get importSubtitle => 'Tekst zostanie automatycznie wyodrębniony';
	@override String get export => 'Eksportuj jako PDF';
	@override String get exporting => 'Tworzenie PDF...';
	@override String exportFailed({required Object error}) => 'Nie udało się wyeksportować PDF: ${error}';
	@override String get page => 'Strona';
	@override String get of => 'z';
}

// Path: settings
class _TranslationsSettingsPl extends TranslationsSettingsDe {
	_TranslationsSettingsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ustawienia';
	@override String get general => 'Ogólne';
	@override String get theme => 'Motyw';
	@override String get themeSubtitle => 'Jasny · Ciemny · Systemowy';
	@override String get darkMode => 'Tryb ciemny';
	@override String get lightMode => 'Tryb jasny';
	@override String get systemMode => 'Tryb systemowy';
	@override String get language => 'Język';
	@override String get languageSubtitle => 'Polski (beta)';
	@override String get sync => 'Synchronizacja';
	@override String get syncEnabled => 'Synchronizacja włączona';
	@override String get syncDisabled => 'Synchronizacja wyłączona';
	@override String get account => 'Konto';
	@override String get about => 'O aplikacji';
	@override String get version => 'Wersja';
	@override String get privacy => 'Prywatność';
	@override String get terms => 'Warunki korzystania';
	@override String get input => 'Wejście';
	@override String get inputDevices => 'Urządzenia wejściowe';
	@override String get inputDeviceSubtitle => 'Długopis · Dotyk · Mysz';
	@override String get automation => 'Automatyzacja';
	@override String get unlockPen => 'Odblokuj długopis';
	@override String get pen => 'Długopis';
	@override String get touch => 'Dotyk';
	@override String get mouse => 'Mysz';
	@override String get autoLockOnStylus => 'Automatycznie zablokuj przy użyciu rysika';
	@override String get editorSettings => 'Ustawienia edytora';
	@override String get noteEditor => 'Edytor notatek';
	@override String get noteEditorSubtitle => 'Panel po lewej · prawej';
	@override String get strokeWidths => 'Grubości pędzla';
	@override String get strokeWidthsSubtitle => 'Cienki · Średni · Gruby';
	@override String get palmRejection => 'Odrzucenie dłoni';
	@override String get palmRejectionSubtitle => 'Zapobiega niechcianym wprowadzaniom';
	@override String get assistPanel => 'Panel asystenta';
	@override String get leftRightHanded => 'Dla leworęcznych · Praworęcznych';
	@override String get rightLeftHanded => 'Dla praworęcznych · Leworęcznych';
	@override String get drawingArea => 'Obszar rysunku';
	@override String get debugMode => 'Włącz tryb debugowania';
	@override String get cloud => 'Chmura i synchronizacja';
	@override String get storageTarget => 'Cel przechowywania';
	@override String get storageSubtitle => 'Chmura Inkpadu (bezpłatnie)';
	@override String get encryption => 'Szyfrowanie';
	@override String get encryptionSubtitle => 'Szyfrowanie end-to-end aktywne';
}

// Path: errors
class _TranslationsErrorsPl extends TranslationsErrorsDe {
	_TranslationsErrorsPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Błąd sieci. Sprawdź swoje połączenie.';
	@override String get unknownError => 'Wystąpił nieznany błąd.';
	@override String get authError => 'Błąd logowania. Proszę spróbować ponownie.';
	@override String get saveError => 'Nie udało się zapisać.';
	@override String get loadError => 'Nie udało się załadować.';
	@override String get exportError => 'Nie udało się wyeksportować.';
	@override String loginFailed({required Object provider}) => 'Logowanie (${provider}) nie powiodło się';
}

// Path: onboarding
class _TranslationsOnboardingPl extends TranslationsOnboardingDe {
	_TranslationsOnboardingPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Witaj w Inkpadu';
	@override String get description => 'Szkicuj pomysły, pisz notatki i organizuj swoje myśli naturalnym pismem.';
	@override String get digitalNotebook => 'Twoje cyfrowe notatnik';
	@override String get digitalNotebookDescription => 'Ręczne doświadczenie, zoptymalizowane dla kreatywności i koncentracji – całkowicie bez rozproszeń.';
	@override String get connecting => 'Łączenie…';
	@override String get loginWithGitHub => 'Zaloguj się przez GitHub';
	@override String get loginWithGoogle => 'Zaloguj się przez Google';
}

// Path: editor
class _TranslationsEditorPl extends TranslationsEditorDe {
	_TranslationsEditorPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nowa notatka';
	@override String get editNote => 'Edytuj notatkę';
	@override String get title => 'Tytuł';
	@override String get writeNote => 'Napisz swoją notatkę...';
	@override String get assistPanel => 'Panel asystenta';
	@override String get leftRightHanded => 'Dla leworęcznych · praworęcznych';
	@override String get rightLeftHanded => 'Dla praworęcznych · leworęcznych';
	@override String get handednessHint => 'Praworęczni mają łatwiejszy dostęp do narzędzi, gdy panel jest po lewej stronie. Leworęczni powinni wybrać prawą stronę.';
	@override String get drawingArea => 'Obszar rysowania';
	@override String get enableDebugMode => 'Aktywuj tryb debugowania';
	@override String get debugModeHint => 'Wyświetla ramki ograniczające i wypukłe osłony w edytorze oraz w asystencie AI.';
	@override String get useLineSimplifier => 'Użyj uproszczenia linii';
	@override String get lineSimplifierHint => 'Automatycznie wygładza twoje linie dla uzyskania płynniejszych kresk.';
	@override String smoothingIntensity({required Object value}) => 'Intensywność wygładzania (${value})';
	@override String get smoothingHint => 'Niskie wartości zachowują więcej szczegółów, wysokie wartości bardziej wygładzają.';
	@override String minTolerance({required Object value}) => 'Minimalna tolerancja (${value} px)';
	@override String get minToleranceHint => 'Ustal minimalny próg dla wygładzania – wyższe wartości filtrują drobne ząbkowania.';
	@override String get aiPersona => 'Osobowość Asystenta AI';
	@override String get choosePersonaStyle => 'Wybierz styl swojego asystenta AI';
	@override String get personaStyleHint => 'Osobowość określa, jak asystent z tobą współpracuje.';
	@override String get strictTrainer => 'Surowy trener';
	@override String get strictTrainerHint => 'Bezpośrednia, ostra krytyka jak rosyjski trener olimpijski';
	@override String get encouragingMentor => 'Motywujący mentor';
	@override String get encouragingMentorHint => 'Pozytywne wzmocnienia i motywujące informacje zwrotne';
	@override String get customPersona => 'Niestandardowy';
	@override String get customPersonaHint => 'Ustal własny system-prompt';
	@override String get yourSystemPrompt => 'Twój system-prompt';
	@override String get systemPromptPlaceholder => 'Opisz, jak asystent powinien się zachowywać…';
	@override String get systemPromptHint => 'System-prompt określa osobowość i zachowanie asystenta w każdej interakcji.';
	@override String get currentStyle => 'Aktualny styl';
	@override String get strictTrainerDescription => 'Asystent daje ci ostrą, bezpośrednią wiadomość. Nie akceptuje przeciętności i motywuje cię do największej wydajności poprzez konstruktywną krytykę.';
	@override String get encouragingMentorDescription => 'Asystent chwali twoje postępy i daje ci motywujące informacje zwrotne. Błędy są postrzegane jako możliwości do nauki.';
	@override String get customPersonaDescription => 'Asystent zachowuje się zgodnie z twoim własnym system-prompt.';
}

// Path: pdfDialog
class _TranslationsPdfDialogPl extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Wybierz plik PDF';
	@override String get analyzePdf => 'Analizuj PDF';
	@override String get ready => 'Gotowe';
	@override String get processPdf => 'Przetwarzam PDF';
	@override String get importComplete => 'Import zakończony';
	@override String get selectPdfFile => 'Proszę wybrać plik PDF...';
	@override String get analyzingPdf => 'Analizuję PDF...';
	@override String pagesFound({required Object count}) => 'Znaleziono ${count} stron(y)';
	@override String get textExtractionBackground => 'Ekstrakcja tekstu odbywa się w tle.';
	@override String get couldNotReadPdf => 'Nie można odczytać pliku PDF.';
	@override String pagesImported({required Object count}) => 'Zaimportowano ${count} stron(y)';
	@override String charactersExtracted({required Object count}) => '~${count}k znaków wyodrębniono';
	@override String get extractedTextContext => 'Wyodrębniony tekst jest używany jako kontekst dla asystenta AI.';
	@override String get textExtractionDuration => 'Ekstrakcja tekstu może zająć kilka sekund na stronę.';
	@override String renderingPage({required Object current, required Object total}) => 'Renderuję stronę ${current} z ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Ekstrakcja tekstu z strony ${current} z ${total}...';
	@override String get recognizingTasks => 'Rozpoznawanie zadań...';
}

/// The flat map containing all translations for locale <pl>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPl {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Twoje notatki, twój styl',
			'common.save' => 'Zapisz',
			'common.cancel' => 'Anuluj',
			'common.delete' => 'Usuń',
			'common.edit' => 'Edytuj',
			'common.close' => 'Zamknij',
			'common.confirm' => 'Potwierdź',
			'common.loading' => 'Ładowanie...',
			'common.error' => 'Błąd',
			'common.success' => 'Sukces',
			'common.retry' => 'Spróbuj ponownie',
			'common.search' => 'Szukaj',
			'common.settings' => 'Ustawienia',
			'common.back' => 'Cofnij',
			'common.next' => 'Dalej',
			'common.done' => 'Gotowe',
			'common.yes' => 'Tak',
			'common.no' => 'Nie',
			'common.apply' => 'Zastosuj',
			'common.loggedOut' => 'Wylogowano',
			'common.justNow' => 'Właśnie teraz',
			'common.minutesAgo' => ({required Object count}) => 'przed ${count} minutami',
			'common.hoursAgo' => ({required Object count}) => 'przed ${count} godzinami',
			'common.yesterday' => 'Wczoraj',
			'auth.login' => 'Zaloguj się',
			'auth.logout' => 'Wyloguj się',
			'auth.register' => 'Zarejestruj się',
			'auth.email' => 'E-mail',
			'auth.password' => 'Hasło',
			'auth.forgotPassword' => 'Zapomniałeś hasła?',
			'auth.welcomeBack' => 'Witaj ponownie!',
			'auth.createAccount' => 'Stwórz konto',
			'auth.loginWithGoogle' => 'Zaloguj się przez Google',
			'auth.loginWithApple' => 'Zaloguj się przez Apple',
			'nav.notes' => 'Notatki',
			'nav.settings' => 'Ustawienia',
			'notes.title' => 'Notatki',
			'notes.newNote' => 'Nowa notatka',
			'notes.untitled' => 'Bez tytułu',
			'notes.unnamed' => 'Nieoznakowana notatka',
			'notes.noContent' => 'Brak treści',
			'notes.noteDate' => 'Notatka',
			'notes.lastEdited' => 'Ostatnio edytowane',
			'notes.deleteNote' => 'Usuń notatkę',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Czy na pewno chcesz usunąć "${title}"?',
			'notes.deleteNoteTooltip' => 'Usuń notatkę',
			'notes.noNotes' => 'Brak ręcznych notatek',
			'notes.createFirst' => 'Stwórz swoją pierwszą notatkę',
			'notes.createNew' => 'Utwórz nową notatkę',
			'notes.export' => 'Eksportuj',
			'notes.share' => 'Udostępnij',
			'notes.duplicate' => 'Duplikuj',
			'notes.openNote' => 'Otwórz notatkę',
			'notes.adjustTitlePaper' => 'Dostosuj tytuł i papier',
			'notes.emptyNote' => 'Pusta notatka',
			'notes.emptyNoteSubtitle' => 'Rozpocznij na pustej stronie',
			'drawing.pen' => 'Długopis',
			'drawing.pencil' => 'Ołówek',
			'drawing.highlighter' => 'Marker',
			'drawing.eraser' => 'Gumka',
			'drawing.select' => 'Wybierz',
			'drawing.undo' => 'Cofnij',
			'drawing.redo' => 'Ponów',
			'drawing.clear' => 'Wyczyść',
			'drawing.clearConfirm' => 'Czy na pewno chcesz usunąć wszystkie rysunki?',
			'drawing.color' => 'Kolor',
			'drawing.colorWheel' => 'Koło kolorów',
			'drawing.symbol' => 'Symbol',
			'drawing.strokeWidth' => 'Grubość kreski',
			'drawing.zoomIn' => 'Powiększ',
			'drawing.zoomOut' => 'Pomniejsz',
			'drawing.markerMode' => 'Tryb markera (przezroczysty)',
			'drawing.pressureDetection' => 'Wykrywanie siły nacisku',
			'drawing.customizeTool' => ({required Object name}) => 'Dostosuj ${name}',
			'drawing.fineliner' => 'Długopis',
			'drawing.inkRoller' => 'Pióro',
			'drawing.fountainPen' => 'Pióro wieczne',
			'drawing.marker' => 'Marker',
			'drawing.neon' => 'Neon',
			'drawing.lasso' => 'Lasso',
			'paper.plain' => 'Czysta',
			'paper.lined' => 'W linię',
			'paper.grid' => 'W kratkę',
			'paper.dotted' => 'W kropki',
			'ai.title' => 'Funkcje AI',
			'ai.assistant' => 'Asystent AI',
			'ai.recognize' => 'Rozpoznawanie tekstu',
			'ai.recognizing' => 'Rozpoznawanie...',
			'ai.summarize' => 'Podsumuj',
			'ai.extractTasks' => 'Wyodrębnij zadania',
			'ai.translate' => 'Tłumacz',
			'ai.noTextFound' => 'Nie znaleziono tekstu',
			'ai.persona' => 'Personalizacja asystenta AI',
			'ai.personaSubtitle' => 'Wybierz styl asystenta',
			'ai.helpMe' => 'Pomóż mi',
			'ai.helpMeTitle' => 'Odpowiedź AI',
			'ai.analyzingSelection' => 'Analizowanie zaznaczenia…',
			'ai.noSelection' => 'Najpierw zaznacz coś lasssem.',
			'ai.helpMeNotConfigured' => 'AI nie jest jeszcze skonfigurowane.',
			'pdf.import' => 'Importuj PDF',
			'pdf.importSubtitle' => 'Tekst zostanie automatycznie wyodrębniony',
			'pdf.export' => 'Eksportuj jako PDF',
			'pdf.exporting' => 'Tworzenie PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Nie udało się wyeksportować PDF: ${error}',
			'pdf.page' => 'Strona',
			'pdf.of' => 'z',
			'settings.title' => 'Ustawienia',
			'settings.general' => 'Ogólne',
			'settings.theme' => 'Motyw',
			'settings.themeSubtitle' => 'Jasny · Ciemny · Systemowy',
			'settings.darkMode' => 'Tryb ciemny',
			'settings.lightMode' => 'Tryb jasny',
			'settings.systemMode' => 'Tryb systemowy',
			'settings.language' => 'Język',
			'settings.languageSubtitle' => 'Polski (beta)',
			'settings.sync' => 'Synchronizacja',
			'settings.syncEnabled' => 'Synchronizacja włączona',
			'settings.syncDisabled' => 'Synchronizacja wyłączona',
			'settings.account' => 'Konto',
			'settings.about' => 'O aplikacji',
			'settings.version' => 'Wersja',
			'settings.privacy' => 'Prywatność',
			'settings.terms' => 'Warunki korzystania',
			'settings.input' => 'Wejście',
			'settings.inputDevices' => 'Urządzenia wejściowe',
			'settings.inputDeviceSubtitle' => 'Długopis · Dotyk · Mysz',
			'settings.automation' => 'Automatyzacja',
			'settings.unlockPen' => 'Odblokuj długopis',
			'settings.pen' => 'Długopis',
			'settings.touch' => 'Dotyk',
			'settings.mouse' => 'Mysz',
			'settings.autoLockOnStylus' => 'Automatycznie zablokuj przy użyciu rysika',
			'settings.editorSettings' => 'Ustawienia edytora',
			'settings.noteEditor' => 'Edytor notatek',
			'settings.noteEditorSubtitle' => 'Panel po lewej · prawej',
			'settings.strokeWidths' => 'Grubości pędzla',
			'settings.strokeWidthsSubtitle' => 'Cienki · Średni · Gruby',
			'settings.palmRejection' => 'Odrzucenie dłoni',
			'settings.palmRejectionSubtitle' => 'Zapobiega niechcianym wprowadzaniom',
			'settings.assistPanel' => 'Panel asystenta',
			'settings.leftRightHanded' => 'Dla leworęcznych · Praworęcznych',
			'settings.rightLeftHanded' => 'Dla praworęcznych · Leworęcznych',
			'settings.drawingArea' => 'Obszar rysunku',
			'settings.debugMode' => 'Włącz tryb debugowania',
			'settings.cloud' => 'Chmura i synchronizacja',
			'settings.storageTarget' => 'Cel przechowywania',
			'settings.storageSubtitle' => 'Chmura Inkpadu (bezpłatnie)',
			'settings.encryption' => 'Szyfrowanie',
			'settings.encryptionSubtitle' => 'Szyfrowanie end-to-end aktywne',
			'errors.networkError' => 'Błąd sieci. Sprawdź swoje połączenie.',
			'errors.unknownError' => 'Wystąpił nieznany błąd.',
			'errors.authError' => 'Błąd logowania. Proszę spróbować ponownie.',
			'errors.saveError' => 'Nie udało się zapisać.',
			'errors.loadError' => 'Nie udało się załadować.',
			'errors.exportError' => 'Nie udało się wyeksportować.',
			'errors.loginFailed' => ({required Object provider}) => 'Logowanie (${provider}) nie powiodło się',
			'onboarding.welcome' => 'Witaj w Inkpadu',
			'onboarding.description' => 'Szkicuj pomysły, pisz notatki i organizuj swoje myśli naturalnym pismem.',
			'onboarding.digitalNotebook' => 'Twoje cyfrowe notatnik',
			'onboarding.digitalNotebookDescription' => 'Ręczne doświadczenie, zoptymalizowane dla kreatywności i koncentracji – całkowicie bez rozproszeń.',
			'onboarding.connecting' => 'Łączenie…',
			'onboarding.loginWithGitHub' => 'Zaloguj się przez GitHub',
			'onboarding.loginWithGoogle' => 'Zaloguj się przez Google',
			'editor.newNote' => 'Nowa notatka',
			'editor.editNote' => 'Edytuj notatkę',
			'editor.title' => 'Tytuł',
			'editor.writeNote' => 'Napisz swoją notatkę...',
			'editor.assistPanel' => 'Panel asystenta',
			'editor.leftRightHanded' => 'Dla leworęcznych · praworęcznych',
			'editor.rightLeftHanded' => 'Dla praworęcznych · leworęcznych',
			'editor.handednessHint' => 'Praworęczni mają łatwiejszy dostęp do narzędzi, gdy panel jest po lewej stronie. Leworęczni powinni wybrać prawą stronę.',
			'editor.drawingArea' => 'Obszar rysowania',
			'editor.enableDebugMode' => 'Aktywuj tryb debugowania',
			'editor.debugModeHint' => 'Wyświetla ramki ograniczające i wypukłe osłony w edytorze oraz w asystencie AI.',
			'editor.useLineSimplifier' => 'Użyj uproszczenia linii',
			'editor.lineSimplifierHint' => 'Automatycznie wygładza twoje linie dla uzyskania płynniejszych kresk.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Intensywność wygładzania (${value})',
			'editor.smoothingHint' => 'Niskie wartości zachowują więcej szczegółów, wysokie wartości bardziej wygładzają.',
			'editor.minTolerance' => ({required Object value}) => 'Minimalna tolerancja (${value} px)',
			'editor.minToleranceHint' => 'Ustal minimalny próg dla wygładzania – wyższe wartości filtrują drobne ząbkowania.',
			'editor.aiPersona' => 'Osobowość Asystenta AI',
			'editor.choosePersonaStyle' => 'Wybierz styl swojego asystenta AI',
			'editor.personaStyleHint' => 'Osobowość określa, jak asystent z tobą współpracuje.',
			'editor.strictTrainer' => 'Surowy trener',
			'editor.strictTrainerHint' => 'Bezpośrednia, ostra krytyka jak rosyjski trener olimpijski',
			'editor.encouragingMentor' => 'Motywujący mentor',
			'editor.encouragingMentorHint' => 'Pozytywne wzmocnienia i motywujące informacje zwrotne',
			'editor.customPersona' => 'Niestandardowy',
			'editor.customPersonaHint' => 'Ustal własny system-prompt',
			'editor.yourSystemPrompt' => 'Twój system-prompt',
			'editor.systemPromptPlaceholder' => 'Opisz, jak asystent powinien się zachowywać…',
			'editor.systemPromptHint' => 'System-prompt określa osobowość i zachowanie asystenta w każdej interakcji.',
			'editor.currentStyle' => 'Aktualny styl',
			'editor.strictTrainerDescription' => 'Asystent daje ci ostrą, bezpośrednią wiadomość. Nie akceptuje przeciętności i motywuje cię do największej wydajności poprzez konstruktywną krytykę.',
			'editor.encouragingMentorDescription' => 'Asystent chwali twoje postępy i daje ci motywujące informacje zwrotne. Błędy są postrzegane jako możliwości do nauki.',
			'editor.customPersonaDescription' => 'Asystent zachowuje się zgodnie z twoim własnym system-prompt.',
			'pdfDialog.selectPdf' => 'Wybierz plik PDF',
			'pdfDialog.analyzePdf' => 'Analizuj PDF',
			'pdfDialog.ready' => 'Gotowe',
			'pdfDialog.processPdf' => 'Przetwarzam PDF',
			'pdfDialog.importComplete' => 'Import zakończony',
			'pdfDialog.selectPdfFile' => 'Proszę wybrać plik PDF...',
			'pdfDialog.analyzingPdf' => 'Analizuję PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => 'Znaleziono ${count} stron(y)',
			'pdfDialog.textExtractionBackground' => 'Ekstrakcja tekstu odbywa się w tle.',
			'pdfDialog.couldNotReadPdf' => 'Nie można odczytać pliku PDF.',
			'pdfDialog.pagesImported' => ({required Object count}) => 'Zaimportowano ${count} stron(y)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k znaków wyodrębniono',
			'pdfDialog.extractedTextContext' => 'Wyodrębniony tekst jest używany jako kontekst dla asystenta AI.',
			'pdfDialog.textExtractionDuration' => 'Ekstrakcja tekstu może zająć kilka sekund na stronę.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Renderuję stronę ${current} z ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Ekstrakcja tekstu z strony ${current} z ${total}...',
			'pdfDialog.recognizingTasks' => 'Rozpoznawanie zadań...',
			_ => null,
		};
	}
}
