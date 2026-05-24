class UserModel {
  final String id;
  final String hospitalId;
  final String? hospitalName; // 💡 NOUVEAU
  final String name;
  final String role;
  final String fonction;
  final String? phone;
  final String? email;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.hospitalId,
    this.hospitalName, // 💡 NOUVEAU
    required this.name,
    required this.role,
    required this.fonction,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Supabase renvoie les jointures sous forme de Map ou List imbriquée
    final hospitalsData = map['hospitals'];
    final String? hName = hospitalsData != null ? hospitalsData['name'] as String? : null;

    return UserModel(
      id: map['id'] as String,
      hospitalId: map['hospital_id'] as String,
      hospitalName: hName, // 💡 NOUVEAU
      name: map['name'] as String,
      role: map['role'] as String,
      fonction: map['fonction'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}