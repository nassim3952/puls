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

  factory SurveyResponse.fromAnswersMap(Map<String, dynamic> answers) {
    // q0 : score /5 (String "5" → int)
    final q0 = (int.tryParse(answers['q0']?.toString() ?? '') ?? 0);

    // q1 : attentes soins (String direct)
    final q1 = answers['q1']?.toString() ?? '';

    // q2/q3/q4 : verbatim { class, polarity, message }
    final q2 = _verbatimFromMap(answers['q2']);
    final q3 = _verbatimFromMap(answers['q3']);
    final q4 = _verbatimFromMap(answers['q4']);

    // q5 : consentement rappel ("Oui" / "Non")
    final q5 = answers['q5']?.toString().toLowerCase() == 'oui';

    return SurveyResponse(
      qualitePriseEnCharge: q0,
      attentesSoins: q1,
      raconteParcours: q2,
      momentMarquant: q3,
      suggestionsAmelioration: q4,
      consentementRappel: q5,
    );
  }

  static Verbatim _verbatimFromMap(dynamic raw) {
    if (raw == null) return Verbatim.empty;
    if (raw is Map<String, dynamic>) {
      return Verbatim(
        message:    raw['message']?.toString()     ?? '',
        classe:     raw['class']?.toString()        ?? '',
        sousClasse: raw['sous_classe']?.toString()  ?? '', // ← NOUVEAU
        polarite:   raw['polarity']?.toString()     ?? '',
      );
    }
    return Verbatim.empty;
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
  final String sousClasse; // ex: "accueil" | "empathie" | "douleur" …
  final String polarite;

  const Verbatim({
    required this.message,
    required this.classe,
    required this.sousClasse,
    required this.polarite,
  });

  // Format Supabase : { "class": "...", "polarity": "...", "message": "..." }
  factory Verbatim.fromAnswerItem(Map<String, dynamic> item) {
    final analysis = item['analysis'] as Map<String, dynamic>?;
    return Verbatim(
      message:    item['value']?.toString()         ?? '',
      classe:     analysis?['class']?.toString()     ?? '',
      sousClasse: analysis?['sous_classe']?.toString() ?? '', // ← NOUVEAU
      polarite:   analysis?['polarity']?.toString()  ?? '',
    );
  }

  static const empty = Verbatim(message: '', classe: '', sousClasse: '', polarite: '');
}