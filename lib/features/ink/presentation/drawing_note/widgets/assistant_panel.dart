import 'dart:convert';

import 'package:ai_handwriting_app/app/auth/appwrite_config.dart';
import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster, ConvexHullCalculator;
import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel/conversation_section.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel/debug_section.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'package:appwrite/models.dart' show Execution;
import 'package:appwrite/enums.dart' as appwrite_enums;

/// Unterstützte Aktionen, die der Assistent auslösen kann.
enum AssistantRequestType {
  /// Liefert einen kurzen Hinweis ohne die Lösung zu verraten.
  tip,

  /// Generiert eine ausführliche Hilfestellung mit Erklärungen.
  help,

  /// Prüft die aktuelle Lösung auf Fehler oder bestätigt sie.
  review,
}

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

class _AssistantPanelState extends State<AssistantPanel> {
  bool _isLoading = false;
  bool _isStreaming = false;
  String? _statusMessage = 'Hier erscheinen KI-Antworten zu deiner Notiz.';
  AssistantRequestType? _activeRequestType;
  AssistantMessage? _pendingMessage;

  late final Functions _functions;
  final DrawingSnapshotService _snapshotService =
      const DrawingSnapshotService();
  final ScrollController _contentScrollController = ScrollController();
  static const String _systemPrompt =
      'Du bist ein hilfreicher Assistent innerhalb einer Notiz-App. '
      'Nutze angehängte Bildausschnitte, um die handschriftlichen Inhalte zu interpretieren. '
    'Beschreibe Unsicherheiten oder unlesbare Bereiche transparent. '
    'Alle mathematischen Ausdrücke sollen in LaTeX-Notation ausgegeben werden, verwende dafür \$…\$ oder \$\$…\$\$ und erhalte Leerzeichen im restlichen Text.';

  CombinedSnapshot? _debugSnapshot;
  String _debugPrompt = '';
  int? _debugTokenEstimate;
  int _debugTotalClusters = 0;
  String? _debugPayloadPreview;
  bool _showDebugPanel = false;

  // TODO: Ersetze diese Platzhalter durch deine Werte oder lade sie aus
  // einer sicheren Konfiguration (Environment / Secrets).
  // Hinweis: Für die URL, die du erwähnt hast, setze Deployment auf
  // 'gpt-5-nano' und api-version auf '2025-01-01-preview'.
  static const String _functionId = 'llm_auth';
  static const String _azureResourceName = 'peped-mgjk16o0-eastus2';
  static const String _azureDeploymentName = 'gpt-5-nano';
  static const String _azureApiVersion = '2025-01-01-preview';
  static const int _maxCompletionTokens = 10768;

  @override
  void initState() {
    super.initState();
    _functions = Functions(AppwriteConfig.client);
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
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
    final List<AssistantMessage> recentHistory = _selectRecentHistory(history);
    final String? historySummary = _summarizeHistory(recentHistory);

    final List<StrokeBoundingBoxCluster> availableClusters = widget
        .strokeClusters
        .where((cluster) => cluster.hasContent)
        .toList(growable: false);
    final int totalClusterCount = availableClusters.length;
    final String? currentSignature =
        _computeClusterSignature(availableClusters);

    final String questionLabel = _questionLabelFor(type);
    final String prompt = _promptTemplateFor(type);

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
        combinedSnapshot = await _snapshotService
            .captureCombinedSnapshot(availableClusters);
      }

      final Execution execution = await _functions.createExecution(
        functionId: _functionId,
        xasync: false,
      );

      final String responseBody = await _resolveExecutionResponse(execution);
      final Map<String, dynamic> data =
          json.decode(responseBody) as Map<String, dynamic>;

      if (data['success'] != true) {
        throw Exception('Konnte Azure-Token nicht erhalten: ${data['error']}');
      }

      final String token = data['accessToken'] as String;

      final Uri url = Uri.parse(
        'https://$_azureResourceName.openai.azure.com/openai/deployments/$_azureDeploymentName/chat/completions?api-version=$_azureApiVersion',
      );

