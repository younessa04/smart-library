import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

class FirestoreSeeder {
  static Future<void> seedIfEmpty() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Vérifier si les catégories sont vides
      final categoriesSnapshot = await firestore.collection(AppConstants.categoriesCollection).limit(1).get();
      if (categoriesSnapshot.docs.isEmpty) {
        print('Initialisation des catégories dans Firestore...');
        final List<Map<String, dynamic>> defaultCategories = [
          {'name': 'Informatique', 'icon': 'computer', 'bookCount': 0},
          {'name': 'Intelligence Artificielle', 'icon': 'psychology', 'bookCount': 0},
          {'name': 'Data Science', 'icon': 'analytics', 'bookCount': 0},
          {'name': 'Mathématiques', 'icon': 'calculate', 'bookCount': 0},
          {'name': 'Physique', 'icon': 'science', 'bookCount': 0},
          {'name': 'Littérature', 'icon': 'menu_book', 'bookCount': 0},
        ];

        for (var cat in defaultCategories) {
          await firestore.collection(AppConstants.categoriesCollection).add(cat);
        }
      }

      // 2. Vérifier si les livres sont vides
      final booksSnapshot = await firestore.collection(AppConstants.booksCollection).limit(1).get();
      if (booksSnapshot.docs.isEmpty) {
        print('Initialisation des livres de démonstration dans Firestore...');
        
        final List<Map<String, dynamic>> defaultBooks = [
          {
            'title': 'Clean Code',
            'author': 'Robert C. Martin',
            'isbn': '9780132350884',
            'categoryId': '',
            'categoryName': 'Informatique',
            'coverImage': 'https://m.media-amazon.com/images/I/41xShlnv7mL._SX218_BO1,204,203,200_QL40_FMwebp_.jpg',
            'description': 'A handbook of agile software craftsmanship. Even bad code can function. But if code isn\'t clean, it can bring a development organization to its knees.',
            'pages': 464,
            'language': 'Anglais',
            'rating': 4.5,
            'ratingCount': 128,
            'likes': 45,
            'dislikes': 2,
            'available': true,
            'totalCopies': 5,
            'availableCopies': 3,
            'createdAt': Timestamp.now(),
          },
          {
            'title': 'Design Patterns',
            'author': 'Gang of Four',
            'isbn': '9780201633610',
            'categoryId': '',
            'categoryName': 'Informatique',
            'coverImage': 'https://m.media-amazon.com/images/I/51szD9HC9pL._SX395_BO1,204,203,200_.jpg',
            'description': 'Elements of reusable object-oriented software. Capturing a wealth of experience about the design of object-oriented software.',
            'pages': 416,
            'language': 'Anglais',
            'rating': 4.3,
            'ratingCount': 95,
            'likes': 38,
            'dislikes': 3,
            'available': true,
            'totalCopies': 3,
            'availableCopies': 1,
            'createdAt': Timestamp.now(),
          },
          {
            'title': 'Introduction à l\'algorithmique',
            'author': 'Thomas H. Cormen',
            'isbn': '9782100039227',
            'categoryId': '',
            'categoryName': 'Informatique',
            'coverImage': 'https://m.media-amazon.com/images/I/41SNoh5ZhOL._SX258_BO1,204,203,200_.jpg',
            'description': 'Un guide complet sur les algorithmes, couvrant un large éventail de sujets avec des exercices pratiques.',
            'pages': 1312,
            'language': 'Français',
            'rating': 4.7,
            'ratingCount': 203,
            'likes': 89,
            'dislikes': 5,
            'available': true,
            'totalCopies': 8,
            'availableCopies': 5,
            'createdAt': Timestamp.now(),
          },
          {
            'title': 'Physique quantique',
            'author': 'Franck Laloë',
            'isbn': '9782730210720',
            'categoryId': '',
            'categoryName': 'Physique',
            'coverImage': 'https://m.media-amazon.com/images/I/51K8EYQ09KL._SX342_BO1,204,203,200_.jpg',
            'description': 'Une introduction claire et pédagogique à la mécanique quantique.',
            'pages': 580,
            'language': 'Français',
            'rating': 4.0,
            'ratingCount': 42,
            'likes': 15,
            'dislikes': 0,
            'available': true,
            'totalCopies': 4,
            'availableCopies': 4,
            'createdAt': Timestamp.now(),
          },
          {
            'title': 'Les Misérables',
            'author': 'Victor Hugo',
            'isbn': '9782070409068',
            'categoryId': '',
            'categoryName': 'Littérature',
            'coverImage': 'https://m.media-amazon.com/images/I/51C-uLZxOYL._SX301_BO1,204,203,200_.jpg',
            'description': 'Chef-d\'oeuvre de la littérature française, une fresque sociale et historique du XIXe siècle.',
            'pages': 1900,
            'language': 'Français',
            'rating': 4.8,
            'ratingCount': 312,
            'likes': 150,
            'dislikes': 8,
            'available': true,
            'totalCopies': 12,
            'availableCopies': 9,
            'createdAt': Timestamp.now(),
          }
        ];

        // Récupérer les ID générés pour les associer aux livres
        final catsSnapshot = await firestore.collection(AppConstants.categoriesCollection).get();
        final Map<String, String> categoryNameToId = {
          for (var doc in catsSnapshot.docs) doc.data()['name'] as String: doc.id
        };

        for (var book in defaultBooks) {
          final catName = book['categoryName'] as String;
          final catId = categoryNameToId[catName] ?? '';
          book['categoryId'] = catId;
          
          final docRef = await firestore.collection(AppConstants.booksCollection).add(book);
          await docRef.update({'id': docRef.id});

          // Mettre à jour le compteur dans la catégorie
          if (catId.isNotEmpty) {
            await firestore.collection(AppConstants.categoriesCollection).doc(catId).update({
              'bookCount': FieldValue.increment(1)
            });
          }
        }
      }
    } catch (e) {
      print('Erreur lors du peuplement initial : $e');
    }
  }
}
