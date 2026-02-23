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
class TranslationsAr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsAr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ar,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ar>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsAr _root = this; // ignore: unused_field

	@override 
	TranslationsAr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsAr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppAr app = _TranslationsAppAr._(_root);
	@override late final _TranslationsCommonAr common = _TranslationsCommonAr._(_root);
	@override late final _TranslationsAuthAr auth = _TranslationsAuthAr._(_root);
	@override late final _TranslationsNavAr nav = _TranslationsNavAr._(_root);
	@override late final _TranslationsNotesAr notes = _TranslationsNotesAr._(_root);
	@override late final _TranslationsDrawingAr drawing = _TranslationsDrawingAr._(_root);
	@override late final _TranslationsPaperAr paper = _TranslationsPaperAr._(_root);
	@override late final _TranslationsAiAr ai = _TranslationsAiAr._(_root);
	@override late final _TranslationsPdfAr pdf = _TranslationsPdfAr._(_root);
	@override late final _TranslationsSettingsAr settings = _TranslationsSettingsAr._(_root);
	@override late final _TranslationsErrorsAr errors = _TranslationsErrorsAr._(_root);
	@override late final _TranslationsOnboardingAr onboarding = _TranslationsOnboardingAr._(_root);
	@override late final _TranslationsEditorAr editor = _TranslationsEditorAr._(_root);
	@override late final _TranslationsPdfDialogAr pdfDialog = _TranslationsPdfDialogAr._(_root);
}

// Path: app
class _TranslationsAppAr extends TranslationsAppDe {
	_TranslationsAppAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'ملاحظاتك، بأسلوبك';
}

// Path: common
class _TranslationsCommonAr extends TranslationsCommonDe {
	_TranslationsCommonAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get save => 'حفظ';
	@override String get cancel => 'إلغاء';
	@override String get delete => 'حذف';
	@override String get edit => 'تعديل';
	@override String get close => 'إغلاق';
	@override String get confirm => 'تأكيد';
	@override String get loading => 'جارٍ التحميل...';
	@override String get error => 'خطأ';
	@override String get success => 'نجاح';
	@override String get retry => 'حاول مرة أخرى';
	@override String get search => 'بحث';
	@override String get settings => 'إعدادات';
	@override String get back => 'عودة';
	@override String get next => 'التالي';
	@override String get done => 'تم';
	@override String get yes => 'نعم';
	@override String get no => 'لا';
	@override String get apply => 'تطبيق';
	@override String get loggedOut => 'تم تسجيل الخروج';
	@override String get justNow => 'الآن';
	@override String minutesAgo({required Object count}) => 'قبل ${count} دقيقة(دقائق)';
	@override String hoursAgo({required Object count}) => 'قبل ${count} ساعة(ساعات)';
	@override String get yesterday => 'أمس';
}

// Path: auth
class _TranslationsAuthAr extends TranslationsAuthDe {
	_TranslationsAuthAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get login => 'تسجيل الدخول';
	@override String get logout => 'تسجيل الخروج';
	@override String get register => 'التسجيل';
	@override String get email => 'البريد الإلكتروني';
	@override String get password => 'كلمة المرور';
	@override String get forgotPassword => 'نسيت كلمة المرور؟';
	@override String get welcomeBack => 'مرحبًا بعودتك!';
	@override String get createAccount => 'إنشاء حساب';
	@override String get loginWithGoogle => 'تسجيل الدخول باستخدام جوجل';
	@override String get loginWithApple => 'تسجيل الدخول باستخدام أبل';
}

// Path: nav
class _TranslationsNavAr extends TranslationsNavDe {
	_TranslationsNavAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get notes => 'الملاحظات';
	@override String get settings => 'الإعدادات';
}

