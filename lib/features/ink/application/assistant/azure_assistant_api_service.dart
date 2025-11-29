import 'dart:async';
import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:appwrite/models.dart';
import 'package:http/http.dart' as http;

/// Verwaltet Authentifizierung, Request-Aufbau und Streaming gegen Azure OpenAI.
/// 
/// Diese Klasse kümmert sich um die Kommunikation mit der Azure OpenAI API,
/// einschließlich Token-Verwaltung, Request-Vorbereitung, Streaming und
/// Antwort-Verarbeitung.
class AzureAssistantApiService {
  /// Erstellt eine neue Instanz des Azure Assistant API Service.
  /// 
  /// Die Parameter ermöglichen die Konfiguration der Azure OpenAI Verbindung.
  AzureAssistantApiService({
    required Functions functions,
    String functionId = 'llm_auth',
    String azureResourceName = 'peped-mgjk16o0-eastus2',
    String azureDeploymentName = 'gpt-5-nano',
    String azureApiVersion = '2025-01-01-preview',
  })  : _functions = functions,
        _functionId = functionId,
        _azureResourceName = azureResourceName,
        _azureDeploymentName = azureDeploymentName,
        _azureApiVersion = azureApiVersion;

  final Functions _functions;
  final String _functionId;
  final String _azureResourceName;
  final String _azureDeploymentName;
  final String _azureApiVersion;

  static const JsonEncoder _prettyEncoder = JsonEncoder.withIndent('  ');

  /// Baut die API-Payload auf und erzeugt eine Vorschau zur Anzeige im UI.
  AzureAssistantPreparedRequest prepareRequest(AzureAssistantRequest request) {
    final Map<String, dynamic> payload = _buildAzureRequest(request);
    final String payloadPreview = _prettyEncoder.convert(payload);
    return AzureAssistantPreparedRequest(
      request: request,
      payload: payload,
      payloadPreview: payloadPreview,
    );
  }

  /// Startet einen Streaming-Aufruf bei Azure und liefert das Endergebnis.
  Future<AzureAssistantResult> streamCompletion({
    required AzureAssistantPreparedRequest preparedRequest,
    required void Function(String aggregatedText) onStreamUpdate,
    void Function()? onStreamStarted,
  }) async {
    final Execution execution = await _createExecution();
    final String responseBody = await _resolveExecutionResponse(execution);
    final Map<String, dynamic> tokenResponse =
        json.decode(responseBody) as Map<String, dynamic>;

    if (tokenResponse['success'] != true) {
      throw Exception(
        'Konnte Azure-Token nicht erhalten: ${tokenResponse['error']}',
      );
    }

    final String token = tokenResponse['accessToken'] as String;
    final Uri url = Uri.parse(
      'https://$_azureResourceName.openai.azure.com/openai/deployments/$_azureDeploymentName/chat/completions?api-version=$_azureApiVersion',
    );

    final Map<String, dynamic> payload = preparedRequest.payload;
    final String payloadPreview = preparedRequest.payloadPreview;

    final http.Client client = http.Client();
    String accumulatedContent = '';
    String? finishReason;

    try {
      final http.Request httpRequest = http.Request('POST', url)
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..body = json.encode(payload);

      final http.StreamedResponse streamedResponse = await client.send(httpRequest);

      if (streamedResponse.statusCode != 200) {
        final String errorBody = await streamedResponse.stream.bytesToString();
        throw Exception('Azure-Fehler: ${streamedResponse.statusCode} $errorBody');
      }

      onStreamStarted?.call();

      final Stream<String> lineStream = streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter());

      await for (final String line in lineStream) {
        final String trimmed = line.trim();
        if (trimmed.isEmpty || !trimmed.startsWith('data:')) {
          continue;
        }
        final String dataPayload = trimmed.substring(5).trim();
        if (dataPayload.isEmpty || dataPayload == '[DONE]') {
          if (dataPayload == '[DONE]') {
            break;
          }
          continue;
        }

        Map<String, dynamic> chunk;
        try {
          chunk = json.decode(dataPayload) as Map<String, dynamic>;
        } catch (_) {
          continue;
        }

        final String? delta =
            _extractDeltaContent(chunk, preserveWhitespace: true);
        if (delta != null && delta.isNotEmpty) {
          accumulatedContent += delta;
          onStreamUpdate(accumulatedContent);
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
      ? '⚠️ Antwort wurde nach ${preparedRequest.request.maxCompletionTokens} Tokens abgeschnitten.'
            : 'Das Modell hat keine Antwort gesendet.';

    return AzureAssistantResult(
      answer: resolvedAnswer,
      finishReason: finishReason,
      payloadPreview: payloadPreview,
    );
  }

  Future<Execution> _createExecution() => _functions.createExecution(
    functionId: _functionId,
    xasync: false,
  );

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

  bool _hasTerminalResponse(Execution execution) =>
    execution.responseBody.trim().isNotEmpty ||
    execution.errors.trim().isNotEmpty ||
    execution.status == appwrite_enums.ExecutionStatus.completed ||
    execution.status == appwrite_enums.ExecutionStatus.failed;

  Map<String, dynamic> _buildAzureRequest(AzureAssistantRequest request) {
    final List<Map<String, dynamic>> messages = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': <Map<String, dynamic>>[
          {'type': 'text', 'text': request.systemPrompt},
        ],
      },
    ];

