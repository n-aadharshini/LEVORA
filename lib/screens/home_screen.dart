import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _cardController;
  late Animation<double> _cardAnimation;

  int _streak = 5;
  int _xp = 240;
  int _signsLearned = 12;

  final List<Map<String, dynamic>> _recentActivity = [
    {'sign': 'HELLO', 'time': '2 mins ago'},
    {'sign': 'WATER', 'time': '1 hour ago'},
    {'sign': 'THANK YOU', 'time': '3 hours ago'},
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    );
    _cardController.forward();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _streak = prefs.getInt('streak') ?? 5;
        _xp = prefs.getInt('xp') ?? 240;
        _signsLearned = prefs.getStringList('learned')?.length ?? 12;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: SafeArea(
          child: FadeTransition(
            opacity: _cardAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildFeaturesSection(),
                  const SizedBox(height: 24),
                  _buildRecentActivity(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNav(0),
      ),
    );
  }

  // ── Notifications ─────────────────────────────
  bool _showNotifications = false;

  final List<Map<String, dynamic>> _notifications = [
    {
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'title': 'Daily Streak!',
      'body': 'You\'re on a 5-day signing streak. Keep it up!',
      'time': '2 mins ago',
      'read': false,
    },
    {
      'icon': Icons.school,
      'color': Color(0xFF00BCD4),
      'title': 'New Lesson Available',
      'body': 'ISL Market signs are now unlocked for you.',
      'time': '1 hour ago',
      'read': false,
    },
    {
      'icon': Icons.emoji_events,
      'color': Colors.amber,
      'title': 'Achievement Unlocked!',
      'body': 'You learned 10 signs. Badge awarded!',
      'time': '3 hours ago',
      'read': true,
    },
    {
      'icon': Icons.emergency,
      'color': Color(0xFFFF5252),
      'title': 'SOS Contact Saved',
      'body': 'Your emergency contact is ready.',
      'time': 'Yesterday',
      'read': true,
    },
  ];

  // ── Header ────────────────────────────────────
  Widget _buildHeader() {
    final unread = _notifications.where((n) => n['read'] == false).length;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
                Text(
                  'Aadharshini',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Ready to communicate today?',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                // ── Notification Bell ──
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _showNotifications = !_showNotifications);
                  },
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _showNotifications
                              ? const Color(0xFF00BCD4).withOpacity(0.15)
                              : const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _showNotifications
                                ? const Color(0xFF00BCD4).withOpacity(0.4)
                                : const Color(0xFF2A2A2A),
                          ),
                        ),
                        child: Icon(
                          _showNotifications
                              ? Icons.notifications
                              : Icons.notifications_outlined,
                          color: _showNotifications
                              ? const Color(0xFF00BCD4)
                              : Colors.white,
                          size: 20,
                        ),
                      ),
                      if (unread > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$unread',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ── Profile Avatar ──
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.push('/profile');
                  },
                  child: Container(
                    width: 46,
                    height: 46,
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
                        'AA',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // ── Notification Panel ──
        if (_showNotifications) ...[
          const SizedBox(height: 12),
          _buildNotificationPanel(),
        ],
      ],
    );
  }

  Widget _buildNotificationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      for (final n in _notifications) {
                        n['read'] = true;
                      }
                    });
                  },
                  child: Text(
                    'Mark all read',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF00BCD4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2A2A2A)),
          ..._notifications.map((n) {
            final isUnread = n['read'] == false;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => n['read'] = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isUnread
                      ? const Color(0xFF00BCD4).withOpacity(0.05)
                      : Colors.transparent,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: (n['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        n['icon'] as IconData,
                        color: n['color'] as Color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                n['title'],
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF00BCD4),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            n['body'],
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFFB0BEC5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            n['time'],
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: const Color(0xFF6B6B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ── Stats Row ─────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.local_fire_department,
          iconColor: Colors.orange,
          borderColor: Colors.orange,
          value: '$_streak',
          label: 'Day Streak',
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.star_outline,
          iconColor: Colors.amber,
          borderColor: Colors.amber,
          value: '$_xp',
          label: 'XP Earned',
        ),
        const SizedBox(width: 10),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          iconColor: const Color(0xFF69F0AE),
          borderColor: const Color(0xFF69F0AE),
          value: '$_signsLearned',
          label: 'Signs Learned',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color borderColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFFB0BEC5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Features Section ──────────────────────────
  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Features',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '6 tools',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Row 1 — Sign Communicator + Learn & Sense
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.sign_language,
                iconColor: const Color(0xFF00BCD4),
                title: 'Sign Communicator',
                subtitle: 'Sign to text and speech',
                badge: 'ACTIVE',
                badgeColor: const Color(0xFF00BCD4),
                onTap: () => context.push('/communicate'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.school,
                iconColor: const Color(0xFF7C4DFF),
                title: 'Learn & Sense',
                subtitle: 'Signs, sounds & stories',
                bottomLabel: '12 lessons',
                bottomLabelColor: const Color(0xFF7C4DFF),
                onTap: () => context.push('/learn'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 2 — Emergency SOS + Caregiver Mode
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.emergency,
                iconColor: const Color(0xFFFF5252),
                title: 'Emergency SOS',
                subtitle: 'Bystander Bridge',
                showPulse: true,
                onTap: () => context.push('/emergency'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.family_restroom,
                iconColor: const Color(0xFF1565C0),
                title: 'Caregiver Mode',
                subtitle: 'Live sign translation',
                onTap: () => context.push('/chat-video'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Row 3 — SoundSense (full width highlight card)
        _buildSoundSenseCard(),
      ],
    );
  }

  // ── SoundSense Highlight Card ─────────────────
  Widget _buildSoundSenseCard() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/sound-textures');
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A0A0A), Color(0xFF0D0A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5252).withOpacity(0.08),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with pulse
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (_, __) => Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF5252).withOpacity(0.08),
                      ),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withOpacity(0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.vibration,
                      color: Color(0xFFFF5252),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'SoundSense',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5252).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF5252).withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          'NEW',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: const Color(0xFFFF5252),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Feel the world through vibration patterns',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Mini sound chips
                  Row(
                    children: [
                      _buildSoundChip('🔔 Bell'),
                      const SizedBox(width: 6),
                      _buildSoundChip('🚨 Siren'),
                      const SizedBox(width: 6),
                      _buildSoundChip('🐕 Dog'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFFF5252),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: const Color(0xFFB0BEC5),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    String? bottomLabel,
    Color? bottomLabelColor,
    bool showPulse = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: showPulse
                ? const Color(0xFFFF5252).withOpacity(0.3)
                : const Color(0xFF2A2A2A),
          ),
          boxShadow: [
            BoxShadow(color: iconColor.withOpacity(0.05), blurRadius: 20),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      badge,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: badgeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFFB0BEC5),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showPulse)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF5252),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF5252,
                                ).withOpacity(_pulseAnimation.value * 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Ready',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFFF5252),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (bottomLabel != null)
                  Text(
                    bottomLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: bottomLabelColor ?? const Color(0xFF00BCD4),
                    ),
                  )
                else
                  const SizedBox(),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 13,
                  color: Color(0xFF00BCD4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Activity ───────────────────────────
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ..._recentActivity.map((item) => _buildActivityItem(item)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF00BCD4).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sign_language,
              color: Color(0xFF00BCD4),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: item['sign'],
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: '  ${item['time']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFFB0BEC5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.replay, color: Color(0xFF6B6B6B), size: 18),
        ],
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
          _buildNavItem(Icons.home_outlined, 'Home', activeIndex == 0, () {}),
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
            () => context.push('/profile'),
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
