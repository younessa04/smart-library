import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? photo;
  final String? studyLevel;
  final Timestamp registrationDate;
  final String role;
  final int points;
  final List<String> badges;

  UserModel({
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

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      photo: data['photo'],
      studyLevel: data['studyLevel'],
      registrationDate: data['registrationDate'] as Timestamp? ?? Timestamp.now(),
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
      'registrationDate': registrationDate,
      'role': role,
      'points': points,
      'badges': badges,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      photo: photo,
      studyLevel: studyLevel,
      registrationDate: registrationDate.toDate(),
      role: role,
      points: points,
      badges: badges,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      email: entity.email,
      phone: entity.phone,
      photo: entity.photo,
      studyLevel: entity.studyLevel,
      registrationDate: Timestamp.fromDate(entity.registrationDate),
      role: entity.role,
      points: entity.points,
      badges: entity.badges,
    );
  }
}
