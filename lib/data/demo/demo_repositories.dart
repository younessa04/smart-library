import '../../domain/entities/user_entity.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/loan_entity.dart';
import '../../domain/entities/reservation_entity.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/entities/favorite_notification_entity.dart';
import '../../domain/repositories/repository_interfaces.dart';

// ============ DEMO DATA ============

final _demoUser = UserEntity(
  id: 'demo-user-1',
  firstName: 'Younes',
  lastName: 'Demo',
  email: 'demo@smartlibrary.com',
  phone: '+213 555 123 456',
  photo: '',
  studyLevel: 'Master 2',
  registrationDate: DateTime(2024, 1, 15),
  role: 'student',
  points: 350,
  badges: ['first_book', 'reviewer', 'punctual'],
);

final _demoCategories = [
  CategoryEntity(id: 'cat1', name: 'Informatique', icon: 'computer'),
  CategoryEntity(id: 'cat2', name: 'Mathématiques', icon: 'calculate'),
  CategoryEntity(id: 'cat3', name: 'Physique', icon: 'science'),
  CategoryEntity(id: 'cat4', name: 'Littérature', icon: 'menu_book'),
  CategoryEntity(id: 'cat5', name: 'Histoire', icon: 'history_edu'),
  CategoryEntity(id: 'cat6', name: 'Biologie', icon: 'biotech'),
];

