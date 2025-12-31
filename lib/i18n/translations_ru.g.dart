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
	@override late final _TranslationsNavRu nav = _TranslationsNavRu._(_root);
	@override late final _TranslationsNotesRu notes = _TranslationsNotesRu._(_root);
	@override late final _TranslationsDrawingRu drawing = _TranslationsDrawingRu._(_root);
	@override late final _TranslationsPaperRu paper = _TranslationsPaperRu._(_root);
	@override late final _TranslationsAiRu ai = _TranslationsAiRu._(_root);
	@override late final _TranslationsPdfRu pdf = _TranslationsPdfRu._(_root);
	@override late final _TranslationsSettingsRu settings = _TranslationsSettingsRu._(_root);
	@override late final _TranslationsErrorsRu errors = _TranslationsErrorsRu._(_root);
	@override late final _TranslationsOnboardingRu onboarding = _TranslationsOnboardingRu._(_root);
	@override late final _TranslationsEditorRu editor = _TranslationsEditorRu._(_root);
	@override late final _TranslationsPdfDialogRu pdfDialog = _TranslationsPdfDialogRu._(_root);
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
	@override String get justNow => 'Только что';
	@override String minutesAgo({required Object count}) => 'назад ${count} минут(ы)';
	@override String hoursAgo({required Object count}) => 'назад ${count} часов(а)';
	@override String get yesterday => 'Вчера';
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

// Path: nav
class _TranslationsNavRu extends TranslationsNavDe {
	_TranslationsNavRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Заметки';
	@override String get settings => 'Настройки';
}

// Path: notes
class _TranslationsNotesRu extends TranslationsNotesDe {
	_TranslationsNotesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Заметки';
	@override String get newNote => 'Новая заметка';
	@override String get untitled => 'Без названия';
	@override String get unnamed => 'Безымянная заметка';
	@override String get noContent => 'Нет контента';
	@override String get noteDate => 'Заметка';
	@override String get lastEdited => 'Последнее редактирование';
	@override String get deleteNote => 'Удалить заметку';
	@override String deleteNoteConfirm({required Object title}) => 'Вы действительно хотите удалить "${title}"?';
	@override String get deleteNoteTooltip => 'Удалить заметку';
	@override String get noNotes => 'Пока нет рукописных заметок';
	@override String get createFirst => 'Создайте свою первую заметку';
	@override String get createNew => 'Создать новую заметку';
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
	@override String get fineliner => 'Тонкий маркер';
	@override String get inkRoller => 'Карандаш с чернилами';
	@override String get fountainPen => 'Ручка';
	@override String get marker => 'Маркер';
	@override String get neon => 'Неон';
}

// Path: paper
class _TranslationsPaperRu extends TranslationsPaperDe {
	_TranslationsPaperRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Простой';
	@override String get lined => 'В линейку';
	@override String get grid => 'В клетку';
	@override String get dotted => 'В точку';
}

