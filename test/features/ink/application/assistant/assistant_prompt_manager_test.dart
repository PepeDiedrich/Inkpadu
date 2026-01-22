import 'dart:typed_data';
import 'dart:ui';

import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_prompt_manager.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/assistant_request_type.dart';
import 'package:ai_handwriting_app/features/ink/domain/assistant_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AssistantPromptManager', () {
    late AssistantPromptManager manager;

    setUp(() {
      manager = const AssistantPromptManager();
    });

    group('promptTemplateFor', () {
      test('returns tip prompt for tip type', () {
        final String prompt = manager.promptTemplateFor(
          AssistantRequestType.tip,
        );
        expect(prompt, contains('Tipp'));
        expect(prompt, contains('LaTeX'));
      });

      test('returns help prompt for help type', () {
        final String prompt = manager.promptTemplateFor(
          AssistantRequestType.help,
        );
        expect(prompt, contains('Hilfestellung'));
      });

      test('returns review prompt for review type', () {
        final String prompt = manager.promptTemplateFor(
          AssistantRequestType.review,
        );
        expect(prompt, contains('Fehler'));
      });

      test('returns pdf extract prompt for pdfExtract type', () {
        final String prompt = manager.promptTemplateFor(
          AssistantRequestType.pdfExtract,
        );
        expect(prompt, contains('Extrahiere'));
        expect(prompt, contains('Text'));
      });
    });

    group('buildUserContent', () {
      test('builds basic content without optional parameters', () {
        final List<Map<String, dynamic>> content = manager.buildUserContent(
          prompt: 'Test Frage',
          combinedSnapshot: null,
          totalClusters: 0,
          historySummary: null,
        );

        expect(content, isNotEmpty);
        expect(content.length, greaterThanOrEqualTo(2));

        final bool hasQuestion = content.any(
          (Map<String, dynamic> item) =>
              item['type'] == 'text' &&
              (item['text'] as String).contains('Test Frage'),
        );
        expect(hasQuestion, isTrue);
      });

      test('adds history summary when provided', () {
        final List<Map<String, dynamic>> content = manager.buildUserContent(
          prompt: 'Test Frage',
          combinedSnapshot: null,
          totalClusters: 0,
          historySummary: 'Vorherige Konversation',
        );

        final bool hasHistory = content.any(
          (Map<String, dynamic> item) =>
              item['type'] == 'text' &&
              (item['text'] as String).contains('Vorherige Konversation'),
        );
        expect(hasHistory, isTrue);
      });

      test('PDF text is no longer included in userContent', () {
        final List<Map<String, dynamic>> content = manager.buildUserContent(
          prompt: 'Test Frage',
          combinedSnapshot: null,
          totalClusters: 0,
          historySummary: null,
        );

        final bool hasPdfText = content.any(
          (Map<String, dynamic> item) =>
              item['type'] == 'text' &&
              (item['text'] as String).contains('PDF-Inhalt'),
        );
        expect(hasPdfText, isFalse);
      });

      test('adds image when snapshot is provided', () {
        final CombinedSnapshot fakeSnapshot = CombinedSnapshot(
          pngBytes: Uint8List.fromList(<int>[0, 1, 2, 3]),
          logicalBounds: const Rect.fromLTWH(0, 0, 100, 100),
          logicalSize: const Size(100, 100),
          scale: 1.0,
          pixelRatio: 2.0,
        );

        final List<Map<String, dynamic>> content = manager.buildUserContent(
          prompt: 'Test Frage',
          combinedSnapshot: fakeSnapshot,
          totalClusters: 1,
          historySummary: null,
        );

        final bool hasImage = content.any(
          (Map<String, dynamic> item) => item['type'] == 'image_url',
        );
        expect(hasImage, isTrue);
      });

      test('adds hint when clusters available but no snapshot', () {
        final List<Map<String, dynamic>> content = manager.buildUserContent(
          prompt: 'Test Frage',
          combinedSnapshot: null,
          totalClusters: 5,
          historySummary: null,
        );

        final bool hasHint = content.any(
          (Map<String, dynamic> item) =>
              item['type'] == 'text' &&
              (item['text'] as String).contains('5 Cluster'),
        );
        expect(hasHint, isTrue);
      });
    });

    group('estimateTokenUsage', () {
      test('estimates tokens for simple text', () {
        final int tokens = manager.estimateTokenUsage(
          systemPrompt: 'System Prompt mit 20 Zeichen.',
          prompt: 'User Prompt',
        );

        expect(tokens, greaterThan(0));
      });

      test('includes history in estimation', () {
        final int tokensWithoutHistory = manager.estimateTokenUsage(
          systemPrompt: 'System',
          prompt: 'User',
        );

        final int tokensWithHistory = manager.estimateTokenUsage(
          systemPrompt: 'System',
          prompt: 'User',
          historySummary: 'Eine lange History mit vielen Zeichen zum Testen',
        );

        expect(tokensWithHistory, greaterThan(tokensWithoutHistory));
      });

      test('includes image in estimation', () {
        final CombinedSnapshot fakeSnapshot = CombinedSnapshot(
          pngBytes: Uint8List.fromList(List<int>.filled(10240, 0)),
          logicalBounds: const Rect.fromLTWH(0, 0, 100, 100),
          logicalSize: const Size(100, 100),
          scale: 1.0,
          pixelRatio: 2.0,
        );

        final int tokensWithoutImage = manager.estimateTokenUsage(
          systemPrompt: 'System',
          prompt: 'User',
        );

        final int tokensWithImage = manager.estimateTokenUsage(
          systemPrompt: 'System',
          prompt: 'User',
          combinedSnapshot: fakeSnapshot,
        );

        expect(tokensWithImage, greaterThan(tokensWithoutImage));
      });
    });

    group('estimatePdfContextTokens', () {
      test('returns 0 for null', () {
        final int tokens = manager.estimatePdfContextTokens(null);
        expect(tokens, equals(0));
      });

      test('returns 0 for empty string', () {
        final int tokens = manager.estimatePdfContextTokens('');
        expect(tokens, equals(0));
      });

      test('estimates tokens for PDF text', () {
        final String pdfText =
            'Dies ist ein langer PDF-Text mit vielen Zeichen. ' * 10;
        final int tokens = manager.estimatePdfContextTokens(pdfText);

        expect(tokens, greaterThan(50));
        expect(tokens, greaterThan(pdfText.length ~/ 4));
      });

      test('PDF context tokens are calculated separately', () {
        final String pdfText = 'Langer PDF-Text ' * 100;
        final int pdfTokens = manager.estimatePdfContextTokens(pdfText);

        final int normalTokens = manager.estimateTokenUsage(
          systemPrompt: 'System',
          prompt: 'User',
        );

        expect(pdfTokens, greaterThan(0));
        expect(normalTokens, lessThan(pdfTokens));
      });
    });

    group('selectRecentHistory', () {
      test('returns all messages when 5 or less', () {
        final List<AssistantMessage> history = List<AssistantMessage>.generate(
          3,
          (int i) => AssistantMessage(
            question: 'Frage $i',
            answer: 'Antwort $i',
            createdAt: DateTime.now(),
          ),
        );

        final List<AssistantMessage> selected = manager.selectRecentHistory(
          history,
        );
        expect(selected.length, equals(3));
      });

      test('returns only last 5 when more available', () {
        final List<AssistantMessage> history = List<AssistantMessage>.generate(
          10,
          (int i) => AssistantMessage(
            question: 'Frage $i',
            answer: 'Antwort $i',
            createdAt: DateTime.now(),
          ),
        );

        final List<AssistantMessage> selected = manager.selectRecentHistory(
          history,
        );
        expect(selected.length, equals(5));
        expect(selected.first.question, equals('Frage 5'));
        expect(selected.last.question, equals('Frage 9'));
      });
    });

    group('summarizeHistory', () {
      test('returns null for empty history', () {
        final String? summary = manager.summarizeHistory(<AssistantMessage>[]);
        expect(summary, isNull);
      });

      test('summarizes single message', () {
        final List<AssistantMessage> history = <AssistantMessage>[
          AssistantMessage(
            question: 'Test Frage',
            answer: 'Test Antwort',
            createdAt: DateTime.now(),
          ),
        ];

        final String? summary = manager.summarizeHistory(history);
        expect(summary, isNotNull);
        expect(summary, contains('Test Frage'));
        expect(summary, contains('Test Antwort'));
      });

      test('separates multiple messages with ---', () {
        final List<AssistantMessage> history = <AssistantMessage>[
          AssistantMessage(
            question: 'Frage 1',
            answer: 'Antwort 1',
            createdAt: DateTime.now(),
          ),
          AssistantMessage(
            question: 'Frage 2',
            answer: 'Antwort 2',
            createdAt: DateTime.now(),
          ),
        ];

        final String? summary = manager.summarizeHistory(history);
        expect(summary, isNotNull);
        expect(summary, contains('---'));
      });
    });
  });
}
