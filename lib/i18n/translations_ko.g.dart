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
class TranslationsKo extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKo _root = this; // ignore: unused_field

	@override 
	TranslationsKo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppKo app = _TranslationsAppKo._(_root);
	@override late final _TranslationsCommonKo common = _TranslationsCommonKo._(_root);
	@override late final _TranslationsAuthKo auth = _TranslationsAuthKo._(_root);
	@override late final _TranslationsNavKo nav = _TranslationsNavKo._(_root);
	@override late final _TranslationsNotesKo notes = _TranslationsNotesKo._(_root);
	@override late final _TranslationsDrawingKo drawing = _TranslationsDrawingKo._(_root);
	@override late final _TranslationsPaperKo paper = _TranslationsPaperKo._(_root);
	@override late final _TranslationsAiKo ai = _TranslationsAiKo._(_root);
	@override late final _TranslationsPdfKo pdf = _TranslationsPdfKo._(_root);
	@override late final _TranslationsSettingsKo settings = _TranslationsSettingsKo._(_root);
	@override late final _TranslationsErrorsKo errors = _TranslationsErrorsKo._(_root);
	@override late final _TranslationsOnboardingKo onboarding = _TranslationsOnboardingKo._(_root);
	@override late final _TranslationsEditorKo editor = _TranslationsEditorKo._(_root);
	@override late final _TranslationsPdfDialogKo pdfDialog = _TranslationsPdfDialogKo._(_root);
}

// Path: app
class _TranslationsAppKo extends TranslationsAppDe {
	_TranslationsAppKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '잉크파두';
	@override String get tagline => '너의 노트, 너의 방식';
}

// Path: common
class _TranslationsCommonKo extends TranslationsCommonDe {
	_TranslationsCommonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get save => '저장';
	@override String get cancel => '취소';
	@override String get delete => '삭제';
	@override String get edit => '편집';
	@override String get close => '닫기';
	@override String get confirm => '확인';
	@override String get loading => '로딩 중...';
	@override String get error => '오류';
	@override String get success => '성공';
	@override String get retry => '다시 시도';
	@override String get search => '검색';
	@override String get settings => '설정';
	@override String get back => '뒤로';
	@override String get next => '다음';
	@override String get done => '완료';
	@override String get yes => '예';
	@override String get no => '아니요';
	@override String get apply => '적용';
	@override String get loggedOut => '로그아웃되었습니다';
	@override String get justNow => '방금';
	@override String minutesAgo({required Object count}) => '${count} 분 전';
	@override String hoursAgo({required Object count}) => '${count} 시간 전';
	@override String get yesterday => '어제';
}

// Path: auth
class _TranslationsAuthKo extends TranslationsAuthDe {
	_TranslationsAuthKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get login => '로그인';
	@override String get logout => '로그아웃';
	@override String get register => '회원가입';
	@override String get email => '이메일';
	@override String get password => '비밀번호';
	@override String get forgotPassword => '비밀번호를 잊으셨나요?';
	@override String get welcomeBack => '다시 오신 것을 환영합니다!';
	@override String get createAccount => '계정 만들기';
	@override String get loginWithGoogle => '구글로 로그인';
	@override String get loginWithApple => '애플로 로그인';
}

// Path: nav
class _TranslationsNavKo extends TranslationsNavDe {
	_TranslationsNavKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get notes => '노트';
	@override String get settings => '설정';
}

// Path: notes
class _TranslationsNotesKo extends TranslationsNotesDe {
	_TranslationsNotesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '노트';
	@override String get newNote => '새 노트';
	@override String get untitled => '제목 없음';
	@override String get unnamed => '이름 없는 노트';
	@override String get noContent => '내용이 없습니다';
	@override String get noteDate => '노트';
	@override String get lastEdited => '마지막 수정';
	@override String get deleteNote => '노트 삭제';
	@override String deleteNoteConfirm({required Object title}) => '"${title}"을(를) 정말로 삭제하시겠습니까?';
	@override String get deleteNoteTooltip => '노트 삭제';
	@override String get noNotes => '손으로 쓴 노트가 없습니다';
	@override String get createFirst => '첫 번째 노트를 작성하세요';
	@override String get createNew => '새 노트 만들기';
	@override String get export => '내보내기';
	@override String get share => '공유';
	@override String get duplicate => '복제';
	@override String get openNote => '노트 열기';
	@override String get adjustTitlePaper => '제목 및 용지 조정';
	@override String get emptyNote => '빈 노트';
	@override String get emptyNoteSubtitle => '빈 페이지로 시작하세요';
}

