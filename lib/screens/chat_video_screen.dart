import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ChatVideoScreen extends StatefulWidget {
  const ChatVideoScreen({super.key});
  @override
  State<ChatVideoScreen> createState() => _ChatVideoScreenState();
}

class _ChatVideoScreenState extends State<ChatVideoScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isDeafMode = true;
  String _roomCode = 'LEVORA-4821';
  bool _isConnected = false;
  int _caregiverCount = 0;

  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _replyController = TextEditingController();

  List<Map<String, dynamic>> _signHistory = [];
  List<Map<String, dynamic>> _liveTranslations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _generateRoomCode();

    _signHistory = [
      {'sign': 'HELLO', 'time': '2:30 PM'},
      {'sign': 'WATER', 'time': '2:31 PM'},
      {'sign': 'HELP', 'time': '2:32 PM'},
    ];

    _liveTranslations = [
      {'sign': 'HELLO', 'time': '2:30 PM', 'type': 'sign'},
      {'sign': 'WATER', 'time': '2:31 PM', 'type': 'sign'},
      {'sign': 'I am thirsty', 'time': '2:31 PM', 'type': 'reply'},
      {'sign': 'HELP', 'time': '2:32 PM', 'type': 'sign'},
    ];
  }

  void _generateRoomCode() {
    final code =
        'LEVORA-${(1000 + DateTime.now().millisecond % 9000).toString()}';
    setState(() => _roomCode = code);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _roomCodeController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'Caregiver Mode',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          const Icon(Icons.family_restroom, color: Color(0xFF1565C0), size: 28),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          _buildModeToggle(),
          Expanded(
            child: _isDeafMode ? _buildDeafPersonMode() : _buildCaregiverMode(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(4),
    );
  }

  // ── Mode Toggle ───────────────────────────────
  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isDeafMode = true);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isDeafMode
                      ? const Color(0xFF00BCD4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'I am Deaf',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isDeafMode ? Colors.white : const Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _isDeafMode = false);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isDeafMode
                      ? const Color(0xFF00BCD4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'I am Caregiver',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: !_isDeafMode
                        ? Colors.white
                        : const Color(0xFF6B6B6B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Deaf Person Mode ──────────────────────────
  Widget _buildDeafPersonMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: const Center(
              child: Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF6B6B6B),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00BCD4).withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Your Room Code',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _roomCode,
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _roomCode));
                        HapticFeedback.lightImpact();
                      },
                      child: const Icon(
                        Icons.copy,
                        color: Color(0xFF00BCD4),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => HapticFeedback.mediumImpact(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF00BCD4).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.share,
                          color: Color(0xFF00BCD4),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Share Code with Family',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
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
          const SizedBox(height: 12),

          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConnected
                      ? const Color(0xFF69F0AE).withOpacity(0.3)
                      : const Color(0xFF2A2A2A),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? const Color(0xFF69F0AE)
                          : const Color(0xFF6B6B6B),
                      boxShadow: _isConnected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF69F0AE,
                                ).withOpacity(_pulseAnimation.value),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isConnected
                        ? '$_caregiverCount caregiver connected'
                        : 'Waiting for caregiver...',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _isConnected
                          ? const Color(0xFF69F0AE)
                          : const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Signs Sent',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ..._signHistory.map(
            (item) => Container(
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
                      color: const Color(0xFF00BCD4).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sign_language,
                      color: Color(0xFF00BCD4),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item['sign'],
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    item['time'],
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF6B6B6B),
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

  // ── Caregiver Mode ────────────────────────────
  Widget _buildCaregiverMode() {
    return Column(
      children: [
        if (!_isConnected)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2A2A2A)),
                  ),
                  child: TextField(
                    controller: _roomCodeController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter room code (e.g. LEVORA-4821)',
                      hintStyle: GoogleFonts.poppins(
                        color: const Color(0xFF6B6B6B),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isConnected = true);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BCD4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.login, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Join Room',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFF5252,
                      ).withOpacity(_pulseAnimation.value * 0.3 + 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFF5252).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          'LIVE',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFFFF5252),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Connected to deaf person',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF69F0AE),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _isConnected = false),
                  child: Text(
                    'Leave',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFFFF5252),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _liveTranslations.length,
              itemBuilder: (context, i) {
                final item = _liveTranslations[i];
                final isSign = item['type'] == 'sign';
                return Align(
                  alignment: isSign
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSign
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFF00BCD4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSign
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFF00BCD4).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: isSign
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['sign'],
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSign
                                ? Colors.white
                                : const Color(0xFF00BCD4),
                          ),
                        ),
                        Text(
                          item['time'],
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF6B6B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0F0F0F),
              border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: TextField(
                      controller: _replyController,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a reply...',
                        hintStyle: GoogleFonts.poppins(
                          color: const Color(0xFF6B6B6B),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_replyController.text.isNotEmpty) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _liveTranslations.add({
                          'sign': _replyController.text,
                          'time':
                              '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} PM',
                          'type': 'reply',
                        });
                        _replyController.clear();
                      });
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00BCD4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
