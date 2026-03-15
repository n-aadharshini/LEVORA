import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

Future<Uint8List?> convertCameraImage(CameraImage image) async {
  return compute(_convertYUV420, image);
}

Uint8List _convertYUV420(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  final rgbBytes = Uint8List(width * height * 3);
  int rgbIndex = 0;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int uvIndex =
          uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();

      final int yValue =
          image.planes[0].bytes[y * image.planes[0].bytesPerRow + x];
      final int uValue = image.planes[1].bytes[uvIndex];
      final int vValue = image.planes[2].bytes[uvIndex];

      int r = (yValue + 1.370705 * (vValue - 128)).round().clamp(0, 255);
      int g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
          .round()
          .clamp(0, 255);
      int b = (yValue + 1.732446 * (uValue - 128)).round().clamp(0, 255);

      rgbBytes[rgbIndex++] = r;
      rgbBytes[rgbIndex++] = g;
      rgbBytes[rgbIndex++] = b;
    }
  }
  return rgbBytes;
}
