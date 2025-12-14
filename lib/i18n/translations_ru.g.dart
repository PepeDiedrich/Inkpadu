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
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppRu app = _TranslationsAppRu._(_root);
	@override late final _TranslationsCommonRu common = _TranslationsCommonRu._(_root);
	@override late final _TranslationsAuthRu auth = _TranslationsAuthRu._(_root);
	@override late final _TranslationsNotesRu notes = _TranslationsNotesRu._(_root);
	@override late final _TranslationsDrawingRu drawing = _TranslationsDrawingRu._(_root);
	@override late final _TranslationsAiRu ai = _TranslationsAiRu._(_root);
	@override late final _TranslationsPdfRu pdf = _TranslationsPdfRu._(_root);
	@override late final _TranslationsSettingsRu settings = _TranslationsSettingsRu._(_root);
	@override late final _TranslationsErrorsRu errors = _TranslationsErrorsRu._(_root);
}

// Path: app
class _TranslationsAppRu extends TranslationsAppDe {
	_TranslationsAppRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Твои заметки, твой стиль';
}

// Path: common
class _TranslationsCommonRu extends TranslationsCommonDe {
	_TranslationsCommonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get save => 'Сохранить';
	@override String get cancel => 'Отмена';
	@override String get delete => 'Удалить';
	@override String get edit => 'Редактировать';
	@override String get close => 'Закрыть';
	@override String get confirm => 'Подтвердить';
	@override String get loading => 'Загрузка...';
	@override String get error => 'Ошибка';
	@override String get success => 'Успешно';
	@override String get retry => 'Попробовать снова';
	@override String get search => 'Поиск';
	@override String get settings => 'Настройки';
	@override String get back => 'Назад';
	@override String get next => 'Далее';
	@override String get done => 'Готово';
	@override String get yes => 'Да';
	@override String get no => 'Нет';
	@override String get apply => 'Применить';
	@override String get loggedOut => 'Вы вышли';
}

// Path: auth
class _TranslationsAuthRu extends TranslationsAuthDe {
	_TranslationsAuthRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get login => 'Войти';
	@override String get logout => 'Выйти';
	@override String get register => 'Регистрация';
	@override String get email => 'Электронная почта';
	@override String get password => 'Пароль';
	@override String get forgotPassword => 'Забыли пароль?';
	@override String get welcomeBack => 'С возвращением!';
	@override String get createAccount => 'Создать аккаунт';
	@override String get loginWithGoogle => 'Войти с помощью Google';
	@override String get loginWithApple => 'Войти с помощью Apple';
}

// Path: notes
class _TranslationsNotesRu extends TranslationsNotesDe {
	_TranslationsNotesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Заметки';
	@override String get newNote => 'Новая заметка';
	@override String get untitled => 'Без названия';
	@override String get lastEdited => 'Последнее редактирование';
	@override String get deleteNote => 'Удалить заметку';
	@override String deleteNoteConfirm({required Object title}) => 'Вы действительно хотите удалить "${title}"?';
	@override String get noNotes => 'Пока нет рукописных заметок';
	@override String get createFirst => 'Создайте свою первую заметку';
	@override String get export => 'Экспортировать';
	@override String get share => 'Поделиться';
	@override String get duplicate => 'Создать дубликат';
	@override String get openNote => 'Открыть заметку';
	@override String get adjustTitlePaper => 'Настроить заголовок и бумагу';
	@override String get emptyNote => 'Пустая заметка';
	@override String get emptyNoteSubtitle => 'Начните с пустой страницы';
}

// Path: drawing
class _TranslationsDrawingRu extends TranslationsDrawingDe {
	_TranslationsDrawingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Ручка';
	@override String get pencil => 'Карандаш';
	@override String get highlighter => 'Маркер';
	@override String get eraser => 'Стерка';
	@override String get select => 'Выбрать';
	@override String get undo => 'Отменить';
	@override String get redo => 'Повторить';
	@override String get clear => 'Очистить';
	@override String get clearConfirm => 'Удалить все рисунки?';
	@override String get color => 'Цвет';
	@override String get colorWheel => 'Цветовой круг';
	@override String get symbol => 'Символ';
	@override String get strokeWidth => 'Толщина линии';
	@override String get zoomIn => 'Увеличить';
	@override String get zoomOut => 'Уменьшить';
	@override String get markerMode => 'Режим маркера (прозрачный)';
	@override String get pressureDetection => 'Обнаружение давления';
	@override String customizeTool({required Object name}) => 'Настроить ${name}';
}

