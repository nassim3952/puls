import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class PainScoreBar extends StatelessWidget {
  final double score;
  const PainScoreBar({required this.score});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(10, (i) {
            final filled = i < score;
            Color c;
            if (i < 4)
              c = AppColors.primaryBlue;
            else if (i < 7)
              c = AppColors.primaryWarning;
            else
              c = AppColors.primaryError;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 3),
                height: 10,
                decoration: BoxDecoration(
                  color: filled ? c : AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Faible',
                style:
                TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            Text('${score.toInt()}/10',
                style: const TextStyle(
                    color: AppColors.primaryError,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
            const Text('Critique',
                style:
                TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
