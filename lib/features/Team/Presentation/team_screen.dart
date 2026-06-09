import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/team_member_model.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/core/provider/team_provider.dart';

import '../../alertsView/presentation/widgets/adaptativesheet.dart';
import '../../alertsView/presentation/widgets/sheet_base.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync  = ref.watch(teamNotifierProvider);
    final currentUser = ref.watch(authProvider).user;
    final canManage  = currentUser?.role == 'owner' ||
        currentUser?.role == 'admin';

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
            child: Row(
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Équipe', style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  teamAsync.when(
                    data: (members) => Text(
                        '${members.length} membre${members.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ]),
                const Spacer(),
                if (canManage)
                  FilledButton.icon(
                    onPressed: () => _showInviteSheet(context, ref),
                    icon: const Icon(Icons.person_add_outlined, size: 18),
                    label: const Text('Inviter'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            ),
          ),

          // ── Liste ─────────────────────────────────────────────────────────
          Expanded(
            child: teamAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue)),
              error: (e, _) => Center(
                  child: Text('Erreur : $e',
                      style: const TextStyle(color: AppColors.primaryError))),
              data: (members) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                itemBuilder: (ctx, i) => _MemberCard(
                  member:     members[i],
                  canManage:  canManage && !members[i].isOwner &&
                      members[i].id != currentUser?.id,
                  onRoleChange: (newRole) => ref
                      .read(teamNotifierProvider.notifier)
                      .updateRole(members[i].id, newRole),
                  onRemove: () => _confirmRemove(context, ref, members[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sheet invitation ───────────────────────────────────────────────────────
  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    showAdaptiveSheet(
      context,
      child: SheetBase(child: _InviteSheet(ref: ref)),
    );
  }
  // ── Confirmation suppression ───────────────────────────────────────────────
  void _confirmRemove(BuildContext context, WidgetRef ref, TeamMemberModel member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le membre',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16,
                fontWeight: FontWeight.w700)),
        content: Text(
            'Voulez-vous supprimer ${member.name} de l\'équipe ?',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(teamNotifierProvider.notifier)
                  .removeMember(member.id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryError,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ── Card membre ────────────────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final TeamMemberModel member;
  final bool canManage;
  final ValueChanged<String> onRoleChange;
  final VoidCallback onRemove;

  const _MemberCard({
    required this.member,
    required this.canManage,
    required this.onRoleChange,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final roleColor = switch (member.role) {
      'owner' => AppColors.primaryBlue,
      'admin' => const Color(0xFF7C3AED),
      _       => AppColors.textSecondary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlueLighter,
            backgroundImage: member.avatarUrl != null
                ? NetworkImage(member.avatarUrl!) : null,
            child: member.avatarUrl == null
                ? Text(member.name[0].toUpperCase(),
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700, fontSize: 18))
                : null,
          ),
          const SizedBox(width: 14),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(member.fonction, style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 2),
                Text(member.email, style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),

          // Badge rôle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(member.roleLabel, style: TextStyle(
                color: roleColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),

          // Menu actions
          if (canManage) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppColors.textSecondary, size: 20),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (val) {
                if (val == 'remove') {
                  onRemove();
                } else {
                  onRoleChange(val);
                }
              },
              itemBuilder: (_) => [
                if (member.role != 'admin')
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(children: [
                      Icon(Icons.admin_panel_settings_outlined,
                          size: 16, color: Color(0xFF7C3AED)),
                      SizedBox(width: 10),
                      Text('Passer Admin',
                          style: TextStyle(fontSize: 13)),
                    ]),
                  ),
                if (member.role != 'user')
                  const PopupMenuItem(
                    value: 'user',
                    child: Row(children: [
                      Icon(Icons.person_outline_rounded,
                          size: 16, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Passer Utilisateur',
                          style: TextStyle(fontSize: 13)),
                    ]),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(children: [
                    Icon(Icons.person_remove_outlined,
                        size: 16, color: AppColors.primaryError),
                    SizedBox(width: 10),
                    Text('Supprimer',
                        style: TextStyle(
                            color: AppColors.primaryError, fontSize: 13)),
                  ]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Sheet invitation ───────────────────────────────────────────────────────────
class _InviteSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _InviteSheet({required this.ref});

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  final _emailCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _fonctionCtrl = TextEditingController();
  String _role = 'user';
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _fonctionCtrl.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    if (_emailCtrl.text.isEmpty || _nameCtrl.text.isEmpty ||
        _fonctionCtrl.text.isEmpty) {
      setState(() => _error = 'Tous les champs sont requis.');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      await ref.read(teamNotifierProvider.notifier).inviteMember(
        email:    _emailCtrl.text.trim(),
        name:     _nameCtrl.text.trim(),
        fonction: _fonctionCtrl.text.trim(),
        role:     _role,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error   = 'Erreur : $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2))),
        ),
        const SizedBox(height: 20),

        const Text('Inviter un membre', style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w800,
            color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        const Text('Un email d\'invitation sera envoyé automatiquement.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        const SizedBox(height: 20),

        // Champs
        _Field(controller: _emailCtrl,    hint: 'Email *',    icon: Icons.email_outlined),
        const SizedBox(height: 12),
        _Field(controller: _nameCtrl,     hint: 'Nom *',      icon: Icons.person_outline_rounded),
        const SizedBox(height: 12),
        _Field(controller: _fonctionCtrl, hint: 'Fonction *', icon: Icons.work_outline_rounded),
        const SizedBox(height: 12),

        // Sélecteur de rôle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _role,
              isExpanded: true,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 14),
              onChanged: (v) => setState(() => _role = v!),
              items: const [
                DropdownMenuItem(value: 'user',
                    child: Text('Utilisateur')),
                DropdownMenuItem(value: 'admin',
                    child: Text('Administrateur')),
              ],
            ),
          ),
        ),

        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(
              color: AppColors.primaryError, fontSize: 12)),
        ],

        const SizedBox(height: 20),

        // Bouton
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _loading ? null : _invite,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Text('Envoyer l\'invitation',
                style: TextStyle(fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        filled: true,
        fillColor: AppColors.primaryBG,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: AppColors.primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}