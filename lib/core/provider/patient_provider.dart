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
  final filters = ref.watch(historiqueFilterProvider);

  return allPatientsAsync.whenData((patients) {
    var result = patients.where((p) {
      final v = p.latestVisit;
      if (v == null) return false;

      // ── Filtres existants ──────────────────────────────────────────────────
      final matchService = filters.serviceFilter.isEmpty
          ? true
          : v.service == filters.serviceFilter;

      final matchType = filters.typeFilter.isEmpty
          ? true
          : v.visitType == filters.typeFilter;

      final matchAlert = filters.alertFilter == 'all'
          ? true
          : filters.alertFilter == 'alert'
          ? (v.hasAlert == true)
          : (v.hasAlert != true);

      // ── Recherche ──────────────────────────────────────────────────────────
      final q = filters.searchQuery.toLowerCase().trim();
      bool matchSearch = true;

      if (q.isNotEmpty) {
        if (filters.searchMode == SearchMode.patient) {
          // Recherche par nom ou IPP
          matchSearch =
              '${p.firstName} ${p.lastName}'.toLowerCase().contains(q) ||
                  p.ipp.toLowerCase().contains(q);
        } else {
          // Recherche par mot-clé dans les verbatims
          final survey = v.survey;
          if (survey == null) {
            matchSearch = false;
          } else {
            final verbatims = [
              survey.raconteParcours.message,
              survey.momentMarquant.message,
              survey.suggestionsAmelioration.message,
            ];
            matchSearch = verbatims.any(
                  (msg) => msg.toLowerCase().contains(q),
            );
          }
        }
      }

      return matchService && matchType && matchAlert && matchSearch;
    }).toList();

    // ── Tri ───────────────────────────────────────────────────────────────────
    final asc = filters.sortDirection == SortDirection.asc;
    switch (filters.sortColumn) {
      case SortColumn.nom:
        result.sort((a, b) {
          final cmp =
          '${a.firstName} ${a.lastName}'.compareTo('${b.firstName} ${b.lastName}');
          return asc ? cmp : -cmp;
        });
        break;
      case SortColumn.date:
        result.sort((a, b) {
          final da = a.latestVisit?.date ?? DateTime(0);
          final db = b.latestVisit?.date ?? DateTime(0);
          return asc ? da.compareTo(db) : db.compareTo(da);
        });
        break;
      case SortColumn.service:
        result.sort((a, b) {
          final cmp = (a.latestVisit?.service ?? '').compareTo(b.latestVisit?.service ?? '');
          return asc ? cmp : -cmp;
        });
        break;
      case SortColumn.type:
        result.sort((a, b) {
          final cmp = (a.latestVisit?.visitType ?? '').compareTo(b.latestVisit?.visitType ?? '');
          return asc ? cmp : -cmp;
        });
        break;
      default:
        break;
    }

    return result;
  });
});