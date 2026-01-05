import 'dart:async';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';
import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_cluster_utils.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_prompt_manager.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_request_type.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/cluster_shape_data.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/pdf/pdf_import_service.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel/conversation_section.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel/debug_section.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';

/// Zeigt den Platzhalter für den KI-Assistenten an und reagiert auf
/// Größenänderungen der Sidebar.
class AssistantPanel extends StatefulWidget {
  /// Erstellt ein Panel mit Statusanzeige für den Assistenten.
  const AssistantPanel({
    super.key,
    required this.isActive,
    required this.widthFraction,
    required this.resizeTrend,
    required this.side,
    required this.controller,
    this.strokeClusters = const <StrokeBoundingBoxCluster>[],
  });

  /// Ob die Sidebar aktuell eingeblendet ist.
  final bool isActive;

  /// Anteil der Sidebar-Breite relativ zum Editor.
  final double widthFraction;

  /// Zeigt, ob sich die Sidebar gerade vergrößert oder verkleinert.
  final SidebarResizeTrend resizeTrend;

  /// Seite, auf der die Sidebar angezeigt wird.
  final EditorSidebarSide side;

  /// Die aktuell ermittelten Stroke-Cluster auf der Zeichenfläche.
  final List<StrokeBoundingBoxCluster> strokeClusters;

  /// Controller der aktuellen Notizseite für das Persistieren von Kontext.
  final DrawingNoteController controller;

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<AssistantPanel>
  with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _statusMessage = 'Hier erscheinen KI-Antworten zu deiner Notiz.';
  AssistantRequestType? _activeRequestType;
  AssistantMessage? _pendingMessage;
  final ValueNotifier<String> _streamingAnswer = ValueNotifier<String>('');
  String? _pendingStreamingText;
  bool _streamUpdateScheduled = false;

  late final Functions _functions;
  late final AzureAssistantApiService _assistantService;
  late final AssistantPromptManager _promptManager;
  final DrawingSnapshotService _snapshotService =
      const DrawingSnapshotService();
  final ScrollController _contentScrollController = ScrollController();

  CombinedSnapshot? _debugSnapshot;
  String _debugPrompt = '';
  int? _debugTokenEstimate;
  int _debugTotalClusters = 0;
  String? _debugPayloadPreview;
  bool _showDebugPanel = false;
  int _debugPdfContextTokens = 0;

  static const int _maxCompletionTokens = 10768;

  InkNotesController? _inkNotesController;

