import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/infrastructure/ink_note_page_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('InkNotePageDto erstellt eine verlustfreie Domain-Repräsentation', () {
    final stroke = Stroke(
      id: 's1',
      points: [
        DrawingPoint(position: const Offset(1, 2)),
        DrawingPoint(position: const Offset(3, 4), pressure: 0.8),
      ],
      color: Colors.blue,
      baseWidth: 7,
      isHighlighter: true,
    );
    final AssistantMessage message = AssistantMessage(
      question: 'Was steht hier?',
      answer: 'Das ist ein Test',
      visionDescription: 'Eine kurze Beschreibung',
      createdAt: DateTime(2024, 10, 15, 8, 30, 0),
      reusedCachedDescription: true,
    );
    final page = NotePage(
      strokes: [stroke],
      assistantHistory: [message],
      cachedVisionDescription: 'Eine kurze Beschreibung',
    );

    final dto = InkNotePageDto.fromDomain(page, index: 0);
    final restored = dto.toDomain();

    expect(dto.index, 0);
    expect(dto.strokes, hasLength(1));
    expect(restored.strokes.single.color, equals(Colors.blue));
    expect(restored.strokes.single.isHighlighter, isTrue);
    expect(restored.strokes.single.points, hasLength(2));
    expect(restored.cachedVisionDescription, equals('Eine kurze Beschreibung'));
    expect(restored.assistantHistory, hasLength(1));
    final AssistantMessage restoredMessage = restored.assistantHistory.single;
    expect(restoredMessage.question, equals(message.question));
    expect(restoredMessage.answer, equals(message.answer));
    expect(restoredMessage.visionDescription, equals(message.visionDescription));
    expect(restoredMessage.reusedCachedDescription, isTrue);
    expect(
      restoredMessage.createdAt.toIso8601String(),
      equals(message.createdAt.toIso8601String()),
    );
  });

  test('InkNotePageDto serialisiert sich korrekt nach JSON', () {
    final stroke = Stroke(
      id: 's2',
      points: [DrawingPoint(position: const Offset(5, 6), pressure: 0.1)],
      color: Colors.red,
      baseWidth: 3,
    );
    final dto = InkNotePageDto(
      index: 3,
      strokes: [stroke],
      cachedVisionDescription: 'Kurzbeschreibung',
      assistantHistory: [
        AssistantMessage(
          question: 'Frage',
          answer: 'Antwort',
          visionDescription: 'Kurzbeschreibung',
          createdAt: DateTime(2024, 5, 10, 9, 0, 0),
        ),
      ],
    );

    final encoded = dto.toJson();
    final decoded = InkNotePageDto.fromJson(encoded);

    expect(decoded.index, 3);
    expect(decoded.strokes.single.color.value, equals(Colors.red.value));
    expect(decoded.strokes.single.points.single.pressure, closeTo(0.1, 1e-6));
    expect(decoded.cachedVisionDescription, equals('Kurzbeschreibung'));
    expect(decoded.assistantHistory, hasLength(1));
    final AssistantMessage decodedMessage = decoded.assistantHistory.single;
    expect(decodedMessage.question, equals('Frage'));
    expect(decodedMessage.answer, equals('Antwort'));
    expect(decodedMessage.visionDescription, equals('Kurzbeschreibung'));
    expect(
      decodedMessage.createdAt.toIso8601String(),
      equals(DateTime(2024, 5, 10, 9, 0, 0).toIso8601String()),
    );
    expect(decodedMessage.reusedCachedDescription, isFalse);
  });
}
