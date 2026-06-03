import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/select_button.dart';
import 'package:puls/core/shared_widget/result_number.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../features/dashboard/model/domain/filtred_state.dart';
import '../color.dart';

// Import de tes nouveaux fichiers de gestion d'état
import '../provider/filter_controller.dart';
import 'build_reset_button.dart';

class DashboardHeader extends ConsumerWidget {
  final bool showResultChip;
  const DashboardHeader({super.key, this.showResultChip = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le nouvel état unifié du Dashboard
    final filters = ref.watch(filterProvider);
    // On récupère le Notifier pour appeler ses méthodes propres
    final notifier = ref.read(filterProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            child: isMobile
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ..._buildFilterButtons(
                      filters,
                      notifier,
                      context,
                    ),
                    if (showResultChip) const ResultNumber(),
                  ],
                ),
                const SizedBox(height: 16),
                buildResetButton(notifier),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ..._buildFilterButtons(
                        filters,
                        notifier,
                        context,
                      ),
                      if (showResultChip) const ResultNumber(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Si l'état n'est pas l'état initial (vide), on affiche le bouton reset
                if (filters != const DashboardFilterState())
                  buildResetButton(notifier),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterButtons(
      DashboardFilterState filters,
      DashboardFilterNotifier notifier,
      BuildContext context,
      ) {
    List<String> dureeOptions = [
      '7 jours',
      '1 mois',
      '1 an',
      'Personnalisé',
    ];
    String? currentDureeValue;

    // Logique de détection de la plage sélectionnée pour l'UI
    if (filters.periode != null) {
      final difference = filters.periode!.end.difference(filters.periode!.start).inDays;
      // On essaie de deviner si ça correspond à un raccourci, sinon c'est du personnalisé
      if (difference == 7) {
        currentDureeValue = '7 jours';
      } else if (difference >= 28 && difference <= 31) {
        currentDureeValue = '1 mois';
      } else if (difference >= 364 && difference <= 366) {
        currentDureeValue = '1 an';
      } else {
        currentDureeValue = 'Personnalisé';
      }
    } else {
      currentDureeValue = null; // Label "Durée" par défaut
    }

    return [
      // 1. FILTRE DURÉE
      FilterSelectButton(
        label: "Durée",
        value: currentDureeValue,
        options: dureeOptions,
        onSelected: (val) {
          if (val == 'Personnalisé') {
            _showCustomDatePicker(context, notifier);
          } else {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);

            switch (val) {
              case '7 jours':
                notifier.updatePeriode(DateTimeRange(start: today.subtract(const Duration(days: 7)), end: today));
                break;
              case '1 mois':
                notifier.updatePeriode(DateTimeRange(start: today.subtract(const Duration(days: 30)), end: today));
                break;
              case '1 an':
                notifier.updatePeriode(DateTimeRange(start: today.subtract(const Duration(days: 365)), end: today));
                break;
              default:
                notifier.updatePeriode(null); // Tout
            }
          }
        },
      ),

      // 2. FILTRE TYPE
      FilterSelectButton(
        label: "Type",
        value: (filters.type == null || filters.type!.isEmpty) ? null : filters.type,
        options: const [
          'Consultation',
          'Hospitalisation',
          'Urgences',
          'Exploration',
        ],
        onSelected: (val) {
          notifier.updateType(val == 'Tout' ? '' : val);
        },
      ),

      // 3. FILTRE SERVICE
      FilterSelectButton(
        label: "Service",
        value: (filters.service == null || filters.service!.isEmpty) ? null : filters.service,
        options: const [
          "Admin & Gestion",
          "Cardiologie",
          "Gynécologie-Obstétrique",
          "Medecine interne",
          "Pédiatrie",
          "Neurologie",
          "Rhumatologie & Rééducation",
          "Dermatologie",
          "Pneumologie",
          "Gastro-entérologie",
          "Chirurgie",
          "Oncologie",
          "Imagerie",
          "Laboratoire",
          "Soins de Support",
        ],
        onSelected: (val) {
          notifier.updateService(val == 'Tout' ? '' : val);
        },
      ),

      // 4. FILTRE EXPLORATION
      FilterSelectButton(
        label: "Exploration",
        value: (filters.exploration == null || filters.exploration!.isEmpty) ? null : filters.exploration,
        options: const [
          'Imagerie',
          'Biologie / Laboratoire',
          'Explorations Fonctionnelles',
        ],
        onSelected: (val) {
          notifier.updateExploration(val == 'Tout' ? '' : val);
        },
      ),
    ];
  }
}

void _showCustomDatePicker(
    BuildContext context,
    DashboardFilterNotifier notifier,
    ) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text("Sélectionner une période"),
      content: SizedBox(
        height: 350,
        width: 300,
        child: SfDateRangePicker(
          headerStyle: const DateRangePickerHeaderStyle(
            backgroundColor: AppColors.surface,
          ),
          backgroundColor: AppColors.surface,
          selectionColor: AppColors.primaryBlue,
          endRangeSelectionColor: AppColors.primaryBlue,
          startRangeSelectionColor: AppColors.primaryBlue,
          rangeSelectionColor: AppColors.primaryBlue.withOpacity(0.2),
          todayHighlightColor: AppColors.primaryBlue,
          selectionMode: DateRangePickerSelectionMode.range,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is PickerDateRange) {
              final range = args.value as PickerDateRange;
              if (range.startDate != null && range.endDate != null) {
                notifier.updatePeriode(
                  DateTimeRange(
                    start: range.startDate!,
                    end: range.endDate!,
                  ),
                );
              }
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            "Valider",
            style: TextStyle(color: AppColors.primaryBlue),
          ),
        ),
      ],
    ),
  );
}