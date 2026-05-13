import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:puls/core/shared_widget/select_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../features/dashboard/presentation/provider/filter_controller.dart';
import '../provider/patient_provider.dart';
import '../provider/spline_selection_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/shared_widget/select_button.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../features/dashboard/presentation/provider/filter_controller.dart';
import '../provider/patient_provider.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(allFiltersProvider);
    final notifier = ref.read(allFiltersProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Container(
          constraints: const BoxConstraints(minHeight: 70),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
          ),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _buildFilterButtons(filters, notifier, context),
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
                  children: _buildFilterButtons(filters, notifier, context),
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

  List<Widget> _buildFilterButtons(
      PatientFilters filters,
      StateController<PatientFilters> notifier,
      BuildContext context,
      ) {
    return [
      // 1. FILTRE DURÉE
// 1. FILTRE DURÉE
    FilterSelectButton(
      label: "Durée",
      // Modifié : Si c'est 'all', on renvoie null pour que le bouton ne soit pas en surbrillance
      currentValue: filters.dateRange == DateRange.custom && filters.customRange != null
          ? "${filters.customRange!.start.day}/${filters.customRange!.start.month}"
          : (filters.dateRange == DateRange.all ? null :
      filters.dateRange == DateRange.week ? '7 jours' :
      filters.dateRange == DateRange.month ? '1 mois' : '1 an'),
      options: const ['Tout', '7 jours', '1 mois', '1 an', 'Personnalisé'],
      onSelected: (val) {
        if (val == 'Personnalisé') {
          _showCustomDatePicker(context, notifier);
        } else {
          DateRange selectedRange;
          switch (val) {
            case '7 jours': selectedRange = DateRange.week; break;
            case '1 mois':  selectedRange = DateRange.month; break;
            case '1 an':    selectedRange = DateRange.year; break;
            default:        selectedRange = DateRange.all;
          }
          notifier.update((state) => state.copyWith(dateRange: selectedRange, customRange: null));
        }
      },
    ),

      // 2. FILTRE TYPE
      FilterSelectButton(
        label: "Type",
        // On vérifie si la String est vide pour afficher le label
        currentValue: filters.typePriseEncharge.isEmpty ? null : filters.typePriseEncharge,
        options: const ['Tout', 'Consultation', 'Hospitalisation', 'Urgences', 'Exploration'],
        onSelected: (val) {
          // Utilise une chaîne vide pour réinitialiser le filtre dans le modèle
          notifier.update((state) => state.copyWith(typePriseEncharge: val == 'Tout' ? '' : val));
        },
      ),

      // 3. FILTRE SERVICE
      FilterSelectButton(
        label: "Service",
        currentValue: filters.service.isEmpty ? null : filters.service,
        options: const ['Tout', 'Cardiologie', 'Gynécologie-Obstétrique', 'Pédiatrie', 'Neurologie'],
        onSelected: (val) {
          notifier.update((state) => state.copyWith(service: val == 'Tout' ? '' : val));
        },
      ),

      // 4. FILTRE EXPLORATION
      FilterSelectButton(
        label: "Exploration",
        currentValue: filters.exploration.isEmpty ? null : filters.exploration,
        options: const ['Tout', 'Imagerie', 'Biologie / Laboratoire', 'Explorations Fonctionnelles'],
        onSelected: (val) {
          notifier.update((state) => state.copyWith(exploration: val == 'Tout' ? '' : val));
        },
      ),
    ];
  }

  Widget _buildActionButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => ref.invalidate(patientsListProvider),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      child: const Text('Réinitialiser', style: TextStyle(fontWeight: FontWeight.bold)),
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
      title: const Text("Sélectionner une période"),
      content: SizedBox(
        height: 350,
        width: 300,
        child: SfDateRangePicker(
          selectionMode: DateRangePickerSelectionMode.range,
          headerStyle: const DateRangePickerHeaderStyle(
            backgroundColor: Colors.white,
          ),
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
          child: const Text("Valider"),
        ),
      ],
    ),
  );
}
