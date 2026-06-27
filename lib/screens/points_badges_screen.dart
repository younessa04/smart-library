import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../core/theme/app_colors.dart';

class PointsBadgesScreen extends StatefulWidget {
  const PointsBadgesScreen({super.key});
  @override
  State<PointsBadgesScreen> createState() => _PointsBadgesScreenState();
}

class _PointsBadgesScreenState extends State<PointsBadgesScreen> {
  final _authService = AuthService();

  User? _user;
  bool _isLoading = true;

  static const Map<String, Map<String, dynamic>> _allBadges = {
    'first_book': {
      'name': 'Premier Livre',
      'icon': Icons.menu_book,
      'description': 'Emprunter votre premier livre',
      'points': 50,
      'color': Colors.green,
    },
    'bookworm': {
      'name': 'Rat de Bibliothèque',
      'icon': Icons.library_books,
      'description': 'Emprunter 10 livres',
      'points': 100,
      'color': Colors.blue,
    },
    'scholar': {
      'name': 'Érudit',
      'icon': Icons.school,
      'description': 'Emprunter 50 livres',
      'points': 250,
      'color': Colors.purple,
    },
    'reviewer': {
      'name': 'Critique',
      'icon': Icons.rate_review,
      'description': 'Laisser 5 commentaires',
      'points': 75,
      'color': Colors.orange,
    },
    'top_rater': {
      'name': 'Évaluateur',
      'icon': Icons.star,
      'description': 'Évaluer 20 livres',
      'points': 100,
      'color': Colors.amber,
    },
    'punctual': {
      'name': 'Ponctuel',
      'icon': Icons.alarm_on,
      'description': 'Retourner 5 livres à temps',
      'points': 150,
      'color': Colors.teal,
    },
    'social': {
      'name': 'Social',
      'icon': Icons.people,
      'description': 'Partager 10 livres',
      'points': 50,
      'color': Colors.pink,
    },
    'streak_7': {
      'name': 'Série 7 jours',
      'icon': Icons.local_fire_department,
      'description': 'Visiter 7 jours consécutifs',
      'points': 200,
      'color': Colors.red,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Points & Badges')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;
    final points = user?.points ?? 0;
    final earnedBadges = user?.badges ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Points & Badges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    '$points',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Points',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: (points % 500) / 500,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${500 - (points % 500)} points pour le prochain niveau',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Badges (${earnedBadges.length}/${_allBadges.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _allBadges.length,
              itemBuilder: (context, index) {
                final entry = _allBadges.entries.elementAt(index);
                final key = entry.key;
                final badge = entry.value;
                final earned = earnedBadges.contains(key);
                final color = badge['color'] as Color;

                return Card(
                  elevation: earned ? 4 : 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: earned
                          ? color.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.05),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          badge['icon'] as IconData,
                          size: 40,
                          color: earned ? color : Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: earned ? null : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge['description'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: earned ? color : Colors.grey,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${badge['points']} pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
