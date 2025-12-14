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
	@override late final _TranslationsNotesPl notes = _TranslationsNotesPl._(_root);
	@override late final _TranslationsDrawingPl drawing = _TranslationsDrawingPl._(_root);
	@override late final _TranslationsAiPl ai = _TranslationsAiPl._(_root);
	@override late final _TranslationsPdfPl pdf = _TranslationsPdfPl._(_root);
	@override late final _TranslationsSettingsPl settings = _TranslationsSettingsPl._(_root);
	@override late final _TranslationsErrorsPl errors = _TranslationsErrorsPl._(_root);
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

// Path: notes
class _TranslationsNotesPl extends TranslationsNotesDe {
	_TranslationsNotesPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notatki';
	@override String get newNote => 'Nowa notatka';
	@override String get untitled => 'Bez tytułu';
	@override String get lastEdited => 'Ostatnio edytowane';
	@override String get deleteNote => 'Usuń notatkę';
	@override String deleteNoteConfirm({required Object title}) => 'Czy na pewno chcesz usunąć "${title}"?';
	@override String get noNotes => 'Brak ręcznych notatek';
	@override String get createFirst => 'Stwórz swoją pierwszą notatkę';
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
}

// Path: ai
class _TranslationsAiPl extends TranslationsAiDe {
	_TranslationsAiPl._(TranslationsPl root) : this._root = root, super.internal(root);

	final TranslationsPl _root; // ignore: unused_field

	// Translations
	@override String get title => 'Funkcje AI';
	@override String get recognize => 'Rozpoznawanie tekstu';
	@override String get recognizing => 'Rozpoznawanie...';
	@override String get summarize => 'Podsumuj';
	@override String get extractTasks => 'Wyodrębnij zadania';
	@override String get translate => 'Tłumacz';
	@override String get noTextFound => 'Nie znaleziono tekstu';
	@override String get persona => 'Personalizacja asystenta AI';
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
	@override String get theme => 'Motyw';
	@override String get darkMode => 'Tryb ciemny';
	@override String get lightMode => 'Tryb jasny';
	@override String get systemMode => 'Tryb systemowy';
	@override String get language => 'Język';
	@override String get sync => 'Synchronizacja';
	@override String get syncEnabled => 'Synchronizacja włączona';
	@override String get syncDisabled => 'Synchronizacja wyłączona';
	@override String get account => 'Konto';
	@override String get about => 'O aplikacji';
	@override String get version => 'Wersja';
	@override String get privacy => 'Prywatność';
	@override String get terms => 'Warunki korzystania';
	@override String get inputDevices => 'Urządzenia wejściowe';
	@override String get automation => 'Automatyzacja';
	@override String get unlockPen => 'Odblokuj długopis';
	@override String get pen => 'Długopis';
	@override String get touch => 'Dotyk';
	@override String get mouse => 'Mysz';
	@override String get autoLockOnStylus => 'Automatycznie zablokuj przy użyciu rysika';
	@override String get editorSettings => 'Ustawienia edytora';
	@override String get assistPanel => 'Panel asystenta';
	@override String get leftRightHanded => 'Dla leworęcznych · Praworęcznych';
	@override String get rightLeftHanded => 'Dla praworęcznych · Leworęcznych';
	@override String get drawingArea => 'Obszar rysunku';
	@override String get debugMode => 'Włącz tryb debugowania';
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
			'notes.title' => 'Notatki',
			'notes.newNote' => 'Nowa notatka',
			'notes.untitled' => 'Bez tytułu',
			'notes.lastEdited' => 'Ostatnio edytowane',
			'notes.deleteNote' => 'Usuń notatkę',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Czy na pewno chcesz usunąć "${title}"?',
			'notes.noNotes' => 'Brak ręcznych notatek',
			'notes.createFirst' => 'Stwórz swoją pierwszą notatkę',
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
			'ai.title' => 'Funkcje AI',
			'ai.recognize' => 'Rozpoznawanie tekstu',
			'ai.recognizing' => 'Rozpoznawanie...',
			'ai.summarize' => 'Podsumuj',
			'ai.extractTasks' => 'Wyodrębnij zadania',
			'ai.translate' => 'Tłumacz',
			'ai.noTextFound' => 'Nie znaleziono tekstu',
			'ai.persona' => 'Personalizacja asystenta AI',
			'pdf.import' => 'Importuj PDF',
			'pdf.importSubtitle' => 'Tekst zostanie automatycznie wyodrębniony',
			'pdf.export' => 'Eksportuj jako PDF',
			'pdf.exporting' => 'Tworzenie PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Nie udało się wyeksportować PDF: ${error}',
			'pdf.page' => 'Strona',
			'pdf.of' => 'z',
			'settings.title' => 'Ustawienia',
			'settings.theme' => 'Motyw',
			'settings.darkMode' => 'Tryb ciemny',
			'settings.lightMode' => 'Tryb jasny',
			'settings.systemMode' => 'Tryb systemowy',
			'settings.language' => 'Język',
			'settings.sync' => 'Synchronizacja',
			'settings.syncEnabled' => 'Synchronizacja włączona',
			'settings.syncDisabled' => 'Synchronizacja wyłączona',
			'settings.account' => 'Konto',
			'settings.about' => 'O aplikacji',
			'settings.version' => 'Wersja',
			'settings.privacy' => 'Prywatność',
			'settings.terms' => 'Warunki korzystania',
			'settings.inputDevices' => 'Urządzenia wejściowe',
			'settings.automation' => 'Automatyzacja',
			'settings.unlockPen' => 'Odblokuj długopis',
			'settings.pen' => 'Długopis',
			'settings.touch' => 'Dotyk',
			'settings.mouse' => 'Mysz',
			'settings.autoLockOnStylus' => 'Automatycznie zablokuj przy użyciu rysika',
			'settings.editorSettings' => 'Ustawienia edytora',
			'settings.assistPanel' => 'Panel asystenta',
			'settings.leftRightHanded' => 'Dla leworęcznych · Praworęcznych',
			'settings.rightLeftHanded' => 'Dla praworęcznych · Leworęcznych',
			'settings.drawingArea' => 'Obszar rysunku',
			'settings.debugMode' => 'Włącz tryb debugowania',
			'errors.networkError' => 'Błąd sieci. Sprawdź swoje połączenie.',
			'errors.unknownError' => 'Wystąpił nieznany błąd.',
			'errors.authError' => 'Błąd logowania. Proszę spróbować ponownie.',
			'errors.saveError' => 'Nie udało się zapisać.',
			'errors.loadError' => 'Nie udało się załadować.',
			'errors.exportError' => 'Nie udało się wyeksportować.',
			_ => null,
		};
	}
}
