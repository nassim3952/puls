import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_view.dart';
import 'package:puls/features/alertsView/presentation/widgets/detail_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/empty.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_action_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/validated_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/whatsapp_sheet.dart';
import 'package:puls/features/dashboard/presentation/widgets/dashboard_build_header.dart';

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
    // Rebuild quand on change d'onglet pour mettre à jour les badges
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Segmentation des listes selon le workflow ─────────────────────────────

  /// Onglet 1 : alerte active, pas de plan encore
  List<AlertView> _activeAlerts(List<PatientModel> patients) {
    return patients
        .where((p) => p.hasAlert && p.actionPlanLabel == null)
        .map((p) => AlertView(p))
        .where((a) => _filterLevel == null || a.level == _filterLevel)
        .toList();
  }

  /// Onglet 2 : plan initié, en attente de validation (planIsValid == null OU == false si rejeté)
  List<AlertView> _pendingPlans(List<PatientModel> patients) {
    return patients
        .where((p) =>
    p.hasAlert &&
        p.actionPlanLabel != null)
        .map((p) => AlertView(p))
        .toList();
  }

  /// Onglet 3 : plans validés archivés
  List<AlertView> _validatedPlans(List<PatientModel> patients) {
    return patients
        .where((p) => !p.hasAlert && p.planIsValid == true)
        .map((p) => AlertView(p))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: alertsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.urgentText,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Erreur de chargement',
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                err.toString(),
                style: const TextStyle(
                  color: AppColors.textLight,
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
              DashboardHeader(),
              // ── TabBar ────────────────────────────────────────────────
              _buildTabBar(
                activeCount: active.length,
                pendingCount: pending.length,
                validatedCount: validated.length,
              ),
              // ── Filtre niveau (onglet 1 seulement) ───────────────────
              if (_tabController.index == 0) ...[
                const SizedBox(height: 8),
                _buildFilters(),
              ],
              const SizedBox(height: 4),
              // ── Contenu des onglets ───────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Onglet 1 : Alertes actives
                    _buildActiveTab(active),
                    // Onglet 2 : Plans en attente
                    _buildPendingTab(pending),
                    // Onglet 3 : Plans validés
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

  // ── TabBar avec badges ────────────────────────────────────────────────────
  Widget _buildTabBar({
    required int activeCount,
    required int pendingCount,
    required int validatedCount,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        tabs: [
          _Tab(
            label: 'Alertes',
            count: activeCount,
            isSelected: _tabController.index == 0,
            badgeColor: AppColors.urgentText,
          ),
          _Tab(
            label: 'Plans',
            count: pendingCount,
            isSelected: _tabController.index == 1,
            badgeColor: AppColors.warningText,
          ),
          _Tab(
            label: 'Validés',
            count: validatedCount,
            isSelected: _tabController.index == 2,
            badgeColor: AppColors.primaryDark,
          ),
        ],
      ),
    );
  }

  // ── Onglet 1 : Alertes actives ────────────────────────────────────────────
  Widget _buildActiveTab(List<AlertView> alerts) {
    if (alerts.isEmpty) return buildEmpty();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: alerts.length,
      itemBuilder: (ctx, i) => AlertCard(
        alert: alerts[i],
        onDelete: () => ref
            .read(alertsNotifierProvider.notifier)
            .dismiss(alerts[i].source.id),
        onWhatsapp: () => _showWhatsappSheet(context, alerts[i]),
        onDetail: () => _showDetailSheet(context, alerts[i]),
        onPlan: () => _showPlanSheet(context, alerts[i]),
      ),
    );
  }

  // ── Onglet 2 : Plans en attente ───────────────────────────────────────────
  Widget _buildPendingTab(List<AlertView> alerts) {
    if (alerts.isEmpty) {
      return _EmptyTab(
        icon: Icons.assignment_outlined,
        message: 'Aucun plan en attente de validation.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: alerts.length,
      itemBuilder: (ctx, i) => PlanActionCard(alert: alerts[i]),
    );
  }

  // ── Onglet 3 : Plans validés ──────────────────────────────────────────────
  Widget _buildValidatedTab(List<AlertView> alerts) {
    if (alerts.isEmpty) {
      return _EmptyTab(
        icon: Icons.check_circle_outline_rounded,
        message: 'Aucune alerte archivée pour le moment.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: alerts.length,
      itemBuilder: (ctx, i) => ValidatedCard(alert: alerts[i]),
    );
  }

  // ── Filtre niveau (onglet 1 seulement) ────────────────────────────────────
  Widget _buildFilters() {
    final filters = [
      null,
      AlertLevel.urgent,
      AlertLevel.warning,
      AlertLevel.info,
    ];
    final labels = ['Toutes', 'Urgentes', 'Modérées', 'Info'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (ctx, i) {
          final selected = _filterLevel == filters[i];
          return GestureDetector(
            onTap: () => setState(() => _filterLevel = filters[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : [],
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textMid,
                  fontSize: 13,
                  fontWeight:
                  selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
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

// ─── Tab widget avec badge ────────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color badgeColor;

  const _Tab({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textMid,
                fontSize: 13,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.25)
                      : badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty state générique pour les onglets 2 et 3 ───────────────────────────
class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}