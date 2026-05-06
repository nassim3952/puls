import 'package:flutter/material.dart';

import '../color.dart';

enum StatusType { success, warning, error }

class AppWidget {

  static Widget alertTile(
    StatusType type,
    String status,
    String time,
    String message,
    Color color,
    bool isSelected,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: type == StatusType.error
            ? AppColors.error.withAlpha(12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.error : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: getColor(type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              //status
              Text(
                status,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                "  • Il y a $time",
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

Color getColor(StatusType status) {
  switch (status) {
    // <- Correction ici
    case StatusType.success:
      return AppColors.primaryMenthe;
    case StatusType.warning:
      return AppColors.warning;
    case StatusType.error:
      return AppColors.error;
    default:
      return AppColors.textPrimary;
  }
}
