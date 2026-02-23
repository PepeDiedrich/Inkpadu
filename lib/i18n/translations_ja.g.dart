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
class TranslationsJa extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsJa({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ja,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ja>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsJa _root = this; // ignore: unused_field

	@override 
	TranslationsJa $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsJa(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppJa app = _TranslationsAppJa._(_root);
	@override late final _TranslationsCommonJa common = _TranslationsCommonJa._(_root);
	@override late final _TranslationsAuthJa auth = _TranslationsAuthJa._(_root);
	@override late final _TranslationsNavJa nav = _TranslationsNavJa._(_root);
	@override late final _TranslationsNotesJa notes = _TranslationsNotesJa._(_root);
	@override late final _TranslationsDrawingJa drawing = _TranslationsDrawingJa._(_root);
	@override late final _TranslationsPaperJa paper = _TranslationsPaperJa._(_root);
	@override late final _TranslationsAiJa ai = _TranslationsAiJa._(_root);
	@override late final _TranslationsPdfJa pdf = _TranslationsPdfJa._(_root);
	@override late final _TranslationsSettingsJa settings = _TranslationsSettingsJa._(_root);
	@override late final _TranslationsErrorsJa errors = _TranslationsErrorsJa._(_root);
	@override late final _TranslationsOnboardingJa onboarding = _TranslationsOnboardingJa._(_root);
	@override late final _TranslationsEditorJa editor = _TranslationsEditorJa._(_root);
	@override late final _TranslationsPdfDialogJa pdfDialog = _TranslationsPdfDialogJa._(_root);
}

// Path: app
class _TranslationsAppJa extends TranslationsAppDe {
	_TranslationsAppJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'あなたのノート、あなたのスタイル';
}

// Path: common
class _TranslationsCommonJa extends TranslationsCommonDe {
	_TranslationsCommonJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get save => '保存';
	@override String get cancel => 'キャンセル';
	@override String get delete => '削除';
	@override String get edit => '編集';
	@override String get close => '閉じる';
	@override String get confirm => '確認';
	@override String get loading => '読み込み中...';
	@override String get error => 'エラー';
	@override String get success => '成功';
	@override String get retry => '再試行';
	@override String get search => '検索';
	@override String get settings => '設定';
	@override String get back => '戻る';
	@override String get next => '次へ';
	@override String get done => '完了';
	@override String get yes => 'はい';
	@override String get no => 'いいえ';
	@override String get apply => '適用';
	@override String get loggedOut => 'ログアウトしました';
	@override String get justNow => 'たった今';
	@override String minutesAgo({required Object count}) => '${count} 分前';
	@override String hoursAgo({required Object count}) => '${count} 時間前';
	@override String get yesterday => '昨日';
}

// Path: auth
class _TranslationsAuthJa extends TranslationsAuthDe {
	_TranslationsAuthJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get login => 'ログイン';
	@override String get logout => 'ログアウト';
	@override String get register => '登録';
	@override String get email => 'Eメール';
	@override String get password => 'パスワード';
	@override String get forgotPassword => 'パスワードを忘れましたか？';
	@override String get welcomeBack => 'お帰りなさい！';
	@override String get createAccount => 'アカウントを作成';
	@override String get loginWithGoogle => 'Googleでログイン';
	@override String get loginWithApple => 'Appleでログイン';
}

// Path: nav
class _TranslationsNavJa extends TranslationsNavDe {
	_TranslationsNavJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get notes => 'ノート';
	@override String get settings => '設定';
}

// Path: notes
class _TranslationsNotesJa extends TranslationsNotesDe {
	_TranslationsNotesJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'ノート';
	@override String get newNote => '新しいノート';
	@override String get untitled => 'タイトルなし';
	@override String get unnamed => '無名ノート';
	@override String get noContent => 'まだコンテンツがありません';
	@override String get noteDate => 'ノート';
	@override String get lastEdited => '最終編集日';
	@override String get deleteNote => 'ノートを削除';
	@override String deleteNoteConfirm({required Object title}) => '本当に「${title}」を削除しますか？';
	@override String get deleteNoteTooltip => 'ノートを削除';
	@override String get noNotes => 'まだ手書きのノートはありません';
	@override String get createFirst => '最初のノートを作成';
	@override String get createNew => '新しいノートを作成';
	@override String get export => 'エクスポート';
	@override String get share => '共有';
	@override String get duplicate => '複製';
	@override String get openNote => 'ノートを開く';
	@override String get adjustTitlePaper => 'タイトルと用紙を調整';
	@override String get emptyNote => '空のノート';
	@override String get emptyNoteSubtitle => '空白のページから始めましょう';
}

// Path: drawing
class _TranslationsDrawingJa extends TranslationsDrawingDe {
	_TranslationsDrawingJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get pen => 'ペン';
	@override String get pencil => '鉛筆';
	@override String get highlighter => '蛍光ペン';
	@override String get eraser => '消しゴム';
	@override String get select => '選択';
	@override String get lasso => '投げ縄';
	@override String get undo => '元に戻す';
	@override String get redo => 'やり直す';
	@override String get clear => '消去';
	@override String get clearConfirm => 'すべての描画を削除しますか？';
	@override String get color => '色';
	@override String get colorWheel => 'カラーホイール';
	@override String get symbol => 'シンボル';
	@override String get strokeWidth => '筆の太さ';
	@override String get zoomIn => 'ズームイン';
	@override String get zoomOut => 'ズームアウト';
	@override String get markerMode => 'マーカー モード (透過)';
	@override String get pressureDetection => '圧力検出';
	@override String customizeTool({required Object name}) => '${name}をカスタマイズ';
	@override String get fineliner => 'ファインライナー';
	@override String get inkRoller => 'インクローラー';
	@override String get fountainPen => '万年筆';
	@override String get marker => 'マーカー';
	@override String get neon => 'ネオン';
}

// Path: paper
class _TranslationsPaperJa extends TranslationsPaperDe {
	_TranslationsPaperJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get plain => '無地';
	@override String get lined => '罫線';
	@override String get grid => '方眼';
	@override String get dotted => '点線';
}

// Path: ai
class _TranslationsAiJa extends TranslationsAiDe {
	_TranslationsAiJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI機能';
	@override String get assistant => 'AIアシスタント';
	@override String get recognize => 'テキスト認識';
	@override String get recognizing => '認識中...';
	@override String get summarize => '要約';
	@override String get extractTasks => 'タスクを抽出';
	@override String get translate => '翻訳';
	@override String get noTextFound => 'テキストが見つかりません';
	@override String get helpMe => '助けて';
	@override String get helpMeTitle => 'AIの回答';
	@override String get analyzingSelection => '選択範囲を分析中…';
	@override String get noSelection => '先に投げ縄で何かを選択してください。';
	@override String get helpMeNotConfigured => 'AIはまだ設定されていません。';
	@override String get persona => 'AIアシスタントのペルソナ';
	@override String get personaSubtitle => 'アシスタントのスタイルを選択';
}

// Path: pdf
class _TranslationsPdfJa extends TranslationsPdfDe {
	_TranslationsPdfJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get import => 'PDFをインポート';
	@override String get importSubtitle => 'テキストが自動的に抽出されます';
	@override String get export => 'PDFとしてエクスポート';
	@override String get exporting => 'PDFを生成中...';
	@override String exportFailed({required Object error}) => 'PDFエクスポートに失敗しました: ${error}';
	@override String get page => 'ページ';
	@override String get of => 'の';
}

// Path: settings
class _TranslationsSettingsJa extends TranslationsSettingsDe {
	_TranslationsSettingsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get title => '設定';
	@override String get general => '一般';
	@override String get theme => 'テーマ';
	@override String get themeSubtitle => '明るい · 暗い · システム';
	@override String get darkMode => 'ダークモード';
	@override String get lightMode => 'ライトモード';
	@override String get systemMode => 'システムモード';
	@override String get language => '言語';
	@override String get languageSubtitle => '日本語 (ベータ)';
	@override String get sync => '同期';
	@override String get syncEnabled => '同期が有効';
	@override String get syncDisabled => '同期が無効';
	@override String get account => 'アカウント';
	@override String get about => 'について';
	@override String get version => 'バージョン';
	@override String get privacy => 'プライバシー';
	@override String get terms => '利用規約';
	@override String get input => '入力';
	@override String get inputDevices => '入力デバイス';
	@override String get inputDeviceSubtitle => 'ペン · タッチ · マウス';
	@override String get automation => '自動化';
	@override String get unlockPen => 'ペンのロックを解除';
	@override String get pen => 'ペン';
	@override String get touch => 'タッチ';
	@override String get mouse => 'マウス';
	@override String get autoLockOnStylus => 'スタイラスで自動ロック';
	@override String get editorSettings => 'エディター設定';
	@override String get noteEditor => 'ノートエディタ';
	@override String get noteEditorSubtitle => 'ページパネル 左 · 右';
	@override String get strokeWidths => 'ペンの太さ';
	@override String get strokeWidthsSubtitle => '細い · 中 · 太い';
	@override String get palmRejection => 'パームリジェction';
	@override String get palmRejectionSubtitle => '不要な入力を防ぎます';
	@override String get assistPanel => 'アシストパネル';
	@override String get leftRightHanded => '左利き · 右利き';
	@override String get rightLeftHanded => '右利き · 左利き';
	@override String get drawingArea => '描画エリア';
	@override String get debugMode => 'デバッグモードを有効にする';
	@override String get cloud => 'クラウド＆同期';
	@override String get storageTarget => '保存先';
	@override String get storageSubtitle => 'Inkpaduクラウド（無料）';
	@override String get encryption => '暗号化';
	@override String get encryptionSubtitle => 'エンドツーエンドでアクティブ';
}

// Path: errors
class _TranslationsErrorsJa extends TranslationsErrorsDe {
	_TranslationsErrorsJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'ネットワークエラー。接続を確認してください。';
	@override String get unknownError => '不明なエラーが発生しました。';
	@override String get authError => 'ログインエラー。再試行してください。';
	@override String get saveError => '保存に失敗しました。';
	@override String get loadError => '読み込みに失敗しました。';
	@override String get exportError => 'エクスポートに失敗しました。';
	@override String loginFailed({required Object provider}) => '${provider}でのログインに失敗しました';
}

// Path: onboarding
class _TranslationsOnboardingJa extends TranslationsOnboardingDe {
	_TranslationsOnboardingJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Inkpaduへようこそ';
	@override String get description => 'アイデアをスケッチし、ノートを書き、自然な手書きで考えを整理します。';
	@override String get digitalNotebook => 'あなたのデジタルノートブック';
	@override String get digitalNotebookDescription => '創造性と集中のために最適化された手書きの体験 - 攪乱なし。';
	@override String get connecting => '接続中...';
	@override String get loginWithGitHub => 'GitHubでログイン';
	@override String get loginWithGoogle => 'Googleでログイン';
}

// Path: editor
class _TranslationsEditorJa extends TranslationsEditorDe {
	_TranslationsEditorJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get newNote => '新しいノート';
	@override String get editNote => 'ノートを編集';
	@override String get title => 'タイトル';
	@override String get writeNote => 'ノートを書いてください...';
	@override String get assistPanel => 'アシストパネル';
	@override String get leftRightHanded => '左 · 右利き';
	@override String get rightLeftHanded => '右 · 左利き';
	@override String get handednessHint => '右利きの方はツールが左側にあると便利です。左利きの方は右側を選択してください。';
	@override String get drawingArea => '描画エリア';
	@override String get enableDebugMode => 'デバッグモードを有効にする';
	@override String get debugModeHint => 'エディタとAIアシスタント内でバウンディングボックスと凸包を表示します。';
	@override String get useLineSimplifier => 'ライン簡素化ツールを使用';
	@override String get lineSimplifierHint => '自動的に線を滑らかにし、きれいなラインを得ます。';
	@override String smoothingIntensity({required Object value}) => '滑らかさの強度 (${value})';
	@override String get smoothingHint => '低い値は詳細を保持し、高い値はより滑らかになります。';
	@override String minTolerance({required Object value}) => '最小許容値 (${value} px)';
	@override String get minToleranceHint => '滑らかさの下限を設定 - 高い値は小さなギザギザをフィルタリングします。';
	@override String get aiPersona => 'AIアシスタントのペルソナ';
	@override String get choosePersonaStyle => 'AIアシスタントのスタイルを選ぶ';
	@override String get personaStyleHint => 'ペルソナはアシスタントとのコミュニケーションスタイルを決定します。';
	@override String get strictTrainer => '厳格なトレーナー';
	@override String get strictTrainerHint => 'ロシアのオリンピックコーチのように直接的で厳しい批評';
	@override String get encouragingMentor => '励ましのメンター';
	@override String get encouragingMentorHint => 'ポジティブな強化とモチベーションのフィードバック';
	@override String get customPersona => 'カスタム';
	@override String get customPersonaHint => '独自のシステムプロンプトを設定';
	@override String get yourSystemPrompt => 'あなたのシステムプロンプト';
	@override String get systemPromptPlaceholder => 'アシスタントの動作を説明してください...';
	@override String get systemPromptHint => 'システムプロンプトは、アシスタントがすべてのリクエストでどのように振る舞うかを定義します。';
	@override String get currentStyle => '現在のスタイル';
	@override String get strictTrainerDescription => 'アシスタントは厳しいフィードバックを提供します。平凡を受け入れず、建設的な批評を通して最高のパフォーマンスを引き出します。';
	@override String get encouragingMentorDescription => 'アシスタントは進歩を称賛し、励ましのフィードバックを提供します。ミスは学びの機会として捉えられます。';
	@override String get customPersonaDescription => 'アシスタントはあなた自身のシステムプロンプトに従って行動します。';
}

// Path: pdfDialog
class _TranslationsPdfDialogJa extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogJa._(TranslationsJa root) : this._root = root, super.internal(root);

	final TranslationsJa _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'PDFを選択';
	@override String get analyzePdf => 'PDFを分析';
	@override String get ready => '準備完了';
	@override String get processPdf => 'PDFを処理';
	@override String get importComplete => 'インポート完了';
	@override String get selectPdfFile => 'PDFファイルを選択してください...';
	@override String get analyzingPdf => 'PDFを分析中...';
	@override String pagesFound({required Object count}) => '${count} ページが見つかりました';
	@override String get textExtractionBackground => 'テキスト抽出はバックグラウンドで行われます。';
	@override String get couldNotReadPdf => 'PDFファイルを読み込めませんでした。';
	@override String pagesImported({required Object count}) => '${count} ページがインポートされました';
	@override String charactersExtracted({required Object count}) => '~${count}k 文字が抽出されました';
	@override String get extractedTextContext => '抽出されたテキストはAIアシスタントのコンテキストとして使用されます。';
	@override String get textExtractionDuration => 'テキスト抽出は1ページあたり数秒かかる場合があります。';
	@override String renderingPage({required Object total, required Object current}) => '${total} ページ中の ${current} ページをレンダリング中...';
	@override String extractingPage({required Object total, required Object current}) => '${total} ページ中の ${current} ページからテキストを抽出中...';
	@override String get recognizingTasks => 'タスクを認識中...';
}

/// The flat map containing all translations for locale <ja>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsJa {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'あなたのノート、あなたのスタイル',
			'common.save' => '保存',
			'common.cancel' => 'キャンセル',
			'common.delete' => '削除',
			'common.edit' => '編集',
			'common.close' => '閉じる',
			'common.confirm' => '確認',
			'common.loading' => '読み込み中...',
			'common.error' => 'エラー',
			'common.success' => '成功',
			'common.retry' => '再試行',
			'common.search' => '検索',
			'common.settings' => '設定',
			'common.back' => '戻る',
			'common.next' => '次へ',
			'common.done' => '完了',
			'common.yes' => 'はい',
			'common.no' => 'いいえ',
			'common.apply' => '適用',
			'common.loggedOut' => 'ログアウトしました',
			'common.justNow' => 'たった今',
			'common.minutesAgo' => ({required Object count}) => '${count} 分前',
			'common.hoursAgo' => ({required Object count}) => '${count} 時間前',
			'common.yesterday' => '昨日',
			'auth.login' => 'ログイン',
			'auth.logout' => 'ログアウト',
			'auth.register' => '登録',
			'auth.email' => 'Eメール',
			'auth.password' => 'パスワード',
			'auth.forgotPassword' => 'パスワードを忘れましたか？',
			'auth.welcomeBack' => 'お帰りなさい！',
			'auth.createAccount' => 'アカウントを作成',
			'auth.loginWithGoogle' => 'Googleでログイン',
			'auth.loginWithApple' => 'Appleでログイン',
			'nav.notes' => 'ノート',
			'nav.settings' => '設定',
			'notes.title' => 'ノート',
			'notes.newNote' => '新しいノート',
			'notes.untitled' => 'タイトルなし',
			'notes.unnamed' => '無名ノート',
			'notes.noContent' => 'まだコンテンツがありません',
			'notes.noteDate' => 'ノート',
			'notes.lastEdited' => '最終編集日',
			'notes.deleteNote' => 'ノートを削除',
			'notes.deleteNoteConfirm' => ({required Object title}) => '本当に「${title}」を削除しますか？',
			'notes.deleteNoteTooltip' => 'ノートを削除',
			'notes.noNotes' => 'まだ手書きのノートはありません',
			'notes.createFirst' => '最初のノートを作成',
			'notes.createNew' => '新しいノートを作成',
			'notes.export' => 'エクスポート',
			'notes.share' => '共有',
			'notes.duplicate' => '複製',
			'notes.openNote' => 'ノートを開く',
			'notes.adjustTitlePaper' => 'タイトルと用紙を調整',
			'notes.emptyNote' => '空のノート',
			'notes.emptyNoteSubtitle' => '空白のページから始めましょう',
			'drawing.pen' => 'ペン',
			'drawing.pencil' => '鉛筆',
			'drawing.highlighter' => '蛍光ペン',
			'drawing.eraser' => '消しゴム',
			'drawing.select' => '選択',
			'drawing.lasso' => '投げ縄',
			'drawing.undo' => '元に戻す',
			'drawing.redo' => 'やり直す',
			'drawing.clear' => '消去',
			'drawing.clearConfirm' => 'すべての描画を削除しますか？',
			'drawing.color' => '色',
			'drawing.colorWheel' => 'カラーホイール',
			'drawing.symbol' => 'シンボル',
			'drawing.strokeWidth' => '筆の太さ',
			'drawing.zoomIn' => 'ズームイン',
			'drawing.zoomOut' => 'ズームアウト',
			'drawing.markerMode' => 'マーカー モード (透過)',
			'drawing.pressureDetection' => '圧力検出',
			'drawing.customizeTool' => ({required Object name}) => '${name}をカスタマイズ',
			'drawing.fineliner' => 'ファインライナー',
			'drawing.inkRoller' => 'インクローラー',
			'drawing.fountainPen' => '万年筆',
			'drawing.marker' => 'マーカー',
			'drawing.neon' => 'ネオン',
			'paper.plain' => '無地',
			'paper.lined' => '罫線',
			'paper.grid' => '方眼',
			'paper.dotted' => '点線',
			'ai.title' => 'AI機能',
			'ai.assistant' => 'AIアシスタント',
			'ai.recognize' => 'テキスト認識',
			'ai.recognizing' => '認識中...',
			'ai.summarize' => '要約',
			'ai.extractTasks' => 'タスクを抽出',
			'ai.translate' => '翻訳',
			'ai.noTextFound' => 'テキストが見つかりません',
			'ai.helpMe' => '助けて',
			'ai.helpMeTitle' => 'AIの回答',
			'ai.analyzingSelection' => '選択範囲を分析中…',
			'ai.noSelection' => '先に投げ縄で何かを選択してください。',
			'ai.helpMeNotConfigured' => 'AIはまだ設定されていません。',
			'ai.persona' => 'AIアシスタントのペルソナ',
			'ai.personaSubtitle' => 'アシスタントのスタイルを選択',
			'pdf.import' => 'PDFをインポート',
			'pdf.importSubtitle' => 'テキストが自動的に抽出されます',
			'pdf.export' => 'PDFとしてエクスポート',
			'pdf.exporting' => 'PDFを生成中...',
			'pdf.exportFailed' => ({required Object error}) => 'PDFエクスポートに失敗しました: ${error}',
			'pdf.page' => 'ページ',
			'pdf.of' => 'の',
			'settings.title' => '設定',
			'settings.general' => '一般',
			'settings.theme' => 'テーマ',
			'settings.themeSubtitle' => '明るい · 暗い · システム',
			'settings.darkMode' => 'ダークモード',
			'settings.lightMode' => 'ライトモード',
			'settings.systemMode' => 'システムモード',
			'settings.language' => '言語',
			'settings.languageSubtitle' => '日本語 (ベータ)',
			'settings.sync' => '同期',
			'settings.syncEnabled' => '同期が有効',
			'settings.syncDisabled' => '同期が無効',
			'settings.account' => 'アカウント',
			'settings.about' => 'について',
			'settings.version' => 'バージョン',
			'settings.privacy' => 'プライバシー',
			'settings.terms' => '利用規約',
			'settings.input' => '入力',
			'settings.inputDevices' => '入力デバイス',
			'settings.inputDeviceSubtitle' => 'ペン · タッチ · マウス',
			'settings.automation' => '自動化',
			'settings.unlockPen' => 'ペンのロックを解除',
			'settings.pen' => 'ペン',
			'settings.touch' => 'タッチ',
			'settings.mouse' => 'マウス',
			'settings.autoLockOnStylus' => 'スタイラスで自動ロック',
			'settings.editorSettings' => 'エディター設定',
			'settings.noteEditor' => 'ノートエディタ',
			'settings.noteEditorSubtitle' => 'ページパネル 左 · 右',
			'settings.strokeWidths' => 'ペンの太さ',
			'settings.strokeWidthsSubtitle' => '細い · 中 · 太い',
			'settings.palmRejection' => 'パームリジェction',
			'settings.palmRejectionSubtitle' => '不要な入力を防ぎます',
			'settings.assistPanel' => 'アシストパネル',
			'settings.leftRightHanded' => '左利き · 右利き',
			'settings.rightLeftHanded' => '右利き · 左利き',
			'settings.drawingArea' => '描画エリア',
			'settings.debugMode' => 'デバッグモードを有効にする',
			'settings.cloud' => 'クラウド＆同期',
			'settings.storageTarget' => '保存先',
			'settings.storageSubtitle' => 'Inkpaduクラウド（無料）',
			'settings.encryption' => '暗号化',
			'settings.encryptionSubtitle' => 'エンドツーエンドでアクティブ',
			'errors.networkError' => 'ネットワークエラー。接続を確認してください。',
			'errors.unknownError' => '不明なエラーが発生しました。',
			'errors.authError' => 'ログインエラー。再試行してください。',
			'errors.saveError' => '保存に失敗しました。',
			'errors.loadError' => '読み込みに失敗しました。',
			'errors.exportError' => 'エクスポートに失敗しました。',
			'errors.loginFailed' => ({required Object provider}) => '${provider}でのログインに失敗しました',
			'onboarding.welcome' => 'Inkpaduへようこそ',
			'onboarding.description' => 'アイデアをスケッチし、ノートを書き、自然な手書きで考えを整理します。',
			'onboarding.digitalNotebook' => 'あなたのデジタルノートブック',
			'onboarding.digitalNotebookDescription' => '創造性と集中のために最適化された手書きの体験 - 攪乱なし。',
			'onboarding.connecting' => '接続中...',
			'onboarding.loginWithGitHub' => 'GitHubでログイン',
			'onboarding.loginWithGoogle' => 'Googleでログイン',
			'editor.newNote' => '新しいノート',
			'editor.editNote' => 'ノートを編集',
			'editor.title' => 'タイトル',
			'editor.writeNote' => 'ノートを書いてください...',
			'editor.assistPanel' => 'アシストパネル',
			'editor.leftRightHanded' => '左 · 右利き',
			'editor.rightLeftHanded' => '右 · 左利き',
			'editor.handednessHint' => '右利きの方はツールが左側にあると便利です。左利きの方は右側を選択してください。',
			'editor.drawingArea' => '描画エリア',
			'editor.enableDebugMode' => 'デバッグモードを有効にする',
			'editor.debugModeHint' => 'エディタとAIアシスタント内でバウンディングボックスと凸包を表示します。',
			'editor.useLineSimplifier' => 'ライン簡素化ツールを使用',
			'editor.lineSimplifierHint' => '自動的に線を滑らかにし、きれいなラインを得ます。',
			'editor.smoothingIntensity' => ({required Object value}) => '滑らかさの強度 (${value})',
			'editor.smoothingHint' => '低い値は詳細を保持し、高い値はより滑らかになります。',
			'editor.minTolerance' => ({required Object value}) => '最小許容値 (${value} px)',
			'editor.minToleranceHint' => '滑らかさの下限を設定 - 高い値は小さなギザギザをフィルタリングします。',
			'editor.aiPersona' => 'AIアシスタントのペルソナ',
			'editor.choosePersonaStyle' => 'AIアシスタントのスタイルを選ぶ',
			'editor.personaStyleHint' => 'ペルソナはアシスタントとのコミュニケーションスタイルを決定します。',
			'editor.strictTrainer' => '厳格なトレーナー',
			'editor.strictTrainerHint' => 'ロシアのオリンピックコーチのように直接的で厳しい批評',
			'editor.encouragingMentor' => '励ましのメンター',
			'editor.encouragingMentorHint' => 'ポジティブな強化とモチベーションのフィードバック',
			'editor.customPersona' => 'カスタム',
			'editor.customPersonaHint' => '独自のシステムプロンプトを設定',
			'editor.yourSystemPrompt' => 'あなたのシステムプロンプト',
			'editor.systemPromptPlaceholder' => 'アシスタントの動作を説明してください...',
			'editor.systemPromptHint' => 'システムプロンプトは、アシスタントがすべてのリクエストでどのように振る舞うかを定義します。',
			'editor.currentStyle' => '現在のスタイル',
			'editor.strictTrainerDescription' => 'アシスタントは厳しいフィードバックを提供します。平凡を受け入れず、建設的な批評を通して最高のパフォーマンスを引き出します。',
			'editor.encouragingMentorDescription' => 'アシスタントは進歩を称賛し、励ましのフィードバックを提供します。ミスは学びの機会として捉えられます。',
			'editor.customPersonaDescription' => 'アシスタントはあなた自身のシステムプロンプトに従って行動します。',
			'pdfDialog.selectPdf' => 'PDFを選択',
			'pdfDialog.analyzePdf' => 'PDFを分析',
			'pdfDialog.ready' => '準備完了',
			'pdfDialog.processPdf' => 'PDFを処理',
			'pdfDialog.importComplete' => 'インポート完了',
			'pdfDialog.selectPdfFile' => 'PDFファイルを選択してください...',
			'pdfDialog.analyzingPdf' => 'PDFを分析中...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} ページが見つかりました',
			'pdfDialog.textExtractionBackground' => 'テキスト抽出はバックグラウンドで行われます。',
			'pdfDialog.couldNotReadPdf' => 'PDFファイルを読み込めませんでした。',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} ページがインポートされました',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k 文字が抽出されました',
			'pdfDialog.extractedTextContext' => '抽出されたテキストはAIアシスタントのコンテキストとして使用されます。',
			'pdfDialog.textExtractionDuration' => 'テキスト抽出は1ページあたり数秒かかる場合があります。',
			'pdfDialog.renderingPage' => ({required Object total, required Object current}) => '${total} ページ中の ${current} ページをレンダリング中...',
			'pdfDialog.extractingPage' => ({required Object total, required Object current}) => '${total} ページ中の ${current} ページからテキストを抽出中...',
			'pdfDialog.recognizingTasks' => 'タスクを認識中...',
			_ => null,
		};
	}
}
