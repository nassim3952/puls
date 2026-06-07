// lib/features/dashboard/presentation/widgets/verbatim_bar_chart.dart
//
// VUE 1 — Histogramme CLASSES :
//   Barres horizontales empilées (Positive / Négative / Neutre), triées par total.
//   Clic → Vue 2.
//
// VUE 2 — Drill-down SOUS-CLASSES :
//   Barres horizontales empilées par sous-classe. Clic → Vue 3.
//
// VUE 3 — Drill-down POLARITÉS (HORIZONTAL) :
//   Barres horizontales segmentées par polarité.
//   Chaque segment = 1 verbatim. Clic → panel verbatim flottant.
//
// MODIFICATION : Ajout du champ `sousClasse` dans VerbatimFlatNode
//   → navigation 3 niveaux : Classe → Sous-classe → Polarités
//
// ─── IMPORTANT : mettre à jour VerbatimFlatNode dans verbatim_provider.dart ───
//   Ajouter : final String sousClasse;
//   Mapper depuis : answers['qX']['sous_classe'] ?? ''

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';

import '../provider/verbatim_provider.dart';

// ─── Constantes polarité ──────────────────────────────────────────────────────

const _kPols = ['Positive', 'Négative', 'Neutre'];

Color _polColor(String pol) {
  switch (pol) {
    case 'Positive':
      return AppColors.primaryBlue;
    case 'Négative':
      return AppColors.primaryError;
    default:
      return AppColors.primaryNeutral;
  }
}

Color _polBg(String pol) => _polColor(pol).withOpacity(0.9);
Color _polTrack(String pol) => _polColor(pol).withOpacity(0.06);

// ─── Mapping Classe → label affiché ──────────────────────────────────────────
//
// Les 4 grandes classes du PDF (valeurs renvoyées par l'IA / le script Python)
// → labels courts pour l'affichage dans les barres.

const _kClasseLabels = <String, String>{
  'organisation':  'Organisation & Prestations',
  'communication': 'Communication & Interaction',
  'prise_en_charge': 'Prise en charge médicale',
  'information':   'Information & Éducation',
};

String _classeLabel(String raw) =>
    _kClasseLabels[raw.toLowerCase()] ?? raw;

// ─── Mapping Sous-classe → label affiché ─────────────────────────────────────
//
// Toutes les sous-classes du PDF, regroupées par classe.
// Valeurs normalisées (snake_case) envoyées par l'IA / le script.

const _kSousClasseLabels = <String, String>{
  // Classe 1 – Organisation
  'accueil':                 'Accueil',
  'attente':                 'Attente',
  'flexibilite':             'Flexibilité',
  'coordination_equipe':     'Coordination équipe',
  'orientation':             'Orientation',
  'facturation':             'Facturation',
  'continuite_soins':        'Continuité des soins',
  'materiel':                'Matériel',
  'structure':               'Structure',
  'proprete':                'Propreté',
  'hygiene':                 'Hygiène',
  'prevention_infectieux':   'Prévention risque infectieux',

  // Classe 2 – Communication
  'empathie':                'Empathie',
  'ecoute_medecins':         'Écoute active des médecins',
  'relation_soignant':       'Relation soignant-patient',
  'reconfort_emotionnel':    'Réconfort émotionnel',
  'indifference':            'Indifférence',
  'implication_patient':     'Implication du patient',
  'confiance_equipe':        'Confiance dans l\'équipe',
  'traitement_equitable':    'Traitement équitable',
  'dignite_respect':         'Dignité et respect',

  // Classe 3 – Prise en charge
  'douleur':                 'Douleur',
  'soulagement':             'Soulagement & Efficacité',
  'souffrance_inefficacite': 'Souffrance & Inefficacité',
  'stress':                  'Stress',
  'anxiete':                 'Anxiété',
  'confort_emotionnel':      'Confort émotionnel',
  'personnalisation_soins':  'Personnalisation des soins',
  'soins':                   'Soins',
  'geste_soignant':          'Geste soignant',
  'securite_soins':          'Sécurité des soins',

  // Classe 4 – Information
  'explication':             'Explication',
  'informations_traitement': 'Informations traitement',
  'explication_deroulement': 'Explication déroulement',
  'education_sante':         'Éducation santé',
  'personnalisation_info':   'Personnalisation info',
  'accompagnement_proches':  'Accompagnement des proches',
  'continuite_information':  'Continuité information',
  'suivi':                   'Suivi',
};

