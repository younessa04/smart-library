import 'package:flutter/material.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/repository_interfaces.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  needsVerification,
}

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthProvider({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository {
    _initAuth();
  }

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isManager => _user?.isManager ?? false;
  bool get isStudent => _user?.isStudent ?? false;

  Future<void> _initAuth() async {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _user = null;
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });

    // Check current user
    final currentUser = await _authRepository.getCurrentUser();
    if (currentUser != null) {
      _user = currentUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(email, password);
      if (_user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Échec de connexion';
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Une erreur est survenue: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String studyLevel,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = UserEntity(
        id: '',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        studyLevel: studyLevel,
        registrationDate: DateTime.now(),
        role: 'student',
      );

      _user = await _authRepository.register(newUser, password);

      if (_user != null) {
        await _authRepository.verifyEmail();
        _status = AuthStatus.needsVerification;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'Échec d\'inscription';
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Une erreur est survenue: ${e.toString()}';
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.resetPassword(email);
    } catch (e) {
      _errorMessage = 'Erreur: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> verifyEmail() async {
    try {
      final verified = await _authRepository.isEmailVerified();
      if (verified) {
        _user = await _authRepository.getCurrentUser();
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur de vérification';
      notifyListeners();
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _authRepository.verifyEmail();
    } catch (e) {
      _errorMessage = 'Erreur d\'envoi de l\'email';
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_user != null) {
      _user = await _userRepository.getUserById(_user!.id);
      notifyListeners();
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      case 'network-request-failed':
        return 'Erreur de connexion réseau';
      default:
        return 'Erreur d\'authentification: $code';
    }
  }
}
