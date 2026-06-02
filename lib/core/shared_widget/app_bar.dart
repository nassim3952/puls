import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/core/provider/notification_provider.dart';
import '../../features/historique/presentation/historique_screen.dart' hide historiqueFilterProvider;
import '../models/notification_model.dart';
import '../provider/historique_filter_controller.dart';
import 'logout_dialog.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  // ✅ Controller stable — ne sera jamais recréé entre les rebuilds
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final bool isTablet = width >= 600 && width < 1024;

    final filters = ref.watch(historiqueFilterProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final unreadCount = ref.watch(unreadNotifCountProvider);

    // Sync le controller si le state est réinitialisé (ex : bouton reset)
    if (_searchCtrl.text != filters.searchQuery) {
      _searchCtrl.value = _searchCtrl.value.copyWith(
        text: filters.searchQuery,
        selection: TextSelection.collapsed(offset: filters.searchQuery.length),
      );
    }

    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      automaticallyImplyActions: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16),
        child: Row(
          children: [
            // ── Logo / Icône ──────────────────────────────────────────────
            if (!isMobile)
              isTablet
                  ? const Icon(
                Icons.flash_on,
                color: AppColors.primaryBlue,
                size: 32,
              )
                  : Image.asset('assets/logo.png', width: 200, height: 32),

            if (!isMobile) SizedBox(width: isTablet ? 20 : 40),

            // ── Toggle mode de recherche + barre ─────────────────────────
            SizedBox(
              width: isMobile ? double.infinity : 420,
              height: 38,
              child: Row(
                children: [
                  // Toggle Patient / Mot-clé
                  _SearchModeToggle(
                    current: filters.searchMode,
                    onChanged: (mode) {
                      ref
                          .read(historiqueFilterProvider.notifier)
                          .setSearchMode(mode);
                      _searchCtrl.clear();
                    },
                  ),
                  const SizedBox(width: 8),

                  // Barre de recherche
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => ref
                          .read(historiqueFilterProvider.notifier)
                          .setSearch(v),
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: filters.searchMode == SearchMode.patient
                            ? 'Nom, prénom, IPP…'
                            : 'Mot-clé dans les verbatims…',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: filters.searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            ref
                                .read(historiqueFilterProvider.notifier)
                                .setSearch('');
                          },
                        )
                            : null,
                        filled: true,
                        fillColor: AppColors.white,
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: filters.searchQuery.isNotEmpty
                                ? AppColors.primaryBlue
                                : AppColors.border,
                            width: filters.searchQuery.isNotEmpty ? 1.5 : 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Badge Live ────────────────────────────────────────────────
            if (!isMobile) ...[
              const SizedBox(width: 20),
              const _LiveBadge(),
            ],

            const Spacer(),

            // ── Profil utilisateur ────────────────────────────────────────
            PopupMenuButton<int>(
              tooltip: "Menu profil",
              offset: const Offset(0, 50),
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: _UserSection(
                showName: !isMobile,
                user: user,
                isLoading: authState.status == AuthStatus.loading,
              ),
              onSelected: (value) {
                if (value == 1) {
                  // TODO: Navigation vers les paramètres
                } else if (value == 2) {
                  showLogoutDialog(context, ref);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: const [
                      Icon(Icons.settings_outlined,
                          size: 18, color: AppColors.textPrimary),
                      SizedBox(width: 10),
                      Text("Paramètres",
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 13)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded,
                          size: 18, color: AppColors.primaryError),
                      SizedBox(width: 10),
                      Text("Déconnexion",
                          style: TextStyle(
                              color: AppColors.primaryError,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(width: 4),

            // ── Cloche de notifications ───────────────────────────────────
            _NotificationBell(unreadCount: unreadCount),

            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}


class _SearchModeToggle extends StatelessWidget {
  final SearchMode current;
  final void Function(SearchMode) onChanged;

  const _SearchModeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(
            icon: Icons.person_search_rounded,
            tooltip: 'Par patient',
            isActive: current == SearchMode.patient,
            onTap: () => onChanged(SearchMode.patient),
          ),
          _ToggleBtn(
            icon: Icons.manage_search_rounded,
            tooltip: 'Par mot-clé verbatim',
            isActive: current == SearchMode.keyword,
            onTap: () => onChanged(SearchMode.keyword),
          ),
        ],
      ),
    );
  }
}
class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}



// ══════════════════════════════════════════════════════════════════════════════
// BADGE LIVE ANIMÉ
// ══════════════════════════════════════════════════════════════════════════════

class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Opacity(
              opacity: _pulse.value,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            "Live",
            style: TextStyle(
                color: AppColors.primaryBlueDarker,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SECTION UTILISATEUR (avec avatar réel + shimmer)
// ══════════════════════════════════════════════════════════════════════════════

class _UserSection extends StatelessWidget {
  final bool showName;
  final dynamic user; // UserModel?
  final bool isLoading;

  const _UserSection({
    required this.showName,
    required this.user,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && user == null) {
      return const _UserShimmer();
    }

    final String initial = (user?.name != null && user!.name.isNotEmpty)
        ? user!.name.substring(0, 1).toUpperCase()
        : 'A';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showName && user != null) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user!.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user!.fonction,
                  style: const TextStyle(
                      color: AppColors.kTextSub, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 12),
          ],
          // ── Avatar ──────────────────────────────────────────────────────
          Avatar(
            avatarUrl: user?.avatarUrl as String?,
            initial: initial,
            radius: 18,
          ),
        ],
      ),
    );
  }
}
// ── Avatar ─────────────────────────────────────────────────────────────────


