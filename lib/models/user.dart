import 'package:cloud_firestore/cloud_firestore.dart';

class User {
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

  User({
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

  User copyWith({
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
    return User(
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

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photo: data['photo'],
      studyLevel: data['studyLevel'],
      registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: data['role'] ?? 'student',
      points: data['points'] ?? 0,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'photo': photo,
      'studyLevel': studyLevel,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'role': role,
      'points': points,
      'badges': badges,
    };
  }
}
