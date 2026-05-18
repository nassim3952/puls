import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:puls/core/models/patient.dart';

import 'patient_provider.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class AlertsNotifier extends StateNotifier<Map<String, PatientModel>> {
  AlertsNotifier() : super({});

  /// Étape 1 → 2 : assigne un plan d'action (label + rapport)
  /// On passe le PatientModel complet en cas où il n'est pas encore dans le state local
  void assignPlan(PatientModel patient, String label, String report) {
    final current = state[patient.id] ?? patient;
    state = {
      ...state,
      patient.id: current.copyWith(
        actionPlanLabel: label,
        actionPlanReport: report,
        planIsValid: null,
      ),
    };
  }

  /// Étape 2 → 3 validé : résout l'alerte
  void validatePlan(PatientModel patient) {
    final current = state[patient.id] ?? patient;
    state = {
      ...state,
      patient.id: current.copyWith(
        hasAlert: false,
        planIsValid: true,
        resolvedAt: DateTime.now(),
      ),
    };
  }

  /// Étape 2 → 1 rejeté : remet l'alerte active, marque comme non-valide
  void rejectPlan(PatientModel patient) {
    final current = state[patient.id] ?? patient;
    state = {
      ...state,
      patient.id: current.copyWith(
        hasAlert: true,
        planIsValid: false,
        actionPlanLabel: null,
        actionPlanReport: null,
      ),
    };
  }

  /// Supprime un patient de la vue (dismiss local)
  void dismiss(String patientId) {
    final updated = Map<String, PatientModel>.from(state);
    updated.remove(patientId);
    state = updated;
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final alertsNotifierProvider =
StateNotifierProvider<AlertsNotifier, Map<String, PatientModel>>(
      (ref) => AlertsNotifier(),
);

/// Provider dérivé qui merge la liste réseau + les overrides locaux
final alertsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final overrides = ref.watch(alertsNotifierProvider);

  return patientsAsync.whenData((list) {
    final alerts = list.where((p) => p.hasAlert).toList();
    alerts.sort((a, b) => b.date.compareTo(a.date));

    // Merge : override local prime sur la donnée réseau
    // Pas besoin de seeding — si le patient n'est pas dans overrides, on prend p directement
    return alerts.map((p) => overrides[p.id] ?? p).toList();
  });
});