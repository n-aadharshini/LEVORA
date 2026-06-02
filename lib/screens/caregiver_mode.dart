import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';

// MODELS

class ReminderItem {
  final String time;
  final String label;
  final String morse;
  bool active;

  ReminderItem({
    required this.time,
    required this.label,
    required this.morse,
    this.active = true,
  });
}

// COLORS

class C {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF1A1A1A);
  static const surface2 = Color(0xFF141414);
  static const surface3 = Color(0xFF111111);
  static const border = Color(0xFF2A2A2A);
  static const border2 = Color(0xFF1E1E1E);
  static const white = Color(0xFFFFFFFF);
  static const textSec = Color(0xFFB0BEC5);
  static const textMuted = Color(0xFF555555);
  static const textDim = Color(0xFF3A3A3A);
  static const blue = Color(0xFF1565C0);
  static const blueLight = Color(0xFF42A5F5);
  static const cyan = Color(0xFF00BCD4);
  static const green = Color(0xFF69F0AE);
  static const purple = Color(0xFF7C4DFF);
  static const yellow = Color(0xFFFFC107);
  static const red = Color(0xFFFF5252);
  static const orange = Color(0xFFFF6D00);
}

// ROOT SCREEN

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            const Expanded(
              child: _UserInfoTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Mode',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: C.white,
                  ),
                ),
                Text(
                  'Safety · AI · Monitoring',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: C.textSec,
                  ),
                ),
              ],
            ),
          ),
          _AnimatedGuardianBadge(pulseController: _pulseController),
        ],
      ),
    );
  }
}

class _AnimatedGuardianBadge extends StatelessWidget {
  final AnimationController pulseController;

  const _AnimatedGuardianBadge({required this.pulseController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseController,
      builder: (_, __) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0x1A00BCD4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x3300BCD4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: 0.6 + 0.4 * pulseController.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: C.cyan,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              'ACTIVE',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: C.cyan,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// USER INFO TAB

class _UserInfoTab extends StatelessWidget {
  const _UserInfoTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _UserHero(),
          const SizedBox(height: 12),
          const _StatusRow(),
          _sectionLabel('AI Emotion Detection'),
          const _EmotionCard(),
          _sectionLabel('Live Zone Map'),
          const _MapBox(),
          _sectionLabel('AI Behaviour Insight'),
          const _AICard(),
          _sectionLabel('Caregiver Network'),
          const _NetworkRow(),
          _sectionLabel('Priority Alert Cascade'),
          const _PriorityCascade(),
          _sectionLabel('Offline Morse via Bluetooth'),
          const _BLECard(),
          _sectionLabel('Memory Reminders'),
          const _RemindersCard(),
          _sectionLabel('Weekly Safety Report'),
          const _WeeklyGrid(),
          const SizedBox(height: 12),
          const _PdfDownloadButton(),
        ],
      ),
    );
  }
}

class _UserHero extends StatefulWidget {
  const _UserHero();

  @override
  State<_UserHero> createState() => _UserHeroState();
}

class _UserHeroState extends State<_UserHero> {
  late Timer _timer;
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = _now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _time = _now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _now() {
    final n = DateTime.now();
    return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}:${n.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1628), Color(0xFF0D0A20)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x591565C0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [C.cyan, C.purple]),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    'AA',
                    style: GoogleFonts.poppins(
                      color: C.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aadharshini',
                      style: GoogleFonts.poppins(
                        color: C.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: C.cyan, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _time,
                          style: GoogleFonts.poppins(
                            color: C.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x1A69F0AE),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0x3369F0AE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: C.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Safe Zone',
                            style: GoogleFonts.poppins(
                              color: C.green,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: 'Safe',
                  label: 'ZONE',
                  valueColor: C.green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: _StatCard(value: '2m', label: 'LAST CHECK')),
              SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  value: 'Low',
                  label: 'STRESS',
                  valueColor: C.green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(child: _StatCard(value: 'On', label: 'GUARDIAN')),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: valueColor ?? C.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: C.textMuted,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _ActCard(
            icon: Icons.directions_walk_rounded,
            iconColor: C.cyan,
            label: 'ACTIVITY',
            value: 'Walking',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ActCard(
            icon: Icons.schedule_rounded,
            iconColor: C.purple,
            label: 'SCREEN TIME',
            value: '2h 14m',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ActCard(
            icon: Icons.wifi_rounded,
            iconColor: C.green,
            label: 'CONNECTION',
            value: 'Online',
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _ActCard(
            icon: Icons.notifications_active_rounded,
            iconColor: C.yellow,
            label: 'ALERTS',
            value: '2 New',
          ),
        ),
      ],
    );
  }
}

