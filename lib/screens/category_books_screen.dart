import 'package:flutter/material.dart';
import '../core/widgets/book_card.dart';
import '../core/widgets/loading_widget.dart';
import '../models/book.dart';
import '../services/database_service.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const CategoryBooksScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final _db = DatabaseService();

  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _db.getBooksByCategory(widget.categoryId);
      if (mounted) {
        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement des livres...')
          : _books.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun livre dans cette catégorie',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return BookCard(
                      bookId: book.id,
                      title: book.title,
                      author: book.author,
                      coverImage: book.coverImage,
                      rating: book.rating,
                      available: book.available,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/book-detail',
                          arguments: book.id,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
