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
class TranslationsZh extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsZh({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.zh,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <zh>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsZh _root = this; // ignore: unused_field

	@override 
	TranslationsZh $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsZh(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppZh app = _TranslationsAppZh._(_root);
	@override late final _TranslationsCommonZh common = _TranslationsCommonZh._(_root);
	@override late final _TranslationsAuthZh auth = _TranslationsAuthZh._(_root);
	@override late final _TranslationsNavZh nav = _TranslationsNavZh._(_root);
	@override late final _TranslationsNotesZh notes = _TranslationsNotesZh._(_root);
	@override late final _TranslationsDrawingZh drawing = _TranslationsDrawingZh._(_root);
	@override late final _TranslationsPaperZh paper = _TranslationsPaperZh._(_root);
	@override late final _TranslationsAiZh ai = _TranslationsAiZh._(_root);
	@override late final _TranslationsPdfZh pdf = _TranslationsPdfZh._(_root);
	@override late final _TranslationsSettingsZh settings = _TranslationsSettingsZh._(_root);
	@override late final _TranslationsErrorsZh errors = _TranslationsErrorsZh._(_root);
	@override late final _TranslationsOnboardingZh onboarding = _TranslationsOnboardingZh._(_root);
	@override late final _TranslationsEditorZh editor = _TranslationsEditorZh._(_root);
	@override late final _TranslationsPdfDialogZh pdfDialog = _TranslationsPdfDialogZh._(_root);
}

// Path: app
class _TranslationsAppZh extends TranslationsAppDe {
	_TranslationsAppZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => '你的笔记，你的方式';
}

// Path: common
class _TranslationsCommonZh extends TranslationsCommonDe {
	_TranslationsCommonZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get save => '保存';
	@override String get cancel => '取消';
	@override String get delete => '删除';
	@override String get edit => '编辑';
	@override String get close => '关闭';
	@override String get confirm => '确认';
	@override String get loading => '加载中...';
	@override String get error => '错误';
	@override String get success => '成功';
	@override String get retry => '重试';
	@override String get search => '搜索';
	@override String get settings => '设置';
	@override String get back => '返回';
	@override String get next => '下一步';
	@override String get done => '完成';
	@override String get yes => '是';
	@override String get no => '否';
	@override String get apply => '应用';
	@override String get loggedOut => '已注销';
	@override String get justNow => '刚刚';
	@override String minutesAgo({required Object count}) => '前 ${count} 分钟';
	@override String hoursAgo({required Object count}) => '前 ${count} 小时';
	@override String get yesterday => '昨天';
}

// Path: auth
class _TranslationsAuthZh extends TranslationsAuthDe {
	_TranslationsAuthZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get login => '登录';
	@override String get logout => '注销';
	@override String get register => '注册';
	@override String get email => '电子邮箱';
	@override String get password => '密码';
	@override String get forgotPassword => '忘记密码？';
	@override String get welcomeBack => '欢迎回来！';
	@override String get createAccount => '创建账户';
	@override String get loginWithGoogle => '使用 Google 登录';
	@override String get loginWithApple => '使用 Apple 登录';
}

// Path: nav
class _TranslationsNavZh extends TranslationsNavDe {
	_TranslationsNavZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get notes => '笔记';
	@override String get settings => '设置';
}

// Path: notes
class _TranslationsNotesZh extends TranslationsNotesDe {
	_TranslationsNotesZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '笔记';
	@override String get newNote => '新笔记';
	@override String get untitled => '未命名';
	@override String get unnamed => '未命名笔记';
	@override String get noContent => '还没有内容';
	@override String get noteDate => '笔记';
	@override String get lastEdited => '最后编辑时间';
	@override String get deleteNote => '删除笔记';
	@override String deleteNoteConfirm({required Object title}) => '您确定要删除 "${title}" 吗?';
	@override String get deleteNoteTooltip => '删除笔记';
	@override String get noNotes => '还没有手写笔记';
	@override String get createFirst => '创建你的第一篇笔记';
	@override String get createNew => '创建新笔记';
	@override String get export => '导出';
	@override String get share => '分享';
	@override String get duplicate => '复制';
	@override String get openNote => '打开笔记';
	@override String get adjustTitlePaper => '调整标题和纸张';
	@override String get emptyNote => '空白笔记';
	@override String get emptyNoteSubtitle => '从空白页面开始';
}

// Path: drawing
class _TranslationsDrawingZh extends TranslationsDrawingDe {
	_TranslationsDrawingZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get pen => '钢笔';
	@override String get pencil => '铅笔';
	@override String get highlighter => '荧光笔';
	@override String get eraser => '橡皮擦';
	@override String get select => '选择';
	@override String get lasso => '套索';
	@override String get undo => '撤销';
	@override String get redo => '重做';
	@override String get clear => '清除';
	@override String get clearConfirm => '要清除所有绘图吗?';
	@override String get color => '颜色';
	@override String get colorWheel => '色轮';
	@override String get symbol => '符号';
	@override String get strokeWidth => '笔划宽度';
	@override String get zoomIn => '放大';
	@override String get zoomOut => '缩小';
	@override String get markerMode => '标记模式（透明）';
	@override String get pressureDetection => '压力感应';
	@override String customizeTool({required Object name}) => '${name} 自定义';
	@override String get fineliner => '细笔';
	@override String get inkRoller => '墨水滚筒';
	@override String get fountainPen => '钢笔';
	@override String get marker => '记号笔';
	@override String get neon => '霓虹';
}

// Path: paper
class _TranslationsPaperZh extends TranslationsPaperDe {
	_TranslationsPaperZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get plain => '空白';
	@override String get lined => '带线';
	@override String get grid => '方格';
	@override String get dotted => '点状';
}

// Path: ai
class _TranslationsAiZh extends TranslationsAiDe {
	_TranslationsAiZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 功能';
	@override String get assistant => 'AI助手';
	@override String get recognize => '识别文本';
	@override String get recognizing => '识别中...';
	@override String get summarize => '总结';
	@override String get extractTasks => '提取任务';
	@override String get translate => '翻译';
	@override String get noTextFound => '未找到文本';
	@override String get helpMe => '帮帮我';
	@override String get helpMeTitle => 'AI 回复';
	@override String get analyzingSelection => '正在分析选区…';
	@override String get noSelection => '请先用套索选中内容。';
	@override String get helpMeNotConfigured => 'AI 尚未配置。';
	@override String get persona => 'AI 助手角色';
	@override String get personaSubtitle => '选择助手风格';
}

// Path: pdf
class _TranslationsPdfZh extends TranslationsPdfDe {
	_TranslationsPdfZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get import => '导入 PDF';
	@override String get importSubtitle => '文本将自动提取';
	@override String get export => '导出为 PDF';
	@override String get exporting => 'PDF 正在生成...';
	@override String exportFailed({required Object error}) => 'PDF 导出失败: ${error}';
	@override String get page => '页';
	@override String get of => '的';
}

// Path: settings
class _TranslationsSettingsZh extends TranslationsSettingsDe {
	_TranslationsSettingsZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get title => '设置';
	@override String get general => '常规';
	@override String get theme => '主题';
	@override String get themeSubtitle => '亮 · 暗 · 系统';
	@override String get darkMode => '深色模式';
	@override String get lightMode => '浅色模式';
	@override String get systemMode => '系统默认';
	@override String get language => '语言';
	@override String get languageSubtitle => '德语 (测试版)';
	@override String get sync => '同步';
	@override String get syncEnabled => '同步已启用';
	@override String get syncDisabled => '同步已禁用';
	@override String get account => '账户';
	@override String get about => '关于';
	@override String get version => '版本';
	@override String get privacy => '隐私';
	@override String get terms => '服务条款';
	@override String get input => '输入';
	@override String get inputDevices => '输入设备';
	@override String get inputDeviceSubtitle => '笔 · 触摸 · 鼠标';
	@override String get automation => '自动化';
	@override String get unlockPen => '解锁钢笔';
	@override String get pen => '钢笔';
	@override String get touch => '触控';
	@override String get mouse => '鼠标';
	@override String get autoLockOnStylus => '自动锁定在钢笔上';
	@override String get editorSettings => '编辑器设置';
	@override String get noteEditor => '笔记编辑器';
	@override String get noteEditorSubtitle => '左侧或右侧面板';
	@override String get strokeWidths => '笔划宽度';
	@override String get strokeWidthsSubtitle => '细 · 中 · 粗';
	@override String get palmRejection => '手掌识别';
	@override String get palmRejectionSubtitle => '防止误输入';
	@override String get assistPanel => '助手面板';
	@override String get leftRightHanded => '左手 · 右手';
	@override String get rightLeftHanded => '右手 · 左手';
	@override String get drawingArea => '绘图区域';
	@override String get debugMode => '启用调试模式';
	@override String get cloud => '云与同步';
	@override String get storageTarget => '存储目标';
	@override String get storageSubtitle => 'Inkpadu 云 (免费)';
	@override String get encryption => '加密';
	@override String get encryptionSubtitle => '端到端激活';
}

// Path: errors
class _TranslationsErrorsZh extends TranslationsErrorsDe {
	_TranslationsErrorsZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get networkError => '网络错误。请检查你的连接。';
	@override String get unknownError => '发生未知错误。';
	@override String get authError => '登录错误。请重试。';
	@override String get saveError => '保存失败。';
	@override String get loadError => '加载失败。';
	@override String get exportError => '导出失败。';
	@override String loginFailed({required Object provider}) => '登录 (${provider}) 失败';
}

// Path: onboarding
class _TranslationsOnboardingZh extends TranslationsOnboardingDe {
	_TranslationsOnboardingZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get welcome => '欢迎使用 Inkpadu';
	@override String get description => '用自然的手写签名勾画想法，写下笔记，组织你的思维。';
	@override String get digitalNotebook => '你的数字笔记本';
	@override String get digitalNotebookDescription => '优化创造力和专注的手写体验 - 无干扰。';
	@override String get connecting => '连接中...';
	@override String get loginWithGitHub => '使用 GitHub 登录';
	@override String get loginWithGoogle => '使用 Google 登录';
}

// Path: editor
class _TranslationsEditorZh extends TranslationsEditorDe {
	_TranslationsEditorZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get newNote => '新笔记';
	@override String get editNote => '编辑笔记';
	@override String get title => '标题';
	@override String get writeNote => '写下你的笔记...';
	@override String get assistPanel => '辅助面板';
	@override String get leftRightHanded => '左手 · 右手';
	@override String get rightLeftHanded => '右手 · 左手';
	@override String get handednessHint => '右手用户在左侧面板上更便于操作。左手用户则选择右侧。';
	@override String get drawingArea => '绘画区域';
	@override String get enableDebugMode => '启用调试模式';
	@override String get debugModeHint => '在编辑器及 AI 助手中显示边界框和凸包。';
	@override String get useLineSimplifier => '使用线条简化';
	@override String get lineSimplifierHint => '自动平滑线条，以获得平滑的轮廓。';
	@override String smoothingIntensity({required Object value}) => '平滑强度 (${value})';
	@override String get smoothingHint => '较低的值保留更多细节，较高的值更平滑。';
	@override String minTolerance({required Object value}) => '最小容差 (${value} px)';
	@override String get minToleranceHint => '设置平滑的下限 - 较高的值会过滤掉微小的锯齿。';
	@override String get aiPersona => 'AI助手角色';
	@override String get choosePersonaStyle => '选择你的 AI 助手风格';
	@override String get personaStyleHint => '角色决定助手如何与你交流。';
	@override String get strictTrainer => '严格的教练';
	@override String get strictTrainerHint => '直接的、严厉的批评，就像俄国的奥林匹克教练。';
	@override String get encouragingMentor => '鼓励的导师';
	@override String get encouragingMentorHint => '积极的强化与激励的反馈。';
	@override String get customPersona => '自定义';
	@override String get customPersonaHint => '设定自己的系统提示';
	@override String get yourSystemPrompt => '你的系统提示';
	@override String get systemPromptPlaceholder => '描述助手应该如何行为…';
	@override String get systemPromptHint => '系统提示定义了助手在所有请求时的个性和行为。';
	@override String get currentStyle => '当前风格';
	@override String get strictTrainerDescription => '助手会给你严厉、直接的反馈。他不接受平庸，并通过建设性的批评激励你达到卓越。';
	@override String get encouragingMentorDescription => '助手会赞扬你的进步，并给你鼓励的反馈。错误被视为学习的机会。';
	@override String get customPersonaDescription => '助手根据你的系统提示来行动。';
}

// Path: pdfDialog
class _TranslationsPdfDialogZh extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogZh._(TranslationsZh root) : this._root = root, super.internal(root);

	final TranslationsZh _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => '选择 PDF';
	@override String get analyzePdf => '分析 PDF';
	@override String get ready => '准备好了';
	@override String get processPdf => '处理 PDF';
	@override String get importComplete => '导入完成';
	@override String get selectPdfFile => '请选择一个 PDF 文件...';
	@override String get analyzingPdf => '正在分析 PDF...';
	@override String pagesFound({required Object count}) => '找到 ${count} 页';
	@override String get textExtractionBackground => '文本提取在后台进行。';
	@override String get couldNotReadPdf => '无法读取 PDF 文件。';
	@override String pagesImported({required Object count}) => '已导入 ${count} 页';
	@override String charactersExtracted({required Object count}) => '~${count}k 个字符已提取';
	@override String get extractedTextContext => '提取的文本将作为 AI 助手的上下文使用。';
	@override String get textExtractionDuration => '每页的文本提取可能需要几秒钟。';
	@override String renderingPage({required Object current, required Object total}) => '正在渲染第 ${current} 页，共 ${total} 页...';
	@override String extractingPage({required Object current, required Object total}) => '正在提取第 ${current} 页的文本，共 ${total} 页...';
	@override String get recognizingTasks => '识别任务中...';
}

/// The flat map containing all translations for locale <zh>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsZh {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => '你的笔记，你的方式',
			'common.save' => '保存',
			'common.cancel' => '取消',
			'common.delete' => '删除',
			'common.edit' => '编辑',
			'common.close' => '关闭',
			'common.confirm' => '确认',
			'common.loading' => '加载中...',
			'common.error' => '错误',
			'common.success' => '成功',
			'common.retry' => '重试',
			'common.search' => '搜索',
			'common.settings' => '设置',
			'common.back' => '返回',
			'common.next' => '下一步',
			'common.done' => '完成',
			'common.yes' => '是',
			'common.no' => '否',
			'common.apply' => '应用',
			'common.loggedOut' => '已注销',
			'common.justNow' => '刚刚',
			'common.minutesAgo' => ({required Object count}) => '前 ${count} 分钟',
			'common.hoursAgo' => ({required Object count}) => '前 ${count} 小时',
			'common.yesterday' => '昨天',
			'auth.login' => '登录',
			'auth.logout' => '注销',
			'auth.register' => '注册',
			'auth.email' => '电子邮箱',
			'auth.password' => '密码',
			'auth.forgotPassword' => '忘记密码？',
			'auth.welcomeBack' => '欢迎回来！',
			'auth.createAccount' => '创建账户',
			'auth.loginWithGoogle' => '使用 Google 登录',
			'auth.loginWithApple' => '使用 Apple 登录',
			'nav.notes' => '笔记',
			'nav.settings' => '设置',
			'notes.title' => '笔记',
			'notes.newNote' => '新笔记',
			'notes.untitled' => '未命名',
			'notes.unnamed' => '未命名笔记',
			'notes.noContent' => '还没有内容',
			'notes.noteDate' => '笔记',
			'notes.lastEdited' => '最后编辑时间',
			'notes.deleteNote' => '删除笔记',
			'notes.deleteNoteConfirm' => ({required Object title}) => '您确定要删除 "${title}" 吗?',
			'notes.deleteNoteTooltip' => '删除笔记',
			'notes.noNotes' => '还没有手写笔记',
			'notes.createFirst' => '创建你的第一篇笔记',
			'notes.createNew' => '创建新笔记',
			'notes.export' => '导出',
			'notes.share' => '分享',
			'notes.duplicate' => '复制',
			'notes.openNote' => '打开笔记',
			'notes.adjustTitlePaper' => '调整标题和纸张',
			'notes.emptyNote' => '空白笔记',
			'notes.emptyNoteSubtitle' => '从空白页面开始',
			'drawing.pen' => '钢笔',
			'drawing.pencil' => '铅笔',
			'drawing.highlighter' => '荧光笔',
			'drawing.eraser' => '橡皮擦',
			'drawing.select' => '选择',
			'drawing.lasso' => '套索',
			'drawing.undo' => '撤销',
			'drawing.redo' => '重做',
			'drawing.clear' => '清除',
			'drawing.clearConfirm' => '要清除所有绘图吗?',
			'drawing.color' => '颜色',
			'drawing.colorWheel' => '色轮',
			'drawing.symbol' => '符号',
			'drawing.strokeWidth' => '笔划宽度',
			'drawing.zoomIn' => '放大',
			'drawing.zoomOut' => '缩小',
			'drawing.markerMode' => '标记模式（透明）',
			'drawing.pressureDetection' => '压力感应',
			'drawing.customizeTool' => ({required Object name}) => '${name} 自定义',
			'drawing.fineliner' => '细笔',
			'drawing.inkRoller' => '墨水滚筒',
			'drawing.fountainPen' => '钢笔',
			'drawing.marker' => '记号笔',
			'drawing.neon' => '霓虹',
			'paper.plain' => '空白',
			'paper.lined' => '带线',
			'paper.grid' => '方格',
			'paper.dotted' => '点状',
			'ai.title' => 'AI 功能',
			'ai.assistant' => 'AI助手',
			'ai.recognize' => '识别文本',
			'ai.recognizing' => '识别中...',
			'ai.summarize' => '总结',
			'ai.extractTasks' => '提取任务',
			'ai.translate' => '翻译',
			'ai.noTextFound' => '未找到文本',
			'ai.helpMe' => '帮帮我',
			'ai.helpMeTitle' => 'AI 回复',
			'ai.analyzingSelection' => '正在分析选区…',
			'ai.noSelection' => '请先用套索选中内容。',
			'ai.helpMeNotConfigured' => 'AI 尚未配置。',
			'ai.persona' => 'AI 助手角色',
			'ai.personaSubtitle' => '选择助手风格',
			'pdf.import' => '导入 PDF',
			'pdf.importSubtitle' => '文本将自动提取',
			'pdf.export' => '导出为 PDF',
			'pdf.exporting' => 'PDF 正在生成...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF 导出失败: ${error}',
			'pdf.page' => '页',
			'pdf.of' => '的',
			'settings.title' => '设置',
			'settings.general' => '常规',
			'settings.theme' => '主题',
			'settings.themeSubtitle' => '亮 · 暗 · 系统',
			'settings.darkMode' => '深色模式',
			'settings.lightMode' => '浅色模式',
			'settings.systemMode' => '系统默认',
			'settings.language' => '语言',
			'settings.languageSubtitle' => '德语 (测试版)',
			'settings.sync' => '同步',
			'settings.syncEnabled' => '同步已启用',
			'settings.syncDisabled' => '同步已禁用',
			'settings.account' => '账户',
			'settings.about' => '关于',
			'settings.version' => '版本',
			'settings.privacy' => '隐私',
			'settings.terms' => '服务条款',
			'settings.input' => '输入',
			'settings.inputDevices' => '输入设备',
			'settings.inputDeviceSubtitle' => '笔 · 触摸 · 鼠标',
			'settings.automation' => '自动化',
			'settings.unlockPen' => '解锁钢笔',
			'settings.pen' => '钢笔',
			'settings.touch' => '触控',
			'settings.mouse' => '鼠标',
			'settings.autoLockOnStylus' => '自动锁定在钢笔上',
			'settings.editorSettings' => '编辑器设置',
			'settings.noteEditor' => '笔记编辑器',
			'settings.noteEditorSubtitle' => '左侧或右侧面板',
			'settings.strokeWidths' => '笔划宽度',
			'settings.strokeWidthsSubtitle' => '细 · 中 · 粗',
			'settings.palmRejection' => '手掌识别',
			'settings.palmRejectionSubtitle' => '防止误输入',
			'settings.assistPanel' => '助手面板',
			'settings.leftRightHanded' => '左手 · 右手',
			'settings.rightLeftHanded' => '右手 · 左手',
			'settings.drawingArea' => '绘图区域',
			'settings.debugMode' => '启用调试模式',
			'settings.cloud' => '云与同步',
			'settings.storageTarget' => '存储目标',
			'settings.storageSubtitle' => 'Inkpadu 云 (免费)',
			'settings.encryption' => '加密',
			'settings.encryptionSubtitle' => '端到端激活',
			'errors.networkError' => '网络错误。请检查你的连接。',
			'errors.unknownError' => '发生未知错误。',
			'errors.authError' => '登录错误。请重试。',
			'errors.saveError' => '保存失败。',
			'errors.loadError' => '加载失败。',
			'errors.exportError' => '导出失败。',
			'errors.loginFailed' => ({required Object provider}) => '登录 (${provider}) 失败',
			'onboarding.welcome' => '欢迎使用 Inkpadu',
			'onboarding.description' => '用自然的手写签名勾画想法，写下笔记，组织你的思维。',
			'onboarding.digitalNotebook' => '你的数字笔记本',
			'onboarding.digitalNotebookDescription' => '优化创造力和专注的手写体验 - 无干扰。',
			'onboarding.connecting' => '连接中...',
			'onboarding.loginWithGitHub' => '使用 GitHub 登录',
			'onboarding.loginWithGoogle' => '使用 Google 登录',
			'editor.newNote' => '新笔记',
			'editor.editNote' => '编辑笔记',
			'editor.title' => '标题',
			'editor.writeNote' => '写下你的笔记...',
			'editor.assistPanel' => '辅助面板',
			'editor.leftRightHanded' => '左手 · 右手',
			'editor.rightLeftHanded' => '右手 · 左手',
			'editor.handednessHint' => '右手用户在左侧面板上更便于操作。左手用户则选择右侧。',
			'editor.drawingArea' => '绘画区域',
			'editor.enableDebugMode' => '启用调试模式',
			'editor.debugModeHint' => '在编辑器及 AI 助手中显示边界框和凸包。',
			'editor.useLineSimplifier' => '使用线条简化',
			'editor.lineSimplifierHint' => '自动平滑线条，以获得平滑的轮廓。',
			'editor.smoothingIntensity' => ({required Object value}) => '平滑强度 (${value})',
			'editor.smoothingHint' => '较低的值保留更多细节，较高的值更平滑。',
			'editor.minTolerance' => ({required Object value}) => '最小容差 (${value} px)',
			'editor.minToleranceHint' => '设置平滑的下限 - 较高的值会过滤掉微小的锯齿。',
			'editor.aiPersona' => 'AI助手角色',
			'editor.choosePersonaStyle' => '选择你的 AI 助手风格',
			'editor.personaStyleHint' => '角色决定助手如何与你交流。',
			'editor.strictTrainer' => '严格的教练',
			'editor.strictTrainerHint' => '直接的、严厉的批评，就像俄国的奥林匹克教练。',
			'editor.encouragingMentor' => '鼓励的导师',
			'editor.encouragingMentorHint' => '积极的强化与激励的反馈。',
			'editor.customPersona' => '自定义',
			'editor.customPersonaHint' => '设定自己的系统提示',
			'editor.yourSystemPrompt' => '你的系统提示',
			'editor.systemPromptPlaceholder' => '描述助手应该如何行为…',
			'editor.systemPromptHint' => '系统提示定义了助手在所有请求时的个性和行为。',
			'editor.currentStyle' => '当前风格',
			'editor.strictTrainerDescription' => '助手会给你严厉、直接的反馈。他不接受平庸，并通过建设性的批评激励你达到卓越。',
			'editor.encouragingMentorDescription' => '助手会赞扬你的进步，并给你鼓励的反馈。错误被视为学习的机会。',
			'editor.customPersonaDescription' => '助手根据你的系统提示来行动。',
			'pdfDialog.selectPdf' => '选择 PDF',
			'pdfDialog.analyzePdf' => '分析 PDF',
			'pdfDialog.ready' => '准备好了',
			'pdfDialog.processPdf' => '处理 PDF',
			'pdfDialog.importComplete' => '导入完成',
			'pdfDialog.selectPdfFile' => '请选择一个 PDF 文件...',
			'pdfDialog.analyzingPdf' => '正在分析 PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '找到 ${count} 页',
			'pdfDialog.textExtractionBackground' => '文本提取在后台进行。',
			'pdfDialog.couldNotReadPdf' => '无法读取 PDF 文件。',
			'pdfDialog.pagesImported' => ({required Object count}) => '已导入 ${count} 页',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k 个字符已提取',
			'pdfDialog.extractedTextContext' => '提取的文本将作为 AI 助手的上下文使用。',
			'pdfDialog.textExtractionDuration' => '每页的文本提取可能需要几秒钟。',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => '正在渲染第 ${current} 页，共 ${total} 页...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => '正在提取第 ${current} 页的文本，共 ${total} 页...',
			'pdfDialog.recognizingTasks' => '识别任务中...',
			_ => null,
		};
	}
}
