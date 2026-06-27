import '../entities/user_entity.dart';
import '../entities/book_entity.dart';
import '../entities/category_entity.dart';
import '../entities/loan_entity.dart';
import '../entities/reservation_entity.dart';
import '../entities/comment_entity.dart';
import '../entities/favorite_notification_entity.dart';

// Auth Repository Interface
abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(UserEntity user, String password);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> verifyEmail();
  Future<bool> isEmailVerified();
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
}

// User Repository Interface
abstract class UserRepository {
  Future<UserEntity?> getUserById(String id);
  Future<void> updateUser(UserEntity user);
  Future<void> updateUserPhoto(String userId, String photoUrl);
  Future<List<UserEntity>> getAllUsers();
  Stream<UserEntity?> watchUser(String userId);
  Future<void> addPoints(String userId, int points);
  Future<void> addBadge(String userId, String badge);
}

// Book Repository Interface
abstract class BookRepository {
  Future<List<BookEntity>> getAllBooks();
  Future<BookEntity?> getBookById(String id);
  Future<void> addBook(BookEntity book);
  Future<void> updateBook(BookEntity book);
  Future<void> deleteBook(String id);
  Future<List<BookEntity>> searchBooks(String query);
  Future<List<BookEntity>> getBooksByCategory(String categoryId);
  Future<List<BookEntity>> getPopularBooks();
  Future<List<BookEntity>> getNewBooks();
  Future<List<BookEntity>> getTopRatedBooks();
  Future<void> likeBook(String bookId, String userId);
  Future<void> dislikeBook(String bookId, String userId);
  Stream<List<BookEntity>> watchBooks();
}

// Category Repository Interface
abstract class CategoryRepository {
  Future<List<CategoryEntity>> getAllCategories();
  Future<void> addCategory(CategoryEntity category);
  Future<void> updateCategory(CategoryEntity category);
  Future<void> deleteCategory(String id);
}

// Loan Repository Interface
abstract class LoanRepository {
  Future<List<LoanEntity>> getUserLoans(String userId);
  Future<List<LoanEntity>> getAllLoans();
  Future<List<LoanEntity>> getPendingLoans();
  Future<void> requestLoan(LoanEntity loan);
  Future<void> approveLoan(String loanId);
  Future<void> rejectLoan(String loanId);
  Future<void> returnLoan(String loanId);
  Future<void> renewLoan(String loanId);
  Stream<List<LoanEntity>> watchUserLoans(String userId);
  Stream<List<LoanEntity>> watchAllLoans();
}

// Reservation Repository Interface
abstract class ReservationRepository {
  Future<List<ReservationEntity>> getUserReservations(String userId);
  Future<List<ReservationEntity>> getBookReservations(String bookId);
  Future<void> createReservation(ReservationEntity reservation);
  Future<void> cancelReservation(String reservationId);
  Future<void> completeReservation(String reservationId);
  Stream<List<ReservationEntity>> watchUserReservations(String userId);
}

// Comment Repository Interface
abstract class CommentRepository {
  Future<List<CommentEntity>> getBookComments(String bookId);
  Future<void> addComment(CommentEntity comment);
  Future<void> deleteComment(String bookId, String commentId);
  Future<void> likeComment(String bookId, String commentId);
  Future<void> addReply(String bookId, String commentId, CommentReply reply);
  Stream<List<CommentEntity>> watchBookComments(String bookId);
}

// Favorite Repository Interface
abstract class FavoriteRepository {
  Future<List<FavoriteEntity>> getUserFavorites(String userId);
  Future<void> addFavorite(FavoriteEntity favorite);
  Future<void> removeFavorite(String userId, String bookId);
  Future<bool> isFavorite(String userId, String bookId);
  Stream<List<FavoriteEntity>> watchUserFavorites(String userId);
}

// Notification Repository Interface
abstract class NotificationRepository {
  Future<List<NotificationEntity>> getUserNotifications(String userId);
  Future<void> sendNotification(NotificationEntity notification);
  Future<void> markAsRead(String userId, String notificationId);
  Future<void> deleteNotification(String userId, String notificationId);
  Future<int> getUnreadCount(String userId);
  Stream<List<NotificationEntity>> watchUserNotifications(String userId);
}