// Path: drawing
class _TranslationsDrawingKo extends TranslationsDrawingDe {
	_TranslationsDrawingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pen => '펜';
	@override String get pencil => '연필';
	@override String get highlighter => '형광펜';
	@override String get eraser => '지우개';
	@override String get select => '선택';
	@override String get lasso => '올가미';
	@override String get undo => '실행 취소';
	@override String get redo => '다시 실행';
	@override String get clear => '지우기';
	@override String get clearConfirm => '모든 그림을 지우시겠습니까?';
	@override String get color => '색상';
	@override String get colorWheel => '색상 휠';
	@override String get symbol => '기호';
	@override String get strokeWidth => '선 굵기';
	@override String get zoomIn => '확대';
	@override String get zoomOut => '축소';
	@override String get markerMode => '마커 모드 (반투명)';
	@override String get pressureDetection => '압력 감지';
	@override String customizeTool({required Object name}) => '${name} 사용자 정의';
	@override String get fineliner => '세밀한 펜';
	@override String get inkRoller => '잉크 롤러';
	@override String get fountainPen => '만년필';
	@override String get marker => '마커';
	@override String get neon => '네온';
}

// Path: paper
class _TranslationsPaperKo extends TranslationsPaperDe {
	_TranslationsPaperKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get plain => '무지';
	@override String get lined => '줄무늬';
	@override String get grid => '격자무늬';
	@override String get dotted => '점선';
}

// Path: ai
class _TranslationsAiKo extends TranslationsAiDe {
	_TranslationsAiKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 기능';
	@override String get assistant => 'AI 어시스턴트';
	@override String get recognize => '텍스트 인식';
	@override String get recognizing => '인식 중...';
	@override String get summarize => '요약하기';
	@override String get extractTasks => '작업 추출';
	@override String get translate => '번역하기';
	@override String get noTextFound => '텍스트를 찾을 수 없습니다';
	@override String get helpMe => '도와줘';
	@override String get helpMeTitle => 'AI 답변';
	@override String get analyzingSelection => '선택 영역 분석 중…';
	@override String get noSelection => '먼저 올가미로 무언가를 선택해 주세요.';
	@override String get helpMeNotConfigured => 'AI가 아직 설정되지 않았습니다.';
	@override String get persona => 'AI 어시스턴트 페르소나';
	@override String get personaSubtitle => '어시스턴트 스타일 선택';
}

// Path: pdf
class _TranslationsPdfKo extends TranslationsPdfDe {
	_TranslationsPdfKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get import => 'PDF 가져오기';
	@override String get importSubtitle => '텍스트가 자동으로 추출됩니다';
	@override String get export => 'PDF로 내보내기';
	@override String get exporting => 'PDF 생성 중...';
	@override String exportFailed({required Object error}) => 'PDF 내보내기 실패: ${error}';
	@override String get page => '페이지';
	@override String get of => '의';
}

