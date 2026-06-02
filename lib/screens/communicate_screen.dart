import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/camera_service.dart';
import '../services/gesture_service.dart';
import '../services/permission_service.dart';
import '../widgets/camera_preview_widget.dart';

class CommunicateScreen extends StatefulWidget {
  const CommunicateScreen({super.key});

  @override
  State<CommunicateScreen> createState() => _CommunicateScreenState();
}

class _CommunicateScreenState extends State<CommunicateScreen> {
  final GestureService _gestureService = GestureService();
  final CameraService _cameraService = CameraService();
  final PermissionService _permissionService = PermissionService();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _roomController = TextEditingController();

  int _frameSkipCount = 0;
  bool _isProcessingFrame = false;
  bool _inCall = false;
  bool _isMuted = false;
  bool _captionsEnabled = true;
  bool _ttsEnabled = true;
  bool _showLocalAsMain = false;

  String _debugStatus = 'Idle';
  String _currentSubtitle = '';
  String _lastDetectedGesture = '';
  String _lastSpokenText = '';
  String _sentence = '';

  final List<Map<String, String>> _subtitles = [];
  List<String> _suggestions = [];

  final Map<String, List<String>> _suggestionMap = {
    'Yes': ['Yes, I agree', 'Yes, please', 'Yes, thank you'],
    'Wait': ['Please wait', 'Wait a moment', 'Give me some time'],
    'Stop': ['Stop please', 'Please stop', 'Do not continue'],
  };

  final List<Map<String, String>> _languages = [
    {'label': 'English', 'code': 'en-US'},
    {'label': 'Hindi', 'code': 'hi-IN'},
    {'label': 'Tamil', 'code': 'ta-IN'},
  ];

  int _languageIndex = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _initTts();
    await _gestureService.loadModel();
    final granted = await _permissionService.requestCamera(context);
    if (granted) {
      await _cameraService.initialize();
      if (mounted) setState(() {});
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage(_languages[_languageIndex]['code']!);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.awaitSpeakCompletion(true);
  }

  Future<void> _startGestureStream() async {
    setState(() => _debugStatus = 'Stream started');
    await _cameraService.startImageStream((image) async {
      if (mounted) setState(() => _debugStatus = 'Frame callback');
      if (_isProcessingFrame) return;
      _frameSkipCount++;
      if (_frameSkipCount % 3 != 0) return;
      _isProcessingFrame = true;
      try {
        await _handleCameraFrame(image);
      } catch (_) {
        if (mounted) setState(() => _debugStatus = 'Frame error');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> _handleCameraFrame(CameraImage image) async {
    final controller = _cameraService.controller;
    if (controller == null) return;
    final gestureName = await _gestureService.detectGestureFromFrame(
        image, controller.description);
    if (mounted)
      setState(() => _debugStatus = 'Gesture: ${gestureName ?? "none"}');
    if (gestureName == null) return;
    final detectedText = _gestureService.mapGestureToText(gestureName);
    if (detectedText == null) return;
    await _onGestureDetected(detectedText);
  }

  Future<void> _speakSubtitle(String text) async {
    if (!_ttsEnabled || _isMuted || text.isEmpty) return;
    if (_lastSpokenText == text) return;
    _lastSpokenText = text;
    await _flutterTts.stop();
    await _flutterTts.setLanguage(_languages[_languageIndex]['code']!);
    await _flutterTts.speak(text);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _lastSpokenText == text) _lastSpokenText = '';
    });
  }

  Future<void> _speakSentence() async {
    if (_sentence.trim().isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.setLanguage(_languages[_languageIndex]['code']!);
    await _flutterTts.speak(_sentence.trim());
  }

  Future<void> _changeLanguage() async {
    setState(() => _languageIndex = (_languageIndex + 1) % _languages.length);
    await _flutterTts.setLanguage(_languages[_languageIndex]['code']!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Language switched to ${_languages[_languageIndex]['label']}'),
      ));
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) _flutterTts.stop();
  }

  void _toggleCaptions() =>
      setState(() => _captionsEnabled = !_captionsEnabled);

  void _swapVideoViews() =>
      setState(() => _showLocalAsMain = !_showLocalAsMain);

