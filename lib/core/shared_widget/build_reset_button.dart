import 'package:flutter/material.dart';
import 'package:puls/core/color.dart';

import '../provider/filter_controller.dart';

Widget buildResetButton(DashboardFilterNotifier notifier) {
  return TextButton.icon(
    onPressed: () {
      notifier.reset(); // nettoyage via le Notifier
    },
    icon: const Icon(Icons.refresh_rounded, size: 16),
    label: const Text('Réinitialiser'),
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primaryMenthe,
      textStyle: const TextStyle(fontSize: 13),
    ),
  );
}
