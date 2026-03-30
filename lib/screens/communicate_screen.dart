import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';
import '../services/camera_service.dart';
import '../services/permission_service.dart';
import '../services/gesture_service.dart';
import '../services/tflite_service.dart';
import '../widgets/camera_preview_widget.dart';

class CommunicateScreen extends StatefulWidget {
  const CommunicateScreen({super.key});
  @override
  State<CommunicateScreen> createState() => _CommunicateScreenState();
}

class _CommunicateScreenState extends State<CommunicateScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ── Services ─────────────────────────────────
  final CameraService _cameraService = CameraService();
  final PermissionService _permissionService = PermissionService();
  final GestureService _gestureService = GestureService();
  final TFLiteService _tfliteService = TFLiteService();
  final FlutterTts _tts = FlutterTts();

  // ── Sign to Text ──────────────────────────────
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

  // ── Speech to Sign ────────────────────────────
  bool _isListening = false;
  String _spokenText = '';
  String _signToShow = '';
  String _signInstruction = '';

  // ── Video Call ────────────────────────────────
  bool _inCall = false;
  final TextEditingController _roomController = TextEditingController();
  List<Map<String, String>> _subtitles = [];

  // ── Animations ────────────────────────────────
  late AnimationController _micPulseController;
  late Animation<double> _micPulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

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

  final Map<String, Map<String, String>> _phraseToSign = {
    'hello': {
      'sign': 'HELLO',
      'how': 'Open hand wave from forehead outward',
      'difficulty': 'Easy',
    },
    'help': {
      'sign': 'HELP',
      'how': 'Thumb up fist on flat palm, lift both up',
      'difficulty': 'Easy',
    },
    'thank you': {
      'sign': 'THANK YOU',
      'how': 'Flat hand from chin moves forward and down',
      'difficulty': 'Easy',
    },
    'thanks': {
      'sign': 'THANK YOU',
      'how': 'Flat hand from chin moves forward and down',
      'difficulty': 'Easy',
    },
    'sorry': {
      'sign': 'SORRY',
      'how': 'A handshape circles on chest',
      'difficulty': 'Easy',
    },
    'yes': {
      'sign': 'YES',
      'how': 'A handshape nods up and down',
      'difficulty': 'Easy',
    },
    'no': {
      'sign': 'NO',
      'how': 'Index and middle finger close onto thumb',
      'difficulty': 'Easy',
    },
    'water': {
      'sign': 'WATER',
      'how': 'W handshape tapped to chin twice',
      'difficulty': 'Easy',
    },
    'food': {
      'sign': 'FOOD',
      'how': 'Bring fingertips to mouth repeatedly',
      'difficulty': 'Easy',
    },
    'eat': {
      'sign': 'FOOD',
      'how': 'Bring fingertips to mouth repeatedly',
      'difficulty': 'Easy',
    },
    'stop': {
      'sign': 'STOP',
      'how': 'Chop edge of hand onto other palm',
      'difficulty': 'Easy',
    },
    'please': {
      'sign': 'PLEASE',
      'how': 'Flat hand circles clockwise on chest',
      'difficulty': 'Easy',
    },
    'good': {
      'sign': 'GOOD',
      'how': 'Flat hand from chin moves to other palm',
      'difficulty': 'Easy',
    },
    'love': {
      'sign': 'I LOVE YOU',
      'how': 'Cross both arms over chest like a hug',
      'difficulty': 'Easy',
    },
    'pain': {
      'sign': 'PAIN',
      'how': 'Tap fingers together at hurt area',
      'difficulty': 'Easy',
    },
    'where': {
      'sign': 'WHERE',
      'how': 'Index finger waggles side to side',
      'difficulty': 'Easy',
    },
    'more': {
      'sign': 'MORE',
      'how': 'Bring flat O hands together tapping fingertips',
      'difficulty': 'Easy',
    },
    'danger': {
      'sign': 'DANGER',
      'how': 'A handshape sweeps up from under other hand',
      'difficulty': 'Medium',
    },
  };

  final List<String> _quickPhrases = [
    'HELLO',
    'HELP',
    'THANK YOU',
    'SORRY',
    'YES',
    'NO',
    'WATER',
    'FOOD',
    'STOP',
    'PLEASE',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

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

  // ── Sign Detection Logic ──────────────────────
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
    if (_inCall) {
      setState(() {
        _subtitles.add({
          'text': sign,
          'time':
              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        });
      });
    }
  }

  void _speakText(String text) async {
    if (text.isNotEmpty) {
      HapticFeedback.lightImpact();
      await _tts.speak(text);
    }
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

  // ── Speech to Sign Logic ──────────────────────
  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = !_isListening;
      if (!_isListening) {
        _spokenText = '';
      }
    });
  }

  void _convertPhraseToSign(String phrase) {
    final lower = phrase.toLowerCase();
    Map<String, String>? found;
    for (final key in _phraseToSign.keys) {
      if (lower.contains(key)) {
        found = _phraseToSign[key];
        break;
      }
    }
    if (found != null) {
      setState(() {
        _signToShow = found!['sign']!;
        _signInstruction = found['how']!;
        _spokenText = phrase;
      });
    } else {
      setState(() {
        _signToShow = phrase.toUpperCase();
        _signInstruction = 'Spell it out letter by letter';
        _spokenText = phrase;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _micPulseController.dispose();
    _waveController.dispose();
    _autoSpaceTimer?.cancel();
    _cooldownTimer?.cancel();
    _roomController.dispose();
    _cameraService.dispose();
    _gestureService.dispose();
    _tfliteService.dispose();
    _tts.stop();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: _buildAppBar(),
        body: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSignToTextTab(),
                  _buildSpeechToSignTab(),
                  _buildVideoCallTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(1),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF0A0A0A),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'Communicate',
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
    );
  }

  // ── Tab Bar ───────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF00BCD4),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF6B6B6B),
        labelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sign_language, size: 14),
                SizedBox(width: 4),
                Flexible(
                  child: Text('Sign → Text', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic, size: 14),
                SizedBox(width: 4),
                Flexible(
                  child: Text('Speech → Sign', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam, size: 14),
                SizedBox(width: 4),
                Flexible(
                  child: Text('Video Call', overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // TAB 1 — SIGN TO TEXT
  // ══════════════════════════════════════════════
  Widget _buildSignToTextTab() {
    final fullText = (_sentence + _currentWord).trim();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Camera Preview ──────────────────
          Container(
            height: 320,
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

          // ── Detection Result ────────────────
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
                            ? '$_currentSign  added!'
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

          // ── Output Box ──────────────────────
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
                            Clipboard.setData(ClipboardData(text: fullText));
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

          // ── Row 1: Start + Speak ────────────
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
                  onTap:
                      fullText.isNotEmpty ? () => _speakText(fullText) : null,
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

          // ── Row 2: Space, Delete, Clear ─────
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
        ],
      ),
    );
  }

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

  // ══════════════════════════════════════════════
  // TAB 2 — SPEECH TO SIGN
  // ══════════════════════════════════════════════
  Widget _buildSpeechToSignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Mic Button ──────────────────────
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _micPulseAnimation,
              builder: (context, child) => Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening) ...[
                    Container(
                      width: 130 * _micPulseAnimation.value,
                      height: 130 * _micPulseAnimation.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00BCD4).withOpacity(0.1),
                      ),
                    ),
                    Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00BCD4).withOpacity(0.15),
                      ),
                    ),
                  ],
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFFF5252), const Color(0xFFB71C1C)]
                            : [
                                const Color(0xFF00BCD4),
                                const Color(0xFF7C4DFF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? const Color(0xFFFF5252)
                                  : const Color(0xFF00BCD4))
                              .withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop : Icons.mic,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: _isListening
                  ? const Color(0xFF00BCD4)
                  : const Color(0xFFB0BEC5),
            ),
          ),

          // ── Waveform ────────────────────────
          if (_isListening) ...[
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(12, (i) {
                  final height = 10.0 +
                      (i % 3 == 0
                          ? 30 * _waveAnimation.value
                          : i % 3 == 1
                              ? 20 * _waveAnimation.value
                              : 15 * _waveAnimation.value);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 4,
                    height: height,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Sign Result ─────────────────────
          if (_signToShow.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sign_language,
                      color: Color(0xFF00BCD4),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Make this sign:',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _signToShow,
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _signInstruction,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _speakText(_signToShow),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C4DFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF7C4DFF).withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volume_up,
                            color: Color(0xFF7C4DFF),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Hear it',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF7C4DFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Quick Phrases ───────────────────
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Common Phrases',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPhrases
                .map(
                  (phrase) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _convertPhraseToSign(phrase.toLowerCase());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF00BCD4).withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        phrase,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF00BCD4),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // TAB 3 — VIDEO CALL
  // ══════════════════════════════════════════════
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
            child: const Icon(
              Icons.videocam,
              color: Color(0xFF00BCD4),
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Video Call with Sign Captions',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Signs detected automatically as live subtitles',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFB0BEC5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...[
            'Live sign detection',
            'Auto subtitles for both sides',
            'Works with any video call',
            'Adjustable caption size',
          ].map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Color(0xFF00BCD4),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    f,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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
                  color: const Color(0xFF6B6B6B),
                  fontSize: 14,
                ),
                suffixIcon: const Icon(
                  Icons.login_outlined,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _inCall = true);
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
                  Text(
                    'Start Video Call',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
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
        Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFF0D0D0D),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Color(0xFF3A3A3A), size: 80),
              Text(
                'Connecting...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00BCD4).withOpacity(0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _cameraService.isInitialized
                  ? CameraPreviewWidget(controller: _cameraService.controller!)
                  : const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Color(0xFF6B6B6B),
                        size: 24,
                      ),
                    ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: 16,
          right: 16,
          child: Column(
            children: [
              if (_currentSign.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _currentSign,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF5252),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE CAPTIONS',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFFFF5252),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._subtitles.take(3).map(
                          (s) => Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '${s['text']}  ${s['time']}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    if (_subtitles.isEmpty)
                      Text(
                        'Signs will appear here...',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCallButton(Icons.mic_off, const Color(0xFF1A1A1A), () {}),
              _buildCallButton(Icons.videocam, const Color(0xFF1A1A1A), () {}),
              _buildCallButton(
                Icons.call_end,
                const Color(0xFFFF5252),
                () => setState(() {
                  _inCall = false;
                  _subtitles.clear();
                }),
              ),
              _buildCallButton(
                Icons.closed_caption,
                const Color(0xFF00BCD4),
                () {},
              ),
              _buildCallButton(
                Icons.screen_share,
                const Color(0xFF1A1A1A),
                () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Call Button ───────────────────────────────
  Widget _buildCallButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
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
            () {},
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
