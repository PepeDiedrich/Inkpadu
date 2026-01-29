import 'package:ai_handwriting_app/app/auth/auth_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/azure_assistant_api_service.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appwrite/enums.dart' as enums;

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockFunctions extends Mock implements Functions {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController authController;
  late MockFlutterSecureStorage mockSecureStorage;
  late MockFunctions mockFunctions;

  // Needed for path_provider
  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall methodCall) async => '.',
        );

    mockSecureStorage = MockFlutterSecureStorage();
    SharedPreferences.setMockInitialValues({});
    mockFunctions = MockFunctions();

    // We need to inject a mock service or just rely on static state.
    // Since we are testing integration with AuthController calling static method,
    // we can use a helper service instance to populate the cache.

    authController = AuthController(secureStorage: mockSecureStorage);

    // Reset cache
    AzureAssistantApiService.clearCachedToken();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    AzureAssistantApiService.clearCachedToken();
  });

  test('logout clears AzureAssistantApiService token cache', () async {
    // Arrange: Populate the cache first
    // We can do this by creating a service instance and calling getAccessToken
    // or by manually setting it if we had a setter.
    // Since we don't have a setter, we use the service to fetch a token.

    final apiService = AzureAssistantApiService(functions: mockFunctions);
    const token = 'secret-token-123';

    // Mock the execution response to return a token
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
      responseBody:
          '{"success": true, "accessToken": "$token", "expiresIn": 3600}',
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

    // Populate cache
    await apiService.getAccessToken();
    expect(AzureAssistantApiService.cachedAccessToken, equals(token));

    // Arrange: Mock Secure Storage calls for logout
    when(
      () => mockSecureStorage.delete(key: any(named: 'key')),
    ).thenAnswer((_) async {});

    // Act: Logout
    await authController.logout();

    // Assert: Check if token is cleared
    expect(AzureAssistantApiService.cachedAccessToken, isNull);
  });
}
