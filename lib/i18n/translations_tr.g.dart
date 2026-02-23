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
class TranslationsTr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsTr _root = this; // ignore: unused_field

	@override 
	TranslationsTr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTr(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppTr app = _TranslationsAppTr._(_root);
	@override late final _TranslationsCommonTr common = _TranslationsCommonTr._(_root);
	@override late final _TranslationsAuthTr auth = _TranslationsAuthTr._(_root);
	@override late final _TranslationsNavTr nav = _TranslationsNavTr._(_root);
	@override late final _TranslationsNotesTr notes = _TranslationsNotesTr._(_root);
	@override late final _TranslationsDrawingTr drawing = _TranslationsDrawingTr._(_root);
	@override late final _TranslationsPaperTr paper = _TranslationsPaperTr._(_root);
	@override late final _TranslationsAiTr ai = _TranslationsAiTr._(_root);
	@override late final _TranslationsPdfTr pdf = _TranslationsPdfTr._(_root);
	@override late final _TranslationsSettingsTr settings = _TranslationsSettingsTr._(_root);
	@override late final _TranslationsErrorsTr errors = _TranslationsErrorsTr._(_root);
	@override late final _TranslationsOnboardingTr onboarding = _TranslationsOnboardingTr._(_root);
	@override late final _TranslationsEditorTr editor = _TranslationsEditorTr._(_root);
	@override late final _TranslationsPdfDialogTr pdfDialog = _TranslationsPdfDialogTr._(_root);
}

// Path: app
class _TranslationsAppTr extends TranslationsAppDe {
	_TranslationsAppTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Notların, senin tarzın';
}

// Path: common
class _TranslationsCommonTr extends TranslationsCommonDe {
	_TranslationsCommonTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get save => 'Kaydet';
	@override String get cancel => 'İptal';
	@override String get delete => 'Sil';
	@override String get edit => 'Düzenle';
	@override String get close => 'Kapat';
	@override String get confirm => 'Onayla';
	@override String get loading => 'Yükleniyor...';
	@override String get error => 'Hata';
	@override String get success => 'Başarılı';
	@override String get retry => 'Yeniden dene';
	@override String get search => 'Ara';
	@override String get settings => 'Ayarlar';
	@override String get back => 'Geri';
	@override String get next => 'İleri';
	@override String get done => 'Tamam';
	@override String get yes => 'Evet';
	@override String get no => 'Hayır';
	@override String get apply => 'Uygula';
	@override String get loggedOut => 'Çıkış yapıldı';
	@override String get justNow => 'Şu anda';
	@override String minutesAgo({required Object count}) => '${count} dakika önce';
	@override String hoursAgo({required Object count}) => '${count} saat önce';
	@override String get yesterday => 'Dün';
}

// Path: auth
class _TranslationsAuthTr extends TranslationsAuthDe {
	_TranslationsAuthTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get login => 'Giriş yap';
	@override String get logout => 'Çıkış yap';
	@override String get register => 'Kaydol';
	@override String get email => 'E-posta';
	@override String get password => 'Şifre';
	@override String get forgotPassword => 'Şifreni mi unuttun?';
	@override String get welcomeBack => 'Hoş geldin tekrar!';
	@override String get createAccount => 'Hesap oluştur';
	@override String get loginWithGoogle => 'Google ile giriş yap';
	@override String get loginWithApple => 'Apple ile giriş yap';
}

// Path: nav
class _TranslationsNavTr extends TranslationsNavDe {
	_TranslationsNavTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notlar';
	@override String get settings => 'Ayarlar';
}

// Path: notes
class _TranslationsNotesTr extends TranslationsNotesDe {
	_TranslationsNotesTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notlar';
	@override String get newNote => 'Yeni Not';
	@override String get untitled => 'Başlıksız';
	@override String get unnamed => 'İsimsiz Not';
	@override String get noContent => 'Henüz içerik yok';
	@override String get noteDate => 'Not';
	@override String get lastEdited => 'Son düzenleme';
	@override String get deleteNote => 'Notu sil';
	@override String deleteNoteConfirm({required Object title}) => '"${title}"\'yı gerçekten silmek istiyor musun?';
	@override String get deleteNoteTooltip => 'Notu sil';
	@override String get noNotes => 'Henüz el yazısı not yok';
	@override String get createFirst => 'İlk notunu oluştur';
	@override String get createNew => 'Yeni Not Oluştur';
	@override String get export => 'Dışa aktar';
	@override String get share => 'Paylaş';
	@override String get duplicate => 'Çoğalt';
	@override String get openNote => 'Notu aç';
	@override String get adjustTitlePaper => 'Başlık & Kağıt ayarla';
	@override String get emptyNote => 'Boş not';
	@override String get emptyNoteSubtitle => 'Boş bir sayfa ile başla';
}

