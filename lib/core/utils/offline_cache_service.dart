import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/book_entity.dart';

/// Offline cache service using Hive
class OfflineCacheService {
  static const String _booksBoxName = 'books_cache';
  static const String _metaBoxName = 'app_meta';

  /// Initialize Hive boxes
  static Future<void> initialize() async {
    await Hive.initFlutter('smart_library');
    await Hive.openBox(_booksBoxName);
    await Hive.openBox(_metaBoxName);
  }

  /// Check if device is online
  static Future<bool> isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Cache books for offline access
  static Future<void> cacheBooks(List<BookEntity> books) async {
    final box = Hive.box(_booksBoxName);
    for (final book in books) {
      await box.put(book.id, jsonEncode(_bookToMap(book)));
    }
    // Save last sync time
    final metaBox = Hive.box(_metaBoxName);
    await metaBox.put('last_books_sync', DateTime.now().toIso8601String());
  }

  /// Get cached books
  static List<BookEntity> getCachedBooks() {
    final box = Hive.box(_booksBoxName);
    final books = <BookEntity>[];
    for (final key in box.keys) {
      try {
        final json = jsonDecode(box.get(key) as String);
        books.add(_bookFromMap(json));
      } catch (e) {
        // Skip invalid entries
      }
    }
    return books;
  }

  /// Get a single cached book
  static BookEntity? getCachedBook(String bookId) {
    final box = Hive.box(_booksBoxName);
    try {
      final json = jsonDecode(box.get(bookId) as String);
      return _bookFromMap(json);
    } catch (e) {
      return null;
    }
  }

  /// Get last sync time
  static DateTime? getLastSyncTime() {
    final metaBox = Hive.box(_metaBoxName);
    final dateStr = metaBox.get('last_books_sync');
    if (dateStr != null) {
      return DateTime.tryParse(dateStr as String);
    }
    return null;
  }

  /// Clear all cached data
  static Future<void> clearCache() async {
    await Hive.box(_booksBoxName).clear();
    await Hive.box(_metaBoxName).clear();
  }

  /// Get cache size info
  static int getCachedBooksCount() {
    return Hive.box(_booksBoxName).length;
  }

  static Map<String, dynamic> _bookToMap(BookEntity book) {
    return {
      'id': book.id,
      'title': book.title,
      'author': book.author,
      'description': book.description,
      'isbn': book.isbn,
      'coverImage': book.coverImage,
      'categoryName': book.categoryName,
      'categoryId': book.categoryId,
      'language': book.language,
      'pages': book.pages,
      'publishDate': book.publishDate?.toIso8601String(),
      'available': book.available,
      'availableCopies': book.availableCopies,
      'totalCopies': book.totalCopies,
      'createdAt': book.createdAt.toIso8601String(),
      'rating': book.rating,
      'ratingCount': book.ratingCount,
      'likes': book.likes,
      'dislikes': book.dislikes,
    };
  }

  static BookEntity _bookFromMap(Map<String, dynamic> map) {
    return BookEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      isbn: map['isbn'] ?? '',
      coverImage: map['coverImage'] ?? '',
      categoryName: map['categoryName'] ?? '',
      categoryId: map['categoryId'] ?? '',
      language: map['language'] ?? '',
      pages: map['pages'] ?? 0,
      publishDate: map['publishDate'] != null ? DateTime.tryParse(map['publishDate'] as String) : null,
      available: map['available'] ?? true,
      availableCopies: map['availableCopies'] ?? 0,
      totalCopies: map['totalCopies'] ?? 0,
      rating: (map['rating'] ?? 0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      likes: map['likes'] ?? 0,
      dislikes: map['dislikes'] ?? 0,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
