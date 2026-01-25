import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Service zum Exportieren von [InkNote] als PDF-Dokument.
class PdfExportService {
  /// Exportiert die übergebene [InkNote] als PDF und gibt den Dateipfad zurück.
  ///
  /// Die PDF wird im temporären Verzeichnis des Geräts gespeichert.
  Future<String> exportNoteToPdf(InkNote note) async {
    final pw.Document document = pw.Document(
      title: note.title,
      author: 'Inkpadu',
    );

    for (int i = 0; i < note.pages.length; i++) {
      final NotePage page = note.pages[i];
      document.addPage(_buildPdfPage(page, note.paperStyle, i + 1));
    }

    final Uint8List pdfBytes = await document.save();

    final String fileName = _sanitizeFileName(note.title);
    final String filePath = await _savePdfToFile(pdfBytes, fileName);
    return filePath;
  }

  /// Exportiert die Notiz und öffnet das native Teilen-Menü.
  Future<ShareResult> exportAndShare(
    InkNote note, {
    Rect? sharePositionOrigin,
  }) async {
    final String filePath = await exportNoteToPdf(note);

    final ShareResult result = await Share.shareXFiles(
      <XFile>[XFile(filePath, mimeType: 'application/pdf')],
      subject: note.title,
      sharePositionOrigin: sharePositionOrigin,
    );
    return result;
  }

