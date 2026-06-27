import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser != null) {
        return _getUserFromFirestore(firebaseUser.uid);
      }
      return null;
    });
  }

  Future<User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      return _getUserFromFirestore(firebaseUser.uid);
    }
    return null;
  }

  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      return _getUserFromFirestore(credential.user!.uid);
    }
    return null;
  }

  Future<User?> register(User user, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: user.email,
      password: password,
    );
    if (credential.user != null) {
      final newUser = user.copyWith(id: credential.user!.uid);
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toFirestore());
      return newUser;
    }
    return null;
  }

  Future<void> logout() => _auth.signOut();
  Future<void> resetPassword(String email) => _auth.sendPasswordResetEmail(email: email);
  Future<void> verifyEmail() => _auth.currentUser?.sendEmailVerification() ?? Future.value();
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  Future<void> updateUser(User user) async {
    await _firestore.collection('users').doc(user.id).update(user.toFirestore());
  }

  Future<void> updateUserPhoto(String userId, String photoUrl) async {
    await _firestore.collection('users').doc(userId).update({'photo': photoUrl});
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => User.fromFirestore(doc)).toList();
  }

  Future<User?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return User.fromFirestore(doc);
    }
    return null;
  }

  String getAuthErrorMessage(Object e) {
    final code = (e as FirebaseAuthException).code;
    switch (code) {
      case 'user-not-found': return 'Aucun compte trouv\u00e9 avec cet email';
      case 'wrong-password': return 'Mot de passe incorrect';
      case 'email-already-in-use': return 'Cet email est d\u00e9j\u00e0 utilis\u00e9';
      case 'weak-password': return 'Le mot de passe est trop faible';
      case 'invalid-email': return 'Email invalide';
      case 'user-disabled': return 'Ce compte a \u00e9t\u00e9 d\u00e9sactiv\u00e9';
      case 'too-many-requests': return 'Trop de tentatives. R\u00e9essayez plus tard';
      case 'network-request-failed': return 'Erreur de connexion r\u00e9seau';
      default: return 'Erreur d\'authentification: $code';
    }
  }
}
