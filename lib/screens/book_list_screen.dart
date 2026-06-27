import 'package:flutter/material.dart';
import '../core/widgets/book_card.dart';
import '../core/widgets/loading_widget.dart';
import '../models/book.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final _db = DatabaseService();
  final _authService = AuthService();

  List<Book> _books = [];
  bool _isLoading = true;
  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      final books = await _db.getAllBooks();
      if (mounted) {
        setState(() {
          _books = books;
          _isManager = user?.isManager ?? false;
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
      appBar: AppBar(
        title: const Text('Livres'),
        actions: [
          if (_isManager)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add-edit-book');
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget(message: 'Chargement des livres...')
          : _books.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Aucun livre disponible',
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('Les livres ajoutés apparaîtront ici',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: GridView.builder(
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
                ),
    );
  }
}
