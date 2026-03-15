import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../services/gesture_service.dart';
import '../services/tflite_service.dart';
import '../widgets/camera_preview_widget.dart';

class SignSpeechScreen extends StatefulWidget {
  const SignSpeechScreen({super.key});
  @override
  State<SignSpeechScreen> createState() => _SignSpeechScreenState();
}

class _SignSpeechScreenState extends State<SignSpeechScreen>
    with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService();
  final PermissionService _permissionService = PermissionService();
  final GestureService _gestureService = GestureService();
  final TFLiteService _tfliteService = TFLiteService();
  final FlutterTts _tts = FlutterTts();

  bool _isDetecting = false;
  bool _isProcessing = false;
  bool _inCooldown = false;
  String _currentSign = '';
  double _confidence = 0.0;
  String _currentWord = '';
  String _sentence = '';
  int _frameCount = 0;
  String _lastStableSign = '';
  int _sameSignCount = 0;
  static const int _confirmFrames = 8;
  static const Duration _cooldownDuration = Duration(milliseconds: 1500);
  static const Duration _autoSpaceDuration = Duration(seconds: 2);
  Timer? _autoSpaceTimer;
  Timer? _cooldownTimer;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Set<String> _wordSigns = {
    'HELLO',
    'HELP',
    'YES',
    'NO',
    'STOP',
    'THANK YOU',
    'SORRY',
    'PLEASE',
    'WATER',
    'FOOD',
    'I LOVE YOU',
    'WHERE',
    'PAIN',
    'GOOD',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
    _init();
  }

  Future<void> _init() async {
    final granted = await _permissionService.requestCamera(context);
    if (granted) {
      await _cameraService.initialize();
      await _gestureService.loadModel();
      await _tfliteService.loadModel();
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      if (mounted) setState(() {});
    }
  }

  void _startCooldown() {
    _inCooldown = true;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(_cooldownDuration, () {
      _inCooldown = false;
      _sameSignCount = 0;
      _lastStableSign = '';
    });
  }

  void _startAutoSpaceTimer() {
    _autoSpaceTimer?.cancel();
    _autoSpaceTimer = Timer(_autoSpaceDuration, () {
      if (_currentWord.isNotEmpty && mounted) {
        setState(() {
          _sentence += _currentWord + ' ';
          _currentWord = '';
          _lastStableSign = '';
          _sameSignCount = 0;
        });
      }
    });
  }

  void _toggleDetection() {
    HapticFeedback.mediumImpact();
    setState(() => _isDetecting = !_isDetecting);
    if (_isDetecting) {
      _cameraService.startImageStream((image) async {
        if (!_isDetecting || _isProcessing || _inCooldown) return;
        _frameCount++;
        if (_frameCount % 2 != 0) return;
        _isProcessing = true;
        try {
          final inputImage = _gestureService.buildInputImage(
            image,
            _cameraService.controller!.description,
          );
          if (inputImage == null) {
            _isProcessing = false;
            return;
          }
          final poses = await _gestureService.detectPose(inputImage);
          final result = _tfliteService.classifyFromPose(poses);
          final sign = result['sign'] as String;
          final confidence = result['confidence'] as double;
          if (sign.isEmpty) {
            if (mounted)
              setState(() {
                _currentSign = '';
                _confidence = 0.0;
                _sameSignCount = 0;
                _lastStableSign = '';
              });
            _isProcessing = false;
            return;
          }
          if (mounted)
            setState(() {
              _currentSign = sign;
              _confidence = confidence;
            });
          if (sign == _lastStableSign) {
            _sameSignCount++;
          } else {
            _lastStableSign = sign;
            _sameSignCount = 1;
          }
          if (_sameSignCount >= _confirmFrames) {
            _handleConfirmedSign(sign);
            _startCooldown();
          }
        } catch (e) {
          print(e);
        } finally {
          _isProcessing = false;
        }
      });
    } else {
      _cameraService.stopImageStream();
      _autoSpaceTimer?.cancel();
      _cooldownTimer?.cancel();
      _inCooldown = false;
      setState(() {
        _currentSign = '';
        _confidence = 0.0;
        _frameCount = 0;
        _sameSignCount = 0;
        _lastStableSign = '';
      });
    }
  }

  void _handleConfirmedSign(String sign) {
    _autoSpaceTimer?.cancel();
    HapticFeedback.lightImpact();
    final isWord = _wordSigns.contains(sign);
    if (mounted) {
      setState(() {
        if (isWord) {
          if (_currentWord.isNotEmpty) {
            _sentence += _currentWord + ' ';
            _currentWord = '';
          }
          _sentence += sign + ' ';
        } else {
          _currentWord += sign;
          _startAutoSpaceTimer();
        }
      });
    }
  }

  void _speakText(String text) async {
    HapticFeedback.lightImpact();
    if (text.isNotEmpty) await _tts.speak(text);
  }

  void _deleteLast() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_currentWord.isNotEmpty) {
        _currentWord = _currentWord.substring(0, _currentWord.length - 1);
      } else if (_sentence.isNotEmpty) {
        _sentence = _sentence.trimRight();
        final lastSpace = _sentence.lastIndexOf(' ');
        _sentence = lastSpace >= 0 ? _sentence.substring(0, lastSpace + 1) : '';
      }
    });
  }

  void _clearAll() {
    HapticFeedback.mediumImpact();
    _autoSpaceTimer?.cancel();
    _cooldownTimer?.cancel();
    _inCooldown = false;
    setState(() {
      _currentWord = '';
      _sentence = '';
      _currentSign = '';
      _confidence = 0.0;
      _sameSignCount = 0;
      _lastStableSign = '';
    });
  }

  void _addSpace() {
    HapticFeedback.lightImpact();
    _autoSpaceTimer?.cancel();
    setState(() {
      if (_currentWord.isNotEmpty) {
        _sentence += _currentWord + ' ';
        _currentWord = '';
      }
    });
  }

  @override
  void dispose() {
    _autoSpaceTimer?.cancel();
    _cooldownTimer?.cancel();
    _fadeController.dispose();
    _cameraService.dispose();
    _gestureService.dispose();
    _tfliteService.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText = (_sentence + _currentWord).trim();
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Sign → Speech',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.flip_camera_android_outlined,
              color: Colors.white,
            ),
            onPressed: () async {
              await _cameraService.switchCamera();
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Camera ──────────────────────
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isDetecting
                        ? const Color(0xFF00BCD4).withOpacity(0.6)
                        : const Color(0xFF2A2A2A),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _cameraService.isInitialized
                          ? CameraPreviewWidget(
                              controller: _cameraService.controller!,
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    color: Color(0xFF6B6B6B),
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Camera loading...',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B6B6B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _isDetecting
                                  ? const Color(0xFF00BCD4).withOpacity(0.5)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            _isDetecting ? 'DETECTING' : 'PAUSED',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _isDetecting
                                  ? const Color(0xFF00BCD4)
                                  : const Color(0xFF6B6B6B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Detection Result ─────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _inCooldown
                        ? const Color(0xFF69F0AE).withOpacity(0.4)
                        : _currentSign.isNotEmpty
                        ? const Color(0xFF00BCD4).withOpacity(0.3)
                        : const Color(0xFF2A2A2A),
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _inCooldown
                            ? const Color(0xFF69F0AE).withOpacity(0.15)
                            : const Color(0xFF00BCD4).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _inCooldown ? Icons.check_circle : Icons.sign_language,
                        color: _inCooldown
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFF00BCD4),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _inCooldown
                                ? '$_currentSign added!'
                                : _currentSign.isEmpty
                                ? 'Show your hand...'
                                : _currentSign,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: _inCooldown
                                  ? const Color(0xFF69F0AE)
                                  : Colors.white,
                            ),
                          ),
                          if (_currentSign.isNotEmpty && !_inCooldown) ...[
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: _sameSignCount / _confirmFrames,
                              backgroundColor: const Color(0xFF2A2A2A),
                              color: const Color(0xFF00BCD4),
                              minHeight: 3,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Confirming...',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFFB0BEC5),
                              ),
                            ),
                          ],
                          if (_inCooldown)
                            Text(
                              'Hold a new sign...',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFFB0BEC5),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_currentSign.isNotEmpty && !_inCooldown)
                      Text(
                        '${(_confidence * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Output Box ────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: const Border(
                    left: BorderSide(color: Color(0xFF00BCD4), width: 3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OUTPUT',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF00BCD4),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${fullText.length} chars',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF6B6B6B),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: fullText),
                                );
                                HapticFeedback.lightImpact();
                              },
                              child: const Icon(
                                Icons.copy_outlined,
                                color: Color(0xFF6B6B6B),
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    fullText.isEmpty
                        ? Text(
                            'Start signing to build sentence...',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF6B6B6B),
                            ),
                          )
                        : RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: _sentence,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextSpan(
                                  text: _currentWord,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: const Color(0xFF00BCD4),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ── Row 1: Start + Speak ──────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleDetection,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: _isDetecting
                              ? const Color(0xFFFF5252)
                              : const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isDetecting ? Icons.stop : Icons.play_arrow,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isDetecting ? 'Stop' : 'Start',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: fullText.isNotEmpty
                          ? () => _speakText(fullText)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: fullText.isNotEmpty
                              ? const Color(0xFF7C4DFF)
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.volume_up,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Speak',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Row 2: Space, Delete, Clear ───
              Row(
                children: [
                  Expanded(
                    child: _buildOutlineBtn(
                      Icons.space_bar,
                      'Space',
                      const Color(0xFF00BCD4),
                      _addSpace,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOutlineBtn(
                      Icons.backspace_outlined,
                      'Delete',
                      Colors.orange,
                      _deleteLast,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildOutlineBtn(
                      Icons.clear,
                      'Clear',
                      const Color(0xFFFF5252),
                      _clearAll,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(1),
    );
  }

  // ── Outline Button ────────────────────────────
  Widget _buildOutlineBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────
  Widget _buildBottomNav(int activeIndex) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home_outlined,
            'Home',
            activeIndex == 0,
            () => context.go('/home'),
          ),
          _buildNavItem(
            Icons.sign_language_outlined,
            'Sign',
            activeIndex == 1,
            () => context.go('/communicate'),
          ),
          _buildNavItem(
            Icons.menu_book_outlined,
            'Learn',
            activeIndex == 2,
            () => context.go('/learn'),
          ),
          _buildNavItem(
            Icons.emergency_outlined,
            'SOS',
            activeIndex == 3,
            () => context.go('/emergency'),
            color: const Color(0xFFFF5252),
          ),
          _buildNavItem(
            Icons.person_outline,
            'Profile',
            activeIndex == 4,
            () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  // ── Nav Item ──────────────────────────────────
  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap, {
    Color? color,
  }) {
    final activeColor = color ?? const Color(0xFF00BCD4);
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? activeColor : const Color(0xFF6B6B6B),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isActive ? activeColor : const Color(0xFF6B6B6B),
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
