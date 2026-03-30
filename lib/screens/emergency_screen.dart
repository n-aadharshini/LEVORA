import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});
  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _sosHoldController;
  late Animation<double> _sosHoldAnimation;
  late AnimationController _alarmWaveController;
  late Animation<double> _alarmWaveAnimation;

  final FlutterTts _tts = FlutterTts();

  bool _isHoldingSOS = false;
  bool _bystanderActive = false;

  // ── Voice Alarm ───────────────────────────────
  bool _voiceAlarmActive = false;
  Timer? _voiceAlarmTimer;

  // ── Location ──────────────────────────────────
  Position? _currentPosition;

  // ── Profile ───────────────────────────────────
  String _userName = 'Aadharshini';
  String _bloodType = 'B+';
  String _allergies = 'None';
  String _medicalConditions = 'Deaf/Mute';
  String _contactName = 'Mom';
  String _contactPhone = '+91 98765 43210';
  String _contactRelation = 'Mother';

  String _consciousStatus = '';
  String _painStatus = '';
  String _needStatus = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _fetchLocation();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sosHoldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _sosHoldAnimation = CurvedAnimation(
      parent: _sosHoldController,
      curve: Curves.easeInOut,
    );

    // Wave throb for active alarm bar
    _alarmWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _alarmWaveAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _alarmWaveController, curve: Curves.easeInOut),
    );

    _tts.setLanguage('en-IN');
    _tts.setSpeechRate(0.5);
    _tts.setVolume(1.0);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sosHoldController.dispose();
    _alarmWaveController.dispose();
    _voiceAlarmTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  // ── Load Profile ──────────────────────────────
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('name') ?? 'Aadharshini';
        _bloodType = prefs.getString('bloodType') ?? 'B+';
        _allergies = prefs.getString('allergies') ?? 'None';
        _medicalConditions = prefs.getString('medical') ?? 'Deaf/Mute';
        _contactName = prefs.getString('contactName') ?? 'Mom';
        _contactPhone = prefs.getString('contactPhone') ?? '+91 98765 43210';
        _contactRelation = prefs.getString('contactRelation') ?? 'Mother';
      });
    }
  }

  // ── Location ──────────────────────────────────
  Future<void> _fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) setState(() => _currentPosition = pos);
    } catch (_) {}
  }

  Future<void> _openGoogleMaps() async {
    if (_currentPosition == null) await _fetchLocation();
    final pos = _currentPosition;
    if (pos == null) {
      _speak('Could not get location. Please check GPS.');
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── TTS ───────────────────────────────────────
  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  // ── Direct Dial ───────────────────────────────
  Future<void> _callNumber(String number) async {
    final clean = number.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── SOS ───────────────────────────────────────
  void _startSOSHold() {
    setState(() => _isHoldingSOS = true);
    _sosHoldController.forward();
    HapticFeedback.heavyImpact();
  }

  void _cancelSOSHold() {
    setState(() => _isHoldingSOS = false);
    _sosHoldController.reset();
  }

  Future<void> _triggerSOS() async {
    HapticFeedback.heavyImpact();
    _sosHoldController.reset();
    setState(() => _isHoldingSOS = false);

    final pos = _currentPosition;
    String locationText = 'Location unavailable';
    if (pos != null) {
      locationText =
          'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
    }

    final smsBody = Uri.encodeComponent(
      '🚨 SOS EMERGENCY 🚨\n'
      'I need immediate help!\n'
      'I am Deaf/Hard of Hearing.\n'
      'My location: $locationText\n'
      'Please respond or call 112.',
    );

    if (_contactPhone.isNotEmpty) {
      final cleanNumber = _contactPhone.replaceAll(' ', '');
      final smsUri = Uri.parse('sms:$cleanNumber?body=$smsBody');
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      }
    }

    if (mounted) _showSOSConfirmation();
  }

  void _showSOSConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF69F0AE).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF69F0AE), size: 32),
              ),
              const SizedBox(height: 16),
              Text('SOS Sent!',
                  style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 8),
              Text('SMS sent to $_contactName',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFFB0BEC5))),
              Text('Location shared',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: const Color(0xFFB0BEC5))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252525),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFFF5252).withOpacity(0.5)),
                        ),
                        child: Text('Cancel SOS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: const Color(0xFFFF5252))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _callNumber(_contactPhone);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('Call Contact',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bystander ─────────────────────────────────
  void _activateBystander() {
    setState(() => _bystanderActive = true);
    _speak(
      'I cannot speak. I am having a medical emergency. '
      'Please look at my screen for instructions.',
    );
    HapticFeedback.heavyImpact();
  }

  void _deactivateBystander() {
    setState(() {
      _bystanderActive = false;
      _consciousStatus = '';
      _painStatus = '';
      _needStatus = '';
    });
    _tts.stop();
  }

  // ── Voice Alarm ───────────────────────────────
  Future<void> _toggleVoiceAlarm() async {
    if (_voiceAlarmActive) {
      _voiceAlarmTimer?.cancel();
      _alarmWaveController.stop();
      _alarmWaveController.reset();
      await _tts.stop();
      if (mounted) setState(() => _voiceAlarmActive = false);
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
      if (mounted) setState(() => _voiceAlarmActive = true);
      _alarmWaveController.repeat(reverse: true);
      _runHelpLoop();
    }
  }

  Future<void> _runHelpLoop() async {
    if (!_voiceAlarmActive || !mounted) return;
    await _tts.speak('Help me! Help me! Please help me! I need help!');
    _voiceAlarmTimer = Timer(const Duration(milliseconds: 3000), () {
      if (_voiceAlarmActive && mounted) _runHelpLoop();
    });
  }

  // ── Speak status ──────────────────────────────
  void _speakStatus(String text) => _speak(text);

  void _speakAllStatuses() {
    final parts = <String>[];
    if (_consciousStatus == 'conscious') parts.add('I am conscious.');
    if (_consciousStatus == 'losing') parts.add('I am losing consciousness.');
    if (_painStatus == 'pain') parts.add('I am in pain.');
    if (_painStatus == 'nopain') parts.add('I am not in pain.');
    if (_needStatus == 'water') parts.add('I need water.');
    if (_needStatus == 'medicine') parts.add('I need medicine urgently.');

    final text = parts.isEmpty
        ? 'No status selected yet. Please tap a status button.'
        : parts.join(' ');
    _speak(text);
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_bystanderActive) return _buildBystanderBridge();

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Emergency SOS',
            style: GoogleFonts.poppins(
              color: const Color(0xFFFF5252),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.shield_outlined, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatusRow(),
              const SizedBox(height: 20),
              _buildContactCard(),
              const SizedBox(height: 24),
              _buildQuickAlerts(),
              const SizedBox(height: 24),
              _buildSOSButton(),
              const SizedBox(height: 24),
              _buildBystanderCard(),
              const SizedBox(height: 12),
              _buildVoiceAlarmBar(),
              const SizedBox(height: 80),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNav(3),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // VOICE ALARM BAR  —  "Cry for Help"
  // ─────────────────────────────────────────────
  Widget _buildVoiceAlarmBar() {
    return AnimatedBuilder(
      animation: _alarmWaveAnimation,
      builder: (_, __) => Transform.scale(
        scale: _voiceAlarmActive ? _alarmWaveAnimation.value : 1.0,
        child: GestureDetector(
          onTap: _toggleVoiceAlarm,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: _voiceAlarmActive
                  ? const Color(0xFFFF1744)
                  : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _voiceAlarmActive
                    ? const Color(0xFFFF1744)
                    : const Color(0xFFFF1744).withOpacity(0.45),
                width: _voiceAlarmActive ? 2.5 : 1.5,
              ),
              boxShadow: _voiceAlarmActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFFFF1744).withOpacity(0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _voiceAlarmActive
                      ? const Icon(Icons.graphic_eq,
                          key: ValueKey('on'), color: Colors.white, size: 30)
                      : const Icon(Icons.mic,
                          key: ValueKey('off'),
                          color: Color(0xFFFF1744),
                          size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _voiceAlarmActive
                            ? 'Screaming for Help...'
                            : 'Cry for Help',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _voiceAlarmActive
                            ? 'Saying "Help me!" on loop — tap to stop'
                            : 'Tap to shout "Help me!" continuously',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _voiceAlarmActive
                              ? Colors.white70
                              : const Color(0xFFB0BEC5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _voiceAlarmActive
                        ? Colors.white
                        : const Color(0xFFFF1744),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _voiceAlarmActive ? 'STOP' : 'START',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: _voiceAlarmActive
                          ? const Color(0xFFFF1744)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATUS ROW
  // ─────────────────────────────────────────────
  Widget _buildStatusRow() {
    return Row(
      children: [
        _buildStatusChip(
            Icons.gps_fixed, 'Location ready', const Color(0xFF69F0AE)),
        const SizedBox(width: 8),
        _buildStatusChip(Icons.sms, 'SMS ready', const Color(0xFF00BCD4)),
        const SizedBox(width: 8),
        _buildStatusChip(
            Icons.contacts, 'Contact saved', const Color(0xFF7C4DFF)),
      ],
    );
  }

  Widget _buildStatusChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: GoogleFonts.poppins(fontSize: 10, color: color),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CONTACT CARD
  // ─────────────────────────────────────────────
  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Color(0xFFFF5252), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_contactName,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(_contactRelation,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: const Color(0xFFB0BEC5))),
                Text(_contactPhone,
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: const Color(0xFF00BCD4))),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3A3A3A)),
              ),
              child: Text('Edit',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: const Color(0xFF00BCD4))),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // QUICK ALERTS
  // ─────────────────────────────────────────────
  Widget _buildQuickAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Alerts',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildQuickAlertButton(
                Icons.sign_language,
                'HELP Sign',
                const Color(0xFF00BCD4),
                onTap: () => _speak('Help! I need help! Please assist me!'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAlertButton(
                Icons.my_location,
                'Share Location',
                const Color(0xFF69F0AE),
                onTap: _openGoogleMaps,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickAlertButton(
                Icons.phone,
                'Call Contact',
                const Color(0xFF7C4DFF),
                onTap: () => _callNumber(_contactPhone),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAlertButton(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // SOS BUTTON
  // ─────────────────────────────────────────────
  Widget _buildSOSButton() {
    return Column(
      children: [
        Text('Hold for Emergency SOS',
            style: GoogleFonts.poppins(
                fontSize: 14, color: const Color(0xFFB0BEC5))),
        const SizedBox(height: 20),
        GestureDetector(
          onLongPressStart: (_) => _startSOSHold(),
          onLongPressEnd: (_) {
            if (_sosHoldController.value >= 0.99) {
              _triggerSOS();
            } else {
              _cancelSOSHold();
            }
          },
          child: AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _sosHoldAnimation]),
            builder: (context, child) => Stack(
              alignment: Alignment.center,
              children: [
                if (!_isHoldingSOS)
                  Container(
                    width: 160 + (_pulseAnimation.value * 20),
                    height: 160 + (_pulseAnimation.value * 20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF5252)
                            .withOpacity(_pulseAnimation.value * 0.4),
                        width: 2,
                      ),
                    ),
                  ),
                if (_isHoldingSOS)
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: CircularProgressIndicator(
                      value: _sosHoldAnimation.value,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFFFF5252).withOpacity(0.2),
                      color: const Color(0xFFFF5252),
                    ),
                  ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5252).withOpacity(
                          _isHoldingSOS ? 0.6 : _pulseAnimation.value * 0.4,
                        ),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emergency,
                          color: Colors.white, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        _isHoldingSOS ? 'RELEASING...' : 'SOS',
                        style: GoogleFonts.poppins(
                          fontSize: _isHoldingSOS ? 12 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (!_isHoldingSOS)
                        Text('Hold 2 sec',
                            style: GoogleFonts.poppins(
                                fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  // BYSTANDER CARD  (main screen entry point)
  // ─────────────────────────────────────────────
  Widget _buildBystanderCard() {
    return GestureDetector(
      onTap: _activateBystander,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.group, color: Color(0xFF7C4DFF), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bystander Bridge',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text('Show emergency info to helpers',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFFB0BEC5))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Activate',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BYSTANDER BRIDGE  (full-screen view)
  // ─────────────────────────────────────────────
  Widget _buildBystanderBridge() {
    return WillPopScope(
      onWillPop: () async {
        _deactivateBystander();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFB71C1C),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('EMERGENCY',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onLongPress: _deactivateBystander,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Hold to Exit',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildBCard1(),
                      const SizedBox(height: 12),
                      _buildBCard2(),
                      const SizedBox(height: 12),
                      _buildBCard3(),
                      const SizedBox(height: 12),
                      _buildBCard4(),
                      const SizedBox(height: 12),
                      _buildBCard5(),
                      const SizedBox(height: 12),
                      _buildBCard6(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card 1 — I Cannot Speak
  Widget _buildBCard1() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('I CANNOT SPEAK',
              style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Please help me. I am deaf/mute.',
              style: GoogleFonts.poppins(
                  fontSize: 16, color: Colors.white.withOpacity(0.9)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Card 2 — Call 112 (direct dial)
  Widget _buildBCard2() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text('Please call emergency services',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _callNumber('112'),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call, color: Color(0xFFB71C1C), size: 22),
                  const SizedBox(width: 8),
                  Text('CALL 112 NOW',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 3 — My Info
  Widget _buildBCard3() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('My Information',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', _userName),
          _buildInfoRow('Blood Type', _bloodType),
          _buildInfoRow('Allergies', _allergies),
          _buildInfoRow('Medical', _medicalConditions),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: Colors.white.withOpacity(0.6))),
          ),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Card 4 — My Status (speakable)
  Widget _buildBCard4() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My Current Status',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const Spacer(),
              // Speak all statuses button
              GestureDetector(
                onTap: _speakAllStatuses,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_up,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text('Speak All',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap any button — it speaks that status aloud',
              style: GoogleFonts.poppins(
                  fontSize: 10, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  'I AM\nCONSCIOUS',
                  _consciousStatus == 'conscious',
                  () {
                    setState(() => _consciousStatus = 'conscious');
                    _speakStatus('I am conscious.');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  'LOSING\nCONSCIOUSNESS',
                  _consciousStatus == 'losing',
                  () {
                    setState(() => _consciousStatus = 'losing');
                    _speakStatus(
                        'I am losing consciousness. Please help immediately!');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  'I AM\nIN PAIN',
                  _painStatus == 'pain',
                  () {
                    setState(() => _painStatus = 'pain');
                    _speakStatus('I am in pain. Please help me!');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  'NOT\nIN PAIN',
                  _painStatus == 'nopain',
                  () {
                    setState(() => _painStatus = 'nopain');
                    _speakStatus('I am not in pain right now.');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  'NEED\nWATER',
                  _needStatus == 'water',
                  () {
                    setState(() => _needStatus = 'water');
                    _speakStatus('I need water please.');
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusButton(
                  'NEED\nMEDICINE',
                  _needStatus == 'medicine',
                  () {
                    setState(() => _needStatus = 'medicine');
                    _speakStatus('I need medicine urgently!');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withOpacity(isSelected ? 1 : 0.3)),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFFB71C1C) : Colors.white)),
      ),
    );
  }

  // Card 5 — Location (opens Google Maps)
  Widget _buildBCard5() {
    final pos = _currentPosition;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('My Location',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pos != null
                ? '${pos.latitude.toStringAsFixed(5)}° N, '
                    '${pos.longitude.toStringAsFixed(5)}° E'
                : 'Fetching GPS coordinates...',
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _openGoogleMaps,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.map, color: Color(0xFFB71C1C), size: 20),
                  const SizedBox(width: 8),
                  Text('OPEN IN MAPS',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card 6 — Emergency Contact (direct dial)
  Widget _buildBCard6() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('Emergency Contact',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Text('$_contactName ($_contactRelation)',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
          Text(_contactPhone,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _callNumber(_contactPhone),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.call, color: Color(0xFFB71C1C), size: 22),
                  const SizedBox(width: 8),
                  Text('CALL NOW',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFB71C1C))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────
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
          _buildNavItem(Icons.home_outlined, 'Home', activeIndex == 0,
              () => context.go('/home')),
          _buildNavItem(Icons.sign_language_outlined, 'Sign', activeIndex == 1,
              () => context.go('/communicate')),
          _buildNavItem(Icons.menu_book_outlined, 'Learn', activeIndex == 2,
              () => context.go('/learn')),
          _buildNavItem(
              Icons.emergency_outlined, 'SOS', activeIndex == 3, () {},
              color: const Color(0xFFFF5252)),
          _buildNavItem(Icons.person_outline, 'Profile', activeIndex == 4,
              () => context.go('/profile')),
        ],
      ),
    );
  }

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
            Icon(icon,
                color: isActive ? activeColor : const Color(0xFF6B6B6B),
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isActive ? activeColor : const Color(0xFF6B6B6B),
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal)),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 4 : 0,
              height: isActive ? 4 : 0,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: activeColor),
            ),
          ],
        ),
      ),
    );
  }
}
