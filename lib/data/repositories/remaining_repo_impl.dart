import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/favorite_notification_entity.dart';
import '../../domain/repositories/repository_interfaces.dart';
import '../models/other_models.dart';

// Loan Repository Implementation
class LoanRepositoryImpl implements LoanRepository {
  final CollectionReference _loansRef =
      FirebaseFirestore.instance.collection(AppConstants.loansCollection);

  @override
  Future<List<LoanEntity>> getUserLoans(String userId) async {
    final snapshot = await _loansRef
        .where('userId', isEqualTo: userId)
        .orderBy('borrowDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LoanModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<LoanEntity>> getAllLoans() async {
    final snapshot = await _loansRef
        .orderBy('borrowDate', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => LoanModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<LoanEntity>> getPendingLoans() async {
    final snapshot = await _loansRef
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs
        .map((doc) => LoanModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> requestLoan(LoanEntity loan) async {
    await _loansRef.add(LoanModel.toFirestore(loan));
  }

  @override
  Future<void> approveLoan(String loanId) async {
    await _loansRef.doc(loanId).update({'status': 'approved'});
  }

  @override
  Future<void> rejectLoan(String loanId) async {
    await _loansRef.doc(loanId).update({'status': 'rejected'});
  }

  @override
  Future<void> returnLoan(String loanId) async {
    await _loansRef.doc(loanId).update({
      'status': 'returned',
      'returnDate': Timestamp.now(),
    });
  }

  @override
  Future<void> renewLoan(String loanId) async {
    final doc = await _loansRef.doc(loanId).get();
    final loan = LoanModel.fromFirestore(doc).toEntity();
    if (loan.canRenew) {
      await _loansRef.doc(loanId).update({
        'dueDate': Timestamp.fromDate(
          loan.dueDate.add(const Duration(days: AppConstants.defaultLoanDuration)),
        ),
        'renewCount': loan.renewCount + 1,
      });
    }
  }

  @override
  Stream<List<LoanEntity>> watchUserLoans(String userId) {
    return _loansRef
        .where('userId', isEqualTo: userId)
        .orderBy('borrowDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Stream<List<LoanEntity>> watchAllLoans() {
    return _loansRef
        .orderBy('borrowDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoanModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

// Reservation Repository Implementation
class ReservationRepositoryImpl implements ReservationRepository {
  final CollectionReference _reservationsRef =
      FirebaseFirestore.instance.collection(AppConstants.reservationsCollection);

  @override
  Future<List<ReservationEntity>> getUserReservations(String userId) async {
    final snapshot = await _reservationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ReservationModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<List<ReservationEntity>> getBookReservations(String bookId) async {
    final snapshot = await _reservationsRef
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'active')
        .orderBy('position')
        .get();
    return snapshot.docs
        .map((doc) => ReservationModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> createReservation(ReservationEntity reservation) async {
    // Get current position
    final existing = await getBookReservations(reservation.bookId);
    final newPosition = existing.isEmpty ? 1 : existing.last.position + 1;
    final updatedReservation = reservation.copyWith(position: newPosition);
    await _reservationsRef.add(ReservationModel.toFirestore(updatedReservation));
  }

  @override
  Future<void> cancelReservation(String reservationId) async {
    await _reservationsRef.doc(reservationId).update({'status': 'cancelled'});
  }

  @override
  Future<void> completeReservation(String reservationId) async {
    await _reservationsRef.doc(reservationId).update({'status': 'completed'});
  }

  @override
  Stream<List<ReservationEntity>> watchUserReservations(String userId) {
    return _reservationsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReservationModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

// Comment Repository Implementation
class CommentRepositoryImpl implements CommentRepository {
  @override
  Future<List<CommentEntity>> getBookComments(String bookId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .collection(AppConstants.commentsCollection)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => CommentModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> addComment(CommentEntity comment) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(comment.bookId)
        .collection(AppConstants.commentsCollection)
        .add(CommentModel.toFirestore(comment));
  }

  @override
  Future<void> deleteComment(String bookId, String commentId) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .collection(AppConstants.commentsCollection)
        .doc(commentId)
        .delete();
  }

  @override
  Future<void> likeComment(String bookId, String commentId) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .collection(AppConstants.commentsCollection)
        .doc(commentId)
        .update({'likes': FieldValue.increment(1)});
  }

  @override
  Future<void> addReply(String bookId, String commentId, CommentReply reply) async {
    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .collection(AppConstants.commentsCollection)
        .doc(commentId)
        .get();

    if (doc.exists) {
      final replies = List<Map<String, dynamic>>.from(doc.data()?['replies'] ?? []);
      replies.add({
        'id': reply.id,
        'userId': reply.userId,
        'userName': reply.userName,
        'userPhoto': reply.userPhoto,
        'text': reply.text,
        'date': Timestamp.fromDate(reply.date),
      });
      await FirebaseFirestore.instance
          .collection(AppConstants.booksCollection)
          .doc(bookId)
          .collection(AppConstants.commentsCollection)
          .doc(commentId)
          .update({'replies': replies});
    }
  }

  @override
  Stream<List<CommentEntity>> watchBookComments(String bookId) {
    return FirebaseFirestore.instance
        .collection(AppConstants.booksCollection)
        .doc(bookId)
        .collection(AppConstants.commentsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommentModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

// Favorite Repository Implementation
class FavoriteRepositoryImpl implements FavoriteRepository {
  @override
  Future<List<FavoriteEntity>> getUserFavorites(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .orderBy('addedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => FavoriteModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> addFavorite(FavoriteEntity favorite) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(favorite.userId)
        .collection(AppConstants.favoritesCollection)
        .add(FavoriteModel.toFirestore(favorite));
  }

  @override
  Future<void> removeFavorite(String userId, String bookId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .where('bookId', isEqualTo: bookId)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<bool> isFavorite(String userId, String bookId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .where('bookId', isEqualTo: bookId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Stream<List<FavoriteEntity>> watchUserFavorites(String userId) {
    return FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.favoritesCollection)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteModel.fromFirestore(doc).toEntity())
            .toList());
  }
}

// Notification Repository Implementation
class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> sendNotification(NotificationEntity notification) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(notification.userId)
        .collection(AppConstants.notificationsCollection)
        .add(NotificationModel.toFirestore(notification));
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .update({'read': true});
  }

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .doc(notificationId)
        .delete();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .where('read', isEqualTo: false)
        .get();
    return snapshot.docs.length;
  }

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) {
    return FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.notificationsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc).toEntity())
            .toList());
  }
}
