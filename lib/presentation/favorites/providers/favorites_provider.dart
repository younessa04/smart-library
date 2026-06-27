import 'package:flutter/material.dart';
import '../../../domain/entities/favorite_notification_entity.dart';
import '../../../domain/entities/book_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;

  FavoritesProvider({required FavoriteRepository favoriteRepository})
      : _favoriteRepository = favoriteRepository;

  List<FavoriteEntity> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<FavoriteEntity> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _favorites = await _favoriteRepository.getUserFavorites(userId);
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String userId, BookEntity book) async {
    try {
      final isFav = await _favoriteRepository.isFavorite(userId, book.id);
      if (isFav) {
        await _favoriteRepository.removeFavorite(userId, book.id);
        _favorites.removeWhere((f) => f.bookId == book.id);
      } else {
        final favorite = FavoriteEntity(
          id: '',
          userId: userId,
          bookId: book.id,
          bookTitle: book.title,
          bookAuthor: book.author,
          bookCover: book.coverImage,
          bookRating: book.rating,
          addedAt: DateTime.now(),
        );
        await _favoriteRepository.addFavorite(favorite);
        _favorites.insert(0, favorite);
      }
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String userId, String bookId) async {
    try {
      await _favoriteRepository.removeFavorite(userId, bookId);
      _favorites.removeWhere((f) => f.bookId == bookId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<bool> isFavorite(String userId, String bookId) async {
    return await _favoriteRepository.isFavorite(userId, bookId);
  }
}
