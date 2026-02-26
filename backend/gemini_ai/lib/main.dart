import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';

Future<dynamic> main(final dynamic context) async {
  final req = context.req;
  final res = context.res;
  final error = context.error;

  try {
    // Parse the request body
    final body = req.body is String ? jsonDecode(req.body as String) : req.body;
    final String? prompt = body['prompt']?.toString();
    final String? imageBase64 = body['image']?.toString(); // Base64 encoded image

    if (prompt == null && imageBase64 == null) {
      return res.json({'error': 'Prompt or image is required'}, 400);
    }

    // Get the Gemini API key from environment variables
    final String? apiKey = Platform.environment['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return res.json({'error': 'GEMINI_API_KEY is not set'}, 500);
    }

    // Initialize the Gemini model
    final model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: Schema.object(
          properties: {
            'text': Schema.string(description: 'The helpful response text.'),
            'boxes': Schema.array(
              description: 'A list of bounding boxes highlighting errors or important parts. Coordinates should be normalized between 0 and 1000.',
              items: Schema.object(
                properties: {
                  'ymin': Schema.integer(description: 'Top Y coordinate (0-1000)'),
                  'xmin': Schema.integer(description: 'Left X coordinate (0-1000)'),
                  'ymax': Schema.integer(description: 'Bottom Y coordinate (0-1000)'),
                  'xmax': Schema.integer(description: 'Right X coordinate (0-1000)'),
                  'description': Schema.string(description: 'Description of what is highlighted'),
                  'color': Schema.string(description: 'Hex color code for the box (e.g. #FF0000, #00FF00, #0000FF). Use different colors for different boxes.'),
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
      // Default prompt if none provided
      parts.add(TextPart('Please analyze this handwriting or drawing and provide a helpful response. If you find multiple distinct elements or errors, highlight them with bounding boxes using different colors for each box.'));
    }

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      // Decode base64 image
      final imageBytes = base64Decode(imageBase64);
      parts.add(DataPart('image/png', imageBytes));
    }

    final content = [Content.multi(parts)];

    final response = await model.generateContent(content);

    // The response text is already a JSON string because of responseMimeType
    final responseJson = jsonDecode(response.text ?? '{}');

    return res.json({
      'success': true,
      'text': responseJson['text'],
      'boxes': responseJson['boxes'],
    });
  } catch (e, stackTrace) {
    error(e.toString());
    error(stackTrace.toString());
    return res.json({'error': e.toString()}, 500);
  }
}