String _sousClasseLabel(String raw) =>
    _kSousClasseLabels[raw.toLowerCase()] ?? raw;

// ─── Modèles internes ─────────────────────────────────────────────────────────

/// Niveau 2 : groupe de verbatims pour une sous-classe donnée.
class _SousClasseGroup {
  final String sousClasse;
  final List<VerbatimFlatNode> nodes;

  _SousClasseGroup({required this.sousClasse, required this.nodes});

  int get total => nodes.length;
  int countPol(String pol) => nodes.where((n) => n.polarite == pol).length;
  List<VerbatimFlatNode> byPol(String pol) =>
      nodes.where((n) => n.polarite == pol).toList();
}

/// Niveau 1 : groupe de verbatims pour une classe donnée.
class _ClasseGroup {
  final String classe;
  final List<VerbatimFlatNode> nodes;

  _ClasseGroup({required this.classe, required this.nodes});

  int get total => nodes.length;
  int countPol(String pol) => nodes.where((n) => n.polarite == pol).length;

  /// Sous-classes contenues dans cette classe, triées par total décroissant.
  List<_SousClasseGroup> get sousClasses {
    final map = <String, List<VerbatimFlatNode>>{};
    for (final n in nodes) {
      map.putIfAbsent(n.sousClasse, () => []).add(n);
    }
    return map.entries
        .map((e) => _SousClasseGroup(sousClasse: e.key, nodes: e.value))
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));
  }
}

List<_ClasseGroup> _buildClasseGroups(List<VerbatimFlatNode> nodes) {
  final map = <String, List<VerbatimFlatNode>>{};
  for (final n in nodes) {
    map.putIfAbsent(n.classe, () => []).add(n);
  }
  return map.entries
      .map((e) => _ClasseGroup(classe: e.key, nodes: e.value))
      .toList()
    ..sort((a, b) => b.total.compareTo(a.total));
}

// ─── Widget principal ─────────────────────────────────────────────────────────

class VerbatimBarChart extends ConsumerStatefulWidget {
  final String questionKey;
  const VerbatimBarChart({super.key, required this.questionKey});

  @override
  ConsumerState<VerbatimBarChart> createState() => _VerbatimBarChartState();
}