  pw.Page _buildPdfPage(NotePage page, NotePaperStyle paperStyle, int _) {
    // Berechne die Grenzen der Striche
    final _PageBounds bounds = _calculatePageBounds(page.strokes);

    // Verwende A4-Seitengröße
    final double pdfWidth = PdfPageFormat.a4.width;
    final double pdfHeight = PdfPageFormat.a4.height;
    const double margin = 20;
    final double availableWidth = pdfWidth - 2 * margin;
    final double availableHeight = pdfHeight - 2 * margin;

    // Berechne Skalierungsfaktor, um die Zeichnung in die PDF einzupassen
    double scale = 1.0;
    double offsetX = 0;
    double offsetY = 0;

    if (bounds.width > 0 && bounds.height > 0) {
      final double scaleX = availableWidth / bounds.width;
      final double scaleY = availableHeight / bounds.height;
      scale = math.min(scaleX, scaleY).clamp(0.1, 1.0);

      // Zentriere die Zeichnung, aber berücksichtige auch den ursprünglichen Offset
      offsetX = margin - bounds.minX * scale;
      offsetY = margin - bounds.minY * scale;
    }

    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (pw.Context context) => pw.Stack(
        children: <pw.Widget>[
          // Papierhintergrund
          _buildPaperBackground(paperStyle, pdfWidth, pdfHeight),
          // Zeichnung
          pw.CustomPaint(
            size: PdfPoint(pdfWidth, pdfHeight),
            painter: (PdfGraphics canvas, PdfPoint size) {
              _paintStrokes(
                canvas,
                page.strokes,
                scale,
                offsetX,
                offsetY,
                pdfHeight,
              );
            },
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPaperBackground(
    NotePaperStyle style,
    double width,
    double height,
  ) {
    final PdfColor bgColor = _paperBackgroundColor(style);
    return pw.Container(
      width: width,
      height: height,
      decoration: pw.BoxDecoration(color: bgColor),
      child: pw.CustomPaint(
        size: PdfPoint(width, height),
        painter: (PdfGraphics canvas, PdfPoint size) {
          _paintPaperPattern(canvas, style, size.x, size.y);
        },
      ),
    );
  }

  PdfColor _paperBackgroundColor(NotePaperStyle style) {
    switch (style) {
      case NotePaperStyle.plain:
        return PdfColors.white;
      case NotePaperStyle.lined:
        return const PdfColor.fromInt(0xFFFFF8E1);
      case NotePaperStyle.grid:
        return PdfColors.white;
      case NotePaperStyle.dotted:
        return PdfColors.white;
    }
  }

  void _paintPaperPattern(
    PdfGraphics canvas,
    NotePaperStyle style,
    double width,
    double height,
  ) {
    const double lineSpacing = 24;
    const double gridSize = 24;
    const double dotRadius = 1;
    final PdfColor lineColor = PdfColor.fromInt(
      Colors.grey.shade300.toARGB32(),
    );

    switch (style) {
      case NotePaperStyle.plain:
        break;
      case NotePaperStyle.lined:
        for (double y = lineSpacing; y < height; y += lineSpacing) {
          canvas
            ..setStrokeColor(lineColor)
            ..setLineWidth(0.5)
            ..drawLine(0, height - y, width, height - y)
            ..strokePath();
        }
      case NotePaperStyle.grid:
        for (double x = gridSize; x < width; x += gridSize) {
          canvas
            ..setStrokeColor(lineColor)
            ..setLineWidth(0.3)
            ..drawLine(x, 0, x, height)
            ..strokePath();
        }
        for (double y = gridSize; y < height; y += gridSize) {
          canvas
            ..setStrokeColor(lineColor)
            ..setLineWidth(0.3)
            ..drawLine(0, height - y, width, height - y)
            ..strokePath();
        }
      case NotePaperStyle.dotted:
        for (double x = gridSize; x < width; x += gridSize) {
          for (double y = gridSize; y < height; y += gridSize) {
            canvas
              ..setFillColor(lineColor)
              ..drawEllipse(x, height - y, dotRadius, dotRadius)
              ..fillPath();
          }
        }
    }
  }

  void _paintStrokes(
    PdfGraphics canvas,
    List<Stroke> strokes,
    double scale,
    double offsetX,
    double offsetY,
    double pdfHeight,
  ) {
    for (final Stroke stroke in strokes) {
      if (stroke.points.isEmpty) {
        continue;
      }

      final PdfColor strokeColor = stroke.isHighlighter
          ? PdfColor.fromInt(
              stroke.color.withValues(alpha: stroke.color.a * 0.5).toARGB32(),
            )
          : PdfColor.fromInt(stroke.color.toARGB32());

      canvas.setStrokeColor(strokeColor);
      canvas.setLineCap(PdfLineCap.round);
      canvas.setLineJoin(PdfLineJoin.round);

      for (int i = 0; i < stroke.points.length - 1; i++) {
        final p1 = stroke.points[i];
        final p2 = stroke.points[i + 1];

        final double avgPressure = (p1.pressure + p2.pressure) / 2;
        final double width = stroke.baseWidth * avgPressure * scale;

        // Transform Flutter coordinates (top-left origin) to PDF (bottom-left origin)
        final double x1 = p1.position.dx * scale + offsetX;
        final double y1 = pdfHeight - (p1.position.dy * scale + offsetY);
        final double x2 = p2.position.dx * scale + offsetX;
        final double y2 = pdfHeight - (p2.position.dy * scale + offsetY);

        canvas
          ..setLineWidth(width.clamp(0.5, 20))
          ..drawLine(x1, y1, x2, y2)
          ..strokePath();
      }
    }
  }

  _PageBounds _calculatePageBounds(List<Stroke> strokes) {
    if (strokes.isEmpty) {
      return _PageBounds(minX: 0, minY: 0, maxX: 595, maxY: 842);
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in strokes) {
      for (final point in stroke.points) {
        if (point.position.dx < minX) minX = point.position.dx;
        if (point.position.dy < minY) minY = point.position.dy;
        if (point.position.dx > maxX) maxX = point.position.dx;
        if (point.position.dy > maxY) maxY = point.position.dy;
      }
    }

    // Füge etwas Padding hinzu
    const double padding = 20;
    return _PageBounds(
      minX: math.max(0, minX - padding),
      minY: math.max(0, minY - padding),
      maxX: maxX + padding,
      maxY: maxY + padding,
    );
  }

  String _sanitizeFileName(String title) {
    // Entferne oder ersetze ungültige Zeichen für Dateinamen
    final String sanitized = title
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();
    if (sanitized.isEmpty) {
      return 'notiz_${DateTime.now().millisecondsSinceEpoch}';
    }
    return sanitized;
  }

  Future<String> _savePdfToFile(Uint8List bytes, String fileName) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String stampedFileName =
        '${fileName}_${DateTime.now().millisecondsSinceEpoch}';
    final String filePath = '${tempDir.path}/$stampedFileName.pdf';
    final File file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }
}

class _PageBounds {
  _PageBounds({
    required this.minX,
    required this.minY,
    required this.maxX,
    required this.maxY,
  });

  final double minX;
  final double minY;
  final double maxX;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;
}
