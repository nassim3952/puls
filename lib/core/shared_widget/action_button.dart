import 'package:flutter/material.dart';
import '../color.dart';

class AppButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final Color primaryColor;
  final Color darkColor;
  final IconData? icon;
  final bool outlined; // <-- Ajout du paramètre

  const AppButton({
    required this.onTap,
    required this.text,
    this.primaryColor = AppColors.primaryBlue,
    this.darkColor = AppColors.primaryBlueDark,
    this.icon,
    this.outlined = false, // Par défaut, le bouton est "plein"
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // Couleurs dynamiques selon le mode
    final textColor = widget.outlined ? widget.primaryColor : AppColors.surface;
    final borderColor = widget.primaryColor;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            // Mode Outlined : pas de gradient, fond transparent
            // Mode Plein : gradient, pas de bordure
            gradient: widget.outlined ? null : LinearGradient(
              colors: [widget.primaryColor, widget.darkColor],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            color: widget.outlined ? Colors.transparent : null,
            borderRadius: BorderRadius.circular(12),
            border: widget.outlined ? Border.all(color: borderColor, width: 1.5) : null,
            boxShadow: widget.outlined ? [] : [
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.40),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: TextStyle(
                    color: textColor, // Couleur adaptative
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}