import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/main_shell.dart';
import 'screens/book_list_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/add_edit_book_screen.dart';
import 'screens/category_books_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/points_badges_screen.dart';
import 'screens/my_loans_screen.dart';
import 'screens/loans_management_screen.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/isbn_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}
  runApp(const SmartLibraryApp());
}

class SmartLibraryApp extends StatelessWidget {
  const SmartLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/': page = const SplashScreen(); break;
          case '/login': page = const LoginScreen(); break;
          case '/register': page = const RegisterScreen(); break;
          case '/forgot-password': page = const ForgotPasswordScreen(); break;
          case '/email-verification': page = const EmailVerificationScreen(); break;
          case '/main': page = const MainShell(); break;
          case '/search': page = const SearchScreen(); break;
          case '/book-detail':
            final bookId = settings.arguments as String;
            page = BookDetailScreen(bookId: bookId); break;
          case '/add-edit-book':
            page = settings.arguments != null
                ? AddEditBookScreen(bookId: settings.arguments as String?)
                : const AddEditBookScreen(); break;
          case '/category-books':
            final args = settings.arguments as Map<String, dynamic>;
            page = CategoryBooksScreen(
              categoryId: args['categoryId'] as String,
              categoryName: args['categoryName'] as String,
            ); break;
          case '/my-loans': page = const MyLoansScreen(); break;
          case '/loans-management': page = const LoansManagementScreen(); break;
          case '/my-reservations': page = const MyReservationsScreen(); break;
          case '/dashboard': page = const DashboardScreen(); break;
          case '/notifications': page = const NotificationsScreen(); break;
          case '/edit-profile': page = const EditProfileScreen(); break;
          case '/chat': page = const ChatScreen(); break;
          case '/qr-scanner': page = const QrScannerScreen(); break;
          case '/isbn-scanner': page = const IsbnScannerScreen(); break;
          case '/badges': page = const PointsBadgesScreen(); break;
          case '/favorites': page = const FavoritesScreen(); break;
          case '/profile': page = const ProfileScreen(); break;
          case '/books': page = const BookListScreen(); break;
          default:
            page = Scaffold(
              appBar: AppBar(title: const Text('Erreur')),
              body: const Center(child: Text('Page non trouv\u00e9e')),
            );
        }
        return MaterialPageRoute(builder: (_) => page, settings: settings);
      },
    );
  }
}