      final List<Map<String, dynamic>> userContent = _buildUserContent(
        prompt: prompt,
        combinedSnapshot: combinedSnapshot,
        totalClusters: totalClusterCount,
        historySummary: historySummary,
      );

      final Map<String, dynamic> payload = <String, dynamic>{
        'messages': [
          {
            'role': 'system',
            'content': const [
              {'type': 'text', 'text': _systemPrompt},
            ],
          },
          {'role': 'user', 'content': userContent},
        ],
        'max_completion_tokens': _maxCompletionTokens,
        'response_format': const {'type': 'text'},
        'stream': true,
      };

      final int tokenEstimate = _estimateTokenUsage(
        prompt: prompt,
        combinedSnapshot: combinedSnapshot,
        historySummary: historySummary,
      );

      final String payloadPreview = const JsonEncoder.withIndent(
        '  ',
      ).convert(payload);

      if (mounted) {
        setState(() {
          _debugPrompt = prompt;
          _debugTokenEstimate = tokenEstimate;
          _debugTotalClusters = totalClusterCount;
          _debugSnapshot = combinedSnapshot;
          _debugPayloadPreview = payloadPreview;
          _showDebugPanel = true;
        });
      }

      final http.Client client = http.Client();
      String accumulatedContent = '';
      String? finishReason;

      try {
        final http.Request request = http.Request('POST', url)
          ..headers.addAll({
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          })
          ..body = json.encode(payload);

        final http.StreamedResponse azureRes = await client.send(request);

        if (azureRes.statusCode != 200) {
          final String errorBody = await azureRes.stream.bytesToString();
          throw Exception(
            'Azure-Fehler: ${azureRes.statusCode} $errorBody',
          );
        }

        if (mounted) {
          setState(() {
            _statusMessage = '${_buttonLabelFor(type)} wird generiert…';
          });
        }

        final Stream<String> lineStream = azureRes.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter());

        await for (final String line in lineStream) {
          if (!mounted) {
            break;
          }
          final String trimmed = line.trim();
          if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
            continue;
          }

          final String dataPayload = trimmed.substring(5).trim();
          if (dataPayload.isEmpty) {
            continue;
          }
          if (dataPayload == '[DONE]') {
            break;
          }

          Map<String, dynamic> chunk;
          try {
            chunk = json.decode(dataPayload) as Map<String, dynamic>;
          } catch (_) {
            continue;
          }

          final String? delta = _extractDeltaContent(chunk, preserveWhitespace: true);
          if (delta != null && delta.isNotEmpty) {
            accumulatedContent += delta;
            if (mounted) {
              setState(() {
                _pendingMessage =
                    _pendingMessage?.copyWith(answer: accumulatedContent);
                _statusMessage = null;
              });
            }
          }

