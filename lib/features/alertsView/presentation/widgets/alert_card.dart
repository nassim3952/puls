import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/alert_patient_avatar.dart';

import 'plan_button.dart';
import 'alert_view.dart';

// ─── Couleurs locales (chips & badges) ───────────────────────────────────────


// ─────────────────────────────────────────────────────────────────────────────
//  POINT D'ENTRÉE PUBLIC
//
//  • AlertCard            → patient avec UNE seule alerte (carte complète)
//  • PatientAlertGroup    → patient avec PLUSIEURS alertes (header + tiles)
//
//  Règles de responsabilité :
//    Patient   : nom, IPP, avatar, consentement
//    Visite    : niveau, score, date, service, type, verbatims, boutons
// ─────────────────────────────────────────────────────────────────────────────

// ─── Carte complète — patient + 1 visite ─────────────────────────────────────
class AlertCard extends StatelessWidget {
  final AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;

  const AlertCard({
    super.key,
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(alert.level),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header patient ───────────────────────────────────────────
          _PatientHeader(alert: alert),
          _Divider(),
          // ── Corps visite ─────────────────────────────────────────────
          _VisitBody(
            alert: alert,
            onDelete: onDelete,
            onWhatsapp: onWhatsapp,
            onDetail: onDetail,
            onPlan: onPlan,
          ),
        ],
      ),
    );
  }
}

// ─── Groupe — header patient + N tiles de visites ────────────────────────────
class PatientAlertGroup extends StatefulWidget {
  final List<AlertView> alerts; // toutes pour le même patient
  final void Function(AlertView) onDelete;
  final void Function(AlertView) onWhatsapp;
  final void Function(AlertView) onDetail;
  final void Function(AlertView) onPlan;

