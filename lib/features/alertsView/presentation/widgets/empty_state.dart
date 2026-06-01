import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyTab({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlueLighter,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textMid,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}