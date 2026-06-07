import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/auth_provider.dart';
import 'package:puls/core/provider/filter_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─── Modèles ──────────────────────────────────────────────────────────────────

class DashboardCharts {
  final double q0Average;
  final List<Q0TimelinePoint> q0Timeline;
  final List<Q1DistributionItem> q1Distribution;
  final List<Q5ConsentItem> q5Consent;

  const DashboardCharts({
    required this.q0Average,
    required this.q0Timeline,
    required this.q1Distribution,
    required this.q5Consent,
  });

  static const empty = DashboardCharts(
    q0Average: 0,
    q0Timeline: [],
    q1Distribution: [],
    q5Consent: [],
  );

  factory DashboardCharts.fromJson(Map<String, dynamic> json) {
    return DashboardCharts(
      q0Average: (json['q0_average'] as num?)?.toDouble() ?? 0,
      q0Timeline: (json['q0_timeline'] as List? ?? [])
          .map((e) => Q0TimelinePoint.fromJson(e))
          .toList(),
      q1Distribution: (json['q1_distribution'] as List? ?? [])
          .map((e) => Q1DistributionItem.fromJson(e))
          .toList(),
      q5Consent: (json['q5_consent'] as List? ?? [])
          .map((e) => Q5ConsentItem.fromJson(e))
          .toList(),
    );
  }
}

class Q0TimelinePoint {
  final String x;
  final double y;
  Q0TimelinePoint({required this.x, required this.y});
  factory Q0TimelinePoint.fromJson(Map<String, dynamic> j) =>
      Q0TimelinePoint(x: j['x'], y: (j['y'] as num).toDouble());
}

class Q1DistributionItem {
  final String label;
  final int count;
  final double pct;
  final Color color;

  Q1DistributionItem({
    required this.label,
    required this.count,
    required this.pct,
    required this.color,
  });

  factory Q1DistributionItem.fromJson(Map<String, dynamic> j) {
    final label = j['label'] as String;
    final color = switch (label) {
      'Oui totalement' => AppColors.primaryBlue,
      'En partie'      => AppColors.primaryWarning,
      'Non'            => AppColors.primaryError,
      _                => AppColors.primaryNeutral,
    };
    return Q1DistributionItem(
      label: label,
      count: (j['count'] as num).toInt(),
      pct:   (j['pct']   as num).toDouble(),
      color: color,
    );
  }
}

class Q5ConsentItem {
  final String label;
  final int count;
  Q5ConsentItem({required this.label, required this.count});
  factory Q5ConsentItem.fromJson(Map<String, dynamic> j) =>
      Q5ConsentItem(label: j['label'], count: (j['count'] as num).toInt());
}

// ─── Provider principal ───────────────────────────────────────────────────────

final dashboardChartsProvider = FutureProvider<DashboardCharts>((ref) async {
  final hospitalId = ref.watch(authProvider).user?.hospitalId;
  if (hospitalId == null) return DashboardCharts.empty;

  final filters = ref.watch(filterProvider);

  final result = await Supabase.instance.client.rpc(
    'get_dashboard_charts',
    params: {
      'p_hospital_id': hospitalId,
      if (filters.service?.isNotEmpty == true)     'p_service':     filters.service,
      if (filters.type?.isNotEmpty == true)        'p_type':        filters.type,
      if (filters.exploration?.isNotEmpty == true) 'p_exploration': filters.exploration,
      if (filters.sortie?.isNotEmpty == true)      'p_sortie':      filters.sortie,
      if (filters.periode != null) 'p_date_start': filters.periode!.start.toIso8601String(),
      if (filters.periode != null) 'p_date_end':   filters.periode!.end.toIso8601String(),
    },
  );

  return DashboardCharts.fromJson(result as Map<String, dynamic>);
});