import 'package:flutter/material.dart';
import 'color.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
}