import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inkpadu/features/input/application/pointer_settings_scope.dart';

void main() {
  group('PointerSettings', () {
    test('has correct default values', () {
      final settings = PointerSettings();
      expect(settings.allowStylus, isTrue);
      expect(settings.allowTouch, isTrue);
      expect(settings.allowMouse, isTrue);
      expect(settings.autoLockOnStylus, isTrue);
      expect(settings.stylusLocked, isFalse);
    });

    test('update modifies values and notifies listeners', () {
      final settings = PointerSettings();
      bool notified = false;
      settings.addListener(() => notified = true);

      settings.update(
        stylus: false,
        touch: false,
        mouse: false,
        autoLock: false,
      );

      expect(settings.allowStylus, isFalse);
      expect(settings.allowTouch, isFalse);
      expect(settings.allowMouse, isFalse);
      expect(settings.autoLockOnStylus, isFalse);
      expect(notified, isTrue);
    });

    test('accept logic works correctly for different device kinds', () {
      final settings = PointerSettings();

      // Default: all allowed
      expect(settings.accept(PointerDeviceKind.stylus), isTrue);
      expect(settings.accept(PointerDeviceKind.touch), isTrue);
      expect(settings.accept(PointerDeviceKind.mouse), isTrue);
      expect(settings.accept(PointerDeviceKind.unknown), isFalse);

      // Disable specific inputs
      settings.update(stylus: false);
      expect(settings.accept(PointerDeviceKind.stylus), isFalse);

      settings.update(stylus: true, touch: false);
      expect(settings.accept(PointerDeviceKind.touch), isFalse);

      settings.update(touch: true, mouse: false);
      expect(settings.accept(PointerDeviceKind.mouse), isFalse);
    });

    test('register activates stylus lock when autoLockOnStylus is true', () {
      final settings = PointerSettings();
      bool notified = false;
      settings.addListener(() => notified = true);

      // Should not lock on touch
      settings.register(PointerDeviceKind.touch);
      expect(settings.stylusLocked, isFalse);
      expect(notified, isFalse);

      // Should lock on stylus
      settings.register(PointerDeviceKind.stylus);
      expect(settings.stylusLocked, isTrue);
      expect(notified, isTrue);
    });

    test('accept rejects non-stylus inputs when locked', () {
      final settings = PointerSettings();
      settings.register(PointerDeviceKind.stylus); // Locks it

      expect(settings.stylusLocked, isTrue);
      expect(settings.accept(PointerDeviceKind.touch), isFalse);
      expect(settings.accept(PointerDeviceKind.mouse), isFalse);
      expect(settings.accept(PointerDeviceKind.stylus), isTrue);
    });

    test('resetStylusLock unlocks the settings', () {
      final settings = PointerSettings();
      settings.register(PointerDeviceKind.stylus);
      expect(settings.stylusLocked, isTrue);

      settings.resetStylusLock();
      expect(settings.stylusLocked, isFalse);

      // Should accept touch again
      expect(settings.accept(PointerDeviceKind.touch), isTrue);
    });

    test('does not lock if autoLockOnStylus is false', () {
      final settings = PointerSettings(autoLockOnStylus: false);
      settings.register(PointerDeviceKind.stylus);
      expect(settings.stylusLocked, isFalse);
    });
  });

  group('PointerSettingsScope', () {
    testWidgets('provides settings to descendants', (tester) async {
      final settings = PointerSettings();
      late PointerSettings retrievedSettings;

      await tester.pumpWidget(
        PointerSettingsScope(
          settings: settings,
          child: Builder(
            builder: (context) {
              retrievedSettings = PointerSettingsScope.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedSettings, equals(settings));
    });

    testWidgets('updates rebuild descendants', (tester) async {
      final settings = PointerSettings();
      int buildCount = 0;

      await tester.pumpWidget(
        PointerSettingsScope(
          settings: settings,
          child: Builder(
            builder: (context) {
              // Register dependency
              PointerSettingsScope.of(context);
              buildCount++;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(buildCount, 1);

      // Update settings -> should trigger rebuild
      settings.update(touch: false);
      await tester.pump();

      expect(buildCount, 2);
    });

    testWidgets('asserts when not found in context', (tester) async {
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            expect(
              () => PointerSettingsScope.of(context),
              throwsA(isA<AssertionError>()),
            );
            return const SizedBox();
          },
        ),
      );
    });
  });
}
