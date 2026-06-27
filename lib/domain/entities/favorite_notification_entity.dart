class FavoriteEntity {
  final String id;
  final String userId;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookCover;
  final double bookRating;
  final DateTime addedAt;

  FavoriteEntity({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookCover,
    required this.bookRating,
    required this.addedAt,
  });
}

class NotificationEntity {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type; // reservation_accepted, book_available, return_reminder, new_book
  final bool read;
  final DateTime date;
  final String? referenceId;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.read = false,
    required this.date,
    this.referenceId,
  });

  NotificationEntity copyWith({
    bool? read,
  }) {
    return NotificationEntity(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: type,
      read: read ?? this.read,
      date: date,
      referenceId: referenceId,
    );
  }
}
