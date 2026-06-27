class BookEntity {
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

  BookEntity({
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

  BookEntity copyWith({
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
    return BookEntity(
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
}
