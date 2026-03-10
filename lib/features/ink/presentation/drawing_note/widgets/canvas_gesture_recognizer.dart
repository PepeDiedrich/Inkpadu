import 'package:flutter/gestures.dart';

/// Helper class to handle custom Canvas gestures like 2-finger tap (undo)
/// and 3-finger tap (redo), as well as two-finger scrolling.
class CanvasGestureRecognizer {
  /// Creates a [CanvasGestureRecognizer].
  CanvasGestureRecognizer({
    required this.onTwoFingerUndo,
    required this.onThreeFingerRedo,
    required this.onTwoFingerScrollUpdate,
  });

  /// Called when a two-finger tap is recognized as an undo command.
  final void Function() onTwoFingerUndo;

  /// Called when a three-finger tap is recognized as a redo command.
  final void Function() onThreeFingerRedo;

  /// Called when a two-finger scroll gesture is active.
  final void Function(double deltaY) onTwoFingerScrollUpdate;

  static const Duration _twoFingerTapMaxDuration = Duration(milliseconds: 260);
  static const double _twoFingerTapMaxMovement = 22;

  final Map<int, Offset> _activeTouchPositions = <int, Offset>{};

  DateTime? _twoFingerTapStart;
  final Map<int, Offset> _twoFingerTapInitialPositions = <int, Offset>{};
  bool _isTwoFingerScrollActive = false;
  Offset? _lastTwoFingerFocalPoint;

  DateTime? _threeFingerTapStart;
  final Map<int, Offset> _threeFingerTapInitialPositions = <int, Offset>{};

  /// Whether multiple touches are currently being tracked.
  bool get maintainsMultipleTouches => _activeTouchPositions.length >= 2;

  /// The number of active touch points currently on the canvas.
  int get currentTouchCount => _activeTouchPositions.length;

  /// Handles pointer down events and updates gesture candidates.
  void handlePointerDown(PointerDownEvent details) {
    if (details.kind != PointerDeviceKind.touch) return;

    _activeTouchPositions[details.pointer] = details.localPosition;
    final int touchCount = _activeTouchPositions.length;

    if (touchCount >= 3) {
      if (touchCount == 3) {
        _beginThreeFingerTapCandidate();
      } else {
        _cancelThreeFingerTapCandidate();
      }
      _cancelTwoFingerTapCandidate();
      _setTwoFingerScrollActive(false);
      _lastTwoFingerFocalPoint = null;
    } else if (touchCount == 2) {
      _cancelThreeFingerTapCandidate();
      _beginTwoFingerTapCandidate();
    } else {
      _cancelTwoFingerTapCandidate();
      _cancelThreeFingerTapCandidate();
    }
  }

  /// Handles pointer move events and identifies scrolling or tap movement violations.
  void handlePointerMove(PointerMoveEvent details) {
    if (details.kind != PointerDeviceKind.touch) return;

    _activeTouchPositions[details.pointer] = details.localPosition;
    final int touchCount = _activeTouchPositions.length;

    if (touchCount >= 4) {
      _cancelThreeFingerTapCandidate();
      _cancelTwoFingerTapCandidate();
      _setTwoFingerScrollActive(true);
      return;
    }

    if (touchCount == 3) {
      _setTwoFingerScrollActive(false);
      _lastTwoFingerFocalPoint = null;
      if (_threeFingerTapStart != null) {
        if (!_isThreeFingerTapMovementWithinThreshold() ||
            !_isThreeFingerTapWithinTimeWindow()) {
          _cancelThreeFingerTapCandidate();
        }
      }
      return;
    }

    if (touchCount == 2) {
      if (_threeFingerTapStart != null) {
        if (!_isThreeFingerTapMovementWithinThreshold() ||
            !_isThreeFingerTapWithinTimeWindow()) {
          _cancelThreeFingerTapCandidate();
        } else {
          return;
        }
      }

      if (_twoFingerTapStart != null) {
        if (!_isTwoFingerTapMovementWithinThreshold() ||
            !_isTwoFingerTapWithinTimeWindow()) {
          _cancelTwoFingerTapCandidate();
          _setTwoFingerScrollActive(true);
        }
      } else {
        _setTwoFingerScrollActive(true);
      }

      final Offset? focal = _computeTouchFocalPoint();
      if (_isTwoFingerScrollActive &&
          focal != null &&
          _lastTwoFingerFocalPoint != null) {
        final double delta = focal.dy - _lastTwoFingerFocalPoint!.dy;
        onTwoFingerScrollUpdate(delta);
      }
      _lastTwoFingerFocalPoint = focal ?? _lastTwoFingerFocalPoint;
    }
  }

