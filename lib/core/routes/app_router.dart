import 'package:flutter/material.dart';
import 'package:puls/features/Misc/not_found_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/features/Auth/presentation/auth_screen.dart';
import 'package:puls/features/fragment.dart';

import '../../features/Auth/presentation/onboarding_screen.dart';
import '../../features/Misc/CheckEmailScreen.dart';

// ── Variables globales pour stocker les états pré-runApp ────────────────────
String? pendingOtpError;
bool pendingInvite = false; // ← true quand l'user arrive via lien invitation

// ── Noms des routes ───────────────────────────────────────────────────────────
class AppRoutes {
  static const auth = '/auth';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const checkEmail = '/check-email';
}

// ── Router ────────────────────────────────────────────────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.auth,
    errorBuilder: (context, state) => const NotFoundScreen(),
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      // ── Logique auth normale ──
      final status = authState.status;
      final hasUserProfile = authState.user != null;
      final isOnAuthPage = state.matchedLocation == AppRoutes.auth;
      final isOnOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      if (status == AuthStatus.needsEmailConfirmation) {
        return state.matchedLocation == AppRoutes.checkEmail
            ? null
            : AppRoutes.checkEmail;
      }

      if (status == AuthStatus.unauthenticated || status == AuthStatus.error) {
        return isOnAuthPage ? null : AppRoutes.auth;
      }

      // Invité avec profil existant → onboarding pour définir mot de passe
      if (status == AuthStatus.authenticated && authState.isInvitedUser) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      if (status == AuthStatus.authenticated && !hasUserProfile) {
        return isOnOnboarding ? null : AppRoutes.onboarding;
      }

      if (status == AuthStatus.authenticated && hasUserProfile) {
        if (isOnAuthPage || isOnOnboarding) return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) {
          print('🟠 builder /auth — pendingOtpError: $pendingOtpError');
          final otpError = pendingOtpError;
          pendingOtpError = null;
          print('🟠 otpError passé à AuthScreen: $otpError');
          return AuthScreen(otpError: otpError);
        },
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) {
          final authState = ref.read(authProvider);
          final isInvite = authState.isInvitedUser;
          return OnboardingScreen(isInvite: isInvite);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const MainDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkEmail,
        builder: (context, state) => const CheckEmailScreen(),
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