    // PDF-Kontext als separate System-Nachricht hinzufügen.
    // Dieser wird immer vollständig mitgesendet und nicht abgeschnitten.
    if (request.pdfContext != null && request.pdfContext!.isNotEmpty) {
      messages.add({
        'role': 'system',
        'content': <Map<String, dynamic>>[
          {
            'type': 'text',
            'text':
                'Der folgende Text wurde aus einem PDF importiert und dient als Kontext für die Aufgabe. '
                'Dieser Kontext ist vollständig und soll bei der Beantwortung berücksichtigt werden:\n\n'
                '${request.pdfContext}',
          },
        ],
      });
    }

    messages.add({'role': 'user', 'content': request.userContent});

    return <String, dynamic>{
      'messages': messages,
      'max_completion_tokens': request.maxCompletionTokens,
      'response_format': const {'type': 'text'},
      'stream': true,
    };
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
}

/// Eingabestruktur für einen Chat-Vorgang beim Azure-Deployment.
class AzureAssistantRequest {
  /// Erstellt eine neue Request-Struktur für Azure OpenAI.
  /// 
  /// [systemPrompt] ist die System-Anweisung für das Modell.
  /// [userContent] enthält die Nachrichteninhalte des Benutzers (möglicherweise mit Bildern).
  /// [maxCompletionTokens] begrenzt die Länge der Antwort.
  /// [pdfContext] ist optionaler PDF-Text, der immer vollständig als
  /// Kontext mitgesendet wird und nicht zum Token-Limit zählt.
  const AzureAssistantRequest({
    required this.systemPrompt,
    required this.userContent,
    required this.maxCompletionTokens,
    this.pdfContext,
  });

  /// Die System-Anweisung für das Modell.
  final String systemPrompt;

  /// Die Nachrichteninhalte des Benutzers.
  final List<Map<String, dynamic>> userContent;

  /// Die maximale Anzahl von Tokens für die Antwort.
  final int maxCompletionTokens;

  /// Optionaler PDF-Text, der als Kontext immer vollständig mitgesendet wird.
  /// Dieser zählt nicht zum max_completion_tokens Limit.
  final String? pdfContext;
}

/// Enthält die serialisierte Payload inklusive Vorschau für Debug-Zwecke.
class AzureAssistantPreparedRequest {
  /// Erstellt eine vorbereitet Request-Struktur mit Payload und Vorschau.
  /// 
  /// Diese Struktur wird verwendet, um die Payload vor dem Absenden an Azure
  /// zu debuggen und anzuzeigen.
  const AzureAssistantPreparedRequest({
    required this.request,
    required this.payload,
    required this.payloadPreview,
  });

  /// Die ursprüngliche Request-Struktur.
  final AzureAssistantRequest request;

  /// Die serialisierte Payload für Azure OpenAI.
  final Map<String, dynamic> payload;

  /// Die formatierte Payload-Vorschau zur Anzeige.
  final String payloadPreview;
}

/// Ergebnis eines Streaming-Aufrufs inklusive Abschlussgrund.
class AzureAssistantResult {
  /// Erstellt eine neue Result-Struktur für die Antwort von Azure OpenAI.
  /// 
  /// [answer] enthält die Antwort des Modells.
  /// [finishReason] gibt den Grund für das Abschließen an (z.B. 'length' bei Tokenüberlauf).
  /// [payloadPreview] enthält die Debug-Vorschau der Payload.
  const AzureAssistantResult({
    required this.answer,
    required this.finishReason,
    required this.payloadPreview,
  });

  /// Die Antwort des Modells.
  final String answer;

  /// Der Grund, warum die Antwort beendet wurde.
  final String? finishReason;

  /// Die formatierte Payload-Vorschau zur Anzeige.
  final String payloadPreview;

  /// Kennzeichnet, ob Azure die Antwort aufgrund eines Tokenlimits abgebrochen hat.
  bool get wasTruncated => finishReason == 'length';
}
