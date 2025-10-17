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
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage = 'Hier erscheinen KI-Antworten zu deiner Notiz.';

  late final Functions _functions;
  final DrawingSnapshotService _snapshotService =
      const DrawingSnapshotService();
  final ScrollController _contentScrollController = ScrollController();
  static const String _systemPrompt =
      'Du bist ein hilfreicher Assistent innerhalb einer Notiz-App. '
      'Nutze angehängte Bildausschnitte, um die handschriftlichen Inhalte zu interpretieren. '
      'Beschreibe Unsicherheiten oder unlesbare Bereiche transparent.';

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
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendPrompt() async {
    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isLoading) {
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

    setState(() {
      _isLoading = true;
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

      final http.Response azureRes = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (azureRes.statusCode == 200) {
        final Map<String, dynamic> body =
            json.decode(utf8.decode(azureRes.bodyBytes))
                as Map<String, dynamic>;
        final String? responseContent = _extractAssistantMessage(body);
        final String? finishReason = _firstFinishReason(body);
        final String fallbackContent = _prepareDisplayContent(
          content: responseContent,
          finishReason: finishReason,
          rawBody: body,
        );
        final String rawAnswer = responseContent ?? fallbackContent;
        final String resolvedAnswer = rawAnswer.trim().isNotEmpty
            ? rawAnswer.trim()
            : fallbackContent.trim();

        final AssistantMessage message = AssistantMessage(
          question: prompt,
          answer: resolvedAnswer,
          createdAt: DateTime.now(),
        );

        controller.appendAssistantMessage(
          message,
          visionSignature: currentSignature,
        );

        if (mounted) {
          setState(() {
            _promptController.clear();
            _statusMessage = finishReason == 'length'
                ? '⚠️ Antwort wurde nach $_maxCompletionTokens Tokens abgeschnitten.'
                : null;
          });
        }
      } else {
        throw Exception(
          'Azure-Fehler: ${azureRes.statusCode} ${azureRes.body}',
        );
      }
    } on FormatException catch (e) {
      setState(() {
        _statusMessage = 'Fehler: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Fehler: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _extractAssistantMessage(Map<String, dynamic> body) {
    final dynamic choices = body['choices'];
    if (choices is! List || choices.isEmpty) {
      return null;
    }

    final dynamic firstChoice = choices.first;
    if (firstChoice is! Map<String, dynamic>) {
      return null;
    }

    final dynamic message = firstChoice['message'];
    if (message is Map<String, dynamic>) {
      final dynamic content = message['content'];
      final String? extracted = _normalizeContent(content);
      if (extracted != null) {
        return extracted;
      }
    }

    final dynamic delta = firstChoice['delta'];
    if (delta is Map<String, dynamic>) {
      final String? extracted = _normalizeContent(delta['content']);
      if (extracted != null) {
        return extracted;
      }
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

  String _prepareDisplayContent({
    required String? content,
    required String? finishReason,
    required Map<String, dynamic> rawBody,
  }) {
    if (content != null) {
      if (finishReason == 'length') {
        return '''$content

---
⚠️ Antwort wurde nach $_maxCompletionTokens Tokens abgeschnitten. Stell sicher, dass dein Prompt kürzer ist oder erhöhe das Limit.''';
      }
      return content;
    }

    if (finishReason == 'length') {
      final String fallback =
          _fallbackFromRawBody(rawBody) ??
          'Antwort konnte nicht gelesen werden.';
      return '''⚠️ Das Modell hat das Tokenlimit ($_maxCompletionTokens) erreicht, bevor Text zurückgegeben wurde.

$fallback''';
    }

    return _fallbackFromRawBody(rawBody) ??
        'Antwort konnte nicht gelesen werden.';
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

  String? _normalizeContent(dynamic content) {
    if (content is String) {
      final String trimmed = content.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (content is List) {
      final StringBuffer buffer = StringBuffer();
      for (final dynamic entry in content) {
        if (entry is Map<String, dynamic>) {
          final String? textValue =
              _resolvedText(entry['text']) ??
              _resolvedText(entry['content']) ??
              _resolvedText(entry['value']);
          if (textValue != null && textValue.isNotEmpty) {
            if (buffer.isNotEmpty) {
              buffer.writeln();
            }
            buffer.write(textValue);
          }
        } else if (entry is String && entry.trim().isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(entry.trim());
        }
      }

      final String combined = buffer.toString().trim();
      return combined.isEmpty ? null : combined;
    }

    return null;
  }

  String? _resolvedText(dynamic value) {
    if (value is String) {
      final String trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (value is Map<String, dynamic>) {
      final String? inner = _resolvedText(
        value['text'] ?? value['content'] ?? value['value'],
      );
      if (inner != null) {
        return inner;
      }

      final dynamic parts =
          value['parts'] ?? value['content'] ?? value['segments'];
      if (parts is List) {
        return _normalizeContent(parts);
      }
    }

    if (value is List) {
      return _normalizeContent(value);
    }

    return null;
  }

  String? _fallbackFromRawBody(Map<String, dynamic> body) {
    try {
      return const JsonEncoder.withIndent('  ').convert(body);
    } catch (_) {
      return body.toString();
    }
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
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _promptController,
                        decoration: const InputDecoration(
                          hintText: 'Frage an den KI-Assistenten…',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendPrompt(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _sendPrompt,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                      label: Text(_isLoading ? 'Senden…' : 'Senden'),
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