// Path: notes
class _TranslationsNotesAr extends TranslationsNotesDe {
	_TranslationsNotesAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'ملاحظات';
	@override String get newNote => 'ملاحظة جديدة';
	@override String get untitled => 'بدون عنوان';
	@override String get unnamed => 'ملاحظة بدون عنوان';
	@override String get noContent => 'لا توجد محتويات بعد';
	@override String get noteDate => 'تاريخ الملاحظة';
	@override String get lastEdited => 'آخر تعديل';
	@override String get deleteNote => 'حذف الملاحظة';
	@override String deleteNoteConfirm({required Object title}) => 'هل ترغب في حذف "${title}" بالفعل؟';
	@override String get deleteNoteTooltip => 'حذف الملاحظة';
	@override String get noNotes => 'لا توجد ملاحظات مكتوبة باليد بعد';
	@override String get createFirst => 'قم بإنشاء ملاحظتك الأولى';
	@override String get createNew => 'إنشاء ملاحظة جديدة';
	@override String get export => 'تصدير';
	@override String get share => 'مشاركة';
	@override String get duplicate => 'تكرار';
	@override String get openNote => 'فتح الملاحظة';
	@override String get adjustTitlePaper => 'تعديل العنوان والورقة';
	@override String get emptyNote => 'ملاحظة فارغة';
	@override String get emptyNoteSubtitle => 'ابدأ بصفحة فارغة';
}

// Path: drawing
class _TranslationsDrawingAr extends TranslationsDrawingDe {
	_TranslationsDrawingAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get pen => 'قلم';
	@override String get pencil => 'قلم رصاص';
	@override String get highlighter => 'محدد';
	@override String get eraser => 'ممحاة';
	@override String get select => 'تحديد';
	@override String get lasso => 'لاسو';
	@override String get undo => 'تراجع';
	@override String get redo => 'إعادة';
	@override String get clear => 'مسح';
	@override String get clearConfirm => 'هل تريد حذف جميع الرسومات؟';
	@override String get color => 'لون';
	@override String get colorWheel => 'عجلة الألوان';
	@override String get symbol => 'رمز';
	@override String get strokeWidth => 'عرض القلم';
	@override String get zoomIn => 'تكبير';
	@override String get zoomOut => 'تصغير';
	@override String get markerMode => 'وضع العلامة (شفاف)';
	@override String get pressureDetection => 'كشف الضغط';
	@override String customizeTool({required Object name}) => 'تخصيص ${name}';
	@override String get fineliner => 'قلم رفيع';
	@override String get inkRoller => 'قلم جاف';
	@override String get fountainPen => 'قلم حبر';
	@override String get marker => 'ماركر';
	@override String get neon => 'نيو';
}

// Path: paper
class _TranslationsPaperAr extends TranslationsPaperDe {
	_TranslationsPaperAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get plain => 'بدون خطوط';
	@override String get lined => 'مخطط';
	@override String get grid => 'مربعات';
	@override String get dotted => 'منقط';
}

// Path: ai
class _TranslationsAiAr extends TranslationsAiDe {
	_TranslationsAiAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'ميزات الذكاء الاصطناعي';
	@override String get assistant => 'المساعد الذكي';
	@override String get recognize => 'تعرف على النص';
	@override String get recognizing => 'جارٍ التعرف...';
	@override String get summarize => 'تلخيص';
	@override String get extractTasks => 'استخراج المهام';
	@override String get translate => 'ترجمة';
	@override String get noTextFound => 'لم يتم العثور على نص';
	@override String get helpMe => 'ساعدني';
	@override String get helpMeTitle => 'ردّ الذكاء الاصطناعي';
	@override String get analyzingSelection => 'جارٍ تحليل التحديد…';
	@override String get noSelection => 'يرجى تحديد شيء باستخدام أداة اللاسو أولاً.';
	@override String get helpMeNotConfigured => 'لم يتم إعداد الذكاء الاصطناعي بعد.';
	@override String get persona => 'شخصية مساعد الذكاء الاصطناعي';
	@override String get personaSubtitle => 'اختر أسلوب المساعد';
}