class _VerbatimBarChartState extends ConsumerState<VerbatimBarChart>
    with SingleTickerProviderStateMixin {

  // Navigation : null = Vue 1, _selectedClasse set = Vue 2,
  //              _selectedSousClasse set = Vue 3
  _ClasseGroup?    _selectedClasse;
  _SousClasseGroup? _selectedSousClasse;

  late final AnimationController _transCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim =
        CurvedAnimation(parent: _transCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.04, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _transCtrl, curve: Curves.easeOut));
    _transCtrl.forward();
  }

  @override
  void dispose() {
    _transCtrl.dispose();
    super.dispose();
  }

  void _drillIntoClasse(_ClasseGroup g) {
    setState(() {
      _selectedClasse    = g;
      _selectedSousClasse = null;
    });
    _transCtrl.forward(from: 0);
  }

  void _drillIntoSousClasse(_SousClasseGroup sg) {
    setState(() => _selectedSousClasse = sg);
    _transCtrl.forward(from: 0);
  }

  void _drillBack() {
    setState(() {
      if (_selectedSousClasse != null) {
        _selectedSousClasse = null; // Vue 3 → Vue 2
      } else {
        _selectedClasse = null;     // Vue 2 → Vue 1
      }
    });
    _transCtrl.forward(from: 0);
  }

  // ── Titre du header selon le niveau actuel ────────────────────────────────

  String get _questionTitle => switch (widget.questionKey) {
    'q2' => 'Vécu du Parcours',
    'q3' => 'Moments Critiques',
    'q4' => 'Suggestions',
    _    => widget.questionKey.toUpperCase(),
  };

  String get _headerTitle {
    if (_selectedSousClasse != null) {
      return _sousClasseLabel(_selectedSousClasse!.sousClasse).toUpperCase();
    }
    if (_selectedClasse != null) {
      return _classeLabel(_selectedClasse!.classe).toUpperCase();
    }
    return _questionTitle;
  }

  // ── Fil d'Ariane (breadcrumb) ─────────────────────────────────────────────

  bool get _showBack =>
      _selectedClasse != null || _selectedSousClasse != null;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(verbatimProvider(widget.questionKey));

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppColors.primaryBlue),
      ),
      error: (e, _) => Center(
        child: Text('Erreur : $e',
            style: const TextStyle(
                color: AppColors.primaryError, fontSize: 12)),
      ),
      data: (nodes) {
        if (nodes.isEmpty) {
          return const Center(
            child: Text('Aucune donnée',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          );
        }

        final groupes = _buildClasseGroups(nodes);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            _ChartHeader(
              title:      _headerTitle,
              showBack:   _showBack,
              totalNodes: nodes.length,
              breadcrumb: _buildBreadcrumb(),
              onBack:     _drillBack,
            ),
            const SizedBox(height: 10),
            _Legend(),
            const SizedBox(height: 12),

            // ── Corps animé ────────────────────────────────────────────────
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildBody(groupes),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Construit le fil d'Ariane selon le niveau actuel.
  String? _buildBreadcrumb() {
    if (_selectedSousClasse != null && _selectedClasse != null) {
      return '${_classeLabel(_selectedClasse!.classe)} › ${_sousClasseLabel(_selectedSousClasse!.sousClasse)}';
    }
    if (_selectedClasse != null) {
      return _classeLabel(_selectedClasse!.classe);
    }
    return null;
  }

  Widget _buildBody(List<_ClasseGroup> groupes) {
    // Vue 3 — Polarités + verbatims
    if (_selectedSousClasse != null) {
      return _DrillView(group: _selectedSousClasse!);
    }
    // Vue 2 — Sous-classes d'une classe
    if (_selectedClasse != null) {
      return _SousClasseView(
        sousClasses: _selectedClasse!.sousClasses,
        onTap:       _drillIntoSousClasse,
      );
    }
    // Vue 1 — Classes
    return _ClasseView(
      groupes: groupes,
      onTap:   _drillIntoClasse,
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ChartHeader extends StatelessWidget {
  final String  title;
  final bool    showBack;
  final int     totalNodes;
  final String? breadcrumb;
  final VoidCallback onBack;

  const _ChartHeader({
    required this.title,
    required this.showBack,
    required this.totalNodes,
    required this.onBack,
    this.breadcrumb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: showBack
                  ? GestureDetector(
                key: const ValueKey('back'),
                onTap: onBack,
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 12,
                    color: AppColors.primaryBlue,
                  ),
                ),
              )
                  : const SizedBox.shrink(key: ValueKey('no-back')),
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.4,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$totalNodes verbatims',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        // Breadcrumb
        if (breadcrumb != null) ...[
          const SizedBox(height: 3),
          Text(
            breadcrumb!,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

// ─── Légende ──────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: _kPols.map((pol) {
        return Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                    color: _polColor(pol), shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(pol,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VUE 1 — Barres horizontales empilées par CLASSE
// ═════════════════════════════════════════════════════════════════════════════

class _ClasseView extends StatelessWidget {
  final List<_ClasseGroup> groupes;
  final void Function(_ClasseGroup) onTap;

  const _ClasseView({required this.groupes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final maxVal = groupes.fold(0, (m, g) => g.total > m ? g.total : m);

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < groupes.length; i++) ...[
            _HorizontalStackedBar(
              label:     _classeLabel(groupes[i].classe),
              nodes:     groupes[i].nodes,
              maxVal:    maxVal,
              animDelay: Duration(milliseconds: i * 55),
              onTap:     () => onTap(groupes[i]),
            ),
            if (i < groupes.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VUE 2 — Barres horizontales empilées par SOUS-CLASSE
// ═════════════════════════════════════════════════════════════════════════════

class _SousClasseView extends StatelessWidget {
  final List<_SousClasseGroup> sousClasses;
  final void Function(_SousClasseGroup) onTap;

  const _SousClasseView({required this.sousClasses, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final maxVal =
    sousClasses.fold(0, (m, g) => g.total > m ? g.total : m);

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < sousClasses.length; i++) ...[
            _HorizontalStackedBar(
              label:     _sousClasseLabel(sousClasses[i].sousClasse),
              nodes:     sousClasses[i].nodes,
              maxVal:    maxVal,
              animDelay: Duration(milliseconds: i * 55),
              onTap:     () => onTap(sousClasses[i]),
            ),
            if (i < sousClasses.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Barre horizontale empilée générique (Vue 1 & Vue 2) ─────────────────────

class _HorizontalStackedBar extends StatefulWidget {
  final String label;
  final List<VerbatimFlatNode> nodes;
  final int maxVal;
  final Duration animDelay;
  final VoidCallback onTap;

  const _HorizontalStackedBar({
    required this.label,
    required this.nodes,
    required this.maxVal,
    required this.animDelay,
    required this.onTap,
  });

  @override
  State<_HorizontalStackedBar> createState() => _HorizontalStackedBarState();
}

class _HorizontalStackedBarState extends State<_HorizontalStackedBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;
  bool _hovered = false;

  static const _labelWidth = 130.0;
  static const _countWidth = 28.0;
  static const _spacing    = 8.0;

  int get _total => widget.nodes.length;
  int _countPol(String pol) =>
      widget.nodes.where((n) => n.polarite == pol).length;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.animDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = widget.maxVal > 0 ? _total / widget.maxVal : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primaryBlueLighter.withOpacity(0.45)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              // Étiquette
              SizedBox(
                width: _labelWidth,
                child: Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _spacing),

              // Barre empilée
              Flexible(
                child: SizedBox(
                  height: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth  = constraints.maxWidth;
                            final filledWidth =
                                totalWidth * ratio * _anim.value;

                            return Stack(
                              children: [
                                Container(
                                  width: totalWidth,
                                  color: AppColors.primaryBlueLighter
                                      .withValues(alpha: 0.5),
                                ),
                                SizedBox(
                                  width: filledWidth,
                                  child: Row(
                                    children: _kPols.map((pol) {
                                      final cnt = _countPol(pol);
                                      if (cnt == 0) {
                                        return const SizedBox.shrink();
                                      }
                                      return Expanded(
                                        flex: cnt,
                                        child: Tooltip(
                                          message:
                                          '$cnt $pol${cnt > 1 ? 's' : ''}',
                                          preferBelow: false,
                                          child: Container(
                                              color: _polColor(pol)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                // Icône drill-down
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  bottom: 0,
                                  child: Icon(
                                    Icons.chevron_right_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: _spacing),

              // Total
              SizedBox(
                width: _countWidth,
                child: Text(
                  '$_total',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// VUE 3 — Drill-down : barres HORIZONTALES par polarité (verbatims individuels)
// ═════════════════════════════════════════════════════════════════════════════

class _DrillView extends StatefulWidget {
  final _SousClasseGroup group;
  const _DrillView({required this.group});

  @override
  State<_DrillView> createState() => _DrillViewState();
}

class _DrillViewState extends State<_DrillView> {
  VerbatimFlatNode? _activeVerbatim;
  OverlayEntry?     _overlayEntry;
  final Map<String, LayerLink> _layerLinks = {};

  @override
  void initState() {
    super.initState();
    for (final pol in _kPols) {
      _layerLinks[pol] = LayerLink();
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOverlay(VerbatimFlatNode node, LayerLink link) {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (_) => _VerbatimOverlay(
        node: node,
        link: link,
        onClose: () {
          _removeOverlay();
          setState(() => _activeVerbatim = null);
        },
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _onTapVerbatim(VerbatimFlatNode node, String pol) {
    if (_activeVerbatim == node) {
      _removeOverlay();
      setState(() => _activeVerbatim = null);
    } else {
      setState(() => _activeVerbatim = node);
      _showOverlay(node, _layerLinks[pol]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activePols =
    _kPols.where((p) => widget.group.countPol(p) > 0).toList();
    final maxVal = activePols.fold(
        0,
            (m, p) =>
        widget.group.countPol(p) > m ? widget.group.countPol(p) : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < activePols.length; i++) ...[
          CompositedTransformTarget(
            link: _layerLinks[activePols[i]]!,
            child: _HorizontalPolarityBar(
              pol:           activePols[i],
              entries:       widget.group.byPol(activePols[i]),
              maxVal:        maxVal,
              animDelay:     Duration(milliseconds: i * 80),
              activeVerbatim: _activeVerbatim,
              onTapVerbatim: (node) =>
                  _onTapVerbatim(node, activePols[i]),
            ),
          ),
          if (i < activePols.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// ─── Barre horizontale d'une polarité, segments = verbatims individuels ───────

class _HorizontalPolarityBar extends StatefulWidget {
  final String pol;
  final List<VerbatimFlatNode> entries;
  final int maxVal;
  final Duration animDelay;
  final VerbatimFlatNode? activeVerbatim;
  final void Function(VerbatimFlatNode) onTapVerbatim;

  const _HorizontalPolarityBar({
    required this.pol,
    required this.entries,
    required this.maxVal,
    required this.animDelay,
    required this.activeVerbatim,
    required this.onTapVerbatim,
  });

  @override
  State<_HorizontalPolarityBar> createState() =>
      _HorizontalPolarityBarState();
}

class _HorizontalPolarityBarState extends State<_HorizontalPolarityBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _anim;

  static const _labelWidth = 72.0;
  static const _countWidth = 28.0;
  static const _spacing    = 8.0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(widget.animDelay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.entries.length;
    final ratio = widget.maxVal > 0 ? count / widget.maxVal : 0.0;
    final color = _polColor(widget.pol);
    final bg    = _polBg(widget.pol);

    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            widget.pol,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: _spacing),

        Expanded(
          child: SizedBox(
            height: 28,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWidth  = constraints.maxWidth;
                      final filledWidth =
                          totalWidth * ratio * _anim.value;

                      return Stack(
                        children: [
                          Container(
                            width: totalWidth,
                            color: _polTrack(widget.pol),
                          ),
                          SizedBox(
                            width: filledWidth,
                            child: Row(
                              children: List.generate(
                                  widget.entries.length, (i) {
                                final entry    = widget.entries[i];
                                final isActive =
                                    widget.activeVerbatim == entry;
                                return Expanded(
                                  child: _TappableSegment(
                                    color:         color,
                                    bgColor:       bg,
                                    isActive:      isActive,
                                    showSeparator:
                                    i < widget.entries.length - 1,
                                    index: i,
                                    total: widget.entries.length,
                                    onTap: () =>
                                        widget.onTapVerbatim(entry),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: _spacing),

        SizedBox(
          width: _countWidth,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Segment individuel cliquable (1 verbatim) ────────────────────────────────

class _TappableSegment extends StatefulWidget {
  final Color color;
  final Color bgColor;
  final bool  isActive;
  final bool  showSeparator;
  final int   index;
  final int   total;
  final VoidCallback onTap;

  const _TappableSegment({
    required this.color,
    required this.bgColor,
    required this.isActive,
    required this.showSeparator,
    required this.index,
    required this.total,
    required this.onTap,
  });

  @override
  State<_TappableSegment> createState() => _TappableSegmentState();
}

class _TappableSegmentState extends State<_TappableSegment> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isActive || _hovered;

    return MouseRegion(
      cursor:  SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message:    '${widget.index + 1} / ${widget.total}',
          preferBelow: true,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            decoration: BoxDecoration(
              color: active ? widget.color : widget.bgColor,
              border: widget.showSeparator
                  ? Border(
                  right: BorderSide(
                      color: active
                          ? Colors.white.withOpacity(0.5)
                          : widget.color.withOpacity(0.25),
                      width: 0.8))
                  : null,
              boxShadow: widget.isActive
                  ? [
                BoxShadow(
                  color:       widget.color.withOpacity(0.45),
                  blurRadius:  4,
                  spreadRadius: 0,
                )
              ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Overlay verbatim flottant ────────────────────────────────────────────────

class _VerbatimOverlay extends StatefulWidget {
  final VerbatimFlatNode node;
  final LayerLink        link;
  final VoidCallback     onClose;

  const _VerbatimOverlay({
    required this.node,
    required this.link,
    required this.onClose,
  });

  @override
  State<_VerbatimOverlay> createState() => _VerbatimOverlayState();
}

class _VerbatimOverlayState extends State<_VerbatimOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap:     widget.onClose,
            behavior:  HitTestBehavior.translucent,
            child:     const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link:              widget.link,
          showWhenUnlinked:  false,
          offset:            const Offset(0, -8),
          targetAnchor:      Alignment.topLeft,
          followerAnchor:    Alignment.bottomLeft,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _VerbatimPanel(
                    node:    widget.node,
                    onClose: widget.onClose,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Panel verbatim ───────────────────────────────────────────────────────────

class _VerbatimPanel extends StatelessWidget {
  final VerbatimFlatNode node;
  final VoidCallback     onClose;

  const _VerbatimPanel({required this.node, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final color = _polColor(node.polarite);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:        MainAxisSize.min,
        children: [
          // Header : polarité + sous-classe + classe + bouton fermer
          Row(
            children: [
              Container(
                width:  6,
                height: 6,
                decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                node.polarite,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
              const SizedBox(width: 8),
              // Sous-classe
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:        color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _sousClasseLabel(node.sousClasse),
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ),
              const SizedBox(width: 4),
              // Classe (plus discret)
              if (node.classe.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _classeLabel(node.classe),
                    style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close_rounded,
                    size: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Message verbatim
          Text(
            node.message,
            style: const TextStyle(
              fontSize: 12,
              color:    AppColors.textPrimary,
              height:   1.55,
            ),
          ),
        ],
      ),
    );
  }
}