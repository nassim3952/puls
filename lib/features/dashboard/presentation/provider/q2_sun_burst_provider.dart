import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:xtal_dataview/xtal_dataview.dart' as xtal;

// On définit une palette de base pour l'application
final List<Color> _appPalette = [
  AppColors.primaryMenthe,
  Colors.blueAccent,
  Colors.orangeAccent,
  Colors.purpleAccent,
  Colors.teal,
  Colors.pinkAccent,
];

final q2SunburstProvider = Provider<AsyncValue<xtal.ChartTreeNode>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return xtal.ChartTreeNode(name: "TOTAL Q2", children: []);

    // 1. Construction de l'arbre de données
    Map<String, Map<String, List<String>>> treeMap = {};
    for (var p in list) {
      final q2 = p.patientResponse.q2;
      final className = q2.classe ?? "Inconnu";
      final subClassName = q2.sousClasse ?? "Inconnu";
      final message = q2.message ?? "";

      treeMap.putIfAbsent(className, () => {});
      treeMap[className]!.putIfAbsent(subClassName, () => []);
      treeMap[className]![subClassName]!.add(message);
    }

    int classCounter = 0;

    // 2. Mapping vers les Noeuds du graphique avec gestion des couleurs
    List<xtal.ChartTreeNode> classNodes = treeMap.entries.map((classEntry) {
      // On sélectionne une couleur de base pour la classe
      final Color baseColor = _appPalette[classCounter % _appPalette.length];
      classCounter++;

      List<xtal.ChartTreeNode> subClassNodes = classEntry.value.entries.map((subEntry) {
        // Sous-classe : même teinte, mais un peu plus claire
        final Color subColor = baseColor.withOpacity(0.7);

        List<xtal.ChartTreeNode> messageNodes = subEntry.value.map((msg) {
          // Messages (feuilles) : très clairs
          return xtal.ChartTreeNode(
            name: msg,
            value: 1.0,
            color: baseColor.withOpacity(0.4),
          );
        }).toList();

        return xtal.ChartTreeNode(
          name: subEntry.key.replaceAll('_', ' ').toUpperCase(),
          children: messageNodes,
          color: subColor,
        );
      }).toList();

      return xtal.ChartTreeNode(
        name: classEntry.key.replaceAll('_', ' ').toUpperCase(),
        children: subClassNodes,
        color: baseColor,
      );
    }).toList();

    return xtal.ChartTreeNode(
      name: "TOTAL Q2",
      children: classNodes,
      color: Colors.white,
    );
  });
});