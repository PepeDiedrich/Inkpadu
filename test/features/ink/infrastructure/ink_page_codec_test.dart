import 'dart:convert';

import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_page_codec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InkNotePageCodec', () {
    test('encodes and decodes strokes losslessly within tolerance', () {
      final stroke = Stroke(
        id: 'stroke-1',
        color: const Color(0xFF123456),
        baseWidth: 5.25,
        isHighlighter: true,
        points: <DrawingPoint>[
          DrawingPoint(position: const Offset(12.345, -45.678), pressure: 0.15),
          DrawingPoint(position: const Offset(12.946, -45.001), pressure: 0.33),
          DrawingPoint(position: const Offset(25.777, -30.200), pressure: 0.91),
        ],
      );
      final page = NotePage(
        strokes: <Stroke>[stroke],
      );

      final encoded = InkNotePageCodec.encode(<NotePage>[page]);
      expect(encoded, isNotEmpty);

      final bundle = InkNotePageCodec.decode(encoded);
      expect(bundle.pages, hasLength(1));
      expect(bundle.lastOpenedPageIndex, 0);

      final NotePage decodedPage = bundle.pages.first;
      final Stroke decodedStroke = decodedPage.strokes.first;
      expect(decodedStroke.id, stroke.id);
      expect(decodedStroke.color.toARGB32(), stroke.color.toARGB32());
      expect(decodedStroke.baseWidth, closeTo(stroke.baseWidth, 1e-6));
      expect(decodedStroke.isHighlighter, stroke.isHighlighter);
      expect(decodedStroke.points, hasLength(stroke.points.length));

      for (var i = 0; i < stroke.points.length; i++) {
        final original = stroke.points[i];
        final roundTripped = decodedStroke.points[i];

        expect(roundTripped.position.dx, closeTo(original.position.dx, 0.002));
        expect(roundTripped.position.dy, closeTo(original.position.dy, 0.002));
        expect(roundTripped.pressure, closeTo(original.pressure, 0.002));
      }
    });

    test('decodes legacy JSON data as fallback', () {
      final legacy = jsonEncode({
        'strokes': [
          {
            'id': 'legacy',
            'points': [
              {'x': 0.0, 'y': 1.0, 'p': 0.5},
            ],
            'color': const Color(0xFF000000).toARGB32(),
            'width': 4.0,
            'isHighlighter': false,
          },
        ],
      });

      final bundle = InkNotePageCodec.decode(legacy);

      expect(bundle.pages, hasLength(1));
      expect(bundle.lastOpenedPageIndex, 0);
      final stroke = bundle.pages.first.strokes.first;
      expect(stroke.id, 'legacy');
      expect(stroke.points, hasLength(1));
      expect(stroke.points.first.pressure, closeTo(0.5, 1e-6));
    });
  });
}
