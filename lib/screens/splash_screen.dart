import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _lineController;
  late AnimationController _bottomController;
  late AnimationController _exitController;

  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowPulse;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _lineScale;
  late Animation<double> _bottomOpacity;
  late Animation<double> _exitOpacity;

  // SVG path drawing animations
  late AnimationController _pathController;
  late Animation<double> _leftHandPath;
  late Animation<double> _rightHandPath;
  late Animation<double> _fingersPath;
  late Animation<double> _heartPath;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    // Logo scale + opacity
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    // Glow pulse
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // SVG paths
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _leftHandPath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pathController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _rightHandPath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pathController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _fingersPath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pathController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _heartPath = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pathController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Title
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    // Tagline
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lineController, curve: Curves.easeOut));
    _lineScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _lineController, curve: Curves.easeOut));

    // Bottom text
    _bottomController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bottomOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeIn));
  }

  Future<void> _startSequence() async {
    // Step 1: Logo appears
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();
    _pathController.forward();

    // Step 2: Title slides up
    await Future.delayed(const Duration(milliseconds: 1000));
    _textController.forward();

    // Step 3: Tagline + line
    await Future.delayed(const Duration(milliseconds: 400));
    _lineController.forward();

    // Step 4: Bottom text
    await Future.delayed(const Duration(milliseconds: 400));
    _bottomController.forward();

    // Step 5: Wait then exit
    await Future.delayed(const Duration(milliseconds: 1000));
    _exitController.forward();

    // Step 6: Navigate
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) context.go('/home');
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _pathController.dispose();
    _textController.dispose();
    _lineController.dispose();
    _bottomController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _exitOpacity,
      builder: (context, child) =>
          Opacity(opacity: _exitOpacity.value, child: child),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [
            // Main content center
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with glow
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _glowController,
                      _pathController,
                    ]),
                    builder: (context, child) => Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow ring
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00BCD4,
                                    ).withOpacity(_glowPulse.value),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            // Outer ring
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFF00BCD4,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                            // SVG hand drawing
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CustomPaint(
                                painter: HandLogoPainter(
                                  leftHand: _leftHandPath.value,
                                  rightHand: _rightHandPath.value,
                                  fingers: _fingersPath.value,
                                  heart: _heartPath.value,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) => Opacity(
                      opacity: _titleOpacity.value,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Text(
                          'LEVORA',
                          style: GoogleFonts.poppins(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 10,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  AnimatedBuilder(
                    animation: _lineController,
                    builder: (context, child) => Opacity(
                      opacity: _taglineOpacity.value,
                      child: Column(
                        children: [
                          Text(
                            'Every Hand Has a Voice',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFFB0BEC5),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Teal line
                          Transform.scale(
                            scaleX: _lineScale.value,
                            child: Container(
                              width: 64,
                              height: 2,
                              color: const Color(0xFF00BCD4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom text
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _bottomController,
                builder: (context, child) => Opacity(
                  opacity: _bottomOpacity.value,
                  child: Column(
                    children: [
                      Text(
                        'Designed for 5 Million Deaf Indians',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF6B6B6B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hand Logo Painter ────────────────────────
class HandLogoPainter extends CustomPainter {
  final double leftHand;
  final double rightHand;
  final double fingers;
  final double heart;

  HandLogoPainter({
    required this.leftHand,
    required this.rightHand,
    required this.fingers,
    required this.heart,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint tealPaint = Paint()
      ..color = const Color(0xFF00BCD4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // ── Left hand ──────────────────────────
    if (leftHand > 0) {
      final leftPath1 = Path()
        ..moveTo(w * 0.25, h * 0.65)
        ..cubicTo(w * 0.25, h * 0.45, w * 0.35, h * 0.30, w * 0.50, h * 0.20);
      _drawPartialPath(canvas, leftPath1, paint, leftHand);

      final leftPath2 = Path()
        ..moveTo(w * 0.30, h * 0.70)
        ..cubicTo(w * 0.20, h * 0.55, w * 0.20, h * 0.40, w * 0.35, h * 0.28);
      _drawPartialPath(canvas, leftPath2, paint, leftHand);
    }

    // ── Right hand ─────────────────────────
    if (rightHand > 0) {
      final rightPath1 = Path()
        ..moveTo(w * 0.75, h * 0.65)
        ..cubicTo(w * 0.75, h * 0.45, w * 0.65, h * 0.30, w * 0.50, h * 0.20);
      _drawPartialPath(canvas, rightPath1, paint, rightHand);

      final rightPath2 = Path()
        ..moveTo(w * 0.70, h * 0.70)
        ..cubicTo(w * 0.80, h * 0.55, w * 0.80, h * 0.40, w * 0.65, h * 0.28);
      _drawPartialPath(canvas, rightPath2, paint, rightHand);
    }

    // ── Fingers left ───────────────────────
    if (fingers > 0) {
      final leftFingers = [
        [0.28, 0.42, 0.22, 0.32],
        [0.33, 0.35, 0.28, 0.24],
        [0.40, 0.30, 0.38, 0.18],
        [0.47, 0.27, 0.48, 0.15],
      ];
      for (final f in leftFingers) {
        final p = Path()
          ..moveTo(w * f[0], h * f[1])
          ..lineTo(w * f[2], h * f[3]);
        _drawPartialPath(canvas, p, tealPaint, fingers);
      }

      // Fingers right
      final rightFingers = [
        [0.72, 0.42, 0.78, 0.32],
        [0.67, 0.35, 0.72, 0.24],
        [0.60, 0.30, 0.62, 0.18],
        [0.53, 0.27, 0.52, 0.15],
      ];
      for (final f in rightFingers) {
        final p = Path()
          ..moveTo(w * f[0], h * f[1])
          ..lineTo(w * f[2], h * f[3]);
        _drawPartialPath(canvas, p, tealPaint, fingers);
      }
    }

    // ── Heart bottom ───────────────────────
    if (heart > 0) {
      final heartPath = Path()
        ..moveTo(w * 0.30, h * 0.70)
        ..cubicTo(w * 0.30, h * 0.82, w * 0.50, h * 0.95, w * 0.50, h * 0.95)
        ..cubicTo(w * 0.50, h * 0.95, w * 0.70, h * 0.82, w * 0.70, h * 0.70);

      final heartPaint = Paint()
        ..color = const Color(0xFF00BCD4)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      _drawPartialPath(canvas, heartPath, heartPaint, heart);
    }
  }

  void _drawPartialPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double progress,
  ) {
    if (progress <= 0) return;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      final double length = metric.length * progress;
      final Path extracted = metric.extractPath(0, length);
      canvas.drawPath(extracted, paint);
    }
  }

  @override
  bool shouldRepaint(HandLogoPainter oldDelegate) =>
      oldDelegate.leftHand != leftHand ||
      oldDelegate.rightHand != rightHand ||
      oldDelegate.fingers != fingers ||
      oldDelegate.heart != heart;
}
