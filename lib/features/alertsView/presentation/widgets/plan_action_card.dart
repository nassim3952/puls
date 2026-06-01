import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/alert_provider.dart';

import '../../../../core/shared_widget/alert_patient_avatar.dart';
import 'plan_button.dart';
import 'alert_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  POINT D'ENTRÉE PUBLIC
//
//  • PlanActionCard          → patient avec UNE seule visite en attente
//  • PatientPlanActionGroup  → patient avec PLUSIEURS visites en attente
//
//  Règles de responsabilité :
//    Patient : nom, IPP, condition, avatar
//    Visite  : plan, rapport, boutons valider/rejeter
// ─────────────────────────────────────────────────────────────────────────────

// ─── Carte complète — patient + 1 visite ─────────────────────────────────────
class PlanActionCard extends ConsumerWidget {
  final AlertView alert;

  const PlanActionCard({required this.alert, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRejected = alert.visit.planIsValid == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(isRejected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanPatientHeader(alert: alert),
          _PlanDivider(),
          _PlanVisitBody(alert: alert, ref: ref),
        ],
      ),
    );
  }
}

// ─── Groupe — header patient + N tiles de visites ─────────────────────────────
class PatientPlanActionGroup extends ConsumerStatefulWidget {
  final List<AlertView> alerts;

  const PatientPlanActionGroup({super.key, required this.alerts});

  @override
  ConsumerState<PatientPlanActionGroup> createState() =>
      _PatientPlanActionGroupState();
}

class _PatientPlanActionGroupState
    extends ConsumerState<PatientPlanActionGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final first = widget.alerts.first;
    final count = widget.alerts.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header patient collapsible ───────────────────────────────
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
                  _PlanCountBadge(count: count),
                  const SizedBox(width: 8),
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

          // ── Tiles visites ────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
            _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Column(
              children: widget.alerts.map((alert) {
                return Column(
                  children: [
                    _PlanDivider(),
                    _PlanVisitBody(alert: alert, ref: ref),
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

// ── Header patient (carte seule) ──────────────────────────────────────────────
class _PlanPatientHeader extends StatelessWidget {
  final AlertView alert;

  const _PlanPatientHeader({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isRejected = alert.visit.planIsValid == false;

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
          if (isRejected) _RejectedBadge(),
        ],
      ),
    );
  }
}

// ── Corps d'une visite en attente ─────────────────────────────────────────────
class _PlanVisitBody extends StatelessWidget {
  final AlertView alert;
  final WidgetRef ref;

  const _PlanVisitBody({required this.alert, required this.ref});

  @override
  Widget build(BuildContext context) {
    final visit = alert.visit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label du plan ──────────────────────────────────────────
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
                const Icon(Icons.assignment_outlined,
                    size: 14, color: AppColors.primaryBlueDark),
                const SizedBox(width: 6),
                Text(
                  visit.actionPlanLabel ?? '',
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

          // ── Boutons Valider / Rejeter ───────────────────────────────
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.schedule_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(alert.time,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
              const Spacer(),
              Plan_button(
                label: 'Rejeter',
                icon: Icons.close_rounded,
                color: AppColors.primaryError,
                bg: AppColors.primaryBG.withValues(alpha: 0.6),
                border: AppColors.primaryError,
                onTap: () => ref
                    .read(alertsNotifierProvider.notifier)
                    .rejectPlan(visit),
              ),
              const SizedBox(width: 8),
              Plan_button(
                label: 'Valider',
                icon: Icons.check_rounded,
                color: Colors.white,
                bg: AppColors.primaryBlue,
                border: AppColors.primaryBlue,
                onTap: () => ref
                    .read(alertsNotifierProvider.notifier)
                    .validatePlan(visit),
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

class _RejectedBadge extends StatelessWidget {
  const _RejectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryWarning, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.close_rounded, size: 12, color: AppColors.primaryError),
          SizedBox(width: 4),
          Text('Non validé',
              style: TextStyle(
                  color: AppColors.primaryError,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PlanCountBadge extends StatelessWidget {
  final int count;

  const _PlanCountBadge({required this.count});

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
          const Icon(Icons.assignment_outlined,
              size: 12, color: AppColors.primaryBlueDark),
          const SizedBox(width: 4),
          Text(
            '$count plans',
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

class _PlanDivider extends StatelessWidget {
  const _PlanDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.primaryBG,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecoration(bool isRejected) {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: isRejected
        ? Border.all(color: AppColors.primaryWarning, width: 1.5)
        : null,
    boxShadow: const [
      BoxShadow(
        color: Color(0x0A000000),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  );
}