// lib/features/dashboard/presentation/widgets/verbatim_bar_chart.dart
//
// VUE 1 — Histogramme classes :
//   Barres horizontales empilées (Positive / Négative / Neutre), triées par total.
//   Clic → Vue 2.
//
// VUE 2 — Drill-down polarités (HORIZONTAL) :
//   Barres horizontales segmentées par polarité.
//   Chaque segment = 1 verbatim. Clic → panel verbatim en bas.
//
// Fix overflow : FractionallySizedBox + Flexible, plus de calcul manuel de largeur.

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

// ─── Modèles internes ─────────────────────────────────────────────────────────

class _ClassGroup {
  final String classe;
  final List<VerbatimFlatNode> nodes;

  _ClassGroup({required this.classe, required this.nodes});

  int get total => nodes.length;

  int countPol(String pol) => nodes.where((n) => n.polarite == pol).length;

  List<VerbatimFlatNode> byPol(String pol) =>
      nodes.where((n) => n.polarite == pol).toList();
}

List<_ClassGroup> _buildGroups(List<VerbatimFlatNode> nodes) {
  final map = <String, List<VerbatimFlatNode>>{};
  for (final n in nodes) {
    map.putIfAbsent(n.classe, () => []).add(n);
  }
  return map.entries
      .map((e) => _ClassGroup(classe: e.key, nodes: e.value))
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
  _ClassGroup? _selected;
  late final AnimationController _transCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

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

  void _drillInto(_ClassGroup g) {
    setState(() => _selected = g);
    _transCtrl.forward(from: 0);
  }

  void _drillBack() {
    setState(() => _selected = null);
    _transCtrl.forward(from: 0);
  }

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
                style:
                TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          );
        }

        final groups = _buildGroups(nodes);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header + légende ───────────────────────────────────────────
            _ChartHeader(
              questionKey: widget.questionKey,
              selected: _selected,
              totalNodes: nodes.length,
              onBack: _drillBack,
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
                  child: _selected == null
                      ? _ClassView(
                    groups: groups,
                    onTap: _drillInto,
                  )
                      : _DrillView(group: _selected!),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _ChartHeader extends StatelessWidget {
  final String questionKey;
  final _ClassGroup? selected;
  final int totalNodes;
  final VoidCallback onBack;

  const _ChartHeader({
    required this.questionKey,
    required this.selected,
    required this.totalNodes,
    required this.onBack,
  });

  String get _title => switch (questionKey) {
    'q2' => 'Vécu du Parcours',
    'q3' => 'Moments Critiques',
    'q4' => 'Suggestions',
    _ => questionKey.toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: selected != null
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
            selected == null ? _title : selected!.classe.toUpperCase(),
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
          style:
          const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
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
// VUE 1 — Barres horizontales empilées par classe
// ═════════════════════════════════════════════════════════════════════════════

class _ClassView extends StatelessWidget {
  final List<_ClassGroup> groups;
  final void Function(_ClassGroup) onTap;

  const _ClassView({required this.groups, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final maxVal = groups.fold(0, (m, g) => g.total > m ? g.total : m);

    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < groups.length; i++) ...[
            _HorizontalStackedBar(
              group: groups[i],
              maxVal: maxVal,
              animDelay: Duration(milliseconds: i * 55),
              onTap: () => onTap(groups[i]),
            ),
            if (i < groups.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _HorizontalStackedBar extends StatefulWidget {
  final _ClassGroup group;
  final int maxVal;
  final Duration animDelay;
  final VoidCallback onTap;

  const _HorizontalStackedBar({
    required this.group,
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
  late final Animation<double> _anim;
  bool _hovered = false;

  static const _labelWidth = 110.0;
  static const _countWidth = 28.0;
  static const _spacing = 8.0;

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
    final g = widget.group;
    final ratio = widget.maxVal > 0 ? g.total / widget.maxVal : 0.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
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
              // Étiquette classe
              SizedBox(
                width: _labelWidth,
                child: Text(
                  g.classe,
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

              // Barre empilée — FIX OVERFLOW : FractionallySizedBox + Flexible
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
                            final totalWidth = constraints.maxWidth;
                            final filledWidth = totalWidth * ratio * _anim.value;

                            return Stack(
                              children: [
                                // Fond vide
                                Container(
                                  width: totalWidth,
                                  color: AppColors.primaryBlueLighter.withValues(alpha: 0.5),
                                ),
                                // Partie remplie
                                SizedBox(
                                  width: filledWidth,
                                  child: Row(
                                    children: _kPols.map((pol) {
                                      final cnt = g.countPol(pol);
                                      if (cnt == 0) return const SizedBox.shrink();
                                      return Expanded(
                                        flex: cnt,
                                        child: Tooltip(
                                          message: '$cnt $pol${cnt > 1 ? 's' : ''}',
                                          preferBelow: false,
                                          child: Container(color: _polColor(pol)),
                                        ),
                                      );
                                    }).toList(),
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

              // Total + %
              SizedBox(
                width: _countWidth,
                child: Text(
                  '${g.total}',
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
// VUE 2 — Drill-down : barres HORIZONTALES par polarité
// ═════════════════════════════════════════════════════════════════════════════

class _DrillView extends StatefulWidget {
  final _ClassGroup group;
  const _DrillView({required this.group});

  @override
  State<_DrillView> createState() => _DrillViewState();
}

class _DrillViewState extends State<_DrillView> {
  VerbatimFlatNode? _activeVerbatim;
  OverlayEntry? _overlayEntry;
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
        0, (m, p) => widget.group.countPol(p) > m ? widget.group.countPol(p) : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < activePols.length; i++) ...[
          CompositedTransformTarget(
            link: _layerLinks[activePols[i]]!,
            child: _HorizontalPolarityBar(
              pol: activePols[i],
              entries: widget.group.byPol(activePols[i]),
              maxVal: maxVal,
              animDelay: Duration(milliseconds: i * 80),
              activeVerbatim: _activeVerbatim,
              onTapVerbatim: (node) => _onTapVerbatim(node, activePols[i]),
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
  State<_HorizontalPolarityBar> createState() => _HorizontalPolarityBarState();
}

class _HorizontalPolarityBarState extends State<_HorizontalPolarityBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  static const _labelWidth = 72.0;
  static const _countWidth = 28.0;
  static const _spacing = 8.0;

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
    final bg = _polBg(widget.pol);

    return Row(
      children: [
        // Label polarité
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

        // Barre segmentée — même fix FractionallySizedBox + Flexible
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
                      final totalWidth = constraints.maxWidth;
                      final filledWidth = totalWidth * ratio * _anim.value;

                      return Stack(
                        children: [
                          // Fond
                          Container(
                            width: totalWidth,
                            color: _polTrack(widget.pol),
                          ),
                          // Segments cliquables
                          SizedBox(
                            width: filledWidth,
                            child: Row(
                              children: List.generate(widget.entries.length, (i) {
                                final entry = widget.entries[i];
                                final isActive = widget.activeVerbatim == entry;
                                return Expanded(
                                  child: _TappableSegment(
                                    color: color,
                                    bgColor: bg,
                                    isActive: isActive,
                                    showSeparator: i < widget.entries.length - 1,
                                    index: i,
                                    total: widget.entries.length,
                                    onTap: () => widget.onTapVerbatim(entry),
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

        // Compteur
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
  final bool isActive;
  final bool showSeparator;
  final int index;
  final int total;
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
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Tooltip(
          message: '${widget.index + 1} / ${widget.total}',
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
                  color: widget.color.withOpacity(0.45),
                  blurRadius: 4,
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
  final LayerLink link;
  final VoidCallback onClose;

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
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
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
        // Tap en dehors = ferme
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.translucent,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: widget.link,
          showWhenUnlinked: false,
          offset: const Offset(0, -8), // 8px au-dessus de la barre
          targetAnchor: Alignment.topLeft,
          followerAnchor: Alignment.bottomLeft,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Material(
                color: Colors.transparent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _VerbatimPanel(
                    node: widget.node,
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



class _VerbatimPanel extends StatelessWidget {
  final VerbatimFlatNode node;
  final VoidCallback onClose;

  const _VerbatimPanel({required this.node, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final color = _polColor(node.polarite);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 6,
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
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  node.classe,
                  style: TextStyle(fontSize: 10, color: color),
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
          // Message
          Text(
            node.message,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}