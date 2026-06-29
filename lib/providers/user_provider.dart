import 'package:flutter/foundation.dart';
import '../models/auth/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

enum UserProfileStatus { idle, loading, success, error }

class UserProvider with ChangeNotifier {
  final AuthRepository _repository;
  final AuthProvider _authProvider;

  UserProvider(this._repository, this._authProvider);

  UserProfileStatus _status = UserProfileStatus.idle;
  UserProfileStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == UserProfileStatus.loading;

  // ── Update Profile ─────────────────────────────────────────────────────────

  Future<bool> updateProfile({
    required String name,
    required String prenom,
    String? phone,
    String? city,
    String? country,
  }) async {
    _status = UserProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _repository.updateProfile(
        name: name,
        prenom: prenom,
        phone: phone,
        city: city,
        country: country,
      );
      // Propagate the update back to AuthProvider so drawer updates too
      _authProvider.updateCurrentUser(updatedUser);
      _status = UserProfileStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = UserProfileStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur réseau. Réessayez.';
      _status = UserProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Change Password ────────────────────────────────────────────────────────

  Future<bool> changePassword(String password, String confirmation) async {
    if (password != confirmation) {
      _errorMessage = 'Les mots de passe ne correspondent pas.';
      _status = UserProfileStatus.error;
      notifyListeners();
      return false;
    }

    _status = UserProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.changePassword(password, confirmation);
      _status = UserProfileStatus.success;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = UserProfileStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors du changement de mot de passe.';
      _status = UserProfileStatus.error;
      notifyListeners();
      return false;
    }
  }

  void clearStatus() {
    _status = UserProfileStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
