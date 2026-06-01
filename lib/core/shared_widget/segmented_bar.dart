import 'package:flutter/material.dart';

import '../color.dart';

class SegmentedTabBar extends StatelessWidget {
  final int selectedIndex;
  final int activeCount;
  final int pendingCount;
  final int validatedCount;
  final ValueChanged<int> onChanged;

  const SegmentedTabBar({
    required this.selectedIndex,
    required this.activeCount,
    required this.pendingCount,
    required this.validatedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (0, 'Alertes', activeCount, AppColors.primaryError),
      (1, 'Plans', pendingCount, AppColors.primaryWarning),
      (2, 'Validés', validatedCount, AppColors.primarySuccess),
    ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surface),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isActive = selectedIndex == tab.$1;
          return GestureDetector(
            onTap: () => onChanged(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tab.$2,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  if (tab.$3 > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white.withOpacity(0.25) : tab.$4,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${tab.$3}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}