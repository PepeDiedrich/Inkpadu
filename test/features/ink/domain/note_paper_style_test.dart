import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotePaperStyle', () {
    test('has four styles', () {
      expect(NotePaperStyle.values, hasLength(4));
    });

    test('plain has correct icon', () {
      expect(NotePaperStyle.plain.icon, Icons.crop_square);
    });

    test('lined has correct icon', () {
      expect(NotePaperStyle.lined.icon, Icons.horizontal_rule);
    });

    test('grid has correct icon', () {
      expect(NotePaperStyle.grid.icon, Icons.grid_3x3);
    });

    test('dotted has correct icon', () {
      expect(NotePaperStyle.dotted.icon, Icons.blur_on);
    });
  });
}
