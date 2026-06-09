import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'package:puls/core/provider/navigation_provider.dart';
import 'package:puls/core/provider/historique_filter_controller.dart';
import 'package:puls/core/shared_widget/empty_state.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/models/service_stats_model.dart';
import '../../../core/models/survey_response.dart';
import '../../../core/provider/filter_controller.dart';
import '../../../core/provider/service_stats_provider.dart';
import '../../../core/shared_widget/custom_sparkline.dart';
import '../../alertsView/presentation/widgets/adaptativesheet.dart';
import '../../alertsView/presentation/widgets/sheet_base.dart';
import '../../dashboard/model/domain/filtred_state.dart';

// ────────────────────────────────────────────────────────────────────────────
// ÉCRAN PRINCIPAL
// ────────────────────────────────────────────────────────────────────────────
class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  ServiceStats? _selectedService;
  DateTimeRange? _sparklineRange;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(filteredServiceStatsProvider);
    final filters = ref.watch(serviceFilterProvider);
    final dashboardFilters = ref.watch(filterProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Barre filtres + recherche ──────────────────────────────────
          _buildFilterBar(filters, dashboardFilters),

          // ── Contenu principal ──────────────────────────────────────────
          Expanded(
            child: statsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (stats) => stats.isEmpty
                  ? const EmptyState(reason: EmptyStateReason.noData)
                  : _selectedService != null
                  ? _buildDetailView(stats, dashboardFilters)
                  : _buildTableView(stats, filters),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BARRE FILTRES ────────────────────────────────────────────────────────
  Widget _buildFilterBar(
      ServiceFilterState filters, DashboardFilterState dashboardFilters) {
    final notifier = ref.read(serviceFilterProvider.notifier);
    final dashboardNotifier = ref.read(filterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 28),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Searchbox
            SizedBox(
              width: 250,
              height: 38,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  onChanged: (v) => notifier.setSearch(v),
                  decoration: InputDecoration(
                    hintText: 'Rechercher...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 12, right: 8),
                      child: Icon(Icons.search_rounded, size: 18),
                    ),
                    prefixIconConstraints:
                    const BoxConstraints(minHeight: 38),
                    hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Dropdowns
            _buildDateFilterButton(dashboardNotifier, dashboardFilters),
            const SizedBox(width: 10),
            _buildTypeFilterButton(dashboardNotifier, dashboardFilters),
            const SizedBox(width: 10),
            _buildServiceFilterButton(dashboardNotifier, dashboardFilters),
            const SizedBox(width: 10),
            _buildExplorationFilterButton(
                dashboardNotifier, dashboardFilters),
            const SizedBox(width: 10),
            if (filters.searchQuery.isNotEmpty)
              TextButton.icon(
                onPressed: () => notifier.reset(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterButton(DashboardFilterNotifier notifier,
      DashboardFilterState dashboardFilters) {
    String label = 'Période';
    if (dashboardFilters.periode != null) {
      final diff = dashboardFilters.periode!.end
          .difference(dashboardFilters.periode!.start)
          .inDays;
      if (diff == 7) {
        label = '7 jours';
      } else if (diff >= 28 && diff <= 31) {
        label = '1 mois';
      } else if (diff >= 364 && diff <= 366) {
        label = '1 an';
      } else {
        label = 'Personnalisé';
      }
    }

    return SizedBox(
      height: 38,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: dashboardFilters.periode != null
                  ? AppColors.primaryBlue
                  : AppColors.border,
              width:
              dashboardFilters.periode != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButton<String>(
            hint: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            value: null,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                color: AppColors.primaryBlue),
            onChanged: (val) {
              if (val == 'Personnalisé') {
                _showCustomDatePicker(context, notifier);
              } else {
                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                switch (val) {
                  case '7 jours':
                    notifier.updatePeriode(DateTimeRange(
                        start: today.subtract(const Duration(days: 7)),
                        end: today));
                    break;
                  case '1 mois':
                    notifier.updatePeriode(DateTimeRange(
                        start: today.subtract(const Duration(days: 30)),
                        end: today));
                    break;
                  case '1 an':
                    notifier.updatePeriode(DateTimeRange(
                        start: today.subtract(const Duration(days: 365)),
                        end: today));
                    break;
                  default:
                    notifier.updatePeriode(null);
                }
              }
            },
            items: [
              DropdownMenuItem<String>(
                  value: '7 jours', child: Text('7 jours')),
              DropdownMenuItem<String>(
                  value: '1 mois', child: Text('1 mois')),
              DropdownMenuItem<String>(value: '1 an', child: Text('1 an')),
              DropdownMenuItem<String>(
                  value: 'Personnalisé', child: Text('Personnalisé')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilterButton(DashboardFilterNotifier notifier,
      DashboardFilterState dashboardFilters) {
    return SizedBox(
      height: 38,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (dashboardFilters.type == null ||
                  dashboardFilters.type!.isEmpty)
                  ? AppColors.border
                  : AppColors.primaryBlue,
              width: (dashboardFilters.type == null ||
                  dashboardFilters.type!.isEmpty)
                  ? 1
                  : 1.5,
            ),
          ),
          child: DropdownButton<String>(
            hint: const Text('Type',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            value: (dashboardFilters.type == null ||
                dashboardFilters.type!.isEmpty)
                ? null
                : dashboardFilters.type,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                color: AppColors.primaryBlue),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
            onChanged: (val) {
              notifier.updateType(val);
            },
            items: [
              const DropdownMenuItem<String>(
                  value: '', child: Text('Tous')),
              const DropdownMenuItem<String>(
                  value: 'Consultation', child: Text('Consultation')),
              const DropdownMenuItem<String>(
                  value: 'Hospitalisation', child: Text('Hospitalisation')),
              const DropdownMenuItem<String>(
                  value: 'Urgences', child: Text('Urgences')),
              const DropdownMenuItem<String>(
                  value: 'Exploration', child: Text('Exploration')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceFilterButton(DashboardFilterNotifier notifier,
      DashboardFilterState dashboardFilters) {
    return SizedBox(
      height: 38,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (dashboardFilters.service == null ||
                  dashboardFilters.service!.isEmpty)
                  ? AppColors.border
                  : AppColors.primaryBlue,
              width: (dashboardFilters.service == null ||
                  dashboardFilters.service!.isEmpty)
                  ? 1
                  : 1.5,
            ),
          ),
          child: DropdownButton<String>(
            hint: const Text('Service',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            value: (dashboardFilters.service == null ||
                dashboardFilters.service!.isEmpty)
                ? null
                : dashboardFilters.service,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                color: AppColors.primaryBlue),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
            onChanged: (val) {
              notifier.updateService(val);
            },
            items: const [
              DropdownMenuItem<String>(value: '', child: Text('Tous')),
              DropdownMenuItem<String>(
                  value: 'Cardiologie', child: Text('Cardiologie')),
              DropdownMenuItem<String>(
                  value: 'Pédiatrie', child: Text('Pédiatrie')),
              DropdownMenuItem<String>(
                  value: 'Neurologie', child: Text('Neurologie')),
              DropdownMenuItem<String>(
                  value: 'Chirurgie', child: Text('Chirurgie')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplorationFilterButton(DashboardFilterNotifier notifier,
      DashboardFilterState dashboardFilters) {
    return SizedBox(
      height: 38,
      child: DropdownButtonHideUnderline(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (dashboardFilters.exploration == null ||
                  dashboardFilters.exploration!.isEmpty)
                  ? AppColors.border
                  : AppColors.primaryBlue,
              width: (dashboardFilters.exploration == null ||
                  dashboardFilters.exploration!.isEmpty)
                  ? 1
                  : 1.5,
            ),
          ),
          child: DropdownButton<String>(
            hint: const Text('Exploration',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            value: (dashboardFilters.exploration == null ||
                dashboardFilters.exploration!.isEmpty)
                ? null
                : dashboardFilters.exploration,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                color: AppColors.primaryBlue),
            style: const TextStyle(
                fontSize: 13, color: AppColors.textPrimary),
            onChanged: (val) {
              notifier.updateExploration(val);
            },
            items: const [
              DropdownMenuItem<String>(value: '', child: Text('Tous')),
              DropdownMenuItem<String>(
                  value: 'Imagerie', child: Text('Imagerie')),
              DropdownMenuItem<String>(
                  value: 'Biologie / Laboratoire',
                  child: Text('Biologie / Laboratoire')),
              DropdownMenuItem<String>(
                  value: 'Explorations Fonctionnelles',
                  child: Text('Explorations Fonctionnelles')),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDatePicker(
      BuildContext context,
      DashboardFilterNotifier notifier,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text("Sélectionner une période"),
        content: SizedBox(
          height: 350,
          width: 300,
          child: SfDateRangePicker(
            headerStyle: const DateRangePickerHeaderStyle(
              backgroundColor: AppColors.surface,
            ),
            backgroundColor: AppColors.surface,
            selectionColor: AppColors.primaryBlue,
            endRangeSelectionColor: AppColors.primaryBlue,
            startRangeSelectionColor: AppColors.primaryBlue,
            rangeSelectionColor: AppColors.primaryBlue.withOpacity(0.2),
            todayHighlightColor: AppColors.primaryBlue,
            selectionMode: DateRangePickerSelectionMode.range,
            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
              if (args.value is PickerDateRange) {
                final range = args.value as PickerDateRange;
                if (range.startDate != null && range.endDate != null) {
                  notifier.updatePeriode(
                    DateTimeRange(
                      start: range.startDate!,
                      end: range.endDate!,
                    ),
                  );
                }
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Valider",
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TABLEAU ───────────────────────────────────────────────────────────────
  Widget _buildTableView(List<ServiceStats> stats, ServiceFilterState filters) {
    final notifier = ref.read(serviceFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 20,
            minWidth: 800,
            headingRowHeight: 44,
            dataRowHeight: 56,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: AppColors.divider, width: 0.5),
            ),
            sortColumnIndex: _sortIndex(filters.sortColumn),
            sortAscending: filters.sortDirection == SortDirection.asc,
            columns: [
              DataColumn2(
                label: _ColHeader('Service'),
                onSort: (_, __) => notifier.setSort(ServiceSortColumn.name),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: _ColHeader('Visites'),
                onSort: (_, __) => notifier.setSort(ServiceSortColumn.visits),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Score ISGPP'),
                onSort: (_, __) => notifier.setSort(ServiceSortColumn.isgpp),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Alertes'),
                onSort: (_, __) => notifier.setSort(ServiceSortColumn.alerts),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Taux de satisfaction'),
                size: ColumnSize.S,
              ),
            ],
            rows: stats.map((s) => _buildServiceRow(s)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow2 _buildServiceRow(ServiceStats service) {
    final satisfactionRate = service.averageIsgpp * 20;

    return DataRow2(
      onTap: () => setState(() => _selectedService = service),
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFFF8F9FB);
        return null;
      }),
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: service.isgppColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLighter,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${service.totalVisits}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
        DataCell(
          _IsgppBadge(score: service.averageIsgpp),
        ),
        DataCell(
          service.alertCount > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryError.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: AppColors.primaryError.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 13,
                  color: AppColors.primaryError,
                ),
                const SizedBox(width: 4),
                Text(
                  '${service.alertCount}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryError,
                  ),
                ),
              ],
            ),
          )
              : Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '0',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMid,
              ),
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: _SatisfactionBar(rate: satisfactionRate),
          ),
        ),
      ],
    );
  }

  // ─── VUE DÉTAIL ────────────────────────────────────────────────────────────
  Widget _buildDetailView(List<ServiceStats> allStats,
      DashboardFilterState dashboardFilters) {
    final service = _selectedService!;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 260,
          child: _SideServiceList(
            services: allStats,
            selected: service,
            onSelect: (svc) => setState(() => _selectedService = svc),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailHeader(service),
                _buildDetailStats(service, dashboardFilters),
                const SizedBox(height: 12),
                _buildPatientsInService(service, dateFormat),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailHeader(ServiceStats service) {
    final dashboardFilters = ref.watch(filterProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            color: AppColors.primaryBlue,
            onPressed: () => setState(() => _selectedService = null),
            splashRadius: 20,
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: service.isgppColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.local_hospital_outlined,
              size: 24,
              color: service.isgppColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.serviceName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                      label: '${service.totalVisits} visites',
                      icon: Icons.assignment_outlined,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label:
                      'Score: ${service.averageIsgpp.toStringAsFixed(1)}/5',
                      icon: Icons.star_outline,
                    ),
                    const SizedBox(width: 8),
                    if (service.alertCount > 0)
                      _StatChip(
                        label: '${service.alertCount} alerte(s)',
                        icon: Icons.warning_amber_outlined,
                        color: AppColors.primaryError,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Sparkline à droite du titre
          SizedBox(
            width: 260,
            height: 60,
            child: _buildServiceSparkline(service, dashboardFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStats(
      ServiceStats service, DashboardFilterState dashboardFilters) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _StatCard(
            title: 'Satisfaction',
            icon: Icons.trending_up_rounded,
            items: [
              _StatItem(
                'Score ISGPP',
                '${service.averageIsgpp.toStringAsFixed(2)}/5',
                service.isgppColor,
              ),
              _StatItem(
                'Taux satisfaction',
                '${(service.averageIsgpp * 20).toStringAsFixed(0)}%',
                service.isgppColor,
              ),
              _StatItem(
                'Total visites',
                '${service.totalVisits}',
                AppColors.primaryBlue,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Alertes',
            icon: Icons.warning_amber_rounded,
            items: [
              _StatItem(
                'Visites en alerte',
                '${service.alertCount}',
                service.alertCount > 0
                    ? AppColors.primaryError
                    : AppColors.primarySuccess,
              ),
              _StatItem(
                'Taux d\'alerte',
                '${(service.alertCount / service.totalVisits * 100).toStringAsFixed(1)}%',
                AppColors.primaryWarning,
              ),
              _StatItem(
                'Patients affectés',
                '${service.patients.length}',
                AppColors.primaryBlue,
              ),
            ],
            // Bouton "Voir alertes" dans la carte Alertes
            actionButton: service.alertCount > 0
                ? OutlinedButton.icon(
              onPressed: () =>
                  _goToAlertsFiltered(service.serviceName),
              icon: const Icon(Icons.warning_amber_rounded, size: 14),
              label: const Text('Voir'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryError,
                side: const BorderSide(color: AppColors.primaryError),
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                textStyle: const TextStyle(fontSize: 11),
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  // Sparkline pour le service
  Widget _buildServiceSparkline(
      ServiceStats service, DashboardFilterState dashboardFilters) {
    // Récupérer tous les scores du service filtrés par date
    final now = DateTime.now();
    final startDate = dashboardFilters.periode?.start ??
        now.subtract(const Duration(days: 30));
    final endDate = dashboardFilters.periode?.end ?? now;

    final scores = <double>[];
    for (final patient in service.patients) {
      for (final visit in patient.visits) {
        if (visit.service == service.serviceName &&
            visit.date.isAfter(startDate) &&
            visit.date.isBefore(endDate.add(const Duration(days: 1)))) {
          if (visit.survey != null) {
            scores.add(visit.survey!.qualitePriseEnCharge.toDouble());
          }
        }
      }
    }

    // Si pas de scores, afficher un message
    if (scores.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Pas de données',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Afficher la sparkline
    return CustomPaint(
      painter: SparklinePainter(data: scores),
      size: const Size(double.infinity, 60),
    );
  }

  Widget _buildPatientsInService(ServiceStats service, DateFormat dateFormat) {
    // Filtrer les patients selon les filtres dashboard
    final dashboardFilters = ref.watch(filterProvider);
    final filteredPatients = service.patients.where((patient) {
      var visites = patient.visits;

      // Filtrer par type
      if (dashboardFilters.type != null && dashboardFilters.type!.isNotEmpty) {
        visites = visites
            .where((v) => v.visitType == dashboardFilters.type)
            .toList();
      }

      // Filtrer par exploration
      if (dashboardFilters.exploration != null &&
          dashboardFilters.exploration!.isNotEmpty) {
        visites = visites
            .where((v) => v.exploration == dashboardFilters.exploration)
            .toList();
      }

      // Filtrer par période
      if (dashboardFilters.periode != null) {
        visites = visites
            .where((v) =>
        v.date.isAfter(dashboardFilters.periode!.start) &&
            v.date.isBefore(dashboardFilters.periode!.end
                .add(const Duration(days: 1))))
            .toList();
      }

      return visites.isNotEmpty;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 16,
                  color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                'Patients (${filteredPatients.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (filteredPatients.isEmpty)
            const Text(
              'Aucun patient ne correspond aux filtres.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredPatients.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.divider, height: 1),
              itemBuilder: (_, i) {
                final patient = filteredPatients[i];
                return _PatientServiceTile(
                  patient: patient,
                  dateFormat: dateFormat,
                  onTap: () => _showPatientMenu(patient),
                );
              },
            ),
        ],
      ),
    );
  }

  // ─── MENU PATIENT ──────────────────────────────────────────────────────────
  void _showPatientMenu(PatientModel patient) {
    showAdaptiveSheet(
      context,
      child: SheetBase(
        child: _PatientMenuSheet(
          patient: patient,
          onViewPatient: () {
            Navigator.pop(context);
            _goToPatientDetail(patient);
          },
          onCreateAlert: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Création d\'alerte - À implémenter')),
            );
          },
        ),
      ),
    );
  }
  void _goToPatientDetail(PatientModel patient) {
    // Set le patient sélectionné et navigate vers l'historique
    ref.read(selectedPatientProvider.notifier).setPatient(patient.id);
    ref.read(navigationProvider.notifier).setIndex(2);
  }

  void _goToAlertsFiltered(String serviceName) {
    // Set le filtre service et navigate vers les alertes
    ref.read(filterProvider.notifier).updateService(serviceName);
    ref.read(navigationProvider.notifier).setIndex(1);
  }

  int? _sortIndex(ServiceSortColumn col) {
    switch (col) {
      case ServiceSortColumn.name:
        return 0;
      case ServiceSortColumn.visits:
        return 1;
      case ServiceSortColumn.isgpp:
        return 2;
      case ServiceSortColumn.alerts:
        return 3;
    }
  }
}

// ────────────────────────────────────────────────────────────────────────────
// WIDGETS RÉUTILISABLES
// ────────────────────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  final String label;
  const _ColHeader(this.label);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textMid,
      letterSpacing: 0.3,
    ),
  );
}

class _IsgppBadge extends StatelessWidget {
  final double score;
  const _IsgppBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final color = ServiceStats.getIsgppColor(score);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        score.toStringAsFixed(2),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SatisfactionBar extends StatelessWidget {
  final double rate;
  const _SatisfactionBar({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate / 100,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(
              rate >= 80
                  ? AppColors.primarySuccess
                  : rate >= 60
                  ? AppColors.primaryWarning
                  : AppColors.primaryError,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${rate.toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.icon,
    this.color = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _SideServiceList extends StatelessWidget {
  final List<ServiceStats> services;
  final ServiceStats selected;
  final void Function(ServiceStats) onSelect;

  const _SideServiceList({
    required this.services,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: services.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.divider),
        itemBuilder: (_, i) {
          final service = services[i];
          final isSelected = service.serviceName == selected.serviceName;

          return InkWell(
            onTap: () => onSelect(service),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              color: isSelected ? const Color(0xFFF1F5F9) : null,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: service.isgppColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.serviceName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${service.totalVisits} visites',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_rounded, size: 16,
                        color: AppColors.primaryBlue),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color color;
  const _StatItem(this.label, this.value, this.color);
}

class _StatCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_StatItem> items;
  final Widget? actionButton;

  const _StatCard({
    required this.title,
    required this.icon,
    required this.items,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (actionButton != null) actionButton!,
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: item.color,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PatientServiceTile extends StatelessWidget {
  final PatientModel patient;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  const _PatientServiceTile({
    required this.patient,
    required this.dateFormat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = patient.firstName[0] + patient.lastName[0];

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLighter,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${patient.firstName} ${patient.lastName}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        patient.ipp,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18,
                    color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: 8),
            if (patient.visits.isNotEmpty)
              ...patient.visits.map((visit) => Padding(
                padding: const EdgeInsets.only(left: 42, top: 4),
                child: _VisitSummary(
                  visit: visit,
                  dateFormat: dateFormat,
                ),
              )),
          ],
        ),
      ),
    );
  }
}

class _VisitSummary extends StatelessWidget {
  final VisitModel visit;
  final DateFormat dateFormat;

  const _VisitSummary({
    required this.visit,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${visit.visitType} • ${dateFormat.format(visit.date)}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (visit.hasAlert) ...[
            const SizedBox(width: 6),
            const Icon(Icons.warning_amber_rounded, size: 10,
                color: AppColors.primaryError),
          ],
          if (visit.survey != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                '${visit.survey!.qualitePriseEnCharge}/5',
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── PATIENT MENU SHEET ────────────────────────────────────────────────────
class _PatientMenuSheet extends StatelessWidget {
  final PatientModel patient;
  final VoidCallback onViewPatient;
  final VoidCallback onCreateAlert;

  const _PatientMenuSheet({
    required this.patient,
    required this.onViewPatient,
    required this.onCreateAlert,
  });

  @override
  Widget build(BuildContext context) {
    final latestVisit = patient.latestVisit;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${patient.firstName} ${patient.lastName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'IPP: ${patient.ipp}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Verbatims si disponibles
        if (latestVisit?.survey != null) ...[
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verbatims',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _VerbatimTile(
                  title: 'Parcours',
                  verbatim: latestVisit!.survey!.raconteParcours,
                ),
                const SizedBox(height: 8),
                _VerbatimTile(
                  title: 'Moment marquant',
                  verbatim: latestVisit.survey!.momentMarquant,
                ),
                const SizedBox(height: 8),
                _VerbatimTile(
                  title: 'Suggestions',
                  verbatim: latestVisit.survey!.suggestionsAmelioration,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
        // Actions
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: onViewPatient,
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Voir le patient en détail'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onCreateAlert,
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Générer une alerte'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryError,
                  side: const BorderSide(color: AppColors.primaryError),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerbatimTile extends StatelessWidget {
  final String title;
  final Verbatim verbatim;

  const _VerbatimTile({
    required this.title,
    required this.verbatim,
  });

  @override
  Widget build(BuildContext context) {
    if (verbatim.message.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"${verbatim.message}"',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          if (verbatim.classe.isNotEmpty || verbatim.polarite.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (verbatim.classe.isNotEmpty)
                  _Tag(label: verbatim.classe, color: AppColors.primaryBlue),
                if (verbatim.polarite.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  _Tag(label: verbatim.polarite, color: AppColors.textSecondary),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─── LOADING / ERROR ───────────────────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => const Center(
    child: CircularProgressIndicator(
      color: AppColors.primaryBlue,
      strokeWidth: 2,
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, size: 40,
            color: AppColors.primaryError),
        const SizedBox(height: 12),
        const Text('Erreur de chargement',
            style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        Text(error,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    ),
  );
}