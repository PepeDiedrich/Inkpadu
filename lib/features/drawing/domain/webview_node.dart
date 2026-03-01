import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

/// Represents a Web-based node (e.g. an AI generated graph) placed on the canvas.
class WebViewNode {
  /// Unique ID of the node.
  final String id;

  /// Bounding box of the node on the canvas.
  final Rect rect;

  /// HTML/JS content of the node.
  final String htmlContent;

  /// Background color of the node's container.
  final Color backgroundColor;

  /// Creates a [WebViewNode].
  WebViewNode({
    required this.rect,
    required this.htmlContent,
    this.backgroundColor = Colors.transparent,
    String? id,
  }) : id = id ?? const Uuid().v4();

  /// Returns a copy of the node with optionally modified values.
  WebViewNode copyWith({
    Rect? rect,
    String? htmlContent,
    Color? backgroundColor,
    String? id,
  }) => WebViewNode(
    id: id ?? this.id,
    rect: rect ?? this.rect,
    htmlContent: htmlContent ?? this.htmlContent,
    backgroundColor: backgroundColor ?? this.backgroundColor,
  );

  /// Converts the node to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'rect_left': rect.left,
    'rect_top': rect.top,
    'rect_right': rect.right,
    'rect_bottom': rect.bottom,
    'htmlContent': htmlContent,
    'backgroundColor': backgroundColor.toARGB32(),
  };

  /// Creates a node from a JSON map.
  factory WebViewNode.fromJson(Map<String, dynamic> json) => WebViewNode(
      id: json['id'] as String?,
      rect: Rect.fromLTRB(
        (json['rect_left'] as num?)?.toDouble() ?? 0,
        (json['rect_top'] as num?)?.toDouble() ?? 0,
        (json['rect_right'] as num?)?.toDouble() ?? 100,
        (json['rect_bottom'] as num?)?.toDouble() ?? 100,
      ),
      htmlContent: json['htmlContent'] as String? ?? '',
      backgroundColor: Color(
        (json['backgroundColor'] as int?) ?? Colors.transparent.toARGB32(),
      ),
    );
}
