import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tato_app/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:tato_app/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:tato_app/features/auth/presentation/screens/login_screen.dart';
import 'package:tato_app/features/business/presentation/screens/setup_business_screen.dart';
import 'package:tato_app/features/dashboard/presentation/screens/hoy_screen.dart';
import 'package:tato_app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:tato_app/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:tato_app/features/inventory/presentation/screens/product_form_screen.dart';
import 'package:tato_app/features/scanner/presentation/screens/scanner_screen.dart';
import 'package:tato_app/features/movements/presentation/screens/new_movement_screen.dart';
import 'package:tato_app/features/insights/presentation/screens/insights_screen.dart';
import 'package:tato_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:tato_app/shared/widgets/main_navigation_shell.dart';
import '../services/providers.dart';
import 'go_router_refresh_notifier.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Built once and kept alive: redirect reads fresh values via ref.read
  // each time it runs, and GoRouterRefreshNotifier tells GoRouter when to
  // re-run it. Rebuilding the whole GoRouter on every auth change (the
  // previous approach, watching the providers directly here) would reset
  // the navigation stack on every login/logout — and with real Supabase
  // Auth, the session stream can emit more than once per sign-in.
  final refreshNotifier = GoRouterRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isLoggedIn = ref.read(currentUserProvider) != null;
      final hasBusiness = ref.read(currentBusinessProvider) != null;
      final path = state.matchedLocation;

      // Splash y onboarding controlan su propia navegación.
      if (path == '/splash' || path == '/onboarding') return null;

      if (!isLoggedIn) {
        return path == '/login' ? null : '/login';
      }
      if (!hasBusiness) {
        return path == '/setup-business' ? null : '/setup-business';
      }
      if (path == '/login' || path == '/setup-business') {
        return '/hoy';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setup-business',
        builder: (context, state) => const SetupBusinessScreen(),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/new-movement',
        builder: (context, state) {
          final productId = state.uri.queryParameters['productId'];
          return NewMovementScreen(initialProductId: productId);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/hoy',
            builder: (context, state) => const HoyScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => ProductFormScreen(
                  initialCategory: state.extra as String?,
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProductDetailScreen(productId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ProductFormScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/scan',
            builder: (context, state) => const ScannerScreen(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
