import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class TFLiteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/model.tflite');

      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      print('✅ TFLite loaded! Labels: $_labels');
      _isLoaded = true;
    } catch (e) {
      print('❌ TFLite load error: $e');
    }
  }

  // Takes pose landmarks → returns sign + confidence
  Map<String, dynamic> classifyFromPose(List<Pose> poses) {
    if (_interpreter == null || !_isLoaded) {
      return {'sign': '', 'confidence': 0.0};
    }
    if (poses.isEmpty) return {'sign': '', 'confidence': 0.0};

    try {
      final pose = poses.first;

      // Extract 21 key landmarks as x,y,z = 63 values
      // Using wrist + finger landmarks from pose detection
      final landmarkTypes = [
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.rightElbow,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.rightShoulder,
        PoseLandmarkType.leftHip,
        PoseLandmarkType.rightHip,
        PoseLandmarkType.leftKnee,
        PoseLandmarkType.rightKnee,
        PoseLandmarkType.leftAnkle,
        PoseLandmarkType.rightAnkle,
        PoseLandmarkType.leftPinky,
        PoseLandmarkType.rightPinky,
        PoseLandmarkType.leftIndex,
        PoseLandmarkType.rightIndex,
        PoseLandmarkType.leftThumb,
        PoseLandmarkType.rightThumb,
        PoseLandmarkType.nose,
        PoseLandmarkType.leftEye,
        PoseLandmarkType.rightEye,
      ];

      // Build input array of 63 values
      final List<double> input = [];
      for (final type in landmarkTypes) {
        final lm = pose.landmarks[type];
        if (lm != null) {
          input.addAll([lm.x, lm.y, lm.z]);
        } else {
          input.addAll([0.0, 0.0, 0.0]);
        }
      }

      final inputTensor = Float32List.fromList(input).reshape([1, 63]);
      final output = List.filled(
        _labels.length,
        0.0,
      ).reshape([1, _labels.length]);

      _interpreter!.run(inputTensor, output);

      final results = output[0] as List<double>;
      double maxConf = 0;
      int maxIdx = 0;

      for (int i = 0; i < results.length; i++) {
        if (results[i] > maxConf) {
          maxConf = results[i];
          maxIdx = i;
        }
      }

      print('🎯 ${_labels[maxIdx]} (${(maxConf * 100).toStringAsFixed(1)}%)');

      if (maxConf > 0.90 && _labels[maxIdx] != 'background') {
        return {'sign': _labels[maxIdx], 'confidence': maxConf};
      }

      return {'sign': '', 'confidence': 0.0};
    } catch (e) {
      print('❌ Classification error: $e');
      return {'sign': '', 'confidence': 0.0};
    }
  }

  void dispose() {
    _interpreter?.close();
    _isLoaded = false;
  }
}
