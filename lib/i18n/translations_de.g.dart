///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'translations.g.dart';

// Path: <root>
typedef TranslationsDe = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsAppDe app = TranslationsAppDe.internal(_root);
	late final TranslationsCommonDe common = TranslationsCommonDe.internal(_root);
	late final TranslationsAuthDe auth = TranslationsAuthDe.internal(_root);
	late final TranslationsNavDe nav = TranslationsNavDe.internal(_root);
	late final TranslationsNotesDe notes = TranslationsNotesDe.internal(_root);
	late final TranslationsDrawingDe drawing = TranslationsDrawingDe.internal(_root);
	late final TranslationsPaperDe paper = TranslationsPaperDe.internal(_root);
	late final TranslationsAiDe ai = TranslationsAiDe.internal(_root);
	late final TranslationsPdfDe pdf = TranslationsPdfDe.internal(_root);
	late final TranslationsSettingsDe settings = TranslationsSettingsDe.internal(_root);
	late final TranslationsErrorsDe errors = TranslationsErrorsDe.internal(_root);
	late final TranslationsOnboardingDe onboarding = TranslationsOnboardingDe.internal(_root);
	late final TranslationsEditorDe editor = TranslationsEditorDe.internal(_root);
	late final TranslationsPdfDialogDe pdfDialog = TranslationsPdfDialogDe.internal(_root);
}

// Path: app
class TranslationsAppDe {
	TranslationsAppDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Inkpadu'
	String get name => 'Inkpadu';

	/// de: 'Deine Notizen, deine Art'
	String get tagline => 'Deine Notizen, deine Art';
}

// Path: common
class TranslationsCommonDe {
	TranslationsCommonDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Speichern'
	String get save => 'Speichern';

	/// de: 'Abbrechen'
	String get cancel => 'Abbrechen';

	/// de: 'Löschen'
	String get delete => 'Löschen';

	/// de: 'Bearbeiten'
	String get edit => 'Bearbeiten';

	/// de: 'Schließen'
	String get close => 'Schließen';

	/// de: 'Bestätigen'
	String get confirm => 'Bestätigen';

	/// de: 'Laden...'
	String get loading => 'Laden...';

	/// de: 'Fehler'
	String get error => 'Fehler';

	/// de: 'Erfolgreich'
	String get success => 'Erfolgreich';

	/// de: 'Erneut versuchen'
	String get retry => 'Erneut versuchen';

	/// de: 'Suchen'
	String get search => 'Suchen';

	/// de: 'Einstellungen'
	String get settings => 'Einstellungen';

	/// de: 'Zurück'
	String get back => 'Zurück';

	/// de: 'Weiter'
	String get next => 'Weiter';

	/// de: 'Fertig'
	String get done => 'Fertig';

	/// de: 'Ja'
	String get yes => 'Ja';

	/// de: 'Nein'
	String get no => 'Nein';

	/// de: 'Übernehmen'
	String get apply => 'Übernehmen';

	/// de: 'Abgemeldet'
	String get loggedOut => 'Abgemeldet';

	/// de: 'Gerade eben'
	String get justNow => 'Gerade eben';

	/// de: 'vor ${count} Minute(n)'
	String minutesAgo({required Object count}) => 'vor ${count} Minute(n)';

	/// de: 'vor ${count} Stunde(n)'
	String hoursAgo({required Object count}) => 'vor ${count} Stunde(n)';

	/// de: 'Gestern'
	String get yesterday => 'Gestern';
}

// Path: auth
class TranslationsAuthDe {
	TranslationsAuthDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Anmelden'
	String get login => 'Anmelden';

	/// de: 'Abmelden'
	String get logout => 'Abmelden';

	/// de: 'Registrieren'
	String get register => 'Registrieren';

	/// de: 'E-Mail'
	String get email => 'E-Mail';

	/// de: 'Passwort'
	String get password => 'Passwort';

	/// de: 'Passwort vergessen?'
	String get forgotPassword => 'Passwort vergessen?';

	/// de: 'Willkommen zurück!'
	String get welcomeBack => 'Willkommen zurück!';

	/// de: 'Konto erstellen'
	String get createAccount => 'Konto erstellen';

	/// de: 'Mit Google anmelden'
	String get loginWithGoogle => 'Mit Google anmelden';

	/// de: 'Mit Apple anmelden'
	String get loginWithApple => 'Mit Apple anmelden';
}

// Path: nav
class TranslationsNavDe {
	TranslationsNavDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Notizen'
	String get notes => 'Notizen';

	/// de: 'Einstellungen'
	String get settings => 'Einstellungen';
}

// Path: notes
class TranslationsNotesDe {
	TranslationsNotesDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Notizen'
	String get title => 'Notizen';

	/// de: 'Neue Notiz'
	String get newNote => 'Neue Notiz';

	/// de: 'Unternotiz erstellen'
	String get createSubNote => 'Unternotiz erstellen';

	/// de: 'Ohne Titel'
	String get untitled => 'Ohne Titel';

