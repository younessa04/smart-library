import 'package:cloud_firestore/cloud_firestore.dart';

class Loan {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String status;
  final int renewCount;
  final String? qrCode;

  Loan({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookTitle,
    this.bookCover = '',
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    this.status = 'pending',
    this.renewCount = 0,
    this.qrCode,
  });

  bool get canRenew => renewCount < 2 && status == 'approved';
  bool get isOverdue => status == 'approved' && DateTime.now().isAfter(dueDate);

  Loan copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bookId,
    String? bookTitle,
    String? bookCover,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
    String? status,
    int? renewCount,
    String? qrCode,
  }) {
    return Loan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookCover: bookCover ?? this.bookCover,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      renewCount: renewCount ?? this.renewCount,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  factory Loan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Loan(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookCover: data['bookCover'] ?? '',
      borrowDate: (data['borrowDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      renewCount: data['renewCount'] ?? 0,
      qrCode: data['qrCode'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookCover': bookCover,
      'borrowDate': Timestamp.fromDate(borrowDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'returnDate': returnDate != null ? Timestamp.fromDate(returnDate!) : null,
      'status': status,
      'renewCount': renewCount,
      'qrCode': qrCode,
    };
  }
}
