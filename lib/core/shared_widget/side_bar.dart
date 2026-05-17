import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../provider/navigation_provider.dart';
import '../provider/side_bar_provider.dart';

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
                ref,
                Icons.grid_view_rounded,
                "Tableau de bord",
                0,
                currentIndex,
                isCollapsed,
              ),
              _navItem(
                ref,
                Icons.notifications_none_rounded,
                "Alerte",
                1,
                currentIndex,
                isCollapsed,
                hasBadge: true,
              ),
              _navItem(
                ref,
                Icons.show_chart_rounded,
                "Historiques",
                2,
                currentIndex,
                isCollapsed,
              ),
              _navItem(
                ref,
                Icons.business_rounded,
                "Services",
                3,
                currentIndex,
                isCollapsed,
              ),
              _navItem(
                ref,
                Icons.description_outlined,
                "Détails Enquêtes",
                4,
                currentIndex,
                isCollapsed,
              ),

              const Spacer(),

              _navItem(
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        height: 50,
        // On utilise un Stack pour que l'icône puisse se déplacer librement
        // par-dessus ou à côté des autres éléments pendant l'anim
        child: Stack(
          children: [
            // 1. Le Logo et le Texte (disparaissent en fondu)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: collapsed ? 0 : 1,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMenthe.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: AppColors.primaryMenthe,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "CHU ABC",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),

            // 2. L'icône Burger avec un alignement animé
            AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              // Si réduit -> centre, si ouvert -> aligné à droite
              alignment: collapsed ? Alignment.center : Alignment.centerRight,
              child: IconButton(
                onPressed: () => ref.read(sidebarProvider.notifier).toggle(),
                icon: collapsed
                    ? const Icon(Icons.menu)
                    : const Icon(Icons.menu_open),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    WidgetRef ref,
    IconData icon,
    String label,
    int index,
    int currentIndex,
    bool collapsed, {
    bool hasBadge = false,
    bool isDestructive = false,
  }) {
    final isActive = currentIndex == index;

    final color = isActive
        ? Colors.white
        : (isDestructive ? Colors.redAccent : AppColors.textSecondary);

    return InkWell(
      onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryMenthe : Colors.transparent,
        ),
        child: Row(
          children: [
            // L'icône reste toujours visible
            Icon(icon, color: color, size: 20),

            // On remplace le IF par un espacement animé
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: collapsed ? 0 : 16,
            ),

            // Le texte et le badge enveloppés dans l'opacité
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                // On cache le texte si collapsed, mais on le garde dans le Row
                opacity: collapsed ? 0 : 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.w500,
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
  }
}
