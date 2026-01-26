import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ai_handwriting_app/features/drawing/application/convex_hull_calculator.dart'
    show RotatedBoundingBox, StrokeBoundingBoxCluster;
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:flutter/material.dart';

/// Enthält die erzeugten PNG-Daten für einen Stroke-Cluster.
class ClusterSnapshot {
  /// Erstellt eine Snapshot-Repräsentation für den angegebenen [cluster].
  ClusterSnapshot({
    required this.cluster,
    required this.boundingRect,
    required this.pngBytes,
  });

  /// Zugehöriger Cluster der Aufnahme.
  final StrokeBoundingBoxCluster cluster;

  /// Axis-Aligned Rectangle, das für den Export verwendet wurde.
  final Rect boundingRect;

  /// PNG-kodierte Bilddaten des Ausschnitts.
  final Uint8List pngBytes;

  /// Gibt die PNG-Daten als Base64-kodierten String zurück.
  String get base64Data => base64Encode(pngBytes);
}

/// Beschreibt einen Abschnitt innerhalb des kombinierten Zeitstrahl-Bildes.
/// Zusammengeführter Snapshot über alle Cluster.
class CombinedSnapshot {
  /// Erzeugt einen kombinierten Snapshot über alle beteiligten Cluster.
  const CombinedSnapshot({
    required this.pngBytes,
    required this.logicalBounds,
    required this.logicalSize,
    required this.scale,
    required this.pixelRatio,
  });

  /// PNG-kodiertes Bild mit allen Clustern.
  final Uint8List pngBytes;

  /// Ursprünglicher logischer Bereich der Zeichnung (inkl. Padding).
  final Rect logicalBounds;

  /// Logische Größe vor Anwendung des Skalierungsfaktors.
  final Size logicalSize;

  /// Eingesetzter Skalierungsfaktor, um das Bild zu verkleinern.
  final double scale;

  /// Pixelratio für den Export.
  final double pixelRatio;

  /// Base64-Repräsentation des PNGs.
  String get base64Data => base64Encode(pngBytes);

  /// Effektive Bildgröße in Pixeln.
  Size get pixelSize => Size(
    logicalSize.width * scale * pixelRatio,
    logicalSize.height * scale * pixelRatio,
  );
}

/// Erstellt Bildausschnitte für Stroke-Cluster, um sie an ein LLM zu senden.
class DrawingSnapshotService {
  /// Erstellt einen neuen Dienst zum Generieren von Drawing-Snapshots.
  const DrawingSnapshotService();

