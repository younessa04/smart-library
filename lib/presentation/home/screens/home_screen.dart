import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../books/providers/book_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        Provider.of<BookProvider>(context, listen: false).loadHomeData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.myLoans);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => bookProvider.loadHomeData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome
              Text(
                'Bonjour, ${authProvider.user?.firstName ?? 'Utilisateur'} !',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Que souhaitez-vous lire aujourd\'hui ?',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),

              // Search bar
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[500]),
                      const SizedBox(width: 12),
                      Text(
                        'Rechercher un livre...',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Statistics
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.book,
                      label: 'Livres',
                      value: '${bookProvider.allBooks.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.category,
                      label: 'Catégories',
                      value: '${bookProvider.categories.length}',
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.people,
                      label: 'Membres',
                      value: '--',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Promotional Slider
              Container(
                height: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_stories, size: 48, color: Colors.white),
                      const SizedBox(height: 8),
                      const Text(
                        'Bienvenue à Smart Library',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Découvrez des milliers de livres',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Popular Books
              _buildSectionHeader('Livres Populaires', () {
                Navigator.pushNamed(context, AppRoutes.bookList);
              }),
              const SizedBox(height: 12),
              if (bookProvider.popularBooks.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookProvider.popularBooks.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.popularBooks[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: HorizontalBookCard(
                          bookId: book.id,
                          title: book.title,
                          author: book.author,
                          coverImage: book.coverImage,
                          rating: book.rating,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.bookDetail,
                              arguments: book.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('Aucun livre disponible')),
                ),
              const SizedBox(height: 24),

              // New Arrivals
              _buildSectionHeader('Nouveautés', () {
                Navigator.pushNamed(context, AppRoutes.bookList);
              }),
              const SizedBox(height: 12),
              if (bookProvider.newBooks.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookProvider.newBooks.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.newBooks[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: HorizontalBookCard(
                          bookId: book.id,
                          title: book.title,
                          author: book.author,
                          coverImage: book.coverImage,
                          rating: book.rating,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.bookDetail,
                              arguments: book.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('Aucune nouveauté')),
                ),
              const SizedBox(height: 24),

              // Top Rated
              _buildSectionHeader('Les mieux notés', null),
              const SizedBox(height: 12),
              if (bookProvider.topRatedBooks.isNotEmpty)
                SizedBox(
                  height: 260,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: bookProvider.topRatedBooks.length,
                    itemBuilder: (context, index) {
                      final book = bookProvider.topRatedBooks[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: HorizontalBookCard(
                          bookId: book.id,
                          title: book.title,
                          author: book.author,
                          coverImage: book.coverImage,
                          rating: book.rating,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.bookDetail,
                              arguments: book.id,
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                const SizedBox(
                  height: 100,
                  child: Center(child: Text('Aucun livre noté')),
                ),
              const SizedBox(height: 24),

              // Categories
              _buildSectionHeader('Catégories', null),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: bookProvider.categories.length.clamp(0, 6),
                itemBuilder: (context, index) {
                  final category = bookProvider.categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.categoryBooks,
                        arguments: {
                          'categoryId': category.id,
                          'categoryName': category.name,
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(category.iconData, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              category.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Voir tout'),
          ),
      ],
    );
  }
}
