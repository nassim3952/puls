import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/alert_provider.dart';
import 'package:puls/core/shared_widget/alert_tile.dart';

import '../../utils/time_ago.dart';
class AlertSection extends ConsumerWidget {
  const AlertSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);

    return alertsAsync.when(
      data: (alerts) {
        if (alerts.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text("Aucune alerte patient pour le moment"),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: alerts.map((patient) {
              // Extraction du message Q2 (Soins & Technique)
              final alertMessage = patient.patientResponse.q2.message;
              final patientName = "${patient.firstName} ${patient.lastName}";

              // Calcul du temps écoulé (optionnel, sinon on met l'heure)
              final timeDisplayText = timeAgo(patient.date);

              return AppWidget.alertTile(
                StatusType.error,
                patientName,
                timeDisplayText, // Affiche désormais "il y a 2 jours", "il y a 3 heures", etc.
                alertMessage,
                AppColors.primaryMentheError,
                false,
              );
            }).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Text("Erreur alertes : $e"),
    );
  }
}