import 'package:flutter/material.dart';

import '../../../../core/color.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Text('$label : ',
              style:
              const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
