import 'package:ai_handwriting_app/features/ink/domain/assistant_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantMessage', () {
    final testTime = DateTime(2024, 6, 15, 14, 30);

    group('constructor', () {
      test('creates message with required properties', () {
        final message = AssistantMessage(
          question: 'What is this?',
          answer: 'This is a test.',
          createdAt: testTime,
        );
        expect(message.question, 'What is this?');
        expect(message.answer, 'This is a test.');
        expect(message.createdAt, testTime);
      });

      test('has null visionDescription by default', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
        );
        expect(message.visionDescription, isNull);
      });

      test('has false reusedCachedDescription by default', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
        );
        expect(message.reusedCachedDescription, false);
      });

      test('can set all optional properties', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
          visionDescription: 'A diagram',
          reusedCachedDescription: true,
        );
        expect(message.visionDescription, 'A diagram');
        expect(message.reusedCachedDescription, true);
      });
    });

    group('copyWith', () {
      test('copies with new question', () {
        final message = AssistantMessage(
          question: 'Original',
          answer: 'A',
          createdAt: testTime,
        );
        final copied = message.copyWith(question: 'New Question');
        expect(copied.question, 'New Question');
        expect(copied.answer, 'A');
      });

      test('copies with new answer', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'Original',
          createdAt: testTime,
        );
        final copied = message.copyWith(answer: 'New Answer');
        expect(copied.answer, 'New Answer');
      });

      test('copies with new visionDescription', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
        );
        final copied = message.copyWith(visionDescription: 'New Description');
        expect(copied.visionDescription, 'New Description');
      });

      test('can set visionDescription to null', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
          visionDescription: 'Existing',
        );
        final copied = message.copyWith(visionDescription: null);
        expect(copied.visionDescription, isNull);
      });
    });

    group('toJson', () {
      test('serializes all properties', () {
        final message = AssistantMessage(
          question: 'What is it?',
          answer: 'A note.',
          createdAt: testTime,
          visionDescription: 'A sketch',
          reusedCachedDescription: true,
        );
        final json = message.toJson();
        expect(json['question'], 'What is it?');
        expect(json['answer'], 'A note.');
        expect(json['vision_description'], 'A sketch');
        expect(json['reused_cached_description'], true);
        expect(json['created_at'], testTime.toIso8601String());
      });

      test('serializes null visionDescription', () {
        final message = AssistantMessage(
          question: 'Q',
          answer: 'A',
          createdAt: testTime,
        );
        final json = message.toJson();
        expect(json['vision_description'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all properties', () {
        final json = <String, dynamic>{
          'question': 'What is it?',
          'answer': 'A note.',
          'vision_description': 'A sketch',
          'created_at': testTime.toIso8601String(),
          'reused_cached_description': true,
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.question, 'What is it?');
        expect(message.answer, 'A note.');
        expect(message.visionDescription, 'A sketch');
        expect(message.reusedCachedDescription, true);
      });

      test('handles empty question', () {
        final json = <String, dynamic>{
          'question': '',
          'answer': 'A',
          'created_at': testTime.toIso8601String(),
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.question, '');
      });

      test('handles missing question', () {
        final json = <String, dynamic>{
          'answer': 'A',
          'created_at': testTime.toIso8601String(),
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.question, '');
      });

      test('handles empty vision_description as null', () {
        final json = <String, dynamic>{
          'question': 'Q',
          'answer': 'A',
          'vision_description': '   ',
          'created_at': testTime.toIso8601String(),
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.visionDescription, isNull);
      });

      test('handles created_at as int (milliseconds)', () {
        final millis = testTime.toUtc().millisecondsSinceEpoch;
        final json = <String, dynamic>{
          'question': 'Q',
          'answer': 'A',
          'created_at': millis,
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.createdAt.millisecondsSinceEpoch, millis);
      });

      test('handles reused_cached_description as number', () {
        final json = <String, dynamic>{
          'question': 'Q',
          'answer': 'A',
          'created_at': testTime.toIso8601String(),
          'reused_cached_description': 1,
        };
        final message = AssistantMessage.fromJson(json);
        expect(message.reusedCachedDescription, true);
      });

      test('roundtrip preserves data', () {
        final original = AssistantMessage(
          question: 'Roundtrip Q',
          answer: 'Roundtrip A',
          createdAt: testTime,
          visionDescription: 'Roundtrip Desc',
          reusedCachedDescription: true,
        );
        final json = original.toJson();
        final restored = AssistantMessage.fromJson(json);
        expect(restored.question, original.question);
        expect(restored.answer, original.answer);
        expect(restored.visionDescription, original.visionDescription);
        expect(
            restored.reusedCachedDescription, original.reusedCachedDescription);
      });
    });
  });
}
