import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _name = 'Aadharshini';
  String _bloodType = 'B+';
  String _allergies = 'None';
  String _medical = 'Deaf/Mute';
  String _contactName = 'Mom';
  String _contactPhone = '+91 98765 43210';
  String _contactRelation = 'Mother';
  String _ttsLanguage = 'English';
  double _ttsSpeed = 0.5;
  double _vibrationIntensity = 0.8;
  bool _notifications = true;

  int _streak = 5;
  int _xp = 240;
  int _signsLearned = 12;
  String _memberSince = 'March 2026';

  final FlutterTts _tts = FlutterTts();

  final List<Map<String, dynamic>> _achievements = [
    {
      'title': 'First Sign',
      'desc': 'Detected your first sign',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD740),
      'earned': true,
    },
    {
      'title': '3 Day Streak',
      'desc': 'Signed 3 days in a row',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'earned': true,
    },
    {
      'title': '10 Signs Learned',
      'desc': 'Learned 10 different signs',
      'icon': Icons.school,
      'color': const Color(0xFF00BCD4),
      'earned': true,
    },
    {
      'title': 'Emergency Ready',
      'desc': 'Set up SOS contact',
      'icon': Icons.favorite,
      'color': const Color(0xFFFF5252),
      'earned': true,
    },
    {
      'title': 'Caregiver Connected',
      'desc': 'Connected with a caregiver',
      'icon': Icons.group,
      'color': const Color(0xFF7C4DFF),
      'earned': false,
    },
    {
      'title': '30 Day Streak',
      'desc': 'Sign for 30 days straight',
      'icon': Icons.star,
      'color': Colors.amber,
      'earned': false,
    },
    {
      'title': 'Story Master',
      'desc': 'Complete all 5 stories',
      'icon': Icons.auto_stories,
      'color': const Color(0xFF9C27B0),
      'earned': false,
    },
    {
      'title': 'Speed Signer',
      'desc': 'Sign 10 words in 60 seconds',
      'icon': Icons.speed,
      'color': const Color(0xFF4CAF50),
      'earned': false,
    },
  ];

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
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _name = prefs.getString('name') ?? 'Aadharshini';
        _bloodType = prefs.getString('bloodType') ?? 'B+';
        _allergies = prefs.getString('allergies') ?? 'None';
        _medical = prefs.getString('medical') ?? 'Deaf/Mute';
        _contactName = prefs.getString('contactName') ?? 'Mom';
        _contactPhone = prefs.getString('contactPhone') ?? '+91 98765 43210';
        _contactRelation = prefs.getString('contactRelation') ?? 'Mother';
        _streak = prefs.getInt('streak') ?? 5;
        _xp = prefs.getInt('xp') ?? 240;
        _signsLearned = prefs.getStringList('learned')?.length ?? 12;
        _notifications = prefs.getBool('notifications') ?? true;
        _ttsSpeed = prefs.getDouble('ttsSpeed') ?? 0.5;
        _vibrationIntensity = prefs.getDouble('vibration') ?? 0.8;
      });
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _name);
    await prefs.setString('bloodType', _bloodType);
    await prefs.setString('allergies', _allergies);
    await prefs.setString('medical', _medical);
    await prefs.setString('contactName', _contactName);
    await prefs.setString('contactPhone', _contactPhone);
    await prefs.setString('contactRelation', _contactRelation);
    await prefs.setBool('notifications', _notifications);
    await prefs.setDouble('ttsSpeed', _ttsSpeed);
    await prefs.setDouble('vibration', _vibrationIntensity);
  }

  void _showEditDialog(
    String field,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit $field',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF252525),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3A3A3A)),
                ),
                child: TextField(
                  controller: controller,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                  autofocus: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter $field',
                    hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ),
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
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFFB0BEC5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        onSave(controller.text);
                        _saveProfile();
                        Navigator.pop(context);
                        HapticFeedback.lightImpact();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Save',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

  @override
  void dispose() {
    _fadeController.dispose();
    _tts.stop();
    super.dispose();
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF00BCD4)),
              onPressed: () => _showEditDialog(
                'Name',
                _name,
                (v) => setState(() => _name = v),
              ),
            ),
          ],
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTopSection(),
                const SizedBox(height: 20),
                _buildStatsSection(),
                const SizedBox(height: 20),
                _buildEmergencyInfo(),
                const SizedBox(height: 20),
                _buildSettings(),
                const SizedBox(height: 20),
                _buildAchievements(),
                const SizedBox(height: 20),
                _buildLogout(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(4),
      ),
    );
  }

  // ── Top Section ───────────────────────────────
  Widget _buildTopSection() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF7C4DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  _name.isNotEmpty ? _name.substring(0, 2).toUpperCase() : 'AA',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showEditDialog(
                  'Name',
                  _name,
                  (v) => setState(() => _name = v),
                ),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0A0A0A),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _name,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00BCD4).withOpacity(0.3)),
          ),
          child: Text(
            'Deaf/Mute User',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF00BCD4),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Member since $_memberSince',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  // ── Stats Section ─────────────────────────────
  Widget _buildStatsSection() {
    return Row(
      children: [
        _buildStatCard(
          Icons.local_fire_department,
          Colors.orange,
          '$_streak',
          'Day Streak',
        ),
        const SizedBox(width: 10),
        _buildStatCard(Icons.star_outline, Colors.amber, '$_xp', 'Total XP'),
        const SizedBox(width: 10),
        _buildStatCard(
          Icons.check_circle_outline,
          const Color(0xFF69F0AE),
          '$_signsLearned',
          'Signs Learned',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Emergency Info ────────────────────────────
  Widget _buildEmergencyInfo() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.emergency, color: Color(0xFFFF5252), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Emergency Information',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  'Shown in SOS',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          _buildInfoTile(
            'Full Name',
            _name,
            Icons.person,
            () => _showEditDialog(
              'Name',
              _name,
              (v) => setState(() => _name = v),
            ),
          ),
          _buildInfoTile(
            'Blood Type',
            _bloodType,
            Icons.bloodtype,
            () => _showEditDialog(
              'Blood Type',
              _bloodType,
              (v) => setState(() => _bloodType = v),
            ),
          ),
          _buildInfoTile(
            'Allergies',
            _allergies,
            Icons.medical_information,
            () => _showEditDialog(
              'Allergies',
              _allergies,
              (v) => setState(() => _allergies = v),
            ),
          ),
          _buildInfoTile(
            'Medical Conditions',
            _medical,
            Icons.health_and_safety,
            () => _showEditDialog(
              'Medical Conditions',
              _medical,
              (v) => setState(() => _medical = v),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.contacts, color: Color(0xFF7C4DFF), size: 18),
                const SizedBox(width: 8),
                Text(
                  'Emergency Contact',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          _buildInfoTile(
            'Contact Name',
            _contactName,
            Icons.person_outline,
            () => _showEditDialog(
              'Contact Name',
              _contactName,
              (v) => setState(() => _contactName = v),
            ),
          ),
          _buildInfoTile(
            'Phone Number',
            _contactPhone,
            Icons.phone,
            () => _showEditDialog(
              'Phone Number',
              _contactPhone,
              (v) => setState(() => _contactPhone = v),
            ),
          ),
          _buildInfoTile(
            'Relation',
            _contactRelation,
            Icons.family_restroom,
            () => _showEditDialog(
              'Relation',
              _contactRelation,
              (v) => setState(() => _contactRelation = v),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    VoidCallback onEdit,
  ) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF252525),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFB0BEC5), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Color(0xFF3A3A3A), size: 16),
          ],
        ),
      ),
    );
  }

  // ── Settings ──────────────────────────────────
  Widget _buildSettings() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF00BCD4),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),

          // TTS Language
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.volume_up, color: Color(0xFFB0BEC5), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Voice Language',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final langs = ['English', 'Tamil', 'Hindi'];
                    final idx = langs.indexOf(_ttsLanguage);
                    setState(
                      () => _ttsLanguage = langs[(idx + 1) % langs.length],
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _ttsLanguage,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Speech Rate
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speed, color: Color(0xFFB0BEC5), size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Speech Rate',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _ttsSpeed < 0.4
                          ? 'Slow'
                          : _ttsSpeed < 0.7
                          ? 'Normal'
                          : 'Fast',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF00BCD4),
                    inactiveTrackColor: const Color(0xFF2A2A2A),
                    thumbColor: const Color(0xFF00BCD4),
                    overlayColor: const Color(0xFF00BCD4).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _ttsSpeed,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) {
                      setState(() => _ttsSpeed = v);
                      _tts.setSpeechRate(v);
                    },
                    onChangeEnd: (_) => _saveProfile(),
                  ),
                ),
              ],
            ),
          ),

          // Vibration
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.vibration,
                      color: Color(0xFFB0BEC5),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Vibration Intensity',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _vibrationIntensity < 0.4
                          ? 'Low'
                          : _vibrationIntensity < 0.7
                          ? 'Medium'
                          : 'High',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7C4DFF),
                      ),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF7C4DFF),
                    inactiveTrackColor: const Color(0xFF2A2A2A),
                    thumbColor: const Color(0xFF7C4DFF),
                    overlayColor: const Color(0xFF7C4DFF).withOpacity(0.2),
                  ),
                  child: Slider(
                    value: _vibrationIntensity,
                    min: 0.1,
                    max: 1.0,
                    onChanged: (v) => setState(() => _vibrationIntensity = v),
                    onChangeEnd: (_) => _saveProfile(),
                  ),
                ),
              ],
            ),
          ),

          // Notifications
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFFB0BEC5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                Switch(
                  value: _notifications,
                  onChanged: (v) {
                    setState(() => _notifications = v);
                    _saveProfile();
                    HapticFeedback.lightImpact();
                  },
                  activeColor: const Color(0xFF00BCD4),
                  inactiveThumbColor: const Color(0xFF6B6B6B),
                  inactiveTrackColor: const Color(0xFF2A2A2A),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Achievements ──────────────────────────────
  Widget _buildAchievements() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_achievements.where((a) => a['earned']).length}/${_achievements.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _achievements.length,
            itemBuilder: (context, i) {
              final a = _achievements[i];
              final earned = a['earned'] as bool;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF1A1A1A),
                      content: Text(
                        '${a['title']}: ${a['desc']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: earned
                            ? (a['color'] as Color).withOpacity(0.15)
                            : const Color(0xFF252525),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: earned
                              ? (a['color'] as Color).withOpacity(0.4)
                              : const Color(0xFF3A3A3A),
                        ),
                      ),
                      child: Icon(
                        a['icon'] as IconData,
                        color: earned
                            ? a['color'] as Color
                            : const Color(0xFF3A3A3A),
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a['title'],
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: earned ? Colors.white : const Color(0xFF3A3A3A),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Logout ────────────────────────────────────
  Widget _buildLogout() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
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
                  const Icon(Icons.logout, color: Color(0xFFFF5252), size: 36),
                  const SizedBox(height: 12),
                  Text(
                    'Sign Out?',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Are you sure you want to sign out?',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFFB0BEC5),
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                            ),
                            child: Text(
                              'Cancel',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFFB0BEC5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            context.go('/');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Sign Out',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, color: Color(0xFFFF5252), size: 20),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: const Color(0xFFFF5252),
                fontWeight: FontWeight.w600,
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
            () {},
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
