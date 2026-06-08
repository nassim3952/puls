import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/user_model.dart';
import '../../../core/provider/auth_provider.dart';

// ── État ──────────────────────────────────────────────────────────────────────
enum OnboardingStatus { idle, loading, success, error }

class OnboardingState {
  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.status = OnboardingStatus.idle,
    this.errorMessage,
  });

  OnboardingState copyWith({OnboardingStatus? status, String? errorMessage}) {
    return OnboardingState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingNotifier(this._ref) : super(const OnboardingState());

  Future<void> createHospitalAndOwner({
    required String hospitalName,
    String? whatsappPhone,
    String? wilaya,
    String? commune,
    String? cite,
  }) async {
    state = state.copyWith(status: OnboardingStatus.loading);

    final supabase = Supabase.instance.client;

    // ── Récupération de la session live (corrige le timing post-signUp) ───
    final session = supabase.auth.currentSession;
    final uid = session?.user.id;

    if (uid == null) {
      state = state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: 'Session expirée. Veuillez vous reconnecter.',
      );
      return;
    }

    // name + fonction stockés dans userMetadata lors du signUp
    final metadata = session!.user.userMetadata ?? {};
    final ownerName = metadata['name'] as String? ?? 'Owner';
    final ownerFonction = metadata['fonction'] as String? ?? '';

    try {
      // ── Étape 1 : Créer l'hôpital ─────────────────────────────────────────
      final Map<String, dynamic> hospitalPayload = {
        'name': hospitalName,
        if (whatsappPhone != null && whatsappPhone.isNotEmpty)
          'whatsapp_phone': whatsappPhone,
        if (wilaya != null || commune != null || cite != null)
          'localisation': {
            if (wilaya != null && wilaya.isNotEmpty) 'wilaya': wilaya,
            if (commune != null && commune.isNotEmpty) 'commune': commune,
            if (cite != null && cite.isNotEmpty) 'cite': cite,
          },
      };

      final hospitalRes = await supabase
          .from('hospitals')
          .insert(hospitalPayload)
          .select('id')
          .single();

      final hospitalId = hospitalRes['id'] as String;

      print('✅ Hospital créé : $hospitalId'); // ← ici

      // ── Étape 2 : Créer le profil user (owner) lié à l'hôpital ──────────
      final userPayload = {
        'id': uid,
        'hospital_id': hospitalId,
        'name': ownerName,
        'role': 'owner',
        'fonction': ownerFonction,
        if (session.user.email != null) 'email': session.user.email,
      };

      print('👤 uid: $uid');           // ← ici
      print('🏥 hospital_id: $hospitalId');
      print('📦 payload: $userPayload');
      await supabase.auth.refreshSession();

      final freshSession = supabase.auth.currentSession;
      print('🔑 Role: ${freshSession?.user.role}');
      print('🔑 Email confirmed: ${freshSession?.user.emailConfirmedAt}');
      print('🔑 Token expires at: ${freshSession?.expiresAt}');
      final token = freshSession?.accessToken ?? '';
// Split en morceaux de 200 chars pour pas que Flutter tronque
      for (var i = 0; i < token.length; i += 200) {
        print(token.substring(i, i + 200 > token.length ? token.length : i + 200));
      }
      final userRes = await supabase
          .from('users')
          .insert(userPayload)
          .select()
          .single();

      // ── Étape 3 : Mettre à jour l'état auth avec le profil complet ───────
      _ref.read(authProvider.notifier).setUser(UserModel.fromMap(userRes));

      state = state.copyWith(status: OnboardingStatus.success);
    } on PostgrestException catch (e) {
      print('❌ code: ${e.code}');
      print('❌ message: ${e.message}');
      print('❌ details: ${e.details}');
      print('❌ hint: ${e.hint}');
      // Code 23505 = unique constraint violation (nom hôpital déjà utilisé)
      if (e.code == '23505') {
        state = state.copyWith(
          status: OnboardingStatus.error,
          errorMessage: 'Un hôpital avec ce nom existe déjà. Choisissez un autre nom.',
        );
      } else {
        state = state.copyWith(
          status: OnboardingStatus.error,
          errorMessage: 'Erreur BDD : ${e.message}',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: OnboardingStatus.error,
        errorMessage: 'Erreur inattendue : $e',
      );
    }
  }

  void reset() => state = const OnboardingState();
}

final onboardingProvider =
StateNotifierProvider<OnboardingNotifier, OnboardingState>(
      (ref) => OnboardingNotifier(ref),
);