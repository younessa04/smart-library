import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/repository_interfaces.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserEntity?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return await _getUserFromFirestore(credential.user!.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> register(UserEntity user, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      if (credential.user != null) {
        final newUser = user.copyWith(id: credential.user!.uid);
        final userModel = UserModel.fromEntity(newUser);
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(credential.user!.uid)
            .set(userModel.toFirestore());
        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> verifyEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user != null) {
        return await _getUserFromFirestore(user.uid);
      }
      return null;
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _getUserFromFirestore(user.uid);
    }
    return null;
  }

  Future<UserEntity?> _getUserFromFirestore(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc).toEntity();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