// Path: settings
class _TranslationsSettingsKo extends TranslationsSettingsDe {
	_TranslationsSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '설정';
	@override String get general => '일반';
	@override String get theme => '테마';
	@override String get themeSubtitle => '밝은 · 어두운 · 시스템';
	@override String get darkMode => '어두운 모드';
	@override String get lightMode => '밝은 모드';
	@override String get systemMode => '시스템 기본';
	@override String get language => '언어';
	@override String get languageSubtitle => '독일어 (베타)';
	@override String get sync => '동기화';
	@override String get syncEnabled => '동기화 활성화됨';
	@override String get syncDisabled => '동기화 비활성화됨';
	@override String get account => '계정';
	@override String get about => '정보';
	@override String get version => '버전';
	@override String get privacy => '개인정보 보호';
	@override String get terms => '이용 약관';
	@override String get input => '입력';
	@override String get inputDevices => '입력 장치';
	@override String get inputDeviceSubtitle => '펜 · 터치 · 마우스';
	@override String get automation => '자동화';
	@override String get unlockPen => '펜 잠금 해제';
	@override String get pen => '펜';
	@override String get touch => '터치';
	@override String get mouse => '마우스';
	@override String get autoLockOnStylus => '스타일러스 자동 잠금';
	@override String get editorSettings => '편집기 설정';
	@override String get noteEditor => '노트 편집기';
	@override String get noteEditorSubtitle => '왼쪽 · 오른쪽 페이지 패널';
	@override String get strokeWidths => '펜 두께';
	@override String get strokeWidthsSubtitle => '얇은 · 중간 · 두꺼운';
	@override String get palmRejection => '손바닥 인식';
	@override String get palmRejectionSubtitle => '원하지 않는 입력을 방지';
	@override String get assistPanel => '지원 패널';
	@override String get leftRightHanded => '왼손 · 오른손';
	@override String get rightLeftHanded => '오른손 · 왼손';
	@override String get drawingArea => '그리기 영역';
	@override String get debugMode => '디버그 모드 활성화';
	@override String get cloud => '클라우드 및 동기화';
	@override String get storageTarget => '저장 위치';
	@override String get storageSubtitle => 'Inkpadu 클라우드 (무료)';
	@override String get encryption => '암호화';
	@override String get encryptionSubtitle => '종단 간 활성화';
}

// Path: errors
class _TranslationsErrorsKo extends TranslationsErrorsDe {
	_TranslationsErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get networkError => '네트워크 오류. 연결을 확인하세요.';
	@override String get unknownError => '알 수 없는 오류가 발생했습니다.';
	@override String get authError => '로그인 오류. 다시 시도하세요.';
	@override String get saveError => '저장 실패.';
	@override String get loadError => '로드 실패.';
	@override String get exportError => '내보내기 실패.';
	@override String loginFailed({required Object provider}) => '${provider} 로그인 실패';
}

// Path: onboarding
class _TranslationsOnboardingKo extends TranslationsOnboardingDe {
	_TranslationsOnboardingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Inkpadu에 오신 것을 환영합니다';
	@override String get description => '자연스러운 손글씨로 아이디어를 스케치하고, 노트를 쓰며, 생각을 정리하세요.';
	@override String get digitalNotebook => '당신의 디지털 노트북';
	@override String get digitalNotebookDescription => '창의성과 집중력을 위해 최적화된 손글씨 경험 – 방해 없이.';
	@override String get connecting => '연결 중...';
	@override String get loginWithGitHub => 'GitHub로 로그인';
	@override String get loginWithGoogle => 'Google로 로그인';
}

