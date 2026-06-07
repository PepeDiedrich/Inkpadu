import 'package:flutter/material.dart';
import 'package:inkpadu/features/drawing/application/drawing_controller.dart';
import 'package:inkpadu/features/drawing/presentation/cross_platform_webview.dart';

/// A widget layer that renders all web views on the canvas.
class WebViewLayer extends StatelessWidget {
  /// Creates a [WebViewLayer].
  const WebViewLayer({
    super.key,
    required this.drawingController,
    required this.selectedWebViewIds,
  });

  /// The drawing controller managing the web view nodes.
  final DrawingController drawingController;

  /// A set of currently selected web view IDs.
  final Set<String> selectedWebViewIds;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: drawingController,
      builder: (context, child) => Stack(
        clipBehavior: Clip.none,
        children: [
          ...drawingController.webViewNodes.map(
            (node) => Positioned(
              left: node.rect.left,
              top: node.rect.top,
              width: node.rect.width,
              height: node.rect.height,
              child: Stack(
                children: [
                  CrossPlatformWebView(node: node),
                  if (selectedWebViewIds.contains(node.id)) ...[
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: scheme.primary, width: 2),
                          color: scheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -8,
                      bottom: -8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: scheme.primary, width: 2),
                        ),
                        child: Icon(
                          Icons.open_in_full,
                          size: 14,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
