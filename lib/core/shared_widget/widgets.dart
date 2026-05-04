import 'package:flutter/material.dart';

import '../color.dart';

class AppWidget {
  static Widget simpleButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color color = AppColors.TextPrimary,
    Color textColor = AppColors.textPrimary,
    Color iconColor = AppColors.textPrimary,
  }) {

    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor),
        label: Text(text, style: TextStyle(color: textColor)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }

    // Sinon, utiliser un OutlinedButton simple
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  static Widget actionButton({
    required VoidCallback onPressed,
    required String text,
  }) {
    return OutlinedButton(onPressed: () {}, child: Text(text));
  }
}
