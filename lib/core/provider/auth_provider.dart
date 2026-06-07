import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

// ── Accès rapide au client Supabase ──────────────────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>(
      (_) => Supabase.instance.client,
);

// ── État de l'auth ────────────────────────────────────────────────────────────
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsEmailConfirmation,
  wrongPassword, // ← mdp incorrect mais email valide
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;

  AuthNotifier(this._supabase) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _loadUserFromDb(session.user.id);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      // Quand l'utilisateur clique sur le lien de confirmation email,
      // Supabase émet un signedIn — on charge alors le profil
      if (event == AuthChangeEvent.signedIn && data.session != null) {
        _loadUserFromDb(data.session!.user.id);
      }
    });
  }

  Future<void> _loadUserFromDb(String uid) async {
    try {
      final data = await _supabase
          .from('users')
          .select('*, hospitals(name)')
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: UserModel.fromMap(data),
        );
      } else {
        // Auth OK mais pas encore de profil BDD (juste après inscription)
        state = state.copyWith(status: AuthStatus.authenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  Future<void> signIn({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // Nettoyage de l'email (évite les majuscules automatiques des claviers mobiles)
      final cleanEmail = email.trim().toLowerCase();

      // On tente directement la connexion sans requêter la table 'users' avant
      final res = await _supabase.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      if (res.user != null) {
        await _loadUserFromDb(res.user!.id);
      }
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();

      // Si l'identifiant ou le mot de passe est faux, GoTrue renvoie 'invalid login credentials'
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credentials')) {
        state = state.copyWith(
          status: AuthStatus.error, // Ou AuthStatus.wrongPassword selon ta logique UI
          errorMessage: 'Email ou mot de passe incorrect.',
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: _translateAuthError(e.message),
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur inattendue est survenue.',
      );
    }
  }
  // ── Inscription owner ──────────────────────────────────────────────────────
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String fonction,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'fonction': fonction},
      );

      if (res.user != null && res.session == null) {
        // Confirmation email activée → utilisateur créé mais pas encore connecté
        state = state.copyWith(
          status: AuthStatus.needsEmailConfirmation,
        );
      } else if (res.user != null && res.session != null) {
        // Confirmation désactivée → connecté directement
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: 'Inscription échouée. Veuillez réessayer.',
        );
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateAuthError(e.message),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur inattendue est survenue.',
      );
    }
  }

  // ── Mot de passe oublié ────────────────────────────────────────────────────
  Future<void> resetPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        // Remplace par ton domaine réel (configuré dans Supabase → URL Configuration)
        redirectTo: 'https://TON_DOMAINE/auth?type=recovery',
      );
      // On repasse unauthenticated pour débloquer l'UI
      state = state.copyWith(status: AuthStatus.unauthenticated);
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _translateAuthError(e.message),
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Une erreur inattendue est survenue.',
      );
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  // Appelé après création hôpital + user en BDD
  void setUser(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
  }

  // ── Traduction des erreurs Supabase en français ────────────────────────────
  String _translateAuthError(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return 'Email ou mot de passe incorrect.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Veuillez confirmer votre email avant de vous connecter.';
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return 'Cette adresse email est déjà utilisée.';
    }
    if (msg.contains('password should be at least')) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    if (msg.contains('rate limit')) {
      return 'Trop de tentatives. Veuillez patienter quelques minutes.';
    }
    // Fallback : message original
    return message;
  }
}

// ── Provider public ───────────────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(supabaseClientProvider));
});

// Raccourci : uid de l'utilisateur connecté
final currentUidProvider = Provider<String?>((ref) {
  return Supabase.instance.client.auth.currentUser?.id;
});