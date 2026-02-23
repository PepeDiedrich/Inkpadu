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
class TranslationsFr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsFr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsFr _root = this; // ignore: unused_field

	@override 
	TranslationsFr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsFr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppFr app = _TranslationsAppFr._(_root);
	@override late final _TranslationsCommonFr common = _TranslationsCommonFr._(_root);
	@override late final _TranslationsAuthFr auth = _TranslationsAuthFr._(_root);
	@override late final _TranslationsNavFr nav = _TranslationsNavFr._(_root);
	@override late final _TranslationsNotesFr notes = _TranslationsNotesFr._(_root);
	@override late final _TranslationsDrawingFr drawing = _TranslationsDrawingFr._(_root);
	@override late final _TranslationsPaperFr paper = _TranslationsPaperFr._(_root);
	@override late final _TranslationsAiFr ai = _TranslationsAiFr._(_root);
	@override late final _TranslationsPdfFr pdf = _TranslationsPdfFr._(_root);
	@override late final _TranslationsSettingsFr settings = _TranslationsSettingsFr._(_root);
	@override late final _TranslationsErrorsFr errors = _TranslationsErrorsFr._(_root);
	@override late final _TranslationsOnboardingFr onboarding = _TranslationsOnboardingFr._(_root);
	@override late final _TranslationsEditorFr editor = _TranslationsEditorFr._(_root);
	@override late final _TranslationsPdfDialogFr pdfDialog = _TranslationsPdfDialogFr._(_root);
}

// Path: app
class _TranslationsAppFr extends TranslationsAppDe {
	_TranslationsAppFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Tes notes, à ta manière';
}

// Path: common
class _TranslationsCommonFr extends TranslationsCommonDe {
	_TranslationsCommonFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get save => 'Sauvegarder';
	@override String get cancel => 'Annuler';
	@override String get delete => 'Supprimer';
	@override String get edit => 'Modifier';
	@override String get close => 'Fermer';
	@override String get confirm => 'Confirmer';
	@override String get loading => 'Chargement...';
	@override String get error => 'Erreur';
	@override String get success => 'Réussi';
	@override String get retry => 'Réessayer';
	@override String get search => 'Rechercher';
	@override String get settings => 'Paramètres';
	@override String get back => 'Retour';
	@override String get next => 'Suivant';
	@override String get done => 'Terminé';
	@override String get yes => 'Oui';
	@override String get no => 'Non';
	@override String get apply => 'Appliquer';
	@override String get loggedOut => 'Déconnecté';
	@override String get justNow => 'À l\'instant';
	@override String minutesAgo({required Object count}) => 'il y a ${count} minute(s)';
	@override String hoursAgo({required Object count}) => 'il y a ${count} heure(s)';
	@override String get yesterday => 'Hier';
}

// Path: auth
class _TranslationsAuthFr extends TranslationsAuthDe {
	_TranslationsAuthFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get login => 'Se connecter';
	@override String get logout => 'Se déconnecter';
	@override String get register => 'S\'inscrire';
	@override String get email => 'E-mail';
	@override String get password => 'Mot de passe';
	@override String get forgotPassword => 'Mot de passe oublié ?';
	@override String get welcomeBack => 'Content de te revoir !';
	@override String get createAccount => 'Créer un compte';
	@override String get loginWithGoogle => 'Se connecter avec Google';
	@override String get loginWithApple => 'Se connecter avec Apple';
}

// Path: nav
class _TranslationsNavFr extends TranslationsNavDe {
	_TranslationsNavFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notes';
	@override String get settings => 'Paramètres';
}

// Path: notes
class _TranslationsNotesFr extends TranslationsNotesDe {
	_TranslationsNotesFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notes';
	@override String get newNote => 'Nouvelle note';
	@override String get untitled => 'Sans titre';
	@override String get unnamed => 'Note non nommée';
	@override String get noContent => 'Pas encore de contenu';
	@override String get noteDate => 'Note';
	@override String get lastEdited => 'Dernière modification';
	@override String get deleteNote => 'Supprimer la note';
	@override String deleteNoteConfirm({required Object title}) => 'Voulez-vous vraiment supprimer « ${title} » ?';
	@override String get deleteNoteTooltip => 'Supprimer la note';
	@override String get noNotes => 'Pas encore de notes manuscrites';
	@override String get createFirst => 'Crée ta première note';
	@override String get createNew => 'Créer une nouvelle note';
	@override String get export => 'Exporter';
	@override String get share => 'Partager';
	@override String get duplicate => 'Dupliquer';
	@override String get openNote => 'Ouvrir la note';
	@override String get adjustTitlePaper => 'Ajuster le titre & le papier';
	@override String get emptyNote => 'Note vide';
	@override String get emptyNoteSubtitle => 'Commence avec une page blanche';
}

