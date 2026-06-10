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

  // Pas de search ici — la recherche se fait 100% en local dans historiqueListProvider.
  // Envoyer search à Supabase déclenchait un re-fetch à chaque keystroke,
  // ce qui freezait le whenData et vidait les résultats mid-saisie.
  return service.fetchFilteredPatients(
    service:     filters.service,
    type:        filters.type,
    exploration: filters.exploration,
    sortie:      filters.sortie,
    dateStart:   filters.periode?.start,
    dateEnd:     filters.periode?.end,
  );
});

// ── Liste historique : filtrée + triée + filtre alerte ───────────────────────
final historiqueListProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final filters = ref.watch(historiqueFilterProvider);

  return patientsAsync.whenData((patients) {
    var result = List<PatientModel>.from(patients);

    // ── Recherche ──────────────────────────────────────────────────────────
    // Split en tokens : "rania ben" → ["rania", "ben"]
    // Chaque token doit matcher → résiste à l'espace et à l'ordre des mots.
    final tokens = filters.searchQuery
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (tokens.isNotEmpty) {
      result = result.where((p) {
        if (filters.searchMode == SearchMode.patient) {
          final fullName = '${p.firstName} ${p.lastName}'.toLowerCase();
          final ipp = p.ipp.toLowerCase();
          return tokens.every((t) => fullName.contains(t) || ipp.contains(t));
        } else {
          // Recherche dans les verbatims de TOUTES les visites
          return p.visits.any((v) {
            final s = v.survey;
            if (s == null) return false;
            final corpus = '${s.raconteParcours.message} '
                '${s.momentMarquant.message} '
                '${s.suggestionsAmelioration.message}'
                .toLowerCase();
            return tokens.every((t) => corpus.contains(t));
          });
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