// Path: ai
class _TranslationsAiRu extends TranslationsAiDe {
	_TranslationsAiRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Функции';
	@override String get recognize => 'Распознать текст';
	@override String get recognizing => 'Распознавание...';
	@override String get summarize => 'Подвести итоги';
	@override String get extractTasks => 'Извлечение задач';
	@override String get translate => 'Перевести';
	@override String get noTextFound => 'Текст не найден';
	@override String get persona => 'Персона AI-ассистента';
}

// Path: pdf
class _TranslationsPdfRu extends TranslationsPdfDe {
	_TranslationsPdfRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get import => 'Импортировать PDF';
	@override String get importSubtitle => 'Текст будет автоматически извлечен';
	@override String get export => 'Экспорт в PDF';
	@override String get exporting => 'Создание PDF...';
	@override String exportFailed({required Object error}) => 'Ошибка экспорта PDF: ${error}';
	@override String get page => 'Страница';
	@override String get of => 'из';
}

// Path: settings
class _TranslationsSettingsRu extends TranslationsSettingsDe {
	_TranslationsSettingsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Настройки';
	@override String get theme => 'Тема';
	@override String get darkMode => 'Темный режим';
	@override String get lightMode => 'Светлый режим';
	@override String get systemMode => 'Системный режим';
	@override String get language => 'Язык';
	@override String get sync => 'Синхронизация';
	@override String get syncEnabled => 'Синхронизация включена';
	@override String get syncDisabled => 'Синхронизация выключена';
	@override String get account => 'Аккаунт';
	@override String get about => 'О приложении';
	@override String get version => 'Версия';
	@override String get privacy => 'Конфиденциальность';
	@override String get terms => 'Условия использования';
	@override String get inputDevices => 'Устройства ввода';
	@override String get automation => 'Автоматизация';
	@override String get unlockPen => 'Разблокировать ручку';
	@override String get pen => 'Ручка';
	@override String get touch => 'Тач';
	@override String get mouse => 'Мышь';
	@override String get autoLockOnStylus => 'Автоматическая блокировка на стилусе';
	@override String get editorSettings => 'Настройки редактора';
	@override String get assistPanel => 'Панель помощи';
	@override String get leftRightHanded => 'Левая · Правая рука';
	@override String get rightLeftHanded => 'Правая · Левая рука';
	@override String get drawingArea => 'Область рисования';
	@override String get debugMode => 'Включить режим отладки';
}

