// Petit modèle interne pour faciliter la lecture de la Treemap
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/features/dashboard/presentation/provider/q3_nav_provider.dart';

class Q3FlatNode {
  final String classe;
  final String sousClasse;
  final String message;

  Q3FlatNode({required this.classe, required this.sousClasse, required this.message});
}

final q3TreemapProvider = Provider<AsyncValue<List<Q3FlatNode>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final nav = ref.watch(treemapNavProvider);

  return patientsAsync.whenData((list) {
    // 1. On crée d'abord la liste complète proprement
    final allNodes = list.map((p) {
      final q3 = p.patientResponse.q3;
      return Q3FlatNode(
        classe: q3.classe.replaceAll('_', ' ').toUpperCase().trim(),
        sousClasse: q3.sousClasse.replaceAll('_', ' ').toUpperCase().trim(),
        message: q3.message.trim(),
      );
    }).toList();

    // 2. On filtre avec des logs pour debugger si ça vide tout
    final filtered = allNodes.where((node) {
      if (nav.selectedSousClasse != null) {
        return node.classe == nav.selectedClasse &&
            node.sousClasse == nav.selectedSousClasse;
      } else if (nav.selectedClasse != null) {
        return node.classe == nav.selectedClasse;
      }
      return true;
    }).toList();

    return filtered;
  });
});