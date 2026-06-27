import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/book_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/repository_interfaces.dart';
import '../models/book_model.dart';
import '../models/user_model.dart';
import '../models/other_models.dart';

// Book Repository Implementation
class BookRepositoryImpl implements BookRepository {
  final CollectionReference _booksRef =
      FirebaseFirestore.instance.collection(AppConstants.booksCollection);

  @override
  Future<List<BookEntity>> getAllBooks() async {
    final snapshot = await _booksRef.get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<BookEntity?> getBookById(String id) async {
    final doc = await _booksRef.doc(id).get();
    if (doc.exists) {
      return BookModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  @override
  Future<void> addBook(BookEntity book) async {
    final model = BookModel.fromEntity(book);
    final data = model.toFirestore();
    data.remove('id');
    final docRef = await _booksRef.add(data);
    await _booksRef.doc(docRef.id).update({'id': docRef.id});
  }

  @override
  Future<void> updateBook(BookEntity book) async {
    final model = BookModel.fromEntity(book);
    await _booksRef.doc(book.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteBook(String id) async {
    await _booksRef.doc(id).delete();
  }

  @override
  Future<List<BookEntity>> searchBooks(String query) async {
    final allBooks = await getAllBooks();
    final lowerQuery = query.toLowerCase();
    return allBooks.where((book) {
      return book.title.toLowerCase().contains(lowerQuery) ||
          book.author.toLowerCase().contains(lowerQuery) ||
          book.isbn.toLowerCase().contains(lowerQuery) ||
          book.categoryName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<BookEntity>> getBooksByCategory(String categoryId) async {
    final snapshot = await _booksRef
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<List<BookEntity>> getPopularBooks() async {
    final allBooks = await getAllBooks();
    allBooks.sort((a, b) => b.likes.compareTo(a.likes));
    return allBooks.take(10).toList();
  }

  @override
  Future<List<BookEntity>> getNewBooks() async {
    final snapshot = await _booksRef
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<List<BookEntity>> getTopRatedBooks() async {
    final snapshot = await _booksRef
        .orderBy('rating', descending: true)
        .limit(10)
        .get();
    return snapshot.docs.map((doc) => BookModel.fromFirestore(doc).toEntity()).toList();
  }

  @override
  Future<void> likeBook(String bookId, String userId) async {
    await _booksRef.doc(bookId).update({
      'likes': FieldValue.increment(1),
    });
  }

  @override
  Future<void> dislikeBook(String bookId, String userId) async {
    await _booksRef.doc(bookId).update({
      'dislikes': FieldValue.increment(1),
    });
  }

  @override
  Stream<List<BookEntity>> watchBooks() {
    return _booksRef.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc).toEntity())
          .toList(),
    );
  }
}

// Category Repository Implementation
class CategoryRepositoryImpl implements CategoryRepository {
  final CollectionReference _categoriesRef =
      FirebaseFirestore.instance.collection(AppConstants.categoriesCollection);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    final snapshot = await _categoriesRef.get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Future<void> addCategory(CategoryEntity category) async {
    await _categoriesRef.add(CategoryModel.toFirestore(category));
  }

  @override
  Future<void> updateCategory(CategoryEntity category) async {
    await _categoriesRef.doc(category.id).update(CategoryModel.toFirestore(category));
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _categoriesRef.doc(id).delete();
  }
}

// User Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection(AppConstants.usersCollection);

  @override
  Future<UserEntity?> getUserById(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc).toEntity();
    }
    return null;
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final model = UserModel.fromEntity(user);
    await _usersRef.doc(user.id).update(model.toFirestore());
  }

  @override
  Future<void> updateUserPhoto(String userId, String photoUrl) async {
    await _usersRef.doc(userId).update({'photo': photoUrl});
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final snapshot = await _usersRef.get();
    return snapshot.docs
        .map((doc) => UserModel.fromFirestore(doc).toEntity())
        .toList();
  }

  @override
  Stream<UserEntity?> watchUser(String userId) {
    return _usersRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc).toEntity();
      }
      return null;
    });
  }

  @override
  Future<void> addPoints(String userId, int points) async {
    await _usersRef.doc(userId).update({
      'points': FieldValue.increment(points),
    });
  }

  @override
  Future<void> addBadge(String userId, String badge) async {
    await _usersRef.doc(userId).update({
      'badges': FieldValue.arrayUnion([badge]),
    });
  }
}
