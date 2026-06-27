class AppConstants {
  // App Info
  static const String appName = 'Smart Library';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String categoriesCollection = 'categories';
  static const String loansCollection = 'loans';
  static const String reservationsCollection = 'reservations';
  static const String commentsCollection = 'comments';
  static const String favoritesCollection = 'favorites';
  static const String notificationsCollection = 'notifications';

  // User Roles
  static const String roleStudent = 'student';
  static const String roleManager = 'manager';

  // Loan Status
  static const String loanPending = 'pending';
  static const String loanApproved = 'approved';
  static const String loanRejected = 'rejected';
  static const String loanReturned = 'returned';
  static const String loanOverdue = 'overdue';

  // Reservation Status
  static const String reservationActive = 'active';
  static const String reservationCancelled = 'cancelled';
  static const String reservationCompleted = 'completed';

  // Loan Duration (days)
  static const int defaultLoanDuration = 14;
  static const int maxRenewals = 2;

  // Pagination
  static const int booksPerPage = 10;
  static const int commentsPerPage = 10;

  // Study Levels
  static const List<String> studyLevels = [
    'Licence 1',
    'Licence 2',
    'Licence 3',
    'Master 1',
    'Master 2',
    'Doctorat',
  ];

  // Categories with icons
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Informatique', 'icon': 'computer'},
    {'name': 'Intelligence Artificielle', 'icon': 'psychology'},
    {'name': 'Data Science', 'icon': 'analytics'},
    {'name': 'Mathématiques', 'icon': 'calculate'},
    {'name': 'Physique', 'icon': 'science'},
    {'name': 'Chimie', 'icon': 'experiment'},
    {'name': 'Économie', 'icon': 'trending_up'},
    {'name': 'Management', 'icon': 'business_center'},
    {'name': 'Réseaux', 'icon': 'lan'},
    {'name': 'Cybersécurité', 'icon': 'security'},
  ];

  // Languages
  static const List<String> languages = [
    'Français',
    'Anglais',
    'Arabe',
    'Espagnol',
    'Allemand',
  ];
}
