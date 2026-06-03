import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/models/visit_model.dart';
import 'package:puls/core/shared_widget/empty_state.dart';

import '../../../core/models/service_stats_model.dart';
import '../../../core/provider/service_stats_provider.dart';



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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(filteredServiceStatsProvider);
    final filters = ref.watch(serviceFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Barre de filtres
          _buildFilterBar(filters),

          // Contenu principal
          Expanded(
            child: statsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (stats) => stats.isEmpty
                  ? const EmptyState(reason: EmptyStateReason.noData)
                  : _selectedService != null
                      ? _buildDetailView(stats)
                      : _buildTableView(stats, filters),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlueLighter,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  size: 24,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Vue d\'ensemble des services et leurs performances',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BARRE DE FILTRES ──────────────────────────────────────────────────────
  Widget _buildFilterBar(ServiceFilterState filters) {
    final notifier = ref.read(serviceFilterProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: Row(
        children: [
          // Recherche
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                onChanged: (v) => notifier.setSearch(v),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un service...',
                  border: InputBorder.none,
                  isDense: true,
                  prefixIcon: Icon(Icons.search_rounded, size: 18),
                  prefixIconConstraints: BoxConstraints(minWidth: 36),
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                ),
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (filters.searchQuery.isNotEmpty)
            TextButton.icon(
              onPressed: () => notifier.reset(),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Réinitialiser'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: const TextStyle(fontSize: 13),
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
    // Calcul du taux de satisfaction (%)
    final satisfactionRate = service.averageIsgpp * 20; // /5 → /100

    return DataRow2(
      onTap: () => setState(() => _selectedService = service),
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFFF8F9FB);
        return null;
      }),
      cells: [
        // Nom du service
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
        // Nombre de visites
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
        // Score ISGPP
        DataCell(
          _IsgppBadge(score: service.averageIsgpp),
        ),
        // Alertes
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
        // Taux de satisfaction (barre)
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
  Widget _buildDetailView(List<ServiceStats> allStats) {
    final service = _selectedService!;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste latérale des services
        SizedBox(
          width: 260,
          child: _SideServiceList(
            services: allStats,
            selected: service,
            onSelect: (svc) => setState(() => _selectedService = svc),
          ),
        ),
        // Détail principal
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 0, 28, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header détail
                _buildDetailHeader(service),

                // Grille stats
                _buildDetailStats(service),

                const SizedBox(height: 12),

                // Liste des patients du service
                _buildPatientsInService(service, dateFormat),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailHeader(ServiceStats service) {
    final satisfactionRate = service.averageIsgpp * 20;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
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
        ],
      ),
    );
  }

  Widget _buildDetailStats(ServiceStats service) {
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
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsInService(ServiceStats service, DateFormat dateFormat) {
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
                'Patients (${service.patients.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (service.patients.isEmpty)
            const Text(
              'Aucun patient dans ce service.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: service.patients.length,
              separatorBuilder: (_, __) =>
                  Divider(color: AppColors.divider, height: 1),
              itemBuilder: (_, i) {
                final patient = service.patients[i];
                return _PatientServiceTile(
                  patient: patient,
                  dateFormat: dateFormat,
                );
              },
            ),
        ],
      ),
    );
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
  final double rate; // 0-100

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

// ─── SIDE SERVICE LIST ─────────────────────────────────────────────────────
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

// ─── STAT CARDS ────────────────────────────────────────────────────────────
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

  const _StatCard({
    required this.title,
    required this.icon,
    required this.items,
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

// ─── PATIENT TILE ──────────────────────────────────────────────────────────
class _PatientServiceTile extends StatelessWidget {
  final PatientModel patient;
  final DateFormat dateFormat;

  const _PatientServiceTile({
    required this.patient,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context) {
    final initials = patient.firstName[0] + patient.lastName[0];

    return Padding(
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
            ],
          ),
          const SizedBox(height: 8),
          // Visites du patient dans ce service
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
