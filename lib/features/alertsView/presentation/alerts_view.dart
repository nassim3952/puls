import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_card.dart';
import 'package:puls/features/alertsView/presentation/widgets/alert_view.dart';
import 'package:puls/features/alertsView/presentation/widgets/detail_sheet.dart';
import 'package:puls/features/alertsView/presentation/widgets/empty.dart';
import 'package:puls/features/alertsView/presentation/widgets/plan_sheet.dart';
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
  late AnimationController _animController;

  // Liste locale pour gérer la suppression (dismiss) en session
  // On garde les IDs supprimés pour filtrer la liste
  final Set<String> _dismissed = {};

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<AlertView> _applyFilters(List<PatientModel> patients) {
    return patients
        .where((p) => !_dismissed.contains(p.id))
        .map((p) => AlertView(p))
        .where((a) => _filterLevel == null || a.level == _filterLevel)
        .toList();
  }

  void _dismissAlert(String id) {
    setState(() => _dismissed.add(id));
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
          final filtered = _applyFilters(patients);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(),
              _buildFilters(),
              Expanded(
                child: filtered.isEmpty
                    ? buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => AlertCard(
                          alert: filtered[i],
                          onDelete: () => _dismissAlert(filtered[i].source.id),
                          onWhatsapp: () =>
                              _showWhatsappSheet(context, filtered[i]),
                          onDetail: () =>
                              _showDetailSheet(context, filtered[i]),
                          onPlan: () => _showPlanSheet(context, filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          color: AppColors.primary.withOpacity(0.25),
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
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
