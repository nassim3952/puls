
class SurveyResponse {
  final int qualitePriseEnCharge;       // note /5
  final String attentesSoins;           // "Oui totalement" | "En partie" | "Non"
  final Verbatim raconteParcours;
  final Verbatim momentMarquant;
  final Verbatim suggestionsAmelioration;
  final bool consentementRappel;

  const SurveyResponse({
    required this.qualitePriseEnCharge,
    required this.attentesSoins,
    required this.raconteParcours,
    required this.momentMarquant,
    required this.suggestionsAmelioration,
    required this.consentementRappel,
  });

  factory SurveyResponse.fromAnswersList(List<dynamic> answers) {
    final map = <String, Map<String, dynamic>>{};
    for (final item in answers) {
      if (item is Map<String, dynamic> && item['question_id'] != null) {
        map[item['question_id'] as String] = item;
      }
    }

    return SurveyResponse(
      qualitePriseEnCharge:
      (map['qualite_prise_en_charge']?['value'] as num?)?.toInt() ?? 0,
      attentesSoins:
      map['attentes_soins']?['value']?.toString() ?? '',
      raconteParcours:
      Verbatim.fromAnswerItem(map['racontre_parcours'] ?? {}),
      momentMarquant:
      Verbatim.fromAnswerItem(map['moment_marquant'] ?? {}),
      suggestionsAmelioration:
      Verbatim.fromAnswerItem(map['suggestions_amelioration'] ?? {}),
      consentementRappel:
      map['consentement_rappel']?['value']?.toString().toLowerCase() == 'oui',
    );
  }

  static const empty = SurveyResponse(
    qualitePriseEnCharge: 0,
    attentesSoins: '',
    raconteParcours: Verbatim.empty,
    momentMarquant: Verbatim.empty,
    suggestionsAmelioration: Verbatim.empty,
    consentementRappel: false,
  );
}

// ── Verbatim ──────────────────────────────────────────────────────────────────

class Verbatim {
  final String message;
  final String classe;
  final String sousClasse;

  const Verbatim({
    required this.message,
    required this.classe,
    required this.sousClasse,
  });

  // Format Supabase : { "value": "...", "analysis": { "class": "...", "sub_class": "..." } }
  factory Verbatim.fromAnswerItem(Map<String, dynamic> item) {
    final analysis = item['analysis'] as Map<String, dynamic>?;
    return Verbatim(
      message: item['value']?.toString() ?? '',
      classe: analysis?['class']?.toString() ?? '',
      sousClasse: analysis?['sub_class']?.toString() ?? '',
    );
  }

  static const empty = Verbatim(message: '', classe: '', sousClasse: '');
}