          final String? chunkFinish = _firstFinishReason(chunk);
          if (chunkFinish != null) {
            finishReason ??= chunkFinish;
          }
        }
      } finally {
        client.close();
      }

      final String resolvedAnswer = accumulatedContent.trim().isNotEmpty
          ? accumulatedContent.trim()
          : finishReason == 'length'
              ? '⚠️ Antwort wurde nach $_maxCompletionTokens Tokens abgeschnitten.'
        : 'Das Modell hat keine Antwort gesendet.';

      final AssistantMessage finalMessage = AssistantMessage(
        question: questionLabel,
        answer: resolvedAnswer,
        createdAt: DateTime.now(),
      );

      controller.appendAssistantMessage(
        finalMessage,
        visionSignature: currentSignature,
      );

      if (mounted) {
        setState(() {
          _pendingMessage = null;
          _statusMessage = finishReason == 'length'
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Fehler: $e';
          _pendingMessage = _pendingMessage?.copyWith(answer: _statusMessage!);
        });
      }
    } finally {
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
    }
  }

  String _promptTemplateFor(AssistantRequestType type) {
    switch (type) {
      case AssistantRequestType.tip:
        return 'Gib einen kurzen Tipp zur Aufgabe in der Notiz, ohne die vollständige Lösung zu verraten. Nutze für Formeln LaTeX (\$…\$ bzw. \$\$…\$\$) und lasse übrige Texte mit korrekten Leerzeichen.';
      case AssistantRequestType.help:
        return 'Erkläre ausführlich, wie man die Aufgabe in der Notiz lösen kann und gib eine strukturierte Hilfestellung. Mathematische Ausdrücke sollen immer in LaTeX notiert sein (\$…\$ oder \$\$…\$\$).';
      case AssistantRequestType.review:
        return 'Überprüfe die dargestellte Lösung in der Notiz. Bestätige kurz, ob sie korrekt ist, oder beschreibe kompakt die wichtigsten Fehler. Verwende LaTeX-Notation (\$…\$ bzw. \$\$…\$\$) für Formeln.';
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
    }
  }

  String? _extractDeltaContent(
    Map<String, dynamic> chunk, {
    bool preserveWhitespace = false,
  }) {
    final dynamic choices = chunk['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }

    final dynamic firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return null;
    }

    final dynamic delta = firstChoice['delta'];
    if (delta is Map<String, dynamic>) {
      final String? extracted = _normalizeContent(
        delta['content'],
        trimWhitespace: !preserveWhitespace,
      );
      if (extracted != null) {
        return extracted;
      }

      final dynamic inner = delta['text'] ?? delta['value'];
      final String? fallback = _normalizeContent(
        inner,
        trimWhitespace: !preserveWhitespace,
      );
      if (fallback != null) {
        return fallback;
      }
    }

    final dynamic message = firstChoice['message'];
    if (message is Map<String, dynamic>) {
      return _normalizeContent(
        message['content'],
        trimWhitespace: !preserveWhitespace,
      );
    }

    return null;
  }

  String? _firstFinishReason(Map<String, dynamic> body) {
    final dynamic choices = body['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }

    final dynamic firstChoice = choices.first;
    if (firstChoice is Map<String, dynamic>) {
      final dynamic reason = firstChoice['finish_reason'];
      if (reason is String && reason.isNotEmpty) {
        return reason;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _buildUserContent({
    required String prompt,
    required CombinedSnapshot? combinedSnapshot,
    required int totalClusters,
    required String? historySummary,
  }) {
    final List<Map<String, dynamic>> content = <Map<String, dynamic>>[
      {
        'type': 'text',
        'text':
            'Beantworte die Frage zur handschriftlichen Notiz präzise und markiere Unsicherheiten ausdrücklich.',
      },
    ];

    if (historySummary != null && historySummary.isNotEmpty) {
      content.add({
        'type': 'text',
        'text': 'Bisherige Unterhaltung:\n$historySummary',
      });
    }

    if (combinedSnapshot != null) {
      content.add({
        'type': 'image_url',
        'image_url': {
          'url': 'data:image/png;base64,${combinedSnapshot.base64Data}',
          'detail': 'auto',
        },
      });
    } else if (totalClusters > 0) {
      content.add({
        'type': 'text',
        'text':
            'Hinweis: Es standen $totalClusters Cluster zur Verfügung, es konnte aber kein Bild erzeugt werden.',
      });
    }

    content.add({
      'type': 'text',
      'text': 'Frage: $prompt',
    });

    return content;
  }

  String? _normalizeContent(
    dynamic content, {
    bool trimWhitespace = true,
  }) {
    if (content is String) {
      if (trimWhitespace) {
        final String trimmed = content.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return content.isEmpty ? null : content;
    }

    if (content is List) {
      final StringBuffer buffer = StringBuffer();
      for (final dynamic entry in content) {
        if (entry is Map<String, dynamic>) {
          final String? textValue = _resolvedText(
            entry['text'] ?? entry['content'] ?? entry['value'],
            trimWhitespace: trimWhitespace,
          );
          if (textValue != null && textValue.isNotEmpty) {
            if (buffer.isNotEmpty && trimWhitespace) {
              buffer.writeln();
            }
            buffer.write(textValue);
          }
        } else if (entry is String) {
          final String candidate = trimWhitespace ? entry.trim() : entry;
          if (candidate.isNotEmpty) {
            if (buffer.isNotEmpty && trimWhitespace) {
              buffer.writeln();
            }
            buffer.write(candidate);
          }
        }
      }

      if (buffer.isEmpty) {
        return null;
      }

      if (trimWhitespace) {
        final String trimmed = buffer.toString().trim();
        return trimmed.isEmpty ? null : trimmed;
      }

      final String combined = buffer.toString();
      return combined.isEmpty ? null : combined;
    }

    return null;
  }

  String? _resolvedText(
    dynamic value, {
    bool trimWhitespace = true,
  }) {
    if (value is String) {
      if (trimWhitespace) {
        final String trimmed = value.trim();
        return trimmed.isEmpty ? null : trimmed;
      }
      return value.isEmpty ? null : value;
    }

    if (value is Map<String, dynamic>) {
      final dynamic primary =
          value['text'] ?? value['content'] ?? value['value'];
      final String? inner = _resolvedText(
        primary,
        trimWhitespace: trimWhitespace,
      );
      if (inner != null) {
        return inner;
      }

      final dynamic parts =
          value['parts'] ?? value['content'] ?? value['segments'];
      if (parts is List) {
        return _normalizeContent(parts, trimWhitespace: trimWhitespace);
      }
    }

    if (value is List) {
      return _normalizeContent(value, trimWhitespace: trimWhitespace);
    }

    return null;
  }

  Future<String> _resolveExecutionResponse(Execution execution) async {
    if (execution.responseBody.trim().isNotEmpty) {
      return execution.responseBody;
    }

    if (execution.errors.trim().isNotEmpty) {
      throw FormatException(execution.errors.trim());
    }

    final Execution finalExecution = await _pollExecution(execution.$id);
    if (finalExecution.responseBody.trim().isNotEmpty) {
      return finalExecution.responseBody;
    }

    if (finalExecution.errors.trim().isNotEmpty) {
      throw FormatException(finalExecution.errors.trim());
    }

    throw const FormatException('Server lieferte eine leere Antwort.');
  }

  Future<Execution> _pollExecution(String executionId) async {
    Execution lastExecution = await _functions.getExecution(
      functionId: _functionId,
      executionId: executionId,
    );

    if (_hasTerminalResponse(lastExecution)) {
      return lastExecution;
    }

    const int maxAttempts = 5;
    const Duration pollInterval = Duration(milliseconds: 200);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future<void>.delayed(pollInterval);
      lastExecution = await _functions.getExecution(
        functionId: _functionId,
        executionId: executionId,
      );

      if (_hasTerminalResponse(lastExecution)) {
        return lastExecution;
      }
    }

    return lastExecution;
  }

  bool _hasTerminalResponse(Execution execution) {
    if (execution.responseBody.trim().isNotEmpty) {
      return true;
    }
    if (execution.errors.trim().isNotEmpty) {
      return true;
    }
    return execution.status == appwrite_enums.ExecutionStatus.completed ||
        execution.status == appwrite_enums.ExecutionStatus.failed;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final bool debugModeEnabled = EditorSettingsScope.of(
      context,
    ).debugModeEnabled;
  final List<ClusterShapeData> clusterShapes = debugModeEnabled
        ? _computeClusterShapes(widget.strokeClusters)
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

    final List<Widget> listViewChildren = <Widget>[
      AssistantConversationSection(
        statusMessage: _statusMessage,
        isLoading: _isLoading,
        messages: history,
        debugModeEnabled: debugModeEnabled,
        pendingMessage: _pendingMessage,
        isStreaming: _isStreaming,
      ),
    ];

    if (showDebugControls) {
      listViewChildren
        ..add(const SizedBox(height: 12))
        ..add(
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _showDebugPanel = !_showDebugPanel;
                });
              },
              icon: Icon(
                _showDebugPanel
                    ? Icons.bug_report
                    : Icons.bug_report_outlined,
              ),
              label: Text(
                _showDebugPanel ? 'Debug ausblenden' : 'Debug anzeigen',
              ),
            ),
          ),
        )
        ..add(
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
                  )
                : const SizedBox.shrink(),
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
                    child: ListView(
                      controller: _contentScrollController,
                      padding: EdgeInsets.zero,
                      children: listViewChildren,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final AssistantRequestType type
                        in AssistantRequestType.values)
                      _AssistantActionButton(
                        label: _buttonLabelFor(type),
                        description: _buttonDescriptionFor(type),
                        icon: _iconForType(type),
                        isActive: _isStreaming && _activeRequestType == type,
                        onPressed: _isLoading
                            ? null
                            : () => _handleAssistantRequest(type),
                      ),
                  ],
                ),
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

  int _estimateTokenUsage({
    required String prompt,
    required CombinedSnapshot? combinedSnapshot,
    String? historySummary,
  }) {
    var total = _approxTokens(_systemPrompt) + _approxTokens(prompt) + 32;
    if (historySummary != null) {
      total += _approxTokens(historySummary);
    }
    if (combinedSnapshot != null) {
      final double kiloBytes = combinedSnapshot.pngBytes.lengthInBytes / 1024;
      final int imageTokens = (80 + kiloBytes * 1.6).ceil();
      total += imageTokens;
    }
    return total;
  }

  int _approxTokens(String text) {
    if (text.isEmpty) {
      return 0;
    }
    return (text.length / 4).ceil();
  }

  List<AssistantMessage> _selectRecentHistory(
    List<AssistantMessage> history,
  ) {
    if (history.length <= 5) {
      return history;
    }
    return history.sublist(history.length - 5);
  }

  String? _summarizeHistory(List<AssistantMessage> history) {
    if (history.isEmpty) {
      return null;
    }
    final StringBuffer buffer = StringBuffer();
    for (var i = 0; i < history.length; i++) {
      final AssistantMessage message = history[i];
      if (buffer.isNotEmpty) {
        buffer.writeln('---');
      }
      buffer
        ..writeln('Frage: ${_condenseForPrompt(message.question)}')
        ..writeln('Antwort: ${_condenseForPrompt(message.answer)}');
    }
    final String result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  String _condenseForPrompt(String value, {int maxLength = 420}) {
    final String trimmed = value.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength - 1)}…';
  }

  String? _computeClusterSignature(
    List<StrokeBoundingBoxCluster> clusters,
  ) {
    if (clusters.isEmpty) {
      return null;
    }

    final List<String> entries = <String>[];
    for (final StrokeBoundingBoxCluster cluster in clusters) {
      final List<String> strokeIds = List<String>.from(cluster.strokeIds)
        ..sort();
      final List<String> corners = cluster.boundingBox.corners
          .map(
            (Offset corner) =>
                '${corner.dx.toStringAsFixed(1)}:${corner.dy.toStringAsFixed(1)}',
          )
          .toList(growable: false);
      entries.add(
        '${strokeIds.join(',')}|${corners.join(';')}|'
        '${cluster.boundingBox.width.toStringAsFixed(1)}|'
        '${cluster.boundingBox.height.toStringAsFixed(1)}|'
        '${cluster.boundingBox.angle.toStringAsFixed(3)}',
      );
    }

    entries.sort();
    return entries.join('#');
  }

  List<ClusterShapeData> _computeClusterShapes(
    List<StrokeBoundingBoxCluster> clusters,
  ) {
    if (clusters.isEmpty) {
      return const <ClusterShapeData>[];
    }

    final List<ClusterShapeData> shapes = <ClusterShapeData>[];
    for (final StrokeBoundingBoxCluster cluster in clusters) {
      if (!cluster.hasContent) {
        continue;
      }

      final List<Offset> hull = List<Offset>.from(
        ConvexHullCalculator.convexHullForCluster(cluster),
        growable: false,
      );
      final List<Offset> corners = List<Offset>.from(
        cluster.boundingBox.corners,
        growable: false,
      );

      if (hull.isEmpty && corners.isEmpty) {
        continue;
      }

      shapes.add(ClusterShapeData(hull: hull, boundingCorners: corners));
    }

    return shapes;
  }
}

class _AssistantActionButton extends StatelessWidget {
  const _AssistantActionButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.onPressed,
    required this.isActive,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color spinnerColor = Theme.of(context).colorScheme.onPrimary;
    return Tooltip(
      message: description,
      waitDuration: const Duration(milliseconds: 400),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
        child: FilledButton(
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
