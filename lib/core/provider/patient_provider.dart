import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/patient.dart';
import '../models/patient_service.dart';

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

// 5. La "Boîte" qui stocke l'état actuel de tous tes filtres
final allFiltersProvider = StateProvider<PatientFilters>((ref) => PatientFilters());

// 6. LA PASSOIRE UNIQUE : Filtre par Service ET par Date
final filteredPatientsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final allPatientsAsync = ref.watch(patientsListProvider);
  final filters = ref.watch(allFiltersProvider);

  return allPatientsAsync.whenData((patients) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return patients.where((p) {
      // --- FILTRAGE PAR CATÉGORIE ---
      final matchService = filters.service.isEmpty || p.service == filters.service;
      final matchType = filters.typePriseEncharge.isEmpty || p.visitType == filters.typePriseEncharge;
      final matchExplo = filters.exploration.isEmpty || p.exploration == filters.exploration;
      final matchSortie = filters.sortie.isEmpty || p.afterCare == filters.sortie;

      // --- FILTRAGE PAR DATE ---
      bool matchDate = true;
      final difference = today.difference(p.date).inDays;

      switch (filters.dateRange) {
        case DateRange.week:
          matchDate = difference <= 7 && difference >= 0;
          break;
        case DateRange.month:
          matchDate = difference <= 30 && difference >= 0;
          break;
        case DateRange.year:
          matchDate = difference <= 365 && difference >= 0;
          break;
        case DateRange.custom:
          if (filters.customRange != null) {
            // On vérifie si la date du patient est entre le début et la fin
            return p.date.isAfter(filters.customRange!.start) &&
                p.date.isBefore(filters.customRange!.end.add(const Duration(days: 1)));
          }
          return true;
        case DateRange.all:
          matchDate = true;
          break;
      }

      // Le patient doit valider TOUS les critères
      return matchService && matchType && matchExplo && matchSortie && matchDate;
    }).toList();
  });
});