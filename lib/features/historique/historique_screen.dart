// ===========================================================================
// historique_screen.dart
// Dépendances à ajouter dans pubspec.yaml :
//   data_table_2: ^2.5.12
//   intl: ^0.19.0
// ===========================================================================


// ---------------------------------------------------------------------------
// THÈME MENTHE
// ---------------------------------------------------------------------------
import 'dart:ui';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- Vérifie cet import
import 'package:puls/features/historique/presentation/BuildHeader.dart';
import '../../core/color.dart';
import '../../core/models/patient.dart';
import '../../core/provider/filterprovider.dart';
import '../../core/provider/patient_provider.dart';


// ---------------------------------------------------------------------------
// PROVIDER : état des filtres + tri pour l'historique
// ---------------------------------------------------------------------------
enum SortColumn { nom, date, service, type, score, none }
enum SortDirection { asc, desc }

class HistoriqueFilterState {
  final String searchQuery;
  final String serviceFilter;
  final String typeFilter;
  final String alertFilter; // 'all' | 'alert' | 'ok'
  final SortColumn sortColumn;
  final SortDirection sortDirection;

  const HistoriqueFilterState({
    this.searchQuery = '',
    this.serviceFilter = '',
    this.typeFilter = '',
    this.alertFilter = 'all',
    this.sortColumn = SortColumn.date,
    this.sortDirection = SortDirection.desc,
  });

  HistoriqueFilterState copyWith({
    String? searchQuery,
    String? serviceFilter,
    String? typeFilter,
    String? alertFilter,
    SortColumn? sortColumn,
    SortDirection? sortDirection,
  }) {
    return HistoriqueFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      serviceFilter: serviceFilter ?? this.serviceFilter,
      typeFilter: typeFilter ?? this.typeFilter,
      alertFilter: alertFilter ?? this.alertFilter,
      sortColumn: sortColumn ?? this.sortColumn,
      sortDirection: sortDirection ?? this.sortDirection,
    );
  }
}

class HistoriqueFilterNotifier extends Notifier<HistoriqueFilterState> {
  @override
  HistoriqueFilterState build() => const HistoriqueFilterState();

  void setSearch(String v) => state = state.copyWith(searchQuery: v);

  void setService(String v) => state = state.copyWith(serviceFilter: v);

  void setType(String v) => state = state.copyWith(typeFilter: v);

  void setAlert(String v) => state = state.copyWith(alertFilter: v);

  void reset() => state = const HistoriqueFilterState();

  void setSort(SortColumn col) {
    if (state.sortColumn == col) {
      state = state.copyWith(
        sortDirection: state.sortDirection == SortDirection.asc
            ? SortDirection.desc
            : SortDirection.asc,
      );
    } else {
      state = state.copyWith(sortColumn: col, sortDirection: SortDirection.asc);
    }
  }
}

final historiqueFilterProvider =
NotifierProvider<HistoriqueFilterNotifier, HistoriqueFilterState>(
    HistoriqueFilterNotifier.new);

// Provider dérivé : liste filtrée + triée


