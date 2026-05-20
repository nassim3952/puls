class UserModel {
  final String id; // = auth.uid()
  final String hospitalId;
  final String name;
  final String role; // 'owner' | 'admin' | 'doctor' | 'secretary'
  final String fonction;
  final String? phone;
  final String? email;
  final String? avatarUrl; //  Nouvelle propriété nullable pour l'image

  const UserModel({
    required this.id,
    required this.hospitalId,
    required this.name,
    required this.role,
    required this.fonction,
    this.phone,
    this.email,
    this.avatarUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      hospitalId: map['hospital_id'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      fonction: map['fonction'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}