import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14)),
    );
  }
}
