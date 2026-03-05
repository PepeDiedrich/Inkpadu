// ignore_for_file: public_member_api_docs

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

Future<ui.Image> scaleImageIfNeeded(
  ui.Image imageToEncode, {
  double maxDimension = 1024.0,
}) async {
  if (imageToEncode.width > maxDimension ||
      imageToEncode.height > maxDimension) {
    final double scale = imageToEncode.width > imageToEncode.height
        ? maxDimension / imageToEncode.width
        : maxDimension / imageToEncode.height;
    final int targetWidth = (imageToEncode.width * scale).toInt();
    final int targetHeight = (imageToEncode.height * scale).toInt();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale, scale);
    canvas.drawImage(
      imageToEncode,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.medium,
    );
    return recorder.endRecording().toImage(targetWidth, targetHeight);
  }
  return imageToEncode;
}