  @override
  void initState() {
    super.initState();
    _functions = Functions(AppwriteConfig.client);
    _assistantService = AzureAssistantApiService(functions: _functions);
    _promptManager = const AssistantPromptManager();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_prewarmAccessToken());
  }

  @override
  void didUpdateWidget(covariant AssistantPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      unawaited(_prewarmAccessToken());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = InkNotesScope.maybeOf(context);
    if (_inkNotesController != newController) {
      _inkNotesController?.removeListener(_onInkNotesChanged);
      _inkNotesController = newController;
      _inkNotesController?.addListener(_onInkNotesChanged);
      debugPrint('[AssistantPanel] InkNotes listener updated');
    }
  }

  void _onInkNotesChanged() {
    debugPrint('[AssistantPanel] InkNotes changed, checking for updates...');
    // Versuche, die Notiz im Controller zu aktualisieren
    if (widget.controller.isInitialized) {
      final bool updated = widget.controller.refreshFromSource();
      debugPrint('[AssistantPanel] Controller refresh result: $updated');
      if (updated && mounted) {
        setState(() {
          // UI neu aufbauen um den aktualisierten PDF-Text anzuzeigen
        });
      }
    }
  }

  @override
  void dispose() {
    // Listener entfernen
    _inkNotesController?.removeListener(_onInkNotesChanged);

    _streamingAnswer.dispose();
    _contentScrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_prewarmAccessToken());
    }
  }

  Future<void> _prewarmAccessToken() async {
    if (!widget.isActive) {
      return;
    }
    try {
      await _assistantService.getAccessToken();
    } catch (error, stackTrace) {
      debugPrint('[AssistantPanel] Token prewarm failed: $error\n$stackTrace');
    }
  }

  Future<void> _handleAssistantRequest(AssistantRequestType type) async {
    if (_isLoading) {
      return;
    }

    final DrawingNoteController controller = widget.controller;
    if (!controller.isInitialized) {
      setState(() {
        _statusMessage = 'Notiz wird noch geladen…';
      });
      return;
    }

    final int pageIndex = controller.currentPageIndex;
    final List<NotePage> pages = controller.pages;
    if (pageIndex < 0 || pageIndex >= pages.length) {
      setState(() {
        _statusMessage = 'Konnte aktuelle Seite nicht ermitteln.';
      });
      return;
    }

    final NotePage currentPage = pages[pageIndex];
    final List<AssistantMessage> history = currentPage.assistantHistory;
    final List<AssistantMessage> recentHistory = _promptManager
        .selectRecentHistory(history);
    final String? historySummary = _promptManager.summarizeHistory(
      recentHistory,
    );

    final List<StrokeBoundingBoxCluster> availableClusters = widget
        .strokeClusters
        .where((cluster) => cluster.hasContent)
        .toList(growable: false);
    final int totalClusterCount = availableClusters.length;
    final String? currentSignature =
        AssistantClusterUtils.computeClusterSignature(availableClusters);

    // Starte Token-Abruf sofort und parallel zur Bildverarbeitung
    final Future<String> tokenFuture = _assistantService.getAccessToken();

    final String questionLabel = _questionLabelFor(type);
    final String prompt = _promptManager.promptTemplateFor(type);

    // Get the system prompt from the persona settings
    final String systemPrompt = EditorSettingsScope.of(
      context,
    ).assistantPersona.systemPrompt;

    _streamingAnswer.value = '';
    _pendingStreamingText = null;
    _streamUpdateScheduled = false;

    setState(() {
      _isLoading = true;
      _isStreaming = true;
      _activeRequestType = type;
      _pendingMessage = AssistantMessage(
        question: questionLabel,
        answer: '',
        createdAt: DateTime.now(),
      );
      _statusMessage = totalClusterCount > 0
          ? 'Erstelle neue Bildbeschreibung aus $totalClusterCount Clustern…'
          : 'Sende Anfrage ohne Bildkontext…';
    });

    CombinedSnapshot? combinedSnapshot;

    try {
      if (availableClusters.isNotEmpty) {
        combinedSnapshot = await _snapshotService.captureCombinedSnapshot(
          availableClusters,
        );
      }

      final List<Map<String, dynamic>> userContent = _promptManager
          .buildUserContent(
            prompt: prompt,
            combinedSnapshot: combinedSnapshot,
            totalClusters: totalClusterCount,
            historySummary: historySummary,
          );

      final int tokenEstimate = _promptManager.estimateTokenUsage(
        systemPrompt: systemPrompt,
        prompt: prompt,
        combinedSnapshot: combinedSnapshot,
        historySummary: historySummary,
      );

      // Nutze nur den Text der aktuellen Seite als Kontext
      final String? pagePdfText = currentPage.importedPdfText;

      final int pdfContextTokens = _promptManager.estimatePdfContextTokens(
        pagePdfText,
      );

      final AzureAssistantPreparedRequest preparedRequest = _assistantService
          .prepareRequest(
            AzureAssistantRequest(
              systemPrompt: systemPrompt,
              userContent: userContent,
              maxCompletionTokens: _maxCompletionTokens,
              pdfContext: pagePdfText,
              reasoningEffort: 'low',
            ),
          );

      if (mounted) {
        setState(() {
          _debugPrompt = prompt;
          _debugTokenEstimate = tokenEstimate;
          _debugTotalClusters = totalClusterCount;
          _debugSnapshot = combinedSnapshot;
          _debugPayloadPreview = preparedRequest.payloadPreview;
          _debugPdfContextTokens = pdfContextTokens;
          _showDebugPanel = true;
        });
      }

      // Warten auf Token, falls noch nicht fertig
      final String token = await tokenFuture;

      final AzureAssistantResult result = await _assistantService
          .streamCompletion(
            preparedRequest: preparedRequest,
            preloadedToken: token,
            onStreamUpdate: (String text) {
              _scheduleStreamingUpdate(text);
              if (mounted && _statusMessage != null) {
                setState(() {
                  _statusMessage = null;
                });
              }
            },
            onStreamStarted: () {
              if (mounted) {
                setState(() {
                  _statusMessage = '${_buttonLabelFor(type)} wird generiert…';
                });
              }
            },
          );

      _pendingStreamingText = null;
      _streamUpdateScheduled = false;
      _streamingAnswer.value = result.answer;

      final AssistantMessage finalMessage = AssistantMessage(
        question: questionLabel,
        answer: result.answer,
        createdAt: DateTime.now(),
      );

      controller.appendAssistantMessage(
        finalMessage,
        visionSignature: currentSignature,
      );

      if (mounted) {
        setState(() {
          _pendingMessage = null;
          _statusMessage = result.wasTruncated
              ? '⚠️ Antwort wurde nach $_maxCompletionTokens Tokens abgeschnitten.'
              : null;
        });
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Fehler: ${e.message}';
          _pendingMessage = _pendingMessage?.copyWith(answer: _statusMessage!);
        });
      }
      _pendingStreamingText = null;
      _streamUpdateScheduled = false;
      _streamingAnswer.value = _statusMessage ?? '';
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Fehler: $e';
          _pendingMessage = _pendingMessage?.copyWith(answer: _statusMessage!);
        });
      }
      _pendingStreamingText = null;
      _streamUpdateScheduled = false;
      _streamingAnswer.value = _statusMessage ?? '';
    } finally {
      _pendingStreamingText = null;
      _streamUpdateScheduled = false;
      _streamingAnswer.value = '';
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isStreaming = false;
          _activeRequestType = null;
        });
      }
    }
  }

  String _questionLabelFor(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return 'Tipp anfordern';
      case AssistantRequestType.help:
        return 'Hilfe anfordern';
      case AssistantRequestType.review:
        return 'Lösung überprüfen lassen';
      case AssistantRequestType.pdfExtract:
        return 'PDF-Text extrahieren';
    }
  }

  String _buttonLabelFor(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return 'Tipp';
      case AssistantRequestType.help:
        return 'Hilfe';
      case AssistantRequestType.review:
        return 'Überprüfen';
      case AssistantRequestType.pdfExtract:
        return 'PDF';
    }
  }

  String _buttonDescriptionFor(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return 'Kurzer Hinweis ohne Spoiler.';
      case AssistantRequestType.help:
        return 'Ausführliche Schritt-für-Schritt-Hilfe.';
      case AssistantRequestType.review:
        return 'Überprüfung der aktuellen Lösung.';
      case AssistantRequestType.pdfExtract:
        return 'Text aus PDF extrahieren.';
    }
  }

  IconData _iconForType(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return Icons.lightbulb_outline;
      case AssistantRequestType.help:
        return Icons.support_agent;
      case AssistantRequestType.review:
        return Icons.fact_check_outlined;
      case AssistantRequestType.pdfExtract:
        return Icons.picture_as_pdf;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool debugModeEnabled = EditorSettingsScope.of(
      context,
    ).debugModeEnabled;
    final List<ClusterShapeData> clusterShapes = debugModeEnabled
        ? AssistantClusterUtils.computeClusterShapes(widget.strokeClusters)
        : const <ClusterShapeData>[];

    final bool hasPayloadDebugContent =
        _debugPrompt.isNotEmpty ||
        _debugSnapshot != null ||
        (_debugPayloadPreview?.isNotEmpty ?? false) ||
        _debugTokenEstimate != null ||
        _debugTotalClusters > 0;
    final bool hasDebugContent =
        hasPayloadDebugContent || clusterShapes.isNotEmpty;
    final bool showDebugControls = debugModeEnabled && hasDebugContent;

    if (!debugModeEnabled && _showDebugPanel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _showDebugPanel) {
          setState(() => _showDebugPanel = false);
        }
      });
    }

    final bool panelOnRight = widget.side == EditorSidebarSide.right;
    final Color borderColor = widget.isActive
        ? AppColors.primaryAccent
        : colorScheme.outlineVariant;
    final BorderSide highlightedBorder = BorderSide(
      color: borderColor,
      width: 2,
    );
    final BorderRadius borderRadius = BorderRadius.horizontal(
      left: panelOnRight ? const Radius.circular(20) : Radius.zero,
      right: panelOnRight ? Radius.zero : const Radius.circular(20),
    );

    final int percentage = (widget.widthFraction * 100).round();
    final Color headerBadgeColor = colorScheme.primaryContainer;
    final Color indicatorBackground = colorScheme.inverseSurface;
    final Color indicatorTextColor = colorScheme.onInverseSurface;
    final bool shouldShowClusterInfo =
        showDebugControls && clusterShapes.isNotEmpty;

    final List<AssistantMessage> history = widget.controller.isInitialized
        ? widget.controller.currentAssistantHistory
        : const <AssistantMessage>[];

    // PDF-Text nur im Debug-Modus anzeigen und nur von der aktuellen Seite
    String? importedPdfText;
    if (debugModeEnabled && widget.controller.isInitialized) {
      final int pageIndex = widget.controller.currentPageIndex;
      if (pageIndex >= 0 && pageIndex < widget.controller.pages.length) {
        importedPdfText = widget.controller.pages[pageIndex].importedPdfText;
      }
    }

    final List<Widget> slivers = <Widget>[
      AssistantConversationSliver(
        statusMessage: _statusMessage,
        isLoading: _isLoading,
        messages: history,
        debugModeEnabled: debugModeEnabled,
        pendingMessage: _pendingMessage,
        isStreaming: _isStreaming,
        streamingAnswerListenable: _streamingAnswer,
        importedPdfText: importedPdfText,
        currentNoteId: widget.controller.note.id,
      ),
    ];

    if (showDebugControls) {
      slivers.add(
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showDebugPanel = !_showDebugPanel;
                  });
                },
                icon: Icon(
                  _showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined,
                ),
                label: Text(
                  _showDebugPanel ? 'Debug ausblenden' : 'Debug anzeigen',
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _showDebugPanel && hasDebugContent
                    ? AssistantDebugSection(
                        prompt: _debugPrompt,
                        snapshot: _debugSnapshot,
                        tokenEstimate: _debugTokenEstimate,
                        totalClusters: _debugTotalClusters,
                        payloadPreview: _debugPayloadPreview,
                        clusterShapes: clusterShapes,
                        showClusterInfo: shouldShowClusterInfo,
                        pdfContextTokens: _debugPdfContextTokens,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          height: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: borderRadius,
            border: Border(
              left: panelOnRight ? highlightedBorder : BorderSide.none,
              right: panelOnRight ? BorderSide.none : highlightedBorder,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: headerBadgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'KI-Assistent',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Scrollbar(
                    controller: _contentScrollController,
                    child: CustomScrollView(
                      controller: _contentScrollController,
                      slivers: slivers,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildActionSelector(colorScheme),
              ],
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: panelOnRight ? 16 : null,
          left: panelOnRight ? null : 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: widget.isActive ? 1 : 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: indicatorBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _trendIcon(panelOnRight, widget.resizeTrend),
                      color: AppColors.primaryAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$percentage %',
                      style: textTheme.labelMedium?.copyWith(
                        color: indicatorTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSelector(ColorScheme colorScheme) {
    const Radius segmentRadius = Radius.circular(28);
    // Nur die UI-relevanten Typen anzeigen (pdfExtract ist nur intern)
    final List<AssistantRequestType> types = AssistantRequestType.values
        .where((t) => t != AssistantRequestType.pdfExtract)
        .toList();
    final AssistantRequestType? activeType = _isStreaming
        ? _activeRequestType
        : null;

    // Prüfe ob PDF-Verarbeitung für diese Notiz läuft
    final String? noteId = widget.controller.isInitialized
        ? widget.controller.noteId
        : null;
    final bool isPdfProcessing =
        noteId != null && InkNotesScope.of(context).isPdfProcessing(noteId);
    final bool isBusy = _isLoading || isPdfProcessing;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // PDF-Verarbeitungs-Hinweis
          if (isPdfProcessing) _buildPdfProcessingBanner(colorScheme, noteId),
          ClipRRect(
            borderRadius: const BorderRadius.all(segmentRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.all(segmentRadius),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  for (int index = 0; index < types.length; index++) ...[
                    Expanded(
                      child: _AssistantActionSegment(
                        label: _buttonLabelFor(types[index]),
                        description: _buttonDescriptionFor(types[index]),
                        icon: _iconForType(types[index]),
                        isActive: activeType == types[index],
                        isDisabled: isBusy,
                        showProgress:
                            _isStreaming && _activeRequestType == types[index],
                        onPressed: isBusy
                            ? null
                            : () => _handleAssistantRequest(types[index]),
                        borderRadius: BorderRadius.only(
                          topLeft: index == 0 ? segmentRadius : Radius.zero,
                          bottomLeft: index == 0 ? segmentRadius : Radius.zero,
                          topRight: index == types.length - 1
                              ? segmentRadius
                              : Radius.zero,
                          bottomRight: index == types.length - 1
                              ? segmentRadius
                              : Radius.zero,
                        ),
                        showTrailingDivider: index != types.length - 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfProcessingBanner(ColorScheme colorScheme, String noteId) =>
      StreamBuilder<PdfProcessingUpdate>(
        stream: InkNotesScope.of(
          context,
        ).pdfProcessingUpdates.where((update) => update.noteId == noteId),
        builder: (context, snapshot) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  snapshot.data != null
                      ? _getPdfProcessingText(snapshot.data!)
                      : 'PDF wird verarbeitet...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.hourglass_top,
                size: 16,
                color: colorScheme.onSecondaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      );

  String _getPdfProcessingText(PdfProcessingUpdate update) {
    switch (update.stage) {
      case PdfImportStage.rendering:
        return 'PDF: Rendere Seite ${update.currentPage}/${update.totalPages}';
      case PdfImportStage.extracting:
        return 'PDF: Extrahiere Seite ${update.currentPage}/${update.totalPages}';
      case PdfImportStage.parsingTasks:
        if (update.parsedTasks != null) {
          return 'PDF: ${update.parsedTasks!.length} Aufgaben erkannt';
        }
        return 'PDF: Erkenne Aufgaben...';
    }
  }

  void _scheduleStreamingUpdate(String text) {
    _pendingStreamingText = text;
    if (_streamUpdateScheduled) {
      return;
    }
    _streamUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _streamUpdateScheduled = false;
      if (!mounted) {
        _pendingStreamingText = null;
        return;
      }
      final String? pending = _pendingStreamingText;
      if (pending != null) {
        _streamingAnswer.value = pending;
      }
      _pendingStreamingText = null;
    });
  }

  IconData _trendIcon(bool panelOnRight, SidebarResizeTrend trend) {
    if (trend == SidebarResizeTrend.expand) {
      return panelOnRight
          ? Icons.keyboard_double_arrow_left
          : Icons.keyboard_double_arrow_right;
    }
    if (trend == SidebarResizeTrend.shrink) {
      return panelOnRight
          ? Icons.keyboard_double_arrow_right
          : Icons.keyboard_double_arrow_left;
    }
    return Icons.open_with;
  }
}

class _AssistantActionSegment extends StatelessWidget {
  const _AssistantActionSegment({
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
    required this.isActive,
    required this.isDisabled,
    required this.showProgress,
    required this.borderRadius,
    required this.showTrailingDivider,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isDisabled;
  final bool showProgress;
  final BorderRadius borderRadius;
  final bool showTrailingDivider;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color activeBackground = AppColors.primaryAccent;
    final Brightness accentBrightness = ThemeData.estimateBrightnessForColor(
      activeBackground,
    );
    final Color activeForeground = accentBrightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final Color baseForeground = colorScheme.onSurface;
    final Color labelColor = isActive ? activeForeground : baseForeground;

    final VoidCallback? effectiveOnTap = isDisabled ? null : onPressed;

    final Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: labelColor),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (showProgress) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(labelColor),
            ),
          ),
        ],
      ],
    );

    final Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: borderRadius,
        splashColor: activeBackground.withValues(alpha: 0.12),
        highlightColor: activeBackground.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isActive ? activeBackground : Colors.transparent,
            borderRadius: borderRadius,
            border: showTrailingDivider
                ? Border(
                    right: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                  )
                : null,
          ),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 120),
            opacity: isDisabled && !showProgress ? 0.65 : 1,
            child: content,
          ),
        ),
      ),
    );

    return Tooltip(
      message: description,
      waitDuration: const Duration(milliseconds: 400),
      child: button,
    );
  }
}
