import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/application/ink_notes_scope.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockInkNotesController extends Mock implements InkNotesController {}

class MockDrawingController extends Mock implements DrawingController {}

class MockDrawingToolPreferencesRepository extends Mock
    implements DrawingToolPreferencesRepository {}

class FakeInkNote extends Fake implements InkNote {}

void main() {
  late MockInkNotesController mockInkNotesController;
  late MockDrawingController mockDrawingController;
  late MockDrawingToolPreferencesRepository mockToolPreferencesRepository;
  late DrawingNoteController controller;

  const String noteId = 'test-note-id';
  final DateTime initialTime = DateTime(2023, 1, 1, 10);
  final InkNote testNote = InkNote(
    id: noteId,
    title: 'Test Note',
    updatedAt: initialTime,
    pages: List<NotePage>.unmodifiable([
      NotePage(strokes: const []),
      NotePage(strokes: const []),
    ]),
    paperStyle: NotePaperStyle.plain,
  );

  setUpAll(() {
    registerFallbackValue(FakeInkNote());
  });

  setUp(() {
    mockInkNotesController = MockInkNotesController();
    mockDrawingController = MockDrawingController();
    mockToolPreferencesRepository = MockDrawingToolPreferencesRepository();

    when(() => mockInkNotesController.notes).thenReturn([testNote]);
    when(() => mockDrawingController.strokes).thenReturn(const []);
    when(() => mockDrawingController.initialize(any())).thenReturn(null);
    when(() => mockDrawingController.dispose()).thenReturn(null);

    // Mock preferences repository defaults
    when(() => mockToolPreferencesRepository.load(any()))
        .thenAnswer((_) async => []);
    when(() => mockToolPreferencesRepository.loadSelectedToolId())
        .thenAnswer((_) async => null);
    when(() => mockToolPreferencesRepository.loadToolbarPosition())
        .thenAnswer((_) async => null);
    when(() => mockToolPreferencesRepository.loadToolbarOrientation())
        .thenAnswer((_) async => Axis.horizontal);
    when(
      () => mockToolPreferencesRepository.saveSelectedToolId(
        any(),
        currentTools: any(named: 'currentTools'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockToolPreferencesRepository.save(
        any(),
        selectedToolId: any(named: 'selectedToolId'),
      ),
    ).thenAnswer((_) async {});

    // Mock upsert
    when(
      () => mockInkNotesController.upsert(
        any(),
        changedPageIndices: any(named: 'changedPageIndices'),
      ),
    ).thenAnswer((_) async {});

    controller = DrawingNoteController(
      noteId: noteId,
      inkNotesController: mockInkNotesController,
      drawingController: mockDrawingController,
      toolPreferencesRepository: mockToolPreferencesRepository,
    );
  });

  group('DrawingNoteController Refresh', () {
    setUp(() async {
      await controller.initialize();
    });

    test('refreshFromSource returns false if note not found', () {
      when(() => mockInkNotesController.notes).thenReturn([]);

      final result = controller.refreshFromSource();

      expect(result, false);
    });

    test('refreshFromSource returns false if timestamp unchanged', () {
      // notes returns testNote which has same timestamp as controller.note
      final result = controller.refreshFromSource();

      expect(result, false);
    });

    test('refreshFromSource updates note if timestamp changed', () {
      final updatedNote = testNote.copyWith(
        updatedAt: initialTime.add(const Duration(minutes: 5)),
        title: 'Updated Title',
      );
      when(() => mockInkNotesController.notes).thenReturn([updatedNote]);

      final result = controller.refreshFromSource();

      expect(result, true);
      expect(controller.note.title, 'Updated Title');
      expect(controller.note.updatedAt, updatedNote.updatedAt);
    });

    test('refreshFromSource preserves current page strokes', () {
      // Simulate current drawing state
      final currentStrokes = [
         Stroke(points: const [], id: 'current-stroke'),
      ];
      when(() => mockDrawingController.strokes).thenReturn(currentStrokes);

      // Incoming update has different strokes on the same page
      final incomingStrokes = [
         Stroke(points: const [], id: 'incoming-stroke'),
      ];
      final updatedNote = testNote.copyWith(
        updatedAt: initialTime.add(const Duration(minutes: 5)),
        pages: [
            testNote.pages[0].copyWith(strokes: incomingStrokes), // Current page (0)
            testNote.pages[1],
        ],
      );
      when(() => mockInkNotesController.notes).thenReturn([updatedNote]);

      final result = controller.refreshFromSource();

      expect(result, true);
      // The controller's note should have the NEW timestamp/metadata but OLD strokes for current page
      expect(controller.note.pages[0].strokes, currentStrokes);
      expect(controller.note.pages[0].strokes, isNot(incomingStrokes));
    });

    test('refreshFromSource updates other pages strokes', () {
       // Incoming update has changes on page 1 (not current)
      final incomingStrokes = [
         Stroke(points: const [], id: 'incoming-stroke-p1'),
      ];
      final updatedNote = testNote.copyWith(
        updatedAt: initialTime.add(const Duration(minutes: 5)),
        pages: [
            testNote.pages[0],
            testNote.pages[1].copyWith(strokes: incomingStrokes),
        ],
      );
      when(() => mockInkNotesController.notes).thenReturn([updatedNote]);

      final result = controller.refreshFromSource();

      expect(result, true);
      // Page 1 should be updated
      expect(controller.note.pages[1].strokes, incomingStrokes);
    });
  });

  group('DrawingNoteController Persistence', () {
    setUp(() async {
      await controller.initialize();
    });

    test('persistDrawing updates timestamp and calls upsert', () {
      final oldUpdatedAt = controller.note.updatedAt;

      // Fast forward a bit to ensure time difference
      // We can't easily mock DateTime.now() without a wrapper,
      // but we can check if it's after oldUpdatedAt.

      controller.persistDrawing();

      final capturedNote = verify(
        () => mockInkNotesController.upsert(
          captureAny(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).captured.first as InkNote;

      expect(capturedNote.updatedAt.isAfter(oldUpdatedAt), true);
      expect(controller.note.updatedAt.isAfter(oldUpdatedAt), true);
    });

    test('persistDrawing includes current page in changedPageIndices', () {
      controller.persistDrawing();

      verify(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: {0}, // default current page is 0
        ),
      ).called(1);
    });
  });
}
