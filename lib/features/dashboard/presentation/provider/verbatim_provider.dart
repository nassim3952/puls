// lib/features/dashboard/presentation/widgets/verbatim_provider.dart
//
// Provider .family<AsyncValue<List<VerbatimFlatNode>>, String>
// questionKey = 'q2' | 'q3' | 'q4'
//
// Utilise filteredPatientsProvider (déjà AsyncValue) correctement via .whenData

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:puls/core/provider/patient_provider.dart';


// ─── Normalisation polarité ───────────────────────────────────────────────────
// Le JSON peut renvoyer 'Positive', 'positive', 'Négative', 'negative', 'Neutre'…
// On normalise vers 3 valeurs exactes utilisées pour les couleurs.

String _normPol(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'positive':
      return 'Positive';
    case 'negative':
    case 'négative':
    case 'negatif':
    case 'négatif':
      return 'Négative';
    default:
      return 'Neutre';
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
// IMPORTANT : filteredPatientsProvider est déjà un AsyncValue.
// On utilise .whenData pour rester dans l'AsyncValue sans double-wrap.

final verbatimProvider =
Provider.family<AsyncValue<List<VerbatimFlatNode>>, String>(
        (ref, questionKey) {
      return ref.watch(filteredPatientsProvider).whenData((patients) {
        final result = <VerbatimFlatNode>[];

        for (final p in patients) {
          final survey = p.latestVisit?.survey;
          if (survey == null) continue;

          final v = switch (questionKey) {
            'q2' => survey.raconteParcours,
            'q3' => survey.momentMarquant,
            'q4' => survey.suggestionsAmelioration,
            _ => null,
          };

          if (v == null ||
              v.message.trim().isEmpty ||
              v.classe.trim().isEmpty) continue;

          result.add(VerbatimFlatNode(
            classe:     v.classe.trim(),
            sousClasse: v.sousClasse.trim(), // ← NOUVEAU
            polarite:   _normPol(v.polarite),
            message:    v.message.trim(),
          ));
        }

        return result;
      });
    });

// lib/features/dashboard/presentation/widgets/verbatim_flat_node.dart

/// Nœud plat représentant un verbatim analysé.
/// Utilisé par [verbatimProvider] et [VerbatimBarChart].
class VerbatimFlatNode {
  final String classe;     // ex: "organisation" | "communication" …
  final String sousClasse; // ex: "accueil" | "empathie" | "douleur" …
  final String polarite;   // toujours: 'Positive' | 'Négative' | 'Neutre'
  final String message;

  const VerbatimFlatNode({
    required this.classe,
    required this.sousClasse,
    required this.polarite,
    required this.message,
  });
}