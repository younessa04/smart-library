class UserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? photo;
  final String? studyLevel;
  final DateTime registrationDate;
  final String role;
  final int points;
  final List<String> badges;

  UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.photo,
    this.studyLevel,
    required this.registrationDate,
    required this.role,
    this.points = 0,
    this.badges = const [],
  });

  String get fullName => '$firstName $lastName';
  bool get isManager => role == 'manager';
  bool get isStudent => role == 'student';

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photo,
    String? studyLevel,
    DateTime? registrationDate,
    String? role,
    int? points,
    List<String>? badges,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      studyLevel: studyLevel ?? this.studyLevel,
      registrationDate: registrationDate ?? this.registrationDate,
      role: role ?? this.role,
      points: points ?? this.points,
      badges: badges ?? this.badges,
    );
  }
}
