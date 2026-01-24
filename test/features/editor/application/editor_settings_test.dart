import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorSettings', () {
    test('initial values are correct', () {
      final settings = EditorSettings();

      expect(settings.sidebarSide, equals(EditorSidebarSide.right));
      expect(settings.lineSimplifierEnabled, isTrue);
      expect(settings.lineSimplifierStrength, equals(0.25));
      expect(settings.lineSimplifierMinTolerance, equals(0.3));
      expect(settings.debugModeEnabled, isFalse);
      expect(settings.isPanelOnRight, isTrue);
      expect(settings.isPanelOnLeft, isFalse);
    });

    test('update notifies listeners when values change', () {
      final settings = EditorSettings();
      bool notified = false;
      settings.addListener(() => notified = true);

      settings.update(debugModeEnabled: true);

      expect(settings.debugModeEnabled, isTrue);
      expect(notified, isTrue);
    });

    test('update does not notify listeners when values do not change', () {
      final settings = EditorSettings();
      bool notified = false;
      settings.addListener(() => notified = true);

      settings.update(debugModeEnabled: false); // Default is false

      expect(notified, isFalse);
    });

    test('update changes sidebar side', () {
      final settings = EditorSettings();

      settings.update(sidebarSide: EditorSidebarSide.left);

      expect(settings.sidebarSide, equals(EditorSidebarSide.left));
      expect(settings.isPanelOnLeft, isTrue);
      expect(settings.isPanelOnRight, isFalse);
    });

    test('update clamps lineSimplifierStrength', () {
      final settings = EditorSettings();

      // Test lower bound (0.05)
      settings.update(lineSimplifierStrength: 0.01);
      expect(settings.lineSimplifierStrength, equals(0.05));

      // Test upper bound (0.8)
      settings.update(lineSimplifierStrength: 1.0);
      expect(settings.lineSimplifierStrength, equals(0.8));

      // Test valid value
      settings.update(lineSimplifierStrength: 0.5);
      expect(settings.lineSimplifierStrength, equals(0.5));
    });

    test('update clamps lineSimplifierMinTolerance', () {
      final settings = EditorSettings();

      // Test lower bound (0.05)
      settings.update(lineSimplifierMinTolerance: 0.01);
      expect(settings.lineSimplifierMinTolerance, equals(0.05));

      // Test valid value
      settings.update(lineSimplifierMinTolerance: 1.5);
      expect(settings.lineSimplifierMinTolerance, equals(1.5));
    });

    test('update changes lineSimplifierEnabled', () {
      final settings = EditorSettings();

      settings.update(lineSimplifierEnabled: false);
      expect(settings.lineSimplifierEnabled, isFalse);

      settings.update(lineSimplifierEnabled: true);
      expect(settings.lineSimplifierEnabled, isTrue);
    });
  });
}