// Path: drawing
class _TranslationsDrawingTr extends TranslationsDrawingDe {
	_TranslationsDrawingTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Kalem';
	@override String get pencil => 'Kurşun kalem';
	@override String get highlighter => 'Marker';
	@override String get eraser => 'Silgi';
	@override String get select => 'Seç';
	@override String get undo => 'Geri al';
	@override String get redo => 'Yinele';
	@override String get clear => 'Temizle';
	@override String get clearConfirm => 'Tüm çizimleri silmek istiyor musun?';
	@override String get color => 'Renk';
	@override String get colorWheel => 'Renk paleti';
	@override String get symbol => 'Sembol';
	@override String get strokeWidth => 'Çizgi kalınlığı';
	@override String get zoomIn => 'Zoom yap';
	@override String get zoomOut => 'Zoomu azalt';
	@override String get markerMode => 'Marker modu (şeffaf)';
	@override String get pressureDetection => 'Baskı algılama';
	@override String customizeTool({required Object name}) => '${name} ayarla';
	@override String get fineliner => 'İnce Kalem';
	@override String get inkRoller => 'Mürekkep Kalemi';
	@override String get fountainPen => 'Dolma Kalem';
	@override String get marker => 'İşaretleyici';
	@override String get neon => 'Neon';
}

// Path: paper
class _TranslationsPaperTr extends TranslationsPaperDe {
	_TranslationsPaperTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Düz';
	@override String get lined => 'Çizgili';
	@override String get grid => 'Kareli';
	@override String get dotted => 'Noktalı';
}

// Path: ai
class _TranslationsAiTr extends TranslationsAiDe {
	_TranslationsAiTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Yapay Zeka Özellikleri';
	@override String get assistant => 'Yapay Zeka Asistanı';
	@override String get recognize => 'Metni tanı';
	@override String get recognizing => 'Tanımlanıyor...';
	@override String get summarize => 'Özetle';
	@override String get extractTasks => 'Görevleri çıkar';
	@override String get translate => 'Çevir';
	@override String get noTextFound => 'Metin bulunamadı';
	@override String get persona => 'Yapay Zeka Asistanı Persona';
	@override String get personaSubtitle => 'Asistan stilini seç';
}

// Path: pdf
class _TranslationsPdfTr extends TranslationsPdfDe {
	_TranslationsPdfTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get import => 'PDF içe aktar';
	@override String get importSubtitle => 'Metin otomatik olarak çıkarılacak';
	@override String get export => 'PDF olarak dışa aktar';
	@override String get exporting => 'PDF oluşturuluyor...';
	@override String exportFailed({required Object error}) => 'PDF dışa aktarımı başarısız oldu: ${error}';
	@override String get page => 'Sayfa';
	@override String get of => ' / ';
}