class _ActCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ActCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 2),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth,
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  color: C.textMuted,
                  fontSize: 8,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 3),
          LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              width: constraints.maxWidth,
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  color: C.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmotionCard extends StatelessWidget {
  const _EmotionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x337C4DFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.psychology_rounded, C.purple),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stress Pattern Analysis',
                    style: GoogleFonts.poppins(
                      color: C.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Learned from 14 days · On-device AI',
                    style: GoogleFonts.poppins(color: C.textSec, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _EmoChip(
                  icon: Icons.sentiment_satisfied_rounded,
                  iconColor: C.green,
                  label: 'STRESS',
                  value: 'Low',
                  ok: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _EmoChip(
                  icon: Icons.back_hand_rounded,
                  iconColor: C.green,
                  label: 'TREMOR',
                  value: 'None',
                  ok: true,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _EmoChip(
                  icon: Icons.favorite_rounded,
                  iconColor: C.yellow,
                  label: 'RHYTHM',
                  value: 'Slightly off',
                  ok: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool ok;

  const _EmoChip({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.ok,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: C.surface3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: C.textMuted,
              fontSize: 9,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ok ? C.green : C.yellow,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBox extends StatelessWidget {
  const _MapBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: C.border2),
      ),
      child: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), size: Size.infinite),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x1269F0AE),
                border: Border.all(color: const Color(0x4D69F0AE), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_rounded, color: C.green, size: 22),
                  Text(
                    'SAFE',
                    style: GoogleFonts.poppins(
                      color: C.green,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 22,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x12FF5252),
                border: Border.all(color: const Color(0x59FF5252), width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning_rounded, color: C.red, size: 14),
                  Text(
                    'ROAD',
                    style: GoogleFonts.poppins(color: C.red, fontSize: 7),
                  ),
                ],
              ),
            ),
          ),
          const Center(child: _PingDot()),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 26) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PingDot extends StatefulWidget {
  const _PingDot();

  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  late final Animation<double> _anim = Tween<double>(begin: 0.0, end: 14.0)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 11 + _anim.value,
            height: 11 + _anim.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: C.green.withOpacity(0.4 * (1 - _ctrl.value)),
            ),
          ),
          Container(
            width: 11,
            height: 11,
            decoration:
                const BoxDecoration(color: C.green, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

class _AICard extends StatelessWidget {
  const _AICard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x337C4DFF)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _iconBox(Icons.hub_rounded, C.purple),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pattern Engine',
                    style: GoogleFonts.poppins(
                      color: C.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '14 days learned · Smart filter ON',
                    style: GoogleFonts.poppins(color: C.textSec, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: C.surface3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _insightRow(
                  Icons.check_circle_rounded,
                  C.green,
                  'Normal routine detected. Reaches college by 9:15 AM — on time today.',
                ),
                const SizedBox(height: 8),
                _insightRow(
                  Icons.filter_alt_rounded,
                  C.cyan,
                  'Smart filter: 9 routine alerts suppressed. Only anomalies trigger you.',
                ),
                const SizedBox(height: 8),
                _insightRow(
                  Icons.location_on_rounded,
                  C.yellow,
                  'Unusual 4-min pause near danger zone at 6:42 PM — auto-notified.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insightRow(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: C.textSec,
              fontSize: 11,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkRow extends StatelessWidget {
  const _NetworkRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: const Row(
        children: [
          Expanded(
            child: _OrbCard(
              initials: 'MA',
              color: C.cyan,
              name: 'Mom',
              role: 'PRIMARY',
              online: true,
              primary: true,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _OrbCard(
              initials: 'RK',
              color: C.blueLight,
              name: 'Ravi',
              role: 'SECONDARY',
              online: true,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _OrbCard(
              initials: 'DP',
              color: C.purple,
              name: 'Dr. Priya',
              role: 'EMERGENCY',
              online: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbCard extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final Color color;
  final bool online;
  final bool primary;

  const _OrbCard({
    required this.initials,
    required this.color,
    required this.name,
    required this.role,
    required this.online,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: primary ? const Color(0x4D00BCD4) : C.border2,
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: online ? C.green : const Color(0xFF444444),
                    border: Border.all(color: C.surface, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: C.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            role,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: C.textMuted,
              fontSize: 9,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityCascade extends StatelessWidget {
  const _PriorityCascade();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.account_tree_rounded, C.orange),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alert Cascade Chain',
                      style: GoogleFonts.poppins(
                        color: C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'No response in 60s → escalates automatically',
                      style:
                          GoogleFonts.poppins(color: C.textSec, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _cascadeStep(
            number: '1',
            name: 'Mom',
            role: 'Primary Caregiver',
            color: C.cyan,
            time: 'Immediately',
            isLast: false,
          ),
          _cascadeStep(
            number: '2',
            name: 'Ravi',
            role: 'Secondary Caregiver',
            color: C.blueLight,
            time: 'After 60 sec',
            isLast: false,
          ),
          _cascadeStep(
            number: '3',
            name: 'Dr. Priya',
            role: 'Emergency Contact',
            color: C.purple,
            time: 'After 120 sec',
            isLast: true,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: C.orange.withOpacity(0.06),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: C.orange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    color: C.orange, size: 13),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'SOS signal triggers all contacts simultaneously, bypassing the cascade.',
                    style: GoogleFonts.poppins(
                      color: C.orange,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cascadeStep({
    required String number,
    required String name,
    required String role,
    required Color color,
    required String time,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.15),
                border: Border.all(color: color.withOpacity(0.4)),
              ),
              child: Center(
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: C.border2,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: C.surface3,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            color: C.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          role,
                          style: GoogleFonts.poppins(
                            color: C.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      time,
                      style: GoogleFonts.poppins(
                        color: color,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BLECard extends StatefulWidget {
  const _BLECard();

  @override
  State<_BLECard> createState() => _BLECardState();
}

class _BLECardState extends State<_BLECard> {
  bool _bleActive = false;
  bool _sending = false;
  String _status = 'Ready to transmit';
  String? _lastSent;

  void _toggleBLE() {
    setState(() {
      _bleActive = !_bleActive;
      _status = _bleActive ? 'BLE Connected · Range 30m' : 'Disconnected';
    });
  }

  void _sendTestSignal() async {
    if (!_bleActive) return;
    setState(() {
      _sending = true;
      _status = 'Transmitting SOS via BLE...';
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _sending = false;
        _lastSent = 'SOS · ● ● ● ▬ ▬ ▬ ● ● ●';
        _status = 'Signal delivered successfully';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _bleActive ? const Color(0x3300BCD4) : C.border2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.bluetooth_rounded, C.cyan),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Morse via BLE',
                      style: GoogleFonts.poppins(
                        color: C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Internet down? Auto-switches to BLE to relay Morse vibrations.',
                      style: GoogleFonts.poppins(
                        color: C.textSec,
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _toggleBLE,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _bleActive ? C.cyan : C.surface3,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _bleActive ? C.cyan.withOpacity(0.5) : C.border,
                    ),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: _bleActive
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _bleActive ? C.bg : C.textMuted,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: C.surface3,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: C.border2),
            ),
            child: Row(
              children: [
                Icon(
                  _bleActive
                      ? Icons.bluetooth_connected_rounded
                      : Icons.bluetooth_disabled_rounded,
                  color: _bleActive ? C.cyan : C.textMuted,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _status,
                    style: GoogleFonts.poppins(
                      color: _bleActive ? C.cyan : C.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
                if (_sending)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: C.cyan,
                    ),
                  ),
              ],
            ),
          ),
          if (_lastSent != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: C.green, size: 12),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Last sent: $_lastSent',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(color: C.green, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _bleActive ? _sendTestSignal : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: _bleActive ? C.cyan.withOpacity(0.1) : C.surface3,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: _bleActive ? C.cyan.withOpacity(0.3) : C.border2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.send_rounded,
                          color: _bleActive ? C.cyan : C.textMuted,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Send Test SOS',
                          style: GoogleFonts.poppins(
                            color: _bleActive ? C.cyan : C.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

class _RemindersCard extends StatefulWidget {
  const _RemindersCard();

  @override
  State<_RemindersCard> createState() => _RemindersCardState();
}

class _RemindersCardState extends State<_RemindersCard> {
  final List<ReminderItem> _reminders = [
    ReminderItem(time: '8:00 AM', label: 'Wake up', morse: '▬ ▬'),
    ReminderItem(time: '2:00 PM', label: 'Medicine', morse: '▬ ▬ ▬'),
    ReminderItem(time: '6:30 PM', label: 'Head home', morse: '● ▬ ●'),
  ];

  final _timeCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();
  bool _showForm = false;
  String _selectedMorse = '● ▬';

  final List<(String, String)> _morseOptions = const [
    ('Short', '● ▬'),
    ('Long', '▬ ▬ ▬'),
    ('Urgent', '● ● ● ▬ ▬ ▬'),
    ('Custom', '▬ ● ●'),
  ];

  @override
  void dispose() {
    _timeCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  void _addReminder() {
    if (_timeCtrl.text.trim().isEmpty || _labelCtrl.text.trim().isEmpty) return;

    setState(() {
      _reminders.add(
        ReminderItem(
          time: _timeCtrl.text.trim(),
          label: _labelCtrl.text.trim(),
          morse: _selectedMorse,
        ),
      );
      _timeCtrl.clear();
      _labelCtrl.clear();
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: C.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBox(Icons.vibration_rounded, C.purple),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tactile Memory Reminders',
                      style: GoogleFonts.poppins(
                        color: C.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'User feels unique vibration pattern at set times',
                      style: GoogleFonts.poppins(
                        color: C.textSec,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showForm = !_showForm),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: C.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: C.blue.withOpacity(0.3)),
                  ),
                  child: Icon(
                    _showForm ? Icons.close_rounded : Icons.add_rounded,
                    color: C.blueLight,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ..._reminders.asMap().entries.map((e) => _remItem(e.key, e.value)),
          if (_showForm) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: C.surface3,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: C.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule New Reminder',
                    style: GoogleFonts.poppins(
                      color: C.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: _inputField(_timeCtrl, 'Time (e.g. 9:00 AM)')),
                      const SizedBox(width: 8),
                      Expanded(child: _inputField(_labelCtrl, 'Label')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vibration Pattern',
                    style:
                        GoogleFonts.poppins(color: C.textMuted, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _morseOptions
                        .map(
                          (o) => GestureDetector(
                            onTap: () => setState(() => _selectedMorse = o.$2),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _selectedMorse == o.$2
                                    ? C.blue.withOpacity(0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: _selectedMorse == o.$2
                                      ? C.blueLight.withOpacity(0.5)
                                      : C.border,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    o.$1,
                                    style: GoogleFonts.poppins(
                                      color: _selectedMorse == o.$2
                                          ? C.blueLight
                                          : C.textSec,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    o.$2,
                                    style: GoogleFonts.poppins(
                                      color: C.textMuted,
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _addReminder,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: C.blue,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        'Add Reminder',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: C.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: GoogleFonts.poppins(color: C.white, fontSize: 11),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: C.textMuted, fontSize: 10),
        filled: true,
        fillColor: C.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.blue),
        ),
      ),
    );
  }

  Widget _remItem(int idx, ReminderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: C.surface3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: C.border2),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => item.active = !item.active),
            child: Icon(
              item.active
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: item.active ? C.purple : C.textMuted,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            item.time,
            style: GoogleFonts.poppins(
              color: item.active ? C.white : C.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              item.label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: item.active ? C.textSec : C.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              item.morse,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: C.textMuted,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => setState(() => _reminders.removeAt(idx)),
            child: const Icon(Icons.close_rounded, color: C.textDim, size: 14),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGrid extends StatelessWidget {
  const _WeeklyGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: const [
        _RepBlock(
          label: 'ZONES VISITED',
          value: '3',
          sub: 'Home · College · Market',
          icon: Icons.map_rounded,
          iconColor: C.cyan,
        ),
        _RepBlock(
          label: 'ANOMALIES',
          value: '2',
          sub: 'AI auto-notified',
          vc: C.yellow,
          icon: Icons.warning_amber_rounded,
          iconColor: C.yellow,
        ),
        _RepBlock(
          label: 'MESSAGES',
          value: '14',
          sub: 'Morse + text',
          icon: Icons.chat_rounded,
          iconColor: C.blueLight,
        ),
        _RepBlock(
          label: 'ALERTS FILTERED',
          value: '9',
          sub: 'Smart AI filter',
          vc: C.green,
          icon: Icons.filter_alt_rounded,
          iconColor: C.green,
        ),
      ],
    );
  }
}

class _RepBlock extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color? vc;
  final IconData icon;
  final Color iconColor;

  const _RepBlock({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    this.vc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: C.border2),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: C.textMuted,
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: vc ?? C.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  sub,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: C.textSec,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfDownloadButton extends StatefulWidget {
  const _PdfDownloadButton();

  @override
  State<_PdfDownloadButton> createState() => _PdfDownloadButtonState();
}

class _PdfDownloadButtonState extends State<_PdfDownloadButton> {
  bool _generating = false;
  String? _savedPath;

  Future<void> _generatePdf() async {
    setState(() => _generating = true);

    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Aadharshini - Weekly Safety Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text(
              'Generated: ${DateTime.now().toString().substring(0, 16)}',
              style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Summary'),
            pw.Table.fromTextArray(
              headers: ['Metric', 'Value'],
              data: [
                ['Zones Visited', '3 (Home - College - Market)'],
                ['Anomalies Detected', '2'],
                ['Alerts Filtered by AI', '9'],
                ['Messages Sent', '14 (Morse + Text)'],
                ['Screen Time', '2h 14m'],
                ['Stress Level', 'Low'],
                ['Last Check-in', '2 minutes ago'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'Caregiver Network'),
            pw.Table.fromTextArray(
              headers: ['Name', 'Role', 'Status'],
              data: [
                ['Mom', 'Primary', 'Online'],
                ['Ravi', 'Secondary', 'Online'],
                ['Dr. Priya', 'Emergency', 'Offline'],
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Header(level: 1, text: 'AI Insights'),
            pw.Bullet(
                text: 'Normal routine detected. Reaches college by 9:15 AM.'),
            pw.Bullet(text: '9 routine alerts suppressed by smart filter.'),
            pw.Bullet(
                text:
                    'Unusual 4-min pause near danger zone at 6:42 PM - notified.'),
            pw.SizedBox(height: 20),
            pw.Text(
              'This report was auto-generated by the Guardian safety system.',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/safety_report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File(path);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        setState(() {
          _generating = false;
          _savedPath = path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: C.surface,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: C.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PDF saved to Documents',
                    style: GoogleFonts.poppins(color: C.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: C.surface,
            content: Text(
              'Could not generate PDF: $e',
              style: GoogleFonts.poppins(color: C.red, fontSize: 11),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _generating ? null : _generatePdf,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _savedPath != null ? C.green.withOpacity(0.08) : C.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _savedPath != null ? C.green.withOpacity(0.3) : C.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _generating
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: C.blueLight,
                    ),
                  )
                : Icon(
                    _savedPath != null
                        ? Icons.check_circle_rounded
                        : Icons.picture_as_pdf_rounded,
                    color: _savedPath != null ? C.green : C.textSec,
                    size: 16,
                  ),
            const SizedBox(width: 8),
            Text(
              _generating
                  ? 'Generating PDF...'
                  : _savedPath != null
                      ? 'PDF Saved to Documents'
                      : 'Download Weekly PDF Report',
              style: GoogleFonts.poppins(
                color: _savedPath != null ? C.green : C.textSec,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// SHARED HELPERS

Widget _sectionLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 10),
    child: Row(
      children: [
        Text(
          text.toUpperCase(),
          style: GoogleFonts.poppins(
            color: C.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Divider(
            color: Color(0xFF1A1A1A),
            thickness: 1,
            height: 1,
          ),
        ),
      ],
    ),
  );
}

Widget _iconBox(IconData icon, Color color) {
  return Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Center(child: Icon(icon, color: color, size: 16)),
  );
}
