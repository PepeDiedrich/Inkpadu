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

  group('DrawingNoteController Initialization', () {
    test('initializes with note from InkNotesController', () async {
      await controller.initialize();

      expect(controller.note.id, noteId);
      expect(controller.pages.length, 2);
      expect(controller.isInitialized, true);
      verify(() => mockDrawingController.initialize(any())).called(1);
    });

    test('creates placeholder note if not found', () async {
      when(() => mockInkNotesController.notes).thenReturn([]);
      when(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).thenAnswer((_) async {});

      await controller.initialize();

      expect(controller.note.id, noteId);
      expect(controller.note.title, 'Fehlende Notiz');
      verify(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).called(1);
    });
  });

  group('Tool Management', () {
    setUp(() async {
      await controller.initialize();
    });

    test('selectTool updates selectedToolId and persists it', () {
      final tools = controller.tools;
      final secondToolId = tools[1].id;

      controller.selectTool(secondToolId);

      expect(controller.selectedToolId, secondToolId);
      verify(
        () => mockToolPreferencesRepository.saveSelectedToolId(
          secondToolId,
          currentTools: any(named: 'currentTools'),
        ),
      ).called(1);
    });

    test('addTool adds a new tool and selects it', () {
      final initialCount = controller.tools.length;
      final newTool = controller.addTool();

      expect(controller.tools.length, initialCount + 1);
      expect(controller.selectedToolId, newTool.id);
      verify(
        () => mockToolPreferencesRepository.save(
          any(),
          selectedToolId: newTool.id,
        ),
      ).called(1);
    });

    test('removeTool removes tool and selects default if needed', () {
      final toolToRemove = controller.tools.first;
      // Ensure we have enough tools to remove one
      controller.addTool();

      controller.removeTool(toolToRemove.id);

      expect(
        controller.tools.any((t) => t.id == toolToRemove.id),
        false,
      );
      expect(controller.selectedToolId, isNot(toolToRemove.id));
    });
  });

  group('Navigation and Persistence', () {
    setUp(() async {
      when(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).thenAnswer((_) async {});
      await controller.initialize();
    });

    test('setCurrentPage persists current strokes and switches page', () {
      final initialPageIndex = controller.currentPageIndex;
      const targetPageIndex = 1;

      // Simulate some strokes on the current page
      final strokes = [
        Stroke(points: [DrawingPoint(position: Offset.zero, pressure: 0.5)], baseWidth: 1.0)
      ];
      when(() => mockDrawingController.strokes).thenReturn(strokes);

      controller.setCurrentPage(targetPageIndex);

      // Should have persisted the old page
      verify(() => mockInkNotesController.upsert(
            any(that: isA<InkNote>()),
            changedPageIndices: {initialPageIndex},
          )).called(1);

      expect(controller.currentPageIndex, targetPageIndex);
      // Initializes drawing controller for new page
      verify(() => mockDrawingController.initialize(any())).called(2); // Once at init, once now
    });

    test('addPageAfterCurrent inserts page and switches to it', () {
        // Mock current page having content so we can add a page
       when(() => mockDrawingController.strokes).thenReturn([
         Stroke(points: [DrawingPoint(position: Offset.zero, pressure: 0.5)], baseWidth: 1.0)
       ]);

      final initialLength = controller.pages.length;
      final newPageIndex = controller.addPageAfterCurrent();

      expect(newPageIndex, isNotNull);
      expect(controller.pages.length, initialLength + 1);
      expect(controller.currentPageIndex, newPageIndex);
    });
  });

    group('Metadata Updates', () {
    setUp(() async {
       when(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).thenAnswer((_) async {});
      await controller.initialize();
    });

    test('updateMetadata updates title and paper style', () {
      const newTitle = 'Updated Title';
      const newStyle = NotePaperStyle.dotted;

      controller.updateMetadata(title: newTitle, paperStyle: newStyle);

      expect(controller.note.title, newTitle);
      expect(controller.note.paperStyle, newStyle);
      verify(() => mockInkNotesController.upsert(any(), changedPageIndices: any(named: 'changedPageIndices'))).called(1);
    });
  });

  group('Assistant Integration', () {
    setUp(() async {
        when(
        () => mockInkNotesController.upsert(
          any(),
          changedPageIndices: any(named: 'changedPageIndices'),
        ),
      ).thenAnswer((_) async {});
      await controller.initialize();
    });

    test('appendAssistantMessage adds message to history', () {
      final message = AssistantMessage(
        question: 'Hello',
        answer: 'Hi there',
        createdAt: DateTime.now(),
      );

      controller.appendAssistantMessage(message);

      expect(controller.currentAssistantHistory.contains(message), true);
      verify(() => mockInkNotesController.upsert(any(), changedPageIndices: any(named: 'changedPageIndices'))).called(1);
    });
  });
}
