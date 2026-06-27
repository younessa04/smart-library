import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../books/providers/book_provider.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const CategoryBooksScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: FutureBuilder(
        future: Provider.of<BookProvider>(context, listen: false).getBooksByCategory(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final books = snapshot.data ?? [];
          if (books.isEmpty) {
            return const EmptyStateWidget(icon: Icons.book_outlined, title: 'Aucun livre dans cette catégorie');
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                bookId: book.id,
                title: book.title,
                author: book.author,
                coverImage: book.coverImage,
                rating: book.rating,
                available: book.available,
                onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book.id),
              );
            },
          );
        },
      ),
    );
  }
}
