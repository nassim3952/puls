

// ── Liste filtrée → dashboard, alertes ───────────────────────────────────────
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/historique_filter_controller.dart';

import '../../features/historique/presentation/historique_screen.dart';
import '../models/patient.dart';
import '../models/patient_service.dart';
import 'filter_controller.dart';

final filteredPatientsProvider = FutureProvider<List<PatientModel>>((ref) {
  final service = ref.watch(patientServiceProvider);
  final filters = ref.watch(filterProvider);

  return service.fetchFilteredPatients(
    service:     filters.service,
    type:        filters.type,
    exploration: filters.exploration,
    sortie:      filters.sortie,
    dateStart:   filters.periode?.start,
    dateEnd:     filters.periode?.end,
    search:      filters.searchQuery.isEmpty ? null : filters.searchQuery,
  );
});

// ── Liste historique : filtrée + triée + filtre alerte ───────────────────────
// Lit filteredPatientsProvider (déjà fetché) et applique les filtres locaux
// spécifiques à l'écran historique (alertFilter, sort, recherche verbatim).
final historiqueListProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final filters = ref.watch(historiqueFilterProvider);

  return patientsAsync.whenData((patients) {
    var result = List<PatientModel>.from(patients);

    // ── Recherche ──────────────────────────────────────────────────────────
    final q = filters.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((p) {
        if (filters.searchMode == SearchMode.patient) {
          // Recherche par nom / prénom / IPP
          return p.firstName.toLowerCase().contains(q) ||
              p.lastName.toLowerCase().contains(q) ||
              p.ipp.toLowerCase().contains(q);
        } else {
          // Recherche dans les verbatims
          final s = p.latestVisit?.survey;
          if (s == null) return false;
          return s.raconteParcours.message.toLowerCase().contains(q) ||
              s.momentMarquant.message.toLowerCase().contains(q) ||
              s.suggestionsAmelioration.message.toLowerCase().contains(q);
        }
      }).toList();
    }

    // ── Filtre alerte ──────────────────────────────────────────────────────
    if (filters.alertFilter != 'all') {
      result = result.where((p) {
        final v = p.latestVisit;
        if (v == null) return false;
        return switch (filters.alertFilter) {
          'alert' => v.hasAlert,
          'ok'    => !v.hasAlert,
          _       => true,
        };
      }).toList();
    }

    // ── Tri ────────────────────────────────────────────────────────────────
    result.sort((a, b) {
      final va = a.latestVisit;
      final vb = b.latestVisit;
      if (va == null || vb == null) return 0;

      final cmp = switch (filters.sortColumn) {
        SortColumn.nom => '${a.lastName} ${a.firstName}'
            .compareTo('${b.lastName} ${b.firstName}'),
        SortColumn.date    => va.date.compareTo(vb.date),
        SortColumn.service => va.service.compareTo(vb.service),
        SortColumn.type    => va.visitType.compareTo(vb.visitType),
        SortColumn.score   => (va.survey?.qualitePriseEnCharge ?? 0)
            .compareTo(vb.survey?.qualitePriseEnCharge ?? 0),
        SortColumn.none => 0,
      };

      return filters.sortDirection == SortDirection.desc ? -cmp : cmp;
    });

    return result;
  });
});