	/// de: 'Unbenannte Notiz'
	String get unnamed => 'Unbenannte Notiz';

	/// de: 'Noch keine Inhalte'
	String get noContent => 'Noch keine Inhalte';

	/// de: 'Notiz'
	String get noteDate => 'Notiz';

	/// de: 'Zuletzt bearbeitet'
	String get lastEdited => 'Zuletzt bearbeitet';

	/// de: 'Notiz löschen'
	String get deleteNote => 'Notiz löschen';

	/// de: 'Möchten Sie "${title}" wirklich löschen?'
	String deleteNoteConfirm({required Object title}) => 'Möchten Sie "${title}" wirklich löschen?';

	/// de: 'Notiz löschen'
	String get deleteNoteTooltip => 'Notiz löschen';

	/// de: 'Noch keine handschriftlichen Notizen'
	String get noNotes => 'Noch keine handschriftlichen Notizen';

	/// de: 'Erstelle deine erste Notiz'
	String get createFirst => 'Erstelle deine erste Notiz';

	/// de: 'Neue Notiz erstellen'
	String get createNew => 'Neue Notiz erstellen';

	/// de: 'Exportieren'
	String get export => 'Exportieren';

	/// de: 'Teilen'
	String get share => 'Teilen';

	/// de: 'Duplizieren'
	String get duplicate => 'Duplizieren';

	/// de: 'Notiz öffnen'
	String get openNote => 'Notiz öffnen';

	/// de: 'Titel & Papier anpassen'
	String get adjustTitlePaper => 'Titel & Papier anpassen';

	/// de: 'Leere Notiz'
	String get emptyNote => 'Leere Notiz';

	/// de: 'Starte mit einer leeren Seite'
	String get emptyNoteSubtitle => 'Starte mit einer leeren Seite';

	/// de: 'Zum Löschen wischen'
	String get swipeToDelete => 'Zum Löschen wischen';

	/// de: 'Notiz gelöscht'
	String get noteDeleted => 'Notiz gelöscht';

	/// de: 'Rückgängig'
	String get undo => 'Rückgängig';

	/// de: 'Notizen durchsuchen...'
	String get searchNotes => 'Notizen durchsuchen...';

	/// de: '${count} Seite(n)'
	String pagesCount({required Object count}) => '${count} Seite(n)';

	/// de: '${count} Strich(e)'
	String strokesCount({required Object count}) => '${count} Strich(e)';
}

// Path: drawing
class TranslationsDrawingDe {
	TranslationsDrawingDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Stift'
	String get pen => 'Stift';

	/// de: 'Bleistift'
	String get pencil => 'Bleistift';

	/// de: 'Textmarker'
	String get highlighter => 'Textmarker';

	/// de: 'Radierer'
	String get eraser => 'Radierer';

	/// de: 'Auswählen'
	String get select => 'Auswählen';

	/// de: 'Rückgängig'
	String get undo => 'Rückgängig';

	/// de: 'Wiederholen'
	String get redo => 'Wiederholen';

	/// de: 'Löschen'
	String get clear => 'Löschen';

	/// de: 'Alle Zeichnungen löschen?'
	String get clearConfirm => 'Alle Zeichnungen löschen?';

	/// de: 'Farbe'
	String get color => 'Farbe';

	/// de: 'Farbkreis'
	String get colorWheel => 'Farbkreis';

	/// de: 'Symbol'
	String get symbol => 'Symbol';

	/// de: 'Strichstärke'
	String get strokeWidth => 'Strichstärke';

	/// de: 'Vergrößern'
	String get zoomIn => 'Vergrößern';

	/// de: 'Verkleinern'
	String get zoomOut => 'Verkleinern';

	/// de: 'Marker-Modus (durchscheinend)'
	String get markerMode => 'Marker-Modus (durchscheinend)';

	/// de: 'Druckerkennung'
	String get pressureDetection => 'Druckerkennung';

	/// de: '${name} anpassen'
	String customizeTool({required Object name}) => '${name} anpassen';

	/// de: 'Fineliner'
	String get fineliner => 'Fineliner';

	/// de: 'Tintenroller'
	String get inkRoller => 'Tintenroller';

	/// de: 'Füller'
	String get fountainPen => 'Füller';

	/// de: 'Marker'
	String get marker => 'Marker';

	/// de: 'Neon'
	String get neon => 'Neon';
}

// Path: paper
class TranslationsPaperDe {
	TranslationsPaperDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Hintergrund wählen'
	String get selectStyle => 'Hintergrund wählen';

	/// de: 'Blanko'
	String get plain => 'Blanko';

	/// de: 'Liniert'
	String get lined => 'Liniert';

	/// de: 'Kariert'
	String get grid => 'Kariert';

	/// de: 'Punktiert'
	String get dotted => 'Punktiert';
}

// Path: ai
class TranslationsAiDe {
	TranslationsAiDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'KI-Funktionen'
	String get title => 'KI-Funktionen';

	/// de: 'KI-Assistent'
	String get assistant => 'KI-Assistent';

	/// de: 'Text erkennen'
	String get recognize => 'Text erkennen';

