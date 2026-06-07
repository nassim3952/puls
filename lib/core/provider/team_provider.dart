import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puls/core/models/team_member_model.dart';
import 'package:puls/core/provider/auth_provider.dart';

// ── Liste des membres ─────────────────────────────────────────────────────────
final teamProvider = FutureProvider<List<TeamMemberModel>>((ref) async {
  final hospitalId = ref.watch(authProvider).user?.hospitalId;
  if (hospitalId == null) return [];

  final result = await Supabase.instance.client.rpc(
    'get_team_members',
    params: {'p_hospital_id': hospitalId},
  );

  return (result as List)
      .map((e) => TeamMemberModel.fromMap(e as Map<String, dynamic>))
      .toList();
});

// ── Actions ───────────────────────────────────────────────────────────────────
class TeamNotifier extends AsyncNotifier<List<TeamMemberModel>> {
  @override
  Future<List<TeamMemberModel>> build() async {
    final hospitalId = ref.watch(authProvider).user?.hospitalId;
    if (hospitalId == null) return [];

    final result = await Supabase.instance.client.rpc(
      'get_team_members',
      params: {'p_hospital_id': hospitalId},
    );

    return (result as List)
        .map((e) => TeamMemberModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  // ── Inviter un membre par email ───────────────────────────────────────────
  Future<void> inviteMember({
    required String email,
    required String name,
    required String fonction,
    required String role,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    final token = session?.accessToken;

    if (token == null) throw Exception('Non authentifié');

    final response = await Supabase.instance.client.functions.invoke(
      'swift-api',
      headers: {'Authorization': 'Bearer $token'},
      body: {
        'email':    email,
        'name':     name,
        'fonction': fonction,
        'role':     role,
      },
    );

    if (response.status != 200) {
      final msg = response.data?['error'] ?? 'Erreur inconnue';
      throw Exception(msg);
    }
  }  // ── Modifier le rôle ──────────────────────────────────────────────────────
  Future<void> updateRole(String userId, String newRole) async {
    await Supabase.instance.client.rpc(
      'update_member_role',
      params: {'p_user_id': userId, 'p_new_role': newRole},
    );
    ref.invalidateSelf();
  }

  // ── Supprimer un membre ───────────────────────────────────────────────────
  Future<void> removeMember(String userId) async {
    await Supabase.instance.client.rpc(
      'remove_team_member',
      params: {'p_user_id': userId},
    );
    ref.invalidateSelf();
  }
}

final teamNotifierProvider =
AsyncNotifierProvider<TeamNotifier, List<TeamMemberModel>>(
  TeamNotifier.new,
);