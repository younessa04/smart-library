import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/routing/route_generator.dart';
import 'core/routing/app_routes.dart';
import 'core/utils/offline_cache_service.dart';

// Repositories
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/book_category_user_repo_impl.dart';
import 'data/repositories/remaining_repo_impl.dart';
import 'domain/repositories/repository_interfaces.dart';

// Providers
import 'presentation/auth/providers/auth_provider.dart';
import 'presentation/books/providers/book_provider.dart';
import 'presentation/favorites/providers/favorites_provider.dart';
import 'presentation/loans/providers/loan_provider.dart';
import 'presentation/reservations/providers/reservation_provider.dart';
import 'presentation/notifications/providers/notifications_provider.dart';

// Demo data
import 'data/demo/demo_repositories.dart';

bool _demoMode = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    _demoMode = true;
  }
  if (!_demoMode) {
    await OfflineCacheService.initialize();
  }
  runApp(SmartLibraryApp(demoMode: _demoMode));
}

class SmartLibraryApp extends StatelessWidget {
  final bool demoMode;
  const SmartLibraryApp({super.key, this.demoMode = false});

  @override
  Widget build(BuildContext context) {
    if (demoMode) {
      return _buildDemoApp();
    }
    return _buildFirebaseApp();
  }

  Widget _buildDemoApp() {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => DemoAuthRepository()),
        Provider<UserRepository>(create: (_) => DemoUserRepository()),
        Provider<BookRepository>(create: (_) => DemoBookRepository()),
        Provider<CategoryRepository>(create: (_) => DemoCategoryRepository()),
        Provider<LoanRepository>(create: (_) => DemoLoanRepository()),
        Provider<ReservationRepository>(create: (_) => DemoReservationRepository()),
        Provider<CommentRepository>(create: (_) => DemoCommentRepository()),
        Provider<FavoriteRepository>(create: (_) => DemoFavoriteRepository()),
        Provider<NotificationRepository>(create: (_) => DemoNotificationRepository()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BookProvider(
            bookRepository: context.read<BookRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(
            favoriteRepository: context.read<FavoriteRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoanProvider(
            loanRepository: context.read<LoanRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(
            reservationRepository: context.read<ReservationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationsProvider(
            notificationRepository: context.read<NotificationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Library',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        builder: (context, child) => Stack(
          children: [
            child ?? const SizedBox(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: Colors.orange,
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'DEMO MODE - Configurez Firebase pour le mode production',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebaseApp() {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
        Provider<UserRepository>(create: (_) => UserRepositoryImpl()),
        Provider<BookRepository>(create: (_) => BookRepositoryImpl()),
        Provider<CategoryRepository>(create: (_) => CategoryRepositoryImpl()),
        Provider<LoanRepository>(create: (_) => LoanRepositoryImpl()),
        Provider<ReservationRepository>(create: (_) => ReservationRepositoryImpl()),
        Provider<CommentRepository>(create: (_) => CommentRepositoryImpl()),
        Provider<FavoriteRepository>(create: (_) => FavoriteRepositoryImpl()),
        Provider<NotificationRepository>(create: (_) => NotificationRepositoryImpl()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            authRepository: context.read<AuthRepository>(),
            userRepository: context.read<UserRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BookProvider(
            bookRepository: context.read<BookRepository>(),
            categoryRepository: context.read<CategoryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => FavoritesProvider(
            favoriteRepository: context.read<FavoriteRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => LoanProvider(
            loanRepository: context.read<LoanRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ReservationProvider(
            reservationRepository: context.read<ReservationRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => NotificationsProvider(
            notificationRepository: context.read<NotificationRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Library',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
