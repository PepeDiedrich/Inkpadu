import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite/enums.dart' as enums;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFunctions extends Mock implements Functions {}

void main() {
  late MockFunctions mockFunctions;
  late AzureAssistantApiService apiService;

  setUp(() {
    mockFunctions = MockFunctions();
    apiService = AzureAssistantApiService(functions: mockFunctions);
    // Ensure cache is clear before each test
    AzureAssistantApiService.clearCachedToken();
  });

  tearDown(() {
    AzureAssistantApiService.clearCachedToken();
  });

  group('AzureAssistantApiService Logic', () {
    test('getAccessToken populates static cache', () async {
      // Arrange
      const token = 'test-token-123';
      const responseBody =
          '{"success": true, "accessToken": "$token", "expiresIn": 3600}';

      final execution = Execution(
        $id: 'exec1',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
        deploymentId: 'dep-1',
        functionId: 'llm_auth',
        trigger: enums.ExecutionTrigger.http,
        status: enums.ExecutionStatus.completed,
        requestMethod: 'POST',
        requestPath: '/',
        requestHeaders: [],
        responseStatusCode: 200,
        responseBody: responseBody,
        responseHeaders: [],
        logs: '',
        errors: '',
        duration: 0.1,
      );

      when(
        () => mockFunctions.createExecution(
          functionId: any(named: 'functionId'),
          xasync: any(named: 'xasync'),
        ),
      ).thenAnswer((_) async => execution);

      // Act
      final result = await apiService.getAccessToken();

      // Assert
      expect(result, equals(token));
      expect(AzureAssistantApiService.cachedAccessToken, equals(token));
    });

    test('clearCachedToken clears the static cache', () async {
      // Arrange: Populate cache first
      const token = 'test-token-to-clear';
      const responseBody =
          '{"success": true, "accessToken": "$token", "expiresIn": 3600}';

      final execution = Execution(
        $id: 'exec2',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
        deploymentId: 'dep-2',
        functionId: 'llm_auth',
        trigger: enums.ExecutionTrigger.http,
        status: enums.ExecutionStatus.completed,
        requestMethod: 'POST',
        requestPath: '/',
        requestHeaders: [],
        responseStatusCode: 200,
        responseBody: responseBody,
        responseHeaders: [],
        logs: '',
        errors: '',
        duration: 0.1,
      );

      when(
        () => mockFunctions.createExecution(
          functionId: any(named: 'functionId'),
          xasync: any(named: 'xasync'),
        ),
      ).thenAnswer((_) async => execution);

      await apiService.getAccessToken();
      expect(AzureAssistantApiService.cachedAccessToken, equals(token));

      // Act
      AzureAssistantApiService.clearCachedToken();

      // Assert
      expect(AzureAssistantApiService.cachedAccessToken, isNull);
    });
  });
}
