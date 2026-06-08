import 'package:go_router/go_router.dart';
import '../screens/auth/landing_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/complete_profile_screen.dart';
import '../screens/main/shell_screen.dart';
import '../screens/main/edit_profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => const LandingScreen()),
    GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
    GoRoute(path: '/complete-profile', builder: (ctx, state) => const CompleteProfileScreen()),
    GoRoute(path: '/main', builder: (ctx, state) {
      final extra = state.extra as Map<String, dynamic>?;
      final tab = (extra?['tab'] as int?) ?? 0;
      final draftTab = (extra?['draftTab'] as bool?) ?? false;
      return ShellScreen(initialTab: tab, openDraftTab: draftTab);
    }),
    GoRoute(path: '/edit-profile', builder: (ctx, state) => const EditProfileScreen()),
  ],
);
