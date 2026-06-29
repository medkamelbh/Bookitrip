import 'package:flutter/foundation.dart';
import '../models/auth/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository);

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Session Restore ────────────────────────────────────────────────────────

  /// Called once at app startup (from SplashScreen or main).
  Future<void> checkSession() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final user = await _repository.restoreSession();

    if (user != null) {
      _currentUser = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repository.login(email, password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[AuthProvider.login] Unexpected error: $e');
      _errorMessage = 'Erreur réseau. Vérifiez votre connexion internet.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<bool> register({
    required String name,
    required String prenom,
    required String email,
    required String password,
    required String tel,
    required String ville,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.register(
        name: name,
        prenom: prenom,
        email: email,
        password: password,
        tel: tel,
        ville: ville,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('[AuthProvider.register] Unexpected error: $e');
      _errorMessage = 'Erreur réseau. Vérifiez votre connexion internet.';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _repository.sendPasswordReset(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── User Update (called by UserProvider after profile edit) ────────────────

  void updateCurrentUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