	/// de: 'Erkennen...'
	String get recognizing => 'Erkennen...';

	/// de: 'Zusammenfassen'
	String get summarize => 'Zusammenfassen';

	/// de: 'Aufgaben extrahieren'
	String get extractTasks => 'Aufgaben extrahieren';

	/// de: 'Übersetzen'
	String get translate => 'Übersetzen';

	/// de: 'Kein Text gefunden'
	String get noTextFound => 'Kein Text gefunden';

	/// de: 'KI-Assistent Persona'
	String get persona => 'KI-Assistent Persona';

	/// de: 'Stil des Assistenten wählen'
	String get personaSubtitle => 'Stil des Assistenten wählen';
}

// Path: pdf
class TranslationsPdfDe {
	TranslationsPdfDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'PDF importieren'
	String get import => 'PDF importieren';

	/// de: 'Text wird automatisch extrahiert'
	String get importSubtitle => 'Text wird automatisch extrahiert';

	/// de: 'Als PDF exportieren'
	String get export => 'Als PDF exportieren';

	/// de: 'PDF wird erstellt...'
	String get exporting => 'PDF wird erstellt...';

	/// de: 'PDF-Export fehlgeschlagen: ${error}'
	String exportFailed({required Object error}) => 'PDF-Export fehlgeschlagen: ${error}';

	/// de: 'Seite'
	String get page => 'Seite';

	/// de: 'von'
	String get of => 'von';
}

// Path: settings
class TranslationsSettingsDe {
	TranslationsSettingsDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Einstellungen'
	String get title => 'Einstellungen';

	/// de: 'Allgemein'
	String get general => 'Allgemein';

	/// de: 'Design'
	String get theme => 'Design';

	/// de: 'Hell · Dunkel · System'
	String get themeSubtitle => 'Hell · Dunkel · System';

	/// de: 'Dunkelmodus'
	String get darkMode => 'Dunkelmodus';

	/// de: 'Hellmodus'
	String get lightMode => 'Hellmodus';

	/// de: 'Systemstandard'
	String get systemMode => 'Systemstandard';

	/// de: 'Sprache'
	String get language => 'Sprache';

	/// de: 'Deutsch (beta)'
	String get languageSubtitle => 'Deutsch (beta)';

	/// de: 'Synchronisierung'
	String get sync => 'Synchronisierung';

	/// de: 'Synchronisierung aktiviert'
	String get syncEnabled => 'Synchronisierung aktiviert';

	/// de: 'Synchronisierung deaktiviert'
	String get syncDisabled => 'Synchronisierung deaktiviert';

	/// de: 'Konto'
	String get account => 'Konto';

	/// de: 'Über'
	String get about => 'Über';

	/// de: 'Version'
	String get version => 'Version';

	/// de: 'Datenschutz'
	String get privacy => 'Datenschutz';

	/// de: 'Nutzungsbedingungen'
	String get terms => 'Nutzungsbedingungen';

	/// de: 'Eingabe'
	String get input => 'Eingabe';

	/// de: 'Eingabegeräte'
	String get inputDevices => 'Eingabegeräte';

	/// de: 'Stift · Touch · Maus'
	String get inputDeviceSubtitle => 'Stift · Touch · Maus';

	/// de: 'Automatisierung'
	String get automation => 'Automatisierung';

	/// de: 'Stift-Sperre aufheben'
	String get unlockPen => 'Stift-Sperre aufheben';

	/// de: 'Stift'
	String get pen => 'Stift';

	/// de: 'Touch'
	String get touch => 'Touch';

	/// de: 'Maus'
	String get mouse => 'Maus';

	/// de: 'Automatisch auf Stift sperren'
	String get autoLockOnStylus => 'Automatisch auf Stift sperren';

	/// de: 'Editor-Einstellungen'
	String get editorSettings => 'Editor-Einstellungen';

	/// de: 'Notiz-Editor'
	String get noteEditor => 'Notiz-Editor';

	/// de: 'Seitenpanel links · rechts'
	String get noteEditorSubtitle => 'Seitenpanel links · rechts';

	/// de: 'Stiftstärken'
	String get strokeWidths => 'Stiftstärken';

	/// de: 'Dünn · Medium · Fett'
	String get strokeWidthsSubtitle => 'Dünn · Medium · Fett';

	/// de: 'Handflächen-Erkennung'
	String get palmRejection => 'Handflächen-Erkennung';

	/// de: 'Verhindert ungewollte Eingaben'
	String get palmRejectionSubtitle => 'Verhindert ungewollte Eingaben';

	/// de: 'Assistenz-Panel'
	String get assistPanel => 'Assistenz-Panel';

	/// de: 'Links · Rechtshänder'
	String get leftRightHanded => 'Links · Rechtshänder';

	/// de: 'Rechts · Linkshänder'
	String get rightLeftHanded => 'Rechts · Linkshänder';

	/// de: 'Zeichenfläche'
	String get drawingArea => 'Zeichenfläche';

	/// de: 'Debug-Modus aktivieren'
	String get debugMode => 'Debug-Modus aktivieren';

