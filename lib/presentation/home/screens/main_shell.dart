import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/screens/home_screen.dart';
import '../../search/screens/search_screen.dart';
import '../../favorites/screens/favorites_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../books/screens/book_list_screen.dart';
import '../../loans/screens/loans_management_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget> get _studentScreens => [
        const HomeScreen(),
        const SearchScreen(),
        const FavoritesScreen(),
        const ProfileScreen(),
      ];

  List<Widget> get _managerScreens => [
        const DashboardScreen(),
        const BookListScreen(),
        const LoansManagementScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isManager = authProvider.isManager;

    final screens = isManager ? _managerScreens : _studentScreens;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: isManager
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: 'Livres',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz),
                  label: 'Emprunts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Accueil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Recherche',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: 'Favoris',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
              ],
      ),
    );
  }
}
