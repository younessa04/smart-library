import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/comment.dart';
import '../models/loan.dart';
import '../models/reservation.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---- Books ----
  Future<List<Book>> getAllBooks() async {
    final snapshot = await _firestore.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  Future<Book?> getBookById(String id) async {
    final doc = await _firestore.collection('books').doc(id).get();
    if (doc.exists) return Book.fromFirestore(doc);
    return null;
  }

  Future<void> addBook(Book book) async {
    final data = book.toFirestore();
    data.remove('id');
    final docRef = await _firestore.collection('books').add(data);
    await docRef.update({'id': docRef.id, 'createdAt': Timestamp.now()});
  }

  Future<void> updateBook(Book book) async {
    await _firestore.collection('books').doc(book.id).update(book.toFirestore());
  }

  Future<void> deleteBook(String id) async {
    await _firestore.collection('books').doc(id).delete();
  }

  Future<List<Book>> searchBooks(String query) async {
    final all = await getAllBooks();
    final q = query.toLowerCase();
    return all.where((b) =>
      b.title.toLowerCase().contains(q) ||
      b.author.toLowerCase().contains(q) ||
      b.isbn.toLowerCase().contains(q) ||
      b.categoryName.toLowerCase().contains(q)
    ).toList();
  }

  Future<List<Book>> getBooksByCategory(String categoryId) async {
    final snapshot = await _firestore.collection('books')
        .where('categoryId', isEqualTo: categoryId).get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  Future<List<Book>> getPopularBooks() async {
    final all = await getAllBooks();
    all.sort((a, b) => b.likes.compareTo(a.likes));
    return all.take(10).toList();
  }

  Future<List<Book>> getNewBooks() async {
    final snapshot = await _firestore.collection('books')
        .orderBy('createdAt', descending: true).limit(10).get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  Future<List<Book>> getTopRatedBooks() async {
    final snapshot = await _firestore.collection('books')
        .orderBy('rating', descending: true).limit(10).get();
    return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
  }

  Future<void> likeBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).update({'likes': FieldValue.increment(1)});
  }

  Future<void> dislikeBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).update({'dislikes': FieldValue.increment(1)});
  }

  // ---- Categories ----
  Future<List<Category>> getAllCategories() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs.map((doc) => Category.fromFirestore(doc)).toList();
  }

  Future<void> addCategory(Category category) async {
    await _firestore.collection('categories').add(category.toFirestore());
  }

  // ---- Loans ----
  Future<List<Loan>> getUserLoans(String userId) async {
    final snapshot = await _firestore.collection('loans')
        .where('userId', isEqualTo: userId)
        .orderBy('borrowDate', descending: true).get();
    return snapshot.docs.map((doc) => Loan.fromFirestore(doc)).toList();
  }

  Future<List<Loan>> getAllLoans() async {
    final snapshot = await _firestore.collection('loans')
        .orderBy('borrowDate', descending: true).get();
    return snapshot.docs.map((doc) => Loan.fromFirestore(doc)).toList();
  }

  Future<List<Loan>> getPendingLoans() async {
    final snapshot = await _firestore.collection('loans')
        .where('status', isEqualTo: 'pending').get();
    return snapshot.docs.map((doc) => Loan.fromFirestore(doc)).toList();
  }

  Future<void> requestLoan(Loan loan) async {
    await _firestore.collection('loans').add(loan.toFirestore());
  }

  Future<void> approveLoan(String loanId) async {
    await _firestore.collection('loans').doc(loanId).update({'status': 'approved'});
  }

  Future<void> rejectLoan(String loanId) async {
    await _firestore.collection('loans').doc(loanId).update({'status': 'rejected'});
  }

  Future<void> returnLoan(String loanId) async {
    await _firestore.collection('loans').doc(loanId).update({
      'status': 'returned',
      'returnDate': Timestamp.now(),
    });
  }

  Future<void> renewLoan(String loanId) async {
    final doc = await _firestore.collection('loans').doc(loanId).get();
    if (!doc.exists) return;
    final loan = Loan.fromFirestore(doc);
    if (loan.canRenew) {
      await _firestore.collection('loans').doc(loanId).update({
        'dueDate': Timestamp.fromDate(loan.dueDate.add(const Duration(days: 14))),
        'renewCount': loan.renewCount + 1,
      });
    }
  }

  // ---- Reservations ----
  Future<List<Reservation>> getUserReservations(String userId) async {
    final snapshot = await _firestore.collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
  }

  Future<List<Reservation>> getBookReservations(String bookId) async {
    final snapshot = await _firestore.collection('reservations')
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'active')
        .orderBy('position').get();
    return snapshot.docs.map((doc) => Reservation.fromFirestore(doc)).toList();
  }

  Future<void> createReservation(Reservation reservation) async {
    final existing = await getBookReservations(reservation.bookId);
    final newPosition = existing.isEmpty ? 1 : existing.last.position + 1;
    final updated = reservation.copyWith(position: newPosition);
    await _firestore.collection('reservations').add(updated.toFirestore());
  }

  Future<void> cancelReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).update({'status': 'cancelled'});
  }

  Future<void> completeReservation(String reservationId) async {
    await _firestore.collection('reservations').doc(reservationId).update({'status': 'completed'});
  }

  // ---- Comments ----
  Future<List<Comment>> getBookComments(String bookId) async {
    final snapshot = await _firestore.collection('books').doc(bookId)
        .collection('comments').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  Future<void> addComment(Comment comment) async {
    await _firestore.collection('books').doc(comment.bookId)
        .collection('comments').add(comment.toFirestore());
  }

  Future<void> deleteComment(String bookId, String commentId) async {
    await _firestore.collection('books').doc(bookId)
        .collection('comments').doc(commentId).delete();
  }

  Future<void> likeComment(String bookId, String commentId) async {
    await _firestore.collection('books').doc(bookId)
        .collection('comments').doc(commentId).update({'likes': FieldValue.increment(1)});
  }

  // ---- Favorites ----
  Future<bool> isFavorite(String userId, String bookId) async {
    final snapshot = await _firestore.collection('users').doc(userId)
        .collection('favorites').where('bookId', isEqualTo: bookId).get();
    return snapshot.docs.isNotEmpty;
  }

  Future<void> addFavorite(String userId, String bookId, String bookTitle,
      String bookAuthor, String bookCover, double bookRating) async {
    await _firestore.collection('users').doc(userId).collection('favorites').add({
      'userId': userId,
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookCover': bookCover,
      'bookRating': bookRating,
      'addedAt': Timestamp.now(),
    });
  }

  Future<void> removeFavorite(String userId, String bookId) async {
    final snapshot = await _firestore.collection('users').doc(userId)
        .collection('favorites').where('bookId', isEqualTo: bookId).get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<Map<String, dynamic>>> getUserFavorites(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId)
        .collection('favorites').orderBy('addedAt', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ---- Notifications ----
  Future<List<Map<String, dynamic>>> getUserNotifications(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId)
        .collection('notifications').orderBy('date', descending: true).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    await _firestore.collection('users').doc(userId)
        .collection('notifications').doc(notificationId).update({'read': true});
  }

  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore.collection('users').doc(userId)
        .collection('notifications').doc(notificationId).delete();
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId)
        .collection('notifications').where('read', isEqualTo: false).get();
    return snapshot.docs.length;
  }
}
