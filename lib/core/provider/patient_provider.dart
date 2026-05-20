import 'package:flutter/material.dart';
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
      // Le filtre s'applique sur la visite la plus récente
      final v = p.latestVisit;
      if (v == null) return false;

      final matchService =
          filters.service?.isEmpty ?? true || v.service == filters.service;
      final matchType =
          filters.type?.isEmpty ?? true || v.visitType == filters.type;
      final matchExplo =
          filters.exploration?.isEmpty ?? true || v.exploration == filters.exploration;
      final matchSortie =
          filters.sortie?.isEmpty ?? true || v.afterCare == filters.sortie;

      var matchDate = true;
      if (filters.periode != null) {
        matchDate = v.date.isAfter(filters.periode!.start) &&
            v.date.isBefore(filters.periode!.end.add(const Duration(days: 1)));
      }

      return matchService && matchType && matchExplo && matchSortie && matchDate;
    }).toList();
  });
});