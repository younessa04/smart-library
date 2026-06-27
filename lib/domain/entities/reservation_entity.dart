class ReservationEntity {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final DateTime date;
  final String status; // active, cancelled, completed
  final int position;

  ReservationEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookTitle,
    required this.bookCover,
    required this.date,
    required this.status,
    this.position = 1,
  });

  bool get isActive => status == 'active';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  ReservationEntity copyWith({
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
    return ReservationEntity(
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
}
