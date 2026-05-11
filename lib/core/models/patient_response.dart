
class PatientResponse {
  final String q0;
  final String q1;
  final Verbatim q2;
  final Verbatim q3;
  final Verbatim q4;
  final bool q5;

  PatientResponse({
    required this.q0,
    required this.q1,
    required this.q2,
    required this.q3,
    required this.q4,
    required this.q5
  });

  factory PatientResponse.fromJson(Map<String, dynamic> json) {
    return PatientResponse(
      q0: json['q0'],
      q1: json['q1'],
      q2: Verbatim.fromJson(json['q2']),
      q3: Verbatim.fromJson(json['q3']),
      q4: Verbatim.fromJson(json['q4']),
      // Conversion manuelle car le JSON renvoie "Oui" (String) au lieu de true (bool)
      q5: json['q5'].toString().toLowerCase() == 'oui',
    );
  }
}

class Verbatim {
  final String message;
  final String classe;
  final String sousClasse;

  Verbatim({required this.message, required this.classe, required this.sousClasse});

  factory Verbatim.fromJson(Map<String, dynamic> json) {
    return Verbatim(
      message: json['message'],
      classe: json['class'], // Map 'class' du JSON vers 'classe'
      sousClasse: json['sub_class'], // Map 'sub_class' vers 'sousClasse'
    );
  }
}