// Path: settings
class _TranslationsSettingsTr extends TranslationsSettingsDe {
	_TranslationsSettingsTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ayarlar';
	@override String get general => 'Genel';
	@override String get theme => 'Tema';
	@override String get themeSubtitle => 'Açık · Karanlık · Sistem';
	@override String get darkMode => 'Karanlık Mod';
	@override String get lightMode => 'Aydınlık Mod';
	@override String get systemMode => 'Sistem Modu';
	@override String get language => 'Dil';
	@override String get languageSubtitle => 'Türkçe';
	@override String get sync => 'Senkronizasyon';
	@override String get syncEnabled => 'Senkronizasyon etkin';
	@override String get syncDisabled => 'Senkronizasyon devre dışı';
	@override String get account => 'Hesap';
	@override String get about => 'Hakkında';
	@override String get version => 'Versiyon';
	@override String get privacy => 'Gizlilik';
	@override String get terms => 'Kullanım Şartları';
	@override String get input => 'Girdi';
	@override String get inputDevices => 'Giriş Aygıtları';
	@override String get inputDeviceSubtitle => 'Kalem · Dokunmatik · Fare';
	@override String get automation => 'Otomasyon';
	@override String get unlockPen => 'Kalem kilidini aç';
	@override String get pen => 'Kalem';
	@override String get touch => 'Dokunmatik';
	@override String get mouse => 'Fare';
	@override String get autoLockOnStylus => 'Kalem ile otomatik kilitleme';
	@override String get editorSettings => 'Editör Ayarları';
	@override String get noteEditor => 'Not Editörü';
	@override String get noteEditorSubtitle => 'Sol · Sağ panel';
	@override String get strokeWidths => 'Kalem Kalınlıkları';
	@override String get strokeWidthsSubtitle => 'İnce · Orta · Kalın';
	@override String get palmRejection => 'Avuç İçi Tanıma';
	@override String get palmRejectionSubtitle => 'İstenmeyen girişleri önler';
	@override String get assistPanel => 'Yardımcı Panel';
	@override String get leftRightHanded => 'Sol · Sağ el';
	@override String get rightLeftHanded => 'Sağ · Sol el';
	@override String get drawingArea => 'Çizim Alanı';
	@override String get debugMode => 'Hata ayıklama modunu etkinleştir';
	@override String get cloud => 'Bulut & Senkronizasyon';
	@override String get storageTarget => 'Depolama Hedefi';
	@override String get storageSubtitle => 'Inkpadu Bulut (ücretsiz)';
	@override String get encryption => 'Şifreleme';
	@override String get encryptionSubtitle => 'Uçtan uca aktif';
}

// Path: errors
class _TranslationsErrorsTr extends TranslationsErrorsDe {
	_TranslationsErrorsTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Ağ hatası. Bağlantınızı kontrol edin.';
	@override String get unknownError => 'Bilinmeyen bir hata oluştu.';
	@override String get authError => 'Giriş hatası. Lütfen tekrar deneyin.';
	@override String get saveError => 'Kaydetme başarısız oldu.';
	@override String get loadError => 'Yükleme başarısız oldu.';
	@override String get exportError => 'Dışa aktarım başarısız oldu.';
	@override String loginFailed({required Object provider}) => 'Giriş (${provider}) başarısız';
}

// Path: onboarding
class _TranslationsOnboardingTr extends TranslationsOnboardingDe {
	_TranslationsOnboardingTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Inkpadu\'ya Hoş Geldiniz';
	@override String get description => 'Fikirleri çiz, notlar al ve düşüncelerini doğal el yazısıyla organize et.';
	@override String get digitalNotebook => 'Dijital Not Defterin';
	@override String get digitalNotebookDescription => 'Yaratıcılık ve odaklanma için optimize edilmiş, dikkat dağıtıcı unsurlardan uzak bir el yazısı deneyimi.';
	@override String get connecting => 'Bağlanıyor...';
	@override String get loginWithGitHub => 'GitHub ile giriş yap';
	@override String get loginWithGoogle => 'Google ile giriş yap';
}

