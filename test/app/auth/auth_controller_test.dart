import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ai_handwriting_app/app/auth/auth_controller.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthController authController;
  late MockFlutterSecureStorage mockSecureStorage;

  const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/path_provider',
  );

  setUp(() {
    // Mock path_provider which is used by Appwrite Client
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall methodCall) async => '.',
        );

    mockSecureStorage = MockFlutterSecureStorage();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'initialize loads user from secure storage when appwrite fails',
    () async {
      // Arrange
      when(
        () => mockSecureStorage.read(key: 'inkpadu_cached_user_id'),
      ).thenAnswer((_) async => 'test_user_id');
      when(
        () => mockSecureStorage.read(key: 'inkpadu_cached_email'),
      ).thenAnswer((_) async => 'test@example.com');

      authController = AuthController(secureStorage: mockSecureStorage);

      // Act
      try {
        await authController.initialize();
      } catch (_) {
        // Expected failure of Appwrite call
      }

      // Assert
      verify(
        () => mockSecureStorage.read(key: 'inkpadu_cached_user_id'),
      ).called(1);
      verify(
        () => mockSecureStorage.read(key: 'inkpadu_cached_email'),
      ).called(1);
    },
  );

  test(
    'initialize migrates data from SharedPreferences to FlutterSecureStorage',
    () async {
      // Arrange: Populate SharedPreferences with "legacy" insecure data
      SharedPreferences.setMockInitialValues({
        'inkpadu_cached_user_id': 'legacy_user_id',
        'inkpadu_cached_email': 'legacy@example.com',
      });

      when(
        () => mockSecureStorage.write(
          key: 'inkpadu_cached_user_id',
          value: 'legacy_user_id',
        ),
      ).thenAnswer((_) async {});
      when(
        () => mockSecureStorage.write(
          key: 'inkpadu_cached_email',
          value: 'legacy@example.com',
        ),
      ).thenAnswer((_) async {});

      // Also mock read, because initialize() reads after migration if Appwrite fails
      when(
        () => mockSecureStorage.read(key: 'inkpadu_cached_user_id'),
      ).thenAnswer((_) async => 'legacy_user_id');
      when(
        () => mockSecureStorage.read(key: 'inkpadu_cached_email'),
      ).thenAnswer((_) async => 'legacy@example.com');

      authController = AuthController(secureStorage: mockSecureStorage);

      // Act
      try {
        await authController.initialize();
      } catch (_) {
        // Expected failure of Appwrite call
      }

      // Assert: Check migration writes
      verify(
        () => mockSecureStorage.write(
          key: 'inkpadu_cached_user_id',
          value: 'legacy_user_id',
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: 'inkpadu_cached_email',
          value: 'legacy@example.com',
        ),
      ).called(1);

      // Assert: Check SharedPreferences deletion
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('inkpadu_cached_user_id'), isFalse);
      expect(prefs.containsKey('inkpadu_cached_email'), isFalse);
    },
  );

  test('logout clears both secure storage and shared preferences', () async {
    // Arrange
    when(
      () => mockSecureStorage.delete(key: 'inkpadu_cached_user_id'),
    ).thenAnswer((_) async {});
    when(
      () => mockSecureStorage.delete(key: 'inkpadu_cached_email'),
    ).thenAnswer((_) async {});

    SharedPreferences.setMockInitialValues({
      'inkpadu_cached_user_id': 'should_be_deleted',
    });

    authController = AuthController(secureStorage: mockSecureStorage);

    // Act
    await authController.logout();

    // Assert
    verify(
      () => mockSecureStorage.delete(key: 'inkpadu_cached_user_id'),
    ).called(1);
    verify(
      () => mockSecureStorage.delete(key: 'inkpadu_cached_email'),
    ).called(1);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.containsKey('inkpadu_cached_user_id'), isFalse);
  });
}
