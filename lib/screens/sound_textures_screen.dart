import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class SoundTexturesScreen extends StatefulWidget {
  const SoundTexturesScreen({super.key});
  @override
  State<SoundTexturesScreen> createState() => _SoundTexturesScreenState();
}

class _SoundTexturesScreenState extends State<SoundTexturesScreen>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _barController;
  late Animation<double> _barAnimation;

  // ── Mic / Detection ─────────────────────────
  bool _isListening = false;
  double _currentDb = 0.0;
  double _peakDb = 0.0;
  final List<double> _dbHistory = List.generate(30, (_) => 0.0);

  // ── Detection State ─────────────────────────
  String _detectedSound = '';
  String _detectedEmoji = '';
  Color _detectedColor = const Color(0xFF00BCD4);
  double _confidence = 0.0;
  bool _isVibrating = false;
  bool _waitingForNoticed = false;
  Timer? _detectionCooldown;
  int _detectionCount = 0;
  int? _manualPlayIndex;

  // ── Continuous vibration loop ────────────────
  Timer? _vibrationLoopTimer;

  // ── Audio ────────────────────────────────────
  final AudioRecorder _audioRecorder = AudioRecorder();
  Timer? _recordingTimer;
  bool _isRecording = false;

  // ── Pattern tracking for detection ──────────
  final List<double> _recentDbReadings = [];
  static const int _patternWindow = 5;

  // ── Sound Profiles ──────────────────────────
  final List<Map<String, dynamic>> _soundProfiles = [
    {
      'name': 'Fire Alarm',
      'emoji': '🔥',
      'color': const Color(0xFFFF7043),
      'description': 'Rapid urgent equal bursts',
      // Short sharp equal blasts — classic alarm feel
      'pattern': [1000, 200, 1000, 200, 1000, 200],
      'intensities': [255, 0, 255, 0, 255, 0],
      'repeatCount': 1,
      'dbMin': 80.0,
      'dbMax': 120.0,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
    {
      'name': 'Emergency Siren',
      'emoji': '🚨',
      'color': const Color(0xFFFF5252),
      'description': 'Rising and falling wave',
      // Slow ramp up then ramp down — wailing siren feel
      'pattern': [100, 60, 200, 60, 350, 60, 500, 60, 350, 60, 200, 60, 100],
      'intensities': [100, 0, 160, 0, 210, 0, 255, 0, 210, 0, 160, 0, 100],
      'repeatCount': 1,
      'dbMin': 70.0,
      'dbMax': 79.9,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
    {
      'name': 'Car Honk',
      'emoji': '🚗',
      'color': const Color(0xFF90A4AE),
      'description': 'Two firm steady blasts',
      // Two long strong blasts with a clear gap
      'pattern': [500, 200, 500],
      'intensities': [255, 0, 255],
      'repeatCount': 1,
      'dbMin': 66.0,
      'dbMax': 69.9,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
    {
      'name': 'Shouting / Crying',
      'emoji': '🧒',
      'color': const Color(0xFFFF80AB),
      'description': 'Irregular chaotic pulses',
      // Erratic uneven bursts — mimics crying rhythm
      'pattern': [80, 40, 200, 30, 60, 50, 300, 20, 100, 60, 250, 30, 80],
      'intensities': [200, 0, 255, 0, 180, 0, 255, 0, 220, 0, 255, 0, 190],
      'repeatCount': 1,
      'dbMin': 63.0,
      'dbMax': 65.9,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
    {
      'name': 'Loud Music',
      'emoji': '🎵',
      'color': const Color(0xFF7C4DFF),
      'description': 'Strong steady bass beats',
      // Four-on-the-floor kick drum pattern
      'pattern': [300, 100, 300, 100, 300, 100, 600, 100],
      'intensities': [220, 0, 220, 0, 220, 0, 255, 0],
      'repeatCount': 1,
      'dbMin': 72.0,
      'dbMax': 79.9,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
    {
      'name': 'Bell / Doorbell',
      'emoji': '🔔',
      'color': const Color(0xFFFFC107),
      'description': 'Sharp ping then fade',
      // Strong hit then two quick light taps — ding dong feel
      'pattern': [400, 150, 150, 100, 100],
      'intensities': [255, 0, 180, 0, 120],
      'repeatCount': 1,
      'dbMin': 50.0,
      'dbMax': 62.9,
      'varianceMin': 0.0,
      'varianceMax': 999.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..repeat(reverse: true);
    _barAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    _stopListening();
    _detectionCooldown?.cancel();
    _stopVibrationLoop();
    _audioRecorder.dispose();
    Vibration.cancel();
    super.dispose();
  }

  double _calculateDb(Uint8List bytes, int headerSize) {
    if (bytes.length <= headerSize + 2) return 0.0;
    final pcm = bytes.buffer.asInt16List(headerSize);
    if (pcm.isEmpty) return 0.0;
    double sum = 0;
    for (final s in pcm) {
      sum += s * s;
    }
    final rms = sqrt(sum / pcm.length);
    if (rms == 0) return 0.0;
    final db = 20 * log(rms / 32768.0) / ln10 + 90;
    return db.clamp(0.0, 120.0);
  }

  double _calculateVariance(List<double> values) {
    if (values.length < 2) return 0.0;
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => pow(v - mean, 2)).reduce((a, b) => a + b) /
            values.length;
    return variance;
  }

  Map<String, dynamic>? _classifySound(double avgDb, double variance) {
    debugPrint(
        '🔍 Classifying: avgDb=${avgDb.toStringAsFixed(1)} variance=${variance.toStringAsFixed(1)}');
    if (avgDb < 45.0) return null;
    for (final profile in _soundProfiles) {
      final dbMin = profile['dbMin'] as double;
      final dbMax = profile['dbMax'] as double;
      if (avgDb >= dbMin && avgDb <= dbMax) {
        final dbCenter = (dbMin + dbMax) / 2;
        final score = 1.0 - (avgDb - dbCenter).abs() / ((dbMax - dbMin) / 2);
        debugPrint(
            '✅ Detected: ${profile['name']} (score: ${score.toStringAsFixed(2)})');
        return {'profile': profile, 'score': score.clamp(0.0, 1.0)};
      }
    }
    return null;
  }

  // ══════════════════════════════════════════════
  // Continuous vibration loop
  // ══════════════════════════════════════════════
  void _startVibrationLoop(Map<String, dynamic> sound) {
    _stopVibrationLoop();
    if (mounted) setState(() => _waitingForNoticed = true);
    _runVibrationCycle(sound);
  }

  void _runVibrationCycle(Map<String, dynamic> sound) async {
    if (!_waitingForNoticed || !mounted) return;

    if (mounted) setState(() => _isVibrating = true);

    try {
      await Vibration.vibrate(
        pattern: [0, 1000, 200],
        intensities: [0, 255, 0],
        repeat: 0,
      );
    } catch (e) {
      debugPrint('🔔 Vibration error: $e');
      HapticFeedback.heavyImpact();
    }
  }

  void _stopVibrationLoop() {
    _vibrationLoopTimer?.cancel();
    _vibrationLoopTimer = null;
    Vibration.cancel();
    if (mounted) {
      setState(() {
        _isVibrating = false;
        _waitingForNoticed = false;
      });
    }
  }

  void _onNoticed() {
    _stopVibrationLoop();
  }

  // ══════════════════════════════════════════════
  // Recording loop
  // ══════════════════════════════════════════════
  void _startListeningLoop() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (!_isListening) return;
      if (_detectionCooldown != null) return;
      if (_isRecording) return;
      if (_waitingForNoticed) return;

      _isRecording = true;
      try {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/chunk.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: filePath,
        );

        await Future.delayed(const Duration(milliseconds: 1000));
        await _audioRecorder.stop();

        if (!mounted) return;

        final file = File(filePath);
        if (!await file.exists()) return;

        final bytes = await file.readAsBytes();
        if (bytes.length < 1000) return;

        const headerSize = 46;
        if (bytes.length <= headerSize) return;

        final db = _calculateDb(bytes, headerSize);

        _recentDbReadings.add(db);
        if (_recentDbReadings.length > _patternWindow) {
          _recentDbReadings.removeAt(0);
        }

        if (mounted) {
          setState(() {
            _currentDb = db;
            if (db > _peakDb) _peakDb = db;
            _dbHistory.removeAt(0);
            _dbHistory.add(db);
          });
        }

        if (_recentDbReadings.length < 3) return;

        final avgDb = _recentDbReadings.reduce((a, b) => a + b) /
            _recentDbReadings.length;
        final variance = _calculateVariance(_recentDbReadings);

        final result = _classifySound(avgDb, variance);
        if (result == null || !mounted) return;

        final profile = result['profile'] as Map<String, dynamic>;
        final score = result['score'] as double;

        setState(() {
          _detectedSound = profile['name'] as String;
          _detectedEmoji = profile['emoji'] as String;
          _detectedColor = profile['color'] as Color;
          _confidence = score.clamp(0.0, 1.0);
          _detectionCount++;
        });

        _startVibrationLoop(profile);

        _detectionCooldown = Timer(const Duration(seconds: 3), () {
          _detectionCooldown = null;
          _recentDbReadings.clear();
        });
      } catch (e) {
        debugPrint('recording error: $e');
      } finally {
        _isRecording = false;
      }
    });
  }

  Future<void> _toggleListening() async {
    if (_isListening) {
      _stopListening();
      return;
    }

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1A1A1A),
            content: Text(
              'Microphone permission needed to detect sounds.',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isListening = true;
      _detectedSound = '';
      _currentDb = 0.0;
      _peakDb = 0.0;
      _recentDbReadings.clear();
    });

    _startListeningLoop();
  }

  void _stopListening() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _isRecording = false;
    _audioRecorder.stop();
    _recentDbReadings.clear();
    _stopVibrationLoop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _currentDb = 0.0;
        _peakDb = 0.0;
        _dbHistory.fillRange(0, _dbHistory.length, 0.0);
      });
    }
  }

  // ══════════════════════════════════════════════
  // Single play — for manual tile taps
  // ══════════════════════════════════════════════
  Future<void> _playHapticPattern(Map<String, dynamic> sound) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == null || !hasVibrator) return;

    final pattern = List<int>.from(sound['pattern'] as List);
    final intensities = List<int>.from(sound['intensities'] as List);

    try {
      await Vibration.vibrate(pattern: pattern, intensities: intensities);
    } catch (e) {
      debugPrint('🔔 Vibration failed: $e');
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _playManual(int index) async {
    setState(() => _manualPlayIndex = index);
    await _playHapticPattern(_soundProfiles[index]);
    final dur = (_soundProfiles[index]['pattern'] as List<int>)
            .fold(0, (a, b) => a + b) +
        600;
    Future.delayed(Duration(milliseconds: dur), () {
      if (mounted) setState(() => _manualPlayIndex = null);
    });
  }

  // ══════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.vibration,
                  color: Color(0xFFFF5252), size: 18),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Sound Textures',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_detectionCount > 0)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hearing, color: Color(0xFF00BCD4), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$_detectionCount sounds',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF00BCD4)),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildListenerCard(),
            const SizedBox(height: 16),
            if (_isListening) ...[_buildWaveform(), const SizedBox(height: 16)],
            if (_detectedSound.isNotEmpty) ...[
              _buildDetectionResult(),
              const SizedBox(height: 16),
            ],
            _buildSoundLibraryHeader(),
            const SizedBox(height: 12),
            ...List.generate(_soundProfiles.length, (i) => _buildSoundTile(i)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListenerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isListening
              ? const Color(0xFF00BCD4).withOpacity(0.5)
              : const Color(0xFF2A2A2A),
          width: _isListening ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  if (_isListening) ...[
                    Transform.scale(
                      scale: _pulseAnimation.value * 1.4,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00BCD4).withOpacity(0.05),
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: _pulseAnimation.value * 1.2,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00BCD4).withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFFF5252), const Color(0xFFB71C1C)]
                            : [
                                const Color(0xFF00BCD4),
                                const Color(0xFF0097A7),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? const Color(0xFFFF5252)
                                  : const Color(0xFF00BCD4))
                              .withOpacity(0.45),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic,
                      color: Colors.white,
                      size: 46,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _isListening ? 'Listening...' : 'Tap to Start Listening',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _isListening ? const Color(0xFF00BCD4) : Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isListening
                ? 'Detecting sounds by volume and pattern'
                : 'Detects surrounding sounds and vibrates with unique patterns',
            style: GoogleFonts.poppins(
                fontSize: 12, color: const Color(0xFF6B6B6B)),
            textAlign: TextAlign.center,
          ),
          if (_isListening) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Volume',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: const Color(0xFF6B6B6B)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      height: 10,
                      child: LinearProgressIndicator(
                        value: (_currentDb / 120.0).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF2A2A2A),
                        color: _currentDb > 80
                            ? const Color(0xFFFF5252)
                            : _currentDb > 60
                                ? const Color(0xFFFFC107)
                                : const Color(0xFF00BCD4),
                        minHeight: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_currentDb.toStringAsFixed(0)} dB',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.trending_up, color: Colors.orange, size: 13),
                const SizedBox(width: 4),
                Text(
                  'Peak: ${_peakDb.toStringAsFixed(0)} dB',
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: Colors.orange),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_dbHistory.length, (i) {
          final val = (_dbHistory[i] / 120.0).clamp(0.0, 1.0);
          final h = max(3.0, val * 46);
          return AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            width: 7,
            height: h,
            decoration: BoxDecoration(
              color: val > 0.7
                  ? const Color(0xFFFF5252)
                  : val > 0.5
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF00BCD4),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDetectionResult() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _detectedColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _detectedColor.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: _isVibrating ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _detectedColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(_detectedEmoji,
                          style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Detected',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFB0BEC5),
                          ),
                        ),
                        if (_isVibrating) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _detectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.vibration,
                                    color: _detectedColor, size: 10),
                                const SizedBox(width: 3),
                                Text(
                                  'Vibrating',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    color: _detectedColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _detectedSound,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Confidence',
                style: GoogleFonts.poppins(
                    fontSize: 11, color: const Color(0xFF6B6B6B)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _confidence,
                    backgroundColor: const Color(0xFF2A2A2A),
                    color: _detectedColor,
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(_confidence * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _detectedColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── "I Noticed" button — vibrates until tapped ──
          if (_waitingForNoticed)
            GestureDetector(
              onTap: _onNoticed,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (_, __) => Transform.scale(
                  scale: 0.97 + _pulseAnimation.value * 0.03,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _detectedColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: _detectedColor.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 24),
                        const SizedBox(width: 10),
                        Text(
                          'I Noticed',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── "Feel again" button — shows after noticed ──
          if (!_waitingForNoticed)
            GestureDetector(
              onTap: () {
                final profile = _soundProfiles.firstWhere(
                  (s) => s['name'] == _detectedSound,
                  orElse: () => _soundProfiles[0],
                );
                _startVibrationLoop(profile);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _detectedColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _detectedColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.vibration, color: _detectedColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Feel this vibration again',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _detectedColor,
                        fontWeight: FontWeight.w600,
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

  Widget _buildSoundLibraryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sound Library',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap any card to feel its unique vibration pattern',
          style:
              GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B6B6B)),
        ),
      ],
    );
  }

  Widget _buildSoundTile(int index) {
    final s = _soundProfiles[index];
    final color = s['color'] as Color;
    final isPlaying = _manualPlayIndex == index;
    final pattern = s['pattern'] as List<int>;
    final maxVal = pattern.reduce(max);

    return GestureDetector(
      onTap: () => _playManual(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPlaying ? color.withOpacity(0.1) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying ? color.withOpacity(0.7) : color.withOpacity(0.2),
            width: isPlaying ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(s['emoji'], style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['description'],
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _barAnimation,
                    builder: (_, __) => Row(
                      children: List.generate(min(pattern.length, 10), (i) {
                        final h = 3.0 + (pattern[i] / maxVal) * 16;
                        final animated = isPlaying
                            ? h * (0.7 + _barAnimation.value * 0.3)
                            : h;
                        return Container(
                          margin: const EdgeInsets.only(right: 3),
                          width: 5,
                          height: animated,
                          decoration: BoxDecoration(
                            color: isPlaying ? color : color.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isPlaying ? color : color.withOpacity(0.15),
                shape: BoxShape.circle,
                boxShadow: isPlaying
                    ? [
                        BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2)
                      ]
                    : [],
              ),
              child: Icon(
                isPlaying ? Icons.stop_rounded : Icons.vibration,
                color: isPlaying ? Colors.white : color,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
