import 'package:flutter/material.dart';

/// A wrapper widget that makes its child draggable within a [Stack].
///
/// This widget MUST be a direct child of a [Stack].
class DraggableWobblyWindow extends StatefulWidget {
  /// Creates a [DraggableWobblyWindow].
  const DraggableWobblyWindow({
    super.key,
    required this.child,
    this.initialOffset,
    this.onOffsetChanged,
    this.onDragEnd,
    this.onOrientationChanged,
  });

  /// The widget to be made draggable.
  final Widget child;

  /// Initial offset from the bottom-center position.
  final Offset? initialOffset;

  /// Callback when the position changes.
  final ValueChanged<Offset>? onOffsetChanged;

  /// Callback when dragging ends (useful for saving position).
  final ValueChanged<Offset>? onDragEnd;

  /// Callback when the orientation should change based on position.
  final ValueChanged<Axis>? onOrientationChanged;

  @override
  State<DraggableWobblyWindow> createState() => _DraggableWobblyWindowState();
}

class _DraggableWobblyWindowState extends State<DraggableWobblyWindow> {
  late Offset _offset;
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _offset = widget.initialOffset ?? Offset.zero;
  }

  @override
  void didUpdateWidget(DraggableWobblyWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialOffset != oldWidget.initialOffset) {
      _offset = widget.initialOffset ?? Offset.zero;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final size = MediaQuery.of(context).size;
    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    final Size childSize = renderBox?.size ?? Size.zero;

    Offset newOffset = _offset + details.delta;

    if (childSize != Size.zero) {
      // Clamping logic to keep the window on screen
      final double halfWidth = childSize.width / 2;
      final double screenWidth = size.width;
      final double screenHeight = size.height;
      const double padding = 16.0;

      // Horizontal Clamping
      // CenterX = screenWidth / 2 + dx
      // We want: padding + halfWidth <= CenterX <= screenWidth - padding - halfWidth
      // Substitute CenterX:
      // padding + halfWidth <= screenWidth/2 + dx <= screenWidth - padding - halfWidth
      // padding + halfWidth - screenWidth/2 <= dx <= screenWidth/2 - padding - halfWidth
      final double minDx = padding + halfWidth - screenWidth / 2;
      final double maxDx = screenWidth / 2 - padding - halfWidth;

      // Vertical Clamping
      // dy is positive downwards (decreasing bottom padding)
      // Bottom position = 24 - dy
      // We want: padding <= Bottom position <= screenHeight - padding - childHeight
      // padding <= 24 - dy <= screenHeight - padding - childHeight
      // dy <= 24 - padding
      // dy >= 24 - (screenHeight - padding - childHeight)
      final double maxDy = 24 - padding;
      final double minDy = 24 - (screenHeight - padding - childSize.height);

      double clampedDx = newOffset.dx;
      if (minDx <= maxDx) {
        clampedDx = clampedDx.clamp(minDx, maxDx);
      } else {
        clampedDx = 0; // Center if it doesn't fit
      }

      double clampedDy = newOffset.dy;
      if (minDy <= maxDy) {
        clampedDy = clampedDy.clamp(minDy, maxDy);
      } else {
        clampedDy = maxDy; // Align to bottom if it doesn't fit
      }

      newOffset = Offset(clampedDx, clampedDy);
    }

    setState(() {
      _offset = newOffset;
    });
    widget.onOffsetChanged?.call(_offset);
    _checkOrientation(details.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    widget.onDragEnd?.call(_offset);
  }

  void _checkOrientation(Offset globalPosition) {
    final size = MediaQuery.of(context).size;

    final RenderBox? renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    final Size childSize = renderBox?.size ?? Size.zero;

    // Determine current visual orientation
    final bool isCurrentlyVertical = childSize.height > childSize.width;

    // Vertical thresholds (Top/Bottom)
    final currentBottom = 24 - _offset.dy;
    final bool nearBottom = currentBottom < 100.0;
    final bool nearTop = currentBottom > size.height - 100.0;

    if (nearBottom || nearTop) {
      if (isCurrentlyVertical) {
        widget.onOrientationChanged?.call(Axis.horizontal);
      }
      return;
    }

    // Horizontal thresholds (Left/Right) based on touch position
    final double dx = globalPosition.dx;
    const double triggerZone = 80.0;
    const double releaseZone = 150.0;

    bool shouldBeVertical = isCurrentlyVertical;

    if (!isCurrentlyVertical) {
      // Horizontal -> Vertical
      if (dx < triggerZone || dx > size.width - triggerZone) {
        shouldBeVertical = true;
      }
    } else {
      // Vertical -> Horizontal
      // Stay Vertical unless moved away from edges
      if (dx > releaseZone && dx < size.width - releaseZone) {
        shouldBeVertical = false;
      }
    }

    if (shouldBeVertical != isCurrentlyVertical) {
      widget.onOrientationChanged
          ?.call(shouldBeVertical ? Axis.vertical : Axis.horizontal);
    }
  }

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 24 - _offset.dy,
        left: _offset.dx,
        right: -_offset.dx,
        top: 0, // Fill vertical space to allow Align to work
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            key: _childKey,
            onPanUpdate: _handlePanUpdate,
            onPanEnd: _handlePanEnd,
            child: widget.child,
          ),
        ),
      );
}
