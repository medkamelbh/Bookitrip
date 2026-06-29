import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/voyage.dart';
import '../services/api_client.dart';

class VoyageRepository {
  final ApiClient _client;
  final String _cacheKey = 'cached_voyages';

  VoyageRepository(this._client);

  Future<List<Voyage>> getAllVoyages() async {
    try {
      final jsonData = await _client.get('/utilisateur/voyages');

      if (jsonData == null || jsonData['voyages'] == null) {
        throw Exception("API returned null data");
      }

      if (jsonData['voyages'] is List) {
        final voyages = (jsonData['voyages'] as List)
            .map((v) => Voyage.fromJson(v))
            .toList();

        // Cache for offline use
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
          _cacheKey,
          jsonEncode(voyages.map((v) => v.toJson()).toList()),
        );

        return voyages;
      } else {
        throw Exception("Unexpected data format: ${jsonData['voyages']}");
      }
    } catch (e) {
      // Fall back to cache on error
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(_cacheKey);
      if (cachedData != null) {
        try {
          final List jsonList = jsonDecode(cachedData);
          return jsonList.map((v) => Voyage.fromJson(v)).toList();
        } catch (_) {
          // Cache corrupted
        }
      }
      return [];
    }
  }
}
