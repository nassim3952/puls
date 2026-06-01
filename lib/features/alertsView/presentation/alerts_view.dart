import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/core/shared_widget/segmented_bar.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_view.dart';
import 'package:puls/features/alertsView/presentation/widgets/detail_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/empty_state.dart';
import 'package:puls/features/alertsView/presentation/widgets/patient_groupe_shell.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_action_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/validated_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/whatsapp_sheet.dart';
import 'package:puls/core/shared_widget/build_header.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen>
    with SingleTickerProviderStateMixin {
  AlertLevel? _filterLevel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Segmentation des AlertView selon le workflow ──────────────────────────

  /// Onglet 1 : visites avec hasAlert == true et pas de plan encore
  List<AlertView> _activeAlerts(List<PatientModel> patients) {
    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        if (v.hasAlert && v.actionPlanLabel == null) {
          result.add(AlertView(p, v));
        }
      }
    }
    return result
        .where((a) => _filterLevel == null || a.level == _filterLevel)
        .toList();
  }

  /// Onglet 2 : visites avec hasAlert == true et plan initié
  List<AlertView> _pendingPlans(List<PatientModel> patients) {
    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        if (v.hasAlert && v.actionPlanLabel != null) {
          result.add(AlertView(p, v));
        }
      }
    }
    return result;
  }

  /// Onglet 3 : visites validées archivées
  List<AlertView> _validatedPlans(List<PatientModel> patients) {
    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        if (!v.hasAlert && v.planIsValid == true) {
          result.add(AlertView(p, v));
        }
      }
    }
    return result;
  }

  // ── Groupement par patient ────────────────────────────────────────────────
  Map<String, List<AlertView>> _groupByPatient(List<AlertView> alerts) {
    final map = <String, List<AlertView>>{};
    for (final a in alerts) {
      map.putIfAbsent(a.source.id, () => []).add(a);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: alertsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.primaryError,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                err.toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        data: (patients) {
          final active = _activeAlerts(patients);
          final pending = _pendingPlans(patients);
          final validated = _validatedPlans(patients);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (fixe en haut) ──────────────────────────────────
              const DashboardHeader(),

              // ── Barre unique scrollable : tabs + filtres ───────────────
              _buildTabAndFilterRow(
                activeCount: active.length,
                pendingCount: pending.length,
                validatedCount: validated.length,
              ),

              const SizedBox(height: 4),

              // ── Contenu des onglets ────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildActiveTab(active),
                    _buildPendingTab(pending),
                    _buildValidatedTab(validated),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Barre unique : tabs compacts (gauche) + filtres de niveau (suite) ─────
  Widget _buildTabAndFilterRow({
    required int activeCount,
    required int pendingCount,
    required int validatedCount,
  }) {
    final filterLevels = [null, AlertLevel.urgent, AlertLevel.warning, AlertLevel.info];
    final filterLabels = ['Toutes', 'Urgentes', 'Modérées', 'Info'];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 16),
      child: Row(
        children: [
          Spacer(),
          SegmentedTabBar(
            selectedIndex: _tabController.index,
            activeCount: activeCount,
            pendingCount: pendingCount,
            validatedCount: validatedCount,
            onChanged: (i) => setState(() => _tabController.animateTo(i)),
          ),
        ],
      ),
    );
  }

  // ── Onglet 1 : Alertes actives — groupées par patient ────────────────────
  Widget _buildActiveTab(List<AlertView> alerts) {
    if (alerts.isEmpty) return EmptyTab(icon: Icons.check_circle_outline_rounded ,message: "Aucune alerte non traité",);
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);

        // Un seul alert → AlertCard complète
        if (patientAlerts.length == 1) {
          final alert = patientAlerts.first;
          return AlertCard(
            alert: alert,
            onDelete: () => ref
                .read(alertsNotifierProvider.notifier)
                .dismiss(alert.visit),
            onWhatsapp: () => _showWhatsappSheet(context, alert),
            onDetail: () => _showDetailSheet(context, alert),
            onPlan: () => _showPlanSheet(context, alert),
          );
        }

        // Plusieurs → PatientAlertGroup
        return PatientAlertGroup(
          alerts: patientAlerts,
          onDelete: (alert) => ref
              .read(alertsNotifierProvider.notifier)
              .dismiss(alert.visit),
          onWhatsapp: (alert) => _showWhatsappSheet(context, alert),
          onDetail: (alert) => _showDetailSheet(context, alert),
          onPlan: (alert) => _showPlanSheet(context, alert),
        );
      },
    );
  }

  // ── Onglet 2 : Plans en attente ───────────────────────────────────────────
  Widget _buildPendingTab(List<AlertView> alerts) {
    if (alerts.isEmpty) {
      return EmptyTab(
        icon: Icons.assignment_outlined,
        message: 'Aucun plan en attente de validation.',
      );
    }
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);

        // Un seul → PlanActionCard (header + 1 visite)
        if (patientAlerts.length == 1) {
          return PlanActionCard(alert: patientAlerts.first);
        }

        // Plusieurs → PatientPlanActionGroup (header unique + N tiles)
        return PatientPlanActionGroup(alerts: patientAlerts);
      },
    );
  }

  // ── Onglet 3 : Plans validés ──────────────────────────────────────────────
  Widget _buildValidatedTab(List<AlertView> alerts) {
    if (alerts.isEmpty) {
      return EmptyTab(
        icon: Icons.check_circle_outline_rounded,
        message: 'Aucune alerte archivée pour le moment.',
      );
    }
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);

        // Un seul → ValidatedCard (header + 1 visite)
        if (patientAlerts.length == 1) {
          return ValidatedCard(alert: patientAlerts.first);
        }

        // Plusieurs → PatientValidatedGroup (header unique + N tiles)
        return PatientValidatedGroup(alerts: patientAlerts);
      },
    );
  }



  // ── Bottom Sheets ─────────────────────────────────────────────────────────
  void _showWhatsappSheet(BuildContext context, AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WhatsappSheet(alert: alert),
    );
  }

  void _showDetailSheet(BuildContext context, AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DetailSheet(alert: alert),
    );
  }

  void _showPlanSheet(BuildContext context, AlertView alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlanSheet(alert: alert),
    );
  }
}