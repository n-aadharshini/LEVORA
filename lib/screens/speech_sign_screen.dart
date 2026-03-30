import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechSignScreen extends StatefulWidget {
  const SpeechSignScreen({super.key});
  @override
  State<SpeechSignScreen> createState() => _SpeechSignScreenState();
}

class _SpeechSignScreenState extends State<SpeechSignScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();

  late AnimationController _micPulseController;
  late Animation<double> _micPulseAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool _isListening = false;
  String _spokenText = '';
  String _signToShow = '';
  String _signInstruction = '';
  String _signDifficulty = 'Easy';
  List<Map<String, String>> _recentPhrases = [];

  final Map<String, Map<String, String>> _phraseToSign = {
    'hello': {
      'sign': 'HELLO',
      'how': 'Open hand wave from forehead outward',
      'step1': 'Raise your dominant hand to forehead level',
      'step2': 'Wave your open hand outward away from forehead',
      'difficulty': 'Easy',
      'fact': 'Most commonly used greeting sign worldwide!',
    },
    'help': {
      'sign': 'HELP',
      'how': 'Thumb up fist on flat palm, lift both hands up',
      'step1': 'Place your thumb-up fist onto your flat open palm',
      'step2': 'Lift both hands upward together',
      'difficulty': 'Easy',
      'fact': 'Most important emergency sign to learn!',
    },
    'thank you': {
      'sign': 'THANK YOU',
      'how': 'Flat hand from chin moves forward and down',
      'step1': 'Touch your flat hand to your chin',
      'step2': 'Move your hand forward and slightly down',
      'difficulty': 'Easy',
      'fact': 'Like blowing a kiss of gratitude!',
    },
    'thanks': {
      'sign': 'THANK YOU',
      'how': 'Flat hand from chin moves forward and down',
      'step1': 'Touch your flat hand to your chin',
      'step2': 'Move your hand forward and slightly down',
      'difficulty': 'Easy',
      'fact': 'Like blowing a kiss of gratitude!',
    },
    'sorry': {
      'sign': 'SORRY',
      'how': 'A handshape circles on chest',
      'step1': 'Make an A handshape (closed fist with thumb up)',
      'step2': 'Circle your fist on your chest',
      'difficulty': 'Easy',
      'fact': 'Fist over heart = sincere apology!',
    },
    'yes': {
      'sign': 'YES',
      'how': 'A handshape nods up and down',
      'step1': 'Make an A handshape (closed fist)',
      'step2': 'Nod your fist up and down like a nodding head',
      'difficulty': 'Easy',
      'fact': 'Looks exactly like a nodding head!',
    },
    'no': {
      'sign': 'NO',
      'how': 'Index and middle finger close onto thumb',
      'step1': 'Extend index and middle fingers with thumb out',
      'step2': 'Close index and middle fingers down onto thumb',
      'difficulty': 'Easy',
      'fact': 'Like a mouth snapping shut saying NO!',
    },
    'water': {
      'sign': 'WATER',
      'how': 'W handshape tapped to chin twice',
      'step1': 'Make a W handshape (3 fingers extended)',
      'step2': 'Tap your W hand to your chin twice',
      'difficulty': 'Easy',
      'fact': 'W stands for Water!',
    },
    'food': {
      'sign': 'FOOD',
      'how': 'Bring fingertips to mouth repeatedly',
      'step1': 'Bring all fingertips together pointing up',
      'step2': 'Move fingertips to your mouth repeatedly',
      'difficulty': 'Easy',
      'fact': 'Mimics bringing food to your mouth!',
    },
    'eat': {
      'sign': 'FOOD',
      'how': 'Bring fingertips to mouth repeatedly',
      'step1': 'Bring all fingertips together pointing up',
      'step2': 'Move fingertips to your mouth repeatedly',
      'difficulty': 'Easy',
      'fact': 'Same sign for food and eat!',
    },
    'stop': {
      'sign': 'STOP',
      'how': 'Chop edge of hand onto other palm',
      'step1': 'Hold your non-dominant hand flat, palm up',
      'step2': 'Chop the edge of your other hand onto the palm',
      'difficulty': 'Easy',
      'fact': 'Sharp motion = sharp stop!',
    },
    'please': {
      'sign': 'PLEASE',
      'how': 'Flat hand circles clockwise on chest',
      'step1': 'Place your flat open hand on your chest',
      'step2': 'Circle your hand clockwise on your chest',
      'difficulty': 'Easy',
      'fact': 'Heart area = sincere request!',
    },
    'good': {
      'sign': 'GOOD',
      'how': 'Flat hand from chin moves to other palm',
      'step1': 'Touch your flat hand to your chin',
      'step2': 'Move hand forward and place on other open palm',
      'difficulty': 'Easy',
      'fact': 'Presenting goodness forward!',
    },
    'love': {
      'sign': 'I LOVE YOU',
      'how': 'Cross both arms over chest like a hug',
      'step1': 'Cross your arms over your chest',
      'step2': 'Hold the position or squeeze slightly',
      'difficulty': 'Easy',
      'fact': 'Universal gesture of love!',
    },
    'pain': {
      'sign': 'PAIN',
      'how': 'Tap fingers together at hurt area',
      'step1': 'Point both index fingers toward each other',
      'step2': 'Tap fingertips together near the painful area',
      'difficulty': 'Easy',
      'fact': 'Used to tell doctors exactly where it hurts!',
    },
    'where': {
      'sign': 'WHERE',
      'how': 'Index finger waggles side to side',
      'step1': 'Raise your index finger up',
      'step2': 'Waggle it side to side quickly',
      'difficulty': 'Easy',
      'fact': 'Like searching side to side!',
    },
    'more': {
      'sign': 'MORE',
      'how': 'Bring flat O hands together tapping fingertips',
      'step1': 'Make flat O shapes with both hands',
      'step2': 'Tap fingertips of both hands together',
      'difficulty': 'Easy',
      'fact': 'Gathering more things together!',
    },
    'doctor': {
      'sign': 'DOCTOR',
      'how': 'Tap wrist with two fingers like pulse check',
      'step1': 'Extend index and middle fingers together',
      'step2': 'Tap the inside of your other wrist twice',
      'difficulty': 'Medium',
      'fact': "Mimics checking a patient's pulse!",
    },
    'medicine': {
      'sign': 'MEDICINE',
      'how': 'Middle finger circles on opposite palm',
      'step1': 'Extend your middle finger pointing down',
      'step2': 'Circle it on your opposite open palm',
      'difficulty': 'Medium',
      'fact': 'Represents mixing medicine!',
    },
    'danger': {
      'sign': 'DANGER',
      'how': 'A handshape sweeps up from under other hand',
      'step1': 'Hold one hand flat, palm down',
      'step2': 'Sweep A handshape upward from under that hand',
      'difficulty': 'Medium',
      'fact': 'Rising motion = rising danger!',
    },
    'police': {
      'sign': 'POLICE',
      'how': 'C handshape tapped to badge area on chest',
      'step1': 'Make a C handshape',
      'step2': 'Tap it to the badge area of your chest twice',
      'difficulty': 'Easy',
      'fact': 'C = Cop, tapping badge location!',
    },
    'fire': {
      'sign': 'FIRE',
      'how': 'Wiggle all fingers pointing upward',
      'step1': 'Hold both hands up with fingers spread',
      'step2': 'Wiggle all fingers rapidly pointing upward',
      'difficulty': 'Easy',
      'fact': 'Fingers look like rising flames!',
    },
    'money': {
      'sign': 'MONEY',
      'how': 'Tap back of flat O hand into upturned palm',
      'step1': 'Hold one hand flat, palm facing up',
      'step2': 'Tap the back of your flat O hand into that palm',
      'difficulty': 'Easy',
      'fact': 'Like counting bills in your hand!',
    },
    'sleep': {
      'sign': 'SLEEP',
      'how': 'Pull open hand down over face closing eyes',
      'step1': 'Hold open hand above your face',
      'step2': 'Pull it down over your face while closing eyes',
      'difficulty': 'Easy',
      'fact': 'Hand closing = eyes closing for sleep!',
    },
    'happy': {
      'sign': 'HAPPY',
      'how': 'Brush open hand upward on chest twice',
      'step1': 'Place open hand flat on your chest',
      'step2': 'Brush upward on chest twice quickly',
      'difficulty': 'Easy',
      'fact': 'Lifting motion shows positive feeling!',
    },
    'sad': {
      'sign': 'SAD',
      'how': 'Pull both hands slowly down face',
      'step1': 'Hold both open hands in front of your face',
      'step2': 'Pull them slowly downward',
      'difficulty': 'Easy',
      'fact': 'Hands trace the path of tears!',
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
    'GOOD',
    'LOVE',
    'PAIN',
    'DOCTOR',
    'POLICE',
    'FIRE',
  ];

  @override
  void initState() {
    super.initState();

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _micPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _micPulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.5);
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _waveController.dispose();
    _fadeController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _toggleListening() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isListening = !_isListening;
      if (!_isListening && _spokenText.isNotEmpty) {
        _convertToSign(_spokenText);
      }
    });
  }

  void _convertToSign(String phrase) {
    final lower = phrase.toLowerCase().trim();
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
        _signDifficulty = found['difficulty']!;
      });
      if (!_recentPhrases.any((p) => p['phrase'] == phrase)) {
        setState(() {
          _recentPhrases.insert(0, {'phrase': phrase, 'sign': found!['sign']!});
          if (_recentPhrases.length > 5) _recentPhrases.removeLast();
        });
      }
    } else {
      setState(() {
        _signToShow = phrase.toUpperCase();
        _signInstruction = 'Spell it out letter by letter';
        _signDifficulty = 'Easy';
      });
    }
  }

  void _selectQuickPhrase(String phrase) {
    HapticFeedback.lightImpact();
    _convertToSign(phrase.toLowerCase());
    setState(() => _spokenText = phrase);
  }

  void _speakSign(String sign) async {
    HapticFeedback.lightImpact();
    await _tts.speak(sign);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            'Speech → Sign',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline, color: Color(0xFFB0BEC5)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sign_language,
                            color: Color(0xFF00BCD4),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'How to use',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '1. Tap the mic button and speak\n2. Or tap any quick phrase below\n3. See the sign and how to make it\n4. Practice the sign shown',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFFB0BEC5),
                              height: 1.8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00BCD4),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Got it!',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
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
                _buildMicSection(),
                const SizedBox(height: 20),
                if (_signToShow.isNotEmpty) ...[
                  _buildSignResult(),
                  const SizedBox(height: 20),
                ],
                if (_recentPhrases.isNotEmpty) ...[
                  _buildRecentPhrases(),
                  const SizedBox(height: 20),
                ],
                _buildQuickPhrases(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(1),
      ),
    );
  }

  // ── Mic Section ───────────────────────────────
  Widget _buildMicSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleListening,
          child: AnimatedBuilder(
            animation: _micPulseAnimation,
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (_isListening) ...[
                  Container(
                    width: 140 * _micPulseAnimation.value,
                    height: 140 * _micPulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00BCD4).withOpacity(0.08),
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00BCD4).withOpacity(0.12),
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
                          : [const Color(0xFF00BCD4), const Color(0xFF7C4DFF)],
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
        const SizedBox(height: 14),
        Text(
          _isListening ? 'Listening...' : 'Tap to speak',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: _isListening
                ? const Color(0xFF00BCD4)
                : const Color(0xFFB0BEC5),
          ),
        ),
        if (_isListening) ...[
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(14, (i) {
                final h = 8.0 +
                    (i % 4 == 0
                        ? 32 * _waveAnimation.value
                        : i % 4 == 1
                            ? 22 * _waveAnimation.value
                            : i % 4 == 2
                                ? 16 * _waveAnimation.value
                                : 10 * _waveAnimation.value);
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 4,
                  height: h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {
              _convertToSign('hello');
              setState(() {
                _spokenText = 'Hello';
                _isListening = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00BCD4).withOpacity(0.3),
                ),
              ),
              child: Text(
                'Say something like "Hello" or "Help"',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF6B6B6B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Sign Result ───────────────────────────────
  Widget _buildSignResult() {
    final signData = _phraseToSign[_spokenText.toLowerCase()];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.sign_language,
                    color: Color(0xFF00BCD4),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Make this sign:',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFB0BEC5),
                        ),
                      ),
                      Text(
                        _signToShow,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF69F0AE).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF69F0AE).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _signDifficulty,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF69F0AE),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF252525),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How to sign:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF00BCD4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _signInstruction,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      if (signData != null) ...[
                        const SizedBox(height: 10),
                        _buildStep('1', signData['step1']!),
                        const SizedBox(height: 6),
                        _buildStep('2', signData['step2']!),
                      ],
                    ],
                  ),
                ),
                if (signData != null && signData['fact'] != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD740).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFFFD740).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Color(0xFFFFD740),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            signData['fact']!,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFFD740),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _speakSign(_signToShow),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C4DFF).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF7C4DFF).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.go('/communicate'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF00BCD4).withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.camera_alt,
                                color: Color(0xFF00BCD4),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Practice',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF00BCD4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF00BCD4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFFB0BEC5),
            ),
          ),
        ),
      ],
    );
  }

  // ── Recent Phrases ────────────────────────────
  Widget _buildRecentPhrases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Phrases',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        ..._recentPhrases.map(
          (item) => GestureDetector(
            onTap: () => _convertToSign(item['phrase']!.toLowerCase()),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C4DFF).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Color(0xFF7C4DFF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['phrase']!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Sign: ${item['sign']}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF00BCD4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF3A3A3A),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Quick Phrases ─────────────────────────────
  Widget _buildQuickPhrases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Common Phrases',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap any phrase to see its sign',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPhrases
              .map(
                (phrase) => GestureDetector(
                  onTap: () => _selectQuickPhrase(phrase),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _signToShow == phrase
                          ? const Color(0xFF00BCD4).withOpacity(0.2)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _signToShow == phrase
                            ? const Color(0xFF00BCD4)
                            : const Color(0xFF2A2A2A),
                      ),
                    ),
                    child: Text(
                      phrase,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: _signToShow == phrase
                            ? const Color(0xFF00BCD4)
                            : const Color(0xFFB0BEC5),
                        fontWeight: _signToShow == phrase
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
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