// Path: editor
class _TranslationsEditorTr extends TranslationsEditorDe {
	_TranslationsEditorTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Yeni Not';
	@override String get editNote => 'Notu Düzenle';
	@override String get title => 'Başlık';
	@override String get writeNote => 'Notunu yaz...';
	@override String get assistPanel => 'Destek Paneli';
	@override String get leftRightHanded => 'Sol · Sağ El';
	@override String get rightLeftHanded => 'Sağ · Sol El';
	@override String get handednessHint => 'Sağ eliler panel sol olduğunda araçlara daha rahat ulaşır. Sol eliler ise sağ paneli tercih eder.';
	@override String get drawingArea => 'Çizim Alanı';
	@override String get enableDebugMode => 'Hata Ayıklama Modunu Aktifleştir';
	@override String get debugModeHint => 'Editörde ve AI asistanında sınırlayıcı kutuları ve konveks kapsülleri gösterir.';
	@override String get useLineSimplifier => 'Çizgi Basitleştiriciyi Kullan';
	@override String get lineSimplifierHint => 'Çizgilerini otomatik olarak düzelterek pürüzsüz hatlar elde eder.';
	@override String smoothingIntensity({required Object value}) => 'Pürüzsüzlük Yoğunluğu (${value})';
	@override String get smoothingHint => 'Düşük değerler daha fazla detay korur, yüksek değerler daha fazla düzgünleştirir.';
	@override String minTolerance({required Object value}) => 'Minimum Tolerans (${value} px)';
	@override String get minToleranceHint => 'Pürüzsüzlüğü alt sınır olarak belirler – daha yüksek değerler küçük dikenleri filtreler.';
	@override String get aiPersona => 'AI Asistanı Persona';
	@override String get choosePersonaStyle => 'Yapay Zeka Asistanının Stilini Seç';
	@override String get personaStyleHint => 'Persona, asistanın seninle nasıl iletişim kuracağını belirler.';
	@override String get strictTrainer => 'Sert Eğitmen';
	@override String get strictTrainerHint => 'Direkt, sert eleştiri gibi bir Rus Olimpiyat Antrenörü';
	@override String get encouragingMentor => 'Teşvik Edici Mentor';
	@override String get encouragingMentorHint => 'Olumlu pekiştirme ve motive edici geri bildirim';
	@override String get customPersona => 'Özelleştirilmiş';
	@override String get customPersonaHint => 'Kendi sistem komutunu belirle';
	@override String get yourSystemPrompt => 'Senin Sistem Komutun';
	@override String get systemPromptPlaceholder => 'Asistanın nasıl davranması gerektiğini tanımla...';
	@override String get systemPromptHint => 'Sistem komutu, asistanın tüm talepler karşısında kişiliğini ve davranışını tanımlar.';
	@override String get currentStyle => 'Geçerli Stil';
	@override String get strictTrainerDescription => 'Asistan, sana sert, doğrudan geri bildirim veriyor. Orta halli kabul edilmiyor ve yapıcı eleştirilerle seni en yüksek performansa teşvik ediyor.';
	@override String get encouragingMentorDescription => 'Asistan, ilerlemelerini övüyor ve teşvik edici geri bildirim veriyor. Hatalar öğrenme fırsatı olarak sunuluyor.';
	@override String get customPersonaDescription => 'Asistan, kendi sistem komutuna göre davranıyor.';
}

