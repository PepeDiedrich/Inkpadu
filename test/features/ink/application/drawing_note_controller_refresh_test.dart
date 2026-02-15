import 'package:ai_handwriting_app/features/drawing/application/drawing_controller.dart';
import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
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
  final InkNote testNote = InkNote(
    id: noteId,
    title: 'Test Note',
    updatedAt: DateTime.now(),
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

    controller = DrawingNoteController(
      noteId: noteId,
      inkNotesController: mockInkNotesController,
      drawingController: mockDrawingController,
      toolPreferencesRepository: mockToolPreferencesRepository,
    );
  });

  group('DrawingNoteController refreshFromSource', () {
    setUp(() async {
      await controller.initialize();
    });

    test('returns false if note is not found in InkNotesController', () {
      when(() => mockInkNotesController.notes).thenReturn([]);

      final result = controller.refreshFromSource();

      expect(result, false);
    });

    test('returns false if updatedAt is unchanged', () {
      // Setup mock to return the same note
      when(() => mockInkNotesController.notes).thenReturn([testNote]);

      final result = controller.refreshFromSource();

      expect(result, false);
    });

    test('updates note and returns true if updatedAt is different', () {
      final updatedNote = testNote.copyWith(
        updatedAt: DateTime.now().add(const Duration(minutes: 1)),
        title: 'Updated Title',
      );
      when(() => mockInkNotesController.notes).thenReturn([updatedNote]);

      final result = controller.refreshFromSource();

      expect(result, true);
      expect(controller.note.title, 'Updated Title');
      expect(controller.note.updatedAt, updatedNote.updatedAt);
    });

    test(
        'preserves strokes of the current page from DrawingController while updating other fields',
        () {
      // Arrange
      final strokesOnCanvas = [
        Stroke(points: [DrawingPoint(position: const Offset(10, 10))])
      ];
      when(() => mockDrawingController.strokes).thenReturn(strokesOnCanvas);

      final updatedStrokes = [
        Stroke(points: [DrawingPoint(position: const Offset(20, 20))])
      ];
      final updatedNote = testNote.copyWith(
        updatedAt: DateTime.now().add(const Duration(minutes: 1)),
        pages: [
          testNote.pages[0].copyWith(
            strokes: updatedStrokes,
            importedPdfText: 'New PDF Text',
          ),
          testNote.pages[1],
        ],
      );
      when(() => mockInkNotesController.notes).thenReturn([updatedNote]);

      // Act
      final result = controller.refreshFromSource();

      // Assert
      expect(result, true);

      // Verification:
      // 1. Current page (index 0) should keep strokes from drawingController (strokesOnCanvas)
      //    NOT the ones from the updatedNote (updatedStrokes).
      expect(controller.pages[0].strokes, strokesOnCanvas);

      // 2. But it SHOULD take other fields like importedPdfText from updatedNote
      expect(controller.pages[0].importedPdfText, 'New PDF Text');

      // 3. Note itself should be updated
      expect(controller.note.updatedAt, updatedNote.updatedAt);
    });
  });

  group('DrawingNoteController persistDrawing', () {
    setUp(() async {
      when(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).thenAnswer((_) async {});
      await controller.initialize();
    });

    test('updates updatedAt and calls upsert', () async {
      final initialUpdatedAt = controller.note.updatedAt;

      // Simulate drawing some strokes
      final strokes = [
        Stroke(points: [DrawingPoint(position: Offset.zero)])
      ];
      when(() => mockDrawingController.strokes).thenReturn(strokes);

      // Wait a bit to ensure updatedAt changes
      await Future.delayed(const Duration(milliseconds: 10));

      controller.persistDrawing();

      // updatedAt should be newer
      expect(controller.note.updatedAt.isAfter(initialUpdatedAt), true);

      // Verify upsert call
      verify(
        () => mockInkNotesController.upsert(
          any(
            that: isA<InkNote>()
                .having((n) => n.id, 'id', noteId)
                .having((n) => n.pages[0].strokes, 'strokes', strokes),
          ),
          changedPageIndices: {0},
        ),
      ).called(1);
    });
  });
}
