import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// Variations en % vs la période précédente (même durée, juste avant).
  /// `null` si rien à comparer (ex: mode "Tout", ou période précédente vide).
  final double? variationPatients;
  final double? variationVisits;
  final double? variationResponses;
  final double? variationAlerts;
  final double? variationAlertsResolved;
  final double? variationResponseRate;

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
    this.variationPatients,
    this.variationVisits,
    this.variationResponses,
    this.variationAlerts,
    this.variationAlertsResolved,
    this.variationResponseRate,
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

  factory DashboardKpi.fromJson(Map<String, dynamic> json) {
    List<double> toSpark(dynamic raw) {
      if (raw == null) return List.filled(_kSparkPoints, 0.0);
      final list = (raw as List).map((v) => (v as num).toDouble()).toList();
      final maxVal = list.fold(0.0, (a, b) => a > b ? a : b);
      if (maxVal == 0) return List.filled(_kSparkPoints, 0.0);
      return list.map((v) => (v / maxVal) * 5).toList();
    }

    // Sparkline taux de réponse : responses / visits par point
    List<double> toRateSpark(dynamic rawV, dynamic rawR) {
      if (rawV == null || rawR == null) return List.filled(_kSparkPoints, 0.0);
      final visits    = (rawV as List).map((v) => (v as num).toDouble()).toList();
      final responses = (rawR as List).map((v) => (v as num).toDouble()).toList();
      final rates = List.generate(visits.length, (i) {
        return visits[i] == 0 ? 0.0 : responses[i] / visits[i];
      });
      final maxVal = rates.fold(0.0, (a, b) => a > b ? a : b);
      if (maxVal == 0) return List.filled(_kSparkPoints, 0.0);
      return rates.map((v) => (v / maxVal) * 5).toList();
    }

    double? toVariation(dynamic raw) {
      if (raw == null) return null;
      return (raw as num).toDouble();
    }

    return DashboardKpi(
      totalPatients:       (json['total_patients']        as num).toInt(),
      totalVisits:         (json['total_visits']          as num).toInt(),
      totalResponses:      (json['total_responses']       as num).toInt(),
      totalAlerts:         (json['total_alerts']          as num).toInt(),
      totalAlertsResolved: (json['total_alerts_resolved'] as num).toInt(),
      responseRate:        (json['response_rate']         as num).toDouble(),
      consentRate:         0.0, // pas encore dans la fonction SQL
      patientsSpark:       toSpark(json['spark_patients']),
      visitsSpark:         toSpark(json['spark_visits']),
      responsesSpark:      toSpark(json['spark_responses']),
      alertsSpark:         toSpark(json['spark_alerts']),
      alertsResolvedSpark: toSpark(json['spark_resolved']),
      responseRateSpark:   toRateSpark(json['spark_visits'], json['spark_responses']),
      variationPatients:        toVariation(json['variation_patients']),
      variationVisits:          toVariation(json['variation_visits']),
      variationResponses:       toVariation(json['variation_responses']),
      variationAlerts:          toVariation(json['variation_alerts']),
      variationAlertsResolved:  toVariation(json['variation_alerts_resolved']),
      variationResponseRate:    toVariation(json['variation_response_rate']),
    );
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────
final dashboardKpiProvider = FutureProvider<DashboardKpi>((ref) async {
  final hospitalId = ref.watch(authProvider).user?.hospitalId;
  if (hospitalId == null) return DashboardKpi.empty;

  final filters = ref.watch(filterProvider);
  ref.watch(filterProvider.select((f) => f.searchQuery));

  final result = await Supabase.instance.client.rpc(
    'get_dashboard_kpi',
    params: {
      'p_hospital_id':  hospitalId,
      'p_spark_points': _kSparkPoints,
      if (filters.service?.isNotEmpty == true)     'p_service':     filters.service,
      if (filters.type?.isNotEmpty == true)        'p_type':        filters.type,
      if (filters.exploration?.isNotEmpty == true) 'p_exploration': filters.exploration,
      if (filters.sortie?.isNotEmpty == true)      'p_sortie':      filters.sortie,
      if (filters.periode != null) 'p_date_start': filters.periode!.start.toIso8601String(),
      if (filters.periode != null) 'p_date_end':   filters.periode!.end.toIso8601String(),
      if (filters.searchQuery.isNotEmpty) 'p_search': filters.searchQuery, // 👈 nouveau
    },
  );

  return DashboardKpi.fromJson(result as Map<String, dynamic>);
});