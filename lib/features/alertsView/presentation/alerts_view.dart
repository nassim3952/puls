import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/core/shared_widget/segmented_bar.dart';
import 'package:puls/features/alertsView/presentation/widgets/adaptativesheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_view.dart';
import 'package:puls/features/alertsView/presentation/widgets/detail_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/empty_state.dart';
import 'package:puls/features/alertsView/presentation/widgets/patient_groupe_shell.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_action_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/sheet_base.dart';
import 'package:puls/features/alertsView/presentation/widgets/validated_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/whatsapp_sheet.dart';
import 'package:puls/core/shared_widget/build_header.dart';
import 'package:puls/core/provider/historique_filter_controller.dart';

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

  // ── Filtre de recherche global ────────────────────────────────────────────
  bool _matchesSearch(AlertView a, HistoriqueFilterState filters) {
    final q = filters.searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;

    if (filters.searchMode == SearchMode.patient) {
      return a.source.firstName.toLowerCase().contains(q) ||
          a.source.lastName.toLowerCase().contains(q) ||
          a.source.ipp.toLowerCase().contains(q);
    } else {
      return a.visit.service.toLowerCase().contains(q) ||
          a.visit.visitType.toLowerCase().contains(q) ||
          a.visit.exploration.toLowerCase().contains(q) ||
          a.visit.afterCare.toLowerCase().contains(q) ||
          (a.visit.actionPlanLabel?.toLowerCase().contains(q) ?? false) ||
          (a.visit.actionPlanReport?.toLowerCase().contains(q) ?? false);
    }
  }

  // ── Segmentation des AlertView selon le workflow ──────────────────────────

  /// Onglet 1 : visites avec hasAlert == true et pas de plan encore
  List<AlertView> _activeAlerts(List<PatientModel> patients, HistoriqueFilterState filters) {
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
        .where((a) => _matchesSearch(a, filters))
        .toList();
  }

  /// Onglet 2 : visites avec hasAlert == true et plan initié
  List<AlertView> _pendingPlans(List<PatientModel> patients, HistoriqueFilterState filters) {
    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        if (v.hasAlert && v.actionPlanLabel != null) {
          result.add(AlertView(p, v));
        }
      }
    }
    return result
        .where((a) => _matchesSearch(a, filters))
        .toList();
  }

  /// Onglet 3 : visites validées archivées
  List<AlertView> _validatedPlans(List<PatientModel> patients, HistoriqueFilterState filters) {
    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        if (!v.hasAlert && v.planIsValid == true) {
          result.add(AlertView(p, v));
        }
      }
    }
    return result
        .where((a) => _matchesSearch(a, filters))
        .toList();
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
    // On watch les 3 onglets séparément
    final activeAsync    = ref.watch(activeAlertsProvider(null));
    final pendingAsync   = ref.watch(pendingAlertsProvider(null));
    final validatedAsync = ref.watch(validatedAlertsProvider(null));
    final filters        = ref.watch(historiqueFilterProvider);

    // On combine les 3 états async
    final isLoading = activeAsync.isLoading ||
        pendingAsync.isLoading ||
        validatedAsync.isLoading;

    final error = activeAsync.error ??
        pendingAsync.error ??
        validatedAsync.error;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.primaryBG,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: AppColors.primaryBG,
        body: Center(
          child: Text(error.toString(),
              style: const TextStyle(color: AppColors.primaryError)),
        ),
      );
    }

    final active    = _toAlertViews(activeAsync.value ?? [],    filters);
    final pending   = _toAlertViews(pendingAsync.value ?? [],   filters);
    final validated = _toAlertViews(validatedAsync.value ?? [], filters);

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          _buildTabAndFilterRow(
            activeCount:    active.length,
            pendingCount:   pending.length,
            validatedCount: validated.length,
          ),
          const SizedBox(height: 4),
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
      ),
    );
  }


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

  // ── Onglet 1 : Alertes actives ────────────────────────────────────────────
  Widget _buildActiveTab(List<AlertView> alerts) {
    if (alerts.isEmpty) return EmptyTab(icon: Icons.check_circle_outline_rounded, message: "Aucune alerte non traité");
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);
        if (patientAlerts.length == 1) {
          final alert = patientAlerts.first;
          return AlertCard(
            alert: alert,
            onDelete: () => ref.read(alertsNotifierProvider.notifier).dismiss(alert.visit),
            onWhatsapp: () => _showWhatsappSheet(context, alert),
            onDetail: () => _showDetailSheet(context, alert),
            onPlan: () => _showPlanSheet(context, alert),
          );
        }
        return PatientAlertGroup(
          alerts: patientAlerts,
          onDelete: (alert) => ref.read(alertsNotifierProvider.notifier).dismiss(alert.visit),
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
      return EmptyTab(icon: Icons.assignment_outlined, message: 'Aucun plan en attente de validation.');
    }
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);
        if (patientAlerts.length == 1) return PlanActionCard(alert: patientAlerts.first);
        return PatientPlanActionGroup(alerts: patientAlerts);
      },
    );
  }

// ── Onglet 3 : Plans validés ──────────────────────────────────────────────
  Widget _buildValidatedTab(List<AlertView> alerts) {
    if (alerts.isEmpty) {
      return EmptyTab(icon: Icons.check_circle_outline_rounded, message: 'Aucune alerte archivée pour le moment.');
    }
    final grouped = _groupByPatient(alerts);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: grouped.length,
      itemBuilder: (ctx, i) {
        final patientAlerts = grouped.values.elementAt(i);
        if (patientAlerts.length == 1) return ValidatedCard(alert: patientAlerts.first);
        return PatientValidatedGroup(alerts: patientAlerts);
      },
    );
  }

  // Recherche locale + conversion PatientModel → List<AlertView>
  List<AlertView> _toAlertViews(
      List<PatientModel> patients, HistoriqueFilterState filters) {
    final q = filters.searchQuery.trim().toLowerCase();

    final result = <AlertView>[];
    for (final p in patients) {
      for (final v in p.visits) {
        final a = AlertView(p, v);
        if (q.isEmpty) {
          result.add(a);
          continue;
        }
        if (filters.searchMode == SearchMode.patient) {
          if (p.firstName.toLowerCase().contains(q) ||
              p.lastName.toLowerCase().contains(q) ||
              p.ipp.toLowerCase().contains(q)) {
            result.add(a);
          }
        } else {
          if (v.service.toLowerCase().contains(q) ||
              v.visitType.toLowerCase().contains(q) ||
              (v.actionPlanLabel?.toLowerCase().contains(q) ?? false)) {
            result.add(a);
          }
        }
      }
    }
    return result;
  }
  // ── Bottom Sheets ─────────────────────────────────────────────────────────
  void _showWhatsappSheet(BuildContext context, AlertView alert) {
    showAdaptiveSheet(
      context,
      child: WhatsappSheet(alert: alert), // ← pas de SheetBase ici
    );
  }

  void _showDetailSheet(BuildContext context, AlertView alert) {
    showAdaptiveSheet(
      context,
      child: DetailSheet(alert: alert), // ← pas de SheetBase ici
    );
  }

  void _showPlanSheet(BuildContext context, AlertView alert) {
    showAdaptiveSheet(
      context,
      child: PlanSheet(alert: alert), // ← pas de SheetBase ici
    );
  }
  }
