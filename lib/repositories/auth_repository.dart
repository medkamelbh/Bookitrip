import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth/auth_result.dart';
import '../models/auth/user_model.dart';
import '../models/user_reservation.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthRepository {
  static const String _tokenKey = 'jwt_token';

  final AuthService _authService;
  final UserService _userService;
  final FlutterSecureStorage _storage;

  AuthRepository({
    AuthService? authService,
    UserService? userService,
    FlutterSecureStorage? storage,
  })  : _authService = authService ?? AuthService(),
        _userService = userService ?? UserService(),
        _storage = storage ?? const FlutterSecureStorage();

  // ── Token Management ───────────────────────────────────────────────────────

  Future<String?> getToken() => _storage.read(key: _tokenKey);

  Future<void> _saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);

  // ── Auth Operations ────────────────────────────────────────────────────────

  /// Login and persist the JWT token. Returns the authenticated user.
  Future<UserModel> login(String email, String password) async {
    final AuthResult result = await _authService.login(email, password);
    await _saveToken(result.token);
    return result.user;
  }

  /// Register a new account. No token is returned — user must login separately.
  Future<void> register({
    required String name,
    required String prenom,
    required String email,
    required String password,
    required String tel,
    required String ville,
  }) async {
    await _authService.register(
      name: name,
      prenom: prenom,
      email: email,
      password: password,
      tel: tel,
      ville: ville,
    );
  }

  /// Restore a previously saved session. Returns null if no valid token.
  Future<UserModel?> restoreSession() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return null;
    try {
      return await _userService.getProfile(token);
    } on AuthException {
      // Token is invalid or expired — clean up
      await clearToken();
      return null;
    } catch (_) {
      // Network error — don't clear the token, might be temporary
      return null;
    }
  }

  /// Clear token and log out.
  Future<void> logout() => clearToken();

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordReset(email);

  // ── Protected Operations ───────────────────────────────────────────────────

  Future<UserModel> getProfile() async {
    final token = await _requireToken();
    return _userService.getProfile(token);
  }

  Future<UserModel> updateProfile({
    required String name,
    required String prenom,
    String? phone,
    String? city,
    String? country,
  }) async {
    final token = await _requireToken();
    return _userService.updateProfile(
      token,
      name: name,
      prenom: prenom,
      phone: phone,
      city: city,
      country: country,
    );
  }

  Future<void> changePassword(String password, String confirmation) async {
    final token = await _requireToken();
    return _userService.changePassword(token, password, confirmation);
  }

  Future<List<UserReservation>> getHotelReservations() async {
    final token = await _requireToken();
    return _userService.getHotelReservations(token);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<String> _requireToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Vous devez être connecté pour effectuer cette action.');
    }
    return token;
  }
}
