import 'dart:convert';
import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as enums;
import 'package:appwrite/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFunctions extends Mock implements Functions {}

void main() {
  late MockFunctions mockFunctions;
  late AzureAssistantApiService service;

  setUp(() {
    mockFunctions = MockFunctions();
    service = AzureAssistantApiService(functions: mockFunctions);

    // Reset the static cache before each test to ensure isolation
    AzureAssistantApiService.clearCachedToken();
  });

  test('getAccessToken uses cache and clears it correctly', () async {
    const fakeToken = 'fake-access-token';
    const fakeResponse = {
      'success': true,
      'accessToken': fakeToken,
      'expiresIn': 3600
    };

    // Create a real Execution object instead of mocking, as it's a data class
    final execution = Execution(
        $id: 'exec1',
        $createdAt: DateTime.now().toIso8601String(),
        $updatedAt: DateTime.now().toIso8601String(),
        $permissions: [],
        functionId: 'llm_auth',
        trigger: enums.ExecutionTrigger.http,
        status: enums.ExecutionStatus.completed,
        requestMethod: 'POST',
        requestPath: '/',
        requestHeaders: [],
        responseStatusCode: 200,
        responseBody: jsonEncode(fakeResponse),
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

    // 1. Fetch token - should call API
    final token1 = await service.getAccessToken();
    expect(token1, equals(fakeToken));
    verify(() => mockFunctions.createExecution(
      functionId: any(named: 'functionId'),
      xasync: any(named: 'xasync'),
    )).called(1);

    // 2. Fetch token again - should use cache (no API call)
    final token2 = await service.getAccessToken();
    expect(token2, equals(fakeToken));

    // Verify it was NOT called again (total calls still 1)
    verifyNever(() => mockFunctions.createExecution(
      functionId: any(named: 'functionId'),
      xasync: any(named: 'xasync'),
    ));

    // 3. Clear cache
    AzureAssistantApiService.clearCachedToken();

    // 4. Fetch token again - should call API again
    final token3 = await service.getAccessToken();
    expect(token3, equals(fakeToken));

    // Verify it WAS called again (total calls now 2)
    verify(() => mockFunctions.createExecution(
      functionId: any(named: 'functionId'),
      xasync: any(named: 'xasync'),
    )).called(1);
  });
}
