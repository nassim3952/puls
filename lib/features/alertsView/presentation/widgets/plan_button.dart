import 'package:flutter/material.dart';

class Plan_button extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final String? label;
  final Color? border; // <-- Rendu nullable

  const Plan_button({
    super.key, // Pense à ajouter la key, c'est mieux pour Flutter
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.label,
    this.border, // <-- Plus de 'required'
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: label != null ? 10 : 8, vertical: 7),
        decoration: BoxDecoration(
          // --- La logique est là ---
          border: border != null
              ? Border.all(color: border!, width: 1.2)
              : null, // Si c'est null, pas de bordure
          // --------------------------
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label!,
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}