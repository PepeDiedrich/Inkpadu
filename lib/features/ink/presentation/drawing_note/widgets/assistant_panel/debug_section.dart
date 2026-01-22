import 'dart:math' as math;

import 'package:ai_handwriting_app/features/drawing/application/drawing_snapshot_service.dart';
import 'package:ai_handwriting_app/features/ink/application/assistant/cluster_shape_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visualisiert Debug-Informationen zum letzten KI-Aufruf.
class AssistantDebugSection extends StatelessWidget {
  /// Erstellt eine Debug-Sektion mit Token- und Snapshot-Daten.
  const AssistantDebugSection({
    super.key,
    required this.prompt,
    required this.snapshot,
    required this.tokenEstimate,
    required this.totalClusters,
    required this.payloadPreview,
    required this.clusterShapes,
    required this.showClusterInfo,
    this.pdfContextTokens = 0,
  });

  /// Vollständiger Prompttext, der an das Modell gesendet wurde.
  final String prompt;
  /// Kombinierter Snapshot der Zeichenfläche.
  final CombinedSnapshot? snapshot;
  /// Geschätzte Anzahl konsumierter Tokens.
  final int? tokenEstimate;
  /// Anzahl erkannter Stroke-Cluster auf der Zeichenfläche.
  final int totalClusters;
  /// JSON-Vorschau der generierten Payload.
  final String? payloadPreview;
  /// Geometrische Formen der Cluster zur Visualisierung.
  final List<ClusterShapeData> clusterShapes;
  /// Ob Bounding-Boxen und Hüllen angezeigt werden sollen.
  final bool showClusterInfo;
  /// Geschätzte Tokens für den PDF-Kontext (zählt nicht zum Limit).
  final int pdfContextTokens;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;

    final String tokenLabel = tokenEstimate != null
        ? pdfContextTokens > 0
            ? 'Tokens: $tokenEstimate (+$pdfContextTokens PDF)'
            : 'Token-Schätzung: $tokenEstimate T.'
        : 'Token-Schätzung: –';