// Path: editor
class _TranslationsEditorKo extends TranslationsEditorDe {
	_TranslationsEditorKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get newNote => '새 노트';
	@override String get editNote => '노트 편집';
	@override String get title => '제목';
	@override String get writeNote => '노트를 작성하세요...';
	@override String get assistPanel => '지원 패널';
	@override String get leftRightHanded => '왼손 · 오른손 잡이';
	@override String get rightLeftHanded => '오른손 · 왼손 잡이';
	@override String get handednessHint => '오른손잡이는 패널이 왼쪽에 있을 때 도구에 더 쉽게 접근합니다. 왼손잡이는 오른쪽을 선택하세요.';
	@override String get drawingArea => '그리기 영역';
	@override String get enableDebugMode => '디버그 모드 활성화';
	@override String get debugModeHint => '편집기와 AI 어시스턴트에서 경계 상자와 볼록 외형을 표시합니다.';
	@override String get useLineSimplifier => '선 단순화 도구 사용';
	@override String get lineSimplifierHint => '자동으로 선을 부드럽게 하여 매끈한 선을 얻습니다.';
	@override String smoothingIntensity({required Object value}) => '부드럽게 하기 강도 (${value})';
	@override String get smoothingHint => '낮은 값은 세부 사항을 더 보존하고, 높은 값은 더 많이 부드럽게 합니다.';
	@override String minTolerance({required Object value}) => '최소 허용 오차 (${value} px)';
	@override String get minToleranceHint => '부드럽게 하기를 위한 하한값 설정 – 높은 값은 미세한 톱니를 필터링합니다.';
	@override String get aiPersona => 'AI 어시스턴트 페르소나';
	@override String get choosePersonaStyle => 'AI 어시스턴트 스타일 선택';
	@override String get personaStyleHint => '페르소나는 어시스턴트가 당신과 상호작용하는 방식을 결정합니다.';
	@override String get strictTrainer => '엄격한 트레이너';
	@override String get strictTrainerHint => '러시아 올림픽 코치처럼 직접적이고 강한 피드백';
	@override String get encouragingMentor => '격려하는 멘토';
	@override String get encouragingMentorHint => '긍정적인 강화와 동기 부여 피드백';
	@override String get customPersona => '사용자 정의';
	@override String get customPersonaHint => '자신만의 시스템 프롬프트 설정';
	@override String get yourSystemPrompt => '당신의 시스템 프롬프트';
	@override String get systemPromptPlaceholder => '어시스턴트가 어떻게 행동해야 하는지 설명하세요...';
	@override String get systemPromptHint => '시스템 프롬프트는 모든 요청에서 어시스턴트의 성격과 행동을 정의합니다.';
	@override String get currentStyle => '현재 스타일';
	@override String get strictTrainerDescription => '어시스턴트는 엄격하고 직접적인 피드백을 제공합니다. 타협을 허용하지 않으며, 건설적인 비판으로 최고 성과를 유도합니다.';
	@override String get encouragingMentorDescription => '어시스턴트는 당신의 진행 상황을 칭찬하고 격려하는 피드백을 제공합니다. 실수는 학습 기회로 간주됩니다.';
	@override String get customPersonaDescription => '어시스턴트는 당신의 시스템 프롬프트에 따라 행동합니다.';
}

