import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/historique/presentation/historique_screen.dart' hide historiqueFilterProvider;
import '../models/patient.dart';
import '../models/patient_service.dart';
import 'filter_controller.dart';
import 'historique_filter_controller.dart';

final patientsListProvider = FutureProvider<List<PatientModel>>((ref) {
  return ref.watch(patientServiceProvider).fetchPatients();
});

final filteredPatientsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final allPatientsAsync = ref.watch(patientsListProvider);
  final filters = ref.watch(filterProvider); // ✅ était historiqueFilterProvider

  return allPatientsAsync.whenData((patients) {
    return patients.where((p) {
      final v = p.latestVisit;
      if (v == null) return false;

      // ── Filtres dropdowns ──────────────────────────────────────────────────
      final matchService = filters.service == null || filters.service!.isEmpty
          ? true
          : v.service == filters.service;

      final matchType = filters.type == null || filters.type!.isEmpty
          ? true
          : v.visitType == filters.type;

      final matchExplo =
      filters.exploration == null || filters.exploration!.isEmpty
          ? true
          : v.exploration == filters.exploration;

      final matchSortie =
      filters.sortie == null || filters.sortie!.isEmpty
          ? true
          : v.afterCare == filters.sortie;

      bool matchDate = true;
      if (filters.periode != null) {
        matchDate = v.date.isAfter(filters.periode!.start) &&
            v.date.isBefore(
                filters.periode!.end.add(const Duration(days: 1)));
      }

      // ── Recherche (AppBar searchQuery) ─────────────────────────────────────
      final q = filters.searchQuery.toLowerCase().trim();
      bool matchSearch = true;
      if (q.isNotEmpty) {
        matchSearch =
            '${p.firstName} ${p.lastName}'.toLowerCase().contains(q) ||
                p.ipp.toLowerCase().contains(q);
      }

      return matchService &&
          matchType &&
          matchExplo &&
          matchSortie &&
          matchDate &&
          matchSearch;
    }).toList();
  });
});