// Path: pdf
class _TranslationsPdfAr extends TranslationsPdfDe {
	_TranslationsPdfAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get import => 'استيراد PDF';
	@override String get importSubtitle => 'سيتم استخراج النص تلقائيًا';
	@override String get export => 'تصدير كـ PDF';
	@override String get exporting => 'جارٍ إنشاء PDF...';
	@override String exportFailed({required Object error}) => 'فشل تصدير PDF: ${error}';
	@override String get page => 'صفحة';
	@override String get of => 'من';
}

// Path: settings
class _TranslationsSettingsAr extends TranslationsSettingsDe {
	_TranslationsSettingsAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get title => 'إعدادات';
	@override String get general => 'عام';
	@override String get theme => 'ثيم';
	@override String get themeSubtitle => 'فاتح · داكن · نظام';
	@override String get darkMode => 'الوضع الداكن';
	@override String get lightMode => 'الوضع الفاتح';
	@override String get systemMode => 'الوضع الافتراضي للنظام';
	@override String get language => 'اللغة';
	@override String get languageSubtitle => 'الألمانية (بيتا)';
	@override String get sync => 'المزامنة';
	@override String get syncEnabled => 'تم تفعيل المزامنة';
	@override String get syncDisabled => 'تم تعطيل المزامنة';
	@override String get account => 'حساب';
	@override String get about => 'حول';
	@override String get version => 'الإصدار';
	@override String get privacy => 'الخصوصية';
	@override String get terms => 'الشروط والأحكام';
	@override String get input => 'الإدخال';
	@override String get inputDevices => 'أجهزة الإدخال';
	@override String get inputDeviceSubtitle => 'قلم · لمسة · ماوس';
	@override String get automation => 'التشغيل الآلي';
	@override String get unlockPen => 'إلغاء قفل القلم';
	@override String get pen => 'قلم';
	@override String get touch => 'لمس';
	@override String get mouse => 'فأرة';
	@override String get autoLockOnStylus => 'قفل تلقائي عند استخدام القلم';
	@override String get editorSettings => 'إعدادات المحرر';
	@override String get noteEditor => 'محرر الملاحظات';
	@override String get noteEditorSubtitle => 'لوحة جانبية يسار · يمين';
	@override String get strokeWidths => 'سماكات القلم';
	@override String get strokeWidthsSubtitle => 'رفيع · متوسط · عريض';
	@override String get palmRejection => 'كشف راحة اليد';
	@override String get palmRejectionSubtitle => 'يمنع المدخلات غير المرغوب فيها';
	@override String get assistPanel => 'لوحة المساعدة';
	@override String get leftRightHanded => 'يسار · يمين';
	@override String get rightLeftHanded => 'يمين · يسار';
	@override String get drawingArea => 'منطقة الرسم';
	@override String get debugMode => 'تفعيل وضع التصحيح';
	@override String get cloud => 'السحابة والمزامنة';
	@override String get storageTarget => 'وجهة التخزين';
	@override String get storageSubtitle => 'سحابة Inkpadu (مجاني)';
	@override String get encryption => 'تشفير';
	@override String get encryptionSubtitle => 'تشفير من طرف إلى طرف نشط';
}

// Path: errors
class _TranslationsErrorsAr extends TranslationsErrorsDe {
	_TranslationsErrorsAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'خطأ في الشبكة. تحقق من اتصالك.';
	@override String get unknownError => 'حدث خطأ غير معروف.';
	@override String get authError => 'خطأ في تسجيل الدخول. يرجى المحاولة مرة أخرى.';
	@override String get saveError => 'فشل في حفظ.';
	@override String get loadError => 'فشل في التحميل.';
	@override String get exportError => 'فشل في التصدير.';
	@override String loginFailed({required Object provider}) => 'فشل تسجيل الدخول (${provider})';
}

// Path: onboarding
class _TranslationsOnboardingAr extends TranslationsOnboardingDe {
	_TranslationsOnboardingAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'مرحبًا بك في Inkpadu';
	@override String get description => 'ارسم الأفكار، اكتب الملاحظات، وتنظم أفكارك بخط اليد الطبيعي.';
	@override String get digitalNotebook => 'دفتر ملاحظاتك الرقمي';
	@override String get digitalNotebookDescription => 'تجربة كتابة باليد، محسّنة للإبداع والتركيز – بدون أي تشتت.';
	@override String get connecting => 'جاري الاتصال...';
	@override String get loginWithGitHub => 'تسجيل الدخول باستخدام GitHub';
	@override String get loginWithGoogle => 'تسجيل الدخول باستخدام Google';
}

