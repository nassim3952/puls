class TeamMemberModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String fonction;
  final String? phone;
  final String? avatarUrl;
  final DateTime createdAt;

  const TeamMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.fonction,
    this.phone,
    this.avatarUrl,
    required this.createdAt,
  });

  factory TeamMemberModel.fromMap(Map<String, dynamic> map) {
    return TeamMemberModel(
      id:        map['id'] as String,
      name:      map['name'] as String,
      email:     map['email']?.toString() ?? '',
      role:      map['role'] as String,
      fonction:  map['fonction'] as String,
      phone:     map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isOwner => role == 'owner';
  bool get isAdmin  => role == 'admin';

  String get roleLabel => switch (role) {
    'owner' => 'Propriétaire',
    'admin' => 'Administrateur',
    _       => 'Utilisateur',
  };
}