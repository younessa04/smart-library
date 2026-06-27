class LoanEntity {
  final String id;
  final String userId;
  final String userName;
  final String bookId;
  final String bookTitle;
  final String bookCover;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final String status; // pending, approved, rejected, returned, overdue
  final int renewCount;
  final String? qrCode;

  LoanEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookId,
    required this.bookTitle,
    required this.bookCover,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.renewCount = 0,
    this.qrCode,
  });

  bool get isOverdue =>
      status == 'approved' && DateTime.now().isAfter(dueDate);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isReturned => status == 'returned';
  bool get canRenew => renewCount < 2 && status == 'approved';

  int get daysRemaining => dueDate.difference(DateTime.now()).inDays;

  LoanEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? bookId,
    String? bookTitle,
    String? bookCover,
    DateTime? borrowDate,
    DateTime? dueDate,
    DateTime? returnDate,
    String? status,
    int? renewCount,
    String? qrCode,
  }) {
    return LoanEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookCover: bookCover ?? this.bookCover,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      renewCount: renewCount ?? this.renewCount,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}
