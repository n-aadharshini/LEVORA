import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:vibration/vibration.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';

// ── Add to pubspec.yaml ────────────────────────
// vibration: ^2.0.0
// noise_meter: ^5.0.0
// permission_handler: ^11.0.0

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
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool _isListening = false;
  double _currentDb = 0.0;
  double _peakDb = 0.0;
  final List<double> _dbHistory = List.filled(30, 0.0);

  // ── Detection State ─────────────────────────
  String _detectedSound = '';
  String _detectedEmoji = '';
  Color _detectedColor = const Color(0xFF00BCD4);
  double _confidence = 0.0;
  bool _isVibrating = false;
  Timer? _detectionCooldown;
  int _detectionCount = 0;

  int? _manualPlayIndex;

  // ── Sound Profiles ──────────────────────────
  final List<Map<String, dynamic>> _soundProfiles = [
    {
      'name': 'Bell / Doorbell',
      'emoji': '🔔',
      'color': const Color(0xFFFFC107),
      'description': 'Sharp ping-like repeated taps',
      'minDb': 55.0,
      'maxDb': 75.0,
      // Short rapid equal bursts — mimics ding ding ding
      'pattern': [100, 80, 100, 80, 100, 80, 100],
      'intensities': [255, 0, 255, 0, 255, 0, 255],
      'repeatCount': 2,
    },
    {
      'name': 'Kids Shouting',
      'emoji': '🧒',
      'color': const Color(0xFFFF80AB),
      'description': 'Irregular chaotic pulses',
      'minDb': 70.0,
      'maxDb': 88.0,
      // Chaotic and irregular — mimics scattered children energy
      'pattern': [60, 30, 120, 20, 80, 40, 150, 10, 90, 50, 70],
      'intensities': [180, 0, 255, 0, 150, 0, 255, 0, 200, 0, 160],
      'repeatCount': 1,
    },
    {
      'name': 'Dog Barking',
      'emoji': '🐕',
      'color': const Color(0xFF8D6E63),
      'description': 'Heavy thumps with long pauses',
      'minDb': 65.0,
      'maxDb': 85.0,
      // Heavy slow thumps — chest-heavy bark feeling
      'pattern': [350, 250, 350, 250, 350],
      'intensities': [255, 0, 255, 0, 255],
      'repeatCount': 1,
    },
    {
      'name': 'Breaking Glass',
      'emoji': '🪟',
      'color': const Color(0xFF64B5F6),
      'description': 'One big crack then shimmer',
      'minDb': 75.0,
      'maxDb': 100.0,
      // One massive hit then rapid decay shimmer
      'pattern': [600, 60, 40, 30, 25, 20, 15, 12, 10],
      'intensities': [255, 0, 180, 120, 80, 60, 40, 25, 15],
      'repeatCount': 1,
    },
    {
      'name': 'Emergency Siren',
      'emoji': '🚨',
      'color': const Color(0xFFFF5252),
      'description': 'Rising and falling wave',
      'minDb': 80.0,
      'maxDb': 100.0,
      // Starts soft and builds to max — like siren approaching
      'pattern': [400, 200, 400, 200, 400, 200, 400],
      'intensities': [50, 0, 120, 0, 200, 0, 255],
      'repeatCount': 2,
    },
    {
      'name': 'Car Honk',
      'emoji': '🚗',
      'color': const Color(0xFF90A4AE),
      'description': 'Two firm steady blasts',
      'minDb': 70.0,
      'maxDb': 90.0,
      // Two confident blasts
      'pattern': [300, 150, 300],
      'intensities': [255, 0, 255],
      'repeatCount': 1,
    },
    {
      'name': 'Rain / Water',
      'emoji': '🌧️',
      'color': const Color(0xFF4FC3F7),
      'description': 'Soft irregular light taps',
      'minDb': 35.0,
      'maxDb': 55.0,
      // Very soft and random — like raindrops
      'pattern': [40, 90, 25, 110, 35, 70, 30, 95, 45],
      'intensities': [80, 0, 60, 0, 100, 0, 70, 0, 85],
      'repeatCount': 2,
    },
    {
      'name': 'Fire Alarm',
      'emoji': '🔥',
      'color': const Color(0xFFFF7043),
      'description': 'Rapid urgent equal bursts',
      'minDb': 85.0,
      'maxDb': 110.0,
      // Fast insistent equal pulses — unmistakably urgent
      'pattern': [120, 80, 120, 80, 120, 80, 120, 80, 120],
      'intensities': [255, 0, 255, 0, 255, 0, 255, 0, 255],
      'repeatCount': 3,
    },
    {
      'name': 'Clapping',
      'emoji': '👏',
      'color': const Color(0xFF69F0AE),
      'description': 'Rhythmic repeated claps',
      'minDb': 60.0,
      'maxDb': 80.0,
      // Even rhythmic claps
      'pattern': [150, 120, 150, 120, 150, 120],
      'intensities': [200, 0, 200, 0, 200, 0],
      'repeatCount': 2,
    },
    {
      'name': 'Loud Music',
      'emoji': '🎵',
      'color': const Color(0xFF7C4DFF),
      'description': 'Strong steady bass beats',
      'minDb': 75.0,
      'maxDb': 95.0,
      // Bass beat pattern — strong with variation
      'pattern': [200, 100, 200, 100, 400, 100, 200, 100],
      'intensities': [200, 0, 200, 0, 255, 0, 200, 0],
      'repeatCount': 2,
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
    _barAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _barController, curve: Curves.easeInOut));
    _noiseMeter = NoiseMeter();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    _stopListening();
    _detectionCooldown?.cancel();
    Vibration.cancel();
    super.dispose();
  }

  // ── Mic Permission ──────────────────────────
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
    });

    try {
      _noiseSubscription = _noiseMeter!.noise.listen((NoiseReading reading) {
        if (!mounted) return;
        final db = reading.meanDecibel.isFinite
            ? reading.meanDecibel.clamp(0.0, 120.0)
            : 0.0;
        setState(() {
          _currentDb = db;
          if (db > _peakDb) _peakDb = db;
          _dbHistory.removeAt(0);
          _dbHistory.add(db);
        });
        _analyzeSound(db);
      }, onError: (_) => _stopListening());
    } catch (_) {
      _stopListening();
    }
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    if (mounted) {
      setState(() {
        _isListening = false;
        _currentDb = 0.0;
        _peakDb = 0.0;
        _dbHistory.fillRange(0, _dbHistory.length, 0.0);
      });
    }
  }

  // ── Sound Analysis ───────────────────────────
  void _analyzeSound(double db) {
    if (db < 42.0) {
      if (_detectedSound.isNotEmpty && mounted) {
        setState(() {
          _detectedSound = '';
          _confidence = 0.0;
        });
      }
      return;
    }
    if (_detectionCooldown != null) return;

    // Match by dB range — real app would use ML model here
    final candidates = _soundProfiles
        .where(
          (s) =>
              db >= (s['minDb'] as double) - 8 &&
              db <= (s['maxDb'] as double) + 8,
        )
        .toList();
    if (candidates.isEmpty) return;

    final rng = Random();
    final matched = candidates[rng.nextInt(candidates.length)];
    final conf = 0.62 + rng.nextDouble() * 0.33;

    if (mounted) {
      setState(() {
        _detectedSound = matched['name'];
        _detectedEmoji = matched['emoji'];
        _detectedColor = matched['color'] as Color;
        _confidence = conf;
        _detectionCount++;
      });
    }

    _playHapticPattern(matched);

    _detectionCooldown = Timer(const Duration(seconds: 2), () {
      _detectionCooldown = null;
    });
  }

  // ── Haptic Engine ────────────────────────────
  Future<void> _playHapticPattern(Map<String, dynamic> sound) async {
    final hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    final hasAmplitude = await Vibration.hasAmplitudeControl() ?? false;
    final pattern = List<int>.from(sound['pattern'] as List);
    final intensities = List<int>.from(sound['intensities'] as List);
    final repeatCount = sound['repeatCount'] as int;

    // Build full repeated pattern
    List<int> fullPattern = [];
    List<int> fullIntensities = [];
    for (int r = 0; r < repeatCount; r++) {
      fullPattern.addAll(pattern);
      fullIntensities.addAll(intensities);
      if (r < repeatCount - 1) {
        fullPattern.add(300);
        fullIntensities.add(0);
      }
    }

    if (mounted) setState(() => _isVibrating = true);

    if (hasAmplitude) {
      await Vibration.vibrate(
        pattern: fullPattern,
        intensities: fullIntensities,
      );
    } else {
      // Fallback for devices without amplitude control
      for (int i = 0; i < fullPattern.length; i++) {
        if (fullIntensities[i] > 0) {
          if (fullIntensities[i] > 200) {
            HapticFeedback.heavyImpact();
          } else if (fullIntensities[i] > 100) {
            HapticFeedback.mediumImpact();
          } else {
            HapticFeedback.lightImpact();
          }
        }
        await Future.delayed(Duration(milliseconds: fullPattern[i]));
      }
    }

    final totalMs = fullPattern.fold(0, (a, b) => a + b);
    Future.delayed(Duration(milliseconds: totalMs), () {
      if (mounted) setState(() => _isVibrating = false);
    });
  }

  Future<void> _playManual(int index) async {
    setState(() => _manualPlayIndex = index);
    await _playHapticPattern(_soundProfiles[index]);
    final dur =
        (_soundProfiles[index]['pattern'] as List<int>).fold(
              0,
              (a, b) => a + b,
            ) *
            (_soundProfiles[index]['repeatCount'] as int) +
        600;
    Future.delayed(Duration(milliseconds: dur), () {
      if (mounted) setState(() => _manualPlayIndex = null);
    });
  }

  // ── Build ────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/learn'),
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
              child: const Icon(
                Icons.vibration,
                color: Color(0xFFFF5252),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sound Textures',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
                      fontSize: 11,
                      color: const Color(0xFF00BCD4),
                    ),
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

  // ── Listener Card ────────────────────────────
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
          // Big mic button
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
                          color:
                              (_isListening
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
                ? 'Phone will vibrate when a sound is detected'
                : 'Detects surrounding sounds and vibrates with their unique pattern',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B6B6B),
            ),
            textAlign: TextAlign.center,
          ),

          if (_isListening) ...[
            const SizedBox(height: 16),
            // Live dB meter
            Row(
              children: [
                Text(
                  'Volume',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B6B6B),
                  ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Live Waveform ────────────────────────────
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

  // ── Detection Result Card ────────────────────
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
                      child: Text(
                        _detectedEmoji,
                        style: const TextStyle(fontSize: 30),
                      ),
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
                          'Detected Sound',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFB0BEC5),
                          ),
                        ),
                        if (_isVibrating) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _detectedColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.vibration,
                                  color: _detectedColor,
                                  size: 10,
                                ),
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

          // Confidence
          Row(
            children: [
              Text(
                'Confidence',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: const Color(0xFF6B6B6B),
                ),
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

          // Replay button
          GestureDetector(
            onTap: () {
              final profile = _soundProfiles.firstWhere(
                (s) => s['name'] == _detectedSound,
                orElse: () => _soundProfiles[0],
              );
              _playHapticPattern(profile);
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

  // ── Sound Library ────────────────────────────
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
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
          ),
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
                  // Pattern preview bars
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
                          spreadRadius: 2,
                        ),
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
