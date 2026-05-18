import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class PlanStepCard extends StatelessWidget {
  final PlanStep step;
  final int index;
  const PlanStepCard({required this.step, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
            Center(child: Icon(step.icon, color: step.color, size: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$index',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 8),
                    Text(step.title,
                        style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: step.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(step.delay,
                          style: TextStyle(
                              color: step.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(step.desc,
                    style: const TextStyle(
                        color: AppColors.textMid,
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlanStep {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final String delay;

  const PlanStep({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.delay,
  });
}
