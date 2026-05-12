import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';

import '../../../../core/models/chart_model.dart';

final q5DoughnutProvider = Provider<AsyncValue<List<ChartDataPie>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return [];

    // On compte les occurrences de q5 (qui est un booléen dans ton modèle)
    final ouiCount = list.where((p) => p.patientResponse.q5 == true).length;
    final nonCount = list.where((p) => p.patientResponse.q5 == false).length;

    return [
      ChartDataPie("OUI", ouiCount.toDouble(), const Color(0xFF10B981)), // Vert
      ChartDataPie("NON", nonCount.toDouble(), const Color(0xFFEF4444)), // Rouge
    ];
  });
});