  void _addSubtitle(String text) {
    final timeLabel = TimeOfDay.now().format(context);
    setState(() {
      _currentSubtitle = text;
      _subtitles.insert(0, {'text': text, 'time': timeLabel});
      if (_subtitles.length > 8) _subtitles.removeLast();
      _suggestions = _suggestionMap[text] ?? ['Please repeat'];
    });
  }

  void _appendToSentence(String word) {
    setState(() {
      _sentence = _sentence.isEmpty ? word : '$_sentence $word';
    });
  }

  void _removeLastWord() {
    if (_sentence.trim().isEmpty) return;
    final words = _sentence.trim().split(' ')..removeLast();
    setState(() => _sentence = words.join(' '));
  }

  void _clearSentence() => setState(() => _sentence = '');

  Future<void> _onGestureDetected(String gestureText) async {
    if (gestureText.isEmpty || _lastDetectedGesture == gestureText) return;
    _lastDetectedGesture = gestureText;
    _addSubtitle(gestureText);
    _appendToSentence(gestureText);
    await _speakSubtitle(gestureText);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _lastDetectedGesture == gestureText)
        _lastDetectedGesture = '';
    });
  }

  Future<void> _switchCamera() async {
    await _cameraService.switchCamera();
    if (mounted) setState(() {});
  }

  void _goBack() {
    _cameraService.stopImageStream();
    _flutterTts.stop();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _roomController.dispose();
    _flutterTts.stop();
    _cameraService.stopImageStream();
    _cameraService.dispose();
    _gestureService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // allow back gesture/button to pop normally
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: _buildAppBar(),
        body: _buildVideoCallTab(),
        // ✅ No bottomNavigationBar — ScaffoldWithNav is NOT wrapping this screen
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _goBack,
      ),
      title: Text(
        'Video Call',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language, color: Colors.white),
          onPressed: _changeLanguage,
        ),
        IconButton(
          icon: const Icon(Icons.flip_camera_android_outlined,
              color: Colors.white),
          onPressed: _switchCamera,
        ),
      ],
    );
  }

  Widget _buildVideoCallTab() {
    if (_inCall) return _buildInCallScreen();
    return _buildPreCallScreen();
  }

  Widget _buildPreCallScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.videocam, color: Color(0xFF00BCD4), size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Video Call with Sign Captions',
            style: GoogleFonts.poppins(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time gesture subtitles with speech output',
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFFB0BEC5)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: TextField(
              controller: _roomController,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter room code (optional)',
                hintStyle: GoogleFonts.poppins(
                    color: const Color(0xFF6B6B6B), fontSize: 14),
                suffixIcon: const Icon(Icons.login_outlined,
                    color: Color(0xFF00BCD4), size: 20),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              setState(() => _inCall = true);
              await _startGestureStream();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text('Start Video Call',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInCallScreen() {
    return Stack(
      children: [
        Positioned.fill(child: _buildMainVideoView()),
        Positioned(top: 16, right: 16, child: _buildMiniVideoView()),
        Positioned(top: 16, left: 16, child: _buildStatusChip()),
        Positioned(
          bottom: 84,
          left: 16,
          right: 16,
          child: Column(
            children: [
              if (_captionsEnabled) _buildSubtitleOverlay(),
              const SizedBox(height: 10),
              _buildSentenceComposer(),
              const SizedBox(height: 10),
              _buildSuggestionsRow(),
              const SizedBox(height: 10),
              _buildDemoGestureBar(),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildControlBar(),
        ),
      ],
    );
  }

  Widget _buildMainVideoView() {
    if (_showLocalAsMain) return _buildLocalCameraView();
    return _buildRemoteVideoPlaceholder(
        label: 'Opposite Video', subtitle: 'Remote participant view');
  }

  Widget _buildMiniVideoView() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _swapVideoViews();
      },
      child: Container(
        width: 110,
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 6))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: _showLocalAsMain
              ? _buildRemoteVideoPlaceholder(
                  label: 'Opposite', subtitle: 'Tap to swap', isMini: true)
              : _buildLocalCameraView(),
        ),
      ),
    );
  }

  Widget _buildLocalCameraView() {
    return Container(
      color: const Color(0xFF111111),
      child: _cameraService.isInitialized
          ? CameraPreviewWidget(controller: _cameraService.controller!)
          : const Center(
              child:
                  Icon(Icons.camera_alt, color: Color(0xFF6B6B6B), size: 28)),
    );
  }

  Widget _buildRemoteVideoPlaceholder({
    required String label,
    required String subtitle,
    bool isMini = false,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF161616), Color(0xFF0B0B0B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMini ? 48 : 92,
                height: isMini ? 48 : 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00BCD4).withOpacity(0.14),
                  border: Border.all(
                      color: const Color(0xFF00BCD4).withOpacity(0.35)),
                ),
                child: Icon(Icons.person,
                    color: const Color(0xFF00BCD4), size: isMini ? 24 : 46),
              ),
              SizedBox(height: isMini ? 8 : 14),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: isMini ? 11 : 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              SizedBox(height: isMini ? 2 : 4),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      fontSize: isMini ? 9 : 13,
                      color: const Color(0xFF8E9BA1))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '${_languages[_languageIndex]['label']} • $_debugStatus',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.74),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIVE CAPTIONS',
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFFFF5252),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0)),
          const SizedBox(height: 10),
          if (_currentSubtitle.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00BCD4).withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_currentSubtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          if (_subtitles.isEmpty)
            Text('Detected gestures will appear here...',
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF9A9A9A)))
          else
            ..._subtitles.take(3).map((subtitle) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${subtitle['text']}  •  ${subtitle['time']}',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white)),
                )),
        ],
      ),
    );
  }

  Widget _buildSentenceComposer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.72),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2B2B2B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SENTENCE',
              style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF00BCD4),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(
            _sentence.isEmpty ? 'Your sentence will appear here...' : _sentence,
            style: GoogleFonts.poppins(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _buildSentenceActionButton(
                      label: 'Speak',
                      icon: Icons.volume_up,
                      onTap: _speakSentence)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildSentenceActionButton(
                      label: 'Back',
                      icon: Icons.backspace_outlined,
                      onTap: _removeLastWord)),
              const SizedBox(width: 8),
              Expanded(
                  child: _buildSentenceActionButton(
                      label: 'Clear',
                      icon: Icons.delete_outline,
                      onTap: _clearSentence)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSentenceActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionsRow() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = _suggestions[index];
          return GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              setState(() => _sentence = suggestion);
              await _speakSentence();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF00BCD4).withOpacity(0.35)),
              ),
              child: Center(
                child: Text(suggestion,
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDemoGestureBar() {
    final demoGestures = ['Yes', 'Wait', 'Stop'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: demoGestures.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final gesture = demoGestures[index];
          return GestureDetector(
            onTap: () async {
              HapticFeedback.selectionClick();
              await _onGestureDetected(gesture);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Center(
                child: Text(gesture,
                    style:
                        GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCallButton(
          _isMuted ? Icons.volume_off : Icons.volume_up,
          _isMuted ? const Color(0xFFFF5252) : const Color(0xFF1A1A1A),
          _toggleMute,
        ),
        _buildCallButton(
            Icons.flip_camera_android, const Color(0xFF1A1A1A), _switchCamera),
        // End call → stop stream and go back to chat
        _buildCallButton(Icons.call_end, const Color(0xFFFF5252), () {
          _cameraService.stopImageStream();
          _flutterTts.stop();
          setState(() {
            _inCall = false;
            _subtitles.clear();
            _currentSubtitle = '';
            _lastDetectedGesture = '';
            _lastSpokenText = '';
            _suggestions = [];
            _sentence = '';
            _debugStatus = 'Idle';
          });
        }),
        _buildCallButton(
          _captionsEnabled
              ? Icons.closed_caption
              : Icons.closed_caption_disabled,
          _captionsEnabled ? const Color(0xFF00BCD4) : const Color(0xFF1A1A1A),
          _toggleCaptions,
        ),
        _buildCallButton(
            Icons.swap_horiz, const Color(0xFF1A1A1A), _swapVideoViews),
      ],
    );
  }

  Widget _buildCallButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
