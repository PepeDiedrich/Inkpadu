import 'package:ai_handwriting_app/features/ink/application/drawing_tool_preferences_repository.dart';
import 'package:ai_handwriting_app/features/ink/domain/drawing_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;
  late DrawingToolPreferencesRepository repository;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    repository = DrawingToolPreferencesRepository(sharedPreferences: mockPrefs);
  });

  group('DrawingToolPreferencesRepository', () {
    const defaultTools = <DrawingTool>[
      DrawingTool(
        id: 'pen',
        label: 'Pen',
        icon: Icons.edit,
        color: Color(0xFF000000),
        baseWidth: 2.0,
      ),
    ];

    group('load', () {
      test('returns defaults when storage is empty', () async {
        when(() => mockPrefs.getString(any())).thenReturn(null);

        final result = await repository.load(defaultTools);

        expect(result, equals(defaultTools));
        verify(() => mockPrefs.getString('drawing_tools_v1')).called(1);
      });

      test('returns stored tools when valid json exists', () async {
        const storedTool = DrawingTool(
          id: 'custom_pen',
          label: 'Marker',
          icon: Icons.brush,
          color: Color(0xFFFF0000),
          baseWidth: 5.0,
          isHighlighter: true,
          usePressure: false,
        );
        // Constructed to match toJson/fromJson of DrawingTool
        final jsonString =
            '[{"id":"custom_pen","label":"Marker","icon":${Icons.brush.codePoint},"iconFontFamily":"${Icons.brush.fontFamily}","color":4294901760,"baseWidth":5.0,"isHighlighter":true,"isEraser":false,"usePressure":false}]';

        when(() => mockPrefs.getString('drawing_tools_v1'))
            .thenReturn(jsonString);

        final result = await repository.load(defaultTools);

        expect(result.length, 1);
        expect(result.first.id, storedTool.id);
        expect(result.first.label, storedTool.label);
        expect(result.first.color, storedTool.color);
        expect(result.first.baseWidth, storedTool.baseWidth);
        expect(result.first.isHighlighter, storedTool.isHighlighter);
      });

      test('returns defaults when json is invalid', () async {
        when(() => mockPrefs.getString('drawing_tools_v1'))
            .thenReturn('invalid_json');

        final result = await repository.load(defaultTools);

        expect(result, equals(defaultTools));
      });
    });

    group('save', () {
      test('persists tools to SharedPreferences', () async {
        final toolsToSave = <DrawingTool>[
          const DrawingTool(
            id: 'pen1',
            label: 'Pen 1',
            icon: Icons.edit,
            color: Color(0xFF000000),
            baseWidth: 2.0,
          ),
        ];

        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        await repository.save(toolsToSave);

        final verificationResult = verify(
          () => mockPrefs.setString(
            'drawing_tools_v1',
            captureAny(),
          ),
        );
        verificationResult.called(1);

        // Verify the captured JSON
        final capturedJson = verificationResult.captured.first as String;
        expect(capturedJson, contains('pen1'));
      });

      test('persists selectedToolId if provided', () async {
         final toolsToSave = <DrawingTool>[
          const DrawingTool(
            id: 'pen1',
            label: 'Pen 1',
            icon: Icons.edit,
            color: Color(0xFF000000),
            baseWidth: 2.0,
          ),
        ];
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);

        await repository.save(toolsToSave, selectedToolId: 'pen1');

        verify(
          () => mockPrefs.setString('drawing_selected_tool_v1', 'pen1'),
        ).called(1);
      });
    });

    group('Toolbar Position', () {
      test('loadToolbarPosition returns null when keys missing', () async {
        when(() => mockPrefs.getDouble(any())).thenReturn(null);

        final result = await repository.loadToolbarPosition();

        expect(result, isNull);
      });

      test('loadToolbarPosition returns offset when keys exist', () async {
        when(() => mockPrefs.getDouble('drawing_toolbar_pos_x_v1'))
            .thenReturn(100.0);
        when(() => mockPrefs.getDouble('drawing_toolbar_pos_y_v1'))
            .thenReturn(200.0);

        final result = await repository.loadToolbarPosition();

        expect(result, equals(const Offset(100.0, 200.0)));
      });

      test('saveToolbarPosition persists coordinates', () async {
        when(() => mockPrefs.setDouble(any(), any()))
            .thenAnswer((_) async => true);

        await repository.saveToolbarPosition(const Offset(50.0, 60.0));

        verify(
          () => mockPrefs.setDouble('drawing_toolbar_pos_x_v1', 50.0),
        ).called(1);
        verify(
          () => mockPrefs.setDouble('drawing_toolbar_pos_y_v1', 60.0),
        ).called(1);
      });
    });

    group('Toolbar Orientation', () {
      test('loadToolbarOrientation returns default horizontal when key missing',
          () async {
        when(() => mockPrefs.getInt(any())).thenReturn(null);

        final result = await repository.loadToolbarOrientation();

        expect(result, Axis.horizontal);
      });

      test('loadToolbarOrientation returns saved orientation', () async {
        when(() => mockPrefs.getInt('drawing_toolbar_orientation_v1'))
            .thenReturn(Axis.vertical.index);

        final result = await repository.loadToolbarOrientation();

        expect(result, Axis.vertical);
      });

      test('saveToolbarOrientation persists orientation index', () async {
        when(() => mockPrefs.setInt(any(), any())).thenAnswer((_) async => true);

        await repository.saveToolbarOrientation(Axis.vertical);

        verify(
          () => mockPrefs.setInt(
            'drawing_toolbar_orientation_v1',
            Axis.vertical.index,
          ),
        ).called(1);
      });
    });

    group('Selected Tool ID', () {
      test('loadSelectedToolId returns null when key missing', () async {
        when(() => mockPrefs.getString(any())).thenReturn(null);

        final result = await repository.loadSelectedToolId();

        expect(result, isNull);
      });

      test('loadSelectedToolId returns stored id', () async {
        when(() => mockPrefs.getString('drawing_selected_tool_v1'))
            .thenReturn('tool_123');

        final result = await repository.loadSelectedToolId();

        expect(result, 'tool_123');
      });

      test('saveSelectedToolId persists id', () async {
        when(() => mockPrefs.setString(any(), any()))
            .thenAnswer((_) async => true);
        // Also mocks reading tools to prevent error in _syncRemoteState logic
        when(() => mockPrefs.getString('drawing_tools_v1')).thenReturn(null);


        await repository.saveSelectedToolId('tool_456');

        verify(
          () => mockPrefs.setString('drawing_selected_tool_v1', 'tool_456'),
        ).called(1);
      });
    });
  });
}