// Path: errors
class _TranslationsErrorsRu extends TranslationsErrorsDe {
	_TranslationsErrorsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Ошибка сети. Проверьте подключение.';
	@override String get unknownError => 'Произошла неизвестная ошибка.';
	@override String get authError => 'Ошибка входа. Пожалуйста, попробуйте снова.';
	@override String get saveError => 'Не удалось сохранить.';
	@override String get loadError => 'Не удалось загрузить.';
	@override String get exportError => 'Не удалось экспортировать.';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Твои заметки, твой стиль',
			'common.save' => 'Сохранить',
			'common.cancel' => 'Отмена',
			'common.delete' => 'Удалить',
			'common.edit' => 'Редактировать',
			'common.close' => 'Закрыть',
			'common.confirm' => 'Подтвердить',
			'common.loading' => 'Загрузка...',
			'common.error' => 'Ошибка',
			'common.success' => 'Успешно',
			'common.retry' => 'Попробовать снова',
			'common.search' => 'Поиск',
			'common.settings' => 'Настройки',
			'common.back' => 'Назад',
			'common.next' => 'Далее',
			'common.done' => 'Готово',
			'common.yes' => 'Да',
			'common.no' => 'Нет',
			'common.apply' => 'Применить',
			'common.loggedOut' => 'Вы вышли',
			'auth.login' => 'Войти',
			'auth.logout' => 'Выйти',
			'auth.register' => 'Регистрация',
			'auth.email' => 'Электронная почта',
			'auth.password' => 'Пароль',
			'auth.forgotPassword' => 'Забыли пароль?',
			'auth.welcomeBack' => 'С возвращением!',
			'auth.createAccount' => 'Создать аккаунт',
			'auth.loginWithGoogle' => 'Войти с помощью Google',
			'auth.loginWithApple' => 'Войти с помощью Apple',
			'notes.title' => 'Заметки',
			'notes.newNote' => 'Новая заметка',
			'notes.untitled' => 'Без названия',
			'notes.lastEdited' => 'Последнее редактирование',
			'notes.deleteNote' => 'Удалить заметку',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Вы действительно хотите удалить "${title}"?',
			'notes.noNotes' => 'Пока нет рукописных заметок',
			'notes.createFirst' => 'Создайте свою первую заметку',
			'notes.export' => 'Экспортировать',
			'notes.share' => 'Поделиться',
			'notes.duplicate' => 'Создать дубликат',
			'notes.openNote' => 'Открыть заметку',
			'notes.adjustTitlePaper' => 'Настроить заголовок и бумагу',
			'notes.emptyNote' => 'Пустая заметка',
			'notes.emptyNoteSubtitle' => 'Начните с пустой страницы',
			'drawing.pen' => 'Ручка',
			'drawing.pencil' => 'Карандаш',
			'drawing.highlighter' => 'Маркер',
			'drawing.eraser' => 'Стерка',
			'drawing.select' => 'Выбрать',
			'drawing.undo' => 'Отменить',
			'drawing.redo' => 'Повторить',
			'drawing.clear' => 'Очистить',
			'drawing.clearConfirm' => 'Удалить все рисунки?',
			'drawing.color' => 'Цвет',
			'drawing.colorWheel' => 'Цветовой круг',
			'drawing.symbol' => 'Символ',
			'drawing.strokeWidth' => 'Толщина линии',
			'drawing.zoomIn' => 'Увеличить',
			'drawing.zoomOut' => 'Уменьшить',
			'drawing.markerMode' => 'Режим маркера (прозрачный)',
			'drawing.pressureDetection' => 'Обнаружение давления',
			'drawing.customizeTool' => ({required Object name}) => 'Настроить ${name}',
			'ai.title' => 'AI Функции',
			'ai.recognize' => 'Распознать текст',
			'ai.recognizing' => 'Распознавание...',
			'ai.summarize' => 'Подвести итоги',
			'ai.extractTasks' => 'Извлечение задач',
			'ai.translate' => 'Перевести',
			'ai.noTextFound' => 'Текст не найден',
			'ai.persona' => 'Персона AI-ассистента',
			'pdf.import' => 'Импортировать PDF',
			'pdf.importSubtitle' => 'Текст будет автоматически извлечен',
			'pdf.export' => 'Экспорт в PDF',
			'pdf.exporting' => 'Создание PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Ошибка экспорта PDF: ${error}',
			'pdf.page' => 'Страница',
			'pdf.of' => 'из',
			'settings.title' => 'Настройки',
			'settings.theme' => 'Тема',
			'settings.darkMode' => 'Темный режим',
			'settings.lightMode' => 'Светлый режим',
			'settings.systemMode' => 'Системный режим',
			'settings.language' => 'Язык',
			'settings.sync' => 'Синхронизация',
			'settings.syncEnabled' => 'Синхронизация включена',
			'settings.syncDisabled' => 'Синхронизация выключена',
			'settings.account' => 'Аккаунт',
			'settings.about' => 'О приложении',
			'settings.version' => 'Версия',
			'settings.privacy' => 'Конфиденциальность',
			'settings.terms' => 'Условия использования',
			'settings.inputDevices' => 'Устройства ввода',
			'settings.automation' => 'Автоматизация',
			'settings.unlockPen' => 'Разблокировать ручку',
			'settings.pen' => 'Ручка',
			'settings.touch' => 'Тач',
			'settings.mouse' => 'Мышь',
			'settings.autoLockOnStylus' => 'Автоматическая блокировка на стилусе',
			'settings.editorSettings' => 'Настройки редактора',
			'settings.assistPanel' => 'Панель помощи',
			'settings.leftRightHanded' => 'Левая · Правая рука',
			'settings.rightLeftHanded' => 'Правая · Левая рука',
			'settings.drawingArea' => 'Область рисования',
			'settings.debugMode' => 'Включить режим отладки',
			'errors.networkError' => 'Ошибка сети. Проверьте подключение.',
			'errors.unknownError' => 'Произошла неизвестная ошибка.',
			'errors.authError' => 'Ошибка входа. Пожалуйста, попробуйте снова.',
			'errors.saveError' => 'Не удалось сохранить.',
			'errors.loadError' => 'Не удалось загрузить.',
			'errors.exportError' => 'Не удалось экспортировать.',
			_ => null,
		};
	}
}
