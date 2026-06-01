import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';
import '../models/patient_service.dart';
import 'filter_controller.dart';

final patientsListProvider = FutureProvider<List<PatientModel>>((ref) {
  return ref.watch(patientServiceProvider).fetchPatients();
});

final filteredPatientsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final allPatientsAsync = ref.watch(patientsListProvider);
  final filters = ref.watch(filterProvider);

  return allPatientsAsync.whenData((patients) {
    return patients.where((p) {
      final v = p.latestVisit;
      if (v == null) return false;

      final matchService = filters.service == null || filters.service!.isEmpty
          ? true
          : v.service == filters.service;

      final matchType = filters.type == null || filters.type!.isEmpty
          ? true
          : v.visitType == filters.type;

      final matchExplo = filters.exploration == null || filters.exploration!.isEmpty
          ? true
          : v.exploration == filters.exploration;

      final matchSortie = filters.sortie == null || filters.sortie!.isEmpty
          ? true
          : v.afterCare == filters.sortie;

      var matchDate = true;
      if (filters.periode != null) {
        matchDate = v.date.isAfter(filters.periode!.start) &&
            v.date.isBefore(filters.periode!.end.add(const Duration(days: 1)));
      }
      final matchSearch = filters.searchQuery.isEmpty
          ? true
          : '${p.firstName} ${p.lastName}'.toLowerCase()
          .contains(filters.searchQuery.toLowerCase()) ||
          p.ipp.toLowerCase().contains(filters.searchQuery.toLowerCase());

      return matchService && matchType && matchExplo && matchSortie && matchDate && matchSearch;

      return matchService && matchType && matchExplo && matchSortie && matchDate;
    }).toList();
  });
});