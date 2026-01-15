import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

// Note: We are testing the behavior of FlutterSecureStorage in a simulated environment
// to ensure that the read operation works as expected when the platform channel returns data.
// We cannot easily test the `callbackDispatcher` itself because it is a top-level function
// that executes immediately and relies on Workmanager, but we can verify our assumption
// about how FlutterSecureStorage reads data.

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          log.add(methodCall);
          if (methodCall.method == 'read') {
            final args = methodCall.arguments as Map;
            if (args['key'] == 'inkpadu_cached_user_id') {
              return 'user_123';
            }
          }
          return null;
        });
    log.clear();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'FlutterSecureStorage reads inkpadu_cached_user_id correctly via channel',
    () async {
      const storage = FlutterSecureStorage();

      // Simulate what happens in the background task
      final cachedUserId = await storage.read(key: 'inkpadu_cached_user_id');

      expect(cachedUserId, 'user_123');
      expect(log, hasLength(1));
      expect(log.first.method, 'read');
      expect(log.first.arguments['key'], 'inkpadu_cached_user_id');
    },
  );
}
