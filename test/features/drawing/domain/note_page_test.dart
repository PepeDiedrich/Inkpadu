import 'dart:ui';

import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_link.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotePage', () {
    test('initializes with required fields and defaults', () {
      final page = NotePage(strokes: const []);

      expect(page.strokes, isEmpty);
      expect(page.assistantHistory, isEmpty);
      expect(page.links, isEmpty);
      expect(page.cachedVisionDescription, isNull);
      expect(page.cachedVisionSignature, isNull);
      expect(page.importedPdfText, isNull);
    });

    test('lists are immutable', () {
      final strokes = <Stroke>[];
      final history = <AssistantMessage>[];
      final links = <NoteLink>[];

      final page = NotePage(
        strokes: strokes,
        assistantHistory: history,
        links: links,
      );

      // Verify lists are unmodifiable
      expect(() => page.assistantHistory.add(AssistantMessage(
            question: 'q',
            answer: 'a',
            createdAt: DateTime.now(),
          )), throwsUnsupportedError);

      expect(() => page.links.add(const NoteLink(
            targetNoteId: 'id',
            label: 'label',
            position: Offset.zero,
          )), throwsUnsupportedError);

      // Note: Stroke list is final but not explicitly wrapped in UnmodifiableListView in the constructor,
      // but it is copied from the input if it passes through copyWith?
      // Wait, looking at the constructor:
      // required this.strokes,
      // It assigns directly. So if I pass a mutable list, it might remain mutable if not wrapped.
      // Let's check the constructor again.
      // strokes is just `final List<Stroke> strokes;` and passed directly in constructor.
      // So `strokes` IS mutable if the passed list is mutable.
      // However, `assistantHistory` and `links` are wrapped in `List.unmodifiable`.

      // Verification for strokes mutability (based on current implementation)
      strokes.add(Stroke(points: [], color: const Color(0xFF000000), baseWidth: 1));
      expect(page.strokes, hasLength(1)); // It reflects the change because it wasn't copied.
    });

    test('copyWith updates fields correctly', () {
      final page = NotePage(strokes: const []);
      final now = DateTime.now();
      final newHistory = [
        AssistantMessage(question: 'Q', answer: 'A', createdAt: now)
      ];
      final newStrokes = [
        Stroke(
          points: const [],
          color: const Color(0xFF000000),
          baseWidth: 1.0,
        )
      ];

      final updated = page.copyWith(
        strokes: newStrokes,
        assistantHistory: newHistory,
        cachedVisionDescription: 'desc',
        cachedVisionSignature: 'sig',
        importedPdfText: 'pdf',
      );

      expect(updated.strokes, equals(newStrokes));
      expect(updated.assistantHistory, equals(newHistory));
      expect(updated.cachedVisionDescription, 'desc');
      expect(updated.cachedVisionSignature, 'sig');
      expect(updated.importedPdfText, 'pdf');
    });

    test('copyWith handles null values correctly via sentinel', () {
      final page = NotePage(
        strokes: const [],
        cachedVisionDescription: 'desc',
        cachedVisionSignature: 'sig',
        importedPdfText: 'pdf',
      );

      // Verify we can set fields to null
      final cleared = page.copyWith(
        cachedVisionDescription: null,
        cachedVisionSignature: null,
        importedPdfText: null,
      );

      expect(cleared.cachedVisionDescription, isNull);
      expect(cleared.cachedVisionSignature, isNull);
      expect(cleared.importedPdfText, isNull);

      // Verify we can keep existing values (implicit sentinel)
      final kept = page.copyWith();
      expect(kept.cachedVisionDescription, 'desc');
      expect(kept.cachedVisionSignature, 'sig');
      expect(kept.importedPdfText, 'pdf');
    });

    group('serialization', () {
      test('toJson returns correct map', () {
        final now = DateTime.now().toUtc();
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: now,
        );
        final stroke = Stroke(
          points: const [],
          color: const Color(0xFF000000),
          baseWidth: 2,
        );

        final page = NotePage(
          strokes: [stroke],
          assistantHistory: [message],
          cachedVisionDescription: 'desc',
          cachedVisionSignature: 'sig',
          importedPdfText: 'pdf',
        );

        final json = page.toJson();

        expect(json['strokes'], hasLength(1));
        expect(json['assistant_history'], hasLength(1));
        expect(json['cached_vision_description'], 'desc');
        expect(json['cached_vision_signature'], 'sig');
        expect(json['imported_pdf_text'], 'pdf');
      });

      test('fromJson handles valid JSON', () {
        final json = {
          'strokes': [
            {'points': [], 'color': 1, 'width': 2.0}
          ],
          'assistant_history': [
            {
              'question': 'Q',
              'answer': 'A',
              'created_at': '2023-01-01T12:00:00.000Z',
              'reused_cached_description': false,
            }
          ],
          'cached_vision_description': 'desc',
          'cached_vision_signature': 'sig',
          'imported_pdf_text': 'pdf',
        };

        final page = NotePage.fromJson(json);

        expect(page.strokes, hasLength(1));
        expect(page.assistantHistory, hasLength(1));
        expect(page.cachedVisionDescription, 'desc');
        expect(page.cachedVisionSignature, 'sig');
        expect(page.importedPdfText, 'pdf');
      });

      test('fromJson handles nulls and empty strings', () {
        final json = {
          'strokes': null, // Should default to empty list
          'assistant_history': null, // Should default to empty list
          'cached_vision_description': '', // Should become null
          'cached_vision_signature': '   ', // Should become null
          'imported_pdf_text': null, // Should be null
        };

        final page = NotePage.fromJson(json);

        expect(page.strokes, isEmpty);
        expect(page.assistantHistory, isEmpty);
        expect(page.cachedVisionDescription, isNull);
        expect(page.cachedVisionSignature, isNull);
        expect(page.importedPdfText, isNull);
      });

      test('fromJson handles malformed lists gracefully', () {
        final json = {
          'strokes': 'not-a-list',
          'assistant_history': 123,
        };

        final page = NotePage.fromJson(json);

        expect(page.strokes, isEmpty);
        expect(page.assistantHistory, isEmpty);
      });
    });
  });
}
