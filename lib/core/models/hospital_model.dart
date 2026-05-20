class HospitalModel {
  final String id;
  final String name;
  final String? whatsappPhone;
  final Map<String, dynamic>? localisation; // { wilaya, commune, cite }

  const HospitalModel({
    required this.id,
    required this.name,
    this.whatsappPhone,
    this.localisation,
  });

  factory HospitalModel.fromMap(Map<String, dynamic> map) {
    return HospitalModel(
      id: map['id'] as String,
      name: map['name'] as String,
      whatsappPhone: map['whatsapp_phone'] as String?,
      localisation: map['localisation'] as Map<String, dynamic>?,
    );
  }
}