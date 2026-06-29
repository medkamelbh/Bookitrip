import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth/user_model.dart';
import '../models/user_reservation.dart';
import 'auth_service.dart';

class UserService {
  static const String _baseUrl = 'https://test.tunisiagotravel.com';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Get Profile ────────────────────────────────────────────────────────────

  Future<UserModel> getProfile(String token) async {
    final uri = Uri.parse('$_baseUrl/api/dashbord/user/profil');
    final response = await _client
        .get(uri, headers: _authHeaders(token))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final userData = json is Map && json.containsKey('user')
          ? json['user'] as Map<String, dynamic>
          : json as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } else if (response.statusCode == 401) {
      throw AuthException('Session expirée. Veuillez vous reconnecter.');
    } else {
      throw AuthException('Erreur lors du chargement du profil.');
    }
  }

  // ── Update Profile ─────────────────────────────────────────────────────────

  Future<UserModel> updateProfile(
    String token, {
    required String name,
    required String prenom,
    String? phone,
    String? city,
    String? country,
    File? photo,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/dashbord/user/profil');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['prenom'] = prenom;
    if (phone != null) request.fields['phone'] = phone;
    if (city != null) request.fields['city'] = city;
    if (country != null) request.fields['country'] = country;

    if (photo != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path,
          filename: 'profile.jpg'));
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final userData = json is Map && json.containsKey('user')
          ? json['user'] as Map<String, dynamic>
          : json as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } else {
      throw AuthException('Erreur lors de la mise à jour du profil.');
    }
  }

  // ── Change Password ────────────────────────────────────────────────────────

  Future<void> changePassword(
      String token, String password, String confirmation) async {
    final uri = Uri.parse('$_baseUrl/api/dashbord/user/updatepassword');
    final response = await _client
        .post(uri,
            headers: _authHeaders(token),
            body: jsonEncode({
              'password': password,
              'password_confirmation': confirmation,
            }))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw AuthException('Erreur lors du changement de mot de passe.');
    }
  }

  // ── Reservation History ────────────────────────────────────────────────────

  Future<List<UserReservation>> getHotelReservations(String token) async {
    final uri = Uri.parse('$_baseUrl/api/dashbord/user/resarvationhotel');
    final response = await _client
        .get(uri, headers: _authHeaders(token))
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['reservation'] as List<dynamic>? ?? [];
      return list
          .map((e) => UserReservation.fromJson(e as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 401) {
      throw AuthException('Session expirée. Veuillez vous reconnecter.');
    } else {
      return [];
    }
  }

  // ── Delete Account ─────────────────────────────────────────────────────────

  Future<void> deleteAccount(String token) async {
    final uri = Uri.parse('$_baseUrl/api/userdelete');
    await _client
        .post(uri, headers: _authHeaders(token))
        .timeout(_timeout);
  }
}