// Path: ai
class _TranslationsAiRu extends TranslationsAiDe {
	_TranslationsAiRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Функции';
	@override String get assistant => 'AI Ассистент';
	@override String get recognize => 'Распознать текст';
	@override String get recognizing => 'Распознавание...';
	@override String get summarize => 'Подвести итоги';
	@override String get extractTasks => 'Извлечение задач';
	@override String get translate => 'Перевести';
	@override String get noTextFound => 'Текст не найден';
	@override String get persona => 'Персона AI-ассистента';
	@override String get personaSubtitle => 'Выбрать стиль ассистента';
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
	@override String get general => 'Общие';
	@override String get theme => 'Тема';
	@override String get themeSubtitle => 'Светлая · Тёмная · Системная';
	@override String get darkMode => 'Темный режим';
	@override String get lightMode => 'Светлый режим';
	@override String get systemMode => 'Системный режим';
	@override String get language => 'Язык';
	@override String get languageSubtitle => 'Русский (бета)';
	@override String get sync => 'Синхронизация';
	@override String get syncEnabled => 'Синхронизация включена';
	@override String get syncDisabled => 'Синхронизация выключена';
	@override String get account => 'Аккаунт';
	@override String get about => 'О приложении';
	@override String get version => 'Версия';
	@override String get privacy => 'Конфиденциальность';
	@override String get terms => 'Условия использования';
	@override String get input => 'Ввод';
	@override String get inputDevices => 'Устройства ввода';
	@override String get inputDeviceSubtitle => 'Ручка · Сенсор · Мышь';
	@override String get automation => 'Автоматизация';
	@override String get unlockPen => 'Разблокировать ручку';
	@override String get pen => 'Ручка';
	@override String get touch => 'Тач';
	@override String get mouse => 'Мышь';
	@override String get autoLockOnStylus => 'Автоматическая блокировка на стилусе';
	@override String get editorSettings => 'Настройки редактора';
	@override String get noteEditor => 'Редактор заметок';
	@override String get noteEditorSubtitle => 'Боковая панель слева · справа';
	@override String get strokeWidths => 'Толщина линий';
	@override String get strokeWidthsSubtitle => 'Тонкий · Средний · Толстый';
	@override String get palmRejection => 'Обнаружение ладони';
	@override String get palmRejectionSubtitle => 'Предотвращает случайные вводы';
	@override String get assistPanel => 'Панель помощи';
	@override String get leftRightHanded => 'Левая · Правая рука';
	@override String get rightLeftHanded => 'Правая · Левая рука';
	@override String get drawingArea => 'Область рисования';
	@override String get debugMode => 'Включить режим отладки';
	@override String get cloud => 'Облако и синхронизация';
	@override String get storageTarget => 'Цель хранения';
	@override String get storageSubtitle => 'Inkpadu Cloud (бесплатно)';
	@override String get encryption => 'Шифрование';
	@override String get encryptionSubtitle => 'Шифрование от конца до конца активно';
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
	@override String loginFailed({required Object provider}) => 'Ошибка входа (${provider})';
}

// Path: onboarding
class _TranslationsOnboardingRu extends TranslationsOnboardingDe {
	_TranslationsOnboardingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Добро пожаловать в Inkpadu';
	@override String get description => 'Набрасывай идеи, записывай заметки и организуй свои мысли с помощью естественного почерка.';
	@override String get digitalNotebook => 'Твой цифровой блокнот';
	@override String get digitalNotebookDescription => 'Опыт рукописного ввода, оптимизированный для креативности и концентрации — совершенно без отвлечений.';
	@override String get connecting => 'Подключаюсь…';
	@override String get loginWithGitHub => 'Войти через GitHub';
	@override String get loginWithGoogle => 'Войти через Google';
}

// Path: editor
class _TranslationsEditorRu extends TranslationsEditorDe {
	_TranslationsEditorRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Новая заметка';
	@override String get editNote => 'Редактировать заметку';
	@override String get title => 'Заголовок';
	@override String get writeNote => 'Напиши свою заметку...';
	@override String get assistPanel => 'Панель помощи';
	@override String get leftRightHanded => 'Левша · Правша';
	@override String get rightLeftHanded => 'Правша · Левша';
	@override String get handednessHint => 'Правшам удобнее использовать инструменты, когда панель слева. Левшам лучше выбрать правую сторону.';
	@override String get drawingArea => 'Область рисования';
	@override String get enableDebugMode => 'Включить режим отладки';
	@override String get debugModeHint => 'Показать рамки и конвексные оболочки в редакторе и AI ассистенте.';
	@override String get useLineSimplifier => 'Использовать упрощение линий';
	@override String get lineSimplifierHint => 'Автоматически сглаживает твои линии для получения ровных линий.';
	@override String smoothingIntensity({required Object value}) => 'Интенсивность сглаживания (${value})';
	@override String get smoothingHint => 'Низкие значения сохраняют больше деталей, высокие значения более гладкие.';
	@override String minTolerance({required Object value}) => 'Минимальная толерантность (${value} px)';
	@override String get minToleranceHint => 'Устанавливает нижнюю границу для сглаживания — более высокие значения фильтруют мелкие зубцы.';
	@override String get aiPersona => 'Персона AI Ассистента';
	@override String get choosePersonaStyle => 'Выбери стиль своего AI ассистента';
	@override String get personaStyleHint => 'Персона определяет, как ассистент общается с тобой.';
	@override String get strictTrainer => 'Строгий тренер';
	@override String get strictTrainerHint => 'Прямые, жесткие критики как у русского олимпийского тренера';
	@override String get encouragingMentor => 'Вдохновляющий наставник';
	@override String get encouragingMentorHint => 'Позитивная обратная связь и мотивирующие комментарии';
	@override String get customPersona => 'Пользовательский';
	@override String get customPersonaHint => 'Установите свой собственный системный промт';
	@override String get yourSystemPrompt => 'Твой системный промт';
	@override String get systemPromptPlaceholder => 'Опиши, как должен вести себя ассистент...';
	@override String get systemPromptHint => 'Системный промт определяет личность и поведение ассистента при всех запросах.';
	@override String get currentStyle => 'Текущий стиль';
	@override String get strictTrainerDescription => 'Ассистент дает жесткую и прямую обратную связь. Он не принимает посредственности и мотивирует тебя к достижению высот через конструктивную критику.';
	@override String get encouragingMentorDescription => 'Ассистент хвалит твои достижения и дает вдохновляющую обратную связь. Ошибки рассматриваются как возможности для обучения.';
	@override String get customPersonaDescription => 'Ассистент ведет себя согласно твоему собственному системному промту.';
}

