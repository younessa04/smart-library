import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/book_entity.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String categoryId;
  final String categoryName;
  final String coverImage;
  final String description;
  final Timestamp? publishDate;
  final int pages;
  final String language;
  final bool available;
  final double rating;
  final int ratingCount;
  final int likes;
  final int dislikes;
  final int totalCopies;
  final int availableCopies;
  final Timestamp createdAt;

  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.categoryId,
    required this.categoryName,
    required this.coverImage,
    required this.description,
    this.publishDate,
    required this.pages,
    required this.language,
    this.available = true,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.likes = 0,
    this.dislikes = 0,
    this.totalCopies = 1,
    this.availableCopies = 1,
    required this.createdAt,
  });

  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      coverImage: data['coverImage'] ?? '',
      description: data['description'] ?? '',
      publishDate: data['publishDate'] as Timestamp?,
      pages: data['pages'] ?? 0,
      language: data['language'] ?? 'Français',
      available: data['available'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      totalCopies: data['totalCopies'] ?? 1,
      availableCopies: data['availableCopies'] ?? 1,
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'coverImage': coverImage,
      'description': description,
      'publishDate': publishDate,
      'pages': pages,
      'language': language,
      'available': available,
      'rating': rating,
      'ratingCount': ratingCount,
      'likes': likes,
      'dislikes': dislikes,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'createdAt': createdAt,
    };
  }

  BookEntity toEntity() {
    return BookEntity(
      id: id,
      title: title,
      author: author,
      isbn: isbn,
      categoryId: categoryId,
      categoryName: categoryName,
      coverImage: coverImage,
      description: description,
      publishDate: publishDate?.toDate(),
      pages: pages,
      language: language,
      available: available,
      rating: rating,
      ratingCount: ratingCount,
      likes: likes,
      dislikes: dislikes,
      totalCopies: totalCopies,
      availableCopies: availableCopies,
      createdAt: createdAt.toDate(),
    );
  }

  factory BookModel.fromEntity(BookEntity entity) {
    return BookModel(
      id: entity.id,
      title: entity.title,
      author: entity.author,
      isbn: entity.isbn,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      coverImage: entity.coverImage,
      description: entity.description,
      publishDate: entity.publishDate != null ? Timestamp.fromDate(entity.publishDate!) : null,
      pages: entity.pages,
      language: entity.language,
      available: entity.available,
      rating: entity.rating,
      ratingCount: entity.ratingCount,
      likes: entity.likes,
      dislikes: entity.dislikes,
      totalCopies: entity.totalCopies,
      availableCopies: entity.availableCopies,
      createdAt: Timestamp.fromDate(entity.createdAt),
    );
  }
}
