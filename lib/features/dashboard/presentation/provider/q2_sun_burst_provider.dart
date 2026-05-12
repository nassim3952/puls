import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:xtal_dataview/xtal_dataview.dart' as xtal;

import '../model/chart_tree_model.dart';

final q2SunburstProvider = Provider<AsyncValue<xtal.ChartTreeNode>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return xtal.ChartTreeNode(name: "TOTAL Q2", children: []);

    // Structure : Map<Classe, Map<SubClasse, List<Message>>>
    Map<String, Map<String, List<String>>> treeMap = {};

    for (var p in list) {
      // On accède à q2 qui est de type Verbatim
      final q2 = p.patientResponse.q2;

      // Utilisation des getters EXACTS de ton modèle Verbatim
      final className = q2.classe ?? "Inconnu";      // C'est 'classe' dans ton modèle
      final subClassName = q2.sousClasse ?? "Inconnu"; // C'est 'sousClasse' dans ton modèle
      final message = q2.message ?? "";

      treeMap.putIfAbsent(className, () => {});
      treeMap[className]!.putIfAbsent(subClassName, () => []);
      treeMap[className]![subClassName]!.add(message);
    }
    // Conversion de la Map en liste de ChartTreeNode
    List<xtal.ChartTreeNode> classNodes = treeMap.entries.map((classEntry) {

      List<xtal.ChartTreeNode> subClassNodes = classEntry.value.entries.map((subEntry) {

        // Niveau 3 : Les messages (on peut les grouper ou les mettre individuellement)
        // Ici, on met chaque message comme une feuille de l'arbre
        List<xtal.ChartTreeNode> messageNodes = subEntry.value.map((msg) {
          return xtal.ChartTreeNode(name: msg, value: 1.0); // Chaque message vaut "1"
        }).toList();

        return xtal.ChartTreeNode(
          name: subEntry.key.replaceAll('_', ' ').toUpperCase(),
          children: messageNodes,
        );
      }).toList();

      return xtal.ChartTreeNode(
        name: classEntry.key.replaceAll('_', ' ').toUpperCase(),
        children: subClassNodes,
      );
    }).toList();

    return xtal.ChartTreeNode(name: "TOTAL Q2", children: classNodes);
  });
});