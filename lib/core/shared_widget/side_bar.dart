import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:puls/features/dashboard/presentation/provider/q1_pie_chart_provider.dart';
import '../color.dart';
import '../provider/auth_provider.dart';
import '../provider/navigation_provider.dart';
import '../provider/side_bar_provider.dart';
import 'logout_dialog.dart';

class SideBar extends ConsumerWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);
    final isOpen = ref.watch(sidebarProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 100;
        final isCollapsed = !isOpen || isSmall;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isCollapsed ? 55 : 235,
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildLogo(ref, isCollapsed),
              const SizedBox(height: 50),

              _navItem(
                context,
                ref,
                Icons.grid_view_rounded,
                "Tableau de bord",
                0,
                currentIndex,
                isCollapsed,
              ),
              _navItem(
                context,
                ref,
                Icons.notifications_none_rounded,
                "Alerte",
                1,
                currentIndex,
                isCollapsed,
                hasBadge: true,
              ),
              _navItem(
                context,
                ref,
                Icons.show_chart_rounded,
                "Patients",
                2,
                currentIndex,
                isCollapsed,
              ),
              _navItem(
                context,
                ref,
                Icons.business_rounded,
                "Services",
                3,
                currentIndex,
                isCollapsed,
              ),

              const Spacer(),

              _navItem(
                context,
                ref,
                Icons.logout_rounded,
                "Déconnexion",
                99,
                currentIndex,
                isCollapsed,
                isDestructive: true,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo(WidgetRef ref, bool collapsed) {
    final authState = ref.watch(authProvider);
    final hospitalName = authState.user?.hospitalName?? "Puls App";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: 50,
        child: Stack(
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: collapsed ? 0 : 1,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                   Text(
                    hospitalName.capitalize(),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: collapsed ? Alignment.center : Alignment.centerRight,
              child: IconButton(
                onPressed: () => ref.read(sidebarProvider.notifier).toggle(),
                icon: collapsed ? const Icon(Icons.menu_sharp) : const Icon(Icons.menu_open_sharp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── DIALOGUE DE DÉCONNEXION REFACTORISÉ AU STYLE DE TON APP ────────────────
  Widget _navItem(
      BuildContext context,
      WidgetRef ref, // <-- On s'assure que le WidgetRef est bien déclaré ici
      IconData icon,
      String label,
      int index,
      int currentIndex,
      bool collapsed, {
        bool hasBadge = false,
        bool isDestructive = false,
      }) {
    final isActive = (index == 99) ? false : (currentIndex == index);

    final color = isActive
        ? Colors.white
        : (isDestructive ? AppColors.primaryError : AppColors.sideBarText);

    return InkWell(
      onTap: () {
        if (index == 99) {
          showLogoutDialog(context, ref); // <-- On passe aussi ref au dialogue de déconnexion !
        } else {
          ref.read(navigationProvider.notifier).setIndex(index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? AppColors.primaryGradient : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: collapsed ? 0 : 16,
            ),
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: collapsed ? 0 : 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasBadge)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }}