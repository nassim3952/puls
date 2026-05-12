// Petit modèle interne pour faciliter la lecture de la Treemap
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';

class Q3FlatNode {
  final String classe;
  final String sousClasse;
  final String message;

  Q3FlatNode({required this.classe, required this.sousClasse, required this.message});
}

final q3TreemapProvider = Provider<AsyncValue<List<Q3FlatNode>>>((ref) {
  final patientsAsync = ref.watch(filteredPatientsProvider);

  return patientsAsync.whenData((list) {
    return list.map((p) {
      final q3 = p.patientResponse.q3;
      return Q3FlatNode(
        classe: q3.classe.replaceAll('_', ' ').toUpperCase(),
        sousClasse: q3.sousClasse.replaceAll('_', ' ').toUpperCase(),
        message: q3.message,
      );
    }).toList();
  });
});