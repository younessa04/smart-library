import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: user?.photo != null && user!.photo!.isNotEmpty
                  ? ClipOval(child: CachedNetworkImage(imageUrl: user.photo!, width: 100, height: 100, fit: BoxFit.cover))
                  : Text(user?.firstName.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(fontSize: 36, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Text(user?.fullName ?? 'Utilisateur', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Text(user?.isManager == true ? 'Gérant' : 'Étudiant - ${user?.studyLevel ?? ''}', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: [
                _buildStatItem(context, Icons.book, '0', 'Emprunts'),
                _buildStatItem(context, Icons.bookmark, '0', 'Réservations'),
                _buildStatItem(context, Icons.favorite, '0', 'Favoris'),
                _buildStatItem(context, Icons.stars, '${user?.points ?? 0}', 'Points'),
              ],
            ),
            const SizedBox(height: 24),
            // Menu items
            _buildMenuItem(context, Icons.edit, 'Modifier le profil', () { Navigator.pushNamed(context, AppRoutes.editProfile); }),
            _buildMenuItem(context, Icons.book_online, 'Mes emprunts', () { Navigator.pushNamed(context, AppRoutes.myLoans); }),
            _buildMenuItem(context, Icons.bookmark, 'Mes réservations', () { Navigator.pushNamed(context, AppRoutes.myReservations); }),
            _buildMenuItem(context, Icons.notifications, 'Notifications', () { Navigator.pushNamed(context, AppRoutes.notifications); }),
            _buildMenuItem(context, Icons.chat, 'Chat avec bibliothécaire', () { Navigator.pushNamed(context, AppRoutes.chat); }),
            _buildMenuItem(context, Icons.qr_code_scanner, 'Scanner QR Code', () {}),
            _buildMenuItem(context, Icons.emoji_events, 'Badges & Points', () {}),
            _buildMenuItem(context, Icons.picture_as_pdf, 'Exporter historique PDF', () {}),
            const SizedBox(height: 16),
            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async { await authProvider.logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false); },
                icon: const Icon(Icons.logout), label: const Text('Déconnexion'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
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

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
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
}
