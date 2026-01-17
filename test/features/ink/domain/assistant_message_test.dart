import 'package:ai_handwriting_app/features/ink/domain/assistant_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantMessage', () {
    test('initializes correctly', () {
      final now = DateTime.now();
      final message = AssistantMessage(
        question: 'Q',
        answer: 'A',
        visionDescription: 'desc',
        createdAt: now,
        reusedCachedDescription: true,
      );

      expect(message.question, 'Q');
      expect(message.answer, 'A');
      expect(message.visionDescription, 'desc');
      expect(message.createdAt, now);
      expect(message.reusedCachedDescription, isTrue);
    });

    test('copyWith updates fields', () {
      final now = DateTime.now();
      final message = AssistantMessage(
        question: 'Q',
        answer: 'A',
        createdAt: now,
      );

      final updated = message.copyWith(
        question: 'Q2',
        answer: 'A2',
        visionDescription: 'desc2',
        reusedCachedDescription: true,
      );

      expect(updated.question, 'Q2');
      expect(updated.answer, 'A2');
      expect(updated.visionDescription, 'desc2');
      expect(updated.createdAt, now);
      expect(updated.reusedCachedDescription, isTrue);
    });

    test('copyWith handles null values correctly via sentinel', () {
      final message = AssistantMessage(
        question: 'Q',
        answer: 'A',
        visionDescription: 'desc',
        createdAt: DateTime.now(),
      );

      final cleared = message.copyWith(visionDescription: null);
      expect(cleared.visionDescription, isNull);

      final kept = message.copyWith();
      expect(kept.visionDescription, 'desc');
    });

    test('toJson returns correct map', () {
      final now = DateTime.utc(2023, 1, 1, 12, 0, 0);
      final message = AssistantMessage(
        question: 'Q',
        answer: 'A',
        visionDescription: 'desc',
        createdAt: now,
        reusedCachedDescription: true,
      );

      final json = message.toJson();

      expect(json, {
        'question': 'Q',
        'answer': 'A',
        'vision_description': 'desc',
        'created_at': '2023-01-01T12:00:00.000Z',
        'reused_cached_description': true,
      });
    });

    test('fromJson handles standard JSON', () {
      final json = {
        'question': 'Q',
        'answer': 'A',
        'vision_description': 'desc',
        'created_at': '2023-01-01T12:00:00.000Z',
        'reused_cached_description': true,
      };

      final message = AssistantMessage.fromJson(json);

      expect(message.question, 'Q');
      expect(message.answer, 'A');
      expect(message.visionDescription, 'desc');
      expect(message.createdAt.toUtc().year, 2023);
      expect(message.reusedCachedDescription, isTrue);
    });

    test('fromJson handles int timestamp', () {
      final now = DateTime.utc(2023, 1, 1, 12, 0, 0);
      final json = {
        'created_at': now.millisecondsSinceEpoch,
      };

      final message = AssistantMessage.fromJson(json);

      // We compare milliseconds to avoid timezone issues, but ensure we check rough equality
      expect(
        message.createdAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
    });

    test('fromJson handles int/boolean flexible types', () {
      final json = {
        'reused_cached_description': 1, // int treated as bool true
      };
      final message = AssistantMessage.fromJson(json);
      expect(message.reusedCachedDescription, isTrue);

      final json2 = {
        'reused_cached_description': 0, // int treated as bool false
      };
      final message2 = AssistantMessage.fromJson(json2);
      expect(message2.reusedCachedDescription, isFalse);
    });

    test('fromJson handles edge cases (empty strings, nulls)', () {
      final json = {
        'question': null,
        'answer': '',
        'vision_description': '   ',
        'created_at': null,
      };

      final message = AssistantMessage.fromJson(json);

      expect(message.question, isEmpty);
      expect(message.answer, isEmpty);
      expect(message.visionDescription, isNull);
      // Defaults to now(), so we just check it's recent
      expect(
        message.createdAt.difference(DateTime.now()).inSeconds.abs(),
        lessThan(5),
      );
    });
  });
}
