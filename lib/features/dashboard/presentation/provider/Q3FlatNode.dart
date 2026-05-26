// Petit modèle interne pour faciliter la lecture de la Treemap
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';
import 'package:puls/features/dashboard/presentation/provider/q3_nav_provider.dart';

class Q3FlatNode {
  final String classe;
  final String polarite;
  final String message;

  Q3FlatNode({required this.classe, required this.polarite, required this.message});
}

final q3TreemapProvider = Provider<AsyncValue<List<Q3FlatNode>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);
  final nav = ref.watch(treemapNavProvider);

  return patientsAsync.whenData((list) {
    // 1. On crée d'abord la liste complète proprement
    final allNodes = list
        .where((p) => p.latestVisit?.survey != null)
        .map((p) {
      final q3 = p.latestVisit!.survey!.momentMarquant;
      return Q3FlatNode(
        classe: q3.classe.replaceAll('_', ' ').toUpperCase().trim(),
        polarite: q3.polarite.replaceAll('_', ' ').toUpperCase().trim(),
        message: q3.message.trim(),
      );
    }).toList();

    // 2. On filtre avec des logs pour debugger si ça vide tout
    final filtered = allNodes.where((node) {
      if (nav.selectedPolarite != null) {
        return node.classe == nav.selectedClasse &&
            node.polarite == nav.selectedPolarite;
      } else if (nav.selectedClasse != null) {
        return node.classe == nav.selectedClasse;
      }
      return true;
    }).toList();

    return filtered;
  });
});