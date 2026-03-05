// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

Color parseAiBoxColor(dynamic rawColor) {
  final String input = rawColor?.toString().trim() ?? '';
  if (input.isEmpty) return Colors.red;

  final String normalized = input.toLowerCase().replaceAll('"', '');
  String hex = normalized.replaceAll('#', '');
  if (hex.startsWith('0x')) hex = hex.substring(2);

  if (hex.length == 3) hex = hex.split('').map((char) => '$char$char').join();

  if (hex.length == 6) {
    final int? rgb = int.tryParse(hex, radix: 16);
    if (rgb != null) {
      final Color color = Color(0xFF000000 | rgb);
      return color.toARGB32() == Colors.white.toARGB32() ? Colors.black : color;
    }
  }

  if (hex.length == 8) {
    final int? argb = int.tryParse(hex, radix: 16);
    if (argb != null) {
      final Color color = Color(argb);
      return color.toARGB32() == Colors.white.toARGB32() ? Colors.black : color;
    }
  }

  switch (normalized) {
    case 'green':
      return Colors.green;
    case 'blue':
      return Colors.blue;
    case 'yellow':
      return Colors.yellow;
    case 'orange':
      return Colors.orange;
    case 'purple':
      return Colors.purple;
    case 'pink':
      return Colors.pink;
    case 'cyan':
      return Colors.cyan;
    case 'magenta':
      return const Color(0xFFFF00FF);
    case 'black':
    case 'white':
      return Colors.black;
    default:
      return Colors.red;
  }
}
