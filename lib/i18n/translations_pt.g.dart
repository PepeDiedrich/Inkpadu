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
	@override late final _TranslationsNotesPt notes = _TranslationsNotesPt._(_root);
	@override late final _TranslationsDrawingPt drawing = _TranslationsDrawingPt._(_root);
	@override late final _TranslationsAiPt ai = _TranslationsAiPt._(_root);
	@override late final _TranslationsPdfPt pdf = _TranslationsPdfPt._(_root);
	@override late final _TranslationsSettingsPt settings = _TranslationsSettingsPt._(_root);
	@override late final _TranslationsErrorsPt errors = _TranslationsErrorsPt._(_root);
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

// Path: notes
class _TranslationsNotesPt extends TranslationsNotesDe {
	_TranslationsNotesPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notas';
	@override String get newNote => 'Nova nota';
	@override String get untitled => 'Sem título';
	@override String get lastEdited => 'Última edição';
	@override String get deleteNote => 'Excluir nota';
	@override String deleteNoteConfirm({required Object title}) => 'Você realmente deseja excluir "${title}"?';
	@override String get noNotes => 'Ainda não há notas manuscritas';
	@override String get createFirst => 'Crie sua primeira nota';
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
}

// Path: ai
class _TranslationsAiPt extends TranslationsAiDe {
	_TranslationsAiPt._(TranslationsPt root) : this._root = root, super.internal(root);

	final TranslationsPt _root; // ignore: unused_field

	// Translations
	@override String get title => 'Recursos de IA';
	@override String get recognize => 'Reconhecer texto';
	@override String get recognizing => 'Reconhecendo...';
	@override String get summarize => 'Resumir';
	@override String get extractTasks => 'Extrair tarefas';
	@override String get translate => 'Traduzir';
	@override String get noTextFound => 'Nenhum texto encontrado';
	@override String get persona => 'Persona do Assistente de IA';
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
	@override String get theme => 'Tema';
	@override String get darkMode => 'Modo escuro';
	@override String get lightMode => 'Modo claro';
	@override String get systemMode => 'Padrão do sistema';
	@override String get language => 'Idioma';
	@override String get sync => 'Sincronização';
	@override String get syncEnabled => 'Sincronização ativada';
	@override String get syncDisabled => 'Sincronização desativada';
	@override String get account => 'Conta';
	@override String get about => 'Sobre';
	@override String get version => 'Versão';
	@override String get privacy => 'Privacidade';
	@override String get terms => 'Termos de uso';
	@override String get inputDevices => 'Dispositivos de entrada';
	@override String get automation => 'Automação';
	@override String get unlockPen => 'Desbloquear caneta';
	@override String get pen => 'Caneta';
	@override String get touch => 'Toque';
	@override String get mouse => 'Mouse';
	@override String get autoLockOnStylus => 'Bloquear automaticamente ao usar a caneta';
	@override String get editorSettings => 'Configurações do editor';
	@override String get assistPanel => 'Painel de assistência';
	@override String get leftRightHanded => 'Canhoto · Destro';
	@override String get rightLeftHanded => 'Destro · Canhoto';
	@override String get drawingArea => 'Área de desenho';
	@override String get debugMode => 'Ativar modo de depuração';
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
			'notes.title' => 'Notas',
			'notes.newNote' => 'Nova nota',
			'notes.untitled' => 'Sem título',
			'notes.lastEdited' => 'Última edição',
			'notes.deleteNote' => 'Excluir nota',
			'notes.deleteNoteConfirm' => ({required Object title}) => 'Você realmente deseja excluir "${title}"?',
			'notes.noNotes' => 'Ainda não há notas manuscritas',
			'notes.createFirst' => 'Crie sua primeira nota',
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
			'ai.title' => 'Recursos de IA',
			'ai.recognize' => 'Reconhecer texto',
			'ai.recognizing' => 'Reconhecendo...',
			'ai.summarize' => 'Resumir',
			'ai.extractTasks' => 'Extrair tarefas',
			'ai.translate' => 'Traduzir',
			'ai.noTextFound' => 'Nenhum texto encontrado',
			'ai.persona' => 'Persona do Assistente de IA',
			'pdf.import' => 'Importar PDF',
			'pdf.importSubtitle' => 'Texto será extraído automaticamente',
			'pdf.export' => 'Exportar como PDF',
			'pdf.exporting' => 'Criando PDF...',
			'pdf.exportFailed' => ({required Object error}) => 'Falha ao exportar PDF: ${error}',
			'pdf.page' => 'Página',
			'pdf.of' => 'de',
			'settings.title' => 'Configurações',
			'settings.theme' => 'Tema',
			'settings.darkMode' => 'Modo escuro',
			'settings.lightMode' => 'Modo claro',
			'settings.systemMode' => 'Padrão do sistema',
			'settings.language' => 'Idioma',
			'settings.sync' => 'Sincronização',
			'settings.syncEnabled' => 'Sincronização ativada',
			'settings.syncDisabled' => 'Sincronização desativada',
			'settings.account' => 'Conta',
			'settings.about' => 'Sobre',
			'settings.version' => 'Versão',
			'settings.privacy' => 'Privacidade',
			'settings.terms' => 'Termos de uso',
			'settings.inputDevices' => 'Dispositivos de entrada',
			'settings.automation' => 'Automação',
			'settings.unlockPen' => 'Desbloquear caneta',
			'settings.pen' => 'Caneta',
			'settings.touch' => 'Toque',
			'settings.mouse' => 'Mouse',
			'settings.autoLockOnStylus' => 'Bloquear automaticamente ao usar a caneta',
			'settings.editorSettings' => 'Configurações do editor',
			'settings.assistPanel' => 'Painel de assistência',
			'settings.leftRightHanded' => 'Canhoto · Destro',
			'settings.rightLeftHanded' => 'Destro · Canhoto',
			'settings.drawingArea' => 'Área de desenho',
			'settings.debugMode' => 'Ativar modo de depuração',
			'errors.networkError' => 'Erro de rede. Verifique sua conexão.',
			'errors.unknownError' => 'Ocorreu um erro desconhecido.',
			'errors.authError' => 'Erro de autenticação. Por favor, tente novamente.',
			'errors.saveError' => 'Falha ao salvar.',
			'errors.loadError' => 'Falha ao carregar.',
			'errors.exportError' => 'Falha ao exportar.',
			_ => null,
		};
	}
}