// Path: drawing
class _TranslationsDrawingFr extends TranslationsDrawingDe {
	_TranslationsDrawingFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Stylo';
	@override String get pencil => 'Crayon';
	@override String get highlighter => 'Surligneur';
	@override String get eraser => 'Gomme';
	@override String get select => 'Sélectionner';
	@override String get lasso => 'Lasso';
	@override String get undo => 'Annuler';
	@override String get redo => 'Rétablir';
	@override String get clear => 'Effacer';
	@override String get clearConfirm => 'Voulez-vous effacer tous les dessins ?';
	@override String get color => 'Couleur';
	@override String get colorWheel => 'Roue des couleurs';
	@override String get symbol => 'Symbole';
	@override String get strokeWidth => 'Épaisseur du trait';
	@override String get zoomIn => 'Zoomer';
	@override String get zoomOut => 'Dézoomer';
	@override String get markerMode => 'Mode marqueur (transparent)';
	@override String get pressureDetection => 'Détection de pression';
	@override String customizeTool({required Object name}) => 'Personnaliser ${name}';
	@override String get fineliner => 'Stylos fins';
	@override String get inkRoller => 'Roller';
	@override String get fountainPen => 'Stylo à plume';
	@override String get marker => 'Marqueur';
	@override String get neon => 'Néon';
}

// Path: paper
class _TranslationsPaperFr extends TranslationsPaperDe {
	_TranslationsPaperFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Blanc';
	@override String get lined => 'Ligné';
	@override String get grid => 'À carreaux';
	@override String get dotted => 'Pointillé';
}

// Path: ai
class _TranslationsAiFr extends TranslationsAiDe {
	_TranslationsAiFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fonctions IA';
	@override String get assistant => 'Assistant IA';
	@override String get recognize => 'Reconnaître du texte';
	@override String get recognizing => 'Reconnaissance...';
	@override String get summarize => 'Résumer';
	@override String get extractTasks => 'Extraire des tâches';
	@override String get translate => 'Traduire';
	@override String get noTextFound => 'Aucun texte trouvé';
	@override String get helpMe => 'Aide-moi';
	@override String get helpMeTitle => 'Réponse IA';
	@override String get analyzingSelection => 'Analyse de la sélection…';
	@override String get noSelection => 'Sélectionne d\'abord quelque chose avec le lasso.';
	@override String get helpMeNotConfigured => 'L\'IA n\'est pas encore configurée.';
	@override String get persona => 'Persona de l\'assistant IA';
	@override String get personaSubtitle => 'Choisissez le style de l\'assistant';
}

// Path: pdf
class _TranslationsPdfFr extends TranslationsPdfDe {
	_TranslationsPdfFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get import => 'Importer PDF';
	@override String get importSubtitle => 'Le texte sera extrait automatiquement';
	@override String get export => 'Exporter en PDF';
	@override String get exporting => 'Création du PDF...';
	@override String exportFailed({required Object error}) => 'Échec de l\'export PDF : ${error}';
	@override String get page => 'Page';
	@override String get of => 'de';
}

