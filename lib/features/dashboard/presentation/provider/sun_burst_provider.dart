import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/color.dart';
import 'package:puls/core/models/patient.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:xtal_dataview/xtal_dataview.dart' as xtal;

final List<Color> _mintPalette = [
  AppColors.primaryBlue,
  AppColors.primaryBlueDark,
  AppColors.primaryBlueDarker
];

/// Un Provider de type "Family" qui génère dynamiquement le nœud Sunburst
/// en fonction de la question (q2, q3, q4) passée en paramètre.
final sunburstFamilyProvider = Provider.family<AsyncValue<xtal.ChartTreeNode>, String>((ref, questionKey) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    final title = "TOTAL ${questionKey.toUpperCase()}";
    if (list.isEmpty) return xtal.ChartTreeNode(name: title, children: []);

    // 1. Groupement générique des données en arbre
    final Map<String, Map<String, List<PatientModel>>> treeMap = {};

    for (var p in list) {
      final qResponse = _getQuestionResponse(p, questionKey);
      if (qResponse == null) continue;

      final className = qResponse.classe;
      final polarite = qResponse.polarite;

      treeMap.putIfAbsent(className, () => {});
      treeMap[className]!.putIfAbsent(polarite, () => []);
      treeMap[className]![polarite]!.add(p);
    }

    int classCounter = 0;

    // 2. Construction de l'arbre xtal
    final List<xtal.ChartTreeNode> classNodes = treeMap.entries.map((classEntry) {
      final Color baseColor = _mintPalette[classCounter % _mintPalette.length];
      classCounter++;

      final List<xtal.ChartTreeNode> subClassNodes = classEntry.value.entries.map((subEntry) {
        final Color subColor = baseColor.withOpacity(0.8);

        final List<xtal.ChartTreeNode> messageNodes = subEntry.value.map((patient) {
          final qResponse = _getQuestionResponse(patient, questionKey);
          final msg = qResponse?.message ?? '';
          final isAlert = patient.latestVisit?.hasAlert ?? false;

          return xtal.ChartTreeNode(
            name: msg,
            value: 1.0,
            color: isAlert ? AppColors.primaryWarning : baseColor.withOpacity(0.4),
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
      name: title,
      children: classNodes,
      color: Colors.white,
    );
  });
});

/// Helper pour extraire de manière sécurisée la structure de la question
dynamic _getQuestionResponse(PatientModel patient, String key) {
  final survey = patient.latestVisit?.survey;
  if (survey == null) return null;
  switch (key.toLowerCase()) {
    case 'q2': return survey.raconteParcours;
    case 'q3': return survey.momentMarquant;
    case 'q4': return survey.suggestionsAmelioration;
    default: return null;
  }
}