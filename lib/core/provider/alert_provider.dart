// alert_provider.dart
// Refacto multi-visites :
//  - Map<String, PatientModel> → Map<String, VisitModel> keyed par visit.id
//  - Toutes les actions opèrent sur visit.id (cohérent avec les writes Supabase)
//  - alertsProvider reconstruit les patients avec les visites patchées

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'filter_controller.dart';
import 'patient_provider.dart';

// ─── Notifier ─────────────────────────────────────────────────────────────────

class AlertsNotifier extends StateNotifier<Map<String, VisitModel>> {
  final SupabaseClient _supabase;

  AlertsNotifier(this._supabase) : super({});

  // ── Helper : récupère la visite effective (override ou originale) ─────────

  VisitModel _effectiveVisit(VisitModel original) =>
      state[original.id] ?? original;

  // ── Étape 1 → 2 : assigner un plan ───────────────────────────────────────

  Future<void> assignPlan(
      VisitModel visit,
      String label,
      String report,
      ) async {
    final effective = _effectiveVisit(visit);

    // Optimistic update
    state = {
      ...state,
      visit.id: effective.copyWith(
        actionPlanLabel: label,
        actionPlanReport: report,
        planIsValid: null,
      ),
    };

    try {
      await _supabase.from('survey_responses').update({
        'action_plan_label': label,
        'action_plan_report': report,
        'plan_is_valid': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('visit_id', visit.id);
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  // ── Étape 2 → 3 : valider le plan ────────────────────────────────────────

  Future<void> validatePlan(VisitModel visit) async {
    final effective = _effectiveVisit(visit);
    final now = DateTime.now();

    // Optimistic update
    state = {
      ...state,
      visit.id: effective.copyWith(
        hasAlert: false,
        alertResolved: true,
        planIsValid: true,
        resolvedAt: now,
      ),
    };

    try {
      await _supabase.from('survey_responses').update({
        'has_alert': false,
        'alert_resolved': true,
        'plan_is_valid': true,
        'resolved_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      }).eq('visit_id', visit.id);
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  // ── Étape 2 → 1 : rejeter le plan ────────────────────────────────────────

  Future<void> rejectPlan(VisitModel visit) async {
    final effective = _effectiveVisit(visit);

    // Optimistic update
    state = {
      ...state,
      visit.id: effective.copyWith(
        hasAlert: true,
        planIsValid: false,
        actionPlanLabel: null,
        actionPlanReport: null,
      ),
    };

    try {
      await _supabase.from('survey_responses').update({
        'plan_is_valid': false,
        'action_plan_label': null,
        'action_plan_report': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('visit_id', visit.id);
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  // ── Dismiss : ignorer une alerte ─────────────────────────────────────────

  Future<void> dismiss(VisitModel visit) async {
    final effective = _effectiveVisit(visit);

    // Retrait optimiste
    final snapshot = Map<String, VisitModel>.from(state);
    state = snapshot..remove(visit.id);

    try {
      await _supabase.from('survey_responses').update({
        'has_alert': false,
        'alert_resolved': true,
        'resolved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('visit_id', visit.id);
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final alertsNotifierProvider =
StateNotifierProvider<AlertsNotifier, Map<String, VisitModel>>(
      (ref) => AlertsNotifier(Supabase.instance.client),
);

// ─── alertsProvider ───────────────────────────────────────────────────────────
// Retourne la liste des PatientModel avec leurs visites patchées par les overrides.
// Un patient apparaît si au moins une de ses visites a :
//   - hasAlert == true  (onglets 1 et 2)
//   - planIsValid == true  (onglet 3)
final alertsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(patientsListProvider);
  final overrides = ref.watch(alertsNotifierProvider);
  final filters = ref.watch(filterProvider); // 👈 ajoute ça

  return patientsAsync.whenData((list) {
    final result = <PatientModel>[];

    for (final patient in list) {
      final patchedVisits = patient.visits.map((v) {
        return overrides.containsKey(v.id) ? overrides[v.id]! : v;
      }).toList();

      // 👇 Filtre les visites selon les filtres actifs
      final filteredVisits = patchedVisits.where((v) {
        final matchService = filters.service == null || filters.service!.isEmpty
            ? true : v.service == filters.service;
        final matchType = filters.type == null || filters.type!.isEmpty
            ? true : v.visitType == filters.type;
        final matchExplo = filters.exploration == null || filters.exploration!.isEmpty
            ? true : v.exploration == filters.exploration;
        final matchSortie = filters.sortie == null || filters.sortie!.isEmpty
            ? true : v.afterCare == filters.sortie;

        var matchDate = true;
        if (filters.periode != null) {
          matchDate = v.date.isAfter(filters.periode!.start) &&
              v.date.isBefore(filters.periode!.end.add(const Duration(days: 1)));
        }

        return matchService && matchType && matchExplo && matchSortie && matchDate;
      }).toList();

      final hasRelevantVisit = filteredVisits.any(
            (v) => v.hasAlert || v.planIsValid == true,
      );

      if (hasRelevantVisit) {
        result.add(patient.copyWith(visits: filteredVisits));
      }
    }

    // Tri par date de la visite la plus récente en alerte
    result.sort((a, b) {
      final dateA = a.visits
          .where((v) => v.hasAlert || v.planIsValid == true)
          .map((v) => v.date)
          .fold(DateTime(0), (prev, d) => d.isAfter(prev) ? d : prev);
      final dateB = b.visits
          .where((v) => v.hasAlert || v.planIsValid == true)
          .map((v) => v.date)
          .fold(DateTime(0), (prev, d) => d.isAfter(prev) ? d : prev);
      return dateB.compareTo(dateA);
    });

    return result;
  });
});