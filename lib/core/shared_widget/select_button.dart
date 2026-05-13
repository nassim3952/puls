import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';



class FilterSelectButton extends StatelessWidget {
  final String label;
  final String? currentValue;
  final List<String> options;
  final Function(String) onSelected;

  const FilterSelectButton({
    super.key,
    required this.label,
    required this.currentValue,
    required this.options,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Si la valeur est null ou vide, on n'a pas de sélection active
    final bool hasSelection = currentValue != null && currentValue!.isNotEmpty;

    return PopupMenuButton<String>(
      onSelected: onSelected,
      offset: const Offset(0, 45),
      itemBuilder: (context) => options
          .map((opt) => PopupMenuItem(value: opt, child: Text(opt)))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(
              color: hasSelection
                  ? AppColors.textPrimary.withValues(alpha: 0.6)
                  : AppColors.neutral.withValues(alpha: 0.3)
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // CRITIQUE : Si pas de sélection, on affiche le label (ex: "Service")
              hasSelection ? currentValue! : label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: hasSelection ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary, size: 24),
          ],
        ),
      ),
    );
  }
}