import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';

Widget resultNumber(AsyncValue<List<PatientModel>> patientsAsync, dynamic filters) {
  final count = patientsAsync.whenOrNull(data: (l) => l.length) ?? 0;
  final alertCount = patientsAsync.whenOrNull(
      data: (l) => l.where((p) => p.latestVisit?.hasAlert ?? false).length) ?? 0;

  // On garde juste un Wrap ou un Row serré, sans Spacer parasite
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      _CountBadge(count: count, label: 'patients'),
      if (alertCount > 0) _AlertBadge(count: alertCount),
    ],
  );
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;

  const _CountBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: MintTheme.mint100,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      '$count $label',
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: MintTheme.mint700),
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
      color: MintTheme.alertRedBg,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: MintTheme.alertRed.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 12, color: MintTheme.alertRed),
        const SizedBox(width: 4),
        Text(
          '$count alertes',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: MintTheme.alertRed),
        ),
      ],
    ),
  );
}