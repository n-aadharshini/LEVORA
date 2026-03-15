import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/communicate_screen.dart';
import 'screens/sign_speech_screen.dart';
import 'screens/speech_sign_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/chat_video_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/sound_textures_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/communicate',
      builder: (context, state) => const CommunicateScreen(),
    ),
    GoRoute(
      path: '/sign-speech',
      builder: (context, state) => const SignSpeechScreen(),
    ),
    GoRoute(
      path: '/speech-sign',
      builder: (context, state) => const SpeechSignScreen(),
    ),
    GoRoute(path: '/learn', builder: (context, state) => const LearnScreen()),
    GoRoute(
      path: '/emergency',
      builder: (context, state) => const EmergencyScreen(),
    ),
    GoRoute(
      path: '/chat-video',
      builder: (context, state) => const ChatVideoScreen(),
    ),
    GoRoute(
      path: '/sound-textures',
      builder: (context, state) => const SoundTexturesScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
