import 'package:flutter/material.dart';
import '../color.dart';
import '../text.dart';

class StatCard extends StatelessWidget {
  final String title;
  final Widget child; // Le graphique (jauge, donut, etc.)
  final VoidCallback? onMorePressed;
  final IconData? icon;

  const StatCard({
    super.key,
    required this.title,
    required this.child,
    this.onMorePressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la carte
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Text(title, style: AppTextStyles.cardTitle),
              const Spacer(),
              if (onMorePressed != null)
                const Icon(Icons.more_horiz, color: AppColors.textSecondary),
            ],
          ),

          // Zone de contenu (Graphique)
          const SizedBox(height: 20),
          Expanded(child: Center(child: child)),

          // Footer de la carte (Lien "Plus de détails")
          if (onMorePressed != null) ...[
            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: onMorePressed,
                child: const Text(
                  "Plus de détail",
                  style: TextStyle(
                    color: AppColors.primaryMenthe,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}