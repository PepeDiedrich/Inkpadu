import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AzureAssistantRequest', () {
    test('creates request without pdfContext', () {
      const AzureAssistantRequest request = AzureAssistantRequest(
        systemPrompt: 'System prompt',
        userContent: <Map<String, dynamic>>[
          {'type': 'text', 'text': 'User message'},
        ],
        maxCompletionTokens: 1000,
      );

      expect(request.systemPrompt, equals('System prompt'));
      expect(request.userContent.length, equals(1));
      expect(request.maxCompletionTokens, equals(1000));
      expect(request.pdfContext, isNull);
    });

    test('creates request with pdfContext', () {
      const AzureAssistantRequest request = AzureAssistantRequest(
        systemPrompt: 'System prompt',
        userContent: <Map<String, dynamic>>[
          {'type': 'text', 'text': 'User message'},
        ],
        maxCompletionTokens: 1000,
        pdfContext: 'This is the PDF content that should always be included.',
      );

      expect(request.pdfContext, isNotNull);
      expect(request.pdfContext, contains('PDF content'));
    });

    test('pdfContext is optional', () {
      const AzureAssistantRequest requestWithPdf = AzureAssistantRequest(
        systemPrompt: 'System',
        userContent: <Map<String, dynamic>>[],
        maxCompletionTokens: 100,
        pdfContext: 'PDF text',
      );

      const AzureAssistantRequest requestWithoutPdf = AzureAssistantRequest(
        systemPrompt: 'System',
        userContent: <Map<String, dynamic>>[],
        maxCompletionTokens: 100,
      );

      expect(requestWithPdf.pdfContext, isNotNull);
      expect(requestWithoutPdf.pdfContext, isNull);
    });

    test('creates request with reasoningEffort', () {
      const AzureAssistantRequest request = AzureAssistantRequest(
        systemPrompt: 'System prompt',
        userContent: <Map<String, dynamic>>[],
        maxCompletionTokens: 1000,
        reasoningEffort: 'low',
      );

      expect(request.reasoningEffort, equals('low'));
    });
  });

  group('AzureAssistantPreparedRequest', () {
    test('contains original request reference', () {
      const AzureAssistantRequest originalRequest = AzureAssistantRequest(
        systemPrompt: 'System',
        userContent: <Map<String, dynamic>>[],
        maxCompletionTokens: 100,
        pdfContext: 'PDF context',
      );

      final AzureAssistantPreparedRequest preparedRequest =
          const AzureAssistantPreparedRequest(
            request: originalRequest,
            payload: <String, dynamic>{'messages': <dynamic>[]},
            payloadPreview: '{}',
          );

      expect(preparedRequest.request.pdfContext, equals('PDF context'));
    });
  });

  group('AzureAssistantResult', () {
    test('wasTruncated is true when finishReason is length', () {
      const AzureAssistantResult result = AzureAssistantResult(
        answer: 'Partial answer...',
        finishReason: 'length',
        payloadPreview: '{}',
      );

      expect(result.wasTruncated, isTrue);
    });

    test('wasTruncated is false when finishReason is stop', () {
      const AzureAssistantResult result = AzureAssistantResult(
        answer: 'Complete answer',
        finishReason: 'stop',
        payloadPreview: '{}',
      );

      expect(result.wasTruncated, isFalse);
    });

    test('wasTruncated is false when finishReason is null', () {
      const AzureAssistantResult result = AzureAssistantResult(
        answer: 'Answer',
        finishReason: null,
        payloadPreview: '{}',
      );

      expect(result.wasTruncated, isFalse);
    });
  });
}
