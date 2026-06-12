import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/auth/landing_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/complete_profile_screen.dart';
import '../screens/main/shell_screen.dart';
import '../screens/main/edit_profile_screen.dart';
import '../screens/main/article_detail_screen.dart';

// Protected routes — require auth
const _protectedPaths = ['/main', '/edit-profile'];

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final path = state.matchedLocation;

    // Jika belum login dan mau ke protected route → ke landing
    if (!isLoggedIn && _protectedPaths.any((p) => path.startsWith(p))) {
      return '/';
    }

    // Jika sudah login dan mau ke halaman auth → ke main
    if (isLoggedIn &&
        (path == '/' || path == '/login' || path == '/register')) {
      return '/main';
    }

    return null; // Tidak ada redirect
  },
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
    GoRoute(
      path: '/article/:id',
      builder: (ctx, state) => ArticleDetailScreen(
        articleId: state.pathParameters['id']!,
      ),
    ),
  ],
);

