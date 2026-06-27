class AppRoutes {
  // Auth routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // Main routes
  static const String mainShell = '/main';
  static const String home = '/home';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String profile = '/profile';

  // Book routes
  static const String bookList = '/books';
  static const String bookDetail = '/book-detail';
  static const String addEditBook = '/add-edit-book';
  static const String categoryBooks = '/category-books';

  // Loan routes
  static const String myLoans = '/my-loans';
  static const String loansManagement = '/loans-management';
  static const String loanDetail = '/loan-detail';

  // Reservation routes
  static const String myReservations = '/my-reservations';
  static const String reservationsManagement = '/reservations-management';

  // Dashboard routes
  static const String dashboard = '/dashboard';

  // Other routes
  static const String notifications = '/notifications';
  static const String editProfile = '/edit-profile';
  static const String chat = '/chat';
  static const String qrScanner = '/qr-scanner';
  static const String isbnScanner = '/isbn-scanner';
  static const String statistics = '/statistics';
  static const String badges = '/badges';
}
