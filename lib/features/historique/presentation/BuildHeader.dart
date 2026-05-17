import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';

import '../historique_screen.dart';

Widget buildHeader(AsyncValue<List<PatientModel>> patientsAsync,
    HistoriqueFilterState filters) {
  final count = patientsAsync.whenOrNull(data: (l) => l.length) ?? 0;
  final alertCount = patientsAsync.whenOrNull(
      data: (l) =>
      l
          .where((p) => p.hasAlert)
          .length) ?? 0;

  return Container(
    padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CountBadge(count: count, label: 'patients'),
            if (alertCount > 0) ...[
              const SizedBox(width: 8),
              _AlertBadge(count: alertCount),
            ],
            const Spacer(),

          ],
        ),

      ],
    ),
  );
}


class _CountBadge extends StatelessWidget {
  final int count;
  final String label;

  const _CountBadge({required this.count, required this.label});

  @override
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: MintTheme.mint100,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          '$count $label',
          style: const TextStyle(fontSize: 12,
              fontWeight: FontWeight.w500,
              color: MintTheme.mint700),
        ),
      );
}


class _AlertBadge extends StatelessWidget {
  final int count;

  const _AlertBadge({required this.count});

  @override
  Widget build(BuildContext context) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: MintTheme.alertRedBg,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: MintTheme.alertRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 12,
                color: MintTheme.alertRed),
            const SizedBox(width: 4),
            Text(
              '$count alertes',
              style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: MintTheme.alertRed),
            ),
          ],
        ),
      );
}
