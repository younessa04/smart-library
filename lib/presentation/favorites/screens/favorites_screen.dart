import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../../core/widgets/star_rating.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
        if (userId != null) {
          Provider.of<FavoritesProvider>(context, listen: false).loadFavorites(userId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final favProvider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favProvider.favorites.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: 'Aucun favori',
                  subtitle: 'Ajoutez des livres à vos favoris pour les retrouver ici',
                )
              : RefreshIndicator(
                  onRefresh: () => favProvider.loadFavorites(authProvider.user!.id),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favProvider.favorites.length,
                    itemBuilder: (context, index) {
                      final fav = favProvider.favorites[index];
                      return Dismissible(
                        key: Key(fav.bookId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          favProvider.removeFavorite(authProvider.user!.id, fav.bookId);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: fav.bookCover.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: fav.bookCover,
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                        width: 60, height: 80, color: Colors.grey[300],
                                        child: const Icon(Icons.book, color: Colors.grey),
                                      ),
                                    )
                                  : Container(
                                      width: 60, height: 80, color: Colors.grey[300],
                                      child: const Icon(Icons.book, color: Colors.grey),
                                    ),
                            ),
                            title: Text(fav.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fav.bookAuthor, style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                StarRating(rating: fav.bookRating, size: 14, showValue: true),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.error),
                              onPressed: () {
                                favProvider.removeFavorite(authProvider.user!.id, fav.bookId);
                              },
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: fav.bookId);
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
