import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:ai_handwriting_app/features/drawing/domain/webview_node.dart';

/// Data transfer object für einzelne Seiten einer handschriftlichen Notiz.
class InkNotePageDto {
  /// Erstellt ein neues DTO.
  const InkNotePageDto({
    required this.index,
    required this.strokes,
    this.webViewNodes = const <WebViewNode>[],
  });

  /// Reihenindex der Seite innerhalb der Notiz.
  final int index;

  /// Alle Striche, die auf der Seite gezeichnet wurden.
  final List<Stroke> strokes;

  /// Alle WebView-Knoten der Seite.
  final List<WebViewNode> webViewNodes;

  /// Erstellt ein DTO aus einer Domänen-Seite.
  factory InkNotePageDto.fromDomain(NotePage page, {required int index}) =>
      InkNotePageDto(
        index: index,
        strokes: List<Stroke>.unmodifiable(page.strokes),
        webViewNodes: List<WebViewNode>.unmodifiable(page.webViewNodes),
      );

  /// Wandelt das DTO in die Domänenrepräsentation zurück.
  NotePage toDomain() => NotePage(
    strokes: List<Stroke>.unmodifiable(strokes),
    webViewNodes: List<WebViewNode>.unmodifiable(webViewNodes),
  );

  /// Serialisiert das DTO in eine JSON-Map.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'index': index,
    'strokes': strokes.map((stroke) => stroke.toJson()).toList(growable: false),
    'webNodes': webViewNodes
        .map((node) => node.toJson())
        .toList(growable: false),
  };

  /// Erstellt ein DTO aus einer JSON-Map.
  factory InkNotePageDto.fromJson(Map<String, dynamic> json) {
    final rawIndex = json['index'];
    final effectiveIndex = rawIndex is num ? rawIndex.toInt() : 0;
    final rawStrokes = json['strokes'];
    final List<Stroke> decodedStrokes = rawStrokes is List
        ? rawStrokes
              .whereType<Map<String, dynamic>>()
              .map(Stroke.fromJson)
              .toList(growable: false)
        : const <Stroke>[];

    final rawWebNodes = json['webNodes'];
    final List<WebViewNode> decodedWebNodes = rawWebNodes is List
        ? rawWebNodes
              .whereType<Map<String, dynamic>>()
              .map(WebViewNode.fromJson)
              .toList(growable: false)
        : const <WebViewNode>[];

    return InkNotePageDto(
      index: effectiveIndex,
      strokes: decodedStrokes,
      webViewNodes: decodedWebNodes,
    );
  }
}
