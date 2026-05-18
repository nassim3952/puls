import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/patient.dart';
import '../models/patient_service.dart';
import 'filter_controller.dart';

// 1. Définition des plages de dates
enum DateRange { week, month, year, all,custom }

// 2. Objet unique pour TOUS les filtres (Services + Date)
class PatientFilters {
  final String service;
  final String typePriseEncharge;
  final String exploration;
  final String sortie;
  final DateRange dateRange;
  final DateTimeRange? customRange;

  PatientFilters({
    this.service = '',
    this.typePriseEncharge = '',
    this.exploration = '',
    this.sortie = '',
    this.dateRange = DateRange.all,
    this.customRange,
  });

// Dans patient_provider.dart
  PatientFilters copyWith({
    String? service,
    String? typePriseEncharge,
    String? exploration,
    String? sortie,
    DateRange? dateRange,
    DateTimeRange? customRange, // On repasse en type simple
  }) {
    return PatientFilters(
      service: service ?? this.service,
      typePriseEncharge: typePriseEncharge ?? this.typePriseEncharge,
      exploration: exploration ?? this.exploration,
      sortie: sortie ?? this.sortie,
      dateRange: dateRange ?? this.dateRange,
      // On utilise l'ancienne valeur seulement si la nouvelle est strictement nulle
      // ET que ce n'est pas un changement de dateRange (pour éviter les conflits)
      customRange: customRange ?? this.customRange,
    );
  }}
// 3. Instance du service
final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

// 4. Source de données brute (JSON)
final patientsListProvider = FutureProvider<List<PatientModel>>((ref) async {
  final service = ref.watch(patientServiceProvider);
  return await service.fetchPatients();
});

// patient_provider.dart

// (Supprime l'ancien allFiltersProvider qui était un StateProvider)

// 6. LA PASSOIRE UNIQUE : Écoute désormais le DashboardFilterState du Notifier
final filteredPatientsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final allPatientsAsync = ref.watch(patientsListProvider);
  // On écoute le vrai contrôleur du Dashboard !
  final filters = ref.watch(filterProvider);

  return allPatientsAsync.whenData((patients) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return patients.where((p) {
      // --- FILTRAGE PAR CATÉGORIE ---
      final matchService = filters.service == null || filters.service!.isEmpty || p.service == filters.service;
      final matchType = filters.type == null || filters.type!.isEmpty || p.visitType == filters.type;
      final matchExplo = filters.exploration == null || filters.exploration!.isEmpty || p.exploration == filters.exploration;
      final matchSortie = filters.sortie == null || filters.sortie!.isEmpty || p.afterCare == filters.sortie;

      // --- FILTRAGE PAR DATE (DateTimeRange unique) ---
      bool matchDate = true;
      if (filters.periode != null) {
        // On vérifie si la date du patient est comprise dans la plage sélectionnée
        // .add(Duration(days: 1)) pour inclure totalement le dernier jour du filtre
        matchDate = p.date.isAfter(filters.periode!.start) &&
            p.date.isBefore(filters.periode!.end.add(const Duration(days: 1)));
      }

      return matchService && matchType && matchExplo && matchSortie && matchDate;
    }).toList();
  });
});