import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/models/patient.dart';

import 'patient_provider.dart';

final alertsProvider = Provider<AsyncValue<List<PatientModel>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    // On ne garde que les alertes et on trie par date
    final alerts = list.where((p) => p.hasAlert).toList();
    alerts.sort((a, b) => b.date.compareTo(a.date));
    return alerts;
  });
});