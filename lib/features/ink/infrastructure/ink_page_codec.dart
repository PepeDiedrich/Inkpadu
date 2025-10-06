import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_handwriting_app/features/drawing/domain/drawing_point.dart';
import 'package:ai_handwriting_app/features/drawing/domain/note_page.dart';
import 'package:ai_handwriting_app/features/drawing/domain/stroke.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';

/// Codec zum Komprimieren und Dekomprimieren von [NotePage]-Daten.
class InkNotePageCodec {
  const InkNotePageCodec._();

  static const int _version = 1;
  static const int _positionScale = 1000;
  static const int _pressureScale = 1000;
  static final GZipEncoder _gzipEncoder = GZipEncoder();
  static final GZipDecoder _gzipDecoder = GZipDecoder();

  /// Kodiert eine [NotePage] nach Base64 (gzip-komprimiertes JSON).
  static String encode(NotePage page) {
    final payload = <String, dynamic>{
      'v': _version,
      's': page.strokes.map(_encodeStroke).toList(growable: false),
    };

    final jsonString = jsonEncode(payload);
    final compressed = _gzipEncoder.encode(utf8.encode(jsonString));
    if (compressed == null) {
      throw const FormatException('Failed to gzip ink note payload');
    }
    return base64Encode(compressed);
  }

  /// Dekodiert eine komprimierte Repräsentation in eine [NotePage].
  static NotePage decode(String data) {
    if (data.isEmpty) {
      return NotePage(strokes: <Stroke>[]);
    }

    try {
      final compressed = base64Decode(data);
      final decompressed = _gzipDecoder.decodeBytes(compressed);
      final jsonPayload = utf8.decode(decompressed);
      final decoded = jsonDecode(jsonPayload) as Map<String, dynamic>;
      final version = decoded['v'] as int? ?? _version;
      if (version != _version) {
        throw const FormatException('Unsupported ink note format version');
      }

      final strokes = (decoded['s'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_decodeStroke)
          .toList(growable: false);
      return NotePage(strokes: strokes);
    } on FormatException {
      // Fallback: Versuch, die ursprüngliche JSON-Struktur zu lesen.
      final legacy = jsonDecode(data);
      if (legacy is Map<String, dynamic>) {
        return NotePage.fromJson(legacy);
      }
      rethrow;
    } on Exception {
      final legacy = jsonDecode(data);
      if (legacy is Map<String, dynamic>) {
        return NotePage.fromJson(legacy);
      }
      rethrow;
    }
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
