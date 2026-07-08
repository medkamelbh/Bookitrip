import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/review.dart';

class ReviewService {
  static const String _baseUrl = 'https://backend.bookitrip.com';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client;

  ReviewService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch reviews for a given model (e.g. model=hotel, model_id=123)
  Future<List<Review>> fetchReviews({
    required String modelId,
    required String model,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/utilisateur/reviews?model_id=$modelId&model=$model',
    );

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      debugPrint('Reviews API [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Handle both list and map-wrapped responses
        List<dynamic> list;
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          list = decoded['reviews'] ??
              decoded['data'] ??
              decoded['avis'] ??
              [];
        } else {
          list = [];
        }

        return list
            .whereType<Map<String, dynamic>>()
            .map((e) => Review.fromJson(e))
            .toList();
      } else {
        debugPrint('Reviews fetch failed: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Reviews fetch error: $e');
      return [];
    }
  }
}
