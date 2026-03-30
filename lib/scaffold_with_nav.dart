import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ScaffoldWithNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    final tabs = ['/home', '/caregiver', '/learn', '/emergency', '/profile'];
    final activeIndex = tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: child,
      bottomNavigationBar:
          _buildBottomNav(context, activeIndex == -1 ? 0 : activeIndex),
    );
  }

  Widget _buildBottomNav(BuildContext context, int activeIndex) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0F0F),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, 'Home', activeIndex == 0,
              () => context.go('/home')),
          _buildNavItem(context, Icons.family_restroom_outlined, 'Caregiver',
              activeIndex == 1, () => context.go('/caregiver')),
          _buildNavItem(context, Icons.menu_book_outlined, 'Learn',
              activeIndex == 2, () => context.go('/learn')),
          _buildNavItem(context, Icons.emergency_outlined, 'SOS',
              activeIndex == 3, () => context.go('/emergency'),
              color: const Color(0xFFFF5252)),
          _buildNavItem(context, Icons.person_outline, 'Profile',
              activeIndex == 4, () => context.go('/profile')),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, VoidCallback onTap,
      {Color? color}) {
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
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                )),
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
