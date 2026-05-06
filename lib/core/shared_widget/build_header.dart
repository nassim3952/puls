import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/select_button.dart';
import 'package:puls/core/shared_widget/widgets.dart';

import '../../features/dashboard/presentation/provider/filter_controller.dart';
import '../color.dart';
import '../provider/spline_selection_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute l'état des filtres
    final filters = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Groupe de filtres
          Wrap(
            spacing: 14,
            children: [
              FilterSelectButton(
                label: 'Période',
                currentValue: filters.periode?.toString(), // À adapter pour le format date
                options: ['Aujourd\'hui', '7 derniers jours', 'Ce mois'],
                onSelected: (val) => {}, // Logique DateRangePicker
              ),
              FilterSelectButton(
                label: "Type",
                currentValue: filters.type,
                options: ['Consultation', 'Hospitalisation', 'Urgences', 'Exploration'],
                onSelected: notifier.updateType,
              ),
              FilterSelectButton(
                label: "Service",
                currentValue: filters.service,
                options: ['Cardiologie', 'Pédiatrie', 'Neurologie', 'Chirurgie'],
                onSelected: notifier.updateService,
              ),
              FilterSelectButton(
                label: "Exploration",
                currentValue: filters.exploration,
                options: ['Imagerie', 'Biologie', 'Fonctionnelle'],
                onSelected: (val) => notifier.state = notifier.state.copyWith(exploration: val),
              ),
              FilterSelectButton(
                label: 'Sortie',
                currentValue: filters.sortie,
                options: ['Post-hospitalisation', 'Suivi', 'Instructions'],
                onSelected: (val) => notifier.state = notifier.state.copyWith(sortie: val),
              ),
            ],
          ),
          const Spacer(),
          // Bouton Action
          ElevatedButton(
            onPressed: () {
              ref.read(filterProvider.notifier).applyFilters();
              ref.read(splineSelectionProvider.notifier).toggleSpline("Oui totalement");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981), // Vert propre
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Actualiser', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}