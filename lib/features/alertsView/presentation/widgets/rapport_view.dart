import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/visit_model.dart';

Padding rapportView(VisitModel visit) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surface, width: 1),
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
  );
}
