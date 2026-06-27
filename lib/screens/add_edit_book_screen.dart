import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/validators.dart';
import '../core/constants/app_constants.dart';
import '../core/widgets/custom_text_field.dart';
import '../core/widgets/custom_button.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../services/database_service.dart';

class AddEditBookScreen extends StatefulWidget {
  final String? bookId;
  const AddEditBookScreen({super.key, this.bookId});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _db = DatabaseService();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pagesController = TextEditingController();
  final _coverController = TextEditingController();
  final _copiesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCategoryName;
  String _selectedLanguage = 'Français';
  List<Category> _categories = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _pagesController.dispose();
    _coverController.dispose();
    _copiesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _db.getAllCategories();
      Book? existingBook;
      if (widget.bookId != null) {
        existingBook = await _db.getBookById(widget.bookId!);
      }
      if (mounted) {
        setState(() {
          _categories = categories;
          if (existingBook != null) {
            _titleController.text = existingBook.title;
            _authorController.text = existingBook.author;
            _isbnController.text = existingBook.isbn;
            _descriptionController.text = existingBook.description;
            _pagesController.text = existingBook.pages.toString();
            _coverController.text = existingBook.coverImage;
            _copiesController.text = existingBook.totalCopies.toString();
            _selectedCategory = existingBook.categoryId;
            _selectedCategoryName = existingBook.categoryName;
            _selectedLanguage = existingBook.language;
          } else {
            _copiesController.text = '1';
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final book = Book(
        id: widget.bookId ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        categoryId: _selectedCategory ?? '',
        categoryName: _selectedCategoryName ?? '',
        coverImage: _coverController.text.trim(),
        description: _descriptionController.text.trim(),
        pages: int.tryParse(_pagesController.text) ?? 0,
        language: _selectedLanguage,
        totalCopies: int.tryParse(_copiesController.text) ?? 1,
        availableCopies: int.tryParse(_copiesController.text) ?? 1,
        createdAt: DateTime.now(),
      );
      if (widget.bookId != null) {
        await _db.updateBook(book);
      } else {
        await _db.addBook(book);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.bookId != null ? 'Livre modifié' : 'Livre ajouté'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
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
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.bookId != null ? 'Modifier le livre' : 'Ajouter un livre'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Titre',
                      prefixIcon: Icons.title,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Titre'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _authorController,
                      label: 'Auteur',
                      prefixIcon: Icons.person,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Auteur'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _isbnController,
                      label: 'ISBN',
                      prefixIcon: Icons.numbers,
                      validator: Validators.validateISBN,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _coverController,
                      label: 'URL de couverture',
                      prefixIcon: Icons.image,
                      hint: 'https://...',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map<DropdownMenuItem<String>>((c) {
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _selectedCategory = v;
                            _selectedCategoryName = _categories
                                .firstWhere((c) => c.id == v)
                                .name;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Langue',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: AppConstants.languages.map((l) {
                        return DropdownMenuItem(value: l, child: Text(l));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedLanguage = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _pagesController,
                      label: 'Nombre de pages',
                      prefixIcon: Icons.pages,
                      keyboardType: TextInputType.number,
                      validator: Validators.validatePages,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _copiesController,
                      label: 'Nombre d\'exemplaires',
                      prefixIcon: Icons.content_copy,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Exemplaires'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      prefixIcon: Icons.description,
                      maxLines: 5,
                      validator: (v) =>
                          Validators.validateRequired(v, 'Description'),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: widget.bookId != null ? 'Modifier' : 'Ajouter',
                      onPressed: _save,
                      isLoading: _isSaving,
                      width: double.infinity,
                      icon: Icons.save,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
