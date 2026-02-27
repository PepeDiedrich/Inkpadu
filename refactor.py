import re

with open(r'c:\Users\pepeh\Desktop\Inkpadu\lib\features\ink\presentation\drawing_note\widgets\drawing_canvas.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import
if 'canvas_gesture_recognizer.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/canvas_gesture_recognizer.dart';")

# 2. Replace gesture variables with CanvasGestureRecognizer
state_vars_re = re.compile(
    r'  final Map<int, Offset> _activeTouchPositions = HashMap<int, Offset>\(\);\n'
    r'  static const Duration _twoFingerTapMaxDuration = Duration\(milliseconds: 260\);\n'
    r'  static const double _twoFingerTapMaxMovement = 22;\n+'
    r'  DateTime\? _twoFingerTapStart;\n'
    r'  final Map<int, Offset> _twoFingerTapInitialPositions = <int, Offset>\{\};\n'
    r'  bool _isTwoFingerScrollActive = false;\n'
    r'  Offset\? _lastTwoFingerFocalPoint;\n'
    r'  int\? _activeDrawingPointerId;\n'
    r'  String\? _activeToolDuringStrokeId;\n'
    r'  bool _didEraseDuringDrag = false;\n'
    r'  int _lastObservedVersion = 0;\n'
    r'  DateTime\? _threeFingerTapStart;\n'
    r'  final Map<int, Offset> _threeFingerTapInitialPositions =\n      <int, Offset>\{\};\n?'
)

replacement = """  late final CanvasGestureRecognizer _gestureRecognizer;

  int? _activeDrawingPointerId;
  String? _activeToolDuringStrokeId;
  bool _didEraseDuringDrag = false;
  int _lastObservedVersion = 0;
"""
content = state_vars_re.sub(replacement, content)

# 3. Add to initState
init_state_re = re.compile(r'  void initState\(\) \{\n    super\.initState\(\);\n    _canvasScrollController = ScrollController\(\);')
init_replacement = """  void initState() {
    super.initState();
    _gestureRecognizer = CanvasGestureRecognizer(
      onTwoFingerUndo: _triggerTwoFingerUndo,
      onThreeFingerRedo: _triggerThreeFingerRedo,
      onTwoFingerScrollUpdate: _handleTwoFingerScrollUpdate,
    );
    _canvasScrollController = ScrollController();"""
content = init_state_re.sub(init_replacement, content)

# 4. Remove all the helper methods
methods_to_remove = [
    r'  Offset\? _computeTouchFocalPoint\(\) \{.*?\n  \}\n',
    r'  void _resetTwoFingerScrollState\(\) \{.*?\n  \}\n',
    r'  void _beginTwoFingerTapCandidate\(\) \{.*?\n  \}\n',
    r'  void _cancelTwoFingerTapCandidate\(\) \{.*?\n  \}\n',
    r'  void _beginThreeFingerTapCandidate\(\) \{.*?\n  \}\n',
    r'  void _cancelThreeFingerTapCandidate\(\) \{.*?\n  \}\n',
    r'  bool _isTwoFingerTapMovementWithinThreshold\(\) \{.*?\n  \}\n',
    r'  bool _isTwoFingerTapWithinTimeWindow\(\) \{.*?\n  \}\n',
    r'  bool _isThreeFingerTapMovementWithinThreshold\(\) \{.*?\n  \}\n',
    r'  bool _isThreeFingerTapWithinTimeWindow\(\) \{.*?\n  \}\n',
    r'  void _clearTwoFingerGestureState\(\) \{.*?\n  \}\n',
    r'  void _clearThreeFingerGestureState\(\) \{.*?\n  \}\n',
    r'  void _setTwoFingerScrollActive\(bool value\) \{.*?\n  \}\n',
]

for pattern in methods_to_remove:
    content = re.sub(pattern, '', content, flags=re.DOTALL)

# Add _handleTwoFingerScrollUpdate before _triggerTwoFingerUndo
undo_re = re.compile(r'  void _triggerTwoFingerUndo\(\) \{')
undo_replacement = """  void _handleTwoFingerScrollUpdate(double delta) {
    if (_canvasScrollController.hasClients) {
      final double currentOffset = _canvasScrollController.offset;
      final double maxOffset = _canvasScrollController.position.maxScrollExtent;
      final double targetOffset = (currentOffset - delta).clamp(0.0, maxOffset);
      if ((targetOffset - currentOffset).abs() > 0.01) {
        _canvasScrollController.jumpTo(targetOffset);
      }
    }
  }

  void _triggerTwoFingerUndo() {"""
content = undo_re.sub(undo_replacement, content)

# 5. Fix _start, _update, _end, _cancel pointer handlers with simpler logic using _gestureRecognizer
start_re = re.compile(r'    if \(kind == PointerDeviceKind\.touch\) \{.*?\n      if \(!touchAllowsDrawing\) \{\n        return;\n      \}\n    \}\n', re.DOTALL)
start_replacement = """    if (kind == PointerDeviceKind.touch) {
      _gestureRecognizer.handlePointerDown(details);
      bool touchAllowsDrawing = true;
      if (_gestureRecognizer.currentTouchCount >= 3) {
        _abortDrawing();
        touchAllowsDrawing = false;
      } else if (_gestureRecognizer.currentTouchCount == 2) {
        _abortDrawing();
        touchAllowsDrawing = false;
      }
      if (!touchAllowsDrawing && !settings.accept(kind)) return;
      if (!touchAllowsDrawing) return;
    }
"""
content = start_re.sub(start_replacement, content)

update_re = re.compile(r'    if \(kind == PointerDeviceKind\.touch\) \{.*?\n    \}\n\n    if \(_activeLassoPointerId', re.DOTALL)
update_replacement = """    if (kind == PointerDeviceKind.touch) {
      _gestureRecognizer.handlePointerMove(details);
      if (_gestureRecognizer.maintainsMultipleTouches) {
        return;
      }
    }

    if (_activeLassoPointerId"""
content = update_re.sub(update_replacement, content)

end_re = re.compile(r'  void _end\(PointerUpEvent details\) \{\n    if \(details\.kind == PointerDeviceKind\.touch\) \{.*?\n    \}\n\n    if \(_activeLassoPointerId', re.DOTALL)
end_replacement = """  void _end(PointerUpEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _gestureRecognizer.handlePointerUp(details);
      if (_gestureRecognizer.maintainsMultipleTouches) return;
    }

    if (_activeLassoPointerId"""
content = end_re.sub(end_replacement, content)

cancel_re = re.compile(r'  void _cancel\(PointerCancelEvent details\) \{\n    if \(details\.kind == PointerDeviceKind\.touch\) \{.*?\n    \}\n\n    if \(_activeDrawingPointerId', re.DOTALL)
cancel_replacement = """  void _cancel(PointerCancelEvent details) {
    if (details.kind == PointerDeviceKind.touch) {
      _gestureRecognizer.handlePointerCancel(details);
    }

    if (_activeDrawingPointerId"""
content = cancel_re.sub(cancel_replacement, content)

with open(r'c:\Users\pepeh\Desktop\Inkpadu\lib\features\ink\presentation\drawing_note\widgets\drawing_canvas.dart', 'w', encoding='utf-8') as f:
    f.write(content)