// ---------------------------------------------------------------------------
// ÉCRAN PRINCIPAL
// ---------------------------------------------------------------------------
class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  PatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
        _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(filteredHistoriqueProvider);
    final filters = ref.watch(historiqueFilterProvider);

    return Scaffold(
      backgroundColor: MintTheme.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          buildHeader(patientsAsync, filters),
          _buildFilterBar(filters),
          Expanded(
            child: patientsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (patients) =>
              patients.isEmpty
                  ? const _EmptyState()
                  : _selectedPatient != null
                  ? _buildDetailView(patients)
                  : _buildTableView(patients, filters),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  // ─── BARRE DE FILTRES ──────────────────────────────────────────────────────
  Widget _buildFilterBar(HistoriqueFilterState filters) {
    final patientsAll = ref.watch(patientsListProvider);
    final services = patientsAll.whenOrNull(
      data: (l) =>
      l.map((p) => p.service).toSet().where((s) => s.isNotEmpty).toList()
        ..sort(),
    ) ?? [];
    final types = patientsAll.whenOrNull(
      data: (l) =>
      l.map((p) => p.visitType).toSet().where((s) => s.isNotEmpty).toList()
        ..sort(),
    ) ?? [];

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: Row(
        children: [
          // Recherche
          const SizedBox(width: 10),
          // Service
          _DropdownFilter(
            hint: 'Service',
            value: filters.serviceFilter.isEmpty ? null : filters.serviceFilter,
            items: services,
            onChanged: (v) =>
                ref.read(historiqueFilterProvider.notifier).setService(v ?? ''),
          ),
          const SizedBox(width: 10),
          // Type
          _DropdownFilter(
            hint: 'Type de visite',
            value: filters.typeFilter.isEmpty ? null : filters.typeFilter,
            items: types,
            onChanged: (v) =>
                ref.read(historiqueFilterProvider.notifier).setType(v ?? ''),
          ),
          const SizedBox(width: 10),
          // Alertes — classeur par onglets
          _AlertTabFilter(
              current: filters.alertFilter,
              onChanged: (v) =>
                  ref.read(historiqueFilterProvider.notifier).setAlert(v)
          ),
          Spacer(),
          if (filters != const HistoriqueFilterState())
          TextButton.icon(
            onPressed: () {
              ref.read(historiqueFilterProvider.notifier).reset();
            },
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Réinitialiser'),
            style: TextButton.styleFrom(
              foregroundColor: MintTheme.mint600,
              textStyle: const TextStyle(fontSize: 13),
            ),
          )
        ],
      ),
    );
  }

  // ─── TABLEAU ───────────────────────────────────────────────────────────────
  Widget _buildTableView(List<PatientModel> patients,
      HistoriqueFilterState filters) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
      child: Container(
        decoration: BoxDecoration(
          color: MintTheme.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: MintTheme.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 20,
            minWidth: 900,
            headingRowHeight: 44,
            dataRowHeight: 58,
            headingRowColor: WidgetStateProperty.all(MintTheme.mint50),
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: MintTheme.border.withOpacity(0.6), width: 0.5),
            ),
            sortColumnIndex: _sortIndex(filters.sortColumn),
            sortAscending: filters.sortDirection == SortDirection.asc,
            columns: [
              DataColumn2(
                label: _ColHeader('Patient'),
                onSort: (_, __) =>
                    ref.read(historiqueFilterProvider.notifier).setSort(
                        SortColumn.nom),
                size: ColumnSize.L,
              ),
              DataColumn2(
                label: _ColHeader('IPP'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Service'),
                onSort: (_, __) =>
                    ref.read(historiqueFilterProvider.notifier).setSort(
                        SortColumn.service),
              ),
              DataColumn2(
                label: _ColHeader('Type visite'),
                onSort: (_, __) =>
                    ref.read(historiqueFilterProvider.notifier).setSort(
                        SortColumn.type),
              ),
              DataColumn2(
                label: _ColHeader('Recommandation'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Date'),
                onSort: (_, __) =>
                    ref.read(historiqueFilterProvider.notifier).setSort(
                        SortColumn.date),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: _ColHeader('Statut'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: const SizedBox.shrink(),
                size: ColumnSize.S,
              ),
            ],
            rows: patients.map((p) => _buildRow(p, dateFormat)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow2 _buildRow(PatientModel p, DateFormat fmt) {
    return DataRow2(
      onTap: () => setState(() => _selectedPatient = p),
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return MintTheme.mint50;
        return null;
      }),
      cells: [
        // Nom
        DataCell(Row(
          children: [
            _Avatar(firstName: p.firstName, lastName: p.lastName),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${p.firstName} ${p.lastName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: MintTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.sex,
                    style: const TextStyle(
                        fontSize: 11, color: MintTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        )),
        // IPP
        DataCell(Text(
          p.ipp,
          style: const TextStyle(fontSize: 12,
              color: MintTheme.textSecondary,
              fontFamily: 'monospace'),
        )),
        // Service
        DataCell(_Tag(
            label: p.service, color: MintTheme.mint600, bg: MintTheme.mint100)),
        // Type visite
        DataCell(_Tag(label: p.visitType,
            color: MintTheme.tagBlue,
            bg: MintTheme.tagBlueBg)),
        // Q0 — recommandation
        DataCell(_ScoreBadge(score: p.patientResponse.q0)),
        // Date
        DataCell(Text(
          fmt.format(p.date),
          style: const TextStyle(fontSize: 12, color: MintTheme.textSecondary),
        )),
        // Alerte
        DataCell(p.hasAlert
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: MintTheme.alertRedBg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: MintTheme.alertRed.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 13,
                  color: MintTheme.alertRed),
              SizedBox(width: 4),
              Text('Alerte', style: TextStyle(fontSize: 11,
                  color: MintTheme.alertRed,
                  fontWeight: FontWeight.w500)),
            ],
          ),
        )
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: MintTheme.mint50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: MintTheme.mint200),
          ),
          child: const Text('OK', style: TextStyle(fontSize: 11,
              color: MintTheme.mint700,
              fontWeight: FontWeight.w500)),
        )),
        // Action
        DataCell(IconButton(
          icon: const Icon(
              Icons.chevron_right_rounded, size: 20, color: MintTheme.mint600),
          onPressed: () => setState(() => _selectedPatient = p),
          splashRadius: 18,
        )),
      ],
    );
  }

  // ─── VUE DÉTAIL ───────────────────────────────────────────────────────────
  Widget _buildDetailView(List<PatientModel> patients) {
    final p = _selectedPatient!;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste latérale réduite
        SizedBox(
          width: 260,
          child: _SidePatientList(
            patients: patients,
            selected: p,
            onSelect: (pat) => setState(() => _selectedPatient = pat),
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
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MintTheme.cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MintTheme.border),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        color: MintTheme.mint600,
                        onPressed: () =>
                            setState(() => _selectedPatient = null),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 12),
                      _Avatar(firstName: p.firstName,
                          lastName: p.lastName,
                          size: 46),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${p.firstName} ${p.lastName}',
                                  style: const TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: MintTheme.textPrimary),
                                ),
                                if (p.hasAlert) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: MintTheme.alertRedBg,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: MintTheme.alertRed.withOpacity(
                                              0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.warning_amber_rounded,
                                            size: 13,
                                            color: MintTheme.alertRed),
                                        SizedBox(width: 4),
                                        Text('Alerte active', style: TextStyle(
                                            fontSize: 11,
                                            color: MintTheme.alertRed,
                                            fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IPP ${p.ipp}  •  ${p.sex}  •  ${dateFormat
                                  .format(p.date)}',
                              style: const TextStyle(
                                  fontSize: 12, color: MintTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Grille infos
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _InfoCard(
                      title: 'Informations prise en charge',
                      icon: Icons.local_hospital_outlined,
                      items: [
                        _InfoItem('Service', p.service),
                        _InfoItem('Type de visite', p.visitType),
                        _InfoItem('Exploration', p.exploration),
                        _InfoItem('Suivi sortie', p.afterCare),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoCard(
                      title: 'Réponses questionnaire',
                      icon: Icons.quiz_outlined,
                      items: [
                        _InfoItem('Recommandation (Q0)', p.patientResponse.q0),
                        _InfoItem(
                            'Satisfaction globale (Q1)', p.patientResponse.q1),
                        _InfoItem('Rappelé (Q5)',
                            p.patientResponse.q5 ? 'Oui' : 'Non'),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Verbatims
                _VerbatimCard(
                    title: 'Verbatim Q2', verbatim: p.patientResponse.q2),
                const SizedBox(height: 12),
                _VerbatimCard(
                    title: 'Verbatim Q3', verbatim: p.patientResponse.q3),
                const SizedBox(height: 12),
                _VerbatimCard(
                    title: 'Verbatim Q4', verbatim: p.patientResponse.q4),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int? _sortIndex(SortColumn col) {
    switch (col) {
      case SortColumn.nom:
        return 0;
      case SortColumn.service:
        return 2;
      case SortColumn.type:
        return 3;
      case SortColumn.date:
        return 5;
      default:
        return null;
    }
  }
}

// ---------------------------------------------------------------------------
// WIDGETS UTILITAIRES
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String firstName;
  final String lastName;
  final double size;

  const _Avatar(
      {required this.firstName, required this.lastName, this.size = 34});

  @override
  Widget build(BuildContext context) {
    final initials = '${firstName.isNotEmpty ? firstName[0] : ''}${lastName
        .isNotEmpty ? lastName[0] : ''}'.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: MintTheme.mint100,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w600,
          color: MintTheme.mint700,
        ),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;

  const _ColHeader(this.label);

  @override
  Widget build(BuildContext context) =>
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: MintTheme.textSecondary,
          letterSpacing: 0.3,
        ),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) =>
      label.isEmpty
          ? const SizedBox.shrink()
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      );
}

class _ScoreBadge extends StatelessWidget {
  final String score;

  const _ScoreBadge({required this.score});

  Color _color() {
    final s = score.toUpperCase();
    if (s.contains('OUI TOTALEMENT')) return MintTheme.mint600;
    if (s.contains('OUI PLUTOT')) return MintTheme.mint400;
    if (s.contains('EN PARTIE')) return const Color(0xFFD69E2E);
    if (s.contains('NON')) return MintTheme.alertRed;
    return MintTheme.textSecondary;
  }

  Color _bg() {
    final s = score.toUpperCase();
    if (s.contains('OUI TOTALEMENT')) return MintTheme.mint100;
    if (s.contains('OUI PLUTOT')) return MintTheme.mint50;
    if (s.contains('EN PARTIE')) return const Color(0xFFFEF3C7);
    if (s.contains('NON')) return MintTheme.alertRedBg;
    return const Color(0xFFF7F7F7);
  }

  @override
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _bg(),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          score,
          style: TextStyle(
              fontSize: 10, color: _color(), fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      );
}



class _DropdownFilter extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final void Function(String?) onChanged;

  const _DropdownFilter({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) =>
      SizedBox(
        height: 38,
        child: DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value != null ? MintTheme.mint400 : MintTheme.border,
                width: value != null ? 1.5 : 1,
              ),
            ),
            child: DropdownButton<String>(
              hint: Text(hint, style: const TextStyle(
                  fontSize: 13, color: MintTheme.textSecondary)),
              value: value,
              isDense: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18,
                  color: MintTheme.mint600),
              style: const TextStyle(
                  fontSize: 13, color: MintTheme.textPrimary),
              onChanged: onChanged,
              items: [
                DropdownMenuItem<String>(
                    value: '', child: Text('Tous — $hint')),
                ...items.map((s) =>
                    DropdownMenuItem<String>(value: s, child: Text(s))),
              ],
            ),
          ),
        ),
      );
}

