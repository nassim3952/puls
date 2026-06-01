import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';

import '../provider/alert_provider.dart';
import '../provider/patient_provider.dart';

class ResultNumber extends ConsumerWidget {
  const ResultNumber({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(filteredPatientsProvider);
    final overrides = ref.watch(alertsNotifierProvider); // ← réactif aux actions

    final count = patientsAsync.whenOrNull(data: (l) => l.length) ?? 0;
    final alertCount = patientsAsync.whenOrNull(
      data: (l) => l.fold<int>(0, (sum, p) {
        return sum + p.visits.where((v) {
          final effective = overrides[v.id] ?? v;
          return effective.hasAlert;
        }).length; // 👈 compte les VISITES en alerte, pas les patients
      }),
    ) ?? 0;;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _CountBadge(count: count, label: 'réponses'),
        if (alertCount > 0) _AlertBadge(count: alertCount),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;

  const _CountBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.primaryBlue.withOpacity(0.4)),
      color: AppColors.primaryBlueLighter,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      '$count $label',
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlueDark),
    ),
  );
}

class _AlertBadge extends StatelessWidget {
  final int count;

  const _AlertBadge({required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.primaryError.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.primaryError.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.primaryError),
        const SizedBox(width: 4),
        Text(
          '$count alertes',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryError),
        ),
      ],
    ),
  );
}