  /// Handles pointer up events and triggers undo/redo if the criteria are met.
  void handlePointerUp(PointerUpEvent details) {
    if (details.kind != PointerDeviceKind.touch) return;

    _activeTouchPositions[details.pointer] = details.localPosition;

    final bool twoFingerCandidate = _twoFingerTapStart != null;
    final bool twoWithinMovement =
        twoFingerCandidate && _isTwoFingerTapMovementWithinThreshold();
    final bool twoWithinTime =
        twoFingerCandidate && _isTwoFingerTapWithinTimeWindow();

    final bool threeFingerCandidate = _threeFingerTapStart != null;
    final bool threeWithinMovement =
        threeFingerCandidate && _isThreeFingerTapMovementWithinThreshold();
    final bool threeWithinTime =
        threeFingerCandidate && _isThreeFingerTapWithinTimeWindow();

    _activeTouchPositions.remove(details.pointer);
    final int remainingTouches = _activeTouchPositions.length;

    final bool threeCandidateValid =
        threeFingerCandidate && threeWithinTime && threeWithinMovement;

    if (threeCandidateValid && remainingTouches == 0) {
      onThreeFingerRedo();
      _clearThreeFingerGestureState();
      _clearTwoFingerGestureState();
      return;
    }

    if (threeFingerCandidate && (!threeWithinTime || !threeWithinMovement)) {
      _cancelThreeFingerTapCandidate();
    }

    if (threeCandidateValid && remainingTouches > 0) {
      return;
    }

    if (twoFingerCandidate &&
        twoWithinTime &&
        twoWithinMovement &&
        remainingTouches < 2 &&
        !_isTwoFingerScrollActive) {
      onTwoFingerUndo();
      _clearTwoFingerGestureState();
    } else if (remainingTouches < 2) {
      _clearTwoFingerGestureState();
    }

    if (remainingTouches >= 2) {
      _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
    }
  }

  /// Resets the gesture state when a pointer event is cancelled.
  void handlePointerCancel(PointerCancelEvent details) {
    if (details.kind != PointerDeviceKind.touch) return;
    _activeTouchPositions.remove(details.pointer);
    _resetTwoFingerScrollState();
    _cancelThreeFingerTapCandidate();
  }

  Offset? _computeTouchFocalPoint() {
    if (_activeTouchPositions.isEmpty) return null;
    var focal = Offset.zero;
    for (final position in _activeTouchPositions.values) {
      focal += position;
    }
    return focal / _activeTouchPositions.length.toDouble();
  }

  void _resetTwoFingerScrollState() {
    if (_activeTouchPositions.length < 2) {
      _clearTwoFingerGestureState();
      _cancelThreeFingerTapCandidate();
    } else {
      _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
    }
  }

  void _beginTwoFingerTapCandidate() {
    _twoFingerTapStart = DateTime.now();
    _twoFingerTapInitialPositions
      ..clear()
      ..addAll(_activeTouchPositions);
    _lastTwoFingerFocalPoint = _computeTouchFocalPoint();
    _setTwoFingerScrollActive(false);
  }

  void _cancelTwoFingerTapCandidate() {
    _twoFingerTapStart = null;
    _twoFingerTapInitialPositions.clear();
  }

  void _beginThreeFingerTapCandidate() {
    _threeFingerTapStart = DateTime.now();
    _threeFingerTapInitialPositions
      ..clear()
      ..addAll(_activeTouchPositions);
  }

  void _cancelThreeFingerTapCandidate() {
    _threeFingerTapStart = null;
    _threeFingerTapInitialPositions.clear();
  }

  bool _isTwoFingerTapMovementWithinThreshold() {
    if (_twoFingerTapStart == null || _twoFingerTapInitialPositions.isEmpty) {
      return false;
    }
    final double maxSquared =
        _twoFingerTapMaxMovement * _twoFingerTapMaxMovement;
    for (final entry in _twoFingerTapInitialPositions.entries) {
      final Offset? current = _activeTouchPositions[entry.key];
      if (current == null) continue;
      final double dx = current.dx - entry.value.dx;
      final double dy = current.dy - entry.value.dy;
      if ((dx * dx + dy * dy) > maxSquared) return false;
    }
    return true;
  }

  bool _isTwoFingerTapWithinTimeWindow() {
    if (_twoFingerTapStart == null) return false;
    return DateTime.now().difference(_twoFingerTapStart!) <=
        _twoFingerTapMaxDuration;
  }

  bool _isThreeFingerTapMovementWithinThreshold() {
    if (_threeFingerTapStart == null ||
        _threeFingerTapInitialPositions.isEmpty) {
      return false;
    }
    final double maxSquared =
        _twoFingerTapMaxMovement * _twoFingerTapMaxMovement;
    for (final entry in _threeFingerTapInitialPositions.entries) {
      final Offset? current = _activeTouchPositions[entry.key];
      if (current == null) continue;
      final double dx = current.dx - entry.value.dx;
      final double dy = current.dy - entry.value.dy;
      if ((dx * dx + dy * dy) > maxSquared) return false;
    }
    return true;
  }

  bool _isThreeFingerTapWithinTimeWindow() {
    if (_threeFingerTapStart == null) return false;
    return DateTime.now().difference(_threeFingerTapStart!) <=
        _twoFingerTapMaxDuration;
  }

  void _clearTwoFingerGestureState() {
    _setTwoFingerScrollActive(false);
    _lastTwoFingerFocalPoint = null;
    _cancelTwoFingerTapCandidate();
    _cancelThreeFingerTapCandidate();
  }

  void _clearThreeFingerGestureState() {
    _cancelThreeFingerTapCandidate();
  }

  void _setTwoFingerScrollActive(bool value) {
    _isTwoFingerScrollActive = value;
  }
}
