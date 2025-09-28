import 'package:ai_handwriting_app/app/theme/app_colors.dart';
import 'package:ai_handwriting_app/features/editor/application/editor_settings_scope.dart';
import 'package:flutter/material.dart';

/// Beschreibt die aktuelle Richtung einer Sidebar-Größenänderung.
enum SidebarResizeTrend {
  /// Keine Größenänderung aktiv.
  none,

  /// Die Sidebar wird breiter.
  expand,

  /// Die Sidebar wird schmaler.
  shrink,
}

/// Griff zum Verändern der Sidebar-Breite.
class SidebarResizeHandle extends StatelessWidget {
  /// Erstellt einen Griff zum Resizen der Sidebar.
  const SidebarResizeHandle({
    super.key,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.isActive,
    required this.side,
    this.width = 12,
  });

  /// Callback beim Start der Drag-Geste.
  final VoidCallback onDragStart;

  /// Callback bei jeder Horizontalbewegung (Pixel).
  final ValueChanged<double> onDragUpdate;

  /// Callback am Ende der Drag-Geste.
  final VoidCallback onDragEnd;

  /// Ob der Griff hervorgehoben wird.
  final bool isActive;

  /// Seite, an der der Griff angezeigt wird.
  final EditorSidebarSide side;

  /// Sichtbare Breite des Griffs.
  final double width;

  @override
  Widget build(BuildContext context) {
    final Color stripeColor = isActive
        ? AppColors.primaryAccent
        : Theme.of(context).colorScheme.outlineVariant;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: (_) => onDragStart(),
        onHorizontalDragUpdate: (details) => onDragUpdate(details.delta.dx),
        onHorizontalDragEnd: (_) => onDragEnd(),
        onHorizontalDragCancel: onDragEnd,
        child: Container(
          width: width,
          color: Colors.transparent,
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: isActive ? 8 : 4,
            height: 80,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