// Path: settings
class _TranslationsSettingsFr extends TranslationsSettingsDe {
	_TranslationsSettingsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres';
	@override String get general => 'Général';
	@override String get theme => 'Thème';
	@override String get themeSubtitle => 'Clair · Sombre · Système';
	@override String get darkMode => 'Mode sombre';
	@override String get lightMode => 'Mode clair';
	@override String get systemMode => 'Mode système';
	@override String get language => 'Langue';
	@override String get languageSubtitle => 'Français';
	@override String get sync => 'Synchronisation';
	@override String get syncEnabled => 'Synchronisation activée';
	@override String get syncDisabled => 'Synchronisation désactivée';
	@override String get account => 'Compte';
	@override String get about => 'À propos';
	@override String get version => 'Version';
	@override String get privacy => 'Confidentialité';
	@override String get terms => 'Conditions d\'utilisation';
	@override String get input => 'Entrée';
	@override String get inputDevices => 'Périphériques d\'entrée';
	@override String get inputDeviceSubtitle => 'Stylo · Tactile · Souris';
	@override String get automation => 'Automatisation';
	@override String get unlockPen => 'Déverrouiller le stylo';
	@override String get pen => 'Stylo';
	@override String get touch => 'Tactile';
	@override String get mouse => 'Souris';
	@override String get autoLockOnStylus => 'Verrouiller automatiquement sur stylet';
	@override String get editorSettings => 'Paramètres de l\'éditeur';
	@override String get noteEditor => 'Éditeur de note';
	@override String get noteEditorSubtitle => 'Panneau latéral gauche · droit';
	@override String get strokeWidths => 'Épaisseur de trait';
	@override String get strokeWidthsSubtitle => 'Fin · Moyen · Large';
	@override String get palmRejection => 'Rejet de la paume';
	@override String get palmRejectionSubtitle => 'Empêche les entrées non désirées';
	@override String get assistPanel => 'Panneau d\'assistance';
	@override String get leftRightHanded => 'Gaucher · Droitier';
	@override String get rightLeftHanded => 'Droitier · Gaucher';
	@override String get drawingArea => 'Zone de dessin';
	@override String get debugMode => 'Activer le mode débogage';
	@override String get cloud => 'Cloud & Synchronisation';
	@override String get storageTarget => 'Cible de stockage';
	@override String get storageSubtitle => 'Inkpadu Cloud (gratuit)';
	@override String get encryption => 'Chiffrement';
	@override String get encryptionSubtitle => 'Chiffrement de bout en bout actif';
}

// Path: errors
class _TranslationsErrorsFr extends TranslationsErrorsDe {
	_TranslationsErrorsFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Erreur réseau. Vérifiez votre connexion.';
	@override String get unknownError => 'Une erreur inconnue s\'est produite.';
	@override String get authError => 'Erreur de connexion. Veuillez réessayer.';
	@override String get saveError => 'Échec de la sauvegarde.';
	@override String get loadError => 'Échec du chargement.';
	@override String get exportError => 'Échec de l\'export.';
	@override String loginFailed({required Object provider}) => 'Échec de la connexion (${provider})';
}

// Path: onboarding
class _TranslationsOnboardingFr extends TranslationsOnboardingDe {
	_TranslationsOnboardingFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bienvenue sur Inkpadu';
	@override String get description => 'Esquissez des idées, écrivez des notes et organisez vos pensées avec une écriture manuscrite naturelle.';
	@override String get digitalNotebook => 'Votre carnet de notes numérique';
	@override String get digitalNotebookDescription => 'Une expérience manuscrite optimisée pour la créativité et la concentration – sans distractions.';
	@override String get connecting => 'Connexion…';
	@override String get loginWithGitHub => 'Se connecter avec GitHub';
	@override String get loginWithGoogle => 'Se connecter avec Google';
}

