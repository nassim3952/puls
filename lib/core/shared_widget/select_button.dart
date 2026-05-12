import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

// Aucun changement majeur ici, il reste générique et propre !
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
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentValue ?? label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
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