  const PatientAlertGroup({
    super.key,
    required this.alerts,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  @override
  State<PatientAlertGroup> createState() => _PatientAlertGroupState();
}

class _PatientAlertGroupState extends State<PatientAlertGroup> {
  bool _expanded = true;

  // Niveau le plus sévère du groupe — définit la couleur de la bordure
  AlertLevel get _worstLevel => widget.alerts.fold(AlertLevel.info, (prev, a) {
    if (a.level == AlertLevel.urgent) return AlertLevel.urgent;
    if (a.level == AlertLevel.warning && prev != AlertLevel.urgent) {
      return AlertLevel.warning;
    }
    return prev;
  });

  @override
  Widget build(BuildContext context) {
    final first = widget.alerts.first;
    final count = widget.alerts.length;
    final (_, labelColor, _) = _levelColors(_worstLevel);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: _worstLevel == AlertLevel.urgent
            ? Border.all(color: AppColors.urgentBorder, width: 0.5)
            : null,
        boxShadow: [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header patient (tap pour expand/collapse) ────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  alertPatientAvatar(first.avatarInitials,44,false),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          first.patientName,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          first.patientId,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge nombre d'alertes
                  _CountBadge(count: count, color: labelColor),
                  const SizedBox(width: 8),
                  // Consentement du premier survey disponible
                  if (first.visit.survey != null) ...[
                    _ConsentBadge(
                        consented: first.visit.survey!.consentementRappel),
                    const SizedBox(width: 8),
                  ],
                  // Chevron
                  AnimatedRotation(
                    turns: _expanded ? 0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textMid,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Liste des visites ────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
            _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              children: widget.alerts.map((alert) {
                return Column(
                  children: [
                    _Divider(),
                    _VisitTile(
                      alert: alert,
                      onDelete: () => widget.onDelete(alert),
                      onWhatsapp: () => widget.onWhatsapp(alert),
                      onDetail: () => widget.onDetail(alert),
                      onPlan: () => widget.onPlan(alert),
                    ),
                  ],
                );
              }).toList(),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  COMPOSANTS INTERNES
// ─────────────────────────────────────────────────────────────────────────────

// ── Header patient (utilisé dans AlertCard seule) ────────────────────────────
class _PatientHeader extends StatelessWidget {
  final AlertView alert;

  const _PatientHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    final survey = alert.visit.survey;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          alertPatientAvatar(alert.avatarInitials,44,false),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.patientName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.patientId,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Consentement — lié au patient/survey
          if (survey != null) ...[
            _ConsentBadge(consented: survey.consentementRappel),
          ],
        ],
      ),
    );
  }
}

// ── Corps d'une visite — utilisé dans AlertCard (carte seule) ────────────────
class _VisitBody extends StatelessWidget {
  final AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;

  const _VisitBody({
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context) {
    return _VisitContent(
      alert: alert,
      onDelete: onDelete,
      onWhatsapp: onWhatsapp,
      onDetail: onDetail,
      onPlan: onPlan,
      topPadding: 14,
    );
  }
}

// ── Tile visite dans un groupe (indent légèrement) ───────────────────────────
class _VisitTile extends StatelessWidget {
  final AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;

  const _VisitTile({
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
  });

  @override
  Widget build(BuildContext context) {
    return _VisitContent(
      alert: alert,
      onDelete: onDelete,
      onWhatsapp: onWhatsapp,
      onDetail: onDetail,
      onPlan: onPlan,
      topPadding: 12,
    );
  }
}

// ── Contenu d'une visite (partagé entre _VisitBody et _VisitTile) ────────────
class _VisitContent extends StatefulWidget {
  final AlertView alert;
  final VoidCallback onDelete;
  final VoidCallback onWhatsapp;
  final VoidCallback onDetail;
  final VoidCallback onPlan;
  final double topPadding;

  const _VisitContent({
    required this.alert,
    required this.onDelete,
    required this.onWhatsapp,
    required this.onDetail,
    required this.onPlan,
    required this.topPadding,
  });

  @override
  State<_VisitContent> createState() => _VisitContentState();
}

class _VisitContentState extends State<_VisitContent> {
  bool _verbatimsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final visit = alert.visit;
    final survey = visit.survey;
    final (_, textColor, _) = _levelColors(alert.level);

    // Verbatims filtrés non-vides : parcours, moment, suggestion
    final verbatims = survey == null
        ? <({String label, String message, String polarite})>[]
        : [
      (
      label: 'Parcours',
      message: survey.raconteParcours.message,
      polarite: survey.raconteParcours.polarite,
      ),
      (
      label: 'Moment',
      message: survey.momentMarquant.message,
      polarite: survey.momentMarquant.polarite,
      ),
      (
      label: 'Suggestion',
      message: survey.suggestionsAmelioration.message,
      polarite: survey.suggestionsAmelioration.polarite,
      ),
    ].where((v) => v.message.isNotEmpty).toList();

    final hasMoreVerbatims = verbatims.length > 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, widget.topPadding, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ligne 1 : [badge niveau] à gauche · étoiles + attentes à droite
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (survey != null) ...[
                _ScoreStars(score: survey.qualitePriseEnCharge),
                const SizedBox(width: 8),
                _AttentesChip(value: survey.attentesSoins),
              ],
              const Spacer(),
              _LevelBadge(level: alert.level),

            ],
          ),

          const SizedBox(height: 10),

          // ── Verbatims ─────────────────────────────────────────────────
          if (verbatims.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlueLighter.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlueLighter, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Suggestion toujours visible en premier
                  _VerbatimRow(v: verbatims.last),
                  // Parcours + moment en expand
                  if (_verbatimsExpanded && hasMoreVerbatims) ...[
                    const SizedBox(height: 6),
                    ...verbatims.take(verbatims.length - 1).map(
                          (v) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _VerbatimRow(v: v),
                      ),
                    ),
                  ],
                  if (hasMoreVerbatims) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(
                              () => _verbatimsExpanded = !_verbatimsExpanded),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _verbatimsExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            size: 14,
                            color: textColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _verbatimsExpanded
                                ? 'Voir moins'
                                : 'Voir ${verbatims.length - 1} autre${verbatims.length - 1 > 1 ? 's' : ''}',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ] else if (survey == null) ...[
            // Fallback si aucun survey
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surface, width: 0.5),
              ),
              child: Text(
                alert.description,
                style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // ── Ligne bas : date · service · type à gauche · boutons à droite
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Meta chips
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _MetaChip(
                      icon: Icons.calendar_today_outlined,
                      label: alert.time,
                    ),
                    _MetaChip(
                      icon: Icons.local_hospital_outlined,
                      label: visit.service,
                    ),
                    _MetaChip(
                      icon: Icons.assignment_outlined,
                      label: visit.visitType,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Boutons d'action
              const SizedBox(width: 8),
              Plan_button(
                icon: Icons.chat_bubble_outline_rounded,
                color: AppColors.primaryBlue,
                bg: AppColors.primaryBlueLighter.withValues(alpha: 0.6),
                border: AppColors.primaryBlue,
                onTap: widget.onWhatsapp,
              ),
              const SizedBox(width: 8),
              Plan_button(
                icon: Icons.person_search_outlined,
                color: AppColors.primaryBlue,
                bg: AppColors.primaryBlueLighter.withValues(alpha: 0.6),
                border: AppColors.primaryBlue,
                onTap: widget.onDetail,
              ),
              const SizedBox(width: 8),
              Plan_button(
                icon: Icons.assignment_outlined,
                color: AppColors.white,
                bg: AppColors.primaryBlue,
                onTap: widget.onPlan,
                label: 'Plan', border: AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  WIDGETS ATOMIQUES
// ─────────────────────────────────────────────────────────────────────────────

// ── Avatar initiales ─────────────────────────────────────────────────────────
// class alertAvatar extends StatelessWidget {
//   final String initials;
//   final double size;
//
//   const alertAvatar({required this.initials, required this.size});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [AppColors.primary, AppColors.primaryDark],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(size * 0.27),
//       ),
//       child: Center(
//         child: Text(
//           initials,
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//             fontSize: size * 0.32,
//           ),
//         ),
//       ),
//     );
//   }
// }

// ── Badge niveau d'alerte ─────────────────────────────────────────────────────
class _LevelBadge extends StatelessWidget {
  final AlertLevel level;

  const _LevelBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final (_, textColor, borderColor) = _levelColors(level);
    final (label, icon) = switch (level) {
      AlertLevel.urgent => ('Urgent', Icons.warning_rounded),
      AlertLevel.warning => ('Modéré', Icons.info_outline_rounded),
      AlertLevel.info => ('Info', Icons.notifications_outlined),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,

            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip meta (date, service, type) ──────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

// ── Étoiles score /5 ─────────────────────────────────────────────────────────
class _ScoreStars extends StatelessWidget {
  final int score; // 0–5

  const _ScoreStars({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < score;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 16,
          color: filled ? AppColors.primaryBlue : AppColors.textSecondary,
        );
      }),
    );
  }
}

// ── Chip attentes soins ───────────────────────────────────────────────────────
class _AttentesChip extends StatelessWidget {
  final String value; // "Oui totalement" | "En partie" | "Non"

  const _AttentesChip({required this.value});

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    final (bgColor, textColor) = switch (value.toLowerCase()) {
      'oui totalement' => (AppColors.blueFaint,   AppColors.primaryBlueDark),
      'en partie'      => (AppColors.orangeFaint, AppColors.primaryWarning),
      _                => (AppColors.redFaint,    AppColors.primaryError),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Badge consentement rappel ─────────────────────────────────────────────────
class _ConsentBadge extends StatelessWidget {
  final bool consented;

  const _ConsentBadge({required this.consented});

  @override
  Widget build(BuildContext context) {
    final color  = consented ? AppColors.primaryBlueDark : AppColors.primaryError;
    final bgColor = consented ? AppColors.blueFaint : AppColors.redFaint;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            consented
                ? Icons.phone_enabled_outlined
                : Icons.phone_disabled_outlined,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            consented ? 'Rappel OK' : 'Pas de rappel',
            style: TextStyle(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Badge nombre d'alertes (dans le groupe) ───────────────────────────────────
class _CountBadge extends StatelessWidget {
  final int count;
  final Color color;

  const _CountBadge({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$count alertes',
            style: TextStyle(
              color: AppColors.primaryError,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Ligne verbatim ────────────────────────────────────────────────────────────
class _VerbatimRow extends StatelessWidget {
  final ({String label, String message, String polarite}) v;

  const _VerbatimRow({required this.v});

  bool get _isPositive => v.polarite.toLowerCase() == 'positive';

  @override
  Widget build(BuildContext context) {
    final color = _isPositive ? AppColors.primaryBlue : AppColors.primaryError;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: _isPositive ? AppColors.blueFaint : AppColors.redFaint,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
          ),
          child: Text(
            v.label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            v.message,
            style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Séparateur ────────────────────────────────────────────────────────────────
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.divider,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Retourne (bgColor, textColor, borderColor) selon le niveau
(Color, Color, Color) _levelColors(AlertLevel level) {
  return switch (level) {
    AlertLevel.urgent => (
    AppColors.surface,
    AppColors.primaryError,
    AppColors.urgentBorder,
    ),
    AlertLevel.warning => (
    AppColors.surface,
    AppColors.primaryWarning,
    AppColors.warningBorder,
    ),
    AlertLevel.info => (
    AppColors.surface,
    AppColors.infoText,
    AppColors.infoBorder,
    ),
  };
}

/// Décoration de la carte principale
BoxDecoration _cardDecoration(AlertLevel level) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: level == AlertLevel.urgent
        ? Border.all(color: AppColors.urgentBorder, width: 0.5)
        : null,
    boxShadow: [_cardShadow],
  );
}

const BoxShadow _cardShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 16,
  offset: Offset(0, 4),
);