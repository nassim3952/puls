// Le provider qui va charger et stocker la liste des patients
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/patient.dart';
import '../models/patient_service.dart';

class PatientFilters {
  final String service;
  final String typePriseEncharge;
  final String exploration;
  final String sortie;
  // On ajoutera la période plus tard, c'est un peu plus complexe

  PatientFilters({
    this.service = '',
    this.typePriseEncharge = '',
    this.exploration = '',
    this.sortie = '',
  });

  // Cette fonction permet de changer un seul filtre sans effacer les autres
  PatientFilters copyWith({
    String? service,
    String? typePriseEncharge,
    String? exploration,
    String? sortie,
  }) {
    return PatientFilters(
      service: service ?? this.service,
      typePriseEncharge: typePriseEncharge ?? this.typePriseEncharge,
      exploration: exploration ?? this.exploration,
      sortie: sortie ?? this.sortie,
    );
  }
}



// Par défaut, le filtre est vide (''), ce qui veut dire "Tous les services"
// patient_providers.dart

// 1. L'instance du service
final patientServiceProvider = Provider<PatientService>((ref) {
  return PatientService();
});

// 2. La liste brute (charge le JSON)
final patientsListProvider = FutureProvider<List<PatientModel>>((ref) async {
  final service = ref.watch(patientServiceProvider);
  return await service.fetchPatients();
});

// --- PARTIE FILTRAGE ---

// 3. La "boîte" qui stocke le service choisi (ex: 'Cardiologie')
final allFiltersProvider = StateProvider<PatientFilters>((ref) => PatientFilters());

// 4. La "passoire" qui trie les patients
final filteredPatientsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final allPatientsAsync = ref.watch(patientsListProvider);
  final filters = ref.watch(allFiltersProvider);

  return allPatientsAsync.whenData((patients) {
    return patients.where((p) {
      // Vérifie le Service
      final matchService = filters.service.isEmpty || p.service == filters.service;

      // Vérifie le Type (Consultation, Hospitalisation...)
      final matchType = filters.typePriseEncharge.isEmpty || p.visitType == filters.typePriseEncharge;

      // Vérifie l'Exploration
      final matchExplo = filters.exploration.isEmpty || p.exploration == filters.exploration;

      // Vérifie la Sortie
      // Change filters.afterCare par filters.sortie
      final matchSortie = filters.sortie.isEmpty || p.afterCare == filters.sortie;;

      // Le patient doit passer TOUS les tests
      return matchService && matchType && matchExplo && matchSortie;
    }).toList();
  });
});