class _AlertTabFilter extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const _AlertTabFilter({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ('all', 'Tous'),
      ('alert', 'Alertes'),
      ('ok', 'Sans alerte'),
    ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MintTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: tabs.map((tab) {
          final isActive = current == tab.$1;
          return GestureDetector(
            onTap: () => onChanged(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isActive ? MintTheme.mint400 : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                tab.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : MintTheme.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── LISTE LATÉRALE (vue détail) ───────────────────────────────────────────
class _SidePatientList extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientModel selected;
  final void Function(PatientModel) onSelect;

  const _SidePatientList({
    required this.patients,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yy', 'fr_FR');
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 0, 12, 24),
      decoration: BoxDecoration(
        color: MintTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MintTheme.border),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: patients.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: MintTheme.border.withOpacity(0.7)),
        itemBuilder: (_, i) {
          final p = patients[i];
          final isSelected = p.id == selected.id;
          return InkWell(
            onTap: () => onSelect(p),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isSelected ? MintTheme.mint50 : null,
              child: Row(
                children: [
                  if (p.hasAlert)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                          Icons.circle, size: 7, color: MintTheme.alertRed),
                    ),
                  _Avatar(
                      firstName: p.firstName, lastName: p.lastName, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.firstName} ${p.lastName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: MintTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          fmt.format(p.date),
                          style: const TextStyle(
                              fontSize: 10, color: MintTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.chevron_right_rounded, size: 16,
                        color: MintTheme.mint600),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── CARDS DÉTAIL ──────────────────────────────────────────────────────────
class _InfoItem {
  final String label;
  final String value;

  const _InfoItem(this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoItem> items;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MintTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MintTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: MintTheme.mint600),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MintTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                            fontSize: 12, color: MintTheme.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value.isEmpty ? '—' : item.value,
                        style: const TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: MintTheme.textPrimary),
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

class _VerbatimCard extends StatelessWidget {
  final String title;
  final dynamic verbatim; // PatientResponse.Verbatim

  const _VerbatimCard({required this.title, required this.verbatim});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: MintTheme.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: MintTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 16,
                  color: MintTheme.mint600),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: MintTheme.textPrimary),
              ),
              const Spacer(),
              _Tag(label: verbatim.classe,
                  color: MintTheme.mint600,
                  bg: MintTheme.mint100),
              const SizedBox(width: 6),
              _Tag(label: verbatim.sousClasse,
                  color: MintTheme.tagBlue,
                  bg: MintTheme.tagBlueBg),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MintTheme.mint50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: MintTheme.mint100),
            ),
            child: Text(
              verbatim.message.isEmpty ? 'Aucun commentaire.' : '"${verbatim
                  .message}"',
              style: const TextStyle(
                fontSize: 13,
                color: MintTheme.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ÉTATS VIDES / ERREUR / LOADING ────────────────────────────────────────
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) =>
      const Center(
        child: CircularProgressIndicator(
          color: MintTheme.mint400,
          strokeWidth: 2,
        ),
      );
}

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40,
                color: MintTheme.alertRed),
            const SizedBox(height: 12),
            Text('Erreur de chargement',
                style: TextStyle(fontSize: 15, color: MintTheme.textPrimary)),
            Text(error, style: const TextStyle(
                fontSize: 12, color: MintTheme.textSecondary)),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: MintTheme.mint200),
            const SizedBox(height: 16),
            const Text(
              'Aucun patient ne correspond aux filtres',
              style: TextStyle(fontSize: 15, color: MintTheme.textSecondary),
            ),
          ],
        ),
      );
}