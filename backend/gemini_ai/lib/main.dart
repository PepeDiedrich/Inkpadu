import 'dart:async';
import 'dart:convert';
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
    final String? apiKey = req.variables['GEMINI_API_KEY']?.toString();
    if (apiKey == null || apiKey.isEmpty) {
      return res.json({'error': 'GEMINI_API_KEY is not set'}, 500);
    }

    // Initialize the Gemini model
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final parts = <Part>[];

    if (prompt != null && prompt.isNotEmpty) {
      parts.add(TextPart(prompt));
    } else {
      // Default prompt if none provided
      parts.add(TextPart('Please analyze this handwriting or drawing and provide a helpful response.'));
    }

    if (imageBase64 != null && imageBase64.isNotEmpty) {
      // Decode base64 image
      final imageBytes = base64Decode(imageBase64);
      parts.add(DataPart('image/png', imageBytes));
    }

    final content = [Content.multi(parts)];

    final response = await model.generateContent(content);

    return res.json({
      'success': true,
      'text': response.text,
    });
  } catch (e, stackTrace) {
    error(e.toString());
    error(stackTrace.toString());
    return res.json({'error': e.toString()}, 500);
  }
}