	/// de: 'Cloud & Synchronisation'
	String get cloud => 'Cloud & Synchronisation';

	/// de: 'Speicherziel'
	String get storageTarget => 'Speicherziel';

	/// de: 'Inkpadu Cloud (kostenlos)'
	String get storageSubtitle => 'Inkpadu Cloud (kostenlos)';

	/// de: 'Verschlüsselung'
	String get encryption => 'Verschlüsselung';

	/// de: 'Ende-zu-Ende aktiv'
	String get encryptionSubtitle => 'Ende-zu-Ende aktiv';
}

// Path: errors
class TranslationsErrorsDe {
	TranslationsErrorsDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Netzwerkfehler. Überprüfe deine Verbindung.'
	String get networkError => 'Netzwerkfehler. Überprüfe deine Verbindung.';

	/// de: 'Ein unbekannter Fehler ist aufgetreten.'
	String get unknownError => 'Ein unbekannter Fehler ist aufgetreten.';

	/// de: 'Anmeldefehler. Bitte versuche es erneut.'
	String get authError => 'Anmeldefehler. Bitte versuche es erneut.';

	/// de: 'Speichern fehlgeschlagen.'
	String get saveError => 'Speichern fehlgeschlagen.';

	/// de: 'Laden fehlgeschlagen.'
	String get loadError => 'Laden fehlgeschlagen.';

	/// de: 'Export fehlgeschlagen.'
	String get exportError => 'Export fehlgeschlagen.';

	/// de: 'Login (${provider}) fehlgeschlagen'
	String loginFailed({required Object provider}) => 'Login (${provider}) fehlgeschlagen';
}

// Path: onboarding
class TranslationsOnboardingDe {
	TranslationsOnboardingDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Willkommen bei Inkpadu'
	String get welcome => 'Willkommen bei Inkpadu';

	/// de: 'Skizziere Ideen, schreibe Notizen und organisiere deine Gedanken mit natürlicher Handschrift.'
	String get description => 'Skizziere Ideen, schreibe Notizen und organisiere deine Gedanken mit natürlicher Handschrift.';

	/// de: 'Dein digitales Notizbuch'
	String get digitalNotebook => 'Dein digitales Notizbuch';

	/// de: 'Eine handschriftliche Erfahrung, optimiert für Kreativität und Fokus – ganz ohne Ablenkung.'
	String get digitalNotebookDescription => 'Eine handschriftliche Erfahrung, optimiert für Kreativität und Fokus – ganz ohne Ablenkung.';

	/// de: 'Verbinde…'
	String get connecting => 'Verbinde…';

	/// de: 'Mit GitHub anmelden'
	String get loginWithGitHub => 'Mit GitHub anmelden';

	/// de: 'Mit Google anmelden'
	String get loginWithGoogle => 'Mit Google anmelden';
}

// Path: editor
class TranslationsEditorDe {
	TranslationsEditorDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'Neue Notiz'
	String get newNote => 'Neue Notiz';

	/// de: 'Notiz bearbeiten'
	String get editNote => 'Notiz bearbeiten';

	/// de: 'Titel'
	String get title => 'Titel';

	/// de: 'Schreibe deine Notiz...'
	String get writeNote => 'Schreibe deine Notiz...';

	/// de: 'Assistenz-Panel'
	String get assistPanel => 'Assistenz-Panel';

	/// de: 'Links · Rechtshänder'
	String get leftRightHanded => 'Links · Rechtshänder';

	/// de: 'Rechts · Linkshänder'
	String get rightLeftHanded => 'Rechts · Linkshänder';

	/// de: 'Rechtshänder:innen erreichen die Tools bequemer, wenn das Panel links sitzt. Linkshänder:innen wählen dagegen die rechte Seite.'
	String get handednessHint => 'Rechtshänder:innen erreichen die Tools bequemer, wenn das Panel links sitzt. Linkshänder:innen wählen dagegen die rechte Seite.';

	/// de: 'Zeichenfläche'
	String get drawingArea => 'Zeichenfläche';

	/// de: 'Debug-Modus aktivieren'
	String get enableDebugMode => 'Debug-Modus aktivieren';

	/// de: 'Zeigt Bounding-Boxen und konvexe Hüllen im Editor sowie im KI-Assistenten an.'
	String get debugModeHint => 'Zeigt Bounding-Boxen und konvexe Hüllen im Editor sowie im KI-Assistenten an.';

	/// de: 'Linien-Simplifier verwenden'
	String get useLineSimplifier => 'Linien-Simplifier verwenden';

	/// de: 'Glättet deine Striche automatisch, um ruhige Linien zu erhalten.'
	String get lineSimplifierHint => 'Glättet deine Striche automatisch, um ruhige Linien zu erhalten.';

	/// de: 'Glättungsintensität (${value})'
	String smoothingIntensity({required Object value}) => 'Glättungsintensität (${value})';

	/// de: 'Niedrige Werte bewahren mehr Details, hohe Werte glätten stärker.'
	String get smoothingHint => 'Niedrige Werte bewahren mehr Details, hohe Werte glätten stärker.';

