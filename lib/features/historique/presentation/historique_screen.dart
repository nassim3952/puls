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
import 'package:intl/date_symbol_data_local.dart';
import 'package:puls/core/shared_widget/alert_patient_avatar.dart';
import 'package:puls/core/shared_widget/build_header.dart';
import '../../../core/color.dart';
import '../../../core/models/patient.dart';
import '../../../core/provider/historique_filter_controller.dart';
import '../../../core/provider/patient_provider.dart';
import '../../../core/shared_widget/empty_state.dart';


// ---------------------------------------------------------------------------
// PROVIDER : état des filtres + tri pour l'historique
// ---------------------------------------------------------------------------
enum SortColumn { nom, date, service, type, score, none }
enum SortDirection { asc, desc }

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
    final patientsAsync = ref.watch(filteredPatientsProvider);
    final filters = ref.watch(historiqueFilterProvider);


    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          DashboardHeader(),
          _buildFilterBar(filters),
          Expanded(
            child: patientsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (patients) =>
              patients.isEmpty
                  ? const EmptyState()
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

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
      child: Row(
        children: [
          // Recherche
          const SizedBox(width: 10),
          // Service
          const SizedBox(width: 10),
          // Type
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
                foregroundColor: AppColors.primaryBlue,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: DataTable2(
            columnSpacing: 16,
            horizontalMargin: 20,
            minWidth: 900,
            headingRowHeight: 44,
            dataRowHeight: 58,
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FB)),
            border: TableBorder(
              horizontalInside: BorderSide(
                  color: AppColors.divider, width: 0.5),
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
            ],
            rows: patients.map((p) => _buildRow(p, dateFormat)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow2 _buildRow(PatientModel p, DateFormat fmt) {
    final initials = p.firstName[0] + p.lastName[0];
    final bool hasAlert = p.latestVisit?.hasAlert ?? false;
    return DataRow2(
      onTap: () => setState(() => _selectedPatient = p),
      color: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.hovered)) return const Color(0xFFF8F9FB);
        return null;
      }),
      cells: [
        // Nom
        DataCell(Row(
          children: [
            alertPatientAvatar(initials,36,hasAlert),
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
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    p.sex,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
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
              color: AppColors.textSecondary,
              fontFamily: 'monospace'),
        )),
        // Service
        DataCell(Text(
          p.latestVisit?.service ?? '–',
          style: const TextStyle(fontSize: 12, color: AppColors.textMid),
          overflow: TextOverflow.ellipsis,
        )),
        // Type visite
        DataCell(Text(
          p.latestVisit?.visitType ?? '–',
          style: const TextStyle(fontSize: 12, color: AppColors.textMid),
          overflow: TextOverflow.ellipsis,
        )),
        // attentesSoins (q1) — recommandation
        DataCell(_ScoreBadge(score: p.latestVisit?.survey?.attentesSoins ?? '–')),
        // Date
        DataCell(Text(
          p.latestVisit != null ? fmt.format(p.latestVisit!.date) : '–',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        )),
        // Alerte
        DataCell((p.latestVisit?.hasAlert ?? false)
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryError.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.primaryError.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded, size: 13,
                  color: AppColors.primaryError),
              SizedBox(width: 4),
              Text('Alerte', style: TextStyle(fontSize: 11,
                  color: AppColors.primaryError,
                  fontWeight: FontWeight.w500)),
            ],
          ),
        )
            : Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text('OK', style: TextStyle(fontSize: 11,
              color: AppColors.textMid,
              fontWeight: FontWeight.w500)),
        )),
      ],
    );
  }

  // ─── VUE DÉTAIL ───────────────────────────────────────────────────────────
  Widget _buildDetailView(List<PatientModel> patients) {
    final p = _selectedPatient!;
    final initials = p.firstName[0] + p.lastName[0];
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
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.surface),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, size: 20),
                        color: AppColors.primaryBlue,
                        onPressed: () =>
                            setState(() => _selectedPatient = null),
                        splashRadius: 20,
                      ),
                      const SizedBox(width: 12),
                      alertPatientAvatar(initials,36,false),
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
                                      color: AppColors.textPrimary),
                                ),
                                if (p.latestVisit?.hasAlert ?? false) ...[
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.primaryError.withOpacity(
                                              0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.warning_amber_rounded,
                                            size: 13,
                                            color: AppColors.primaryError),
                                        SizedBox(width: 4),
                                        Text('Alerte active', style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.primaryError,
                                            fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IPP ${p.ipp}  •  ${p.sex}  •  ${p.latestVisit != null ? dateFormat.format(p.latestVisit!.date) : '–'}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textPrimary),
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
                        _InfoItem('Service', p.latestVisit?.service ?? '–'),
                        _InfoItem('Type de visite', p.latestVisit?.visitType ?? '–'),
                        _InfoItem('Exploration', p.latestVisit?.exploration ?? '–'),
                        _InfoItem('Suivi sortie', p.latestVisit?.afterCare ?? '–'),
                      ],
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: _InfoCard(
                      title: 'Réponses questionnaire',
                      icon: Icons.quiz_outlined,
                      items: [
                        _InfoItem('Score satisfaction (Q0)', '${p.latestVisit?.survey?.qualitePriseEnCharge ?? '–'}/5'),
                        _InfoItem('Attentes soins (Q1)', p.latestVisit?.survey?.attentesSoins ?? '–'),
                        _InfoItem('Rappelé (Q5)',
                            p.latestVisit?.survey?.consentementRappel == true ? 'Oui' : 'Non'),
                      ],
                    )),
                  ],
                ),
                const SizedBox(height: 12),

                // Verbatims
                _VerbatimCard(
                    title: 'Verbatim Q2 — Parcours', verbatim: p.latestVisit?.survey?.raconteParcours ?? const _EmptyVerbatim()),
                const SizedBox(height: 12),
                _VerbatimCard(
                    title: 'Verbatim Q3 — Moment marquant', verbatim: p.latestVisit?.survey?.momentMarquant ?? const _EmptyVerbatim()),
                const SizedBox(height: 12),
                _VerbatimCard(
                    title: 'Verbatim Q4 — Suggestions', verbatim: p.latestVisit?.survey?.suggestionsAmelioration ?? const _EmptyVerbatim()),
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
          color: AppColors.textMid,
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
    if (s.contains('OUI TOTALEMENT')) return AppColors.primarySuccess;
    if (s.contains('EN ATTENTE')) return AppColors.primaryNeutral;
    if (s.contains('EN PARTIE')) return AppColors.primaryWarning;
    if (s.contains('NON')) return AppColors.primaryError;
    return AppColors.textSecondary;
  }


  @override
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: _color().withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _color(), width: 0.5),
        ),
        child: Text(
          score,
          style: TextStyle(
              fontSize: 11, color: _color()),
          overflow: TextOverflow.ellipsis,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surface),
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
                color: isActive ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                tab.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : AppColors.textSecondary,
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: patients.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.surface.withOpacity(0.7)),
        itemBuilder: (_, i) {
          final p = patients[i];
          final isSelected = p.id == selected.id;
          final initials = p.firstName[0] + p.lastName[0];
          return InkWell(
            onTap: () => onSelect(p),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              color: isSelected ? const Color(0xFFF1F5F9) : null,
              child: Row(
                children: [
                  if (p.latestVisit?.hasAlert ?? false)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(
                          Icons.circle, size: 7, color: AppColors.textPrimary),
                    ),


                  alertPatientAvatar(initials,36,false),
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
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          p.latestVisit != null ? fmt.format(p.latestVisit!.date) : '–',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const SizedBox(width: 6),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface),
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
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
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
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value.isEmpty ? '—' : item.value,
                        style: const TextStyle(fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, size: 16,
                  color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const Spacer(),
              _Tag(label: verbatim.classe,
                  color: AppColors.primaryBlue,
                  bg: AppColors.primaryBlueLighter),
              const SizedBox(width: 6),
              _Tag(label: verbatim.polarite,
                  color: AppColors.textPrimary,
                  bg: AppColors.surface),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLighter,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primaryBlueLighter),
            ),
            child: Text(
              verbatim.message.isEmpty ? 'Aucun commentaire.' : '"${verbatim
                  .message}"',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
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
// Fallback quand survey est null — évite le crash dans _VerbatimCard
class _EmptyVerbatim {
  final String message = '';
  final String classe = '';
  final String polarite = '';
  const _EmptyVerbatim();
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) =>
      const Center(
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
  Widget build(BuildContext context) =>
      Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40,
                color: AppColors.primaryError),
            const SizedBox(height: 12),
            Text('Erreur de chargement',
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
            Text(error, style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      );
}