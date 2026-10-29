import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/lamaran/lamaran_list_screen.dart';
import 'screens/lamaran/lamaran_detail_screen.dart';
import 'screens/lamaran/lamaran_form_screen.dart';
import 'screens/statistik/statistik_screen.dart';
import 'screens/settings/settings_screen.dart';

/// Konfigurasi rute navigasi aplikasi menggunakan go_router
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/lamaran',
      builder: (context, state) => const LamaranListScreen(),
    ),
    GoRoute(
      path: '/lamaran/create',
      builder: (context, state) => const LamaranFormScreen(),
    ),
    GoRoute(
      path: '/lamaran/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return LamaranDetailScreen(lamaranId: id);
      },
    ),
    GoRoute(
      path: '/lamaran/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return LamaranFormScreen(lamaranId: id);
      },
    ),
    GoRoute(
      path: '/statistik',
      builder: (context, state) => const StatistikScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