// Path: editor
class _TranslationsEditorFr extends TranslationsEditorDe {
	_TranslationsEditorFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nouvelle note';
	@override String get editNote => 'Modifier la note';
	@override String get title => 'Titre';
	@override String get writeNote => 'Écrivez votre note...';
	@override String get assistPanel => 'Panneau d\'assistance';
	@override String get leftRightHanded => 'Gauchers · Droitiers';
	@override String get rightLeftHanded => 'Droitiers · Gauchers';
	@override String get handednessHint => 'Les droitiers atteignent les outils plus facilement lorsque le panneau est à gauche. Les gauchers choisissent plutôt le côté droit.';
	@override String get drawingArea => 'Zone de dessin';
	@override String get enableDebugMode => 'Activer le mode débogage';
	@override String get debugModeHint => 'Affiche les boîtes de délimitation et les enveloppes convexes dans l\'éditeur et l\'assistant IA.';
	@override String get useLineSimplifier => 'Utiliser le simplificateur de lignes';
	@override String get lineSimplifierHint => 'Lisse vos coups pour obtenir des lignes nettes.';
	@override String smoothingIntensity({required Object value}) => 'Intensité de lissage (${value})';
	@override String get smoothingHint => 'Les valeurs faibles conservent plus de détails, les valeurs élevées lissent davantage.';
	@override String minTolerance({required Object value}) => 'Tolérance minimale (${value} px)';
	@override String get minToleranceHint => 'Définit le seuil pour le lissage – des valeurs plus élevées filtrent les petites irrégularités.';
	@override String get aiPersona => 'Persona de l\'assistant IA';
	@override String get choosePersonaStyle => 'Choisissez le style de votre assistant IA';
	@override String get personaStyleHint => 'La persona détermine comment l\'assistant communique avec vous.';
	@override String get strictTrainer => 'Entraîneur strict';
	@override String get strictTrainerHint => 'Critique directe et sévère comme un entraîneur olympique russe';
	@override String get encouragingMentor => 'Mentor encourageant';
	@override String get encouragingMentorHint => 'Renforcement positif et feedback motivant';
	@override String get customPersona => 'Personnalisé';
	@override String get customPersonaHint => 'Définir votre propre prompt système';
	@override String get yourSystemPrompt => 'Votre prompt système';
	@override String get systemPromptPlaceholder => 'Décrivez comment l\'assistant doit se comporter…';
	@override String get systemPromptHint => 'Le prompt système définit la personnalité et le comportement de l\'assistant dans toutes les demandes.';
	@override String get currentStyle => 'Style actuel';
	@override String get strictTrainerDescription => 'L\'assistant vous donne des retours directs et stricts. Il n\'accepte pas la médiocrité et vous motive à atteindre l\'excellence par des critiques constructives.';
	@override String get encouragingMentorDescription => 'L\'assistant loue vos progrès et vous donne des retours encourageants. Les erreurs sont présentées comme des opportunités d\'apprentissage.';
	@override String get customPersonaDescription => 'L\'assistant se comporte selon votre propre prompt système.';
}

// Path: pdfDialog
class _TranslationsPdfDialogFr extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogFr._(TranslationsFr root) : this._root = root, super.internal(root);

	final TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Sélectionner un PDF';
	@override String get analyzePdf => 'Analyser le PDF';
	@override String get ready => 'Prêt';
	@override String get processPdf => 'Traiter le PDF';
	@override String get importComplete => 'Importation terminée';
	@override String get selectPdfFile => 'Veuillez sélectionner un fichier PDF...';
	@override String get analyzingPdf => 'Analyse du PDF en cours...';
	@override String pagesFound({required Object count}) => '${count} page(s) trouvée(s)';
	@override String get textExtractionBackground => 'L\'extraction de texte se fait en arrière-plan.';
	@override String get couldNotReadPdf => 'Le fichier PDF n\'a pas pu être lu.';
	@override String pagesImported({required Object count}) => '${count} page(s) importée(s)';
	@override String charactersExtracted({required Object count}) => '~${count}k caractères extraits';
	@override String get extractedTextContext => 'Le texte extrait sera utilisé comme contexte pour l\'assistant IA.';
	@override String get textExtractionDuration => 'L\'extraction de texte peut prendre quelques secondes par page.';
	@override String renderingPage({required Object current, required Object total}) => 'Rendu de la page ${current} sur ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Extraction du texte de la page ${current} sur ${total}...';
	@override String get recognizingTasks => 'Reconnaissance des tâches...';
}

