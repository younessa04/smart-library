import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/favorite_notification_entity.dart';
import '../../domain/entities/category_entity.dart';

// Loan Model
class LoanModel {
  LoanModel();

  factory LoanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoanModel().._entity = LoanEntity(
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

  late LoanEntity _entity;

  LoanEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(LoanEntity entity) {
    return {
      'userId': entity.userId,
      'userName': entity.userName,
      'bookId': entity.bookId,
      'bookTitle': entity.bookTitle,
      'bookCover': entity.bookCover,
      'borrowDate': Timestamp.fromDate(entity.borrowDate),
      'dueDate': Timestamp.fromDate(entity.dueDate),
      'returnDate': entity.returnDate != null ? Timestamp.fromDate(entity.returnDate!) : null,
      'status': entity.status,
      'renewCount': entity.renewCount,
      'qrCode': entity.qrCode,
    };
  }
}

// Reservation Model
class ReservationModel {
  ReservationModel();

  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReservationModel().._entity = ReservationEntity(
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

  late ReservationEntity _entity;

  ReservationEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(ReservationEntity entity) {
    return {
      'userId': entity.userId,
      'userName': entity.userName,
      'bookId': entity.bookId,
      'bookTitle': entity.bookTitle,
      'bookCover': entity.bookCover,
      'date': Timestamp.fromDate(entity.date),
      'status': entity.status,
      'position': entity.position,
    };
  }
}

// Comment Model
class CommentModel {
  CommentModel();

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final repliesData = data['replies'] as List<dynamic>? ?? [];
    return CommentModel().._entity = CommentEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhoto: data['userPhoto'],
      bookId: data['bookId'] ?? '',
      text: data['text'] ?? '',
      rating: data['rating'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      likes: data['likes'] ?? 0,
      replies: repliesData.map((r) {
        final replyData = r as Map<String, dynamic>;
        return CommentReply(
          id: replyData['id'] ?? '',
          userId: replyData['userId'] ?? '',
          userName: replyData['userName'] ?? '',
          userPhoto: replyData['userPhoto'],
          text: replyData['text'] ?? '',
          date: (replyData['date'] as Timestamp).toDate(),
        );
      }).toList(),
    );
  }

  late CommentEntity _entity;

  CommentEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(CommentEntity entity) {
    return {
      'userId': entity.userId,
      'userName': entity.userName,
      'userPhoto': entity.userPhoto,
      'bookId': entity.bookId,
      'text': entity.text,
      'rating': entity.rating,
      'date': Timestamp.fromDate(entity.date),
      'likes': entity.likes,
      'replies': entity.replies.map((r) => {
        'id': r.id,
        'userId': r.userId,
        'userName': r.userName,
        'userPhoto': r.userPhoto,
        'text': r.text,
        'date': Timestamp.fromDate(r.date),
      }).toList(),
    };
  }
}

// Favorite Model
class FavoriteModel {
  FavoriteModel();

  factory FavoriteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteModel().._entity = FavoriteEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookCover: data['bookCover'] ?? '',
      bookRating: (data['bookRating'] ?? 0).toDouble(),
      addedAt: (data['addedAt'] as Timestamp).toDate(),
    );
  }

  late FavoriteEntity _entity;

  FavoriteEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(FavoriteEntity entity) {
    return {
      'userId': entity.userId,
      'bookId': entity.bookId,
      'bookTitle': entity.bookTitle,
      'bookAuthor': entity.bookAuthor,
      'bookCover': entity.bookCover,
      'bookRating': entity.bookRating,
      'addedAt': Timestamp.fromDate(entity.addedAt),
    };
  }
}

// Notification Model
class NotificationModel {
  NotificationModel();

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel().._entity = NotificationEntity(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      read: data['read'] ?? false,
      date: (data['date'] as Timestamp).toDate(),
      referenceId: data['referenceId'],
    );
  }

  late NotificationEntity _entity;

  NotificationEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(NotificationEntity entity) {
    return {
      'userId': entity.userId,
      'title': entity.title,
      'body': entity.body,
      'type': entity.type,
      'read': entity.read,
      'date': Timestamp.fromDate(entity.date),
      'referenceId': entity.referenceId,
    };
  }
}

// Category Model
class CategoryModel {
  CategoryModel();

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel().._entity = CategoryEntity(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'] ?? 'book',
      bookCount: data['bookCount'] ?? 0,
    );
  }

  late CategoryEntity _entity;

  CategoryEntity toEntity() => _entity;

  static Map<String, dynamic> toFirestore(CategoryEntity entity) {
    return {
      'name': entity.name,
      'icon': entity.icon,
      'bookCount': entity.bookCount,
    };
  }
}
