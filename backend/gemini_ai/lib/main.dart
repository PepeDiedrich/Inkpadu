import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<dynamic> main(final dynamic context) async {
  final req = context.req;
  final res = context.res;
  final error = context.error;
  final log = context.log;

  final stopwatch = Stopwatch()..start();

  try {
    // Robust parsing of the request body
    Map<String, dynamic> body;
    if (req.body is String) {
      if ((req.body as String).isEmpty) {
        return res.json({'error': 'Empty request body'}, 400);
      }
      body = jsonDecode(req.body as String) as Map<String, dynamic>;
    } else if (req.body is Map) {
      body = Map<String, dynamic>.from(req.body as Map);
    } else {
      return res.json({
        'error': 'Invalid request body type: ${req.body.runtimeType}',
      }, 400);
    }

    final String? prompt = body['prompt']?.toString();
    final String? imageBase64 = body['image']?.toString();

    log(
      'Request received. Prompt length: ${prompt?.length ?? 0}, Image provided: ${imageBase64 != null}',
    );

    if (prompt == null && imageBase64 == null) {
      return res.json({'error': 'Prompt or image is required'}, 400);
    }

    final String? apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      error('GEMINI_API_KEY is not set in environment variables');
      return res.json({'error': 'Server configuration error'}, 500);
    }

    // --- Build the Gemini REST API request ---
    const modelId = 'gemini-3-flash-preview';
    const apiEndpoint = 'https://generativelanguage.googleapis.com';
    final uri = Uri.parse(
      '$apiEndpoint/v1beta/models/$modelId:generateContent?key=$apiKey',
    );

    const systemPrompt =
        'Du bist ein hilfsbereiter, sokratischer Tutor für handschriftliche und gezeichnete Notizen. '
        'Dein Ziel ist es, den Nutzer beim Lernen zu unterstützen. Wenn der Nutzer Fehler macht, erkläre sie verständlich und rege zum Nachdenken an, anstatt direkt die Lösung zu verraten. '
        'Wenn es sinnvoll ist, um Fehler, wichtige Konzepte oder bestimmte Gleichungsteile hervorzuheben, verwende Bounding Boxes. '
        'Diese Bounding Boxes MÜSSEN im JSON "boxes" Array enthalten sein und verwenden normalisierte Koordinaten (0-1000) für ymin, xmin, ymax, xmax. '
        'Du kannst auch "color" (z.B. "red", "green", "blue") für die Bounding Boxes angeben, um z.B. Fehler rot und korrekte Dinge grün zu markieren. '
        'Antworte IMMER nur mit einem JSON-Objekt mit den Feldern "text" (string) und "boxes" (array).';

    // Build parts array
    final List<Map<String, dynamic>> parts = [];
    if (prompt != null && prompt.isNotEmpty) {
      parts.add({'text': prompt});
    } else {
      parts.add({'text': 'Bitte analysiere diese Notizen.'});
    }

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      parts.add({
        'inlineData': {'mimeType': 'image/png', 'data': imageBase64},
      });
    }

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt},
        ],
      },
      'contents': [
        {'role': 'user', 'parts': parts},
      ],
      'generationConfig': {
        'thinkingConfig': {'thinkingLevel': 'LOW'},
        'mediaResolution': 'MEDIA_RESOLUTION_HIGH',
        'responseMimeType': 'application/json',
        'responseSchema': {
          'type': 'OBJECT',
          'properties': {
            'text': {
              'type': 'STRING',
              'description': 'The helpful response text.',
            },
            'boxes': {
              'type': 'ARRAY',
              'description':
                  'Bounding boxes highlighting errors or important parts. Coordinates 0-1000.',
              'items': {
                'type': 'OBJECT',
                'properties': {
                  'ymin': {'type': 'INTEGER'},
                  'xmin': {'type': 'INTEGER'},
                  'ymax': {'type': 'INTEGER'},
                  'xmax': {'type': 'INTEGER'},
                  'description': {'type': 'STRING'},
                  'color': {'type': 'STRING'},
                },
              },
            },
          },
        },
      },
    };

    log('Calling Gemini REST API (model: $modelId)...');

    final httpClient = HttpClient();
    httpClient.connectionTimeout = const Duration(seconds: 60);

    final httpRequest = await httpClient.postUrl(uri);
    httpRequest.headers.set('Content-Type', 'application/json');
    httpRequest.write(jsonEncode(requestBody));

    final httpResponse = await httpRequest.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();

    log(
      'Gemini API responded in ${stopwatch.elapsedMilliseconds}ms with status ${httpResponse.statusCode}',
    );

    if (httpResponse.statusCode != 200) {
      error('Gemini API error ${httpResponse.statusCode}: $responseBody');
      return res.json({
        'error': 'Gemini API error: ${httpResponse.statusCode}',
        'details': responseBody,
      }, 502);
    }

    final Map<String, dynamic> geminiResponse =
        jsonDecode(responseBody) as Map<String, dynamic>;

    // Extract the response text from the candidates
    String? responseText;
    try {
      final candidates = geminiResponse['candidates'] as List<dynamic>;
      final content = candidates[0]['content'] as Map<String, dynamic>;
      final responseParts = content['parts'] as List<dynamic>;
      // The model may return thinking parts and then a text part; find the last text part
      for (final part in responseParts.reversed) {
        final partMap = part as Map<String, dynamic>;
        if (partMap.containsKey('text')) {
          responseText = partMap['text'] as String;
          break;
        }
      }
    } catch (e) {
      error('Failed to extract text from Gemini response: $e');
      return res.json({'error': 'Unexpected Gemini response format'}, 500);
    }

    if (responseText == null || responseText.isEmpty) {
      error('Gemini returned empty response text.');
      return res.json({'error': 'Empty response from AI model'}, 500);
    }

    // Parse the JSON response
    dynamic responseJson;
    try {
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      responseJson = jsonDecode(cleanJson.trim());
    } catch (e) {
      error('Failed to parse Gemini JSON: $e. Content: $responseText');
      return res.json({'error': 'Invalid format in AI response'}, 500);
    }

    return res.json({
      'success': true,
      'text': responseJson['text'] ?? 'No text provided',
      'boxes': responseJson['boxes'] ?? <dynamic>[],
    });
  } catch (e, stackTrace) {
    error('Unhandled exception after ${stopwatch.elapsedMilliseconds}ms: $e');
    error(stackTrace.toString());
    return res.json({'error': e.toString()}, 500);
  } finally {
    stopwatch.stop();
  }
}
