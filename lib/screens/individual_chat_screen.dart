import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'chat_list_screen.dart';

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isGesture;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isGesture = false,
  });
}

class IndividualChatScreen extends StatefulWidget {
  final ChatContact contact;

  const IndividualChatScreen({super.key, required this.contact});

  @override
  State<IndividualChatScreen> createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late Color _accentColor;

  final List<ChatMessage> _messages = [
    const ChatMessage(
        text: '👋 Hello! Ready to communicate today?',
        isMe: false,
        time: '9:30 AM'),
    const ChatMessage(
        text: 'Yes! Sign language mode is on 🤟', isMe: true, time: '9:31 AM'),
    const ChatMessage(
        text: '✋ Wait — let me get set up',
        isMe: false,
        time: '9:32 AM',
        isGesture: true),
    const ChatMessage(text: 'Take your time 🙂', isMe: true, time: '9:33 AM'),
    const ChatMessage(
        text: '🆘 Help — I need assistance',
        isMe: false,
        time: '9:35 AM',
        isGesture: true),
    const ChatMessage(
        text: 'On my way! Starting a video call now.',
        isMe: true,
        time: '9:36 AM'),
  ];

  @override
  void initState() {
    super.initState();
    _accentColor = widget.contact.avatarColor;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(
          text: text, isMe: true, time: TimeOfDay.now().format(context)));
    });
    _msgController.clear();
    HapticFeedback.lightImpact();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _startVoiceCall() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CallSheet(
        contact: widget.contact,
        accentColor: _accentColor,
        onVideoCall: () {
          Navigator.pop(ctx);
          _startVideoCall();
        },
      ),
    );
  }

  void _startVideoCall() {
    HapticFeedback.mediumImpact();
    // Opens CommunicateScreen (sign language video call)
    context.push('/communicate');
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111111),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/communicate');
          }
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _accentColor.withOpacity(0.2),
                child: Text(
                  widget.contact.initials,
                  style: GoogleFonts.poppins(
                      color: _accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
              if (widget.contact.isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF111111), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.contact.name,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15),
              ),
              Text(
                widget.contact.isOnline ? 'Online' : 'Offline',
                style: GoogleFonts.poppins(
                  color: widget.contact.isOnline
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFF6B6B6B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Phone call
        IconButton(
          icon: Icon(Icons.call_outlined, color: _accentColor),
          onPressed: _startVoiceCall,
          tooltip: 'Voice Call',
        ),
        // Video call → opens CommunicateScreen
        IconButton(
          icon: Icon(Icons.videocam_outlined, color: _accentColor),
          onPressed: _startVideoCall,
          tooltip: 'Video Call',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        final showAvatar =
            !msg.isMe && (index == 0 || _messages[index - 1].isMe);
        return _MessageBubble(
          message: msg,
          accentColor: _accentColor,
          showAvatar: showAvatar,
          contact: widget.contact,
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: TextField(
                controller: _msgController,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF6B6B6B), fontSize: 14),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration:
                  BoxDecoration(color: _accentColor, shape: BoxShape.circle),
              child:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Bubble ──────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final Color accentColor;
  final bool showAvatar;
  final ChatContact contact;

  const _MessageBubble({
    required this.message,
    required this.accentColor,
    required this.showAvatar,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 14,
                backgroundColor: accentColor.withOpacity(0.2),
                child: Text(contact.initials,
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              )
            else
              const SizedBox(width: 28),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? accentColor.withOpacity(0.85)
                      : message.isGesture
                          ? const Color(0xFF1E2A2A)
                          : const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                  border: message.isGesture
                      ? Border.all(
                          color: const Color(0xFF00BCD4).withOpacity(0.3))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isGesture)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.sign_language,
                                color: Color(0xFF00BCD4), size: 12),
                            const SizedBox(width: 4),
                            Text('Sign Gesture',
                                style: GoogleFonts.poppins(
                                    color: const Color(0xFF00BCD4),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    Text(message.text,
                        style: GoogleFonts.poppins(
                            color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(message.time,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF6B6B6B), fontSize: 10)),
            ],
          ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

// ─── Voice Call Bottom Sheet ─────────────────────────────────────────────────
class _CallSheet extends StatefulWidget {
  final ChatContact contact;
  final Color accentColor;
  final VoidCallback onVideoCall;

  const _CallSheet({
    required this.contact,
    required this.accentColor,
    required this.onVideoCall,
  });

  @override
  State<_CallSheet> createState() => _CallSheetState();
}

class _CallSheetState extends State<_CallSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, child) => Container(
              width: 90 + _pulseController.value * 10,
              height: 90 + _pulseController.value * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.accentColor
                    .withOpacity(0.1 + _pulseController.value * 0.1),
              ),
              child: child,
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: widget.accentColor.withOpacity(0.2),
              child: Text(widget.contact.initials,
                  style: GoogleFonts.poppins(
                      color: widget.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 24)),
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.contact.name,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          const SizedBox(height: 6),
          Text('Calling...',
              style: GoogleFonts.poppins(
                  color: const Color(0xFF6B6B6B), fontSize: 14)),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _callBtn(
                  icon: Icons.call_end,
                  color: const Color(0xFFFF5252),
                  label: 'End',
                  onTap: () => Navigator.pop(context)),
              _callBtn(
                  icon: Icons.videocam_outlined,
                  color: widget.accentColor,
                  label: 'Video\nCall',
                  onTap: widget.onVideoCall),
              _callBtn(
                  icon: Icons.mic_off_outlined,
                  color: const Color(0xFF2A2A2A),
                  label: 'Mute',
                  onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _callBtn({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Column(
        children: [
          Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 26)),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