// Path: editor
class _TranslationsEditorAr extends TranslationsEditorDe {
	_TranslationsEditorAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'ملاحظة جديدة';
	@override String get editNote => 'تعديل الملاحظة';
	@override String get title => 'العنوان';
	@override String get writeNote => 'اكتب ملاحظتك...';
	@override String get assistPanel => 'لوحة المساعدة';
	@override String get leftRightHanded => 'يد يسار · يمين';
	@override String get rightLeftHanded => 'يد يمين · يسار';
	@override String get handednessHint => 'الكتّاب بيدهم اليمنى يصلون للأدوات بشكل مريح إذا كانت اللوحة على اليسار. بينما يفضلون ذوي اليد اليسرى الجانب الأيمن.';
	@override String get drawingArea => 'منطقة الرسم';
	@override String get enableDebugMode => 'تفعيل وضع التصحيح';
	@override String get debugModeHint => 'يعرض مربعات الحدود وأشكال محدبة في المحرر والمساعد الذكي.';
	@override String get useLineSimplifier => 'استخدام مُبسط الخطوط';
	@override String get lineSimplifierHint => 'يُجمل خطوطك تلقائيًا للحصول على خطوط سلسة.';
	@override String smoothingIntensity({required Object value}) => 'شدة التنعيم (${value})';
	@override String get smoothingHint => 'القيم المنخفضة تحتفظ بمزيد من التفاصيل، بينما القيم العالية تونّع أكثر.';
	@override String minTolerance({required Object value}) => 'حد أدنى للتسامح (${value} بكسل)';
	@override String get minToleranceHint => 'يحدد الحد الأدنى للتنعيم - القيم الأعلى ت-filter الفطريات الصغيرة.';
	@override String get aiPersona => 'شخصية المساعد الذكي';
	@override String get choosePersonaStyle => 'اختر أسلوب مساعدك الذكي';
	@override String get personaStyleHint => 'تحدد الشخصية كيفية تواصل المساعد معك.';
	@override String get strictTrainer => 'مدرب صارم';
	@override String get strictTrainerHint => 'نقد مباشر وصارم مثل مدرب أولمبي روسي';
	@override String get encouragingMentor => 'مرشد مشجع';
	@override String get encouragingMentorHint => 'تعزيز إيجابي وتغذية راجعة تحفيزية';
	@override String get customPersona => 'مخصص';
	@override String get customPersonaHint => 'تحديد موجه النظام الخاص بك';
	@override String get yourSystemPrompt => 'موجه النظام الخاص بك';
	@override String get systemPromptPlaceholder => 'صف كيف يجب أن يتصرف المساعد...';
	@override String get systemPromptHint => 'يحدد موجه النظام الشخصية وسلوك المساعد في جميع الاستفسارات.';
	@override String get currentStyle => 'الأسلوب الحالي';
	@override String get strictTrainerDescription => 'يقدم المساعد لك تعليقات صارمة ومباشرة. لا يقبل بالمتوسط، ويحفزك على تحقيق أقصى إمكانياتك من خلال النقد البناء.';
	@override String get encouragingMentorDescription => 'يمتدح المساعد تقدمك ويقدم لك تغذية راجعة مشجعة. تُعرض الأخطاء كفرص للتعلم.';
	@override String get customPersonaDescription => 'يتصرف المساعد وفقًا لموجه النظام الخاص بك.';
}

