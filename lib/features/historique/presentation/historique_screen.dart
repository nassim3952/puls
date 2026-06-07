// ===========================================================================
// historique_screen.dart  —  Vue Historique Patients
// Layout : 2 colonnes — liste patients (gauche) | détail + timeline (droite)
// ===========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:puls/core/shared_widget/alert_patient_avatar.dart';
import 'package:puls/core/shared_widget/build_header.dart';
import '../../../core/color.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/visit_model.dart';
import '../../../core/provider/alert_provider.dart';
import '../../../core/provider/historique_filter_controller.dart';
import '../../../core/provider/patient_provider.dart';
import '../../../core/shared_widget/custom_sparkline.dart';
import '../../../core/shared_widget/empty_state.dart';

// ---------------------------------------------------------------------------
// ENUMS — re-exportés pour patient_provider.dart
// ---------------------------------------------------------------------------
enum SortColumn { nom, date, service, type, score, none }
enum SortDirection { asc, desc }


// ---------------------------------------------------------------------------
// ROUTE OBSERVER — à enregistrer dans GoRouter :
//   observers: [historiqueRouteObserver]
// Permet d'invalider le cache patients à chaque retour sur cet écran.
// ---------------------------------------------------------------------------
final RouteObserver<ModalRoute<void>> historiqueRouteObserver =
RouteObserver<ModalRoute<void>>();

// ---------------------------------------------------------------------------
// ÉCRAN PRINCIPAL
// ---------------------------------------------------------------------------
class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen>
    with RouteAware {
  PatientModel? _selectedPatient;
  VisitModel? _selectedVisit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      historiqueRouteObserver.subscribe(this, route);
    }
  }

  /// Appelé par GoRouter quand on revient sur cet écran (changement de tab,
  /// retour arrière depuis une page enfant, etc.)
  @override
  void didPopNext() => _refresh();

  @override
  void didPush() => _refresh();

  void _refresh() {
    ref.invalidate(activeAlertsProvider(null));
  }

  @override
  void dispose() {
    historiqueRouteObserver.unsubscribe(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(historiqueListProvider);
    final filters = ref.watch(historiqueFilterProvider);

    // Re-synchronise la sélection quand la liste filtrée change.
    // On conserve le patient sélectionné même s'il sort des filtres actifs.
    patientsAsync.whenData((patients) {
      if (_selectedPatient != null) {
        final updated =
            patients.where((p) => p.id == _selectedPatient!.id).firstOrNull;
        if (updated != null && updated != _selectedPatient) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedPatient = updated);
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primaryBG,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          _buildToolbar(filters),
          Expanded(
            child: patientsAsync.when(
              loading: () => const _LoadingState(),
              error: (e, _) => _ErrorState(error: e.toString()),
              data: (patients) => patients.isEmpty && _selectedPatient == null
                  ? const EmptyState()
                  : _buildBody(patients),
            ),
          ),
        ],
      ),
    );
  }

  // ─── TOOLBAR ──────────────────────────────────────────────────────────────
  Widget _buildToolbar(HistoriqueFilterState filters) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Row(
        children: [
          // Recherche
          _SearchBar(
            controller: _searchController,
            mode: filters.searchMode,
            onChanged: (v) =>
                ref.read(historiqueFilterProvider.notifier).setSearch(v),
            onModeChanged: (m) =>
                ref.read(historiqueFilterProvider.notifier).setSearchMode(m),
          ),
          const SizedBox(width: 10),
          // Filtre alerte
          _AlertTabFilter(
            current: filters.alertFilter,
            onChanged: (v) =>
                ref.read(historiqueFilterProvider.notifier).setAlert(v),
          ),
          const Spacer(),
          // Compteur patients
          Consumer(builder: (ctx, r, _) {
            final async = r.watch(historiqueListProvider);
            return async.maybeWhen(
              data: (list) => _CountBadge(count: list.length),
              orElse: () => const SizedBox.shrink(),
            );
          }),
          if (filters != const HistoriqueFilterState()) ...[
            const SizedBox(width: 10),
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(historiqueFilterProvider.notifier).reset();
              },
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Réinitialiser'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── BODY PRINCIPAL ────────────────────────────────────────────────────────
  Widget _buildBody(List<PatientModel> patients) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne gauche — liste patients
        SizedBox(
          width: 340,
          child: _PatientList(
            patients: patients,
            selected: _selectedPatient,
            onSelect: (p) => setState(() {
              _selectedPatient = p;
              _selectedVisit = p.latestVisit;
            }),
          ),
        ),
        // Colonne droite — détail
        Expanded(
          child: _selectedPatient == null
              ? const _EmptyDetailPlaceholder()
              : _PatientDetailPane(
            patient: _selectedPatient!,
            selectedVisit: _selectedVisit,
            onVisitSelected: (v) =>
                setState(() => _selectedVisit = v),
            onClose: () => setState(() {
              _selectedPatient = null;
              _selectedVisit = null;
            }),
          ),
        ),
      ],
    );
  }
}

