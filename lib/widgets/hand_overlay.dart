import 'package:flutter/material.dart';

class HandOverlay extends StatelessWidget {
  final List<Offset> landmarks;
  final Size imageSize;

  const HandOverlay({
    super.key,
    required this.landmarks,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HandPainter(landmarks: landmarks, imageSize: imageSize),
    );
  }
}

class HandPainter extends CustomPainter {
  final List<Offset> landmarks;
  final Size imageSize;

  HandPainter({required this.landmarks, required this.imageSize});

  static const connections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8],
    [0, 9],
    [9, 10],
    [10, 11],
    [11, 12],
    [0, 13],
    [13, 14],
    [14, 15],
    [15, 16],
    [0, 17],
    [17, 18],
    [18, 19],
    [19, 20],
    [5, 9],
    [9, 13],
    [13, 17],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (landmarks.isEmpty) return;

    final dotPaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final scaledLandmarks = landmarks.map((lm) {
      return Offset(lm.dx * scaleX, lm.dy * scaleY);
    }).toList();

    for (final connection in connections) {
      if (connection[0] < scaledLandmarks.length &&
          connection[1] < scaledLandmarks.length) {
        canvas.drawLine(
          scaledLandmarks[connection[0]],
          scaledLandmarks[connection[1]],
          linePaint,
        );
      }
    }

    for (final landmark in scaledLandmarks) {
      canvas.drawCircle(landmark, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(HandPainter oldDelegate) => true;
}
