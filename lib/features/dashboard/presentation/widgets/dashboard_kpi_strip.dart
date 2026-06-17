// dashboard_kpi_strip.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/custom_sparkline.dart';

import '../../../../core/provider/dashboard_kpi_provider.dart';
import '../../../../core/provider/filter_controller.dart';

class DashboardKpiStrip extends ConsumerWidget {
  const DashboardKpiStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpiAsync = ref.watch(dashboardKpiProvider);
    // En mode "Tout" (aucune période sélectionnée), il n'y a pas de période
    // précédente à comparer : on masque les badges de variation.
    final hasPeriode = ref.watch(filterProvider.select((f) => f.periode != null));
    return kpiAsync.when(
      loading: () => const _StripSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (kpi) => _StripContent(kpi: kpi, showVariation: hasPeriode),
    );
  }
}

// ─── Contenu ──────────────────────────────────────────────────────────────────

class _StripContent extends StatelessWidget {
  final DashboardKpi kpi;
  final bool showVariation;
  const _StripContent({required this.kpi, required this.showVariation});

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)} %';

  @override
  Widget build(BuildContext context) {
    final row1 = <Widget>[
      _KpiCard(
        label: 'Patients',
        value: '${kpi.totalPatients}',
        color: AppColors.primaryBlue,
        spark: kpi.patientsSpark,
        variation: showVariation ? kpi.variationPatients : null,
      ),
      _KpiCard(
        label: 'Visites',
        value: '${kpi.totalVisits}',
        color: AppColors.primaryBlue,
        spark: kpi.visitsSpark,
        variation: showVariation ? kpi.variationVisits : null,
      ),
      _KpiCard(
        label: 'Réponses',
        value: '${kpi.totalResponses}',
        color: AppColors.primaryBlue,
        spark: kpi.responsesSpark,
        variation: showVariation ? kpi.variationResponses : null,
      ),
    ];

    final row2 = <Widget>[
      _KpiCard(
        label: 'Alertes',
        value: '${kpi.totalAlerts}',
        color: AppColors.primaryError,
        spark: kpi.alertsSpark,
        variation: showVariation ? kpi.variationAlerts : null,
        invertVariation: true, // hausse d'alertes = mauvais signe
      ),
      _KpiCard(
        label: 'Alertes traitées',
        value: '${kpi.totalAlertsResolved}',
        color: AppColors.primaryBlue,
        spark: kpi.alertsResolvedSpark,
        variation: showVariation ? kpi.variationAlertsResolved : null,
      ),
      _KpiCard(
        label: 'Taux de réponse',
        value: _pct(kpi.responseRate),
        color: AppColors.primaryBlue,
        spark: kpi.responseRateSpark,
        variation: showVariation ? kpi.variationResponseRate : null,
      ),
    ];

    Widget buildRow(List<Widget> cards) => Row(
      children: cards
          .map(
            (w) => Expanded(
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
            child: w,
          ),
        ),
      )
          .toList(),
    );

    return Column(
      children: [
        buildRow(row1),
        const SizedBox(height: 10),
        buildRow(row2),
      ],
    );
  }
}

// ─── Card KPI ─────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final List<double> spark;

  /// Variation déjà calculée côté SQL (% vs période précédente).
  /// `null` si rien à afficher (mode "Tout" ou pas de donnée de comparaison).
  final double? variation;

  /// Si true, une hausse est considérée négative (ex: alertes)
  final bool invertVariation;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
    required this.spark,
    this.variation,
    this.invertVariation = false,
  });

  @override
  Widget build(BuildContext context) {
    // Couleur de la variation : vert si positive (sauf si invertVariation)
    Color? variationColor;
    String? variationLabel;
    IconData? variationIcon;

    if (variation != null) {
      final isPositive = variation! >= 0;
      final isGood = invertVariation ? !isPositive : isPositive;
      variationColor = isGood
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626);
      variationIcon = isPositive
          ? Icons.arrow_drop_up_rounded
          : Icons.arrow_drop_down_rounded;
      const _kCap = 999.0;
      final capped = variation!.abs() > _kCap;
      final display = capped ? _kCap : variation!.abs();
      final sign = variation! >= 0 ? '+' : '-';
      variationLabel = '$sign${display.toStringAsFixed(capped ? 0 : 1)}%${capped ? '+' : ''}';
    }

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Gauche : label + valeur + variation ─────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    if (variation != null) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            variationIcon,
                            size: 26,
                            color: variationColor,
                          ),
                          Text(
                            variationLabel!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: variationColor,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(width: 10),

            // ── Droite : sparkline (prend tout l'espace restant) ─────
            Expanded(
              child: spark.length >= 2
                  ? SizedBox(
                height: 44,
                child: AnimatedSparkline(
                  data: spark,
                  color: color,
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton();

  Widget _row() => Row(
    children: List.generate(
      3,
          (i) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _row(),
          const SizedBox(height: 10),
          _row(),
        ],
      ),
    );
  }
}