// Path: pdfDialog
class _TranslationsPdfDialogRu extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Выбрать PDF';
	@override String get analyzePdf => 'Анализировать PDF';
	@override String get ready => 'Готово';
	@override String get processPdf => 'Обработать PDF';
	@override String get importComplete => 'Импорт завершен';
	@override String get selectPdfFile => 'Пожалуйста, выберите файл PDF...';
	@override String get analyzingPdf => 'Анализирую PDF...';
	@override String pagesFound({required Object count}) => '${count} страница(ы) найдена(ы)';
	@override String get textExtractionBackground => 'Извлечение текста выполняется в фоновом режиме.';
	@override String get couldNotReadPdf => 'Не удалось прочитать PDF-файл.';
	@override String pagesImported({required Object count}) => '${count} страница(ы) импортирована(ы)';
	@override String charactersExtracted({required Object count}) => '~${count}k символов извлечено';
	@override String get extractedTextContext => 'Извлеченный текст используется в качестве контекста для AI ассистента.';
	@override String get textExtractionDuration => 'Извлечение текста может занять несколько секунд на страницу.';
	@override String renderingPage({required Object current, required Object total}) => 'Рендеринг страницы ${current} из ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Извлекаю текст со страницы ${current} из ${total}...';
	@override String get recognizingTasks => 'Распознаю задачи...';
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
			'common.justNow' => 'Только что',
			'common.minutesAgo' => ({required Object count}) => 'назад ${count} минут(ы)',
			'common.hoursAgo' => ({required Object count}) => 'назад ${count} часов(а)',
			'common.yesterday' => 'Вчера',
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
			'nav.notes' => 'Заметки',
			'nav.settings' => 'Настройки',
			'notes.title' => 'Заметки',
			'notes.newNote' => 'Новая заметка',
			'notes.untitled' => 'Без названия',
			'notes.unnamed' => 'Безымянная заметка',
			'notes.noContent' => 'Нет контента',
			'notes.noteDate' => 'Заметка',
			'notes.lastEdited' => 'Последнее редактирование',
			'notes.deleteNote' => 'Удалить заметку',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Вы действительно хотите удалить "${title}"?',
			'notes.deleteNoteTooltip' => 'Удалить заметку',
			'notes.noNotes' => 'Пока нет рукописных заметок',
			'notes.createFirst' => 'Создайте свою первую заметку',
			'notes.createNew' => 'Создать новую заметку',
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
			'drawing.fineliner' => 'Тонкий маркер',
			'drawing.inkRoller' => 'Карандаш с чернилами',
			'drawing.fountainPen' => 'Ручка',
			'drawing.marker' => 'Маркер',
			'drawing.neon' => 'Неон',
			'paper.plain' => 'Простой',
			'paper.lined' => 'В линейку',
			'paper.grid' => 'В клетку',
			'paper.dotted' => 'В точку',
			'ai.title' => 'AI Функции',
			'ai.assistant' => 'AI Ассистент',
			'ai.recognize' => 'Распознать текст',
			'ai.recognizing' => 'Распознавание...',
			'ai.summarize' => 'Подвести итоги',
			'ai.extractTasks' => 'Извлечение задач',
			'ai.translate' => 'Перевести',
			'ai.noTextFound' => 'Текст не найден',
			'ai.persona' => 'Персона AI-ассистента',
			'ai.personaSubtitle' => 'Выбрать стиль ассистента',
			'pdf.import' => 'Импортировать PDF',
			'pdf.importSubtitle' => 'Текст будет автоматически извлечен',
			'pdf.export' => 'Экспорт в PDF',
			'pdf.exporting' => 'Создание PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Ошибка экспорта PDF: ${error}',
			'pdf.page' => 'Страница',
			'pdf.of' => 'из',
			'settings.title' => 'Настройки',
			'settings.general' => 'Общие',
			'settings.theme' => 'Тема',
			'settings.themeSubtitle' => 'Светлая · Тёмная · Системная',
			'settings.darkMode' => 'Темный режим',
			'settings.lightMode' => 'Светлый режим',
			'settings.systemMode' => 'Системный режим',
			'settings.language' => 'Язык',
			'settings.languageSubtitle' => 'Русский (бета)',
			'settings.sync' => 'Синхронизация',
			'settings.syncEnabled' => 'Синхронизация включена',
			'settings.syncDisabled' => 'Синхронизация выключена',
			'settings.account' => 'Аккаунт',
			'settings.about' => 'О приложении',
			'settings.version' => 'Версия',
			'settings.privacy' => 'Конфиденциальность',
			'settings.terms' => 'Условия использования',
			'settings.input' => 'Ввод',
			'settings.inputDevices' => 'Устройства ввода',
			'settings.inputDeviceSubtitle' => 'Ручка · Сенсор · Мышь',
			'settings.automation' => 'Автоматизация',
			'settings.unlockPen' => 'Разблокировать ручку',
			'settings.pen' => 'Ручка',
			'settings.touch' => 'Тач',
			'settings.mouse' => 'Мышь',
			'settings.autoLockOnStylus' => 'Автоматическая блокировка на стилусе',
			'settings.editorSettings' => 'Настройки редактора',
			'settings.noteEditor' => 'Редактор заметок',
			'settings.noteEditorSubtitle' => 'Боковая панель слева · справа',
			'settings.strokeWidths' => 'Толщина линий',
			'settings.strokeWidthsSubtitle' => 'Тонкий · Средний · Толстый',
			'settings.palmRejection' => 'Обнаружение ладони',
			'settings.palmRejectionSubtitle' => 'Предотвращает случайные вводы',
			'settings.assistPanel' => 'Панель помощи',
			'settings.leftRightHanded' => 'Левая · Правая рука',
			'settings.rightLeftHanded' => 'Правая · Левая рука',
			'settings.drawingArea' => 'Область рисования',
			'settings.debugMode' => 'Включить режим отладки',
			'settings.cloud' => 'Облако и синхронизация',
			'settings.storageTarget' => 'Цель хранения',
			'settings.storageSubtitle' => 'Inkpadu Cloud (бесплатно)',
			'settings.encryption' => 'Шифрование',
			'settings.encryptionSubtitle' => 'Шифрование от конца до конца активно',
			'errors.networkError' => 'Ошибка сети. Проверьте подключение.',
			'errors.unknownError' => 'Произошла неизвестная ошибка.',
			'errors.authError' => 'Ошибка входа. Пожалуйста, попробуйте снова.',
			'errors.saveError' => 'Не удалось сохранить.',
			'errors.loadError' => 'Не удалось загрузить.',
			'errors.exportError' => 'Не удалось экспортировать.',
			'errors.loginFailed' => ({required Object provider}) => 'Ошибка входа (${provider})',
			'onboarding.welcome' => 'Добро пожаловать в Inkpadu',
			'onboarding.description' => 'Набрасывай идеи, записывай заметки и организуй свои мысли с помощью естественного почерка.',
			'onboarding.digitalNotebook' => 'Твой цифровой блокнот',
			'onboarding.digitalNotebookDescription' => 'Опыт рукописного ввода, оптимизированный для креативности и концентрации — совершенно без отвлечений.',
			'onboarding.connecting' => 'Подключаюсь…',
			'onboarding.loginWithGitHub' => 'Войти через GitHub',
			'onboarding.loginWithGoogle' => 'Войти через Google',
			'editor.newNote' => 'Новая заметка',
			'editor.editNote' => 'Редактировать заметку',
			'editor.title' => 'Заголовок',
			'editor.writeNote' => 'Напиши свою заметку...',
			'editor.assistPanel' => 'Панель помощи',
			'editor.leftRightHanded' => 'Левша · Правша',
			'editor.rightLeftHanded' => 'Правша · Левша',
			'editor.handednessHint' => 'Правшам удобнее использовать инструменты, когда панель слева. Левшам лучше выбрать правую сторону.',
			'editor.drawingArea' => 'Область рисования',
			'editor.enableDebugMode' => 'Включить режим отладки',
			'editor.debugModeHint' => 'Показать рамки и конвексные оболочки в редакторе и AI ассистенте.',
			'editor.useLineSimplifier' => 'Использовать упрощение линий',
			'editor.lineSimplifierHint' => 'Автоматически сглаживает твои линии для получения ровных линий.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Интенсивность сглаживания (${value})',
			'editor.smoothingHint' => 'Низкие значения сохраняют больше деталей, высокие значения более гладкие.',
			'editor.minTolerance' => ({required Object value}) => 'Минимальная толерантность (${value} px)',
			'editor.minToleranceHint' => 'Устанавливает нижнюю границу для сглаживания — более высокие значения фильтруют мелкие зубцы.',
			'editor.aiPersona' => 'Персона AI Ассистента',
			'editor.choosePersonaStyle' => 'Выбери стиль своего AI ассистента',
			'editor.personaStyleHint' => 'Персона определяет, как ассистент общается с тобой.',
			'editor.strictTrainer' => 'Строгий тренер',
			'editor.strictTrainerHint' => 'Прямые, жесткие критики как у русского олимпийского тренера',
			'editor.encouragingMentor' => 'Вдохновляющий наставник',
			'editor.encouragingMentorHint' => 'Позитивная обратная связь и мотивирующие комментарии',
			'editor.customPersona' => 'Пользовательский',
			'editor.customPersonaHint' => 'Установите свой собственный системный промт',
			'editor.yourSystemPrompt' => 'Твой системный промт',
			'editor.systemPromptPlaceholder' => 'Опиши, как должен вести себя ассистент...',
			'editor.systemPromptHint' => 'Системный промт определяет личность и поведение ассистента при всех запросах.',
			'editor.currentStyle' => 'Текущий стиль',
			'editor.strictTrainerDescription' => 'Ассистент дает жесткую и прямую обратную связь. Он не принимает посредственности и мотивирует тебя к достижению высот через конструктивную критику.',
			'editor.encouragingMentorDescription' => 'Ассистент хвалит твои достижения и дает вдохновляющую обратную связь. Ошибки рассматриваются как возможности для обучения.',
			'editor.customPersonaDescription' => 'Ассистент ведет себя согласно твоему собственному системному промту.',
			'pdfDialog.selectPdf' => 'Выбрать PDF',
			'pdfDialog.analyzePdf' => 'Анализировать PDF',
			'pdfDialog.ready' => 'Готово',
			'pdfDialog.processPdf' => 'Обработать PDF',
			'pdfDialog.importComplete' => 'Импорт завершен',
			'pdfDialog.selectPdfFile' => 'Пожалуйста, выберите файл PDF...',
			'pdfDialog.analyzingPdf' => 'Анализирую PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} страница(ы) найдена(ы)',
			'pdfDialog.textExtractionBackground' => 'Извлечение текста выполняется в фоновом режиме.',
			'pdfDialog.couldNotReadPdf' => 'Не удалось прочитать PDF-файл.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} страница(ы) импортирована(ы)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k символов извлечено',
			'pdfDialog.extractedTextContext' => 'Извлеченный текст используется в качестве контекста для AI ассистента.',
			'pdfDialog.textExtractionDuration' => 'Извлечение текста может занять несколько секунд на страницу.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Рендеринг страницы ${current} из ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Извлекаю текст со страницы ${current} из ${total}...',
			'pdfDialog.recognizingTasks' => 'Распознаю задачи...',
			_ => null,
		};
	}
}
