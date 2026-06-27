class CommentEntity {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String bookId;
  final String text;
  final int rating;
  final DateTime date;
  final int likes;
  final List<CommentReply> replies;

  CommentEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.bookId,
    required this.text,
    required this.rating,
    required this.date,
    this.likes = 0,
    this.replies = const [],
  });

  CommentEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhoto,
    String? bookId,
    String? text,
    int? rating,
    DateTime? date,
    int? likes,
    List<CommentReply>? replies,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhoto: userPhoto ?? this.userPhoto,
      bookId: bookId ?? this.bookId,
      text: text ?? this.text,
      rating: rating ?? this.rating,
      date: date ?? this.date,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
    );
  }
}

class CommentReply {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String text;
  final DateTime date;

  CommentReply({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.text,
    required this.date,
  });
}
