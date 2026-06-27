import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../books/providers/book_provider.dart';
import '../../auth/providers/auth_provider.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
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
    final bookProvider = Provider.of<BookProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres'),
        actions: [
          if (authProvider.isManager)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.addEditBook);
              },
            ),
        ],
      ),
      body: bookProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookProvider.allBooks.isEmpty
              ? const EmptyStateWidget(
                  icon: Icons.book_outlined,
                  title: 'Aucun livre disponible',
                  subtitle: 'Les livres ajoutés apparaîtront ici',
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: bookProvider.allBooks.length,
                  itemBuilder: (context, index) {
                    final book = bookProvider.allBooks[index];
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
                          AppRoutes.bookDetail,
                          arguments: book.id,
                        );
                      },
                    );
                  },
                ),
    );
  }
}