// ===========================================================================
// LISTE PATIENTS (colonne gauche)
// ===========================================================================
class _PatientList extends StatelessWidget {
  final List<PatientModel> patients;
  final PatientModel? selected;
  final void Function(PatientModel) onSelect;

  const _PatientList({
    required this.patients,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 12, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // En-tête colonne
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 0.8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 7),
                Text(
                  'Patients',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMid,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${patients.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Liste
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: patients.length,
              itemBuilder: (_, i) {
                final p = patients[i];
                final isSelected = selected?.id == p.id;
                return _PatientListTile(
                  patient: p,
                  isSelected: isSelected,
                  onTap: () => onSelect(p),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientListTile extends StatelessWidget {
  final PatientModel patient;
  final bool isSelected;
  final VoidCallback onTap;

  const _PatientListTile({
    required this.patient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final initials = '${p.firstName[0]}${p.lastName[0]}';
    final fmt = DateFormat('dd/MM/yy', 'fr_FR');
    final hasAlert = p.latestVisit?.hasAlert ?? false;
    final visitCount = p.visits.length;
    final alertCount = p.visits.where((v) => v.hasAlert && !v.alertResolved).length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlueLighter : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlueLight
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            alertPatientAvatar(initials, 38, hasAlert),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.firstName} ${p.lastName}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'IPP ${p.ipp}',
                        style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: AppColors.kTextSub,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$visitCount visite${visitCount > 1 ? 's' : ''}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (p.latestVisit != null)
                  Text(
                    fmt.format(p.latestVisit!.date),
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.kTextSub),
                  ),
                const SizedBox(height: 4),
                if (alertCount > 0)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                      AppColors.primaryError.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppColors.primaryError.withValues(alpha: 0.3),
                          width: 0.8),
                    ),
                    child: Text(
                      '$alertCount alerte${alertCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryError,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                else
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primarySuccess.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primarySuccess,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===========================================================================
// PANNEAU DÉTAIL (colonne droite)
// ===========================================================================
class _PatientDetailPane extends StatelessWidget {
  final PatientModel patient;
  final VisitModel? selectedVisit;
  final void Function(VisitModel) onVisitSelected;
  final VoidCallback onClose;

  const _PatientDetailPane({
    required this.patient,
    required this.selectedVisit,
    required this.onVisitSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final p = patient;
    final initials = '${p.firstName[0]}${p.lastName[0]}';
    final hasActiveAlert =
    p.visits.any((v) => v.hasAlert && !v.alertResolved);

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header patient ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                alertPatientAvatar(initials, 44, hasActiveAlert),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${p.firstName} ${p.lastName}',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(width: 10),
                          if (hasActiveAlert) _AlertBadge(),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          _MetaChip(
                              icon: Icons.badge_outlined,
                              label: 'IPP ${p.ipp}'),
                          const SizedBox(width: 8),
                          _MetaChip(
                              icon: Icons.person_outline_rounded,
                              label: p.sex),
                          const SizedBox(width: 8),
                          _MetaChip(
                              icon: Icons.history_rounded,
                              label:
                              '${p.visits.length} visite${p.visits.length > 1 ? 's' : ''}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Stats rapides + mini graphe côte à côte
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _QuickStats(patient: p),
                    const SizedBox(width: 16),
                    _MiniScoreChart(visits: p.visits),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Corps : timeline + détail visite ───────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline visites
                SizedBox(
                  width: 260,
                  child: _VisitTimeline(
                    visits: p.visits,
                    selected: selectedVisit,
                    onSelect: onVisitSelected,
                  ),
                ),
                const SizedBox(width: 12),
                // Détail visite sélectionnée
                Expanded(
                  child: selectedVisit == null
                      ? const _EmptyVisitPlaceholder()
                      : _VisitDetailCard(visit: selectedVisit!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats rapides (nb visites, alertes actives, dernière visite) ─────────
class _QuickStats extends StatelessWidget {
  final PatientModel patient;
  const _QuickStats({required this.patient});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final activeAlerts =
        patient.visits.where((v) => v.hasAlert && !v.alertResolved).length;
    final resolvedAlerts =
        patient.visits.where((v) => v.hasAlert && v.alertResolved).length;

    return Row(
      children: [
        _StatBox(
          value: '${patient.visits.length}',
          label: 'Visites',
          color: AppColors.primaryBlue,
          bg: AppColors.primaryBlueLighter,
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: '$activeAlerts',
          label: 'Alertes actives',
          color: activeAlerts > 0
              ? AppColors.primaryError
              : AppColors.primarySuccess,
          bg: activeAlerts > 0
              ? AppColors.primaryError.withValues(alpha: 0.07)
              : AppColors.primarySuccess.withValues(alpha: 0.07),
        ),
        const SizedBox(width: 8),
        if (patient.latestVisit != null)
          _StatBox(
            value: fmt.format(patient.latestVisit!.date),
            label: 'Dernière visite',
            color: AppColors.textMid,
            bg: const Color(0xFFF1F5F9),
          ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color bg;
  const _StatBox(
      {required this.value,
        required this.label,
        required this.color,
        required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ===========================================================================
// TIMELINE VISITES
// ===========================================================================
class _VisitTimeline extends StatelessWidget {
  final List<VisitModel> visits;
  final VisitModel? selected;
  final void Function(VisitModel) onSelect;

  const _VisitTimeline({
    required this.visits,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Tri chronologique décroissant (plus récent en haut)
    final sorted = [...visits]..sort((a, b) => b.date.compareTo(a.date));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // En-tête timeline
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                  bottom:
                  BorderSide(color: AppColors.divider, width: 0.8)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timeline_rounded,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 7),
                const Text(
                  'Parcours',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMid,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLighter,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${sorted.length}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          // Items timeline
          Expanded(
            child: ListView.builder(
              padding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: sorted.length,
              itemBuilder: (_, i) {
                final v = sorted[i];
                final isLast = i == sorted.length - 1;
                final isSelected = selected?.id == v.id;
                return _TimelineItem(
                  visit: v,
                  isLast: isLast,
                  isSelected: isSelected,
                  onTap: () => onSelect(v),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final VisitModel visit;
  final bool isLast;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.visit,
    required this.isLast,
    required this.isSelected,
    required this.onTap,
  });

  Color get _dotColor {
    if (visit.hasAlert && !visit.alertResolved) return AppColors.primaryError;
    if (visit.hasAlert && visit.alertResolved) return AppColors.primaryWarning;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'fr_FR');
    final fmtYear = DateFormat('yyyy', 'fr_FR');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne temporelle + point
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Point
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? _dotColor : _dotColor.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _dotColor,
                        width: isSelected ? 2.5 : 1.5),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                          color: _dotColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          spreadRadius: 1)
                    ]
                        : null,
                  ),
                ),
                // Ligne verticale
                if (!isLast)
                  Container(
                    width: 1.5,
                    height: 68,
                    color: AppColors.divider,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Contenu carte
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryBlueLighter
                    : const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryBlueLight
                      : AppColors.divider,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date
                  Text(
                    fmt.format(visit.date),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryBlueDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Type visite
                  Text(
                    visit.visitType.isEmpty ? '—' : visit.visitType,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Service
                  Text(
                    visit.service.isEmpty ? '—' : visit.service,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Badges statut
                  Row(
                    children: [
                      if (visit.survey != null)
                        _MiniScoreBadge(
                            score: visit.survey!.qualitePriseEnCharge),
                      const Spacer(),
                      if (visit.hasAlert)
                        _AlertStatusDot(resolved: visit.alertResolved),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniScoreBadge extends StatelessWidget {
  final dynamic score; // int ou double
  const _MiniScoreBadge({required this.score});

  Color _color() {
    final s = score?.toString() ?? '';
    final n = double.tryParse(s) ?? 0;
    if (n >= 4) return AppColors.primarySuccess;
    if (n >= 3) return AppColors.primaryWarning;
    return AppColors.primaryError;
  }

  @override
  Widget build(BuildContext context) {
    final s = score?.toString() ?? '–';
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: c.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 9, color: c),
          const SizedBox(width: 3),
          Text('$s/5',
              style: TextStyle(
                  fontSize: 10,
                  color: c,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AlertStatusDot extends StatelessWidget {
  final bool resolved;
  const _AlertStatusDot({required this.resolved});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: resolved
                ? AppColors.primaryWarning
                : AppColors.primaryError,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          resolved ? 'Résolue' : 'Alerte',
          style: TextStyle(
              fontSize: 9,
              color: resolved
                  ? AppColors.primaryWarning
                  : AppColors.primaryError,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ===========================================================================
// DÉTAIL VISITE
// ===========================================================================
class _VisitDetailCard extends StatelessWidget {
  final VisitModel visit;

  const _VisitDetailCard({required this.visit});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMMM yyyy', 'fr_FR');
    final survey = visit.survey;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête visite ────────────────────────────────────────────
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueLighter,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_hospital_outlined,
                          size: 18, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.visitType.isEmpty
                                ? 'Visite sans type'
                                : visit.visitType,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fmt.format(visit.date),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (visit.hasAlert)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: visit.alertResolved
                              ? AppColors.primaryWarning.withValues(alpha: 0.08)
                              : AppColors.primaryError.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: visit.alertResolved
                                ? AppColors.primaryWarning.withValues(alpha: 0.4)
                                : AppColors.primaryError.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visit.alertResolved
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.warning_amber_rounded,
                              size: 14,
                              color: visit.alertResolved
                                  ? AppColors.primaryWarning
                                  : AppColors.primaryError,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              visit.alertResolved
                                  ? 'Alerte résolue'
                                  : 'Alerte active',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: visit.alertResolved
                                      ? AppColors.primaryWarning
                                      : AppColors.primaryError),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Consultation + Satisfaction sur la même ligne ──────────
          // En-tête visite (déjà affiché) + plan d'action si alerte
          if (visit.hasAlert) ...[
            const SizedBox(height: 10),
            _ActionPlanSection(visit: visit),
          ],
          const SizedBox(height: 10),
          if (survey != null)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Infos consultation
                  Expanded(
                    child: _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.local_hospital_outlined,
                            label: 'Consultation',
                          ),
                          const SizedBox(height: 10),
                          // Chips type + service
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (visit.visitType.isNotEmpty)
                                _InfoChip(
                                    icon: Icons.local_hospital_outlined,
                                    label: visit.visitType),
                              if (visit.service.isNotEmpty)
                                _InfoChip(
                                    icon: Icons.business_outlined,
                                    label: visit.service),
                              if (visit.exploration.isNotEmpty)
                                _InfoChip(
                                    icon: Icons.biotech_outlined,
                                    label: visit.exploration),
                              if (visit.afterCare.isNotEmpty)
                                _InfoChip(
                                    icon: Icons.home,
                                    label: visit.afterCare),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Satisfaction
                  Expanded(
                    child: _SatisfactionSection(survey: survey),
                  ),
                ],
              ),
            )
          else
            _SectionCard(
              child: Row(
                children: const [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.kTextSub),
                  SizedBox(width: 8),
                  Text(
                    'Aucune réponse au questionnaire pour cette visite.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          if (survey != null) ...[
            const SizedBox(height: 10),
            _VerbatimsSection(survey: survey),
          ],
        ],
      ),
    );
  }
}

// ─── Plan d'action ────────────────────────────────────────────────────────
class _ActionPlanSection extends StatelessWidget {
  final VisitModel visit;
  const _ActionPlanSection({required this.visit});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      borderColor: visit.alertResolved
          ? AppColors.primaryWarning.withValues(alpha: 0.3)
          : AppColors.primaryError.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.assignment_outlined,
            label: 'Plan d\'action',
            iconColor: visit.alertResolved
                ? AppColors.primaryWarning
                : AppColors.primaryError,
          ),
          const SizedBox(height: 12),
          _DetailRow(
              label: 'Libellé',
              value: visit.actionPlanLabel ?? '—'),
          if (visit.planBy != null)
            _DetailRow(label: 'Traité par', value: visit.planBy!),
          if (visit.resolvedAt != null)
            _DetailRow(
              label: 'Résolu le',
              value: DateFormat('dd MMMM yyyy', 'fr_FR')
                  .format(visit.resolvedAt!),
            ),
          if (visit.planIsValid != null)
            _DetailRow(
              label: 'Plan validé',
              value: visit.planIsValid! ? 'Oui' : 'Non',
            ),
          if (visit.actionPlanReport != null &&
              visit.actionPlanReport!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: Text(
                visit.actionPlanReport!,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Satisfaction ─────────────────────────────────────────────────────────
class _SatisfactionSection extends StatelessWidget {
  final dynamic survey; // SurveyResponse
  const _SatisfactionSection({required this.survey});

  @override
  Widget build(BuildContext context) {
    final rappel = survey.consentementRappel == true ? 'Oui' : 'Non';
    final attentes = survey.attentesSoins?.toString() ?? '—';

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionTitle(
              icon: Icons.star_outline_rounded,
              label: 'Satisfaction'),
          const SizedBox(height: 10),
          // Ligne 1 : score + label inline
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _ScoreGauge(
                score: survey.qualitePriseEnCharge,
                label: 'Q0',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Attentes soins — badge couleur compact
                    _InlineField(
                      label: 'Attentes soins',
                      child: _ScoreBadgeText(value: attentes),
                    ),
                    const SizedBox(height: 6),
                    // Rappel — simple badge Oui/Non
                    _InlineField(
                      label: 'Rappel',
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: rappel == 'Oui'
                              ? AppColors.primarySuccess.withValues(alpha: 0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          rappel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: rappel == 'Oui'
                                ? AppColors.primarySuccess
                                : AppColors.textMid,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final Widget child;
  const _InlineField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        child,
      ],
    );
  }
}

class _ScoreBadgeText extends StatelessWidget {
  final String value;
  const _ScoreBadgeText({required this.value});

  Color _color() {
    final v = value.toUpperCase();
    if (v.contains('OUI TOTALEMENT')) return AppColors.primarySuccess;
    if (v.contains('EN PARTIE')) return AppColors.primaryWarning;
    if (v.contains('NON')) return AppColors.primaryError;
    if (v.contains('EN ATTENTE')) return AppColors.primaryNeutral;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: c.withValues(alpha: 0.35), width: 0.8),
        ),
        child: Text(
          value,
          style: TextStyle(
              fontSize: 11, color: c, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _ScoreGauge extends StatelessWidget {
  final dynamic score;
  final String label;
  const _ScoreGauge({required this.score, required this.label});

  Color _color(double v) {
    if (v >= 4) return AppColors.primarySuccess;
    if (v >= 3) return AppColors.primaryWarning;
    return AppColors.primaryError;
  }

  @override
  Widget build(BuildContext context) {
    final raw = score?.toString() ?? '0';
    final n = double.tryParse(raw) ?? 0;
    final c = _color(n);

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: c.withValues(alpha: 0.1),
            border: Border.all(color: c, width: 2.5),
          ),
          child: Center(
            child: Text(
              raw.isEmpty ? '—' : raw,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: c),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─── Verbatims ────────────────────────────────────────────────────────────
class _VerbatimsSection extends StatelessWidget {
  final dynamic survey; // SurveyResponse
  const _VerbatimsSection({required this.survey});

  @override
  Widget build(BuildContext context) {
    final verbatims = [
      ('Parcours (Q2)', survey.raconteParcours),
      ('Moment marquant (Q3)', survey.momentMarquant),
      ('Suggestions (Q4)', survey.suggestionsAmelioration),
    ];

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Verbatims'),
          const SizedBox(height: 12),
          ...verbatims.map((entry) {
            final title = entry.$1;
            final v = entry.$2;
            if (v == null) return const SizedBox.shrink();
            final msg = v.message?.toString() ?? '';
            if (msg.isEmpty) return const SizedBox.shrink();
            return _VerbatimItem(
              title: title,
              message: msg,
              classe: v.classe?.toString() ?? '',
              polarite: v.polarite?.toString() ?? '',
            );
          }),
        ],
      ),
    );
  }
}

class _VerbatimItem extends StatelessWidget {
  final String title;
  final String message;
  final String classe;
  final String polarite;

  const _VerbatimItem({
    required this.title,
    required this.message,
    required this.classe,
    required this.polarite,
  });

  Color _polariteColor() {
    final p = polarite.toLowerCase();
    if (p.contains('positif')) return AppColors.primarySuccess;
    if (p.contains('négatif') || p.contains('negatif'))
      return AppColors.primaryError;
    return AppColors.primaryNeutral;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMid),
              ),
              const Spacer(),
              if (classe.isNotEmpty)
                _Tag(
                    label: classe,
                    color: AppColors.primaryBlue,
                    bg: AppColors.primaryBlueLighter),
              const SizedBox(width: 5),
              if (polarite.isNotEmpty)
                _Tag(
                    label: polarite,
                    color: _polariteColor(),
                    bg: _polariteColor().withValues(alpha: 0.08)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$message"',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontStyle: FontStyle.italic,
                height: 1.6),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// MINI GRAPHE ÉVOLUTION SCORE (header patient)
// ===========================================================================
class _MiniScoreChart extends StatelessWidget {
  final List<VisitModel> visits;
  const _MiniScoreChart({required this.visits});

  @override
  Widget build(BuildContext context) {
    // Trier chronologiquement et garder seulement les visites avec survey
    final points = [...visits]
      ..sort((a, b) => a.date.compareTo(b.date));
    final data = points
        .where((v) => v.survey?.qualitePriseEnCharge != null)
        .map((v) {
      final raw = v.survey!.qualitePriseEnCharge?.toString() ?? '0';
      return double.tryParse(raw) ?? 0.0;
    })
        .toList();

    if (data.length < 2) {
      return const SizedBox(
        width: 120,
        height: 36,
        child: Center(
          child: Text(
            'Évolution indisponible',
            style: TextStyle(fontSize: 9, color: AppColors.kTextSub),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Évolution qualité',
          style: TextStyle(fontSize: 9, color: AppColors.kTextSub),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 140,
          height: 36,
          child: CustomPaint(
            painter: SparklinePainter(data: data),
          ),
        ),
      ],
    );
  }
}


// ===========================================================================
// WIDGETS UTILITAIRES PARTAGÉS
// ===========================================================================

class _SectionCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;

  const _SectionCard({required this.child, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor ?? AppColors.divider),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;

  const _SectionTitle({
    required this.icon,
    required this.label,
    this.iconColor = AppColors.primaryBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textMid)),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.kTextSub),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _AlertBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryError.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: AppColors.primaryError.withValues(alpha: 0.35)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 12, color: AppColors.primaryError),
          SizedBox(width: 4),
          Text('Alerte active',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryError,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Tag({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count patient${count > 1 ? 's' : ''}',
        style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Barre de recherche ───────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final SearchMode mode;
  final void Function(String) onChanged;
  final void Function(SearchMode) onModeChanged;

  const _SearchBar({
    required this.controller,
    required this.mode,
    required this.onChanged,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Toggle mode
          GestureDetector(
            onTap: () => onModeChanged(
              mode == SearchMode.patient
                  ? SearchMode.keyword
                  : SearchMode.patient,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLighter,
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(9)),
                border:
                Border(right: BorderSide(color: AppColors.divider)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mode == SearchMode.patient
                        ? Icons.person_outline_rounded
                        : Icons.text_fields_rounded,
                    size: 13,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mode == SearchMode.patient ? 'Patient' : 'Verbatim',
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          // Champ texte
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: mode == SearchMode.patient
                    ? 'Nom, prénom, IPP…'
                    : 'Mot-clé dans les verbatims…',
                hintStyle: const TextStyle(
                    fontSize: 12, color: AppColors.kTextSub),
                border: InputBorder.none,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10),
                isDense: true,
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 14),
                  color: AppColors.kTextSub,
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  splashRadius: 14,
                )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filtre onglets alerte ────────────────────────────────────────────────
class _AlertTabFilter extends StatelessWidget {
  final String current;
  final void Function(String) onChanged;

  const _AlertTabFilter(
      {required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      ('all', 'Tous'),
      ('alert', 'Alertes'),
      ('ok', 'Sans alerte'),
    ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
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
              height: double.infinity,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryBlue
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                tab.$2,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Placeholders ─────────────────────────────────────────────────────────
class _EmptyDetailPlaceholder extends StatelessWidget {
  const _EmptyDetailPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlueLighter,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_search_rounded,
                  size: 36, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sélectionnez un patient',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Son parcours complet s\'affichera ici.',
              style:
              TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVisitPlaceholder extends StatelessWidget {
  const _EmptyVisitPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: Text(
          'Sélectionnez une visite dans la timeline.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── États loading / erreur ───────────────────────────────────────────────
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
        const Icon(Icons.error_outline_rounded,
            size: 36, color: AppColors.primaryError),
        const SizedBox(height: 10),
        const Text('Erreur de chargement',
            style:
            TextStyle(fontSize: 14, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(error,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    ),
  );
}