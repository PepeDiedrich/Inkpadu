import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_handwriting_app/features/drawing/domain/assistant_message.dart';
import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';

/// Bündelt dekodierte Seitendaten und Zusatzinformationen.
class InkNotePageBundle {
  /// Erstellt ein neues Bundle aus [pages] mit dem zuletzt geöffneten Index
  /// [lastOpenedPageIndex].
  const InkNotePageBundle({
    required this.pages,
    required this.lastOpenedPageIndex,
  });

  /// Alle Seiten der Notiz.
  final List<NotePage> pages;

  /// Index der Seite, die zuletzt geöffnet war.
  final int lastOpenedPageIndex;
}

/// Codec zum Komprimieren und Dekomprimieren von [NotePage]-Sammlungen.
///
/// Verantwortlich für eine platzsparende Serialisierung (JSON + gzip + Base64)
/// inklusive Metadaten wie dem zuletzt geöffneten Seitenindex. Versioniert
/// mittels interner `v`-Kennzahl, unterstützt Fallbacks für Legacy-Formate
/// und gibt unveränderliche Listen zurück.
class InkNotePageCodec {
  const InkNotePageCodec._();

  static const int _version = 3;
  static const int _positionScale = 1000;
  static const int _pressureScale = 1000;
  static final GZipEncoder _gzipEncoder = GZipEncoder();
  static final GZipDecoder _gzipDecoder = GZipDecoder();

  /// Kodiert eine Liste von Seiten nach Base64 (gzip-komprimiertes JSON).
  static String encode(
    List<NotePage> pages, {
    int lastOpenedPageIndex = 0,
  }) {
    final List<NotePage> normalizedPages =
        pages.isEmpty ? <NotePage>[NotePage(strokes: const <Stroke>[])] : pages;
    final int clampedIndex = normalizedPages.isEmpty
        ? 0
        : lastOpenedPageIndex.clamp(0, normalizedPages.length - 1);

    final payload = <String, dynamic>{
      'v': _version,
      'p': normalizedPages.map(_encodePage).toList(growable: false),
      'meta': <String, dynamic>{'lastPage': clampedIndex},
    };

    final jsonString = jsonEncode(payload);
    final compressed = _gzipEncoder.encode(utf8.encode(jsonString));
    if (compressed == null) {
      throw const FormatException('Failed to gzip ink note payload');
    }
    return base64Encode(compressed);
  }

  /// Kodiert eine einzelne Seite. Nutzt intern [encode], liefert aber exakt
  /// die Darstellung einer Einzelseite, sodass bestehende Kompression und
  /// Versionierung weiter verwendet werden können.
  static String encodeSingle(NotePage page) => encode(<NotePage>[page]);

  /// Dekodiert eine einzelne Seite aus der durch [encodeSingle] erzeugten
  /// Repräsentation. Fällt auf eine leere Seite zurück, falls das Payload leer
  /// oder ungültig ist.
  static NotePage decodeSingle(String data) {
    final InkNotePageBundle bundle = decode(data);
    if (bundle.pages.isEmpty) {
      return NotePage(strokes: const <Stroke>[]);
    }
    return bundle.pages.first;
  }

