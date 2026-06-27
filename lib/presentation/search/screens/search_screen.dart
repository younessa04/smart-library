import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/widgets/book_card.dart';
import '../../../core/widgets/state_widgets.dart';
import '../../books/providers/book_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    final results = await bookProvider.searchBooks(query);
    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par titre, auteur, ISBN...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _search(''); })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _search,
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(label: const Text('Disponible'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Populaire'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Récent'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Mieux noté'), selected: false, onSelected: (_) {}),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const EmptyStateWidget(icon: Icons.search_off, title: 'Aucun résultat', subtitle: 'Recherchez par titre, auteur ou ISBN')
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.6, crossAxisSpacing: 12, mainAxisSpacing: 12,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final book = _results[index];
                          return BookCard(
                            bookId: book.id, title: book.title, author: book.author,
                            coverImage: book.coverImage, rating: book.rating, available: book.available,
                            onTap: () => Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book.id),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
