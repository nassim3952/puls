// dashboard_kpi_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:puls/core/provider/patient_provider.dart';

const int _kSparkPoints = 7;

class DashboardKpi {
  final int totalPatients;
  final int totalVisits;
  final int totalResponses;
  final int totalAlerts;
  final int totalAlertsResolved;
  final double responseRate;
  final double consentRate;

  final List<double> patientsSpark;
  final List<double> visitsSpark;
  final List<double> responsesSpark;
  final List<double> alertsSpark;
  final List<double> alertsResolvedSpark;
  final List<double> responseRateSpark;

  const DashboardKpi({
    required this.totalPatients,
    required this.totalVisits,
    required this.totalResponses,
    required this.totalAlerts,
    required this.totalAlertsResolved,
    required this.responseRate,
    required this.consentRate,
    required this.patientsSpark,
    required this.visitsSpark,
    required this.responsesSpark,
    required this.alertsSpark,
    required this.alertsResolvedSpark,
    required this.responseRateSpark,
  });

  static const empty = DashboardKpi(
    totalPatients: 0,
    totalVisits: 0,
    totalResponses: 0,
    totalAlerts: 0,
    totalAlertsResolved: 0,
    responseRate: 0,
    consentRate: 0,
    patientsSpark: [],
    visitsSpark: [],
    responsesSpark: [],
    alertsSpark: [],
    alertsResolvedSpark: [],
    responseRateSpark: [],
  );
}

final dashboardKpiProvider = Provider<AsyncValue<DashboardKpi>>((ref) {
  // ✅ était patientsListProvider — maintenant on lit les patients déjà filtrés
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final filters = ref.watch(filterProvider);

  return patientsAsync.whenData((patients) {
    final periode = filters.periode;
    final DateTime sparkStart =
        periode?.start ?? DateTime.now().subtract(const Duration(days: 49));
    final DateTime sparkEnd = periode?.end ?? DateTime.now();
    final Duration sparkInterval = Duration(
      seconds: (sparkEnd.difference(sparkStart).inSeconds / _kSparkPoints)
          .round()
          .clamp(1, 999999999),
    );

    final sparkPatientSets =
    List<Set<String>>.generate(_kSparkPoints, (_) => {});
    final sparkVisits = List.filled(_kSparkPoints, 0).toList();
    final sparkResponses = List.filled(_kSparkPoints, 0).toList();
    final sparkAlerts = List.filled(_kSparkPoints, 0).toList();
    final sparkResolved = List.filled(_kSparkPoints, 0).toList();

    final patientsSet = <String>{};
    int totalVisits = 0;
    int totalResponses = 0;
    int totalAlerts = 0;
    int totalAlertsResolved = 0;
    int totalConsents = 0;

    for (final patient in patients) {
      bool patientIncluded = false;

      for (final v in patient.visits) {
        // ✅ Plus besoin de re-filtrer service / type / explo / sortie / search :
        // filteredPatientsProvider l'a déjà fait.
        // On filtre uniquement par date pour positionner les points sparkline.
        bool matchDate = true;
        if (filters.periode != null) {
          matchDate = v.date.isAfter(filters.periode!.start) &&
              v.date.isBefore(
                  filters.periode!.end.add(const Duration(days: 1)));
        }
        if (!matchDate) continue;

        patientIncluded = true;
        totalVisits++;

        final hasResponse = v.survey != null;
        if (hasResponse) {
          totalResponses++;
          if (v.survey!.consentementRappel) totalConsents++;
        }
        if (v.hasAlert) totalAlerts++;
        if (v.alertResolved) totalAlertsResolved++;

        final diff = v.date.difference(sparkStart);
        final idx = (diff.inSeconds / sparkInterval.inSeconds)
            .floor()
            .clamp(0, _kSparkPoints - 1);

        sparkVisits[idx]++;
        if (hasResponse) sparkResponses[idx]++;
        if (v.hasAlert) sparkAlerts[idx]++;
        if (v.alertResolved) sparkResolved[idx]++;
        sparkPatientSets[idx].add(patient.id);
      }

      if (patientIncluded) patientsSet.add(patient.id);
    }

    List<double> toSpark(List<int> raw) {
      final maxVal = raw.reduce((a, b) => a > b ? a : b);
      if (maxVal == 0) return List.filled(_kSparkPoints, 0.0);
      return raw.map((v) => (v / maxVal) * 5).toList();
    }

    List<double> toSparkD(List<double> raw) {
      final maxVal = raw.reduce((a, b) => a > b ? a : b);
      if (maxVal == 0) return List.filled(_kSparkPoints, 0.0);
      return raw.map((v) => (v / maxVal) * 5).toList();
    }

    final rateRaw = List.generate(_kSparkPoints, (i) {
      final v = sparkVisits[i];
      return v == 0 ? 0.0 : sparkResponses[i] / v;
    });

    return DashboardKpi(
      totalPatients: patientsSet.length,
      totalVisits: totalVisits,
      totalResponses: totalResponses,
      totalAlerts: totalAlerts,
      totalAlertsResolved: totalAlertsResolved,
      responseRate:
      totalVisits == 0 ? 0.0 : totalResponses / totalVisits,
      consentRate:
      totalResponses == 0 ? 0.0 : totalConsents / totalResponses,
      patientsSpark:
      toSpark(sparkPatientSets.map((s) => s.length).toList()),
      visitsSpark: toSpark(sparkVisits),
      responsesSpark: toSpark(sparkResponses),
      alertsSpark: toSpark(sparkAlerts),
      alertsResolvedSpark: toSpark(sparkResolved),
      responseRateSpark: toSparkD(rateRaw),
    );
  });
});