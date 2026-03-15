import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class SkeletonOverlay extends StatelessWidget {
  final List<Pose> poses;
  final Size imageSize;
  final Size screenSize;

  const SkeletonOverlay({
    super.key,
    required this.poses,
    required this.imageSize,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: SkeletonPainter(
        poses: poses,
        imageSize: imageSize,
        screenSize: screenSize,
      ),
    );
  }
}

class SkeletonPainter extends CustomPainter {
  final List<Pose> poses;
  final Size imageSize;
  final Size screenSize;

  SkeletonPainter({
    required this.poses,
    required this.imageSize,
    required this.screenSize,
  });

  final Paint _jointPaint = Paint()
    ..color = Colors.tealAccent
    ..strokeWidth = 8
    ..style = PaintingStyle.fill;

  final Paint _bonePaint = Paint()
    ..color = Colors.white.withOpacity(0.8)
    ..strokeWidth = 3
    ..style = PaintingStyle.stroke;

  // Connections between landmarks
  final List<List<PoseLandmarkType>> _connections = [
    // Arms
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    // Shoulders
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    // Hips
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    // Torso
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    // Hands
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftThumb],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftIndex],
    [PoseLandmarkType.leftWrist, PoseLandmarkType.leftPinky],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightThumb],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightIndex],
    [PoseLandmarkType.rightWrist, PoseLandmarkType.rightPinky],
  ];

  Offset _translatePoint(PoseLandmark landmark) {
    final double scaleX = screenSize.width / imageSize.width;
    final double scaleY = screenSize.height / imageSize.height;
    final double scale = scaleX > scaleY ? scaleX : scaleY;
    final double dx = (screenSize.width - imageSize.width * scale) / 2;
    final double dy = (screenSize.height - imageSize.height * scale) / 2;
    return Offset(landmark.x * scale + dx, landmark.y * scale + dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pose in poses) {
      // Draw bones
      for (final connection in _connections) {
        final a = pose.landmarks[connection[0]];
        final b = pose.landmarks[connection[1]];
        if (a != null && b != null) {
          canvas.drawLine(_translatePoint(a), _translatePoint(b), _bonePaint);
        }
      }

      // Draw joints
      for (final landmark in pose.landmarks.values) {
        canvas.drawCircle(_translatePoint(landmark), 5, _jointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(SkeletonPainter oldDelegate) => true;
}
