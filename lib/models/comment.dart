import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'text': text,
      'date': Timestamp.fromDate(date),
    };
  }

  factory CommentReply.fromMap(Map<String, dynamic> data) {
    return CommentReply(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}

class Comment {
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

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.bookId,
    required this.text,
    this.rating = 0,
    required this.date,
    this.likes = 0,
    this.replies = const [],
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final repliesData = data['replies'] as List<dynamic>? ?? [];
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      bookId: data['bookId'] ?? '',
      text: data['text'] ?? '',
      rating: data['rating'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      replies: repliesData.map((r) => CommentReply.fromMap(r as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'bookId': bookId,
      'text': text,
      'rating': rating,
      'date': Timestamp.fromDate(date),
      'likes': likes,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }
}
