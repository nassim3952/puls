import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/provider/spline_selection_provider.dart';
import '../../../../core/data/fake_data.dart';

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
    final isVisible = ref.watch(splineSelectionProvider).contains(label);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        // On supprime l'effet de splash au clic pour que ce soit 100% propre
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          ref.read(splineSelectionProvider.notifier).toggleSpline(label);
        },
        child: Padding(
          // On garde exactement ton labelPadding du FilterChip
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isVisible ? color : Colors.grey[600],
              fontWeight: isVisible ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );  }
}
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
          children: splineData1.map((s) => LegendChip(label: s.name, color: s.color)).toList(),
        ),
      ),
    );
  }
}
