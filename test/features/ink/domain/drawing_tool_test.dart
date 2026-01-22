import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrawingTool', () {
    const testTool = DrawingTool(
      id: 'test-pen',
      label: 'Test Pen',
      icon: Icons.edit,
      color: Colors.blue,
      baseWidth: 5.0,
    );

    group('constructor', () {
      test('creates tool with required properties', () {
        expect(testTool.id, 'test-pen');
        expect(testTool.label, 'Test Pen');
        expect(testTool.icon, Icons.edit);
        expect(testTool.color, Colors.blue);
        expect(testTool.baseWidth, 5.0);
      });

      test('has default values for optional properties', () {
        expect(testTool.isHighlighter, false);
        expect(testTool.isEraser, false);
        expect(testTool.usePressure, true);
      });

      test('can create highlighter', () {
        const highlighter = DrawingTool(
          id: 'highlighter',
          label: 'Highlighter',
          icon: Icons.highlight,
          color: Colors.yellow,
          baseWidth: 10.0,
          isHighlighter: true,
          usePressure: false,
        );
        expect(highlighter.isHighlighter, true);
        expect(highlighter.usePressure, false);
      });

      test('can create eraser', () {
        const eraser = DrawingTool(
          id: 'eraser',
          label: 'Eraser',
          icon: Icons.auto_fix_off,
          color: Colors.white,
          baseWidth: 18.0,
          isEraser: true,
        );
        expect(eraser.isEraser, true);
      });
    });

    group('copyWith', () {
      test('copies with new label', () {
        final copied = testTool.copyWith(label: 'New Label');
        expect(copied.label, 'New Label');
        expect(copied.id, testTool.id);
      });

      test('copies with new color', () {
        final copied = testTool.copyWith(color: Colors.red);
        expect(copied.color, Colors.red);
      });

      test('copies with new baseWidth', () {
        final copied = testTool.copyWith(baseWidth: 10.0);
        expect(copied.baseWidth, 10.0);
      });

      test('preserves id', () {
        final copied = testTool.copyWith(label: 'Changed');
        expect(copied.id, 'test-pen');
      });
    });

    group('toJson', () {
      test('serializes all properties', () {
        final json = testTool.toJson();
        expect(json['id'], 'test-pen');
        expect(json['label'], 'Test Pen');
        expect(json['icon'], Icons.edit.codePoint);
        expect(json['iconFontFamily'], Icons.edit.fontFamily);
        expect(json['baseWidth'], 5.0);
        expect(json['isHighlighter'], false);
        expect(json['isEraser'], false);
        expect(json['usePressure'], true);
      });

      test('serializes color as ARGB32', () {
        final json = testTool.toJson();
        expect(json['color'], Colors.blue.toARGB32());
      });
    });

    group('fromJson', () {
      test('deserializes all properties', () {
        final json = testTool.toJson();
        final restored = DrawingTool.fromJson(json);
        expect(restored.id, testTool.id);
        expect(restored.label, testTool.label);
        expect(restored.icon.codePoint, testTool.icon.codePoint);
        // Compare ARGB values because MaterialColor becomes Color after deserialization
        expect(restored.color.toARGB32(), testTool.color.toARGB32());
        expect(restored.baseWidth, testTool.baseWidth);
      });

      test('handles missing optional properties with defaults', () {
        final minimalJson = <String, dynamic>{
          'id': 'minimal',
          'label': 'Minimal Tool',
          'icon': Icons.edit.codePoint,
        };
        final tool = DrawingTool.fromJson(minimalJson);
        expect(tool.baseWidth, 4.0);
        expect(tool.isHighlighter, false);
        expect(tool.isEraser, false);
        expect(tool.usePressure, true);
      });

      test('roundtrip preserves data', () {
        const original = DrawingTool(
          id: 'roundtrip',
          label: 'Roundtrip Test',
          icon: Icons.brush,
          color: Color(0xFFFF5733),
          baseWidth: 7.5,
          isHighlighter: true,
          usePressure: false,
        );
        final json = original.toJson();
        final restored = DrawingTool.fromJson(json);
        expect(restored.id, original.id);
        expect(restored.label, original.label);
        expect(restored.baseWidth, original.baseWidth);
        expect(restored.isHighlighter, original.isHighlighter);
        expect(restored.usePressure, original.usePressure);
      });
    });
  });

  group('DrawingToolDefaults', () {
    test('palette contains 6 tools', () {
      expect(DrawingToolDefaults.palette, hasLength(6));
    });

    test('palette has unique ids', () {
      final ids = DrawingToolDefaults.palette.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('palette contains eraser', () {
      final eraser = DrawingToolDefaults.palette.where((t) => t.isEraser);
      expect(eraser, hasLength(1));
    });

    test('palette contains highlighters', () {
      final highlighters = DrawingToolDefaults.palette.where(
        (t) => t.isHighlighter,
      );
      expect(highlighters.length, greaterThanOrEqualTo(1));
    });
  });
}
