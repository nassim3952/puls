import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/color.dart';

class Avatar extends StatelessWidget {
  final String? avatarUrl;
  final String initial;
  final double radius;

  const Avatar({
    required this.avatarUrl,
    required this.initial,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryMenthe.withOpacity(0.15),
        child: ClipOval(
          child: Image.network(
            avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            // Chargement progressif
            loadingBuilder: (_, child, progress) {
              if (progress == null) return child;
              return _InitialAvatar(initial: initial, radius: radius);
            },
            // Fallback si l'URL est invalide
            errorBuilder: (_, __, ___) =>
                _InitialAvatar(initial: initial, radius: radius),
          ),
        ),
      );
    }
    return _InitialAvatar(initial: initial, radius: radius);
  }
}

class _InitialAvatar extends StatelessWidget {
  final String initial;
  final double radius;

  const _InitialAvatar({required this.initial, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryMenthe.withOpacity(0.15),
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.primaryMentheDarker,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
