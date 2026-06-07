import 'package:inkpadu/features/drawing/domain/drawing_point.dart';
import 'package:inkpadu/features/drawing/domain/note_page.dart';
import 'package:inkpadu/features/drawing/domain/stroke.dart';
import 'package:inkpadu/features/ink/infrastructure/ink_note_page_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InkNotePageDto erstellt eine verlustfreie Domain-Repräsentation', () {
    final stroke = Stroke(
      id: 's1',
      points: [
        DrawingPoint(position: const Offset(1, 2)),
        DrawingPoint(position: const Offset(3, 4)),
      ],
      color: Colors.blue,
      baseWidth: 7,
      isHighlighter: true,
    );
    final page = NotePage(strokes: [stroke]);

    final dto = InkNotePageDto.fromDomain(page, index: 0);
    final restored = dto.toDomain();

    expect(dto.index, 0);
    expect(dto.strokes, hasLength(1));
    expect(restored.strokes.single.color, equals(Colors.blue));
    expect(restored.strokes.single.isHighlighter, isTrue);
    expect(restored.strokes.single.points, hasLength(2));
  });

  test('InkNotePageDto serialisiert sich korrekt nach JSON', () {
    final stroke = Stroke(
      id: 's2',
      points: [DrawingPoint(position: const Offset(5, 6))],
      color: Colors.red,
      baseWidth: 3,
    );
    final dto = InkNotePageDto(index: 3, strokes: [stroke]);

    final encoded = dto.toJson();
    final decoded = InkNotePageDto.fromJson(encoded);

    expect(decoded.index, 3);
    expect(
      decoded.strokes.single.color.toARGB32(),
      equals(Colors.red.toARGB32()),
    );
    expect(decoded.strokes.single.points.single.position, isNotNull);
  });
}
