import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:xtal_dataview/xtal_dataview.dart'; // On utilise directement le type du package

final q3SunburstProvider = Provider<AsyncValue<ChartTreeNode>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    if (list.isEmpty) return ChartTreeNode(name: "TOTAL Q3", children: []);

    Map<String, Map<String, List<String>>> treeMap = {};

    for (var p in list) {
      // ON CHANGE ICI : On prend q3
      final q3 = p.patientResponse.q3;

      final className = q3.classe ?? "Sans Catégorie";
      final subClassName = q3.sousClasse ?? "Général";
      final message = q3.message ?? "";

      treeMap.putIfAbsent(className, () => {});
      treeMap[className]!.putIfAbsent(subClassName, () => []);
      treeMap[className]![subClassName]!.add(message);
    }

    // Conversion en nodes pour xtal_dataview
    List<ChartTreeNode> classNodes = treeMap.entries.map((classEntry) {
      List<ChartTreeNode> subClassNodes = classEntry.value.entries.map((subEntry) {
        return ChartTreeNode(
          name: subEntry.key.replaceAll('_', ' ').toUpperCase(),
          children: subEntry.value.map((msg) => ChartTreeNode(name: msg, value: 1.0)).toList(),
        );
      }).toList();

      return ChartTreeNode(
        name: classEntry.key.replaceAll('_', ' ').toUpperCase(),
        children: subClassNodes,
      );
    }).toList();

    return ChartTreeNode(name: "ANALYSE Q3", children: classNodes);
  });
});