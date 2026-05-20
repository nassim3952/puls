import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/features/Auth/presentation/auth_screen.dart';
import 'package:puls/features/fragment.dart';

import '../../features/Auth/presentation/onboarding_screen.dart';

// ── Noms des routes ───────────────────────────────────────────────────────────
class AppRoutes {
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
}

// ── Router ────────────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final status = authState.status;
      final hasUserProfile = authState.user != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.auth;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

      // Encore en initialisation ou chargement → pas de redirect
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      // ⚠️ FIX : needsEmailConfirmation reste sur /auth pour afficher le dialog
      // Le router ne doit pas interférer — l'écran gère lui-même l'affichage
      if (status == AuthStatus.needsEmailConfirmation) {
        return isOnAuthPage ? null : AppRoutes.auth;
      }

      // Non connecté ou erreur → toujours vers /auth
      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        return isOnAuthPage ? null : AppRoutes.auth;
      }

      // Connecté mais pas de profil BDD → bloqué sur /onboarding
      if (status == AuthStatus.authenticated && !hasUserProfile) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      // Connecté avec profil → pas besoin d'être sur /auth ou /onboarding
      if (status == AuthStatus.authenticated && hasUserProfile) {
        if (isOnAuthPage || isOnOnboarding) return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MainDashboardScreen(),
      ),
    ],
  );
});

// ── Listenable qui notifie GoRouter quand l'état auth change ─────────────────
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}