// Path: pdfDialog
class _TranslationsPdfDialogTr extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'PDF Seç';
	@override String get analyzePdf => 'PDF\'yi Analiz Et';
	@override String get ready => 'Hazır';
	@override String get processPdf => 'PDF\'yi İşle';
	@override String get importComplete => 'İçe Aktarma Tamamlandı';
	@override String get selectPdfFile => 'Lütfen bir PDF dosyası seçin...';
	@override String get analyzingPdf => 'PDF analiz ediliyor...';
	@override String pagesFound({required Object count}) => '${count} sayfa(lar) bulundu';
	@override String get textExtractionBackground => 'Metin çıkarma arka planda gerçekleşiyor.';
	@override String get couldNotReadPdf => 'PDF dosyası okunamadı.';
	@override String pagesImported({required Object count}) => '${count} sayfa(lar) içe aktarıldı';
	@override String charactersExtracted({required Object count}) => '~${count}k karakter çıkarıldı';
	@override String get extractedTextContext => 'Çıkarılan metin, AI asistanı için bağlam olarak kullanılır.';
	@override String get textExtractionDuration => 'Metin çıkarmak sayfa başına birkaç saniye sürebilir.';
	@override String renderingPage({required Object total, required Object current}) => '${total} sayfanın ${current}. sayfası işleniyor...';
	@override String extractingPage({required Object total, required Object current}) => '${total} sayfanın ${current}. sayfasından metin çıkarılıyor...';
	@override String get recognizingTasks => 'Görevler tanımlanıyor...';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Notların, senin tarzın',
			'common.save' => 'Kaydet',
			'common.cancel' => 'İptal',
			'common.delete' => 'Sil',
			'common.edit' => 'Düzenle',
			'common.close' => 'Kapat',
			'common.confirm' => 'Onayla',
			'common.loading' => 'Yükleniyor...',
			'common.error' => 'Hata',
			'common.success' => 'Başarılı',
			'common.retry' => 'Yeniden dene',
			'common.search' => 'Ara',
			'common.settings' => 'Ayarlar',
			'common.back' => 'Geri',
			'common.next' => 'İleri',
			'common.done' => 'Tamam',
			'common.yes' => 'Evet',
			'common.no' => 'Hayır',
			'common.apply' => 'Uygula',
			'common.loggedOut' => 'Çıkış yapıldı',
			'common.justNow' => 'Şu anda',
			'common.minutesAgo' => ({required Object count}) => '${count} dakika önce',
			'common.hoursAgo' => ({required Object count}) => '${count} saat önce',
			'common.yesterday' => 'Dün',
			'auth.login' => 'Giriş yap',
			'auth.logout' => 'Çıkış yap',
			'auth.register' => 'Kaydol',
			'auth.email' => 'E-posta',
			'auth.password' => 'Şifre',
			'auth.forgotPassword' => 'Şifreni mi unuttun?',
			'auth.welcomeBack' => 'Hoş geldin tekrar!',
			'auth.createAccount' => 'Hesap oluştur',
			'auth.loginWithGoogle' => 'Google ile giriş yap',
			'auth.loginWithApple' => 'Apple ile giriş yap',
			'nav.notes' => 'Notlar',
			'nav.settings' => 'Ayarlar',
			'notes.title' => 'Notlar',
			'notes.newNote' => 'Yeni Not',
			'notes.untitled' => 'Başlıksız',
			'notes.unnamed' => 'İsimsiz Not',
			'notes.noContent' => 'Henüz içerik yok',
			'notes.noteDate' => 'Not',
			'notes.lastEdited' => 'Son düzenleme',
			'notes.deleteNote' => 'Notu sil',
			'notes.deleteNoteConfirm' => ({required Object title}) => '"${title}"\'yı gerçekten silmek istiyor musun?',
			'notes.deleteNoteTooltip' => 'Notu sil',
			'notes.noNotes' => 'Henüz el yazısı not yok',
			'notes.createFirst' => 'İlk notunu oluştur',
			'notes.createNew' => 'Yeni Not Oluştur',
			'notes.export' => 'Dışa aktar',
			'notes.share' => 'Paylaş',
			'notes.duplicate' => 'Çoğalt',
			'notes.openNote' => 'Notu aç',
			'notes.adjustTitlePaper' => 'Başlık & Kağıt ayarla',
			'notes.emptyNote' => 'Boş not',
			'notes.emptyNoteSubtitle' => 'Boş bir sayfa ile başla',
			'drawing.pen' => 'Kalem',
			'drawing.pencil' => 'Kurşun kalem',
			'drawing.highlighter' => 'Marker',
			'drawing.eraser' => 'Silgi',
			'drawing.select' => 'Seç',
			'drawing.undo' => 'Geri al',
			'drawing.redo' => 'Yinele',
			'drawing.clear' => 'Temizle',
			'drawing.clearConfirm' => 'Tüm çizimleri silmek istiyor musun?',
			'drawing.color' => 'Renk',
			'drawing.colorWheel' => 'Renk paleti',
			'drawing.symbol' => 'Sembol',
			'drawing.strokeWidth' => 'Çizgi kalınlığı',
			'drawing.zoomIn' => 'Zoom yap',
			'drawing.zoomOut' => 'Zoomu azalt',
			'drawing.markerMode' => 'Marker modu (şeffaf)',
			'drawing.pressureDetection' => 'Baskı algılama',
			'drawing.customizeTool' => ({required Object name}) => '${name} ayarla',
			'drawing.fineliner' => 'İnce Kalem',
			'drawing.inkRoller' => 'Mürekkep Kalemi',
			'drawing.fountainPen' => 'Dolma Kalem',
			'drawing.marker' => 'İşaretleyici',
			'drawing.neon' => 'Neon',
			'paper.plain' => 'Düz',
			'paper.lined' => 'Çizgili',
			'paper.grid' => 'Kareli',
			'paper.dotted' => 'Noktalı',
			'ai.title' => 'Yapay Zeka Özellikleri',
			'ai.assistant' => 'Yapay Zeka Asistanı',
			'ai.recognize' => 'Metni tanı',
			'ai.recognizing' => 'Tanımlanıyor...',
			'ai.summarize' => 'Özetle',
			'ai.extractTasks' => 'Görevleri çıkar',
			'ai.translate' => 'Çevir',
			'ai.noTextFound' => 'Metin bulunamadı',
			'ai.persona' => 'Yapay Zeka Asistanı Persona',
			'ai.personaSubtitle' => 'Asistan stilini seç',
			'pdf.import' => 'PDF içe aktar',
			'pdf.importSubtitle' => 'Metin otomatik olarak çıkarılacak',
			'pdf.export' => 'PDF olarak dışa aktar',
			'pdf.exporting' => 'PDF oluşturuluyor...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF dışa aktarımı başarısız oldu: ${error}',
			'pdf.page' => 'Sayfa',
			'pdf.of' => ' / ',
			'settings.title' => 'Ayarlar',
			'settings.general' => 'Genel',
			'settings.theme' => 'Tema',
			'settings.themeSubtitle' => 'Açık · Karanlık · Sistem',
			'settings.darkMode' => 'Karanlık Mod',
			'settings.lightMode' => 'Aydınlık Mod',
			'settings.systemMode' => 'Sistem Modu',
			'settings.language' => 'Dil',
			'settings.languageSubtitle' => 'Türkçe',
			'settings.sync' => 'Senkronizasyon',
			'settings.syncEnabled' => 'Senkronizasyon etkin',
			'settings.syncDisabled' => 'Senkronizasyon devre dışı',
			'settings.account' => 'Hesap',
			'settings.about' => 'Hakkında',
			'settings.version' => 'Versiyon',
			'settings.privacy' => 'Gizlilik',
			'settings.terms' => 'Kullanım Şartları',
			'settings.input' => 'Girdi',
			'settings.inputDevices' => 'Giriş Aygıtları',
			'settings.inputDeviceSubtitle' => 'Kalem · Dokunmatik · Fare',
			'settings.automation' => 'Otomasyon',
			'settings.unlockPen' => 'Kalem kilidini aç',
			'settings.pen' => 'Kalem',
			'settings.touch' => 'Dokunmatik',
			'settings.mouse' => 'Fare',
			'settings.autoLockOnStylus' => 'Kalem ile otomatik kilitleme',
			'settings.editorSettings' => 'Editör Ayarları',
			'settings.noteEditor' => 'Not Editörü',
			'settings.noteEditorSubtitle' => 'Sol · Sağ panel',
			'settings.strokeWidths' => 'Kalem Kalınlıkları',
			'settings.strokeWidthsSubtitle' => 'İnce · Orta · Kalın',
			'settings.palmRejection' => 'Avuç İçi Tanıma',
			'settings.palmRejectionSubtitle' => 'İstenmeyen girişleri önler',
			'settings.assistPanel' => 'Yardımcı Panel',
			'settings.leftRightHanded' => 'Sol · Sağ el',
			'settings.rightLeftHanded' => 'Sağ · Sol el',
			'settings.drawingArea' => 'Çizim Alanı',
			'settings.debugMode' => 'Hata ayıklama modunu etkinleştir',
			'settings.cloud' => 'Bulut & Senkronizasyon',
			'settings.storageTarget' => 'Depolama Hedefi',
			'settings.storageSubtitle' => 'Inkpadu Bulut (ücretsiz)',
			'settings.encryption' => 'Şifreleme',
			'settings.encryptionSubtitle' => 'Uçtan uca aktif',
			'errors.networkError' => 'Ağ hatası. Bağlantınızı kontrol edin.',
			'errors.unknownError' => 'Bilinmeyen bir hata oluştu.',
			'errors.authError' => 'Giriş hatası. Lütfen tekrar deneyin.',
			'errors.saveError' => 'Kaydetme başarısız oldu.',
			'errors.loadError' => 'Yükleme başarısız oldu.',
			'errors.exportError' => 'Dışa aktarım başarısız oldu.',
			'errors.loginFailed' => ({required Object provider}) => 'Giriş (${provider}) başarısız',
			'onboarding.welcome' => 'Inkpadu\'ya Hoş Geldiniz',
			'onboarding.description' => 'Fikirleri çiz, notlar al ve düşüncelerini doğal el yazısıyla organize et.',
			'onboarding.digitalNotebook' => 'Dijital Not Defterin',
			'onboarding.digitalNotebookDescription' => 'Yaratıcılık ve odaklanma için optimize edilmiş, dikkat dağıtıcı unsurlardan uzak bir el yazısı deneyimi.',
			'onboarding.connecting' => 'Bağlanıyor...',
			'onboarding.loginWithGitHub' => 'GitHub ile giriş yap',
			'onboarding.loginWithGoogle' => 'Google ile giriş yap',
			'editor.newNote' => 'Yeni Not',
			'editor.editNote' => 'Notu Düzenle',
			'editor.title' => 'Başlık',
			'editor.writeNote' => 'Notunu yaz...',
			'editor.assistPanel' => 'Destek Paneli',
			'editor.leftRightHanded' => 'Sol · Sağ El',
			'editor.rightLeftHanded' => 'Sağ · Sol El',
			'editor.handednessHint' => 'Sağ eliler panel sol olduğunda araçlara daha rahat ulaşır. Sol eliler ise sağ paneli tercih eder.',
			'editor.drawingArea' => 'Çizim Alanı',
			'editor.enableDebugMode' => 'Hata Ayıklama Modunu Aktifleştir',
			'editor.debugModeHint' => 'Editörde ve AI asistanında sınırlayıcı kutuları ve konveks kapsülleri gösterir.',
			'editor.useLineSimplifier' => 'Çizgi Basitleştiriciyi Kullan',
			'editor.lineSimplifierHint' => 'Çizgilerini otomatik olarak düzelterek pürüzsüz hatlar elde eder.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Pürüzsüzlük Yoğunluğu (${value})',
			'editor.smoothingHint' => 'Düşük değerler daha fazla detay korur, yüksek değerler daha fazla düzgünleştirir.',
			'editor.minTolerance' => ({required Object value}) => 'Minimum Tolerans (${value} px)',
			'editor.minToleranceHint' => 'Pürüzsüzlüğü alt sınır olarak belirler – daha yüksek değerler küçük dikenleri filtreler.',
			'editor.aiPersona' => 'AI Asistanı Persona',
			'editor.choosePersonaStyle' => 'Yapay Zeka Asistanının Stilini Seç',
			'editor.personaStyleHint' => 'Persona, asistanın seninle nasıl iletişim kuracağını belirler.',
			'editor.strictTrainer' => 'Sert Eğitmen',
			'editor.strictTrainerHint' => 'Direkt, sert eleştiri gibi bir Rus Olimpiyat Antrenörü',
			'editor.encouragingMentor' => 'Teşvik Edici Mentor',
			'editor.encouragingMentorHint' => 'Olumlu pekiştirme ve motive edici geri bildirim',
			'editor.customPersona' => 'Özelleştirilmiş',
			'editor.customPersonaHint' => 'Kendi sistem komutunu belirle',
			'editor.yourSystemPrompt' => 'Senin Sistem Komutun',
			'editor.systemPromptPlaceholder' => 'Asistanın nasıl davranması gerektiğini tanımla...',
			'editor.systemPromptHint' => 'Sistem komutu, asistanın tüm talepler karşısında kişiliğini ve davranışını tanımlar.',
			'editor.currentStyle' => 'Geçerli Stil',
			'editor.strictTrainerDescription' => 'Asistan, sana sert, doğrudan geri bildirim veriyor. Orta halli kabul edilmiyor ve yapıcı eleştirilerle seni en yüksek performansa teşvik ediyor.',
			'editor.encouragingMentorDescription' => 'Asistan, ilerlemelerini övüyor ve teşvik edici geri bildirim veriyor. Hatalar öğrenme fırsatı olarak sunuluyor.',
			'editor.customPersonaDescription' => 'Asistan, kendi sistem komutuna göre davranıyor.',
			'pdfDialog.selectPdf' => 'PDF Seç',
			'pdfDialog.analyzePdf' => 'PDF\'yi Analiz Et',
			'pdfDialog.ready' => 'Hazır',
			'pdfDialog.processPdf' => 'PDF\'yi İşle',
			'pdfDialog.importComplete' => 'İçe Aktarma Tamamlandı',
			'pdfDialog.selectPdfFile' => 'Lütfen bir PDF dosyası seçin...',
			'pdfDialog.analyzingPdf' => 'PDF analiz ediliyor...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} sayfa(lar) bulundu',
			'pdfDialog.textExtractionBackground' => 'Metin çıkarma arka planda gerçekleşiyor.',
			'pdfDialog.couldNotReadPdf' => 'PDF dosyası okunamadı.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} sayfa(lar) içe aktarıldı',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k karakter çıkarıldı',
			'pdfDialog.extractedTextContext' => 'Çıkarılan metin, AI asistanı için bağlam olarak kullanılır.',
			'pdfDialog.textExtractionDuration' => 'Metin çıkarmak sayfa başına birkaç saniye sürebilir.',
			'pdfDialog.renderingPage' => ({required Object total, required Object current}) => '${total} sayfanın ${current}. sayfası işleniyor...',
			'pdfDialog.extractingPage' => ({required Object total, required Object current}) => '${total} sayfanın ${current}. sayfasından metin çıkarılıyor...',
			'pdfDialog.recognizingTasks' => 'Görevler tanımlanıyor...',
			_ => null,
		};
	}
}
