import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String _baseUrl = 'https://backend.bookitrip.com';
  static const Duration _timeout = Duration(seconds: 60);

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  String get baseUrl => _baseUrl;

  Future<dynamic> get(String path, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client
          .get(uri, headers: _mergeHeaders(headers))
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out', uri.toString());
    } on Exception catch (e) {
      throw ApiException('Network error: $e', uri.toString());
    }
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');

    try {
      final response = await _client
          .post(uri, headers: _mergeHeaders(headers), body: jsonEncode(body))
          .timeout(_timeout);

      return _handleResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out', uri.toString());
    } on Exception catch (e) {
      throw ApiException('Network error: $e', uri.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint('API Response [${response.statusCode}]: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw NotFoundException('Resource not found (404)');
    } else if (response.statusCode >= 500) {
      throw ServerException('Server error: ${response.statusCode}');
    } else {
      throw ApiException(
        'HTTP ${response.statusCode}',
        response.body,
      );
    }
  }

  Map<String, String> _mergeHeaders(Map<String, String>? custom) {
    final defaults = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (custom != null) {
      defaults.addAll(custom);
    }
    return defaults;
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final String message;
  final String? details;

  ApiException(this.message, [this.details]);

  @override
  String toString() => 'ApiException: $message${details != null ? ' ($details)' : ''}';
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class ServerException extends ApiException {
  ServerException(super.message);
}
