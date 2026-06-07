import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'package:puls/core/models/patient_service.dart';
import 'package:puls/core/provider/dashboard_kpi_provider.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'filter_controller.dart';

// ─── Notifier (update optimiste) ─────────────────────────────────────────────
class AlertsNotifier extends StateNotifier<Map<String, VisitModel>> {
  final SupabaseClient _supabase;
  final Ref _ref;

  AlertsNotifier(this._supabase, this._ref) : super({});

  VisitModel _effectiveVisit(VisitModel original) =>
      state[original.id] ?? original;

  // ── Invalide tous les providers après une action ──────────────────────────
  void _refresh() {
    _ref.invalidate(dashboardKpiProvider);
    _ref.invalidate(filteredPatientsProvider);
    // Pour les family providers, on invalide via la famille
    _ref.invalidate(activeAlertsProvider(null));
    _ref.invalidate(pendingAlertsProvider(null));
    _ref.invalidate(validatedAlertsProvider(null));
  }
  Future<void> assignPlan(VisitModel visit, String label, String report) async {
    final effective = _effectiveVisit(visit);
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
      _refresh();
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  Future<void> validatePlan(VisitModel visit) async {
    final effective = _effectiveVisit(visit);
    final now = DateTime.now();
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
      _refresh();
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  Future<void> rejectPlan(VisitModel visit) async {
    final effective = _effectiveVisit(visit);
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
      _refresh();
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }

  Future<void> dismiss(VisitModel visit) async {
    final effective = _effectiveVisit(visit);
    final snapshot = Map<String, VisitModel>.from(state);
    state = snapshot..remove(visit.id);
    try {
      await _supabase.from('survey_responses').update({
        'has_alert': false,
        'alert_resolved': true,
        'resolved_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('visit_id', visit.id);
      _refresh();
    } catch (_) {
      state = {...state, visit.id: effective};
      rethrow;
    }
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final alertsNotifierProvider =
StateNotifierProvider<AlertsNotifier, Map<String, VisitModel>>(
      (ref) => AlertsNotifier(Supabase.instance.client, ref), // 👈 ref passé
);

// ── Alertes par onglet ────────────────────────────────────────────────────────
AlertsTabProvider _makeAlertsTab(String tab) {
  return FutureProvider.family<List<PatientModel>, void>((ref, _) {
    final service = ref.watch(patientServiceProvider);
    final filters = ref.watch(filterProvider);
    final overrides = ref.watch(alertsNotifierProvider);

    return service.fetchAlerts(
      tab:         tab,
      service:     filters.service,
      type:        filters.type,
      exploration: filters.exploration,
      sortie:      filters.sortie,
      dateStart:   filters.periode?.start,
      dateEnd:     filters.periode?.end,
      search:      filters.searchQuery.isEmpty ? null : filters.searchQuery,
    ).then((patients) => _applyOverrides(patients, overrides));
  });
}

typedef AlertsTabProvider = FutureProvider<List<PatientModel>> Function(void);

final activeAlertsProvider    = _makeAlertsTab('active');
final pendingAlertsProvider   = _makeAlertsTab('pending');
final validatedAlertsProvider = _makeAlertsTab('validated');

// ── Helper overrides optimistes ───────────────────────────────────────────────
List<PatientModel> _applyOverrides(
    List<PatientModel> patients,
    Map<String, VisitModel> overrides,
    ) {
  if (overrides.isEmpty) return patients;

  return patients
      .map((p) {
    final patchedVisits = p.visits.map((v) {
      return overrides.containsKey(v.id) ? overrides[v.id]! : v;
    }).toList();
    return p.copyWith(visits: patchedVisits);
  })
      .where((p) => p.visits.isNotEmpty)
      .toList();
}