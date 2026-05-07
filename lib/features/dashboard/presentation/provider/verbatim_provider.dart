import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../model/domain/verbatim_node.dart';
part 'verbatim_provider.g.dart';

@riverpod
List<VerbatimNode> verbatimData(Ref ref) {
  // Ici, vous pourriez mapper les données issues de votre Q3/Q4/Q5 [cite: 25, 31, 36]
  return [
    VerbatimNode(
      label: 'Relationnel',
      children: [
        VerbatimNode(
          label: 'Communication',
          children: [
            VerbatimNode(label: 'Empathie', value: 15),
            VerbatimNode(label: 'Écoute', value: 10),
          ],
        ),
        VerbatimNode(label: 'Accueil', value: 20),
      ],
    ),
    VerbatimNode(
      label: 'Prise en charge',
      children: [
        VerbatimNode(label: 'Soin', value: 30),
        VerbatimNode(label: 'Douleur', value: 12),
      ],
    ),
  ];
}