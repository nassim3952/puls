import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/shared_widget/alert_patient_avatar.dart';
import 'package:puls/features/alertsView/presentation/widgets/rapport_view.dart';

import 'alert_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  POINT D'ENTRÉE PUBLIC
//
//  • ValidatedCard          → patient avec UNE seule visite validée
//  • PatientValidatedGroup  → patient avec PLUSIEURS visites validées
//
//  Règles de responsabilité :
//    Patient  : nom, IPP, condition, avatar
//    Visite   : plan, rapport, date de résolution
// ─────────────────────────────────────────────────────────────────────────────

// ─── Carte complète — patient + 1 visite validée ─────────────────────────────
class ValidatedCard extends StatelessWidget {
  final AlertView alert;

  const ValidatedCard({required this.alert, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ValidatedPatientHeader(alert: alert),
          _ValidatedDivider(),
          _ValidatedVisitBody(alert: alert),
        ],
      ),
    );
  }
}

// ─── Groupe — header patient + N tiles de visites validées ───────────────────
class PatientValidatedGroup extends StatefulWidget {
  final List<AlertView> alerts;

  const PatientValidatedGroup({super.key, required this.alerts});

  @override
  State<PatientValidatedGroup> createState() => _PatientValidatedGroupState();
}

class _PatientValidatedGroupState extends State<PatientValidatedGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final first = widget.alerts.first;
    final count = widget.alerts.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
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
                  alertPatientAvatar(first.avatarInitials, 44, false),
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
                          '${first.patientId} · ${first.condition}',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Badge nombre de visites
                  _ValidatedCountBadge(count: count),
                  const SizedBox(width: 8),
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
                    _ValidatedDivider(),
                    _ValidatedVisitBody(alert: alert),
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

// ── Header patient (carte seule) ─────────────────────────────────────────────
class _ValidatedPatientHeader extends StatelessWidget {
  final AlertView alert;

  const _ValidatedPatientHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        children: [
          alertPatientAvatar(alert.avatarInitials, 44, false),
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
                  '${alert.patientId} · ${alert.condition}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          _ValidatedBadge(),
        ],
      ),
    );
  }
}

// ── Corps d'une visite validée ────────────────────────────────────────────────
class _ValidatedVisitBody extends StatelessWidget {
  final AlertView alert;

  const _ValidatedVisitBody({required this.alert});

  @override
  Widget build(BuildContext context) {
    final visit = alert.visit;
    final resolvedDate = visit.resolvedAt != null
        ? DateFormat('dd/MM/yyyy à HH:mm').format(visit.resolvedAt!)
        : 'Date inconnue';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Plan appliqué ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlueLighter,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.assignment_turned_in_outlined,
                    size: 14, color: AppColors.primaryBlueDark),
                const SizedBox(width: 6),
                Text(
                  visit.actionPlanLabel ?? 'Plan appliqué',
                  style: const TextStyle(
                      color: AppColors.primaryBlueDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ── Rapport ────────────────────────────────────────────────
          if (visit.actionPlanReport != null &&
              visit.actionPlanReport!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBG.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBG, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rapport',
                    style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    visit.actionPlanReport!,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        height: 1.4),
                  ),
                ],
              ),
            ),
          ],

          // ── Date de résolution ─────────────────────────────────────
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  size: 13, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              Text(
                'Résolu le $resolvedDate',
                style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w500),
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

// ── Badge "Validé" ────────────────────────────────────────────────────────────
class _ValidatedBadge extends StatelessWidget {
  const _ValidatedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlueLighter,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.4), width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 12, color: AppColors.primaryBlueDark),
          SizedBox(width: 4),
          Text('Validé',
              style: TextStyle(
                  color: AppColors.primaryBlueDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ── Badge nombre de visites ───────────────────────────────────────────────────
class _ValidatedCountBadge extends StatelessWidget {
  final int count;

  const _ValidatedCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 12, color: AppColors.primaryBlueDark),
          const SizedBox(width: 4),
          Text(
            '$count visites',
            style: const TextStyle(
              color: AppColors.primaryBlueDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Séparateur ────────────────────────────────────────────────────────────────
class _ValidatedDivider extends StatelessWidget {
  const _ValidatedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.surface,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: AppColors.primaryBlue.withValues(alpha: 0.3),
      width: 1.5,
    ),
    boxShadow: const [
      BoxShadow(
        color: Color(0x08000000),
        blurRadius: 12,
        offset: Offset(0, 3),
      ),
    ],
  );
}