/// The flat map containing all translations for locale <fr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsFr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Tes notes, à ta manière',
			'common.save' => 'Sauvegarder',
			'common.cancel' => 'Annuler',
			'common.delete' => 'Supprimer',
			'common.edit' => 'Modifier',
			'common.close' => 'Fermer',
			'common.confirm' => 'Confirmer',
			'common.loading' => 'Chargement...',
			'common.error' => 'Erreur',
			'common.success' => 'Réussi',
			'common.retry' => 'Réessayer',
			'common.search' => 'Rechercher',
			'common.settings' => 'Paramètres',
			'common.back' => 'Retour',
			'common.next' => 'Suivant',
			'common.done' => 'Terminé',
			'common.yes' => 'Oui',
			'common.no' => 'Non',
			'common.apply' => 'Appliquer',
			'common.loggedOut' => 'Déconnecté',
			'common.justNow' => 'À l\'instant',
			'common.minutesAgo' => ({required Object count}) => 'il y a ${count} minute(s)',
			'common.hoursAgo' => ({required Object count}) => 'il y a ${count} heure(s)',
			'common.yesterday' => 'Hier',
			'auth.login' => 'Se connecter',
			'auth.logout' => 'Se déconnecter',
			'auth.register' => 'S\'inscrire',
			'auth.email' => 'E-mail',
			'auth.password' => 'Mot de passe',
			'auth.forgotPassword' => 'Mot de passe oublié ?',
			'auth.welcomeBack' => 'Content de te revoir !',
			'auth.createAccount' => 'Créer un compte',
			'auth.loginWithGoogle' => 'Se connecter avec Google',
			'auth.loginWithApple' => 'Se connecter avec Apple',
			'nav.notes' => 'Notes',
			'nav.settings' => 'Paramètres',
			'notes.title' => 'Notes',
			'notes.newNote' => 'Nouvelle note',
			'notes.untitled' => 'Sans titre',
			'notes.unnamed' => 'Note non nommée',
			'notes.noContent' => 'Pas encore de contenu',
			'notes.noteDate' => 'Note',
			'notes.lastEdited' => 'Dernière modification',
			'notes.deleteNote' => 'Supprimer la note',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Voulez-vous vraiment supprimer « ${title} » ?',
			'notes.deleteNoteTooltip' => 'Supprimer la note',
			'notes.noNotes' => 'Pas encore de notes manuscrites',
			'notes.createFirst' => 'Crée ta première note',
			'notes.createNew' => 'Créer une nouvelle note',
			'notes.export' => 'Exporter',
			'notes.share' => 'Partager',
			'notes.duplicate' => 'Dupliquer',
			'notes.openNote' => 'Ouvrir la note',
			'notes.adjustTitlePaper' => 'Ajuster le titre & le papier',
			'notes.emptyNote' => 'Note vide',
			'notes.emptyNoteSubtitle' => 'Commence avec une page blanche',
			'drawing.pen' => 'Stylo',
			'drawing.pencil' => 'Crayon',
			'drawing.highlighter' => 'Surligneur',
			'drawing.eraser' => 'Gomme',
			'drawing.select' => 'Sélectionner',
			'drawing.lasso' => 'Lasso',
			'drawing.undo' => 'Annuler',
			'drawing.redo' => 'Rétablir',
			'drawing.clear' => 'Effacer',
			'drawing.clearConfirm' => 'Voulez-vous effacer tous les dessins ?',
			'drawing.color' => 'Couleur',
			'drawing.colorWheel' => 'Roue des couleurs',
			'drawing.symbol' => 'Symbole',
			'drawing.strokeWidth' => 'Épaisseur du trait',
			'drawing.zoomIn' => 'Zoomer',
			'drawing.zoomOut' => 'Dézoomer',
			'drawing.markerMode' => 'Mode marqueur (transparent)',
			'drawing.pressureDetection' => 'Détection de pression',
			'drawing.customizeTool' => ({required Object name}) => 'Personnaliser ${name}',
			'drawing.fineliner' => 'Stylos fins',
			'drawing.inkRoller' => 'Roller',
			'drawing.fountainPen' => 'Stylo à plume',
			'drawing.marker' => 'Marqueur',
			'drawing.neon' => 'Néon',
			'paper.plain' => 'Blanc',
			'paper.lined' => 'Ligné',
			'paper.grid' => 'À carreaux',
			'paper.dotted' => 'Pointillé',
			'ai.title' => 'Fonctions IA',
			'ai.assistant' => 'Assistant IA',
			'ai.recognize' => 'Reconnaître du texte',
			'ai.recognizing' => 'Reconnaissance...',
			'ai.summarize' => 'Résumer',
			'ai.extractTasks' => 'Extraire des tâches',
			'ai.translate' => 'Traduire',
			'ai.noTextFound' => 'Aucun texte trouvé',
			'ai.helpMe' => 'Aide-moi',
			'ai.helpMeTitle' => 'Réponse IA',
			'ai.analyzingSelection' => 'Analyse de la sélection…',
			'ai.noSelection' => 'Sélectionne d\'abord quelque chose avec le lasso.',
			'ai.helpMeNotConfigured' => 'L\'IA n\'est pas encore configurée.',
			'ai.persona' => 'Persona de l\'assistant IA',
			'ai.personaSubtitle' => 'Choisissez le style de l\'assistant',
			'pdf.import' => 'Importer PDF',
			'pdf.importSubtitle' => 'Le texte sera extrait automatiquement',
			'pdf.export' => 'Exporter en PDF',
			'pdf.exporting' => 'Création du PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Échec de l\'export PDF : ${error}',
			'pdf.page' => 'Page',
			'pdf.of' => 'de',
			'settings.title' => 'Paramètres',
			'settings.general' => 'Général',
			'settings.theme' => 'Thème',
			'settings.themeSubtitle' => 'Clair · Sombre · Système',
			'settings.darkMode' => 'Mode sombre',
			'settings.lightMode' => 'Mode clair',
			'settings.systemMode' => 'Mode système',
			'settings.language' => 'Langue',
			'settings.languageSubtitle' => 'Français',
			'settings.sync' => 'Synchronisation',
			'settings.syncEnabled' => 'Synchronisation activée',
			'settings.syncDisabled' => 'Synchronisation désactivée',
			'settings.account' => 'Compte',
			'settings.about' => 'À propos',
			'settings.version' => 'Version',
			'settings.privacy' => 'Confidentialité',
			'settings.terms' => 'Conditions d\'utilisation',
			'settings.input' => 'Entrée',
			'settings.inputDevices' => 'Périphériques d\'entrée',
			'settings.inputDeviceSubtitle' => 'Stylo · Tactile · Souris',
			'settings.automation' => 'Automatisation',
			'settings.unlockPen' => 'Déverrouiller le stylo',
			'settings.pen' => 'Stylo',
			'settings.touch' => 'Tactile',
			'settings.mouse' => 'Souris',
			'settings.autoLockOnStylus' => 'Verrouiller automatiquement sur stylet',
			'settings.editorSettings' => 'Paramètres de l\'éditeur',
			'settings.noteEditor' => 'Éditeur de note',
			'settings.noteEditorSubtitle' => 'Panneau latéral gauche · droit',
			'settings.strokeWidths' => 'Épaisseur de trait',
			'settings.strokeWidthsSubtitle' => 'Fin · Moyen · Large',
			'settings.palmRejection' => 'Rejet de la paume',
			'settings.palmRejectionSubtitle' => 'Empêche les entrées non désirées',
			'settings.assistPanel' => 'Panneau d\'assistance',
			'settings.leftRightHanded' => 'Gaucher · Droitier',
			'settings.rightLeftHanded' => 'Droitier · Gaucher',
			'settings.drawingArea' => 'Zone de dessin',
			'settings.debugMode' => 'Activer le mode débogage',
			'settings.cloud' => 'Cloud & Synchronisation',
			'settings.storageTarget' => 'Cible de stockage',
			'settings.storageSubtitle' => 'Inkpadu Cloud (gratuit)',
			'settings.encryption' => 'Chiffrement',
			'settings.encryptionSubtitle' => 'Chiffrement de bout en bout actif',
			'errors.networkError' => 'Erreur réseau. Vérifiez votre connexion.',
			'errors.unknownError' => 'Une erreur inconnue s\'est produite.',
			'errors.authError' => 'Erreur de connexion. Veuillez réessayer.',
			'errors.saveError' => 'Échec de la sauvegarde.',
			'errors.loadError' => 'Échec du chargement.',
			'errors.exportError' => 'Échec de l\'export.',
			'errors.loginFailed' => ({required Object provider}) => 'Échec de la connexion (${provider})',
			'onboarding.welcome' => 'Bienvenue sur Inkpadu',
			'onboarding.description' => 'Esquissez des idées, écrivez des notes et organisez vos pensées avec une écriture manuscrite naturelle.',
			'onboarding.digitalNotebook' => 'Votre carnet de notes numérique',
			'onboarding.digitalNotebookDescription' => 'Une expérience manuscrite optimisée pour la créativité et la concentration – sans distractions.',
			'onboarding.connecting' => 'Connexion…',
			'onboarding.loginWithGitHub' => 'Se connecter avec GitHub',
			'onboarding.loginWithGoogle' => 'Se connecter avec Google',
			'editor.newNote' => 'Nouvelle note',
			'editor.editNote' => 'Modifier la note',
			'editor.title' => 'Titre',
			'editor.writeNote' => 'Écrivez votre note...',
			'editor.assistPanel' => 'Panneau d\'assistance',
			'editor.leftRightHanded' => 'Gauchers · Droitiers',
			'editor.rightLeftHanded' => 'Droitiers · Gauchers',
			'editor.handednessHint' => 'Les droitiers atteignent les outils plus facilement lorsque le panneau est à gauche. Les gauchers choisissent plutôt le côté droit.',
			'editor.drawingArea' => 'Zone de dessin',
			'editor.enableDebugMode' => 'Activer le mode débogage',
			'editor.debugModeHint' => 'Affiche les boîtes de délimitation et les enveloppes convexes dans l\'éditeur et l\'assistant IA.',
			'editor.useLineSimplifier' => 'Utiliser le simplificateur de lignes',
			'editor.lineSimplifierHint' => 'Lisse vos coups pour obtenir des lignes nettes.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Intensité de lissage (${value})',
			'editor.smoothingHint' => 'Les valeurs faibles conservent plus de détails, les valeurs élevées lissent davantage.',
			'editor.minTolerance' => ({required Object value}) => 'Tolérance minimale (${value} px)',
			'editor.minToleranceHint' => 'Définit le seuil pour le lissage – des valeurs plus élevées filtrent les petites irrégularités.',
			'editor.aiPersona' => 'Persona de l\'assistant IA',
			'editor.choosePersonaStyle' => 'Choisissez le style de votre assistant IA',
			'editor.personaStyleHint' => 'La persona détermine comment l\'assistant communique avec vous.',
			'editor.strictTrainer' => 'Entraîneur strict',
			'editor.strictTrainerHint' => 'Critique directe et sévère comme un entraîneur olympique russe',
			'editor.encouragingMentor' => 'Mentor encourageant',
			'editor.encouragingMentorHint' => 'Renforcement positif et feedback motivant',
			'editor.customPersona' => 'Personnalisé',
			'editor.customPersonaHint' => 'Définir votre propre prompt système',
			'editor.yourSystemPrompt' => 'Votre prompt système',
			'editor.systemPromptPlaceholder' => 'Décrivez comment l\'assistant doit se comporter…',
			'editor.systemPromptHint' => 'Le prompt système définit la personnalité et le comportement de l\'assistant dans toutes les demandes.',
			'editor.currentStyle' => 'Style actuel',
			'editor.strictTrainerDescription' => 'L\'assistant vous donne des retours directs et stricts. Il n\'accepte pas la médiocrité et vous motive à atteindre l\'excellence par des critiques constructives.',
			'editor.encouragingMentorDescription' => 'L\'assistant loue vos progrès et vous donne des retours encourageants. Les erreurs sont présentées comme des opportunités d\'apprentissage.',
			'editor.customPersonaDescription' => 'L\'assistant se comporte selon votre propre prompt système.',
			'pdfDialog.selectPdf' => 'Sélectionner un PDF',
			'pdfDialog.analyzePdf' => 'Analyser le PDF',
			'pdfDialog.ready' => 'Prêt',
			'pdfDialog.processPdf' => 'Traiter le PDF',
			'pdfDialog.importComplete' => 'Importation terminée',
			'pdfDialog.selectPdfFile' => 'Veuillez sélectionner un fichier PDF...',
			'pdfDialog.analyzingPdf' => 'Analyse du PDF en cours...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} page(s) trouvée(s)',
			'pdfDialog.textExtractionBackground' => 'L\'extraction de texte se fait en arrière-plan.',
			'pdfDialog.couldNotReadPdf' => 'Le fichier PDF n\'a pas pu être lu.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} page(s) importée(s)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k caractères extraits',
			'pdfDialog.extractedTextContext' => 'Le texte extrait sera utilisé comme contexte pour l\'assistant IA.',
			'pdfDialog.textExtractionDuration' => 'L\'extraction de texte peut prendre quelques secondes par page.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Rendu de la page ${current} sur ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Extraction du texte de la page ${current} sur ${total}...',
			'pdfDialog.recognizingTasks' => 'Reconnaissance des tâches...',
			_ => null,
		};
	}
}
