import 'dart:convert';

import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFunctions extends Mock implements Functions {}

void main() {
  late MockFunctions mockFunctions;
  late AzureAssistantApiService apiService;

  setUp(() {
    mockFunctions = MockFunctions();
    apiService = AzureAssistantApiService(functions: mockFunctions);

    // Reset the static cache before each test
    AzureAssistantApiService.clearCachedToken();
  });

  tearDown(() {
    AzureAssistantApiService.clearCachedToken();
  });

  group('AzureAssistantApiService Logic', () {
    test('getAccessToken caches the token', () async {
      // Arrange
      const token = 'fake-access-token';
      final responseBody = jsonEncode({
        'success': true,
        'accessToken': token,
        'expiresIn': 300,
      });

      final execution = Execution(
        $id: 'exec1',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
        functionId: 'llm_auth',
        trigger: ExecutionTrigger.http,
        status: ExecutionStatus.completed,
        requestMethod: 'GET',
        requestPath: '/',
        requestHeaders: [],
        responseStatusCode: 200,
        responseBody: responseBody,
        responseHeaders: [],
        logs: '',
        errors: '',
        duration: 0.1,
        deploymentId: 'dep1',
      );

      when(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          )).thenAnswer((_) async => execution);

      // Act 1: First call
      final result1 = await apiService.getAccessToken();

      // Assert 1
      expect(result1, equals(token));
      verify(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          )).called(1);

      // Act 2: Second call (should use cache)
      final result2 = await apiService.getAccessToken();

      // Assert 2
      expect(result2, equals(token));
      verifyNever(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          ));
    });

    test('clearCachedToken invalidates the cache', () async {
      // Arrange
      const token = 'fake-access-token';
      final responseBody = jsonEncode({
        'success': true,
        'accessToken': token,
        'expiresIn': 300,
      });

      final execution = Execution(
        $id: 'exec1',
        $createdAt: '',
        $updatedAt: '',
        $permissions: [],
        functionId: 'llm_auth',
        trigger: ExecutionTrigger.http,
        status: ExecutionStatus.completed,
        requestMethod: 'GET',
        requestPath: '/',
        requestHeaders: [],
        responseStatusCode: 200,
        responseBody: responseBody,
        responseHeaders: [],
        logs: '',
        errors: '',
        duration: 0.1,
        deploymentId: 'dep1',
      );

      when(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          )).thenAnswer((_) async => execution);

      // Act 1: First call to populate cache
      await apiService.getAccessToken();
      verify(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          )).called(1);

      // Act 2: Clear cache
      AzureAssistantApiService.clearCachedToken();

      // Act 3: Call again (should call API again)
      final result = await apiService.getAccessToken();

      // Assert
      expect(result, equals(token));
      verify(() => mockFunctions.createExecution(
            functionId: any(named: 'functionId'),
            xasync: any(named: 'xasync'),
          )).called(1); // Total calls: 1 (previous) + 1 (new) = 2
    });
  });
}
