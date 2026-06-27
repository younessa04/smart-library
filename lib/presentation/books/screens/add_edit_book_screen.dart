import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../domain/entities/book_entity.dart';
import '../../books/providers/book_provider.dart';

class AddEditBookScreen extends StatefulWidget {
  final String? bookId;
  const AddEditBookScreen({super.key, this.bookId});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pagesController = TextEditingController();
  final _coverController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCategoryName;
  String _selectedLanguage = 'Français';
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    _pagesController.dispose();
    _coverController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final book = BookEntity(
        id: widget.bookId ?? '',
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        isbn: _isbnController.text.trim(),
        categoryId: _selectedCategory ?? '',
        categoryName: _selectedCategoryName ?? '',
        coverImage: _coverController.text.trim(),
        description: _descriptionController.text.trim(),
        pages: int.parse(_pagesController.text),
        language: _selectedLanguage,
        available: true,
        totalCopies: 1,
        availableCopies: 1,
        createdAt: DateTime.now(),
      );

      if (widget.bookId != null) {
        await bookProvider.updateBook(book.copyWith(id: widget.bookId!));
      } else {
        await bookProvider.addBook(book);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.bookId != null ? 'Livre modifié' : 'Livre ajouté'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.error),
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
        title: Text(widget.bookId != null ? 'Modifier le livre' : 'Ajouter un livre'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _titleController, label: 'Titre', prefixIcon: Icons.title, validator: (v) => Validators.validateRequired(v, 'Titre')),
              const SizedBox(height: 16),
              CustomTextField(controller: _authorController, label: 'Auteur', prefixIcon: Icons.person, validator: (v) => Validators.validateRequired(v, 'Auteur')),
              const SizedBox(height: 16),
              CustomTextField(controller: _isbnController, label: 'ISBN', prefixIcon: Icons.numbers, validator: Validators.validateISBN),
              const SizedBox(height: 16),
              CustomTextField(controller: _coverController, label: 'URL de couverture', prefixIcon: Icons.image, hint: 'https://...'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Catégorie', prefixIcon: Icon(Icons.category)),
                items: AppConstants.defaultCategories.map<DropdownMenuItem<String>>((c) {
                  return DropdownMenuItem<String>(value: c['name'] as String, child: Text(c['name'] as String));
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v;
                    _selectedCategoryName = v;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                decoration: const InputDecoration(labelText: 'Langue', prefixIcon: Icon(Icons.language)),
                items: AppConstants.languages.map((l) {
                  return DropdownMenuItem(value: l, child: Text(l));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedLanguage = v);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(controller: _pagesController, label: 'Nombre de pages', prefixIcon: Icons.pages, keyboardType: TextInputType.number, validator: Validators.validatePages),
              const SizedBox(height: 16),
              CustomTextField(controller: _descriptionController, label: 'Description', prefixIcon: Icons.description, maxLines: 5, validator: (v) => Validators.validateRequired(v, 'Description')),
              const SizedBox(height: 24),
              CustomButton(text: widget.bookId != null ? 'Modifier' : 'Ajouter', onPressed: _save, isLoading: _isSaving, width: double.infinity, icon: Icons.save),
            ],
          ),
        ),
      ),
    );
  }
}
