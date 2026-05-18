

import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class GreenBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const GreenBtn({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: outlined
              ? []
              : [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: outlined ? AppColors.primary : Colors.white),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: outlined ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}