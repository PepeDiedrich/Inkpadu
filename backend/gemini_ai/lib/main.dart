import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

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
      body = jsonDecode(req.body as String);
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

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'text': Schema.string(description: 'The helpful response text.'),
            'boxes': Schema.array(
              description:
                  'A list of bounding boxes highlighting errors or important parts. Coordinates normalized 0-1000.',
              items: Schema.object(
                properties: {
                  'ymin': Schema.integer(),
                  'xmin': Schema.integer(),
                  'ymax': Schema.integer(),
                  'xmax': Schema.integer(),
                  'description': Schema.string(),
                  'color': Schema.string(),
                },
              ),
            ),
          },
        ),
      ),
    );

    final parts = <Part>[];
    if (prompt != null && prompt.isNotEmpty) {
      parts.add(TextPart(prompt));
    } else {
      parts.add(
        TextPart(
          'Please analyze this handwriting or drawing and provide a helpful response. Highlight important elements with bounding boxes.',
        ),
      );
    }

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      try {
        final imageBytes = base64Decode(imageBase64);
        parts.add(DataPart('image/png', imageBytes));
        log('Image decoded successfully. Size: ${imageBytes.length} bytes');
      } catch (e) {
        return res.json({'error': 'Invalid base64 image data'}, 400);
      }
    }

    log('Calling Gemini API...');
    final response = await model.generateContent([Content.multi(parts)]);

    final responseText = response.text;
    log('Gemini API responded in ${stopwatch.elapsedMilliseconds}ms');

    if (responseText == null || responseText.isEmpty) {
      error(
        'Gemini returned an empty response. FinishReason: ${response.promptFeedback?.blockReason}',
      );
      return res.json({
        'error': 'No response from AI model. It might have been blocked.',
      }, 500);
    }

    // Resilient JSON parsing (handling potential markdown formatting)
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
      'boxes': responseJson['boxes'] ?? [],
    });
  } catch (e, stackTrace) {
    error('Unhandled exception after ${stopwatch.elapsedMilliseconds}ms: $e');
    error(stackTrace.toString());
    return res.json({'error': e.toString()}, 500);
  } finally {
    stopwatch.stop();
  }
}
