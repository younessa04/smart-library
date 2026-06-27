import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';

import '../core/widgets/state_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();

  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final favorites = await _db.getUserFavorites(user.id);
        if (!mounted) return;
        setState(() {
          _favorites = favorites;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(String bookId) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;
    await _db.removeFavorite(user.id, bookId);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'Aucun favori',
                  subtitle:
                      'Ajoutez des livres à vos favoris pour les retrouver ici',
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final fav = _favorites[index];
                      return Dismissible(
                        key: Key(fav['bookId'] ?? ''),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _removeFavorite(fav['bookId'] ?? ''),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (fav['bookCover'] ?? '').isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: fav['bookCover'] ?? '',
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 60,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.book,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 80,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.book,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                            title: Text(
                              fav['bookTitle'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fav['bookAuthor'] ?? '',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: AppColors.starGold,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      (fav['bookRating'] ?? 0.0)
                                          .toStringAsFixed(1),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () =>
                                  _removeFavorite(fav['bookId'] ?? ''),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/book-detail',
                                arguments: fav['bookId'],
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
