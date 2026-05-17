import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:puls/core/shared_widget/select_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../features/historique/historique_screen.dart';
import '../color.dart';
import '../provider/patient_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //TODO: remove allfiltersProvider
    final filters = ref.watch(allFiltersProvider);
    final notifier = ref.read(allFiltersProvider.notifier);


    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Container(
          child: Padding(
            padding: EdgeInsets.only(top: 24,right: 24,left: 24),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _buildFilterButtons(
                          filters,
                          notifier,
                          context,
                        ),
                      ),

                      const SizedBox(height: 16),
                      _buildActionButton(ref),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 14,
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: _buildFilterButtons(
                            filters,
                            notifier,
                            context,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      if (filters != const HistoriqueFilterState())
                      _buildActionButton(ref),
                    ],
                  ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFilterButtons(
    PatientFilters filters,
    StateController<PatientFilters> notifier,
    BuildContext context,
  ) {
    // Préparation des options pour le filtre Durée
    List<String> dureeOptions = [
      'Tout',
      '7 jours',
      '1 mois',
      '1 an',
      'Personnalisé',
    ];
    String? currentDureeValue;

    // Logique corrigée pour la valeur du filtre Durée
    if (filters.dateRange == DateRange.custom && filters.customRange != null) {
      // Pour éviter l'erreur d'assertion, la valeur doit être dans la liste.
      // On utilise "Personnalisé" comme valeur sélectionnée.
      currentDureeValue = 'Personnalisé';

      // Note : Si votre SelectButton affiche directement 'value',
      // il faudra peut-être modifier SelectButton pour accepter un 'displayLabel'
      // ou ajouter la date dynamiquement à la liste comme ceci :
      // String dateStr = "${filters.customRange!.start.day}/${filters.customRange!.start.month}";
      // dureeOptions.add(dateStr);
      // currentDureeValue = dateStr;
    } else {
      currentDureeValue = (filters.dateRange == DateRange.all
          ? null // Affiche le label "Durée" par défaut
          : filters.dateRange == DateRange.week
          ? '7 jours'
          : filters.dateRange == DateRange.month
          ? '1 mois'
          : '1 an');
    }

    return [
      // 1. FILTRE DURÉE (CORRIGÉ)
      FilterSelectButton(
        label: "Durée",
        value: currentDureeValue,
        options: dureeOptions,
        onSelected: (val) {
          if (val == 'Personnalisé') {
            _showCustomDatePicker(context, notifier);
          } else {
            DateRange selectedRange;
            switch (val) {
              case '7 jours':
                selectedRange = DateRange.week;
                break;
              case '1 mois':
                selectedRange = DateRange.month;
                break;
              case '1 an':
                selectedRange = DateRange.year;
                break;
              default:
                selectedRange = DateRange.all;
            }
            notifier.update(
              (state) =>
                  state.copyWith(dateRange: selectedRange, customRange: null),
            );
          }
        },
      ),

      // 2. FILTRE TYPE
      FilterSelectButton(
        label: "Type",
        // On vérifie si la String est vide pour afficher le label
        value: filters.typePriseEncharge.isEmpty
            ? null
            : filters.typePriseEncharge,
        options: const [
          'Tout',
          'Consultation',
          'Hospitalisation',
          'Urgences',
          'Exploration',
        ],
        onSelected: (val) {
          // Utilise une chaîne vide pour réinitialiser le filtre dans le modèle
          notifier.update(
            (state) =>
                state.copyWith(typePriseEncharge: val == 'Tout' ? '' : val),
          );
        },
      ),

      // 3. FILTRE SERVICE
      FilterSelectButton(
        label: "Service",
        value: filters.service.isEmpty ? null : filters.service,
        options: const [
          'Tout',
          'Cardiologie',
          'Gynécologie-Obstétrique',
          'Pédiatrie',
          'Neurologie',
        ],
        onSelected: (val) {
          notifier.update(
            (state) => state.copyWith(service: val == 'Tout' ? '' : val),
          );
        },
      ),

      // 4. FILTRE EXPLORATION
      FilterSelectButton(
        label: "Exploration",
        value: filters.exploration.isEmpty ? null : filters.exploration,
        options: const [
          'Tout',
          'Imagerie',
          'Biologie / Laboratoire',
          'Explorations Fonctionnelles',
        ],
        onSelected: (val) {
          notifier.update(
            (state) => state.copyWith(exploration: val == 'Tout' ? '' : val),
          );
        },
      ),
    ];
  }

  Widget _buildActionButton(WidgetRef ref) {
    return  TextButton.icon(
      onPressed: () {
        //TODO ajouter la logique du reset
      },
      icon: const Icon(Icons.refresh_rounded, size: 16),
      label: const Text('Réinitialiser'),
      style: TextButton.styleFrom(
        foregroundColor: MintTheme.mint600,
        textStyle: const TextStyle(fontSize: 13),
      ),
    );

  }
}

void _showCustomDatePicker(
  BuildContext context,

  StateController<PatientFilters> notifier,
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
          headerStyle: DateRangePickerHeaderStyle(
            backgroundColor: AppColors.surface,
          ),

          backgroundColor: AppColors.surface,
          selectionColor: AppColors.primaryMenthe,
          endRangeSelectionColor: AppColors.primaryMenthe,
          startRangeSelectionColor: AppColors.primaryMenthe,
          rangeSelectionColor: AppColors.primaryMenthe.withValues(alpha: 0.2),
          todayHighlightColor: AppColors.primaryMenthe,
          selectionMode: DateRangePickerSelectionMode.range,

          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            if (args.value is PickerDateRange) {
              final range = args.value as PickerDateRange;

              if (range.startDate != null && range.endDate != null) {
                notifier.update(
                  (state) => state.copyWith(
                    dateRange: DateRange.custom,

                    customRange: DateTimeRange(
                      start: range.startDate!,

                      end: range.endDate!,
                    ),
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

          child: const Text("Valider",style: TextStyle(color: AppColors.primaryMenthe),),
        ),
      ],
    ),
  );
}
