import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import '../provider/spline_selection_provider.dart';

class LegendChip extends ConsumerWidget {
  final String label;
  final Color color;

  const LegendChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On compare toujours en majuscules pour être raccord avec ton provider
    final isVisible = ref.watch(splineSelectionProvider).contains(label.toUpperCase());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          ref.read(splineSelectionProvider.notifier).toggleSpline(label);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              // Texte coloré si actif, gris discret si masqué
              color: isVisible ? color : Colors.grey.withOpacity(0.5),
              // On joue sur l'épaisseur pour marquer la sélection
              fontWeight: isVisible ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }}
class SplineLegendHeader extends StatelessWidget {
  const SplineLegendHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300), // Limite la largeur pour laisser de la place au titre
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LegendChip(label: "Oui totalement", color: AppColors.primaryBlue),
            LegendChip(label: "En partie", color: AppColors.primaryWarning),
            LegendChip(label: "Non", color: AppColors.primaryError),
            LegendChip(label: "En attente", color: AppColors.primaryNeutral),
          ]
        ),
      ),
    );
  }
}
