import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InkNote', () {
    final testTime = DateTime(2024, 6, 15, 14, 30);

    group('empty factory', () {
      test('creates note with generated id from timestamp', () {
        final note = InkNote.empty(timestamp: testTime);
        expect(note.id, testTime.microsecondsSinceEpoch.toString());
      });

      test('creates note with custom id', () {
        final note = InkNote.empty(id: 'custom-id', timestamp: testTime);
        expect(note.id, 'custom-id');
      });

      test('creates note with auto-generated title', () {
        final note = InkNote.empty(timestamp: testTime);
        expect(note.title, 'Notiz 2024-06-15 14:30');
      });

      test('creates note with custom title', () {
        final note = InkNote.empty(title: 'Custom Title', timestamp: testTime);
        expect(note.title, 'Custom Title');
      });

      test('creates note with one empty page', () {
        final note = InkNote.empty(timestamp: testTime);
        expect(note.pages, hasLength(1));
        expect(note.pages.first.strokes, isEmpty);
      });

      test('creates note with default paper style', () {
        final note = InkNote.empty(timestamp: testTime);
        expect(note.paperStyle, NotePaperStyle.plain);
      });

      test('creates note with custom paper style', () {
        final note = InkNote.empty(
          timestamp: testTime,
          paperStyle: NotePaperStyle.grid,
        );
        expect(note.paperStyle, NotePaperStyle.grid);
      });

      test('sets lastOpenedPageIndex to 0', () {
        final note = InkNote.empty(timestamp: testTime);
        expect(note.lastOpenedPageIndex, 0);
      });
    });

    group('generateTitle', () {
      test('formats date and time correctly', () {
        final title = InkNote.generateTitle(DateTime(2024, 1, 5, 9, 5));
        expect(title, 'Notiz 2024-01-05 09:05');
      });

      test('pads month and day', () {
        final title = InkNote.generateTitle(DateTime(2024, 3, 7, 10, 15));
        expect(title, 'Notiz 2024-03-07 10:15');
      });
    });

    group('currentPage', () {
      test('returns first page for empty lastOpenedPageIndex', () {
        final pages = [
          NotePage(strokes: const <Stroke>[]),
          NotePage(strokes: const <Stroke>[]),
        ];
        final note = InkNote(
          id: 'test',
          title: 'Test',
          updatedAt: testTime,
          pages: pages,
          paperStyle: NotePaperStyle.plain,
          lastOpenedPageIndex: 0,
        );
        expect(note.currentPage, pages[0]);
      });

      test('returns correct page for lastOpenedPageIndex', () {
        final pages = [
          NotePage(strokes: const <Stroke>[]),
          NotePage(strokes: const <Stroke>[]),
        ];
        final note = InkNote(
          id: 'test',
          title: 'Test',
          updatedAt: testTime,
          pages: pages,
          paperStyle: NotePaperStyle.plain,
          lastOpenedPageIndex: 1,
        );
        expect(note.currentPage, pages[1]);
      });

      test('clamps index to valid range', () {
        final pages = [NotePage(strokes: const <Stroke>[])];
        final note = InkNote(
          id: 'test',
          title: 'Test',
          updatedAt: testTime,
          pages: pages,
          paperStyle: NotePaperStyle.plain,
          lastOpenedPageIndex: 5,
        );
        expect(note.currentPage, pages[0]);
      });

      test('returns empty page when pages list is empty', () {
        final note = InkNote(
          id: 'test',
          title: 'Test',
          updatedAt: testTime,
          pages: const [],
          paperStyle: NotePaperStyle.plain,
        );
        expect(note.currentPage.strokes, isEmpty);
      });
    });

    group('copyWith', () {
      test('copies with new title', () {
        final note = InkNote.empty(timestamp: testTime);
        final copied = note.copyWith(title: 'New Title');
        expect(copied.title, 'New Title');
        expect(copied.id, note.id);
      });

      test('copies with new paper style', () {
        final note = InkNote.empty(timestamp: testTime);
        final copied = note.copyWith(paperStyle: NotePaperStyle.dotted);
        expect(copied.paperStyle, NotePaperStyle.dotted);
      });

      test('copies with new lastOpenedPageIndex', () {
        final note = InkNote.empty(timestamp: testTime);
        final copied = note.copyWith(lastOpenedPageIndex: 3);
        expect(copied.lastOpenedPageIndex, 3);
      });

      test('preserves id', () {
        final note = InkNote.empty(id: 'original-id', timestamp: testTime);
        final copied = note.copyWith(title: 'Changed');
        expect(copied.id, 'original-id');
      });
    });
  });
}
