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
	@override late final _TranslationsNotesTr notes = _TranslationsNotesTr._(_root);
	@override late final _TranslationsDrawingTr drawing = _TranslationsDrawingTr._(_root);
	@override late final _TranslationsAiTr ai = _TranslationsAiTr._(_root);
	@override late final _TranslationsPdfTr pdf = _TranslationsPdfTr._(_root);
	@override late final _TranslationsSettingsTr settings = _TranslationsSettingsTr._(_root);
	@override late final _TranslationsErrorsTr errors = _TranslationsErrorsTr._(_root);
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

// Path: notes
class _TranslationsNotesTr extends TranslationsNotesDe {
	_TranslationsNotesTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notlar';
	@override String get newNote => 'Yeni Not';
	@override String get untitled => 'Başlıksız';
	@override String get lastEdited => 'Son düzenleme';
	@override String get deleteNote => 'Notu sil';
	@override String deleteNoteConfirm({required Object title}) => '"${title}"\'yı gerçekten silmek istiyor musun?';
	@override String get noNotes => 'Henüz el yazısı not yok';
	@override String get createFirst => 'İlk notunu oluştur';
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
}

// Path: ai
class _TranslationsAiTr extends TranslationsAiDe {
	_TranslationsAiTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Yapay Zeka Özellikleri';
	@override String get recognize => 'Metni tanı';
	@override String get recognizing => 'Tanımlanıyor...';
	@override String get summarize => 'Özetle';
	@override String get extractTasks => 'Görevleri çıkar';
	@override String get translate => 'Çevir';
	@override String get noTextFound => 'Metin bulunamadı';
	@override String get persona => 'Yapay Zeka Asistanı Persona';
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
	@override String get theme => 'Tema';
	@override String get darkMode => 'Karanlık Mod';
	@override String get lightMode => 'Aydınlık Mod';
	@override String get systemMode => 'Sistem Modu';
	@override String get language => 'Dil';
	@override String get sync => 'Senkronizasyon';
	@override String get syncEnabled => 'Senkronizasyon etkin';
	@override String get syncDisabled => 'Senkronizasyon devre dışı';
	@override String get account => 'Hesap';
	@override String get about => 'Hakkında';
	@override String get version => 'Versiyon';
	@override String get privacy => 'Gizlilik';
	@override String get terms => 'Kullanım Şartları';
	@override String get inputDevices => 'Giriş Aygıtları';
	@override String get automation => 'Otomasyon';
	@override String get unlockPen => 'Kalem kilidini aç';
	@override String get pen => 'Kalem';
	@override String get touch => 'Dokunmatik';
	@override String get mouse => 'Fare';
	@override String get autoLockOnStylus => 'Kalem ile otomatik kilitleme';
	@override String get editorSettings => 'Editör Ayarları';
	@override String get assistPanel => 'Yardımcı Panel';
	@override String get leftRightHanded => 'Sol · Sağ el';
	@override String get rightLeftHanded => 'Sağ · Sol el';
	@override String get drawingArea => 'Çizim Alanı';
	@override String get debugMode => 'Hata ayıklama modunu etkinleştir';
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
			'notes.title' => 'Notlar',
			'notes.newNote' => 'Yeni Not',
			'notes.untitled' => 'Başlıksız',
			'notes.lastEdited' => 'Son düzenleme',
			'notes.deleteNote' => 'Notu sil',
			'notes.deleteNoteConfirm' => ({required Object title}) => '"${title}"\'yı gerçekten silmek istiyor musun?',
			'notes.noNotes' => 'Henüz el yazısı not yok',
			'notes.createFirst' => 'İlk notunu oluştur',
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
			'ai.title' => 'Yapay Zeka Özellikleri',
			'ai.recognize' => 'Metni tanı',
			'ai.recognizing' => 'Tanımlanıyor...',
			'ai.summarize' => 'Özetle',
			'ai.extractTasks' => 'Görevleri çıkar',
			'ai.translate' => 'Çevir',
			'ai.noTextFound' => 'Metin bulunamadı',
			'ai.persona' => 'Yapay Zeka Asistanı Persona',
			'pdf.import' => 'PDF içe aktar',
			'pdf.importSubtitle' => 'Metin otomatik olarak çıkarılacak',
			'pdf.export' => 'PDF olarak dışa aktar',
			'pdf.exporting' => 'PDF oluşturuluyor...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF dışa aktarımı başarısız oldu: ${error}',
			'pdf.page' => 'Sayfa',
			'pdf.of' => ' / ',
			'settings.title' => 'Ayarlar',
			'settings.theme' => 'Tema',
			'settings.darkMode' => 'Karanlık Mod',
			'settings.lightMode' => 'Aydınlık Mod',
			'settings.systemMode' => 'Sistem Modu',
			'settings.language' => 'Dil',
			'settings.sync' => 'Senkronizasyon',
			'settings.syncEnabled' => 'Senkronizasyon etkin',
			'settings.syncDisabled' => 'Senkronizasyon devre dışı',
			'settings.account' => 'Hesap',
			'settings.about' => 'Hakkında',
			'settings.version' => 'Versiyon',
			'settings.privacy' => 'Gizlilik',
			'settings.terms' => 'Kullanım Şartları',
			'settings.inputDevices' => 'Giriş Aygıtları',
			'settings.automation' => 'Otomasyon',
			'settings.unlockPen' => 'Kalem kilidini aç',
			'settings.pen' => 'Kalem',
			'settings.touch' => 'Dokunmatik',
			'settings.mouse' => 'Fare',
			'settings.autoLockOnStylus' => 'Kalem ile otomatik kilitleme',
			'settings.editorSettings' => 'Editör Ayarları',
			'settings.assistPanel' => 'Yardımcı Panel',
			'settings.leftRightHanded' => 'Sol · Sağ el',
			'settings.rightLeftHanded' => 'Sağ · Sol el',
			'settings.drawingArea' => 'Çizim Alanı',
			'settings.debugMode' => 'Hata ayıklama modunu etkinleştir',
			'errors.networkError' => 'Ağ hatası. Bağlantınızı kontrol edin.',
			'errors.unknownError' => 'Bilinmeyen bir hata oluştu.',
			'errors.authError' => 'Giriş hatası. Lütfen tekrar deneyin.',
			'errors.saveError' => 'Kaydetme başarısız oldu.',
			'errors.loadError' => 'Yükleme başarısız oldu.',
			'errors.exportError' => 'Dışa aktarım başarısız oldu.',
			_ => null,
		};
	}
}
