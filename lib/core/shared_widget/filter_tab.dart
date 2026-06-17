// ─── Filtre onglets  ────────────────────────────────────────────────
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../color.dart';

class TabFilter extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;
  final List<(String, String)>? tabs;

  const TabFilter({
    required this.current,
    required this.onChanged,
    this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTabs = tabs ??
        const [
          ('all', 'Tous'),
          ('alert', 'Alertes'),
          ('ok', 'Sans alerte'),
        ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: effectiveTabs.map((tab) {
          final isActive = current == tab.$1;
          return GestureDetector(
            onTap: () => onChanged(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              height: double.infinity,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                tab.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isActive
                      ? AppColors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}