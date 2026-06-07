import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'alert_provider.dart';
import 'dashboard_kpi_provider.dart';
import 'patient_provider.dart';
import 'package:puls/features/dashboard/presentation/provider/dashboard_charts_provider.dart';

final realtimeProvider = Provider<void>((ref) {
  final supabase = Supabase.instance.client;

  // ── Écoute les changements sur survey_responses ───────────────────────────
  final channel = supabase
      .channel('db-changes')
      .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'survey_responses',
    callback: (payload) {
      // Invalide tous les providers liés aux alertes et KPI
      ref.invalidate(activeAlertsProvider(null));
      ref.invalidate(pendingAlertsProvider(null));
      ref.invalidate(validatedAlertsProvider(null));
      ref.invalidate(dashboardKpiProvider);
      ref.invalidate(dashboardChartsProvider);
      ref.invalidate(filteredPatientsProvider);
    },
  )
      .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'visits',
    callback: (payload) {
      ref.invalidate(filteredPatientsProvider);
      ref.invalidate(dashboardKpiProvider);
      ref.invalidate(dashboardChartsProvider);
    },
  )
      .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'patients',
    callback: (payload) {
      ref.invalidate(filteredPatientsProvider);
      ref.invalidate(dashboardKpiProvider);
    },
  )
      .subscribe();

  // Cleanup quand le provider est détruit
  ref.onDispose(() => supabase.removeChannel(channel));
});