	/// de: 'Mindest-Toleranz (${value} px)'
	String minTolerance({required Object value}) => 'Mindest-Toleranz (${value} px)';

	/// de: 'Setzt die Untergrenze für das Glätten – höhere Werte filtern winzige Zacken.'
	String get minToleranceHint => 'Setzt die Untergrenze für das Glätten – höhere Werte filtern winzige Zacken.';

	/// de: 'KI-Assistent Persona'
	String get aiPersona => 'KI-Assistent Persona';

	/// de: 'Wähle den Stil deines KI-Assistenten'
	String get choosePersonaStyle => 'Wähle den Stil deines KI-Assistenten';

	/// de: 'Die Persona bestimmt, wie der Assistent mit dir kommuniziert.'
	String get personaStyleHint => 'Die Persona bestimmt, wie der Assistent mit dir kommuniziert.';

	/// de: 'Strenger Trainer'
	String get strictTrainer => 'Strenger Trainer';

	/// de: 'Direkte, harte Kritik wie ein russischer Olympia-Trainer'
	String get strictTrainerHint => 'Direkte, harte Kritik wie ein russischer Olympia-Trainer';

	/// de: 'Ermutigender Mentor'
	String get encouragingMentor => 'Ermutigender Mentor';

	/// de: 'Positive Verstärkung und motivierendes Feedback'
	String get encouragingMentorHint => 'Positive Verstärkung und motivierendes Feedback';

	/// de: 'Benutzerdefiniert'
	String get customPersona => 'Benutzerdefiniert';

	/// de: 'Eigenes System-Prompt festlegen'
	String get customPersonaHint => 'Eigenes System-Prompt festlegen';

	/// de: 'Dein System-Prompt'
	String get yourSystemPrompt => 'Dein System-Prompt';

	/// de: 'Beschreibe, wie sich der Assistent verhalten soll…'
	String get systemPromptPlaceholder => 'Beschreibe, wie sich der Assistent verhalten soll…';

	/// de: 'Das System-Prompt definiert die Persönlichkeit und das Verhalten des Assistenten bei allen Anfragen.'
	String get systemPromptHint => 'Das System-Prompt definiert die Persönlichkeit und das Verhalten des Assistenten bei allen Anfragen.';

	/// de: 'Aktueller Stil'
	String get currentStyle => 'Aktueller Stil';

	/// de: 'Der Assistent gibt dir hartes, direktes Feedback. Er akzeptiert keine Mittelmäßigkeit und motiviert dich durch konstruktive Kritik zu Höchstleistungen.'
	String get strictTrainerDescription => 'Der Assistent gibt dir hartes, direktes Feedback. Er akzeptiert keine Mittelmäßigkeit und motiviert dich durch konstruktive Kritik zu Höchstleistungen.';

	/// de: 'Der Assistent lobt deine Fortschritte und gibt dir ermutigendes Feedback. Fehler werden als Lernmöglichkeiten dargestellt.'
	String get encouragingMentorDescription => 'Der Assistent lobt deine Fortschritte und gibt dir ermutigendes Feedback. Fehler werden als Lernmöglichkeiten dargestellt.';

	/// de: 'Der Assistent verhält sich gemäß deinem eigenen System-Prompt.'
	String get customPersonaDescription => 'Der Assistent verhält sich gemäß deinem eigenen System-Prompt.';
}

// Path: pdfDialog
class TranslationsPdfDialogDe {
	TranslationsPdfDialogDe.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// de: 'PDF auswählen'
	String get selectPdf => 'PDF auswählen';

	/// de: 'PDF analysieren'
	String get analyzePdf => 'PDF analysieren';

	/// de: 'Bereit'
	String get ready => 'Bereit';

	/// de: 'PDF verarbeiten'
	String get processPdf => 'PDF verarbeiten';

	/// de: 'Import abgeschlossen'
	String get importComplete => 'Import abgeschlossen';

	/// de: 'Bitte wähle eine PDF-Datei aus...'
	String get selectPdfFile => 'Bitte wähle eine PDF-Datei aus...';

	/// de: 'PDF wird analysiert...'
	String get analyzingPdf => 'PDF wird analysiert...';

	/// de: '${count} Seite(n) gefunden'
	String pagesFound({required Object count}) => '${count} Seite(n) gefunden';

	/// de: 'Textextraktion erfolgt im Hintergrund.'
	String get textExtractionBackground => 'Textextraktion erfolgt im Hintergrund.';

	/// de: 'Die PDF-Datei konnte nicht gelesen werden.'
	String get couldNotReadPdf => 'Die PDF-Datei konnte nicht gelesen werden.';

	/// de: '${count} Seite(n) importiert'
	String pagesImported({required Object count}) => '${count} Seite(n) importiert';

	/// de: '~${count}k Zeichen extrahiert'
	String charactersExtracted({required Object count}) => '~${count}k Zeichen extrahiert';

