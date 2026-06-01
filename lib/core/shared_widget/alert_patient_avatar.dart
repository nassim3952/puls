
import 'package:flutter/material.dart';

import '../color.dart';

Stack alertPatientAvatar(String initial,double size,bool validated,) {
  return Stack(
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue.withValues(alpha: 0.7),
              AppColors.primaryBlueDark.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
                color: AppColors.surface,
                fontWeight: FontWeight.w700,
                fontSize: 15),
          ),
        ),
      ),
      if (validated)
      Positioned(
        right: -1,
        top: -1,
        child: Container(
          width: 18,
          height: 18,
          child: const Icon(Icons.circle,
              size: 10, color: AppColors.primaryError),
        ),
      ),
    ],
  );
}
