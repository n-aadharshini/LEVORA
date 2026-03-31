import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hand_landmarker/hand_landmarker.dart';

class GestureService {
  HandLandmarkerPlugin? _plugin;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  Future<void> loadModel() async {
    _plugin = HandLandmarkerPlugin.create(
      numHands: 1,
      minHandDetectionConfidence: 0.6,
      delegate: HandLandmarkerDelegate.gpu,
    );
    _isLoaded = true;
  }

  Future<String?> detectGestureFromFrame(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (!_isLoaded || _plugin == null) return null;

    final hands = await _plugin!.detect(
      image,
      camera.sensorOrientation,
    );

    debugPrint('Hands detected count: ${hands.length}');

    if (hands.isEmpty) return null;

    return _classifyGesture(hands.first);
  }

  String? _classifyGesture(dynamic hand) {
    final landmarks = hand.landmarks;
    if (landmarks == null || landmarks.length < 21) return null;

    final wrist = landmarks[0];

    final thumbTip = landmarks[4];
    final thumbIp = landmarks[3];

    final indexTip = landmarks[8];
    final indexPip = landmarks[6];

    final middleTip = landmarks[12];
    final middlePip = landmarks[10];

    final ringTip = landmarks[16];
    final ringPip = landmarks[14];

    final pinkyTip = landmarks[20];
    final pinkyPip = landmarks[18];

    final indexUp = indexTip.y < indexPip.y;
    final middleUp = middleTip.y < middlePip.y;
    final ringUp = ringTip.y < ringPip.y;
    final pinkyUp = pinkyTip.y < pinkyPip.y;

    final raisedCount = [
      indexUp,
      middleUp,
      ringUp,
      pinkyUp,
    ].where((v) => v).length;

    // Selfie camera thumbs-up:
    // thumb is above wrist and all other fingers are folded
    final thumbClearlyUp =
        thumbTip.y < thumbIp.y && thumbTip.y < wrist.y && raisedCount == 0;

    debugPrint(
      'index:$indexUp middle:$middleUp ring:$ringUp pinky:$pinkyUp raised:$raisedCount thumbUp:$thumbClearlyUp',
    );

    // Peace sign
    if (indexUp && middleUp && !ringUp && !pinkyUp) {
      return 'peace';
    }

    // Open palm
    if (raisedCount >= 3) {
      return 'open_palm';
    }

    // Thumbs up
    if (thumbClearlyUp) {
      return 'thumbs_up';
    }

    return null;
  }

  String? mapGestureToText(String gestureName) {
    switch (gestureName) {
      case 'thumbs_up':
        return 'Yes';
      case 'open_palm':
        return 'Stop';
      case 'peace':
        return 'Wait';
      default:
        return null;
    }
  }

  void dispose() {
    _plugin?.dispose();
    _plugin = null;
    _isLoaded = false;
  }
}
