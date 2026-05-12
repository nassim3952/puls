import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/select_button.dart';

import '../../features/dashboard/presentation/provider/filter_controller.dart';
import '../provider/patient_provider.dart';
import '../provider/spline_selection_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(allFiltersProvider);
    final notifier = ref.read(allFiltersProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        // On vérifie si on est sur un petit écran (mobile/petite fenêtre)
        bool isMobile = constraints.maxWidth < 800;

        return Container(
          // On enlève la hauteur fixe de 70 pour permettre l'expansion si le Wrap revient à la ligne
          constraints: const BoxConstraints(minHeight: 70),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: isMobile
              ? Column(
            // Version Mobile : On empile verticalement
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10, // Espace entre les lignes de filtres
                children: _buildFilterButtons(filters, notifier),
              ),
              const SizedBox(height: 16),
              _buildActionButton(ref),
            ],
          )
              : Row(
            // Version Desktop : Ta ligne actuelle bien alignée
            children: [
              Expanded(
                child: Wrap(
                  spacing: 14,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _buildFilterButtons(filters, notifier),
                ),
              ),
              const SizedBox(width: 20),
              _buildActionButton(ref),
            ],
          ),
        );
      },
    );
  }

// Pour garder le code propre, on sépare les widgets
  List<Widget> _buildFilterButtons(filters, notifier) {
    return [
      // ... Bouton Période (on le laisse vide pour l'instant) ...

      FilterSelectButton(
        label: "Type",
        currentValue: filters.typePriseEncharge, // Attention au nom dans ta classe !
        options: ['Consultation', 'Hospitalisation', 'Urgences', 'Exploration'],
        onSelected: (val) => notifier.state = notifier.state.copyWith(typePriseEncharge: val),
      ),
      FilterSelectButton(
        label: "Service",
        currentValue: filters.service,
        options: ['Cardiologie', 'Gynécologie-Obstétrique', 'Pédiatrie', 'Neurologie'],
        onSelected: (val) => notifier.state = notifier.state.copyWith(service: val),
      ),
      FilterSelectButton(
        label: "Exploration",
        currentValue: filters.exploration,
        options: ['Imagerie', 'Biologie / Laboratoire', 'Explorations Fonctionnelles'],
        onSelected: (val) => notifier.state = notifier.state.copyWith(exploration: val),
      ),
      FilterSelectButton(
        label: 'Sortie',
        currentValue: filters.sortie,
        options: ['Post-hospitalisation', 'Consultation de suivi', 'Instructions de sortie'],
        onSelected: (val) => notifier.state = notifier.state.copyWith(sortie: val),
      ),
    ];
  }
  Widget _buildActionButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () {
        ref.invalidate(patientsListProvider);

      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: const Text('Actualiser', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }}
