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
    final thumbMcp = landmarks[2];

    final indexTip = landmarks[8];
    final indexPip = landmarks[6];
    final indexMcp = landmarks[5];

    final middleTip = landmarks[12];
    final middlePip = landmarks[10];

    final ringTip = landmarks[16];
    final ringPip = landmarks[14];

    final pinkyTip = landmarks[20];
    final pinkyPip = landmarks[18];
    final pinkyMcp = landmarks[17];

    final indexUp = indexTip.y < indexPip.y;
    final middleUp = middleTip.y < middlePip.y;
    final ringUp = ringTip.y < ringPip.y;
    final pinkyUp = pinkyTip.y < pinkyPip.y;

    final indexFolded = !indexUp;
    final middleFolded = !middleUp;
    final ringFolded = !ringUp;
    final pinkyFolded = !pinkyUp;

    final raisedCount =
        [indexUp, middleUp, ringUp, pinkyUp].where((v) => v).length;

    double dist(dynamic a, dynamic b) {
      final dx = (a.x as num).toDouble() - (b.x as num).toDouble();
      final dy = (a.y as num).toDouble() - (b.y as num).toDouble();
      return (dx * dx + dy * dy) * 1.0;
    }

    final thumbFarFromPalm =
        dist(thumbTip, indexMcp) > dist(thumbMcp, indexMcp);
    final thumbSeparated = dist(thumbTip, pinkyMcp) > 0.03;

    final thumbsUpLike = indexFolded &&
        middleFolded &&
        ringFolded &&
        pinkyFolded &&
        thumbFarFromPalm;

    final iLoveYouLike =
        indexUp && !middleUp && !ringUp && pinkyUp && thumbSeparated;

    debugPrint(
      'thumbFar:$thumbFarFromPalm thumbSep:$thumbSeparated '
      'index:$indexUp middle:$middleUp ring:$ringUp pinky:$pinkyUp',
    );

    if (iLoveYouLike) {
      return 'i_love_you';
    }

    if (indexUp && middleUp && !ringUp && !pinkyUp) {
      return 'peace';
    }

    if (raisedCount >= 3) {
      return 'open_palm';
    }

    if (thumbsUpLike) {
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
      case 'i_love_you':
        return 'I love you';
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
