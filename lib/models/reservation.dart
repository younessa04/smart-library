import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final DateTime date;
  final String status;
  final int position;

  Reservation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookTitle,
    this.bookCover = '',
    required this.date,
    this.status = 'active',
    this.position = 1,
  });

  Reservation copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bookId,
    String? bookTitle,
    String? bookCover,
    DateTime? date,
    String? status,
    int? position,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookCover: bookCover ?? this.bookCover,
      date: date ?? this.date,
      status: status ?? this.status,
      position: position ?? this.position,
    );
  }

  factory Reservation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reservation(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookCover: data['bookCover'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: data['status'] ?? 'active',
      position: data['position'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookCover': bookCover,
      'date': Timestamp.fromDate(date),
      'status': status,
      'position': position,
    };
  }
}
