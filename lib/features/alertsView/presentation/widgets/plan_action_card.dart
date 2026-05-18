import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/alert_provider.dart';

import 'alert_view.dart';

class PlanActionCard extends ConsumerWidget {
  final AlertView alert;

  const PlanActionCard({required this.alert, super.key});

  (Color, Color, Color) get _levelColors {
    switch (alert.level) {
      case AlertLevel.urgent:
        return (AppColors.urgentBg, AppColors.urgentText, AppColors.urgentBorder);
      case AlertLevel.warning:
        return (AppColors.warningBg, AppColors.warningText, AppColors.warningBorder);
      case AlertLevel.info:
        return (AppColors.infoBg, AppColors.infoText, AppColors.infoBorder);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (bgColor, textColor, borderColor) = _levelColors;
    final patient = alert.source;
    final isRejected = patient.planIsValid == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRejected ? AppColors.urgentBorder : AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── En-tête patient ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      alert.avatarInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.patientName,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${alert.patientId} · ${alert.condition}',
                        style: const TextStyle(
                            color: AppColors.textLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Badge rejeté si applicable
                if (isRejected)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.urgentBg,
                      borderRadius: BorderRadius.circular(20),
                      border:
                      Border.all(color: AppColors.urgentBorder, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 12, color: AppColors.urgentText),
                        SizedBox(width: 4),
                        Text('Non validé',
                            style: TextStyle(
                                color: AppColors.urgentText,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // ── Label du plan ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.assignment_outlined,
                      size: 14, color: AppColors.primaryDark),
                  const SizedBox(width: 6),
                  Text(
                    patient.actionPlanLabel ?? '',
                    style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // ── Rapport ─────────────────────────────────────────────────────
          if (patient.actionPlanReport != null &&
              patient.actionPlanReport!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1),
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
                      patient.actionPlanReport!,
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

          // ── Boutons Valider / Rejeter ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined,
                    size: 13, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(alert.time,
                    style: const TextStyle(
                        color: AppColors.textLight, fontSize: 12)),
                const Spacer(),
                // Rejeter
                _ActionBtn(
                  label: 'Rejeter',
                  icon: Icons.close_rounded,
                  color: AppColors.urgentText,
                  bg: AppColors.urgentBg,
                  onTap: () => ref
                      .read(alertsNotifierProvider.notifier)
                      .rejectPlan(patient),
                ),
                const SizedBox(width: 8),
                // Valider
                _ActionBtn(
                  label: 'Valider',
                  icon: Icons.check_rounded,
                  color: Colors.white,
                  bg: AppColors.primary,
                  onTap: () => ref
                      .read(alertsNotifierProvider.notifier)
                      .validatePlan(patient),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}