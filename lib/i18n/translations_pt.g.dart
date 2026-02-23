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
class TranslationsPt extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsPt({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.pt,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <pt>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsPt _root = this; // ignore: unused_field

	@override 
	TranslationsPt $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsPt(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsAppPt app = _TranslationsAppPt._(_root);
	@override late final _TranslationsCommonPt common = _TranslationsCommonPt._(_root);
	@override late final _TranslationsAuthPt auth = _TranslationsAuthPt._(_root);
	@override late final _TranslationsNavPt nav = _TranslationsNavPt._(_root);
	@override late final _TranslationsNotesPt notes = _TranslationsNotesPt._(_root);
	@override late final _TranslationsDrawingPt drawing = _TranslationsDrawingPt._(_root);
	@override late final _TranslationsPaperPt paper = _TranslationsPaperPt._(_root);
	@override late final _TranslationsAiPt ai = _TranslationsAiPt._(_root);
	@override late final _TranslationsPdfPt pdf = _TranslationsPdfPt._(_root);
	@override late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	@override late final _TranslationsErrorsPt errors = _TranslationsErrorsPt._(_root);
	@override late final _TranslationsOnboardingPt onboarding = _TranslationsOnboardingPt._(_root);
	@override late final _TranslationsEditorPt editor = _TranslationsEditorPt._(_root);
	@override late final _TranslationsPdfDialogPt pdfDialog = _TranslationsPdfDialogPt._(_root);
}

// Path: app
class _TranslationsAppPt extends TranslationsAppDe {
	_TranslationsAppPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get name => 'Inkpadu';
	@override String get tagline => 'Suas notas, do seu jeito';
}

// Path: common
class _TranslationsCommonPt extends TranslationsCommonDe {
	_TranslationsCommonPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get save => 'Salvar';
	@override String get cancel => 'Cancelar';
	@override String get delete => 'Excluir';
	@override String get edit => 'Editar';
	@override String get close => 'Fechar';
	@override String get confirm => 'Confirmar';
	@override String get loading => 'Carregando...';
	@override String get error => 'Erro';
	@override String get success => 'Sucesso';
	@override String get retry => 'Tentar novamente';
	@override String get search => 'Pesquisar';
	@override String get settings => 'Configurações';
	@override String get back => 'Voltar';
	@override String get next => 'Próximo';
	@override String get done => 'Concluído';
	@override String get yes => 'Sim';
	@override String get no => 'Não';
	@override String get apply => 'Aplicar';
	@override String get loggedOut => 'Desconectado';
	@override String get justNow => 'Agora mesmo';
	@override String minutesAgo({required Object count}) => 'há ${count} minuto(s)';
	@override String hoursAgo({required Object count}) => 'há ${count} hora(s)';
	@override String get yesterday => 'Ontem';
}

// Path: auth
class _TranslationsAuthPt extends TranslationsAuthDe {
	_TranslationsAuthPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get login => 'Entrar';
	@override String get logout => 'Sair';
	@override String get register => 'Registrar';
	@override String get email => 'E-mail';
	@override String get password => 'Senha';
	@override String get forgotPassword => 'Esqueceu a senha?';
	@override String get welcomeBack => 'Bem-vindo de volta!';
	@override String get createAccount => 'Criar conta';
	@override String get loginWithGoogle => 'Entrar com o Google';
	@override String get loginWithApple => 'Entrar com a Apple';
}

// Path: nav
class _TranslationsNavPt extends TranslationsNavDe {
	_TranslationsNavPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get notes => 'Notas';
	@override String get settings => 'Configurações';
}

// Path: notes
class _TranslationsNotesPt extends TranslationsNotesDe {
	_TranslationsNotesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notas';
	@override String get newNote => 'Nova nota';
	@override String get untitled => 'Sem título';
	@override String get unnamed => 'Nota sem nome';
	@override String get noContent => 'Sem conteúdo ainda';
	@override String get noteDate => 'Nota';
	@override String get lastEdited => 'Última edição';
	@override String get deleteNote => 'Excluir nota';
	@override String deleteNoteConfirm({required Object title}) => 'Você realmente deseja excluir "${title}"?';
	@override String get deleteNoteTooltip => 'Excluir nota';
	@override String get noNotes => 'Ainda não há notas manuscritas';
	@override String get createFirst => 'Crie sua primeira nota';
	@override String get createNew => 'Criar nova nota';
	@override String get export => 'Exportar';
	@override String get share => 'Compartilhar';
	@override String get duplicate => 'Duplicar';
	@override String get openNote => 'Abrir nota';
	@override String get adjustTitlePaper => 'Ajustar título e papel';
	@override String get emptyNote => 'Nota vazia';
	@override String get emptyNoteSubtitle => 'Comece com uma página em branco';
}

// Path: drawing
class _TranslationsDrawingPt extends TranslationsDrawingDe {
	_TranslationsDrawingPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get pen => 'Caneta';
	@override String get pencil => 'Lápis';
	@override String get highlighter => 'Marcador';
	@override String get eraser => 'Borracha';
	@override String get select => 'Selecionar';
	@override String get lasso => 'Laço';
	@override String get undo => 'Desfazer';
	@override String get redo => 'Refazer';
	@override String get clear => 'Limpar';
	@override String get clearConfirm => 'Deseja realmente apagar todos os desenhos?';
	@override String get color => 'Cor';
	@override String get colorWheel => 'Roda de cores';
	@override String get symbol => 'Símbolo';
	@override String get strokeWidth => 'Espessura do traço';
	@override String get zoomIn => 'Aumentar';
	@override String get zoomOut => 'Diminuir';
	@override String get markerMode => 'Modo marcador (translúcido)';
	@override String get pressureDetection => 'Detecção de pressão';
	@override String customizeTool({required Object name}) => 'Personalizar ${name}';
	@override String get fineliner => 'Caneta fina';
	@override String get inkRoller => 'Caneta roller';
	@override String get fountainPen => 'Caneta-tinteiro';
	@override String get marker => 'Marcador';
	@override String get neon => 'Neon';
}

// Path: paper
class _TranslationsPaperPt extends TranslationsPaperDe {
	_TranslationsPaperPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get plain => 'Em branco';
	@override String get lined => 'Linho';
	@override String get grid => 'Quadriculado';
	@override String get dotted => 'Pontilhado';
}

// Path: ai
class _TranslationsAiPt extends TranslationsAiDe {
	_TranslationsAiPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recursos de IA';
	@override String get assistant => 'Assistente de IA';
	@override String get recognize => 'Reconhecer texto';
	@override String get recognizing => 'Reconhecendo...';
	@override String get summarize => 'Resumir';
	@override String get extractTasks => 'Extrair tarefas';
	@override String get translate => 'Traduzir';
	@override String get noTextFound => 'Nenhum texto encontrado';
	@override String get helpMe => 'Ajude-me';
	@override String get helpMeTitle => 'Resposta da IA';
	@override String get analyzingSelection => 'Analisando seleção…';
	@override String get noSelection => 'Selecione algo com o laço primeiro.';
	@override String get helpMeNotConfigured => 'A IA ainda não está configurada.';
	@override String get persona => 'Persona do Assistente de IA';
	@override String get personaSubtitle => 'Escolher estilo do assistente';
}

// Path: pdf
class _TranslationsPdfPt extends TranslationsPdfDe {
	_TranslationsPdfPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get import => 'Importar PDF';
	@override String get importSubtitle => 'Texto será extraído automaticamente';
	@override String get export => 'Exportar como PDF';
	@override String get exporting => 'Criando PDF...';
	@override String exportFailed({required Object error}) => 'Falha ao exportar PDF: ${error}';
	@override String get page => 'Página';
	@override String get of => 'de';
}

// Path: settings
class _TranslationsSettingsPt extends TranslationsSettingsDe {
	_TranslationsSettingsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurações';
	@override String get general => 'Geral';
	@override String get theme => 'Tema';
	@override String get themeSubtitle => 'Clare · Escure · Sistema';
	@override String get darkMode => 'Modo escuro';
	@override String get lightMode => 'Modo claro';
	@override String get systemMode => 'Padrão do sistema';
	@override String get language => 'Idioma';
	@override String get languageSubtitle => 'Português (beta)';
	@override String get sync => 'Sincronização';
	@override String get syncEnabled => 'Sincronização ativada';
	@override String get syncDisabled => 'Sincronização desativada';
	@override String get account => 'Conta';
	@override String get about => 'Sobre';
	@override String get version => 'Versão';
	@override String get privacy => 'Privacidade';
	@override String get terms => 'Termos de uso';
	@override String get input => 'Entrada';
	@override String get inputDevices => 'Dispositivos de entrada';
	@override String get inputDeviceSubtitle => 'Caneta · Toque · Mouse';
	@override String get automation => 'Automação';
	@override String get unlockPen => 'Desbloquear caneta';
	@override String get pen => 'Caneta';
	@override String get touch => 'Toque';
	@override String get mouse => 'Mouse';
	@override String get autoLockOnStylus => 'Bloquear automaticamente ao usar a caneta';
	@override String get editorSettings => 'Configurações do editor';
	@override String get noteEditor => 'Editor de Notas';
	@override String get noteEditorSubtitle => 'Painel lateral esquerdo · direito';
	@override String get strokeWidths => 'Larguras da caneta';
	@override String get strokeWidthsSubtitle => 'Fina · Média · Grossa';
	@override String get palmRejection => 'Rejeição da palma';
	@override String get palmRejectionSubtitle => 'Evita entradas indesejadas';
	@override String get assistPanel => 'Painel de assistência';
	@override String get leftRightHanded => 'Canhoto · Destro';
	@override String get rightLeftHanded => 'Destro · Canhoto';
	@override String get drawingArea => 'Área de desenho';
	@override String get debugMode => 'Ativar modo de depuração';
	@override String get cloud => 'Nuvem & Sincronização';
	@override String get storageTarget => 'Destino de armazenamento';
	@override String get storageSubtitle => 'Nuvem Inkpadu (gratuita)';
	@override String get encryption => 'Criptografia';
	@override String get encryptionSubtitle => 'Ativação de ponta a ponta';
}

// Path: errors
class _TranslationsErrorsPt extends TranslationsErrorsDe {
	_TranslationsErrorsPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get networkError => 'Erro de rede. Verifique sua conexão.';
	@override String get unknownError => 'Ocorreu um erro desconhecido.';
	@override String get authError => 'Erro de autenticação. Por favor, tente novamente.';
	@override String get saveError => 'Falha ao salvar.';
	@override String get loadError => 'Falha ao carregar.';
	@override String get exportError => 'Falha ao exportar.';
	@override String loginFailed({required Object provider}) => 'Login (${provider}) falhou';
}

// Path: onboarding
class _TranslationsOnboardingPt extends TranslationsOnboardingDe {
	_TranslationsOnboardingPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Bem-vindo ao Inkpadu';
	@override String get description => 'Esboce ideias, escreva notas e organize seus pensamentos com escrita à mão natural.';
	@override String get digitalNotebook => 'Seu caderno digital';
	@override String get digitalNotebookDescription => 'Uma experiência manuscrita, otimizada para criatividade e foco – sem distrações.';
	@override String get connecting => 'Conectando...';
	@override String get loginWithGitHub => 'Entrar com GitHub';
	@override String get loginWithGoogle => 'Entrar com Google';
}

// Path: editor
class _TranslationsEditorPt extends TranslationsEditorDe {
	_TranslationsEditorPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get newNote => 'Nova Nota';
	@override String get editNote => 'Editar Nota';
	@override String get title => 'Título';
	@override String get writeNote => 'Escreva sua nota...';
	@override String get assistPanel => 'Painel de Assistência';
	@override String get leftRightHanded => 'Canhoto · Destro';
	@override String get rightLeftHanded => 'Destro · Canhoto';
	@override String get handednessHint => 'Direitos têm acesso mais fácil às ferramentas quando o painel está do lado esquerdo. Canhotos, por outro lado, escolhem o lado direito.';
	@override String get drawingArea => 'Área de desenho';
	@override String get enableDebugMode => 'Ativar modo de depuração';
	@override String get debugModeHint => 'Mostra caixas de delimitação e cascas convexas no editor e no assistente de IA.';
	@override String get useLineSimplifier => 'Usar simplificador de linhas';
	@override String get lineSimplifierHint => 'Suaviza seus traços automaticamente para obter linhas tranquilas.';
	@override String smoothingIntensity({required Object value}) => 'Intensidade de suavização (${value})';
	@override String get smoothingHint => 'Valores baixos preservam mais detalhes, valores altos suavizam mais.';
	@override String minTolerance({required Object value}) => 'Tolerância mínima (${value} px)';
	@override String get minToleranceHint => 'Define o limite inferior para suavização – valores mais altos filtram ondulações pequenas.';
	@override String get aiPersona => 'Persona do Assistente de IA';
	@override String get choosePersonaStyle => 'Escolha o estilo do seu Assistente de IA';
	@override String get personaStyleHint => 'A persona determina como o assistente se comunica com você.';
	@override String get strictTrainer => 'Treinador rigoroso';
	@override String get strictTrainerHint => 'Crítica direta e dura como um treinador olímpico russo';
	@override String get encouragingMentor => 'Mentor encorajador';
	@override String get encouragingMentorHint => 'Reforço positivo e feedback motivador';
	@override String get customPersona => 'Personalizado';
	@override String get customPersonaHint => 'Defina seu próprio prompt de sistema';
	@override String get yourSystemPrompt => 'Seu prompt de sistema';
	@override String get systemPromptPlaceholder => 'Descreva como o assistente deve se comportar...';
	@override String get systemPromptHint => 'O prompt de sistema define a personalidade e o comportamento do assistente em todas as solicitações.';
	@override String get currentStyle => 'Estilo atual';
	@override String get strictTrainerDescription => 'O assistente oferece feedback duro e direto. Ele não aceita mediocridade e motiva você com críticas construtivas a alcançar altos padrões.';
	@override String get encouragingMentorDescription => 'O assistente elogia seus progressos e fornece feedback encorajador. Erros são apresentados como oportunidades de aprendizado.';
	@override String get customPersonaDescription => 'O assistente se comporta de acordo com o seu próprio prompt de sistema.';
}

// Path: pdfDialog
class _TranslationsPdfDialogPt extends TranslationsPdfDialogDe {
	_TranslationsPdfDialogPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get selectPdf => 'Selecionar PDF';
	@override String get analyzePdf => 'Analisar PDF';
	@override String get ready => 'Pronto';
	@override String get processPdf => 'Processar PDF';
	@override String get importComplete => 'Importação concluída';
	@override String get selectPdfFile => 'Por favor, selecione um arquivo PDF...';
	@override String get analyzingPdf => 'Analisando PDF...';
	@override String pagesFound({required Object count}) => '${count} página(s) encontrada(s)';
	@override String get textExtractionBackground => 'Extração de texto em andamento em segundo plano.';
	@override String get couldNotReadPdf => 'Não foi possível ler o arquivo PDF.';
	@override String pagesImported({required Object count}) => '${count} página(s) importada(s)';
	@override String charactersExtracted({required Object count}) => '~${count}k caracteres extraídos';
	@override String get extractedTextContext => 'O texto extraído será usado como contexto para o assistente de IA.';
	@override String get textExtractionDuration => 'A extração de texto pode levar alguns segundos por página.';
	@override String renderingPage({required Object current, required Object total}) => 'Renderizando página ${current} de ${total}...';
	@override String extractingPage({required Object current, required Object total}) => 'Extraindo texto da página ${current} de ${total}...';
	@override String get recognizingTasks => 'Reconhecendo tarefas...';
}

/// The flat map containing all translations for locale <pt>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsPt {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'app.name' => 'Inkpadu',
			'app.tagline' => 'Suas notas, do seu jeito',
			'common.save' => 'Salvar',
			'common.cancel' => 'Cancelar',
			'common.delete' => 'Excluir',
			'common.edit' => 'Editar',
			'common.close' => 'Fechar',
			'common.confirm' => 'Confirmar',
			'common.loading' => 'Carregando...',
			'common.error' => 'Erro',
			'common.success' => 'Sucesso',
			'common.retry' => 'Tentar novamente',
			'common.search' => 'Pesquisar',
			'common.settings' => 'Configurações',
			'common.back' => 'Voltar',
			'common.next' => 'Próximo',
			'common.done' => 'Concluído',
			'common.yes' => 'Sim',
			'common.no' => 'Não',
			'common.apply' => 'Aplicar',
			'common.loggedOut' => 'Desconectado',
			'common.justNow' => 'Agora mesmo',
			'common.minutesAgo' => ({required Object count}) => 'há ${count} minuto(s)',
			'common.hoursAgo' => ({required Object count}) => 'há ${count} hora(s)',
			'common.yesterday' => 'Ontem',
			'auth.login' => 'Entrar',
			'auth.logout' => 'Sair',
			'auth.register' => 'Registrar',
			'auth.email' => 'E-mail',
			'auth.password' => 'Senha',
			'auth.forgotPassword' => 'Esqueceu a senha?',
			'auth.welcomeBack' => 'Bem-vindo de volta!',
			'auth.createAccount' => 'Criar conta',
			'auth.loginWithGoogle' => 'Entrar com o Google',
			'auth.loginWithApple' => 'Entrar com a Apple',
			'nav.notes' => 'Notas',
			'nav.settings' => 'Configurações',
			'notes.title' => 'Notas',
			'notes.newNote' => 'Nova nota',
			'notes.untitled' => 'Sem título',
			'notes.unnamed' => 'Nota sem nome',
			'notes.noContent' => 'Sem conteúdo ainda',
			'notes.noteDate' => 'Nota',
			'notes.lastEdited' => 'Última edição',
			'notes.deleteNote' => 'Excluir nota',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Você realmente deseja excluir "${title}"?',
			'notes.deleteNoteTooltip' => 'Excluir nota',
			'notes.noNotes' => 'Ainda não há notas manuscritas',
			'notes.createFirst' => 'Crie sua primeira nota',
			'notes.createNew' => 'Criar nova nota',
			'notes.export' => 'Exportar',
			'notes.share' => 'Compartilhar',
			'notes.duplicate' => 'Duplicar',
			'notes.openNote' => 'Abrir nota',
			'notes.adjustTitlePaper' => 'Ajustar título e papel',
			'notes.emptyNote' => 'Nota vazia',
			'notes.emptyNoteSubtitle' => 'Comece com uma página em branco',
			'drawing.pen' => 'Caneta',
			'drawing.pencil' => 'Lápis',
			'drawing.highlighter' => 'Marcador',
			'drawing.eraser' => 'Borracha',
			'drawing.select' => 'Selecionar',
			'drawing.lasso' => 'Laço',
			'drawing.undo' => 'Desfazer',
			'drawing.redo' => 'Refazer',
			'drawing.clear' => 'Limpar',
			'drawing.clearConfirm' => 'Deseja realmente apagar todos os desenhos?',
			'drawing.color' => 'Cor',
			'drawing.colorWheel' => 'Roda de cores',
			'drawing.symbol' => 'Símbolo',
			'drawing.strokeWidth' => 'Espessura do traço',
			'drawing.zoomIn' => 'Aumentar',
			'drawing.zoomOut' => 'Diminuir',
			'drawing.markerMode' => 'Modo marcador (translúcido)',
			'drawing.pressureDetection' => 'Detecção de pressão',
			'drawing.customizeTool' => ({required Object name}) => 'Personalizar ${name}',
			'drawing.fineliner' => 'Caneta fina',
			'drawing.inkRoller' => 'Caneta roller',
			'drawing.fountainPen' => 'Caneta-tinteiro',
			'drawing.marker' => 'Marcador',
			'drawing.neon' => 'Neon',
			'paper.plain' => 'Em branco',
			'paper.lined' => 'Linho',
			'paper.grid' => 'Quadriculado',
			'paper.dotted' => 'Pontilhado',
			'ai.title' => 'Recursos de IA',
			'ai.assistant' => 'Assistente de IA',
			'ai.recognize' => 'Reconhecer texto',
			'ai.recognizing' => 'Reconhecendo...',
			'ai.summarize' => 'Resumir',
			'ai.extractTasks' => 'Extrair tarefas',
			'ai.translate' => 'Traduzir',
			'ai.noTextFound' => 'Nenhum texto encontrado',
			'ai.helpMe' => 'Ajude-me',
			'ai.helpMeTitle' => 'Resposta da IA',
			'ai.analyzingSelection' => 'Analisando seleção…',
			'ai.noSelection' => 'Selecione algo com o laço primeiro.',
			'ai.helpMeNotConfigured' => 'A IA ainda não está configurada.',
			'ai.persona' => 'Persona do Assistente de IA',
			'ai.personaSubtitle' => 'Escolher estilo do assistente',
			'pdf.import' => 'Importar PDF',
			'pdf.importSubtitle' => 'Texto será extraído automaticamente',
			'pdf.export' => 'Exportar como PDF',
			'pdf.exporting' => 'Criando PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Falha ao exportar PDF: ${error}',
			'pdf.page' => 'Página',
			'pdf.of' => 'de',
			'settings.title' => 'Configurações',
			'settings.general' => 'Geral',
			'settings.theme' => 'Tema',
			'settings.themeSubtitle' => 'Clare · Escure · Sistema',
			'settings.darkMode' => 'Modo escuro',
			'settings.lightMode' => 'Modo claro',
			'settings.systemMode' => 'Padrão do sistema',
			'settings.language' => 'Idioma',
			'settings.languageSubtitle' => 'Português (beta)',
			'settings.sync' => 'Sincronização',
			'settings.syncEnabled' => 'Sincronização ativada',
			'settings.syncDisabled' => 'Sincronização desativada',
			'settings.account' => 'Conta',
			'settings.about' => 'Sobre',
			'settings.version' => 'Versão',
			'settings.privacy' => 'Privacidade',
			'settings.terms' => 'Termos de uso',
			'settings.input' => 'Entrada',
			'settings.inputDevices' => 'Dispositivos de entrada',
			'settings.inputDeviceSubtitle' => 'Caneta · Toque · Mouse',
			'settings.automation' => 'Automação',
			'settings.unlockPen' => 'Desbloquear caneta',
			'settings.pen' => 'Caneta',
			'settings.touch' => 'Toque',
			'settings.mouse' => 'Mouse',
			'settings.autoLockOnStylus' => 'Bloquear automaticamente ao usar a caneta',
			'settings.editorSettings' => 'Configurações do editor',
			'settings.noteEditor' => 'Editor de Notas',
			'settings.noteEditorSubtitle' => 'Painel lateral esquerdo · direito',
			'settings.strokeWidths' => 'Larguras da caneta',
			'settings.strokeWidthsSubtitle' => 'Fina · Média · Grossa',
			'settings.palmRejection' => 'Rejeição da palma',
			'settings.palmRejectionSubtitle' => 'Evita entradas indesejadas',
			'settings.assistPanel' => 'Painel de assistência',
			'settings.leftRightHanded' => 'Canhoto · Destro',
			'settings.rightLeftHanded' => 'Destro · Canhoto',
			'settings.drawingArea' => 'Área de desenho',
			'settings.debugMode' => 'Ativar modo de depuração',
			'settings.cloud' => 'Nuvem & Sincronização',
			'settings.storageTarget' => 'Destino de armazenamento',
			'settings.storageSubtitle' => 'Nuvem Inkpadu (gratuita)',
			'settings.encryption' => 'Criptografia',
			'settings.encryptionSubtitle' => 'Ativação de ponta a ponta',
			'errors.networkError' => 'Erro de rede. Verifique sua conexão.',
			'errors.unknownError' => 'Ocorreu um erro desconhecido.',
			'errors.authError' => 'Erro de autenticação. Por favor, tente novamente.',
			'errors.saveError' => 'Falha ao salvar.',
			'errors.loadError' => 'Falha ao carregar.',
			'errors.exportError' => 'Falha ao exportar.',
			'errors.loginFailed' => ({required Object provider}) => 'Login (${provider}) falhou',
			'onboarding.welcome' => 'Bem-vindo ao Inkpadu',
			'onboarding.description' => 'Esboce ideias, escreva notas e organize seus pensamentos com escrita à mão natural.',
			'onboarding.digitalNotebook' => 'Seu caderno digital',
			'onboarding.digitalNotebookDescription' => 'Uma experiência manuscrita, otimizada para criatividade e foco – sem distrações.',
			'onboarding.connecting' => 'Conectando...',
			'onboarding.loginWithGitHub' => 'Entrar com GitHub',
			'onboarding.loginWithGoogle' => 'Entrar com Google',
			'editor.newNote' => 'Nova Nota',
			'editor.editNote' => 'Editar Nota',
			'editor.title' => 'Título',
			'editor.writeNote' => 'Escreva sua nota...',
			'editor.assistPanel' => 'Painel de Assistência',
			'editor.leftRightHanded' => 'Canhoto · Destro',
			'editor.rightLeftHanded' => 'Destro · Canhoto',
			'editor.handednessHint' => 'Direitos têm acesso mais fácil às ferramentas quando o painel está do lado esquerdo. Canhotos, por outro lado, escolhem o lado direito.',
			'editor.drawingArea' => 'Área de desenho',
			'editor.enableDebugMode' => 'Ativar modo de depuração',
			'editor.debugModeHint' => 'Mostra caixas de delimitação e cascas convexas no editor e no assistente de IA.',
			'editor.useLineSimplifier' => 'Usar simplificador de linhas',
			'editor.lineSimplifierHint' => 'Suaviza seus traços automaticamente para obter linhas tranquilas.',
			'editor.smoothingIntensity' => ({required Object value}) => 'Intensidade de suavização (${value})',
			'editor.smoothingHint' => 'Valores baixos preservam mais detalhes, valores altos suavizam mais.',
			'editor.minTolerance' => ({required Object value}) => 'Tolerância mínima (${value} px)',
			'editor.minToleranceHint' => 'Define o limite inferior para suavização – valores mais altos filtram ondulações pequenas.',
			'editor.aiPersona' => 'Persona do Assistente de IA',
			'editor.choosePersonaStyle' => 'Escolha o estilo do seu Assistente de IA',
			'editor.personaStyleHint' => 'A persona determina como o assistente se comunica com você.',
			'editor.strictTrainer' => 'Treinador rigoroso',
			'editor.strictTrainerHint' => 'Crítica direta e dura como um treinador olímpico russo',
			'editor.encouragingMentor' => 'Mentor encorajador',
			'editor.encouragingMentorHint' => 'Reforço positivo e feedback motivador',
			'editor.customPersona' => 'Personalizado',
			'editor.customPersonaHint' => 'Defina seu próprio prompt de sistema',
			'editor.yourSystemPrompt' => 'Seu prompt de sistema',
			'editor.systemPromptPlaceholder' => 'Descreva como o assistente deve se comportar...',
			'editor.systemPromptHint' => 'O prompt de sistema define a personalidade e o comportamento do assistente em todas as solicitações.',
			'editor.currentStyle' => 'Estilo atual',
			'editor.strictTrainerDescription' => 'O assistente oferece feedback duro e direto. Ele não aceita mediocridade e motiva você com críticas construtivas a alcançar altos padrões.',
			'editor.encouragingMentorDescription' => 'O assistente elogia seus progressos e fornece feedback encorajador. Erros são apresentados como oportunidades de aprendizado.',
			'editor.customPersonaDescription' => 'O assistente se comporta de acordo com o seu próprio prompt de sistema.',
			'pdfDialog.selectPdf' => 'Selecionar PDF',
			'pdfDialog.analyzePdf' => 'Analisar PDF',
			'pdfDialog.ready' => 'Pronto',
			'pdfDialog.processPdf' => 'Processar PDF',
			'pdfDialog.importComplete' => 'Importação concluída',
			'pdfDialog.selectPdfFile' => 'Por favor, selecione um arquivo PDF...',
			'pdfDialog.analyzingPdf' => 'Analisando PDF...',
			'pdfDialog.pagesFound' => ({required Object count}) => '${count} página(s) encontrada(s)',
			'pdfDialog.textExtractionBackground' => 'Extração de texto em andamento em segundo plano.',
			'pdfDialog.couldNotReadPdf' => 'Não foi possível ler o arquivo PDF.',
			'pdfDialog.pagesImported' => ({required Object count}) => '${count} página(s) importada(s)',
			'pdfDialog.charactersExtracted' => ({required Object count}) => '~${count}k caracteres extraídos',
			'pdfDialog.extractedTextContext' => 'O texto extraído será usado como contexto para o assistente de IA.',
			'pdfDialog.textExtractionDuration' => 'A extração de texto pode levar alguns segundos por página.',
			'pdfDialog.renderingPage' => ({required Object current, required Object total}) => 'Renderizando página ${current} de ${total}...',
			'pdfDialog.extractingPage' => ({required Object current, required Object total}) => 'Extraindo texto da página ${current} de ${total}...',
			'pdfDialog.recognizingTasks' => 'Reconhecendo tarefas...',
			_ => null,
		};
	}
}
