import 'package:go_router/go_router.dart';
import '../features/dressup/dressup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/studio/outfit_studio_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DressUpScreen()),
      GoRoute(path: '/stylist', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/studio', builder: (context, state) => const OutfitStudioScreen()),
    ],
  );
}