    final List<Widget> children = <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Debug: Gesendete Daten',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            tokenLabel,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        pdfContextTokens > 0
            ? 'PDF-Kontext wird separat übertragen und nicht abgeschnitten.'
            : 'Heuristik: Text ≈ Zeichen/4 · Tokens, Bilder ≈ 80 + 1,6 · KiB',
        style: textTheme.bodySmall?.copyWith(
          color: pdfContextTokens > 0
              ? colorScheme.tertiary
              : colorScheme.onSurfaceVariant,
        ),
      ),
    ];

    if (prompt.isNotEmpty) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            'Prompt',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
        ..add(const SizedBox(height: 6))
        ..add(
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(prompt, style: textTheme.bodyMedium),
            ),
          ),
        );
    }

    final CombinedSnapshot? combinedSnapshot = snapshot;
    if (combinedSnapshot != null) {
      final Size logicalSize = combinedSnapshot.logicalSize;
      final Size pixelSize = combinedSnapshot.pixelSize;
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            'Gesamtsnapshot ($totalClusters Cluster)',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
        ..add(const SizedBox(height: 6))
        ..add(
          Text(
            'Logische Größe: ${logicalSize.width.toStringAsFixed(0)} × '
            '${logicalSize.height.toStringAsFixed(0)} px · '
            'Pixel: ${pixelSize.width.toStringAsFixed(0)} × '
            '${pixelSize.height.toStringAsFixed(0)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        )
        ..add(const SizedBox(height: 4))
        ..add(
          Text(
            'Skalierung: '
            '${(combinedSnapshot.scale * 100).toStringAsFixed(0)} % · '
            'Pixelratio: ${combinedSnapshot.pixelRatio.toStringAsFixed(2)}',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        )
        ..add(const SizedBox(height: 8))
        ..add(
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.memory(
                    combinedSnapshot.pngBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
    }

    if (payloadPreview?.isNotEmpty ?? false) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            'JSON-Payload',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
        ..add(const SizedBox(height: 6))
        ..add(
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 260),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                primary: false,
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  payloadPreview!,
                  style: textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
                ),
              ),
            ),
          ),
        );
    }

    if (showClusterInfo) {
      children
        ..add(const SizedBox(height: 12))
        ..add(
          Text(
            'Bounding-Boxen & Hüllen',
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        )
        ..add(const SizedBox(height: 6))
        ..add(
          _ClusterDebugPreview(
            shapes: clusterShapes,
            colorScheme: colorScheme,
          ),
        )
        ..add(const SizedBox(height: 6))
        ..add(
          Text(
            'Türkis: Bounding-Box · Gold: Konvexe Hülle',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
    }

    return Container(
      key: const ValueKey<String>('assistant_debug_panel'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _ClusterDebugPreview extends StatelessWidget {
  const _ClusterDebugPreview({
    required this.shapes,
    required this.colorScheme,
  });

  final List<ClusterShapeData> shapes;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: CustomPaint(painter: _ClusterPreviewPainter(shapes)),
          ),
        ),
      );
}

class _ClusterPreviewPainter extends CustomPainter {
  const _ClusterPreviewPainter(this.shapes);

  final List<ClusterShapeData> shapes;

  @override
  void paint(Canvas canvas, Size size) {
    if (shapes.isEmpty) {
      final TextPainter textPainter = TextPainter(
        text: const TextSpan(
          text: 'Keine Cluster erkannt',
          style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) * 0.5,
          (size.height - textPainter.height) * 0.5,
        ),
      );
      return;
    }

    final Rect? bounds = _computeBounds();
    if (bounds == null) {
      return;
    }

    const double padding = 12;
    final double availableWidth = size.width - padding * 2;
    final double availableHeight = size.height - padding * 2;
    if (availableWidth <= 0 || availableHeight <= 0) {
      return;
    }

    final double width = math.max(bounds.width, 1e-3);
    final double height = math.max(bounds.height, 1e-3);
    final double scale = math.min(
      availableWidth / width,
      availableHeight / height,
    );

    final double offsetX =
        (size.width - width * scale) * 0.5 - bounds.left * scale;
    final double offsetY =
        (size.height - height * scale) * 0.5 - bounds.top * scale;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final Paint hullFillPaint = Paint()
      ..color = const Color(0x33FFC107)
      ..style = PaintingStyle.fill;
    final Paint hullStrokePaint = Paint()
      ..color = const Color(0xFFFFC107)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 / scale;
    final Paint boxFillPaint = Paint()
      ..color = const Color(0x1A2962FF)
      ..style = PaintingStyle.fill;
    final Paint boxStrokePaint = Paint()
      ..color = const Color(0xFF2962FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 / scale;

    for (final ClusterShapeData shape in shapes) {
      if (shape.hull.length >= 3) {
        final Path hullPath = Path()..addPolygon(shape.hull, true);
        canvas.drawPath(hullPath, hullFillPaint);
        canvas.drawPath(hullPath, hullStrokePaint);
      } else if (shape.hull.length == 2) {
        final Path hullPath = Path()..addPolygon(shape.hull, false);
        canvas.drawPath(hullPath, hullStrokePaint);
      } else if (shape.hull.length == 1) {
        canvas.drawCircle(shape.hull.first, 3 / scale, hullStrokePaint);
      }

      if (shape.boundingCorners.isNotEmpty) {
        final Path boxPath = Path()..addPolygon(shape.boundingCorners, true);
        final Rect boxBounds = boxPath.getBounds();
        if (boxBounds.width > 0 && boxBounds.height > 0) {
          canvas.drawPath(boxPath, boxFillPaint);
        }
        canvas.drawPath(boxPath, boxStrokePaint);
      }
    }

    canvas.restore();

    final Paint framePaint = Paint()
      ..color = const Color(0x40FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final RRect frame = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        padding * 0.5,
        padding * 0.5,
        size.width - padding,
        size.height - padding,
      ),
      const Radius.circular(12),
    );
    canvas.drawRRect(frame, framePaint);
  }

  Rect? _computeBounds() {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final ClusterShapeData shape in shapes) {
      for (final Offset point in shape.hull) {
        if (point.dx < minX) minX = point.dx;
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy < minY) minY = point.dy;
        if (point.dy > maxY) maxY = point.dy;
      }
      for (final Offset corner in shape.boundingCorners) {
        if (corner.dx < minX) minX = corner.dx;
        if (corner.dx > maxX) maxX = corner.dx;
        if (corner.dy < minY) minY = corner.dy;
        if (corner.dy > maxY) maxY = corner.dy;
      }
    }

    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return null;
    }

    if ((maxX - minX).abs() < 1e-6 && (maxY - minY).abs() < 1e-6) {
      return Rect.fromLTWH(minX - 4, minY - 4, 8, 8);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  bool shouldRepaint(covariant _ClusterPreviewPainter oldDelegate) =>
      !listEquals(oldDelegate.shapes, shapes);
}
