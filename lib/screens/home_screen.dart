import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../core/theme/app_colors.dart';

import '../core/widgets/book_card.dart';
import '../core/widgets/state_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _db = DatabaseService();

  List<Book> _allBooks = [];
  List<Book> _popularBooks = [];
  List<Book> _newBooks = [];
  List<Book> _topRatedBooks = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String _userName = 'Utilisateur';
  int _membersCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      final allBooksFuture = _db.getAllBooks();
      final popularFuture = _db.getPopularBooks();
      final newFuture = _db.getNewBooks();
      final topRatedFuture = _db.getTopRatedBooks();
      final categoriesFuture = _db.getAllCategories();
      final membersFuture = _authService.getAllUsers();

      final results = await Future.wait([
        allBooksFuture,
        popularFuture,
        newFuture,
        topRatedFuture,
        categoriesFuture,
        membersFuture,
      ]);

      if (!mounted) return;

      setState(() {
        _userName = user?.firstName ?? 'Utilisateur';
        _allBooks = results[0] as List<Book>;
        _popularBooks = results[1] as List<Book>;
        _newBooks = results[2] as List<Book>;
        _topRatedBooks = results[3] as List<Book>;
        _categories = results[4] as List<Category>;
        _membersCount = (results[5] as List<dynamic>).length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => Navigator.pushNamed(context, '/my-loans'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $_userName !',
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
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
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
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.book,
                      label: 'Livres',
                      value: '${_allBooks.length}',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.category,
                      label: 'Catégories',
                      value: '${_categories.length}',
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: Icons.people,
                      label: 'Membres',
                      value: '$_membersCount',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
              _buildSectionHeader('Livres Populaires', () {
                Navigator.pushNamed(context, '/books');
              }),
              const SizedBox(height: 12),
              if (_popularBooks.isNotEmpty)
                SizedBox(
                  height: 275,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _popularBooks.length,
                    itemBuilder: (context, index) {
                      final book = _popularBooks[index];
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
                              '/book-detail',
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
              _buildSectionHeader('Nouveautés', () {
                Navigator.pushNamed(context, '/books');
              }),
              const SizedBox(height: 12),
              if (_newBooks.isNotEmpty)
                SizedBox(
                  height: 275,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _newBooks.length,
                    itemBuilder: (context, index) {
                      final book = _newBooks[index];
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
                              '/book-detail',
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
              _buildSectionHeader('Les mieux notés', null),
              const SizedBox(height: 12),
              if (_topRatedBooks.isNotEmpty)
                SizedBox(
                  height: 275,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _topRatedBooks.length,
                    itemBuilder: (context, index) {
                      final book = _topRatedBooks[index];
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
                              '/book-detail',
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
                itemCount: _categories.length.clamp(0, 6),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/category-books',
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
