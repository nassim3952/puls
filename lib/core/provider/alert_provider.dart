import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:puls/core/models/patient.dart';
import 'patient_provider.dart';


class AlertsNotifier extends StateNotifier<Map<String, PatientModel>> {
  AlertsNotifier() : super({});

  // Étape 1 → 2 : assignation d'un plan
  void assignPlan(PatientModel patient, String label, String report) {
    final current = state[patient.id] ?? patient;
    final visit = current.latestVisit;
    if (visit == null) return;

    state = {
      ...state,
      patient.id: current.withUpdatedLatestVisit(
        visit.copyWith(
          actionPlanLabel: label,
          actionPlanReport: report,
          planIsValid: null,
        ),
      ),
    };
  }

  // Étape 2 → 3 validé
  void validatePlan(PatientModel patient) {
    final current = state[patient.id] ?? patient;
    final visit = current.latestVisit;
    if (visit == null) return;

    state = {
      ...state,
      patient.id: current.withUpdatedLatestVisit(
        visit.copyWith(
          hasAlert: false,
          planIsValid: true,
          resolvedAt: DateTime.now(),
        ),
      ),
    };
  }

  // Étape 2 → 1 rejeté
  void rejectPlan(PatientModel patient) {
    final current = state[patient.id] ?? patient;
    final visit = current.latestVisit;
    if (visit == null) return;

    state = {
      ...state,
      patient.id: current.withUpdatedLatestVisit(
        visit.copyWith(
          hasAlert: true,
          planIsValid: false,
          actionPlanLabel: null,
          actionPlanReport: null,
        ),
      ),
    };
  }

  void dismiss(String patientId) {
    final updated = Map<String, PatientModel>.from(state)..remove(patientId);
    state = updated;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final alertsNotifierProvider =
StateNotifierProvider<AlertsNotifier, Map<String, PatientModel>>(
      (ref) => AlertsNotifier(),
);

// Liste des patients avec alerte, overrides locaux appliqués
final alertsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final overrides = ref.watch(alertsNotifierProvider);

  return patientsAsync.whenData((list) {
    final alerts = list
        .where((p) => (overrides[p.id] ?? p).latestVisit?.hasAlert ?? false)
        .map((p) => overrides[p.id] ?? p)
        .toList()
      ..sort((a, b) {
        final dateA = a.latestVisit?.date ?? DateTime(0);
        final dateB = b.latestVisit?.date ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

    return alerts;
  });
});