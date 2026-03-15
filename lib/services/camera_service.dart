import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  CameraController? get controller => _controller;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Use front camera (index 1) for gesture detection
      final camera = _cameras.length > 1 ? _cameras[1] : _cameras[0];

      _controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Camera error: $e');
    }
  }

  Future<void> startImageStream(Function(CameraImage) onFrame) async {
    if (_isInitialized && _controller != null) {
      await _controller!.startImageStream(onFrame);
    }
  }

  Future<void> stopImageStream() async {
    if (_isInitialized && _controller != null) {
      await _controller!.stopImageStream();
    }
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    final currentCamera = _controller!.description;
    final newCamera = _cameras.firstWhere(
      (c) => c != currentCamera,
      orElse: () => _cameras[0],
    );
    await _controller!.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _isInitialized = false;
  }
}