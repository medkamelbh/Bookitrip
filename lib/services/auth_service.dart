import '../models/auth/auth_result.dart';
import '../services/api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ── Login ──────────────────────────────────────────────────────────────────

  Future<AuthResult> login(String email, String password) async {
    try {
      final json = await _apiClient.post(
        '/utilisateur/login',
        body: {'email': email, 'password': password},
      );
      return AuthResult.fromJson(json as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.message.contains('401')) {
        throw AuthException(
          'Identifiants invalides. Vérifiez votre email et mot de passe.',
        );
      }
      throw AuthException(
        'Erreur serveur. Réessayez plus tard.',
      );
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────

  Future<void> register({
    required String name,
    required String prenom,
    required String email,
    required String password,
    required String tel,
    required String ville,
  }) async {
    try {
      await _apiClient.post(
        '/utilisateur/registeruser',
        body: {
          'name': name,
          'prenom': prenom,
          'email': email,
          'password': password,
          'tel': tel,
          'ville': ville,
          'privacy': true,
        },
      );
    } on ApiException catch (e) {
      throw AuthException(
        e.details ?? e.message,
      );
    }
  }

  // ── Password Reset ─────────────────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    try {
      await _apiClient.post(
        '/api/sendReset',
        body: {'email': email},
      );
    } on ApiException {
      throw AuthException(
        'Impossible d\'envoyer le lien de réinitialisation.',
      );
    }
  }
}

// ── Typed exception ─────────────────────────────────────────────────────────

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}