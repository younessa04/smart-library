import 'package:flutter/material.dart';
import '../../../domain/entities/book_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _bookRepository;
  final CategoryRepository _categoryRepository;

  BookProvider({
    required BookRepository bookRepository,
    required CategoryRepository categoryRepository,
  })  : _bookRepository = bookRepository,
        _categoryRepository = categoryRepository;

  List<BookEntity> _allBooks = [];
  List<BookEntity> _popularBooks = [];
  List<BookEntity> _newBooks = [];
  List<BookEntity> _topRatedBooks = [];
  List<CategoryEntity> _categories = [];
  BookEntity? _selectedBook;
  bool _isLoading = false;
  String? _error;

  List<BookEntity> get allBooks => _allBooks;
  List<BookEntity> get popularBooks => _popularBooks;
  List<BookEntity> get newBooks => _newBooks;
  List<BookEntity> get topRatedBooks => _topRatedBooks;
  List<CategoryEntity> get categories => _categories;
  BookEntity? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _bookRepository.getAllBooks(),
        _bookRepository.getPopularBooks(),
        _bookRepository.getNewBooks(),
        _bookRepository.getTopRatedBooks(),
        _categoryRepository.getAllCategories(),
      ]);

      _allBooks = results[0] as List<BookEntity>;
      _popularBooks = results[1] as List<BookEntity>;
      _newBooks = results[2] as List<BookEntity>;
      _topRatedBooks = results[3] as List<BookEntity>;
      _categories = results[4] as List<CategoryEntity>;
    } catch (e) {
      _error = 'Erreur de chargement: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBookDetail(String bookId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedBook = await _bookRepository.getBookById(bookId);
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBook(BookEntity book) async {
    try {
      await _bookRepository.addBook(book);
      await loadHomeData();
    } catch (e) {
      _error = 'Erreur d\'ajout: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateBook(BookEntity book) async {
    try {
      await _bookRepository.updateBook(book);
      await loadHomeData();
    } catch (e) {
      _error = 'Erreur de modification: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await _bookRepository.deleteBook(bookId);
      _allBooks.removeWhere((b) => b.id == bookId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur de suppression: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<List<BookEntity>> searchBooks(String query) async {
    if (query.isEmpty) return [];
    return await _bookRepository.searchBooks(query);
  }

  Future<List<BookEntity>> getBooksByCategory(String categoryId) async {
    return await _bookRepository.getBooksByCategory(categoryId);
  }

  Future<void> likeBook(String bookId, String userId) async {
    await _bookRepository.likeBook(bookId, userId);
    await loadBookDetail(bookId);
  }

  Future<void> dislikeBook(String bookId, String userId) async {
    await _bookRepository.dislikeBook(bookId, userId);
    await loadBookDetail(bookId);
  }
}
