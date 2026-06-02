import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class ChatContact {
  final String id;
  final String name;
  final String initials;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isOnline;
  final Color avatarColor;

  const ChatContact({
    required this.id,
    required this.name,
    required this.initials,
    required this.lastMessage,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
    required this.avatarColor,
  });
}

final List<ChatContact> demoContacts = [
  ChatContact(
    id: '1',
    name: 'Aadharshini',
    initials: 'AA',
    lastMessage: '👋 Hello! Can you see my signs?',
    time: '9:41 AM',
    unreadCount: 2,
    isOnline: true,
    avatarColor: const Color(0xFF6C63FF),
  ),
  ChatContact(
    id: '2',
    name: 'Ravi Kumar',
    initials: 'RK',
    lastMessage: '✋ Wait — I need a moment',
    time: '9:15 AM',
    unreadCount: 0,
    isOnline: true,
    avatarColor: const Color(0xFF00BCD4),
  ),
  ChatContact(
    id: '3',
    name: 'Priya S',
    initials: 'PS',
    lastMessage: 'Thank you so much 🙏',
    time: 'Yesterday',
    unreadCount: 0,
    isOnline: false,
    avatarColor: const Color(0xFFFF6B6B),
  ),
  ChatContact(
    id: '4',
    name: 'Dr. Meena',
    initials: 'DM',
    lastMessage: '🆘 Help — I need assistance',
    time: 'Yesterday',
    unreadCount: 1,
    isOnline: false,
    avatarColor: const Color(0xFF4CAF50),
  ),
  ChatContact(
    id: '5',
    name: 'Sundar Raj',
    initials: 'SR',
    lastMessage: 'I love you ❤️',
    time: 'Mon',
    unreadCount: 0,
    isOnline: false,
    avatarColor: const Color(0xFFFF9800),
  ),
  ChatContact(
    id: '6',
    name: 'Anitha V',
    initials: 'AV',
    lastMessage: 'Stop — please stop 🛑',
    time: 'Sun',
    unreadCount: 3,
    isOnline: true,
    avatarColor: const Color(0xFFE91E63),
  ),
];

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<ChatContact> _filtered = demoContacts;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filtered = demoContacts
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Chats',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF00BCD4)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearch,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search chats...',
                  hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF6B6B6B), fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: Color(0xFF6B6B6B), size: 20),
                ),
              ),
            ),
          ),

          // Online now strip
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: demoContacts.where((c) => c.isOnline).toList().length,
              itemBuilder: (context, index) {
                final onlineContacts =
                    demoContacts.where((c) => c.isOnline).toList();
                final contact = onlineContacts[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/chat/${contact.id}', extra: contact);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                                  contact.avatarColor.withOpacity(0.2),
                              child: Text(
                                contact.initials,
                                style: GoogleFonts.poppins(
                                  color: contact.avatarColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF0A0A0A), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          contact.name.split(' ')[0],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Recent',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B6B6B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Chat list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 4),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final contact = _filtered[index];
                return _ChatTile(
                  contact: contact,
                  delay: index * 60,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/chat/${contact.id}', extra: contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00BCD4),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatContact contact;
  final int delay;
  final VoidCallback onTap;

  const _ChatTile({
    required this.contact,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: contact.avatarColor.withOpacity(0.18),
                  child: Text(
                    contact.initials,
                    style: GoogleFonts.poppins(
                      color: contact.avatarColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (contact.isOnline)
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFF0A0A0A), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        contact.name,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        contact.time,
                        style: GoogleFonts.poppins(
                          color: contact.unreadCount > 0
                              ? const Color(0xFF00BCD4)
                              : const Color(0xFF6B6B6B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            color: contact.unreadCount > 0
                                ? Colors.white70
                                : const Color(0xFF6B6B6B),
                            fontSize: 13,
                            fontWeight: contact.unreadCount > 0
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (contact.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BCD4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${contact.unreadCount}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