// Path: pdfDialog
class _TranslationsPdfDialogKo extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'PDF 선택';
	@override String get analyzePdf => 'PDF 분석';
	@override String get ready => '준비 완료';
	@override String get processPdf => 'PDF 처리';
	@override String get importComplete => '가져오기 완료';
	@override String get selectPdfFile => 'PDF 파일을 선택하세요...';
	@override String get analyzingPdf => 'PDF 분석 중...';
	@override String pagesFound({required Object count}) => '${count} 페이지(들) 발견됨';
	@override String get textExtractionBackground => '텍스트 추출은 백그라운드에서 진행됩니다.';
	@override String get couldNotReadPdf => 'PDF 파일을 읽을 수 없습니다.';
	@override String pagesImported({required Object count}) => '${count} 페이지(들) 가져오기 완료';
	@override String charactersExtracted({required Object count}) => '~${count}k 문자 추출됨';
	@override String get extractedTextContext => '추출된 텍스트는 AI 어시스턴트를 위한 컨텍스트로 사용됩니다.';
	@override String get textExtractionDuration => '텍스트 추출에는 페이지당 몇 초가 소요될 수 있습니다.';
	@override String renderingPage({required Object total, required Object current}) => '${total}페이지 중 ${current} 페이지 렌더링 중...';
	@override String extractingPage({required Object total, required Object current}) => '${total}페이지 중 ${current} 페이지에서 텍스트 추출 중...';
	@override String get recognizingTasks => '작업 인식 중...';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => '잉크파두',
			'app.tagline' => '너의 노트, 너의 방식',
			'common.save' => '저장',
			'common.cancel' => '취소',
			'common.delete' => '삭제',
			'common.edit' => '편집',
			'common.close' => '닫기',
			'common.confirm' => '확인',
			'common.loading' => '로딩 중...',
			'common.error' => '오류',
			'common.success' => '성공',
			'common.retry' => '다시 시도',
			'common.search' => '검색',
			'common.settings' => '설정',
			'common.back' => '뒤로',
			'common.next' => '다음',
			'common.done' => '완료',
			'common.yes' => '예',
			'common.no' => '아니요',
			'common.apply' => '적용',
			'common.loggedOut' => '로그아웃되었습니다',
			'common.justNow' => '방금',
			'common.minutesAgo' => ({required Object count}) => '${count} 분 전',
			'common.hoursAgo' => ({required Object count}) => '${count} 시간 전',
			'common.yesterday' => '어제',
			'auth.login' => '로그인',
			'auth.logout' => '로그아웃',
			'auth.register' => '회원가입',
			'auth.email' => '이메일',
			'auth.password' => '비밀번호',
			'auth.forgotPassword' => '비밀번호를 잊으셨나요?',
			'auth.welcomeBack' => '다시 오신 것을 환영합니다!',
			'auth.createAccount' => '계정 만들기',
			'auth.loginWithGoogle' => '구글로 로그인',
			'auth.loginWithApple' => '애플로 로그인',
			'nav.notes' => '노트',
			'nav.settings' => '설정',
			'notes.title' => '노트',
			'notes.newNote' => '새 노트',
			'notes.untitled' => '제목 없음',
			'notes.unnamed' => '이름 없는 노트',
			'notes.noContent' => '내용이 없습니다',
			'notes.noteDate' => '노트',
			'notes.lastEdited' => '마지막 수정',
			'notes.deleteNote' => '노트 삭제',
			'notes.deleteNoteConfirm' => ({required Object title}) => '"${title}"을(를) 정말로 삭제하시겠습니까?',
			'notes.deleteNoteTooltip' => '노트 삭제',
			'notes.noNotes' => '손으로 쓴 노트가 없습니다',
			'notes.createFirst' => '첫 번째 노트를 작성하세요',
			'notes.createNew' => '새 노트 만들기',
			'notes.export' => '내보내기',
			'notes.share' => '공유',
			'notes.duplicate' => '복제',
			'notes.openNote' => '노트 열기',
			'notes.adjustTitlePaper' => '제목 및 용지 조정',
			'notes.emptyNote' => '빈 노트',
			'notes.emptyNoteSubtitle' => '빈 페이지로 시작하세요',
			'drawing.pen' => '펜',
			'drawing.pencil' => '연필',
			'drawing.highlighter' => '형광펜',
			'drawing.eraser' => '지우개',
			'drawing.select' => '선택',
			'drawing.lasso' => '올가미',
			'drawing.undo' => '실행 취소',
			'drawing.redo' => '다시 실행',
			'drawing.clear' => '지우기',
			'drawing.clearConfirm' => '모든 그림을 지우시겠습니까?',
			'drawing.color' => '색상',
			'drawing.colorWheel' => '색상 휠',
			'drawing.symbol' => '기호',
			'drawing.strokeWidth' => '선 굵기',
			'drawing.zoomIn' => '확대',
			'drawing.zoomOut' => '축소',
			'drawing.markerMode' => '마커 모드 (반투명)',
			'drawing.pressureDetection' => '압력 감지',
			'drawing.customizeTool' => ({required Object name}) => '${name} 사용자 정의',
			'drawing.fineliner' => '세밀한 펜',
			'drawing.inkRoller' => '잉크 롤러',
			'drawing.fountainPen' => '만년필',
			'drawing.marker' => '마커',
			'drawing.neon' => '네온',
			'paper.plain' => '무지',
			'paper.lined' => '줄무늬',
			'paper.grid' => '격자무늬',
			'paper.dotted' => '점선',
			'ai.title' => 'AI 기능',
			'ai.assistant' => 'AI 어시스턴트',
			'ai.recognize' => '텍스트 인식',
			'ai.recognizing' => '인식 중...',
			'ai.summarize' => '요약하기',
			'ai.extractTasks' => '작업 추출',
			'ai.translate' => '번역하기',
			'ai.noTextFound' => '텍스트를 찾을 수 없습니다',
			'ai.helpMe' => '도와줘',
			'ai.helpMeTitle' => 'AI 답변',
			'ai.analyzingSelection' => '선택 영역 분석 중…',
			'ai.noSelection' => '먼저 올가미로 무언가를 선택해 주세요.',
			'ai.helpMeNotConfigured' => 'AI가 아직 설정되지 않았습니다.',
			'ai.persona' => 'AI 어시스턴트 페르소나',
			'ai.personaSubtitle' => '어시스턴트 스타일 선택',
			'pdf.import' => 'PDF 가져오기',
			'pdf.importSubtitle' => '텍스트가 자동으로 추출됩니다',
			'pdf.export' => 'PDF로 내보내기',
			'pdf.exporting' => 'PDF 생성 중...',
			'pdf.exportFailed' => ({required Object error}) => 'PDF 내보내기 실패: ${error}',
			'pdf.page' => '페이지',
			'pdf.of' => '의',
			'settings.title' => '설정',
			'settings.general' => '일반',
			'settings.theme' => '테마',
			'settings.themeSubtitle' => '밝은 · 어두운 · 시스템',
			'settings.darkMode' => '어두운 모드',
			'settings.lightMode' => '밝은 모드',
			'settings.systemMode' => '시스템 기본',
			'settings.language' => '언어',
			'settings.languageSubtitle' => '독일어 (베타)',
			'settings.sync' => '동기화',
			'settings.syncEnabled' => '동기화 활성화됨',
			'settings.syncDisabled' => '동기화 비활성화됨',
			'settings.account' => '계정',
			'settings.about' => '정보',
			'settings.version' => '버전',
			'settings.privacy' => '개인정보 보호',
			'settings.terms' => '이용 약관',
			'settings.input' => '입력',
			'settings.inputDevices' => '입력 장치',
			'settings.inputDeviceSubtitle' => '펜 · 터치 · 마우스',
			'settings.automation' => '자동화',
			'settings.unlockPen' => '펜 잠금 해제',
			'settings.pen' => '펜',
			'settings.touch' => '터치',
			'settings.mouse' => '마우스',
			'settings.autoLockOnStylus' => '스타일러스 자동 잠금',
			'settings.editorSettings' => '편집기 설정',
			'settings.noteEditor' => '노트 편집기',
			'settings.noteEditorSubtitle' => '왼쪽 · 오른쪽 페이지 패널',
			'settings.strokeWidths' => '펜 두께',
			'settings.strokeWidthsSubtitle' => '얇은 · 중간 · 두꺼운',
			'settings.palmRejection' => '손바닥 인식',
			'settings.palmRejectionSubtitle' => '원하지 않는 입력을 방지',
			'settings.assistPanel' => '지원 패널',
			'settings.leftRightHanded' => '왼손 · 오른손',
			'settings.rightLeftHanded' => '오른손 · 왼손',
			'settings.drawingArea' => '그리기 영역',
			'settings.debugMode' => '디버그 모드 활성화',
			'settings.cloud' => '클라우드 및 동기화',
			'settings.storageTarget' => '저장 위치',
			'settings.storageSubtitle' => 'Inkpadu 클라우드 (무료)',
			'settings.encryption' => '암호화',
			'settings.encryptionSubtitle' => '종단 간 활성화',
			'errors.networkError' => '네트워크 오류. 연결을 확인하세요.',
			'errors.unknownError' => '알 수 없는 오류가 발생했습니다.',
			'errors.authError' => '로그인 오류. 다시 시도하세요.',
			'errors.saveError' => '저장 실패.',
			'errors.loadError' => '로드 실패.',
			'errors.exportError' => '내보내기 실패.',
			'errors.loginFailed' => ({required Object provider}) => '${provider} 로그인 실패',
			'onboarding.welcome' => 'Inkpadu에 오신 것을 환영합니다',
			'onboarding.description' => '자연스러운 손글씨로 아이디어를 스케치하고, 노트를 쓰며, 생각을 정리하세요.',
			'onboarding.digitalNotebook' => '당신의 디지털 노트북',
			'onboarding.digitalNotebookDescription' => '창의성과 집중력을 위해 최적화된 손글씨 경험 – 방해 없이.',
			'onboarding.connecting' => '연결 중...',
			'onboarding.loginWithGitHub' => 'GitHub로 로그인',
			'onboarding.loginWithGoogle' => 'Google로 로그인',
			'editor.newNote' => '새 노트',
			'editor.editNote' => '노트 편집',
			'editor.title' => '제목',
			'editor.writeNote' => '노트를 작성하세요...',
			'editor.assistPanel' => '지원 패널',
			'editor.leftRightHanded' => '왼손 · 오른손 잡이',
			'editor.rightLeftHanded' => '오른손 · 왼손 잡이',
			'editor.handednessHint' => '오른손잡이는 패널이 왼쪽에 있을 때 도구에 더 쉽게 접근합니다. 왼손잡이는 오른쪽을 선택하세요.',
			'editor.drawingArea' => '그리기 영역',
			'editor.enableDebugMode' => '디버그 모드 활성화',
			'editor.debugModeHint' => '편집기와 AI 어시스턴트에서 경계 상자와 볼록 외형을 표시합니다.',
			'editor.useLineSimplifier' => '선 단순화 도구 사용',
			'editor.lineSimplifierHint' => '자동으로 선을 부드럽게 하여 매끈한 선을 얻습니다.',
			'editor.smoothingIntensity' => ({required Object value}) => '부드럽게 하기 강도 (${value})',
			'editor.smoothingHint' => '낮은 값은 세부 사항을 더 보존하고, 높은 값은 더 많이 부드럽게 합니다.',
			'editor.minTolerance' => ({required Object value}) => '최소 허용 오차 (${value} px)',
			'editor.minToleranceHint' => '부드럽게 하기를 위한 하한값 설정 – 높은 값은 미세한 톱니를 필터링합니다.',
			'editor.aiPersona' => 'AI 어시스턴트 페르소나',
			'editor.choosePersonaStyle' => 'AI 어시스턴트 스타일 선택',
			'editor.personaStyleHint' => '페르소나는 어시스턴트가 당신과 상호작용하는 방식을 결정합니다.',
			'editor.strictTrainer' => '엄격한 트레이너',
			'editor.strictTrainerHint' => '러시아 올림픽 코치처럼 직접적이고 강한 피드백',
			'editor.encouragingMentor' => '격려하는 멘토',
			'editor.encouragingMentorHint' => '긍정적인 강화와 동기 부여 피드백',
			'editor.customPersona' => '사용자 정의',
			'editor.customPersonaHint' => '자신만의 시스템 프롬프트 설정',
			'editor.yourSystemPrompt' => '당신의 시스템 프롬프트',
			'editor.systemPromptPlaceholder' => '어시스턴트가 어떻게 행동해야 하는지 설명하세요...',
			'editor.systemPromptHint' => '시스템 프롬프트는 모든 요청에서 어시스턴트의 성격과 행동을 정의합니다.',
			'editor.currentStyle' => '현재 스타일',
			'editor.strictTrainerDescription' => '어시스턴트는 엄격하고 직접적인 피드백을 제공합니다. 타협을 허용하지 않으며, 건설적인 비판으로 최고 성과를 유도합니다.',
			'editor.encouragingMentorDescription' => '어시스턴트는 당신의 진행 상황을 칭찬하고 격려하는 피드백을 제공합니다. 실수는 학습 기회로 간주됩니다.',
			'editor.customPersonaDescription' => '어시스턴트는 당신의 시스템 프롬프트에 따라 행동합니다.',
			'pdfDialog.selectPdf' => 'PDF 선택',
			'pdfDialog.analyzePdf' => 'PDF 분석',
			'pdfDialog.ready' => '준비 완료',
			'pdfDialog.processPdf' => 'PDF 처리',
			'pdfDialog.importComplete' => '가져오기 완료',
			'pdfDialog.selectPdfFile' => 'PDF 파일을 선택하세요...',
			'pdfDialog.analyzingPdf' => 'PDF 분석 중...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} 페이지(들) 발견됨',
			'pdfDialog.textExtractionBackground' => '텍스트 추출은 백그라운드에서 진행됩니다.',
			'pdfDialog.couldNotReadPdf' => 'PDF 파일을 읽을 수 없습니다.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} 페이지(들) 가져오기 완료',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k 문자 추출됨',
			'pdfDialog.extractedTextContext' => '추출된 텍스트는 AI 어시스턴트를 위한 컨텍스트로 사용됩니다.',
			'pdfDialog.textExtractionDuration' => '텍스트 추출에는 페이지당 몇 초가 소요될 수 있습니다.',
			'pdfDialog.renderingPage' => ({required Object total, required Object current}) => '${total}페이지 중 ${current} 페이지 렌더링 중...',
			'pdfDialog.extractingPage' => ({required Object total, required Object current}) => '${total}페이지 중 ${current} 페이지에서 텍스트 추출 중...',
			'pdfDialog.recognizingTasks' => '작업 인식 중...',
			_ => null,
		};
	}
}
