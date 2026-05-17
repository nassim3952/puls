import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:xtal_dataview/xtal_dataview.dart' as xtal;

// On définit une palette de base pour l'application


final List<Color> _mintPalette = [AppColors.primaryMenthe, AppColors.primaryMentheDark, AppColors.primaryMentheDarker];

final q2SunburstProvider = Provider<AsyncValue<xtal.ChartTreeNode>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return xtal.ChartTreeNode(name: "TOTAL Q2", children: []);

    // 2. On change la Map : on stocke des List<PatientModel> au lieu de List<String>
    Map<String, Map<String, List<PatientModel>>> treeMap = {};

    for (var p in list) {
      final q2 = p.patientResponse.q2;
      final className = q2.classe;
      final subClassName = q2.sousClasse;

      treeMap.putIfAbsent(className, () => {});
      treeMap[className]!.putIfAbsent(subClassName, () => []);
      // On sauvegarde l'objet Patient complet ici
      treeMap[className]![subClassName]!.add(p);
    }

    int classCounter = 0;

    // 3. Mapping vers les Noeuds du graphique
    List<xtal.ChartTreeNode> classNodes = treeMap.entries.map((classEntry) {
      // Rotation sur tes 3 couleurs Mint selon l'index de la classe
      final Color baseColor = _mintPalette[classCounter % _mintPalette.length];
      classCounter++;

      List<xtal.ChartTreeNode> subClassNodes = classEntry.value.entries.map((subEntry) {
        // Sous-classe : même teinte, mais légèrement plus transparente pour différencier
        final Color subColor = baseColor.withOpacity(0.8);

        List<xtal.ChartTreeNode> messageNodes = subEntry.value.map((patient) {
          // 4. Extraction des données directement depuis le patient
          final msg = patient.patientResponse.q2.message;
          final isAlert = patient.hasAlert;

          return xtal.ChartTreeNode(
            name: msg,
            value: 1.0,
            // Si alerte -> Rouge, sinon -> Mint très clair
            color: isAlert ? AppColors.primaryMentheWarning : baseColor.withOpacity(0.4),
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