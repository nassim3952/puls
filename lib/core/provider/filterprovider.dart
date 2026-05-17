import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';

import '../../features/historique/historique_screen.dart';
import '../models/patient.dart';

final filteredHistoriqueProvider = Provider<AsyncValue<List<PatientModel>>>((
    ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final filters = ref.watch(historiqueFilterProvider);

  return patientsAsync.whenData((patients) {
    var list = patients.where((p) {
      final fullName = '${p.firstName} ${p.lastName}'.toLowerCase();
      final matchSearch = filters.searchQuery.isEmpty ||
          fullName.contains(filters.searchQuery.toLowerCase()) ||
          p.ipp.contains(filters.searchQuery);
      final matchService =
          filters.serviceFilter.isEmpty || p.service == filters.serviceFilter;
      final matchType =
          filters.typeFilter.isEmpty || p.visitType == filters.typeFilter;
      final matchAlert = filters.alertFilter == 'all' ||
          (filters.alertFilter == 'alert' && p.hasAlert) ||
          (filters.alertFilter == 'ok' && !p.hasAlert);
      return matchSearch && matchService && matchType && matchAlert;
    }).toList();

    // Tri
    list.sort((a, b) {
      int cmp = 0;
      switch (filters.sortColumn) {
        case SortColumn.nom:
          cmp = '${a.firstName} ${a.lastName}'
              .compareTo('${b.firstName} ${b.lastName}');
          break;
        case SortColumn.date:
          cmp = a.date.compareTo(b.date);
          break;
        case SortColumn.service:
          cmp = a.service.compareTo(b.service);
          break;
        case SortColumn.type:
          cmp = a.visitType.compareTo(b.visitType);
          break;
        case SortColumn.score:
          cmp = a.patientResponse.q0.compareTo(b.patientResponse.q0);
          break;
        case SortColumn.none:
          break;
      }
      return filters.sortDirection == SortDirection.asc ? cmp : -cmp;
    });

    return list;
  });
});