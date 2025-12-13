import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';

/// Ein Layout-Widget, das einen Hauptinhalt und eine anpassbare Seitenleiste anzeigt.
class ResizableSidebarLayout extends StatefulWidget {
  const ResizableSidebarLayout({
    super.key,
    required this.content,
    required this.sidebar,
    this.initialSidebarFraction = 0.3,
    this.minSidebarFraction = 0.0,
    this.minVisibleSidebarFraction = 0.15,
    this.maxSidebarFraction = 0.45,
    this.onSidebarFractionChanged,
  });

  /// Der Hauptinhalt der Seite (z.B. der Canvas).
  final Widget content;

  /// Der Inhalt der Seitenleiste.
  /// Wird mit einer [AnimatedOpacity] ausgeblendet, wenn sie zu klein ist.
  final Widget sidebar;

  /// Der initiale Anteil der Breite, den die Sidebar einnimmt (0.0 bis 1.0).
  final double initialSidebarFraction;

  final double minSidebarFraction;
  final double minVisibleSidebarFraction;
  final double maxSidebarFraction;

  /// Callback, wenn sich die Größe der Sidebar ändert.
  final ValueChanged<double>? onSidebarFractionChanged;

  @override
  State<ResizableSidebarLayout> createState() => ResizableSidebarLayoutState();
}

class ResizableSidebarLayoutState extends State<ResizableSidebarLayout> {
  static const double _dragHandleWidth = 12;
  static const Duration _panelAnimationDuration = Duration(milliseconds: 220);
  static const Curve _panelAnimationCurve = Curves.easeOutCubic;

  late double _sidebarFraction;
  double? _previewSidebarFraction;
  bool _isResizing = false;
  SidebarResizeTrend _resizeTrend = SidebarResizeTrend.none;

  bool get isResizing => _isResizing;
  SidebarResizeTrend get resizeTrend => _resizeTrend;
  double get currentFraction => _previewSidebarFraction ?? _sidebarFraction;

  @override
  void initState() {
    super.initState();
    _sidebarFraction = widget.initialSidebarFraction;
  }

  double _snapSidebarFraction(
    double previousFraction,
    double proposedFraction,
  ) {
    final double clamped = proposedFraction
        .clamp(widget.minSidebarFraction, widget.maxSidebarFraction)
        .toDouble();
    if (clamped < widget.minVisibleSidebarFraction) {
      if (clamped < previousFraction) {
        return widget.minSidebarFraction;
      }
      if (clamped > previousFraction) {
        return widget.minVisibleSidebarFraction;
      }
    }
    return clamped;
  }

  @override
  Widget build(BuildContext context) {
    final EditorSettings editorSettings = EditorSettingsScope.of(context);
    final bool panelOnRight = editorSettings.isPanelOnRight;

    final double sidebarFraction = _sidebarFraction
        .clamp(widget.minSidebarFraction, widget.maxSidebarFraction)
        .toDouble();
    final double previewFraction = (_previewSidebarFraction ?? sidebarFraction)
        .clamp(widget.minSidebarFraction, widget.maxSidebarFraction)
        .toDouble();
    final bool isCollapsed = previewFraction < widget.minVisibleSidebarFraction;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double baseWidth = maxWidth <= 0 ? 1 : maxWidth;
        final double panelWidth = baseWidth * previewFraction;
        final double orientationFactor = panelOnRight ? 1 : -1;

        // Ensure handle stays within bounds
        final double rawHandleOffset = math.max(
          panelWidth - _dragHandleWidth,
          0,
        );
        final double handleOffset =
            rawHandleOffset > baseWidth ? baseWidth : rawHandleOffset;

        return Stack(
          children: [
            // Main Content uses full space; logic inside content should handle padding if needed,
            // or we could use a Row/margin.
            // In the original code, the content (PageView) was Positioned.fill behind everything.
            Positioned.fill(
              child: widget.content,
            ),

            // Sidebar
            AnimatedPositioned(
              duration: _isResizing ? Duration.zero : _panelAnimationDuration,
              curve: _panelAnimationCurve,
              top: 0,
              bottom: 0,
              left: panelOnRight ? null : 0,
              right: panelOnRight ? 0 : null,
              width: panelWidth,
              child: IgnorePointer(
                ignoring: isCollapsed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 120),
                  opacity: isCollapsed ? 0 : 1,
                  child: widget.sidebar,
                ),
              ),
            ),

            // Drag Handle
            Positioned(
              top: 0,
              bottom: 0,
              left: panelOnRight ? null : handleOffset,
              right: panelOnRight ? handleOffset : null,
              child: SizedBox(
                width: _dragHandleWidth,
                child: SidebarResizeHandle(
                  isActive: _isResizing,
                  side: editorSettings.sidebarSide,
                  onDragStart: () => setState(() {
                    _isResizing = true;
                    _previewSidebarFraction = _sidebarFraction;
                    _resizeTrend = SidebarResizeTrend.none;
                  }),
                  onDragUpdate: (delta) {
                    setState(() {
                      final double currentPreview =
                          _previewSidebarFraction ?? _sidebarFraction;
                      final double deltaFraction =
                          (delta / baseWidth) * orientationFactor;
                      final double proposedFraction =
                          currentPreview - deltaFraction;
                      final double nextPreview = _snapSidebarFraction(
                        currentPreview,
                        proposedFraction,
                      );

                      _previewSidebarFraction = nextPreview;

                      if (nextPreview > currentPreview) {
                        _resizeTrend = SidebarResizeTrend.expand;
                      } else if (nextPreview < currentPreview) {
                        _resizeTrend = SidebarResizeTrend.shrink;
                      } else {
                        _resizeTrend = SidebarResizeTrend.none;
                      }

                      widget.onSidebarFractionChanged?.call(nextPreview);
                    });
                  },
                  onDragEnd: () => setState(() {
                    final double previous = _sidebarFraction;
                    final double target =
                        _previewSidebarFraction ?? _sidebarFraction;
                    final double adjustedTarget = _snapSidebarFraction(
                      previous,
                      target,
                    );

                    _sidebarFraction = adjustedTarget;
                    _previewSidebarFraction = null;
                    _isResizing = false;
                    _resizeTrend = SidebarResizeTrend.none;

                    widget.onSidebarFractionChanged?.call(adjustedTarget);
                  }),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