// Path: pdfDialog
class _TranslationsPdfDialogAr extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogAr._(TranslationsAr root) : this._root = root, super.internal(root);

	final TranslationsAr _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'اختر PDF';
	@override String get analyzePdf => 'تحليل PDF';
	@override String get ready => 'جاهز';
	@override String get processPdf => 'معالجة PDF';
	@override String get importComplete => 'اكتمل الاستيراد';
	@override String get selectPdfFile => 'يرجى اختيار ملف PDF...';
	@override String get analyzingPdf => 'يتم تحليل PDF...';
	@override String pagesFound({required Object count}) => '${count} صفحة(صفحات) تم العثور عليها';
	@override String get textExtractionBackground => 'يتم استخراج النص في الخلفية.';
	@override String get couldNotReadPdf => 'لم يكن من الممكن قراءة ملف PDF.';
	@override String pagesImported({required Object count}) => '${count} صفحة(صفحات) تم استيرادها';
	@override String charactersExtracted({required Object count}) => '~${count}k حرف تم استخراجها';
	@override String get extractedTextContext => 'يتم استخدام النص المستخرج كمرجع للمساعد الذكي.';
	@override String get textExtractionDuration => 'قد تستغرق عملية استخراج النص عدة ثوانٍ لكل صفحة.';
	@override String renderingPage({required Object current, required Object total}) => 'يتم تجسيد الصفحة ${current} من ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'يتم استخراج النص من الصفحة ${current} من ${total}...';
	@override String get recognizingTasks => 'يتم التعرف على المهام...';
}

