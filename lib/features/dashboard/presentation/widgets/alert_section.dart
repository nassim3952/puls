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
    final alertsAsync = ref.watch(activeAlertsProvider(null));

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
              // Extraction du message Q2 (raconteParcours)
              final alertMessage = patient.latestVisit?.survey?.raconteParcours.message ?? '';
              final patientName = "${patient.firstName} ${patient.lastName}";

              // Calcul du temps écoulé
              final timeDisplayText = patient.latestVisit != null
                  ? timeAgo(patient.latestVisit!.date)
                  : '–';

              return AppWidget.alertTile(
                StatusType.error,
                patientName,
                timeDisplayText, // Affiche désormais "il y a 2 jours", "il y a 3 heures", etc.
                alertMessage,
                AppColors.primaryError,
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