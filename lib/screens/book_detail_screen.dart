import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/star_rating.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/utils/formatters.dart';
import '../models/book.dart';
import '../models/comment.dart';
import '../models/loan.dart';
import '../models/reservation.dart';
import '../models/user.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;
  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _db = DatabaseService();
  final _authService = AuthService();

  Book? _book;
  User? _user;
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _commentsLoading = false;
  final _commentController = TextEditingController();
  int _myRating = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      final book = await _db.getBookById(widget.bookId);
      List<Comment> comments = [];
      bool isFav = false;
      if (book != null) {
        comments = await _db.getBookComments(widget.bookId);
        if (user != null) {
          isFav = await _db.isFavorite(user.id, widget.bookId);
        }
      }
      if (mounted) {
        setState(() {
          _user = user;
          _book = book;
          _comments = comments;
          _isFavorite = isFav;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadComments() async {
    setState(() => _commentsLoading = true);
    try {
      final comments = await _db.getBookComments(widget.bookId);
      if (mounted) setState(() => _comments = comments);
    } catch (_) {}
    if (mounted) setState(() => _commentsLoading = false);
  }

  Future<void> _likeBook() async {
    await _db.likeBook(widget.bookId);
    final book = await _db.getBookById(widget.bookId);
    if (mounted && book != null) setState(() => _book = book);
  }

  Future<void> _dislikeBook() async {
    await _db.dislikeBook(widget.bookId);
    final book = await _db.getBookById(widget.bookId);
    if (mounted && book != null) setState(() => _book = book);
  }

  Future<void> _toggleFavorite() async {
    if (_user == null) return;
    if (_isFavorite) {
      await _db.removeFavorite(_user!.id, widget.bookId);
    } else {
      await _db.addFavorite(
        _user!.id,
        widget.bookId,
        _book!.title,
        _book!.author,
        _book!.coverImage,
        _book!.rating,
      );
    }
    if (mounted) {
      setState(() => _isFavorite = !_isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Ajouté aux favoris' : 'Retiré des favoris'),
          backgroundColor:
              _isFavorite ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty || _user == null) return;
    final comment = Comment(
      id: '',
      userId: _user!.id,
      userName: _user!.fullName,
      userPhoto: _user!.photo,
      bookId: widget.bookId,
      text: _commentController.text.trim(),
      rating: _myRating,
      date: DateTime.now(),
    );
    await _db.addComment(comment);
    _commentController.clear();
    setState(() => _myRating = 0);
    await _loadComments();
  }

  Future<void> _borrowBook() async {
    if (_user == null || _book == null) return;
    final loan = Loan(
      id: '',
      userId: _user!.id,
      userName: _user!.fullName,
      bookId: _book!.id,
      bookTitle: _book!.title,
      bookCover: _book!.coverImage,
      borrowDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 14)),
      status: 'pending',
    );
    try {
      await _db.requestLoan(loan);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Demande d'emprunt envoyée"),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _reserveBook() async {
    if (_user == null || _book == null) return;
    final reservation = Reservation(
      id: '',
      userId: _user!.id,
      userName: _user!.fullName,
      bookId: _book!.id,
      bookTitle: _book!.title,
      bookCover: _book!.coverImage,
      date: DateTime.now(),
      status: 'active',
    );
    try {
      await _db.createReservation(reservation);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation effectuée'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteBook() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Supprimer ce livre ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true && _book != null) {
      await _db.deleteBook(_book!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _book == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final book = _book!;
    final isManager = _user?.isManager ?? false;
    final isStudent = _user?.isStudent ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'book_cover_${book.id}',
                child: book.coverImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: book.coverImage,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.book, size: 80),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.book, size: 80),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(book.author,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      StarRating(rating: book.rating, showValue: true),
                      const SizedBox(width: 16),
                      Text('(${book.ratingCount} avis)',
                          style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(Icons.category, book.categoryName),
                      _buildInfoChip(Icons.language, book.language),
                      _buildInfoChip(Icons.pages, '${book.pages}p'),
                      if (book.isbn.isNotEmpty)
                        _buildInfoChip(Icons.qr_code, book.isbn),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: book.available
                          ? AppColors.success.withOpacity(0.1)
                          : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      book.available
                          ? 'Disponible (${book.availableCopies})'
                          : 'Indisponible',
                      style: TextStyle(
                        color: book.available
                            ? AppColors.success
                            : AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _likeBook,
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        color: AppColors.likeGreen,
                      ),
                      Text('${book.likes}'),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: _dislikeBook,
                        icon: const Icon(Icons.thumb_down_alt_outlined),
                        color: AppColors.dislikeRed,
                      ),
                      Text('${book.dislikes}'),
                      const Spacer(),
                      IconButton(
                        onPressed: _toggleFavorite,
                        icon: Icon(_isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(book.description,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey[700])),
                  const SizedBox(height: 20),
                  if (book.available && isStudent)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Emprunter',
                            icon: Icons.book_online,
                            onPressed: _borrowBook,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Réserver',
                            icon: Icons.bookmark_add_outlined,
                            isOutlined: true,
                            onPressed: _reserveBook,
                          ),
                        ),
                      ],
                    ),
                  if (isManager)
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Modifier',
                            icon: Icons.edit,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/add-edit-book',
                                arguments: book.id,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Supprimer',
                            icon: Icons.delete,
                            backgroundColor: AppColors.error,
                            onPressed: _deleteBook,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Commentaires',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_user != null) ...[
                    InteractiveStarRating(
                      initialRating: _myRating,
                      onRate: (r) => setState(() => _myRating = r),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: _commentController,
                            label: '',
                            hint: 'Votre commentaire...',
                            maxLines: 2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_commentsLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_comments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Aucun commentaire',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    )
                  else
                    ...(_comments.map((c) => _buildCommentTile(c))),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage:
                      (comment.userPhoto != null && comment.userPhoto!.isNotEmpty)
                          ? CachedNetworkImageProvider(comment.userPhoto!)
                          : null,
                  child: (comment.userPhoto == null ||
                          comment.userPhoto!.isEmpty)
                      ? Text(comment.userName[0].toUpperCase())
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(Formatters.formatRelativeDate(comment.date),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                if (comment.rating > 0)
                  StarRating(rating: comment.rating.toDouble(), size: 12),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.text, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