  /// Dekodiert eine komprimierte Repräsentation in mehrere Seiten.
  static InkNotePageBundle decode(String data) {
    if (data.isEmpty) {
      return InkNotePageBundle(
        pages: List<NotePage>.unmodifiable(
          <NotePage>[NotePage(strokes: const <Stroke>[])],
        ),
        lastOpenedPageIndex: 0,
      );
    }

    try {
      final compressed = base64Decode(data);
      final decompressed = _gzipDecoder.decodeBytes(compressed);
      final jsonPayload = utf8.decode(decompressed);
      final decoded = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final version = decoded['v'] as int? ?? 1;

      if (version <= 1) {
        final strokes = (decoded['s'] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .map(_decodeStroke)
            .toList(growable: false);
        return InkNotePageBundle(
          pages: <NotePage>[NotePage(strokes: strokes)],
          lastOpenedPageIndex: 0,
        );
      }

    final List<NotePage> pages =
      (decoded['p'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((pageData) => _decodePage(pageData, version: version))
        .toList(growable: false);
      final meta = decoded['meta'];
      final lastPageRaw =
          meta is Map<String, dynamic> ? meta['lastPage'] : null;
      final int normalizedIndex = _parsePageIndex(
        lastPageRaw,
        pages.isEmpty ? 0 : pages.length - 1,
      );

    final List<NotePage> ensuredPages = pages.isEmpty
      ? <NotePage>[NotePage(strokes: const <Stroke>[])]
      : pages;
    final List<NotePage> immutablePages =
      List<NotePage>.unmodifiable(ensuredPages);
      final int clampedIndex = ensuredPages.isEmpty
          ? 0
          : normalizedIndex.clamp(0, ensuredPages.length - 1);

      return InkNotePageBundle(
        pages: immutablePages,
        lastOpenedPageIndex: clampedIndex,
      );
    } on FormatException {
      // Fallback: Versuch, die ursprüngliche JSON-Struktur zu lesen.
      final legacy = jsonDecode(data);
      if (legacy is Map<String, dynamic>) {
        return InkNotePageBundle(
          pages: List<NotePage>.unmodifiable(
            <NotePage>[NotePage.fromJson(legacy)],
          ),
          lastOpenedPageIndex: 0,
        );
      }
      rethrow;
    } on Exception {
      final legacy = jsonDecode(data);
      if (legacy is Map<String, dynamic>) {
        return InkNotePageBundle(
          pages: List<NotePage>.unmodifiable(
            <NotePage>[NotePage.fromJson(legacy)],
          ),
          lastOpenedPageIndex: 0,
        );
      }
      rethrow;
    }
  }

  static Map<String, dynamic> _encodePage(NotePage page) {
    final List<Map<String, dynamic>> encodedStrokes =
        page.strokes.map(_encodeStroke).toList(growable: false);

    final Map<String, dynamic>? context = _encodeContext(page);

    return <String, dynamic>{
      's': encodedStrokes,
      if (context != null) 'ctx': context,
    };
  }

  static Map<String, dynamic>? _encodeContext(NotePage page) {
    final bool hasDescription =
        (page.cachedVisionDescription?.trim().isNotEmpty ?? false);
    final bool hasHistory = page.assistantHistory.isNotEmpty;

    if (!hasDescription && !hasHistory) {
      return null;
    }

    return <String, dynamic>{
      if (hasDescription) 'vision': page.cachedVisionDescription,
      if (hasHistory)
        'history': page.assistantHistory
            .map((message) => message.toJson())
            .toList(growable: false),
    };
  }

  static NotePage _decodePage(Map<String, dynamic> data, {required int version}) {
    final strokes = (data['s'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(_decodeStroke)
        .toList(growable: false);

    if (version <= 2) {
      return NotePage(strokes: strokes);
    }

    final Object? rawContext = data['ctx'];
    if (rawContext is! Map<String, dynamic>) {
      return NotePage(strokes: strokes);
    }

    final List<AssistantMessage> history = _decodeHistory(rawContext['history']);
    final String? description = _decodeVisionDescription(rawContext['vision']);

    return NotePage(
      strokes: strokes,
      assistantHistory: history,
      cachedVisionDescription: description,
    );
  }

  static List<AssistantMessage> _decodeHistory(Object? rawHistory) {
    if (rawHistory is! List) {
      return const <AssistantMessage>[];
    }

    return rawHistory
        .whereType<Map<String, dynamic>>()
        .map(AssistantMessage.fromJson)
        .toList(growable: false);
  }

  static String? _decodeVisionDescription(Object? rawDescription) {
    if (rawDescription is String) {
      final String trimmed = rawDescription.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return null;
  }

  static Map<String, dynamic> _encodeStroke(Stroke stroke) {
    final pointsBytes = _encodePoints(stroke.points);
    return <String, dynamic>{
      'id': stroke.id,
      'color': stroke.color.toARGB32(),
      'width': stroke.baseWidth,
      'isHighlighter': stroke.isHighlighter,
      'points': base64Encode(pointsBytes),
    };
  }

  static Stroke _decodeStroke(Map<String, dynamic> data) {
    final colorValue = data['color'] as int?;
    final widthValue = (data['width'] as num?)?.toDouble() ?? 4.0;
    final isHighlighter = data['isHighlighter'] as bool? ?? false;
    final pointsEncoded = data['points'] as String? ?? '';

    final color = colorValue != null
        ? Color(colorValue)
        : const Color(0xFF000000);
    final points = _decodePoints(pointsEncoded);

    return Stroke(
      id: data['id'] as String?,
      points: points,
      color: color,
      baseWidth: widthValue,
      isHighlighter: isHighlighter,
    );
  }

  static Uint8List _encodePoints(List<DrawingPoint> points) {
    if (points.isEmpty) {
      return Uint8List(0);
    }

    final builder = BytesBuilder(copy: false);

    int lastX = 0;
    int lastY = 0;
    int lastPressure = 0;

    for (var index = 0; index < points.length; index++) {
      final point = points[index];
      final scaledX = (point.position.dx * _positionScale).round();
      final scaledY = (point.position.dy * _positionScale).round();
      final scaledPressure = (point.pressure * _pressureScale).round();

      if (index == 0) {
        lastX = scaledX;
        lastY = scaledY;
        lastPressure = scaledPressure;

        _writeVarint(builder, _encodeZigZag(scaledX));
        _writeVarint(builder, _encodeZigZag(scaledY));
        _writeVarint(builder, _encodeZigZag(scaledPressure));
        continue;
      }

      final deltaX = scaledX - lastX;
      final deltaY = scaledY - lastY;
      final deltaPressure = scaledPressure - lastPressure;

      lastX = scaledX;
      lastY = scaledY;
      lastPressure = scaledPressure;

      _writeVarint(builder, _encodeZigZag(deltaX));
      _writeVarint(builder, _encodeZigZag(deltaY));
      _writeVarint(builder, _encodeZigZag(deltaPressure));
    }

    return builder.toBytes();
  }

  static List<DrawingPoint> _decodePoints(String data) {
    if (data.isEmpty) {
      return List<DrawingPoint>.unmodifiable(<DrawingPoint>[]);
    }

    final bytes = base64Decode(data);
    if (bytes.isEmpty) {
      return List<DrawingPoint>.unmodifiable(<DrawingPoint>[]);
    }

    final reader = _VarintReader(bytes);
    final result = <DrawingPoint>[];

    var isFirst = true;
    var currentX = 0;
    var currentY = 0;
    var currentPressure = 0;

    while (!reader.isDone) {
      final rawX = _decodeZigZag(reader.read());
      final rawY = _decodeZigZag(reader.read());
      final rawPressure = _decodeZigZag(reader.read());

      if (isFirst) {
        currentX = rawX;
        currentY = rawY;
        currentPressure = rawPressure;
        isFirst = false;
      } else {
        currentX += rawX;
        currentY += rawY;
        currentPressure += rawPressure;
      }

      final position = Offset(
        currentX / _positionScale,
        currentY / _positionScale,
      );
      final pressure = (currentPressure / _pressureScale)
          .clamp(0.0, 1.0)
          .toDouble();

      result.add(DrawingPoint(position: position, pressure: pressure));
    }

    return List<DrawingPoint>.unmodifiable(result);
  }

  static void _writeVarint(BytesBuilder builder, int value) {
    var residual = value;
    while (residual >= 0x80) {
      builder.addByte((residual & 0x7F) | 0x80);
      residual >>= 7;
    }
    builder.addByte(residual & 0x7F);
  }

  static int _encodeZigZag(int value) => (value << 1) ^ (value >> 63);

  static int _decodeZigZag(int value) => (value >> 1) ^ -(value & 1);

  static int _parsePageIndex(Object? rawValue, int maxIndex) {
    if (rawValue is int) {
      return rawValue;
    }
    if (rawValue is num) {
      return rawValue.toInt();
    }
    if (rawValue is String) {
      final parsed = int.tryParse(rawValue);
      if (parsed != null) {
        return parsed;
      }
    }
    return maxIndex;
  }
}

class _VarintReader {
  _VarintReader(this._bytes);

  final Uint8List _bytes;
  int _index = 0;

  bool get isDone => _index >= _bytes.length;

  int read() {
    var shift = 0;
    var value = 0;

    while (true) {
      if (_index >= _bytes.length) {
        throw const FormatException('Unexpected end of varint input');
      }

      final byte = _bytes[_index++];
      value |= (byte & 0x7F) << shift;

      if ((byte & 0x80) == 0) {
        return value;
      }

      shift += 7;
      if (shift > 63) {
        throw const FormatException('Varint too long');
      }
    }
  }
}
