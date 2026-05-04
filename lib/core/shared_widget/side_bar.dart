
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../color.dart';
import '../provider/navigation_provider.dart';

class SideBar extends ConsumerWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute l'état actuel de la navigation
    final currentIndex = ref.watch(navigationProvider);

    return Container(
      width: 310,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          _buildLogo(),
          const SizedBox(height: 40),

          // Menu Items
          _navItem(ref, Icons.grid_view_rounded, "Tableau de bord", 0, currentIndex),
          _navItem(ref, Icons.notifications_none_rounded, "Alerte", 1, currentIndex, hasBadge: true),
          _navItem(ref, Icons.show_chart_rounded, "Historiques KPI", 2, currentIndex),
          _navItem(ref, Icons.business_rounded, "Services", 3, currentIndex),
          _navItem(ref, Icons.description_outlined, "Détails Enquêtes", 4, currentIndex),

          const Spacer(),

          _navItem(ref, Icons.logout_rounded, "Déconnexion", 99, currentIndex, isDestructive: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryMenthe.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.analytics_outlined, color: AppColors.primaryMenthe),
          ),
          const SizedBox(width: 12),
          const Text(
            "CHU al azhar",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _navItem(WidgetRef ref, IconData icon, String label, int index, int currentIndex,
      {bool hasBadge = false, bool isDestructive = false}) {

    final bool isActive = currentIndex == index;
    final Color contentColor = isActive
        ? Colors.white
        : (isDestructive ? Colors.redAccent : AppColors.textSecondary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => ref.read(navigationProvider.notifier).setIndex(index),
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryMenthe : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: contentColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              if (hasBadge)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }
}