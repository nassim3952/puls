import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

Widget buildEmpty() {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 64,
          color: AppColors.primary.withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        const Text(
          'Aucune alerte non traitée',
          style: TextStyle(
            color: AppColors.textLight,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