	/// de: 'Der extrahierte Text wird als Kontext für den KI-Assistenten verwendet.'
	String get extractedTextContext => 'Der extrahierte Text wird als Kontext für den KI-Assistenten verwendet.';

	/// de: 'Die Textextraktion kann einige Sekunden pro Seite dauern.'
	String get textExtractionDuration => 'Die Textextraktion kann einige Sekunden pro Seite dauern.';

	/// de: 'Rendere Seite ${current} von ${total}...'
	String renderingPage({required Object current, required Object total}) => 'Rendere Seite ${current} von ${total}...';

	/// de: 'Extrahiere Text von Seite ${current} von ${total}...'
	String extractingPage({required Object current, required Object total}) => 'Extrahiere Text von Seite ${current} von ${total}...';

	/// de: 'Erkenne Aufgaben...'
	String get recognizingTasks => 'Erkenne Aufgaben...';
}

/// The flat map containing all translations for locale <de>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Deine Notizen, deine Art',
			'common.save' => 'Speichern',
			'common.cancel' => 'Abbrechen',
			'common.delete' => 'Löschen',
			'common.edit' => 'Bearbeiten',
			'common.close' => 'Schließen',
			'common.confirm' => 'Bestätigen',
			'common.loading' => 'Laden...',
			'common.error' => 'Fehler',
			'common.success' => 'Erfolgreich',
			'common.retry' => 'Erneut versuchen',
			'common.search' => 'Suchen',
			'common.settings' => 'Einstellungen',
			'common.back' => 'Zurück',
			'common.next' => 'Weiter',
			'common.done' => 'Fertig',
			'common.yes' => 'Ja',
			'common.no' => 'Nein',
			'common.apply' => 'Übernehmen',
			'common.loggedOut' => 'Abgemeldet',
			'common.justNow' => 'Gerade eben',
			'common.minutesAgo' => ({required Object count}) => 'vor ${count} Minute(n)',
			'common.hoursAgo' => ({required Object count}) => 'vor ${count} Stunde(n)',
			'common.yesterday' => 'Gestern',
			'auth.login' => 'Anmelden',
			'auth.logout' => 'Abmelden',
			'auth.register' => 'Registrieren',
			'auth.email' => 'E-Mail',
			'auth.password' => 'Passwort',
			'auth.forgotPassword' => 'Passwort vergessen?',
			'auth.welcomeBack' => 'Willkommen zurück!',
			'auth.createAccount' => 'Konto erstellen',
			'auth.loginWithGoogle' => 'Mit Google anmelden',
			'auth.loginWithApple' => 'Mit Apple anmelden',
			'nav.notes' => 'Notizen',
			'nav.settings' => 'Einstellungen',
			'notes.title' => 'Notizen',
			'notes.newNote' => 'Neue Notiz',
			'notes.createSubNote' => 'Unternotiz erstellen',
			'notes.untitled' => 'Ohne Titel',
			'notes.unnamed' => 'Unbenannte Notiz',
			'notes.noContent' => 'Noch keine Inhalte',
			'notes.noteDate' => 'Notiz',
			'notes.lastEdited' => 'Zuletzt bearbeitet',
			'notes.deleteNote' => 'Notiz löschen',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Möchten Sie "${title}" wirklich löschen?',
			'notes.deleteNoteTooltip' => 'Notiz löschen',
			'notes.noNotes' => 'Noch keine handschriftlichen Notizen',
			'notes.createFirst' => 'Erstelle deine erste Notiz',
			'notes.createNew' => 'Neue Notiz erstellen',
			'notes.export' => 'Exportieren',
			'notes.share' => 'Teilen',
			'notes.duplicate' => 'Duplizieren',
			'notes.openNote' => 'Notiz öffnen',
			'notes.adjustTitlePaper' => 'Titel & Papier anpassen',
			'notes.emptyNote' => 'Leere Notiz',
			'notes.emptyNoteSubtitle' => 'Starte mit einer leeren Seite',
			'notes.swipeToDelete' => 'Zum Löschen wischen',
			'notes.noteDeleted' => 'Notiz gelöscht',
			'notes.undo' => 'Rückgängig',
			'notes.searchNotes' => 'Notizen durchsuchen...',
			'notes.pagesCount' => ({required Object count}) => '${count} Seite(n)',
			'notes.strokesCount' => ({required Object count}) => '${count} Strich(e)',
			'drawing.pen' => 'Stift',
			'drawing.pencil' => 'Bleistift',
			'drawing.highlighter' => 'Textmarker',
			'drawing.eraser' => 'Radierer',
			'drawing.select' => 'Auswählen',
			'drawing.undo' => 'Rückgängig',
			'drawing.redo' => 'Wiederholen',
			'drawing.clear' => 'Löschen',
			'drawing.clearConfirm' => 'Alle Zeichnungen löschen?',
			'drawing.color' => 'Farbe',
			'drawing.colorWheel' => 'Farbkreis',
			'drawing.symbol' => 'Symbol',
			'drawing.strokeWidth' => 'Strichstärke',
			'drawing.zoomIn' => 'Vergrößern',
			'drawing.zoomOut' => 'Verkleinern',
			'drawing.markerMode' => 'Marker-Modus (durchscheinend)',
			'drawing.pressureDetection' => 'Druckerkennung',
			'drawing.customizeTool' => ({required Object name}) => '${name} anpassen',
			'drawing.fineliner' => 'Fineliner',
			'drawing.inkRoller' => 'Tintenroller',
			'drawing.fountainPen' => 'Füller',
			'drawing.marker' => 'Marker',
			'drawing.neon' => 'Neon',
			'paper.selectStyle' => 'Hintergrund wählen',
			'paper.plain' => 'Blanko',
			'paper.lined' => 'Liniert',
			'paper.grid' => 'Kariert',
			'paper.dotted' => 'Punktiert',
			'ai.title' => 'KI-Funktionen',
			'ai.assistant' => 'KI-Assistent',
			'ai.recognize' => 'Text erkennen',
			'ai.recognizing' => 'Erkennen...',
			'ai.summarize' => 'Zusammenfassen',
			'ai.extractTasks' => 'Aufgaben extrahieren',
			'ai.translate' => 'Übersetzen',
			'ai.noTextFound' => 'Kein Text gefunden',
			'ai.persona' => 'KI-Assistent Persona',
			'ai.personaSubtitle' => 'Stil des Assistenten wählen',
			'pdf.import' => 'PDF importieren',
			'pdf.importSubtitle' => 'Text wird automatisch extrahiert',
			'pdf.export' => 'Als PDF exportieren',
			'pdf.exporting' => 'PDF wird erstellt...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF-Export fehlgeschlagen: ${error}',
			'pdf.page' => 'Seite',
			'pdf.of' => 'von',
			'settings.title' => 'Einstellungen',
			'settings.general' => 'Allgemein',
			'settings.theme' => 'Design',
			'settings.themeSubtitle' => 'Hell · Dunkel · System',
			'settings.darkMode' => 'Dunkelmodus',
			'settings.lightMode' => 'Hellmodus',
			'settings.systemMode' => 'Systemstandard',
			'settings.language' => 'Sprache',
			'settings.languageSubtitle' => 'Deutsch (beta)',
			'settings.sync' => 'Synchronisierung',
			'settings.syncEnabled' => 'Synchronisierung aktiviert',
			'settings.syncDisabled' => 'Synchronisierung deaktiviert',
			'settings.account' => 'Konto',
			'settings.about' => 'Über',
			'settings.version' => 'Version',
			'settings.privacy' => 'Datenschutz',
			'settings.terms' => 'Nutzungsbedingungen',
			'settings.input' => 'Eingabe',
			'settings.inputDevices' => 'Eingabegeräte',
			'settings.inputDeviceSubtitle' => 'Stift · Touch · Maus',
			'settings.automation' => 'Automatisierung',
			'settings.unlockPen' => 'Stift-Sperre aufheben',
			'settings.pen' => 'Stift',
			'settings.touch' => 'Touch',
			'settings.mouse' => 'Maus',
			'settings.autoLockOnStylus' => 'Automatisch auf Stift sperren',
			'settings.editorSettings' => 'Editor-Einstellungen',
			'settings.noteEditor' => 'Notiz-Editor',
			'settings.noteEditorSubtitle' => 'Seitenpanel links · rechts',
			'settings.strokeWidths' => 'Stiftstärken',
			'settings.strokeWidthsSubtitle' => 'Dünn · Medium · Fett',
			'settings.palmRejection' => 'Handflächen-Erkennung',
			'settings.palmRejectionSubtitle' => 'Verhindert ungewollte Eingaben',
			'settings.assistPanel' => 'Assistenz-Panel',
			'settings.leftRightHanded' => 'Links · Rechtshänder',
			'settings.rightLeftHanded' => 'Rechts · Linkshänder',
			'settings.drawingArea' => 'Zeichenfläche',
			'settings.debugMode' => 'Debug-Modus aktivieren',
			'settings.cloud' => 'Cloud & Synchronisation',
			'settings.storageTarget' => 'Speicherziel',
			'settings.storageSubtitle' => 'Inkpadu Cloud (kostenlos)',
			'settings.encryption' => 'Verschlüsselung',
			'settings.encryptionSubtitle' => 'Ende-zu-Ende aktiv',
			'errors.networkError' => 'Netzwerkfehler. Überprüfe deine Verbindung.',
			'errors.unknownError' => 'Ein unbekannter Fehler ist aufgetreten.',
			'errors.authError' => 'Anmeldefehler. Bitte versuche es erneut.',
			'errors.saveError' => 'Speichern fehlgeschlagen.',
			'errors.loadError' => 'Laden fehlgeschlagen.',
			'errors.exportError' => 'Export fehlgeschlagen.',
			'errors.loginFailed' => ({required Object provider}) => 'Login (${provider}) fehlgeschlagen',
			'onboarding.welcome' => 'Willkommen bei Inkpadu',
			'onboarding.description' => 'Skizziere Ideen, schreibe Notizen und organisiere deine Gedanken mit natürlicher Handschrift.',
			'onboarding.digitalNotebook' => 'Dein digitales Notizbuch',
			'onboarding.digitalNotebookDescription' => 'Eine handschriftliche Erfahrung, optimiert für Kreativität und Fokus – ganz ohne Ablenkung.',
			'onboarding.connecting' => 'Verbinde…',
			'onboarding.loginWithGitHub' => 'Mit GitHub anmelden',
			'onboarding.loginWithGoogle' => 'Mit Google anmelden',
			'editor.newNote' => 'Neue Notiz',
			'editor.editNote' => 'Notiz bearbeiten',
			'editor.title' => 'Titel',
			'editor.writeNote' => 'Schreibe deine Notiz...',
			'editor.assistPanel' => 'Assistenz-Panel',
			'editor.leftRightHanded' => 'Links · Rechtshänder',
			'editor.rightLeftHanded' => 'Rechts · Linkshänder',
			'editor.handednessHint' => 'Rechtshänder:innen erreichen die Tools bequemer, wenn das Panel links sitzt. Linkshänder:innen wählen dagegen die rechte Seite.',
			'editor.drawingArea' => 'Zeichenfläche',
			'editor.enableDebugMode' => 'Debug-Modus aktivieren',
			'editor.debugModeHint' => 'Zeigt Bounding-Boxen und konvexe Hüllen im Editor sowie im KI-Assistenten an.',
			'editor.useLineSimplifier' => 'Linien-Simplifier verwenden',
			'editor.lineSimplifierHint' => 'Glättet deine Striche automatisch, um ruhige Linien zu erhalten.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Glättungsintensität (${value})',
			'editor.smoothingHint' => 'Niedrige Werte bewahren mehr Details, hohe Werte glätten stärker.',
			'editor.minTolerance' => ({required Object value}) => 'Mindest-Toleranz (${value} px)',
			'editor.minToleranceHint' => 'Setzt die Untergrenze für das Glätten – höhere Werte filtern winzige Zacken.',
			'editor.aiPersona' => 'KI-Assistent Persona',
			'editor.choosePersonaStyle' => 'Wähle den Stil deines KI-Assistenten',
			'editor.personaStyleHint' => 'Die Persona bestimmt, wie der Assistent mit dir kommuniziert.',
			'editor.strictTrainer' => 'Strenger Trainer',
			'editor.strictTrainerHint' => 'Direkte, harte Kritik wie ein russischer Olympia-Trainer',
			'editor.encouragingMentor' => 'Ermutigender Mentor',
			'editor.encouragingMentorHint' => 'Positive Verstärkung und motivierendes Feedback',
			'editor.customPersona' => 'Benutzerdefiniert',
			'editor.customPersonaHint' => 'Eigenes System-Prompt festlegen',
			'editor.yourSystemPrompt' => 'Dein System-Prompt',
			'editor.systemPromptPlaceholder' => 'Beschreibe, wie sich der Assistent verhalten soll…',
			'editor.systemPromptHint' => 'Das System-Prompt definiert die Persönlichkeit und das Verhalten des Assistenten bei allen Anfragen.',
			'editor.currentStyle' => 'Aktueller Stil',
			'editor.strictTrainerDescription' => 'Der Assistent gibt dir hartes, direktes Feedback. Er akzeptiert keine Mittelmäßigkeit und motiviert dich durch konstruktive Kritik zu Höchstleistungen.',
			'editor.encouragingMentorDescription' => 'Der Assistent lobt deine Fortschritte und gibt dir ermutigendes Feedback. Fehler werden als Lernmöglichkeiten dargestellt.',
			'editor.customPersonaDescription' => 'Der Assistent verhält sich gemäß deinem eigenen System-Prompt.',
			'pdfDialog.selectPdf' => 'PDF auswählen',
			'pdfDialog.analyzePdf' => 'PDF analysieren',
			'pdfDialog.ready' => 'Bereit',
			'pdfDialog.processPdf' => 'PDF verarbeiten',
			'pdfDialog.importComplete' => 'Import abgeschlossen',
			'pdfDialog.selectPdfFile' => 'Bitte wähle eine PDF-Datei aus...',
			'pdfDialog.analyzingPdf' => 'PDF wird analysiert...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} Seite(n) gefunden',
			'pdfDialog.textExtractionBackground' => 'Textextraktion erfolgt im Hintergrund.',
			'pdfDialog.couldNotReadPdf' => 'Die PDF-Datei konnte nicht gelesen werden.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} Seite(n) importiert',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k Zeichen extrahiert',
			'pdfDialog.extractedTextContext' => 'Der extrahierte Text wird als Kontext für den KI-Assistenten verwendet.',
			'pdfDialog.textExtractionDuration' => 'Die Textextraktion kann einige Sekunden pro Seite dauern.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Rendere Seite ${current} von ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Extrahiere Text von Seite ${current} von ${total}...',
			'pdfDialog.recognizingTasks' => 'Erkenne Aufgaben...',
			_ => null,
		};
	}
}
