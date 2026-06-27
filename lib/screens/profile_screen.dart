import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();
  User? _user;
  bool _isLoading = true;
  int _loansCount = 0;
  int _reservationsCount = 0;
  int _favoritesCount = 0;

  // Manager data
  int _totalBooks = 0;
  int _totalUsers = 0;
  int _pendingLoans = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      if (user.isManager) {
        final results = await Future.wait([
          _db.getAllBooks(),
          _authService.getAllUsers(),
          _db.getPendingLoans(),
        ]);
        if (!mounted) return;
        setState(() {
          _user = user;
          _totalBooks = results[0].length;
          _totalUsers = results[1].length;
          _pendingLoans = results[2].length;
          _isLoading = false;
        });
      } else {
        final results = await Future.wait([
          _db.getUserLoans(user.id),
          _db.getUserReservations(user.id),
          _db.getUserFavorites(user.id),
        ]);
        if (!mounted) return;
        setState(() {
          _user = user;
          _loansCount = results[0].length;
          _reservationsCount = results[1].length;
          _favoritesCount = results[2].length;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _user;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Utilisateur non trouv\u00e9')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: (user.photo != null && user.photo!.isNotEmpty)
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: user.photo!,
                        width: 100, height: 100,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      user.firstName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 16),
            Text(user.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user.email, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.isManager ? Colors.orange.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.isManager ? 'G\u00e9rant' : '\u00c9tudiant - ${user.studyLevel ?? ''}',
                style: TextStyle(fontSize: 12, color: user.isManager ? Colors.orange : AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            if (user.isManager)
              _buildManagerStats()
            else
              _buildStudentStats(user),
            const SizedBox(height: 24),
            if (user.isManager) _buildManagerMenu() else _buildStudentMenu(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentStats(User user) {
    return Row(
      children: [
        _buildStatItem(Icons.book, '$_loansCount', 'Emprunts'),
        _buildStatItem(Icons.bookmark, '$_reservationsCount', 'R\u00e9servations'),
        _buildStatItem(Icons.favorite, '$_favoritesCount', 'Favoris'),
        _buildStatItem(Icons.stars, '${user.points}', 'Points'),
      ],
    );
  }

  Widget _buildManagerStats() {
    return Row(
      children: [
        _buildStatItem(Icons.book, '$_totalBooks', 'Livres'),
        _buildStatItem(Icons.people, '$_totalUsers', 'Membres'),
        _buildStatItem(Icons.pending_actions, '$_pendingLoans', 'En attente'),
        _buildStatItem(Icons.stars, '0', 'Points'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStudentMenu() {
    return Column(
      children: [
        _menuItem(Icons.edit, 'Modifier le profil', () => Navigator.pushNamed(context, '/edit-profile')),
        _menuItem(Icons.book_online, 'Mes emprunts', () => Navigator.pushNamed(context, '/my-loans')),
        _menuItem(Icons.bookmark, 'Mes r\u00e9servations', () => Navigator.pushNamed(context, '/my-reservations')),
        _menuItem(Icons.notifications, 'Notifications', () => Navigator.pushNamed(context, '/notifications')),
        _menuItem(Icons.chat, 'Chat avec biblioth\u00e9caire', () => Navigator.pushNamed(context, '/chat')),
        _menuItem(Icons.emoji_events, 'Badges & Points', () => Navigator.pushNamed(context, '/badges')),
        const SizedBox(height: 16),
        _logoutButton(),
      ],
    );
  }

  Widget _buildManagerMenu() {
    return Column(
      children: [
        _menuItem(Icons.dashboard, 'Dashboard', () => Navigator.pushNamed(context, '/dashboard')),
        _menuItem(Icons.inventory_2, 'Gestion des livres', () => Navigator.pushNamed(context, '/books')),
        _menuItem(Icons.swap_horiz, 'Gestion des emprunts', () => Navigator.pushNamed(context, '/loans-management')),
        _menuItem(Icons.bookmark, 'R\u00e9servations', () => Navigator.pushNamed(context, '/my-reservations')),
        _menuItem(Icons.edit, 'Modifier le profil', () => Navigator.pushNamed(context, '/edit-profile')),
        _menuItem(Icons.notifications, 'Notifications', () => Navigator.pushNamed(context, '/notifications')),
        const SizedBox(height: 16),
        _logoutButton(),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('D\u00e9connexion'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
