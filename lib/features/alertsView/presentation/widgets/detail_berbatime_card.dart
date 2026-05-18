import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class VerbatimCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final String message;
  final String classe;

  const VerbatimCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.message,
    required this.classe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  classe.replaceAll('_', ' '),
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message,
              style: const TextStyle(
                  color: AppColors.textMid, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