final _demoBooks = [
  BookEntity(
    id: 'book1', title: 'Clean Code', author: 'Robert C. Martin', isbn: '9780132350884',
    categoryId: 'cat1', categoryName: 'Informatique', coverImage: 'https://m.media-amazon.com/images/I/41xShlnv7mL._SX218_BO1,204,203,200_QL40_FMwebp_.jpg',
    description: 'A handbook of agile software craftsmanship. Even bad code can function. But if code isn\'t clean, it can bring a development organization to its knees.',
    pages: 464, language: 'Anglais', rating: 4.5, ratingCount: 128, likes: 45, dislikes: 2,
    totalCopies: 5, availableCopies: 3, createdAt: DateTime(2024, 1, 10),
  ),
  BookEntity(
    id: 'book2', title: 'Design Patterns', author: 'Gang of Four', isbn: '9780201633610',
    categoryId: 'cat1', categoryName: 'Informatique', coverImage: 'https://m.media-amazon.com/images/I/51szD9HC9pL._SX395_BO1,204,203,200_.jpg',
    description: 'Elements of reusable object-oriented software. Capturing a wealth of experience about the design of object-oriented software.',
    pages: 416, language: 'Anglais', rating: 4.3, ratingCount: 95, likes: 38, dislikes: 3,
    totalCopies: 3, availableCopies: 1, createdAt: DateTime(2024, 2, 5),
  ),
  BookEntity(
    id: 'book3', title: 'Introduction à l\'algorithmique', author: 'Thomas H. Cormen', isbn: '9782100039227',
    categoryId: 'cat1', categoryName: 'Informatique', coverImage: 'https://m.media-amazon.com/images/I/41SNoh5ZhOL._SX258_BO1,204,203,200_.jpg',
    description: 'Un guide complet sur les algorithmes, couvrant un large éventail de sujets avec des exercices pratiques.',
    pages: 1312, language: 'Français', rating: 4.7, ratingCount: 203, likes: 89, dislikes: 5,
    totalCopies: 8, availableCopies: 5, createdAt: DateTime(2024, 1, 20),
  ),
  BookEntity(
    id: 'book4', title: 'Algèbre linéaire', author: 'Joseph Grifone', isbn: '9782729856519',
    categoryId: 'cat2', categoryName: 'Mathématiques', coverImage: 'https://m.media-amazon.com/images/I/41bQm6n0FqL._SX342_BO1,204,203,200_.jpg',
    description: 'Cours et exercices corrigés d\'algèbre linéaire pour les étudiants en licence et master.',
    pages: 420, language: 'Français', rating: 4.1, ratingCount: 67, likes: 22, dislikes: 1,
    totalCopies: 10, availableCopies: 7, createdAt: DateTime(2024, 3, 1),
  ),
  BookEntity(
    id: 'book5', title: 'Physique quantique', author: 'Franck Laloë', isbn: '9782730210720',
    categoryId: 'cat3', categoryName: 'Physique', coverImage: 'https://m.media-amazon.com/images/I/51K8EYQ09KL._SX342_BO1,204,203,200_.jpg',
    description: 'Une introduction claire et pédagogique à la mécanique quantique.',
    pages: 580, language: 'Français', rating: 4.0, ratingCount: 42, likes: 15, dislikes: 0,
    totalCopies: 4, availableCopies: 4, createdAt: DateTime(2024, 3, 15),
  ),
  BookEntity(
    id: 'book6', title: 'Les Misérables', author: 'Victor Hugo', isbn: '9782070409068',
    categoryId: 'cat4', categoryName: 'Littérature', coverImage: 'https://m.media-amazon.com/images/I/51C-uLZxOYL._SX301_BO1,204,203,200_.jpg',
    description: 'Chef-d\'oeuvre de la littérature française, une fresque sociale et historique du XIXe siècle.',
    pages: 1900, language: 'Français', rating: 4.8, ratingCount: 312, likes: 150, dislikes: 8,
    totalCopies: 12, availableCopies: 9, createdAt: DateTime(2024, 1, 5),
  ),
  BookEntity(
    id: 'book7', title: 'Flutter in Action', author: 'Eric Windmill', isbn: '9781617296147',
    categoryId: 'cat1', categoryName: 'Informatique', coverImage: 'https://m.media-amazon.com/images/I/41v-3gf+qSL._SX397_BO1,204,203,200_.jpg',
    description: 'A complete guide to building beautiful mobile applications with Flutter.',
    pages: 592, language: 'Anglais', rating: 4.4, ratingCount: 88, likes: 35, dislikes: 2,
    totalCopies: 6, availableCopies: 4, createdAt: DateTime(2024, 4, 10),
  ),
  BookEntity(
    id: 'book8', title: 'Histoire de l\'Algérie', author: 'Benjamin Stora', isbn: '9782707185457',
    categoryId: 'cat5', categoryName: 'Histoire', coverImage: 'https://m.media-amazon.com/images/I/51Z5K3jZURL._SX342_BO1,204,203,200_.jpg',
    description: 'Une histoire complète de l\'Algérie depuis l\'Antiquité jusqu\'à nos jours.',
    pages: 380, language: 'Français', rating: 4.2, ratingCount: 56, likes: 28, dislikes: 1,
    totalCopies: 7, availableCopies: 6, createdAt: DateTime(2024, 2, 20),
  ),
];

// ============ DEMO REPOSITORIES ============

class DemoAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty || password.isEmpty) throw 'Email et mot de passe requis';
    return _demoUser;
  }

  @override
  Future<UserEntity> register(UserEntity user, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    return user;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> verifyEmail() async {}

  @override
  Future<bool> isEmailVerified() async => true;

  @override
  Future<UserEntity?> getCurrentUser() async => _demoUser;

  @override
  Stream<UserEntity?> get authStateChanges => Stream.value(_demoUser);
}

class DemoUserRepository implements UserRepository {
  @override
  Future<UserEntity?> getUserById(String userId) async => _demoUser;

  @override
  Future<void> updateUser(UserEntity user) async {}

  @override
  Future<void> updateUserPhoto(String userId, String photoUrl) async {}

  @override
  Future<void> addPoints(String userId, int points) async {}

  @override
  Future<void> addBadge(String userId, String badge) async {}

  @override
  Future<List<UserEntity>> getAllUsers() async => [_demoUser];

  @override
  Stream<UserEntity?> watchUser(String userId) => Stream.value(_demoUser);
}

class DemoBookRepository implements BookRepository {
  @override
  Future<List<BookEntity>> getAllBooks() async => _demoBooks;

