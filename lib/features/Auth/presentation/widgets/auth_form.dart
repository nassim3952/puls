import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class LoginField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;

  const LoginField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textSecondary , fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlueLighter, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
        ),
      ),
    );
  }
}
