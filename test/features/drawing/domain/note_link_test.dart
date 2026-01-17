import 'package:ai_handwriting_app/features/drawing/domain/note_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteLink', () {
    test('initializes correctly', () {
      const link = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10, 20),
      );

      expect(link.targetNoteId, 'id');
      expect(link.label, 'label');
      expect(link.position, const Offset(10, 20));
    });

    test('supports value equality', () {
      const link1 = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10, 20),
      );
      const link2 = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10, 20),
      );
      const link3 = NoteLink(
        targetNoteId: 'other',
        label: 'label',
        position: Offset(10, 20),
      );

      expect(link1, equals(link2));
      expect(link1.hashCode, equals(link2.hashCode));
      expect(link1, isNot(equals(link3)));
    });

    test('copyWith updates fields', () {
      const link = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10, 20),
      );

      final updated = link.copyWith(
        targetNoteId: 'newId',
        label: 'newLabel',
        position: const Offset(30, 40),
      );

      expect(updated.targetNoteId, 'newId');
      expect(updated.label, 'newLabel');
      expect(updated.position, const Offset(30, 40));
    });

    test('copyWith respects null values', () {
      const link = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10, 20),
      );

      final same = link.copyWith();

      expect(same.targetNoteId, 'id');
      expect(same.label, 'label');
      expect(same.position, const Offset(10, 20));
    });

    test('toJson returns correct map', () {
      const link = NoteLink(
        targetNoteId: 'id',
        label: 'label',
        position: Offset(10.5, 20.5),
      );

      final json = link.toJson();

      expect(json, {
        'target_note_id': 'id',
        'label': 'label',
        'position_dx': 10.5,
        'position_dy': 20.5,
      });
    });

    test('fromJson creates correct instance', () {
      final json = {
        'target_note_id': 'id',
        'label': 'label',
        'position_dx': 10.5,
        'position_dy': 20.5,
      };

      final link = NoteLink.fromJson(json);

      expect(link.targetNoteId, 'id');
      expect(link.label, 'label');
      expect(link.position, const Offset(10.5, 20.5));
    });

    test('fromJson handles int values for position', () {
       final json = {
        'target_note_id': 'id',
        'label': 'label',
        'position_dx': 10,
        'position_dy': 20,
      };

      final link = NoteLink.fromJson(json);

      expect(link.position, const Offset(10.0, 20.0));
    });
  });
}