  @override
  Future<BookEntity?> getBookById(String bookId) async {
    return _demoBooks.firstWhere((b) => b.id == bookId);
  }

  @override
  Future<void> addBook(BookEntity book) async {}

  @override
  Future<void> updateBook(BookEntity book) async {}

  @override
  Future<void> deleteBook(String bookId) async {}

  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    final q = query.toLowerCase();
    return _demoBooks.where((b) =>
      b.title.toLowerCase().contains(q) || b.author.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Future<List<BookEntity>> getBooksByCategory(String categoryId) async {
    return _demoBooks.where((b) => b.categoryId == categoryId).toList();
  }

  @override
  Future<List<BookEntity>> getPopularBooks() async {
    return [..._demoBooks]..sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
  }

  @override
  Future<List<BookEntity>> getNewBooks() async {
    return [..._demoBooks]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<BookEntity>> getTopRatedBooks() async {
    return [..._demoBooks]..sort((a, b) => b.rating.compareTo(a.rating));
  }

  @override
  Future<void> likeBook(String bookId, String userId) async {}

  @override
  Future<void> dislikeBook(String bookId, String userId) async {}

  @override
  Stream<List<BookEntity>> watchBooks() => Stream.value(_demoBooks);
}

class DemoCategoryRepository implements CategoryRepository {
  @override
  Future<List<CategoryEntity>> getAllCategories() async => _demoCategories;

  @override
  Future<CategoryEntity> getCategory(String id) async => _demoCategories.firstWhere((c) => c.id == id);

  @override
  Future<void> addCategory(CategoryEntity category) async {}

  @override
  Future<void> updateCategory(CategoryEntity category) async {}

  @override
  Future<void> deleteCategory(String id) async {}
}

class DemoLoanRepository implements LoanRepository {
  final _demoLoans = [
    LoanEntity(
      id: 'loan1', userId: 'demo-user-1', userName: 'Younes Demo',
      bookId: 'book1', bookTitle: 'Clean Code', bookCover: 'https://m.media-amazon.com/images/I/41xShlnv7mL._SX218_BO1,204,203,200_QL40_FMwebp_.jpg',
      borrowDate: DateTime.now().subtract(const Duration(days: 5)),
      dueDate: DateTime.now().add(const Duration(days: 9)),
      status: 'approved',
    ),
    LoanEntity(
      id: 'loan2', userId: 'demo-user-1', userName: 'Younes Demo',
      bookId: 'book6', bookTitle: 'Les Misérables', bookCover: 'https://m.media-amazon.com/images/I/51C-uLZxOYL._SX301_BO1,204,203,200_.jpg',
      borrowDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().subtract(const Duration(days: 6)),
      status: 'returned',
    ),
  ];

  @override
  Future<List<LoanEntity>> getUserLoans(String userId) async => _demoLoans;

  @override
  Future<List<LoanEntity>> getAllLoans() async => _demoLoans;

  @override
  Future<List<LoanEntity>> getPendingLoans() async => [];

  @override
  Future<void> requestLoan(LoanEntity loan) async {}

  @override
  Future<void> approveLoan(String loanId) async {}

  @override
  Future<void> rejectLoan(String loanId) async {}

  @override
  Future<void> returnLoan(String loanId) async {}

  @override
  Future<void> renewLoan(String loanId) async {}

  @override
  Stream<List<LoanEntity>> watchUserLoans(String userId) => Stream.value(_demoLoans);

  @override
  Stream<List<LoanEntity>> watchAllLoans() => Stream.value(_demoLoans);
}

class DemoReservationRepository implements ReservationRepository {
  @override
  Future<List<ReservationEntity>> getUserReservations(String userId) async {
    return [
      ReservationEntity(
        id: 'res1', userId: 'demo-user-1', userName: 'Younes Demo',
        bookId: 'book2', bookTitle: 'Design Patterns', bookCover: 'https://m.media-amazon.com/images/I/51szD9HC9pL._SX395_BO1,204,203,200_.jpg',
        date: DateTime.now().subtract(const Duration(days: 2)), status: 'active', position: 1,
      ),
    ];
  }

  @override
  Future<List<ReservationEntity>> getBookReservations(String bookId) async => [];

  @override
  Future<void> createReservation(ReservationEntity reservation) async {}

  @override
  Future<void> cancelReservation(String reservationId) async {}

  @override
  Future<void> completeReservation(String reservationId) async {}

  @override
  Stream<List<ReservationEntity>> watchUserReservations(String userId) => const Stream.empty();
}

class DemoCommentRepository implements CommentRepository {
  @override
  Future<List<CommentEntity>> getBookComments(String bookId) async {
    return [
      CommentEntity(
        id: 'c1', userId: 'user2', userName: 'Amina B.', bookId: bookId,
        text: 'Excellent livre, très instructif !', rating: 5, date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      CommentEntity(
        id: 'c2', userId: 'user3', userName: 'Karim M.', bookId: bookId,
        text: 'Bon livre pour les débutants.', rating: 4, date: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }

  @override
  Future<void> addComment(CommentEntity comment) async {}

  @override
  Future<void> deleteComment(String bookId, String commentId) async {}

  @override
  Future<void> likeComment(String bookId, String commentId) async {}

  @override
  Future<void> addReply(String bookId, String commentId, CommentReply reply) async {}

  @override
  Stream<List<CommentEntity>> watchBookComments(String bookId) => const Stream.empty();
}

class DemoFavoriteRepository implements FavoriteRepository {
  @override
  Future<List<FavoriteEntity>> getUserFavorites(String userId) async {
    return [
      FavoriteEntity(
        id: 'fav1', userId: userId, bookId: 'book3', bookTitle: 'Introduction à l\'algorithmique',
        bookAuthor: 'Thomas H. Cormen', bookCover: 'https://m.media-amazon.com/images/I/41SNoh5ZhOL._SX258_BO1,204,203,200_.jpg',
        bookRating: 4.7, addedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      FavoriteEntity(
        id: 'fav2', userId: userId, bookId: 'book6', bookTitle: 'Les Misérables',
        bookAuthor: 'Victor Hugo', bookCover: 'https://m.media-amazon.com/images/I/51C-uLZxOYL._SX301_BO1,204,203,200_.jpg',
        bookRating: 4.8, addedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<void> addFavorite(FavoriteEntity favorite) async {}

  @override
  Future<void> removeFavorite(String userId, String bookId) async {}

  @override
  Future<bool> isFavorite(String userId, String bookId) async => bookId == 'book3' || bookId == 'book6';

  @override
  Stream<List<FavoriteEntity>> watchUserFavorites(String userId) => const Stream.empty();
}

class DemoNotificationRepository implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getUserNotifications(String userId) async {
    return [
      NotificationEntity(
        id: 'n1', userId: userId, title: 'Emprunt approuvé',
        body: 'Votre demande d\'emprunt de "Clean Code" a été approuvée.',
        type: 'book_available', read: false, date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      NotificationEntity(
        id: 'n2', userId: userId, title: 'Rappel de retour',
        body: 'N\'oubliez pas de retourner "Les Misérables" avant le 15 Juin.',
        type: 'return_reminder', read: false, date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      NotificationEntity(
        id: 'n3', userId: userId, title: 'Nouveau livre disponible',
        body: 'Découvrez "Flutter in Action" nouvellement ajouté à la bibliothèque.',
        type: 'new_book', read: true, date: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }

  @override
  Future<void> sendNotification(NotificationEntity notification) async {}

  @override
  Future<void> markAsRead(String userId, String notificationId) async {}

  @override
  Future<void> deleteNotification(String userId, String notificationId) async {}

  @override
  Future<int> getUnreadCount(String userId) async => 2;

  @override
  Stream<List<NotificationEntity>> watchUserNotifications(String userId) => const Stream.empty();
}
