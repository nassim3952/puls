import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/provider/spline_selection_provider.dart';

Widget _buildLegendChip(WidgetRef ref, String label, Color color) {
  // On regarde si cette spline est actuellement sélectionnée/visible
  final isVisible = ref.watch(splineSelectionProvider).contains(label);

  return FilterChip(
    label: Text(label, style: const TextStyle(fontSize: 10)),
    selected: isVisible,
    selectedColor: color.withValues(alpha: 0.2), // Fond léger quand actif
    checkmarkColor: color,
    shape: StadiumBorder(side: BorderSide(color: isVisible ? color : Colors.transparent)),
    onSelected: (_) {
      ref.read(splineSelectionProvider.notifier).toggleSpline(label);
    },
  );
}