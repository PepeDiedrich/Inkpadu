import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart'
    show EditorSidebarSide;
import 'package:ai_handwriting_app/features/ink/application/drawing_note_controller.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/assistant_panel.dart';
import 'package:ai_handwriting_app/features/ink/presentation/drawing_note/widgets/sidebar_resize_handle.dart';
import 'package:flutter/material.dart';

/// Animated sidebar container for the assistant panel.
///
/// Wraps [AssistantPanel] with position and opacity animations.
/// Extracted to isolate sidebar rebuild scope from main canvas.
class AnimatedSidebar extends StatelessWidget {
  /// Creates an animated sidebar.
  const AnimatedSidebar({
    super.key,
    required this.panelWidth,
    required this.isResizing,
    required this.previewFraction,
    required this.resizeTrend,
    required this.sidebarSide,
    required this.controller,
    required this.strokeClusters,
    required this.isCollapsed,
  });

  /// Width of the sidebar panel.
  final double panelWidth;

  /// Whether the sidebar is currently being resized.
  final bool isResizing;

  /// Preview width fraction during resize.
  final double previewFraction;

  /// Current resize direction trend.
  final SidebarResizeTrend resizeTrend;

  /// Which side the sidebar is on.
  final EditorSidebarSide sidebarSide;

  /// The drawing note controller.
  final DrawingNoteController controller;

  /// Stroke clusters for the assistant panel.
  final List<StrokeBoundingBoxCluster> strokeClusters;

  /// Whether the sidebar is collapsed.
  final bool isCollapsed;

  static const Duration _animationDuration = Duration(milliseconds: 220);
  static const Curve _animationCurve = Curves.easeOutCubic;

  @override
  Widget build(BuildContext context) {
    final bool panelOnRight = sidebarSide == EditorSidebarSide.right;

    return AnimatedPositioned(
      duration: _animationDuration,
      curve: _animationCurve,
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
          child: AssistantPanel(
            isActive: isResizing,
            widthFraction: previewFraction,
            resizeTrend: resizeTrend,
            side: sidebarSide,
            controller: controller,
            strokeClusters: strokeClusters,
          ),
        ),
      ),
    );
  }
}
