class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email est requis';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation est requise';
    }
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom est requis';
    }
    if (value.length < 2) {
      return 'Nom doit contenir au moins 2 caractères';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Téléphone est requis';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  static String? validateISBN(String? value) {
    if (value == null || value.isEmpty) {
      return 'ISBN est requis';
    }
    final isbnRegex = RegExp(r'^(?:\d{9}[\dX]|\d{13})$');
    if (!isbnRegex.hasMatch(value.replaceAll('-', '').replaceAll(' ', ''))) {
      return 'ISBN invalide';
    }
    return null;
  }

  static String? validatePages(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre de pages est requis';
    }
    final pages = int.tryParse(value);
    if (pages == null || pages <= 0) {
      return 'Nombre de pages invalide';
    }
    return null;
  }
}