/// The flat map containing all translations for locale <ar>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsAr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'ملاحظاتك، بأسلوبك',
			'common.save' => 'حفظ',
			'common.cancel' => 'إلغاء',
			'common.delete' => 'حذف',
			'common.edit' => 'تعديل',
			'common.close' => 'إغلاق',
			'common.confirm' => 'تأكيد',
			'common.loading' => 'جارٍ التحميل...',
			'common.error' => 'خطأ',
			'common.success' => 'نجاح',
			'common.retry' => 'حاول مرة أخرى',
			'common.search' => 'بحث',
			'common.settings' => 'إعدادات',
			'common.back' => 'عودة',
			'common.next' => 'التالي',
			'common.done' => 'تم',
			'common.yes' => 'نعم',
			'common.no' => 'لا',
			'common.apply' => 'تطبيق',
			'common.loggedOut' => 'تم تسجيل الخروج',
			'common.justNow' => 'الآن',
			'common.minutesAgo' => ({required Object count}) => 'قبل ${count} دقيقة(دقائق)',
			'common.hoursAgo' => ({required Object count}) => 'قبل ${count} ساعة(ساعات)',
			'common.yesterday' => 'أمس',
			'auth.login' => 'تسجيل الدخول',
			'auth.logout' => 'تسجيل الخروج',
			'auth.register' => 'التسجيل',
			'auth.email' => 'البريد الإلكتروني',
			'auth.password' => 'كلمة المرور',
			'auth.forgotPassword' => 'نسيت كلمة المرور؟',
			'auth.welcomeBack' => 'مرحبًا بعودتك!',
			'auth.createAccount' => 'إنشاء حساب',
			'auth.loginWithGoogle' => 'تسجيل الدخول باستخدام جوجل',
			'auth.loginWithApple' => 'تسجيل الدخول باستخدام أبل',
			'nav.notes' => 'الملاحظات',
			'nav.settings' => 'الإعدادات',
			'notes.title' => 'ملاحظات',
			'notes.newNote' => 'ملاحظة جديدة',
			'notes.untitled' => 'بدون عنوان',
			'notes.unnamed' => 'ملاحظة بدون عنوان',
			'notes.noContent' => 'لا توجد محتويات بعد',
			'notes.noteDate' => 'تاريخ الملاحظة',
			'notes.lastEdited' => 'آخر تعديل',
			'notes.deleteNote' => 'حذف الملاحظة',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'هل ترغب في حذف "${title}" بالفعل؟',
			'notes.deleteNoteTooltip' => 'حذف الملاحظة',
			'notes.noNotes' => 'لا توجد ملاحظات مكتوبة باليد بعد',
			'notes.createFirst' => 'قم بإنشاء ملاحظتك الأولى',
			'notes.createNew' => 'إنشاء ملاحظة جديدة',
			'notes.export' => 'تصدير',
			'notes.share' => 'مشاركة',
			'notes.duplicate' => 'تكرار',
			'notes.openNote' => 'فتح الملاحظة',
			'notes.adjustTitlePaper' => 'تعديل العنوان والورقة',
			'notes.emptyNote' => 'ملاحظة فارغة',
			'notes.emptyNoteSubtitle' => 'ابدأ بصفحة فارغة',
			'drawing.pen' => 'قلم',
			'drawing.pencil' => 'قلم رصاص',
			'drawing.highlighter' => 'محدد',
			'drawing.eraser' => 'ممحاة',
			'drawing.select' => 'تحديد',
			'drawing.lasso' => 'لاسو',
			'drawing.undo' => 'تراجع',
			'drawing.redo' => 'إعادة',
			'drawing.clear' => 'مسح',
			'drawing.clearConfirm' => 'هل تريد حذف جميع الرسومات؟',
			'drawing.color' => 'لون',
			'drawing.colorWheel' => 'عجلة الألوان',
			'drawing.symbol' => 'رمز',
			'drawing.strokeWidth' => 'عرض القلم',
			'drawing.zoomIn' => 'تكبير',
			'drawing.zoomOut' => 'تصغير',
			'drawing.markerMode' => 'وضع العلامة (شفاف)',
			'drawing.pressureDetection' => 'كشف الضغط',
			'drawing.customizeTool' => ({required Object name}) => 'تخصيص ${name}',
			'drawing.fineliner' => 'قلم رفيع',
			'drawing.inkRoller' => 'قلم جاف',
			'drawing.fountainPen' => 'قلم حبر',
			'drawing.marker' => 'ماركر',
			'drawing.neon' => 'نيو',
			'paper.plain' => 'بدون خطوط',
			'paper.lined' => 'مخطط',
			'paper.grid' => 'مربعات',
			'paper.dotted' => 'منقط',
			'ai.title' => 'ميزات الذكاء الاصطناعي',
			'ai.assistant' => 'المساعد الذكي',
			'ai.recognize' => 'تعرف على النص',
			'ai.recognizing' => 'جارٍ التعرف...',
			'ai.summarize' => 'تلخيص',
			'ai.extractTasks' => 'استخراج المهام',
			'ai.translate' => 'ترجمة',
			'ai.noTextFound' => 'لم يتم العثور على نص',
			'ai.helpMe' => 'ساعدني',
			'ai.helpMeTitle' => 'ردّ الذكاء الاصطناعي',
			'ai.analyzingSelection' => 'جارٍ تحليل التحديد…',
			'ai.noSelection' => 'يرجى تحديد شيء باستخدام أداة اللاسو أولاً.',
			'ai.helpMeNotConfigured' => 'لم يتم إعداد الذكاء الاصطناعي بعد.',
			'ai.persona' => 'شخصية مساعد الذكاء الاصطناعي',
			'ai.personaSubtitle' => 'اختر أسلوب المساعد',
			'pdf.import' => 'استيراد PDF',
			'pdf.importSubtitle' => 'سيتم استخراج النص تلقائيًا',
			'pdf.export' => 'تصدير كـ PDF',
			'pdf.exporting' => 'جارٍ إنشاء PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'فشل تصدير PDF: ${error}',
			'pdf.page' => 'صفحة',
			'pdf.of' => 'من',
			'settings.title' => 'إعدادات',
			'settings.general' => 'عام',
			'settings.theme' => 'ثيم',
			'settings.themeSubtitle' => 'فاتح · داكن · نظام',
			'settings.darkMode' => 'الوضع الداكن',
			'settings.lightMode' => 'الوضع الفاتح',
			'settings.systemMode' => 'الوضع الافتراضي للنظام',
			'settings.language' => 'اللغة',
			'settings.languageSubtitle' => 'الألمانية (بيتا)',
			'settings.sync' => 'المزامنة',
			'settings.syncEnabled' => 'تم تفعيل المزامنة',
			'settings.syncDisabled' => 'تم تعطيل المزامنة',
			'settings.account' => 'حساب',
			'settings.about' => 'حول',
			'settings.version' => 'الإصدار',
			'settings.privacy' => 'الخصوصية',
			'settings.terms' => 'الشروط والأحكام',
			'settings.input' => 'الإدخال',
			'settings.inputDevices' => 'أجهزة الإدخال',
			'settings.inputDeviceSubtitle' => 'قلم · لمسة · ماوس',
			'settings.automation' => 'التشغيل الآلي',
			'settings.unlockPen' => 'إلغاء قفل القلم',
			'settings.pen' => 'قلم',
			'settings.touch' => 'لمس',
			'settings.mouse' => 'فأرة',
			'settings.autoLockOnStylus' => 'قفل تلقائي عند استخدام القلم',
			'settings.editorSettings' => 'إعدادات المحرر',
			'settings.noteEditor' => 'محرر الملاحظات',
			'settings.noteEditorSubtitle' => 'لوحة جانبية يسار · يمين',
			'settings.strokeWidths' => 'سماكات القلم',
			'settings.strokeWidthsSubtitle' => 'رفيع · متوسط · عريض',
			'settings.palmRejection' => 'كشف راحة اليد',
			'settings.palmRejectionSubtitle' => 'يمنع المدخلات غير المرغوب فيها',
			'settings.assistPanel' => 'لوحة المساعدة',
			'settings.leftRightHanded' => 'يسار · يمين',
			'settings.rightLeftHanded' => 'يمين · يسار',
			'settings.drawingArea' => 'منطقة الرسم',
			'settings.debugMode' => 'تفعيل وضع التصحيح',
			'settings.cloud' => 'السحابة والمزامنة',
			'settings.storageTarget' => 'وجهة التخزين',
			'settings.storageSubtitle' => 'سحابة Inkpadu (مجاني)',
			'settings.encryption' => 'تشفير',
			'settings.encryptionSubtitle' => 'تشفير من طرف إلى طرف نشط',
			'errors.networkError' => 'خطأ في الشبكة. تحقق من اتصالك.',
			'errors.unknownError' => 'حدث خطأ غير معروف.',
			'errors.authError' => 'خطأ في تسجيل الدخول. يرجى المحاولة مرة أخرى.',
			'errors.saveError' => 'فشل في حفظ.',
			'errors.loadError' => 'فشل في التحميل.',
			'errors.exportError' => 'فشل في التصدير.',
			'errors.loginFailed' => ({required Object provider}) => 'فشل تسجيل الدخول (${provider})',
			'onboarding.welcome' => 'مرحبًا بك في Inkpadu',
			'onboarding.description' => 'ارسم الأفكار، اكتب الملاحظات، وتنظم أفكارك بخط اليد الطبيعي.',
			'onboarding.digitalNotebook' => 'دفتر ملاحظاتك الرقمي',
			'onboarding.digitalNotebookDescription' => 'تجربة كتابة باليد، محسّنة للإبداع والتركيز – بدون أي تشتت.',
			'onboarding.connecting' => 'جاري الاتصال...',
			'onboarding.loginWithGitHub' => 'تسجيل الدخول باستخدام GitHub',
			'onboarding.loginWithGoogle' => 'تسجيل الدخول باستخدام Google',
			'editor.newNote' => 'ملاحظة جديدة',
			'editor.editNote' => 'تعديل الملاحظة',
			'editor.title' => 'العنوان',
			'editor.writeNote' => 'اكتب ملاحظتك...',
			'editor.assistPanel' => 'لوحة المساعدة',
			'editor.leftRightHanded' => 'يد يسار · يمين',
			'editor.rightLeftHanded' => 'يد يمين · يسار',
			'editor.handednessHint' => 'الكتّاب بيدهم اليمنى يصلون للأدوات بشكل مريح إذا كانت اللوحة على اليسار. بينما يفضلون ذوي اليد اليسرى الجانب الأيمن.',
			'editor.drawingArea' => 'منطقة الرسم',
			'editor.enableDebugMode' => 'تفعيل وضع التصحيح',
			'editor.debugModeHint' => 'يعرض مربعات الحدود وأشكال محدبة في المحرر والمساعد الذكي.',
			'editor.useLineSimplifier' => 'استخدام مُبسط الخطوط',
			'editor.lineSimplifierHint' => 'يُجمل خطوطك تلقائيًا للحصول على خطوط سلسة.',
			'editor.smoothingIntensity' => ({required Object value}) => 'شدة التنعيم (${value})',
			'editor.smoothingHint' => 'القيم المنخفضة تحتفظ بمزيد من التفاصيل، بينما القيم العالية تونّع أكثر.',
			'editor.minTolerance' => ({required Object value}) => 'حد أدنى للتسامح (${value} بكسل)',
			'editor.minToleranceHint' => 'يحدد الحد الأدنى للتنعيم - القيم الأعلى ت-filter الفطريات الصغيرة.',
			'editor.aiPersona' => 'شخصية المساعد الذكي',
			'editor.choosePersonaStyle' => 'اختر أسلوب مساعدك الذكي',
			'editor.personaStyleHint' => 'تحدد الشخصية كيفية تواصل المساعد معك.',
			'editor.strictTrainer' => 'مدرب صارم',
			'editor.strictTrainerHint' => 'نقد مباشر وصارم مثل مدرب أولمبي روسي',
			'editor.encouragingMentor' => 'مرشد مشجع',
			'editor.encouragingMentorHint' => 'تعزيز إيجابي وتغذية راجعة تحفيزية',
			'editor.customPersona' => 'مخصص',
			'editor.customPersonaHint' => 'تحديد موجه النظام الخاص بك',
			'editor.yourSystemPrompt' => 'موجه النظام الخاص بك',
			'editor.systemPromptPlaceholder' => 'صف كيف يجب أن يتصرف المساعد...',
			'editor.systemPromptHint' => 'يحدد موجه النظام الشخصية وسلوك المساعد في جميع الاستفسارات.',
			'editor.currentStyle' => 'الأسلوب الحالي',
			'editor.strictTrainerDescription' => 'يقدم المساعد لك تعليقات صارمة ومباشرة. لا يقبل بالمتوسط، ويحفزك على تحقيق أقصى إمكانياتك من خلال النقد البناء.',
			'editor.encouragingMentorDescription' => 'يمتدح المساعد تقدمك ويقدم لك تغذية راجعة مشجعة. تُعرض الأخطاء كفرص للتعلم.',
			'editor.customPersonaDescription' => 'يتصرف المساعد وفقًا لموجه النظام الخاص بك.',
			'pdfDialog.selectPdf' => 'اختر PDF',
			'pdfDialog.analyzePdf' => 'تحليل PDF',
			'pdfDialog.ready' => 'جاهز',
			'pdfDialog.processPdf' => 'معالجة PDF',
			'pdfDialog.importComplete' => 'اكتمل الاستيراد',
			'pdfDialog.selectPdfFile' => 'يرجى اختيار ملف PDF...',
			'pdfDialog.analyzingPdf' => 'يتم تحليل PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} صفحة(صفحات) تم العثور عليها',
			'pdfDialog.textExtractionBackground' => 'يتم استخراج النص في الخلفية.',
			'pdfDialog.couldNotReadPdf' => 'لم يكن من الممكن قراءة ملف PDF.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} صفحة(صفحات) تم استيرادها',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k حرف تم استخراجها',
			'pdfDialog.extractedTextContext' => 'يتم استخدام النص المستخرج كمرجع للمساعد الذكي.',
			'pdfDialog.textExtractionDuration' => 'قد تستغرق عملية استخراج النص عدة ثوانٍ لكل صفحة.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'يتم تجسيد الصفحة ${current} من ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'يتم استخراج النص من الصفحة ${current} من ${total}...',
			'pdfDialog.recognizingTasks' => 'يتم التعرف على المهام...',
			_ => null,
		};
	}
}
