import 'package:go_router/go_router.dart';
import 'package:levora/screens/caregiver_mode.dart';
import 'package:levora/scaffold_with_nav.dart'; // 👈 add this
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/communicate_screen.dart';
import 'screens/speech_sign_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/chat_video_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sound_textures_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // No nav bar
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // With nav bar (ShellRoute wraps these)
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNav(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
            path: '/caregiver', builder: (_, __) => const CaregiverScreen()),
        GoRoute(path: '/learn', builder: (_, __) => const LearnScreen()),
        GoRoute(
            path: '/emergency', builder: (_, __) => const EmergencyScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // No nav bar (detail/sub screens)
    GoRoute(
        path: '/communicate', builder: (_, __) => const CommunicateScreen()),
    GoRoute(path: '/speech-sign', builder: (_, __) => const SpeechSignScreen()),
    GoRoute(path: '/chat-video', builder: (_, __) => const ChatVideoScreen()),
    GoRoute(
        path: '/sound-textures',
        builder: (_, __) => const SoundTexturesScreen()),
  ],
);
