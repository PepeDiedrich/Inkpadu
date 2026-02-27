import 'dart:typed_data';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/ink/domain/ink_note.dart';
import 'package:ai_handwriting_app/features/ink/domain/note_paper_style.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service zum Exportieren von Notizen als PDF.
class PdfExportService {
  /// Exportiert eine [InkNote] als PDF-Dokument.
  Future<Uint8List> exportNoteToPdf(InkNote note) async {
    final pdf = pw.Document();

    for (final page in note.pages) {
      final boundingBox = _calculateBoundingBox(page);
      
      // Wenn die Seite leer ist, füge eine leere A4-Seite hinzu
      if (boundingBox == Rect.zero) {
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.SizedBox(),
          ),
        );
        continue;
      }

      // Bestimme das Seitenformat (Hoch- oder Querformat)
      final isLandscape = boundingBox.width > boundingBox.height;
      final pageFormat = isLandscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(0), // Kein Rand, wir zeichnen bis zum Rand
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.CustomPaint(
              size: PdfPoint(pageFormat.width, pageFormat.height),
              painter: (canvas, size) {
                _drawPage(canvas, size, page, boundingBox, note.paperStyle);
              },
            ),
          ),
        ),
      );
    }

    return pdf.save();
  }

  Rect _calculateBoundingBox(NotePage page) {
    if (page.strokes.isEmpty) return Rect.zero;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in page.strokes) {
      final bounds = stroke.boundingBox;
      if (bounds.left < minX) minX = bounds.left;
      if (bounds.top < minY) minY = bounds.top;
      if (bounds.right > maxX) maxX = bounds.right;
      if (bounds.bottom > maxY) maxY = bounds.bottom;
    }

    // Füge etwas Padding hinzu
    const padding = 50.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  void _drawPage(
    PdfGraphics canvas,
    PdfPoint size,
    NotePage page,
    Rect boundingBox,
    NotePaperStyle paperStyle,
  ) {
    // Berechne Skalierung, um die Bounding Box in die PDF-Seite einzupassen
    final scaleX = size.x / boundingBox.width;
    final scaleY = size.y / boundingBox.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Zentriere die Zeichnung auf der Seite
    final offsetX = (size.x - boundingBox.width * scale) / 2;
    final offsetY = (size.y - boundingBox.height * scale) / 2;

    canvas.saveContext();
    
    // PDF-Koordinatensystem hat den Ursprung unten links, Flutter oben links.
    // Wir transformieren das Koordinatensystem, damit es wie in Flutter funktioniert.
    canvas.setTransform(Matrix4.identity()
      ..translateByDouble(0.0, size.y, 0.0, 1.0)
      ..scaleByDouble(1.0, -1.0, 1.0, 1.0)
      ..translateByDouble(offsetX, offsetY, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0)
      ..translateByDouble(-boundingBox.left, -boundingBox.top, 0.0, 1.0));

    // 1. Hintergrund zeichnen
    _drawBackground(canvas, boundingBox, paperStyle);

    // 2. Striche zeichnen
    for (final stroke in page.strokes) {
      _drawStroke(canvas, stroke);
    }

    canvas.restoreContext();
  }

  void _drawBackground(PdfGraphics canvas, Rect bounds, NotePaperStyle style) {
    // Helle Standardfarben für PDF
    final lineColor = PdfColor.fromHex('#E0E0E0');
    
    // Fülle den Hintergrund weiß
    canvas.setFillColor(PdfColors.white);
    canvas.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
    canvas.fillPath();

    canvas.setStrokeColor(lineColor);
    canvas.setLineWidth(1.0);

    switch (style) {
      case NotePaperStyle.plain:
        break;
      case NotePaperStyle.lined:
        const double spacing = 48;
        // Finde den ersten Y-Wert, der ein Vielfaches von spacing ist
        final startY = (bounds.top / spacing).ceil() * spacing;
        for (double y = startY; y <= bounds.bottom; y += spacing) {
          canvas.drawLine(bounds.left, y, bounds.right, y);
        }
        canvas.strokePath();
        break;
      case NotePaperStyle.grid:
        const double spacing = 48;
        final startY = (bounds.top / spacing).ceil() * spacing;
        for (double y = startY; y <= bounds.bottom; y += spacing) {
          canvas.drawLine(bounds.left, y, bounds.right, y);
        }
        final startX = (bounds.left / spacing).ceil() * spacing;
        for (double x = startX; x <= bounds.right; x += spacing) {
          canvas.drawLine(x, bounds.top, x, bounds.bottom);
        }
        canvas.strokePath();
        break;
      case NotePaperStyle.dotted:
        canvas.setFillColor(lineColor);
        const double spacing = 36;
        const double radius = 1.4;
        final startY = (bounds.top / spacing).ceil() * spacing;
        final startX = (bounds.left / spacing).ceil() * spacing;
        
        for (double y = startY; y <= bounds.bottom; y += spacing) {
          final double offset = (y ~/ spacing).isEven ? 0 : spacing / 2;
          for (double x = startX - offset; x <= bounds.right; x += spacing) {
            if (x >= bounds.left) {
              canvas.drawEllipse(x, y, radius, radius);
              canvas.fillPath();
            }
          }
        }
        break;
    }
  }

  void _drawStroke(PdfGraphics canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final color = PdfColor(
      stroke.color.r,
      stroke.color.g,
      stroke.color.b,
      stroke.isHighlighter ? stroke.color.a * 0.5 : stroke.color.a,
    );

    canvas.setStrokeColor(color);
    canvas.setLineCap(PdfLineCap.round);
    canvas.setLineJoin(PdfLineJoin.round);

    for (var i = 0; i < stroke.points.length - 1; i++) {
      final p1 = stroke.points[i];
      final p2 = stroke.points[i + 1];
      
      final width = stroke.baseWidth * (p1.pressure + p2.pressure) / 2;
      canvas.setLineWidth(width);
      
      canvas.drawLine(p1.position.dx, p1.position.dy, p2.position.dx, p2.position.dy);
      canvas.strokePath();
    }
  }
}
