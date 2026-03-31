import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isStreamingImages = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isStreamingImages => _isStreamingImages;

  Future<void> initialize() async {
    _cameras = await availableCameras();

    if (_cameras.isEmpty) {
      throw Exception('No cameras found on device');
    }

    final frontCameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _selectedCameraIndex = frontCameraIndex >= 0 ? frontCameraIndex : 0;
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> _setupCamera(CameraDescription camera) async {
    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();
  }

  Future<void> switchCamera() async {
    if (_cameras.isEmpty || _cameras.length < 2) return;

    final wasStreaming = _isStreamingImages;

    if (wasStreaming) {
      await stopImageStream();
    }

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _setupCamera(_cameras[_selectedCameraIndex]);
  }

  Future<void> startImageStream(Function(CameraImage image) onFrame) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isStreamingImages) return;

    await _controller!.startImageStream((CameraImage image) {
      onFrame(image);
    });

    _isStreamingImages = true;
  }

  Future<void> stopImageStream() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (!_controller!.value.isStreamingImages) return;

    await _controller!.stopImageStream();
    _isStreamingImages = false;
  }

  Future<void> dispose() async {
    if (_controller != null) {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller!.dispose();
      _controller = null;
    }
    _isStreamingImages = false;
  }
}
