import 'package:flutter/material.dart';
import '../color.dart';
import '../text.dart';

class StatCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onMorePressed;
  final IconData? icon;
  final String fullName;

  const StatCard({
    super.key,
    required this.fullName,
    required this.title,
    required this.child,
    this.onMorePressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
         // La carte s'adapte à la taille du contenu
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Tooltip(

                    message: fullName,
                    preferBelow: true,
                    verticalOffset: 20,
                    child: Text(
                      title,
                      style: AppTextStyles.cardTitle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              if (onMorePressed != null)
                IconButton(
                  icon: const Icon(Icons.more_horiz, size: 20),
                  onPressed: onMorePressed,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Zone graphique : on donne une contrainte de hauteur raisonnable
          // pour éviter les débordements (Overflow)
          Expanded(child: child),
        ],
      ),
    );
  }
}