class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String initial;
  final double radius;

  const Avatar({
    required this.avatarUrl,
    required this.initial,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
        child: ClipOval(
          child: Image.network(
            avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            // Chargement progressif
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _InitialAvatar(initial: initial, radius: radius);
            },
            // Fallback si l'URL est invalide
            errorBuilder: (_, __, ___) =>
                _InitialAvatar(initial: initial, radius: radius),
          ),
        ),
      );
    }
    return _InitialAvatar(initial: initial, radius: radius);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  final double radius;

  const _InitialAvatar({required this.initial, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryBlueDarker,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}


// ── Shimmer de chargement ──────────────────────────────────────────────────

class _UserShimmer extends StatefulWidget {
  const _UserShimmer();

  @override
  State<_UserShimmer> createState() => _UserShimmerState();
}

class _UserShimmerState extends State<_UserShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ShimmerBox(width: 90, height: 11, opacity: _anim.value),
              const SizedBox(height: 4),
              _ShimmerBox(width: 60, height: 9, opacity: _anim.value),
            ],
          ),
          const SizedBox(width: 12),
          _ShimmerBox(
              width: 36, height: 36, radius: 18, opacity: _anim.value),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final double opacity;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 6,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.2),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CLOCHE DE NOTIFICATIONS
// ══════════════════════════════════════════════════════════════════════════════

class _NotificationBell extends ConsumerWidget {
  final int unreadCount;

  const _NotificationBell({required this.unreadCount});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: 'Notifications',
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            unreadCount > 0
                ? Icons.notifications_rounded
                : Icons.notifications_none_rounded,
            color: unreadCount > 0
                ? AppColors.primaryBlue
                : AppColors.textPrimary,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.primaryError,
                  shape: BoxShape.circle,
                ),
                constraints:
                const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () => _openNotificationsDrawer(context, ref),
    );
  }

  void _openNotificationsDrawer(BuildContext context, WidgetRef ref) {
    Scaffold.of(context).openEndDrawer();
    // Si tu n'utilises pas endDrawer sur le Scaffold, utilise showModalBottomSheet
    // ou un custom overlay. Voir ci-dessous pour le drawer complet.
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS DRAWER
// À ajouter dans ton MainDashboardScreen : endDrawer: const NotificationsDrawer()
// ══════════════════════════════════════════════════════════════════════════════

class NotificationsDrawer extends ConsumerWidget {
  const NotificationsDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsProvider);
    final notifs = notifState.notifications;

    return Drawer(
      width: 380,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.surface),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                if (notifState.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${notifState.unreadCount} non lue${notifState.unreadCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.primaryBlueDarker,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (notifState.unreadCount > 0)
                  TextButton(
                    onPressed: () =>
                        ref.read(notificationsProvider.notifier).markAllAsRead(),
                    child: const Text(
                      'Tout lire',
                      style: TextStyle(
                          color: AppColors.primaryBlue, fontSize: 12),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),

          // ── Liste ─────────────────────────────────────────────────────
          Expanded(
            child: notifState.isLoading
                ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 2,
              ),
            )
                : notifs.isEmpty
                ? _EmptyNotifications()
                : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifs.length,
              itemBuilder: (_, i) => _NotificationTile(
                notif: notifs[i],
                onTap: () => ref
                    .read(notificationsProvider.notifier)
                    .markAsRead(notifs[i].id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tuile de notification ──────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotificationTile({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(notif.severity);
    final icon = _typeIcon(notif.type);
    final timeAgo = _formatTime(notif.createdAt);

    return InkWell(
      onTap: notif.isRead ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notif.isRead ? Colors.transparent : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isRead ? Colors.transparent : color.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône sévérité
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: notif.isRead
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notif.body != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      notif.body!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.kTextSub),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.kTextSub),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _severityColor(NotificationSeverity s) => switch (s) {
    NotificationSeverity.critical => AppColors.primaryError,
    NotificationSeverity.warning => const Color(0xFFF59E0B),
    NotificationSeverity.info => AppColors.primaryBlue,
  };

  IconData _typeIcon(NotificationType t) => switch (t) {
    NotificationType.alertPatient => Icons.monitor_heart_rounded,
    NotificationType.admin => Icons.admin_panel_settings_outlined,
    NotificationType.system => Icons.info_outline_rounded,
  };

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return "À l'instant";
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
  }
}

class _EmptyNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: AppColors.primaryBlue.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Aucune notification',
            style: TextStyle(color: AppColors.kTextSub, fontSize: 14),
          ),
        ],
      ),
    );
  }
}