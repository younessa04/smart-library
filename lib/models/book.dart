import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String categoryId;
  final String categoryName;
  final String coverImage;
  final String description;
  final DateTime? publishDate;
  final int pages;
  final String language;
  final bool available;
  final double rating;
  final int ratingCount;
  final int likes;
  final int dislikes;
  final int totalCopies;
  final int availableCopies;
  final DateTime createdAt;

  Book({
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

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? categoryId,
    String? categoryName,
    String? coverImage,
    String? description,
    DateTime? publishDate,
    int? pages,
    String? language,
    bool? available,
    double? rating,
    int? ratingCount,
    int? likes,
    int? dislikes,
    int? totalCopies,
    int? availableCopies,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      publishDate: publishDate ?? this.publishDate,
      pages: pages ?? this.pages,
      language: language ?? this.language,
      available: available ?? this.available,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      isbn: data['isbn'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      coverImage: data['coverImage'] ?? '',
      description: data['description'] ?? '',
      publishDate: (data['publishDate'] as Timestamp?)?.toDate(),
      pages: data['pages'] ?? 0,
      language: data['language'] ?? 'Fran\u00e7ais',
      available: data['available'] ?? true,
      rating: (data['rating'] ?? 0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      likes: data['likes'] ?? 0,
      dislikes: data['dislikes'] ?? 0,
      totalCopies: data['totalCopies'] ?? 1,
      availableCopies: data['availableCopies'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'publishDate': publishDate != null ? Timestamp.fromDate(publishDate!) : null,
      'pages': pages,
      'language': language,
      'available': available,
      'rating': rating,
      'ratingCount': ratingCount,
      'likes': likes,
      'dislikes': dislikes,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
