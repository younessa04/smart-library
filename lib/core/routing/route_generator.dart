import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../presentation/auth/screens/splash_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';
import '../../presentation/auth/screens/register_screen.dart';
import '../../presentation/auth/screens/forgot_password_screen.dart';
import '../../presentation/auth/screens/email_verification_screen.dart';
import '../../presentation/home/screens/main_shell.dart';
import '../../presentation/books/screens/book_detail_screen.dart';
import '../../presentation/books/screens/add_edit_book_screen.dart';
import '../../presentation/books/screens/category_books_screen.dart';
import '../../presentation/loans/screens/my_loans_screen.dart';
import '../../presentation/loans/screens/loans_management_screen.dart';
import '../../presentation/reservations/screens/my_reservations_screen.dart';
import '../../presentation/dashboard/screens/dashboard_screen.dart';
import '../../presentation/notifications/screens/notifications_screen.dart';
import '../../presentation/profile/screens/edit_profile_screen.dart';
import '../../presentation/chat/screens/chat_screen.dart';
import '../../presentation/search/screens/search_screen.dart';
import '../../presentation/books/screens/qr_scanner_screen.dart';
import '../../presentation/books/screens/isbn_scanner_screen.dart';
import '../../presentation/profile/screens/points_badges_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.emailVerification:
        return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());

      // Main routes
      case AppRoutes.mainShell:
        return MaterialPageRoute(builder: (_) => const MainShell());

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      // Book routes
      case AppRoutes.bookDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => BookDetailScreen(bookId: args),
          );
        }
        return _errorRoute();

      case AppRoutes.addEditBook:
        if (args is String?) {
          return MaterialPageRoute(
            builder: (_) => AddEditBookScreen(bookId: args),
          );
        }
        return MaterialPageRoute(builder: (_) => const AddEditBookScreen());

      case AppRoutes.categoryBooks:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => CategoryBooksScreen(
              categoryId: args['categoryId'] as String,
              categoryName: args['categoryName'] as String,
            ),
          );
        }
        return _errorRoute();

      // Loan routes
      case AppRoutes.myLoans:
        return MaterialPageRoute(builder: (_) => const MyLoansScreen());

      case AppRoutes.loansManagement:
        return MaterialPageRoute(builder: (_) => const LoansManagementScreen());

      // Reservation routes
      case AppRoutes.myReservations:
        return MaterialPageRoute(builder: (_) => const MyReservationsScreen());

      // Dashboard routes
      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      // Other routes
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      case AppRoutes.chat:
        return MaterialPageRoute(builder: (_) => const ChatScreen());

      case AppRoutes.qrScanner:
        return MaterialPageRoute(builder: (_) => const QrScannerScreen());

      case AppRoutes.isbnScanner:
        return MaterialPageRoute(builder: (_) => const IsbnScannerScreen());

      case AppRoutes.badges:
        return MaterialPageRoute(builder: (_) => const PointsBadgesScreen());

      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Page non trouvée',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