  /// Rendert die übergebenen [clusters] als einzelne PNG-Ausschnitte.
  Future<List<ClusterSnapshot>> captureClusters(
    List<StrokeBoundingBoxCluster> clusters, {
    double padding = 16,
    double pixelRatio = 2.0,
    Color backgroundColor = Colors.white,
  }) async {
    if (clusters.isEmpty) {
      return const <ClusterSnapshot>[];
    }

    final List<ClusterSnapshot> snapshots = <ClusterSnapshot>[];

    for (final StrokeBoundingBoxCluster cluster in clusters) {
      if (!cluster.hasContent) {
        continue;
      }

      final Rect axisBounds = _axisAlignedBounds(cluster.boundingBox);
      final Rect expandedBounds = axisBounds.inflate(padding);

      final double logicalWidth = math.max(expandedBounds.width, 1);
      final double logicalHeight = math.max(expandedBounds.height, 1);

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);

      final Paint backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, 0, logicalWidth, logicalHeight),
        backgroundPaint,
      );
      canvas.translate(-expandedBounds.left, -expandedBounds.top);

      for (final Stroke stroke in cluster.strokes) {
        _paintStroke(canvas, stroke);
      }

      final ui.Picture picture = recorder.endRecording();
      final int targetWidth = math.max(1, (logicalWidth * pixelRatio).round());
      final int targetHeight = math.max(
        1,
        (logicalHeight * pixelRatio).round(),
      );

      final ui.Image image = await picture.toImage(targetWidth, targetHeight);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        continue;
      }

      snapshots.add(
        ClusterSnapshot(
          cluster: cluster,
          boundingRect: expandedBounds,
          pngBytes: byteData.buffer.asUint8List(),
        ),
      );
    }

    return snapshots;
  }

  /// Erstellt ein einzelnes Bild über alle [clusters], wobei alle Inhalte
  /// kompakt ohne ursprüngliche Abstände angeordnet werden.
  Future<CombinedSnapshot?> captureCombinedSnapshot(
    List<StrokeBoundingBoxCluster> clusters, {
    double outerPadding = 8,
    double clusterPadding = 4,
    double gap = 4,
    double clusterScale = 1.25,
    double maxDimension = 896,
    double pixelRatio = 1.0,
    Color backgroundColor = Colors.white,
  }) async {
    final List<StrokeBoundingBoxCluster> viableClusters = clusters
        .where((cluster) => cluster.hasContent)
        .toList(growable: false);

    if (viableClusters.isEmpty) {
      return null;
    }

    clusterScale = clusterScale.clamp(0.1, 10.0);

    final List<_ClusterLayoutEntry> entries = viableClusters
        .map((cluster) {
          final Rect bounds = _axisAlignedBounds(cluster.boundingBox);
          final double baseWidth = math.max(bounds.width, 1);
          final double baseHeight = math.max(bounds.height, 1);
          final double scaledWidth = baseWidth * clusterScale;
          final double scaledHeight = baseHeight * clusterScale;
          final double paddedWidth = scaledWidth + clusterPadding * 2;
          final double paddedHeight = scaledHeight + clusterPadding * 2;
          return _ClusterLayoutEntry(
            cluster: cluster,
            bounds: bounds,
            scale: clusterScale,
            scaledWidth: scaledWidth,
            scaledHeight: scaledHeight,
            paddedWidth: paddedWidth,
            paddedHeight: paddedHeight,
          );
        })
        .toList(growable: false);

    if (entries.length == 1) {
      final _ClusterLayoutEntry entry = entries.first;
      final double logicalWidth = entry.paddedWidth + outerPadding * 2;
      final double logicalHeight = entry.paddedHeight + outerPadding * 2;
      final double longestSide = math.max(logicalWidth, logicalHeight);
      final double scale = longestSide > maxDimension && maxDimension > 0
          ? maxDimension / longestSide
          : 1.0;

      final double scaledWidth = logicalWidth * scale;
      final double scaledHeight = logicalHeight * scale;

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(recorder);
      final Paint backgroundPaint = Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
        backgroundPaint,
      );

      canvas.save();
      canvas.scale(scale);
      canvas.translate(
        outerPadding + clusterPadding,
        outerPadding + clusterPadding,
      );
      canvas.scale(entry.scale);
      canvas.translate(-entry.bounds.left, -entry.bounds.top);

      for (final Stroke stroke in entry.cluster.strokes) {
        _paintStroke(canvas, stroke);
      }

      canvas.restore();

      final ui.Picture picture = recorder.endRecording();
      final ui.Image image = await picture.toImage(
        math.max(1, (scaledWidth * pixelRatio).round()),
        math.max(1, (scaledHeight * pixelRatio).round()),
      );
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        return null;
      }

      return CombinedSnapshot(
        pngBytes: byteData.buffer.asUint8List(),
        logicalBounds: Rect.fromLTWH(0, 0, logicalWidth, logicalHeight),
        logicalSize: Size(logicalWidth, logicalHeight),
        scale: scale,
        pixelRatio: pixelRatio,
      );
    }

    final _LayoutPlan chosenPlan = _computeLayout(
      entries,
      axis: Axis.vertical,
      outerPadding: outerPadding,
      gap: gap,
    );

    final double logicalWidth = chosenPlan.size.width;
    final double logicalHeight = chosenPlan.size.height;
    final double longestSide = math.max(logicalWidth, logicalHeight);
    final double scale = longestSide > maxDimension && maxDimension > 0
        ? maxDimension / longestSide
        : 1.0;

    final double scaledWidth = logicalWidth * scale;
    final double scaledHeight = logicalHeight * scale;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    final Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, scaledWidth, scaledHeight),
      backgroundPaint,
    );

    canvas.save();
    canvas.scale(scale);

    for (final _ClusterPlacement placement in chosenPlan.placements) {
      final Rect bounds = placement.entry.bounds;
      final Offset offset = placement.offset;
      canvas.save();
      canvas.translate(offset.dx + clusterPadding, offset.dy + clusterPadding);
      canvas.scale(placement.entry.scale);
      canvas.translate(-bounds.left, -bounds.top);
      for (final Stroke stroke in placement.entry.cluster.strokes) {
        _paintStroke(canvas, stroke);
      }
      canvas.restore();
    }

    canvas.restore();

    final ui.Picture picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(
      math.max(1, (scaledWidth * pixelRatio).round()),
      math.max(1, (scaledHeight * pixelRatio).round()),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    if (byteData == null) {
      return null;
    }

    return CombinedSnapshot(
      pngBytes: byteData.buffer.asUint8List(),
      logicalBounds: Rect.fromLTWH(0, 0, logicalWidth, logicalHeight),
      logicalSize: Size(logicalWidth, logicalHeight),
      scale: scale,
      pixelRatio: pixelRatio,
    );
  }

  _LayoutPlan _computeLayout(
    List<_ClusterLayoutEntry> entries, {
    required Axis axis,
    required double outerPadding,
    required double gap,
  }) {
    if (entries.isEmpty) {
      return const _LayoutPlan(
        size: Size.zero,
        placements: <_ClusterPlacement>[],
      );
    }

    final List<_ClusterLayoutEntry> orderedEntries =
        List<_ClusterLayoutEntry>.from(entries);
    final List<_ClusterPlacement> placements = <_ClusterPlacement>[];

    if (axis == Axis.vertical) {
      orderedEntries.sort((a, b) => a.bounds.top.compareTo(b.bounds.top));

      final double contentWidth = orderedEntries.fold<double>(
        0,
        (value, entry) => math.max(value, entry.paddedWidth),
      );
      final double contentHeight =
          orderedEntries.fold<double>(
            0,
            (value, entry) => value + entry.paddedHeight,
          ) +
          (orderedEntries.length > 1 ? gap * (orderedEntries.length - 1) : 0);

      final double totalWidth = contentWidth + outerPadding * 2;
      final double totalHeight = contentHeight + outerPadding * 2;

      double cursor = outerPadding;
      for (int i = 0; i < orderedEntries.length; i++) {
        final _ClusterLayoutEntry entry = orderedEntries[i];
        final double offsetX =
            outerPadding + (contentWidth - entry.paddedWidth) * 0.5;
        placements.add(
          _ClusterPlacement(entry: entry, offset: Offset(offsetX, cursor)),
        );
        cursor += entry.paddedHeight;
        if (i < orderedEntries.length - 1) {
          cursor += gap;
        }
      }

      return _LayoutPlan(
        size: Size(totalWidth, totalHeight),
        placements: placements,
      );
    }

    orderedEntries.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));

    final double contentHeight = orderedEntries.fold<double>(
      0,
      (value, entry) => math.max(value, entry.paddedHeight),
    );
    final double contentWidth =
        orderedEntries.fold<double>(
          0,
          (value, entry) => value + entry.paddedWidth,
        ) +
        (orderedEntries.length > 1 ? gap * (orderedEntries.length - 1) : 0);

    final double totalWidth = contentWidth + outerPadding * 2;
    final double totalHeight = contentHeight + outerPadding * 2;

    double cursor = outerPadding;
    for (int i = 0; i < orderedEntries.length; i++) {
      final _ClusterLayoutEntry entry = orderedEntries[i];
      final double offsetY =
          outerPadding + (contentHeight - entry.paddedHeight) * 0.5;
      placements.add(
        _ClusterPlacement(entry: entry, offset: Offset(cursor, offsetY)),
      );
      cursor += entry.paddedWidth;
      if (i < orderedEntries.length - 1) {
        cursor += gap;
      }
    }

    return _LayoutPlan(
      size: Size(totalWidth, totalHeight),
      placements: placements,
    );
  }

  Rect _axisAlignedBounds(RotatedBoundingBox box) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = -double.infinity;
    double maxY = -double.infinity;

    for (final Offset corner in box.corners) {
      if (corner.dx < minX) minX = corner.dx;
      if (corner.dx > maxX) maxX = corner.dx;
      if (corner.dy < minY) minY = corner.dy;
      if (corner.dy > maxY) maxY = corner.dy;
    }

    if (!minX.isFinite || !minY.isFinite || !maxX.isFinite || !maxY.isFinite) {
      return Rect.zero;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  void _paintStroke(Canvas canvas, Stroke stroke) {
    final List<DrawingPoint> points = stroke.points;
    if (points.length < 2) {
      return;
    }
    final paint = Paint()
      ..color = stroke.isHighlighter
          ? stroke.color.withValues(alpha: stroke.color.a * 0.5)
          : stroke.color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final Offset start = points[i].position;
      final Offset end = points[i + 1].position;
      final double pressureA = points[i].pressure;
      final double pressureB = points[i + 1].pressure;
      final double width = stroke.baseWidth * (pressureA + pressureB) * 0.5;
      paint.strokeWidth = width;
      canvas.drawLine(start, end, paint);
    }
  }
}

class _ClusterLayoutEntry {
  const _ClusterLayoutEntry({
    required this.cluster,
    required this.bounds,
    required this.scale,
    required this.scaledWidth,
    required this.scaledHeight,
    required this.paddedWidth,
    required this.paddedHeight,
  });

  final StrokeBoundingBoxCluster cluster;
  final Rect bounds;
  final double scale;
  final double scaledWidth;
  final double scaledHeight;
  final double paddedWidth;
  final double paddedHeight;
}

class _ClusterPlacement {
  const _ClusterPlacement({required this.entry, required this.offset});

  final _ClusterLayoutEntry entry;
  final Offset offset;
}

class _LayoutPlan {
  const _LayoutPlan({required this.size, required this.placements});

  final Size size;
  final List<_ClusterPlacement> placements;
}
