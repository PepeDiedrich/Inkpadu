// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'dart:ui' as ui;

import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:inkpadu/app/auth/appwrite_config.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/drawing_canvas.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/utils/image_scale_util.dart';
import 'package:inkpadu/features/ink/presentation/drawing_note/widgets/ai_lasso_panel/utils/ai_color_parser.dart';
import 'package:flutter/material.dart';

class AiAnalysisResponse {
  final String text;
  final List<AiBoundingBox> boxes;
  final String? generatedHtml;

  AiAnalysisResponse({
    required this.text,
    required this.boxes,
    this.generatedHtml,
  });
}

class AiLassoService {
  static Future<AiAnalysisResponse> executeAiRequest({
    required Future<({ui.Image image, Rect bounds})?> Function() captureRegion,
    required String prompt,
    required String systemPrompt,
  }) async {
    final effectivePrompt = systemPrompt.isEmpty
        ? prompt
        : 'System instruction:\n$systemPrompt\n\nUser request:\n$prompt';

    final capturedResult = await captureRegion();
    if (capturedResult == null) {
      throw Exception('Could not capture canvas region');
    }

    final ui.Image imageToEncode = await scaleImageIfNeeded(
      capturedResult.image,
    );

    final byteData = await imageToEncode.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) throw Exception('Could not encode image data');

    final base64Image = base64Encode(byteData.buffer.asUint8List());
    final functions = appwrite.Functions(AppwriteConfig.client);
    final execution = await functions.createExecution(
      functionId: AppwriteConfig.aiFunctionId,
      body: jsonEncode({'image': base64Image, 'prompt': effectivePrompt}),
    );

    if (execution.status == 'completed') {
      final responseBody = jsonDecode(execution.responseBody);
      final List<AiBoundingBox> parsedBoxes = [];
      final selectionBounds = capturedResult.bounds;
      if (responseBody['boxes'] != null && responseBody['boxes'] is Iterable) {
        for (final box in responseBody['boxes'] as Iterable) {
          final ymin = (box['ymin'] as num).toDouble() / 1000.0;
          final xmin = (box['xmin'] as num).toDouble() / 1000.0;
          final ymax = (box['ymax'] as num).toDouble() / 1000.0;
          final xmax = (box['xmax'] as num).toDouble() / 1000.0;
          parsedBoxes.add(
            AiBoundingBox(
              Rect.fromLTRB(
                selectionBounds.left + xmin * selectionBounds.width,
                selectionBounds.top + ymin * selectionBounds.height,
                selectionBounds.left + xmax * selectionBounds.width,
                selectionBounds.top + ymax * selectionBounds.height,
              ),
              parseAiBoxColor(box['color']),
            ),
          );
        }
      }

      final answer = responseBody['text']?.toString() ?? 'No response';
      String? generatedHtml;
      if (answer.isNotEmpty) {
        final htmlMatch = RegExp(
          r'```(?:html|javascript|js)?\n(.*?)```',
          dotAll: true,
        ).firstMatch(answer);
        if (htmlMatch != null) {
          generatedHtml = htmlMatch.group(1);
        } else if (answer.trim().startsWith('<') &&
            answer.trim().endsWith('>')) {
          generatedHtml = answer.trim();
        }
      }

      return AiAnalysisResponse(
        text: answer,
        boxes: parsedBoxes,
        generatedHtml: generatedHtml,
      );
    } else {
      throw Exception('AI Function Error: ${execution.responseBody}');
    }
  }
}
