import 'package:inkpadu/features/drawing/domain/stroke.dart';
import 'package:inkpadu/features/drawing/domain/webview_node.dart';

/// Repräsentiert eine einzelne Notizenseite, die eine Sammlung von Strichen enthält.
class NotePage {
  /// Erstellt eine neue Notizenseite.
  NotePage({required this.strokes, this.webViewNodes = const <WebViewNode>[]});

  /// Die Liste aller Striche auf dieser Seite.
  final List<Stroke> strokes;

  /// Die Liste aller WebView-Knoten auf dieser Seite.
  final List<WebViewNode> webViewNodes;

  /// Erstellt eine Kopie der Seite mit optional geänderten Werten.
  NotePage copyWith({List<Stroke>? strokes, List<WebViewNode>? webViewNodes}) =>
      NotePage(
        strokes: strokes ?? this.strokes,
        webViewNodes: webViewNodes ?? this.webViewNodes,
      );

  /// Wandelt das Objekt in eine JSON-Map um.
  Map<String, dynamic> toJson() => {
    'strokes': strokes.map((s) => s.toJson()).toList(),
    'web_views': webViewNodes.map((n) => n.toJson()).toList(),
  };

  /// Erstellt ein [NotePage]-Objekt aus einer JSON-Map.
  factory NotePage.fromJson(Map<String, dynamic> json) {
    final Object? rawStrokes = json['strokes'];
    final List<Stroke> decodedStrokes = rawStrokes is List
        ? rawStrokes
              .whereType<Map<String, dynamic>>()
              .map(Stroke.fromJson)
              .toList(growable: false)
        : const <Stroke>[];

    final Object? rawWebViews = json['web_views'];
    final List<WebViewNode> decodedWebViews = rawWebViews is List
        ? rawWebViews
              .whereType<Map<String, dynamic>>()
              .map(WebViewNode.fromJson)
              .toList(growable: false)
        : const <WebViewNode>[];

    return NotePage(strokes: decodedStrokes, webViewNodes: decodedWebViews);
  }
}
