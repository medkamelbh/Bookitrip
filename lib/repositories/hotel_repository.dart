import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/hotel.dart';
import '../models/hotel_details.dart';
import '../services/api_client.dart';

class HotelRepository {
  final ApiClient _client;

  HotelRepository(this._client);

  Future<List<Hotel>> getHotels({int page = 1}) async {
    final jsonData = await _client.get('/utilisateur/hotels?page=$page');
    final List<dynamic>? hotelList = jsonData['hotels']?['data'];

    if (hotelList != null) {
      return hotelList.map((item) => Hotel.fromJson(item)).toList();
    } else {
      throw Exception("Key 'data' not found in response");
    }
  }

  Future<HotelDetail?> getHotelDetail(String slug) async {
    try {
      final jsonData = await _client.get('/utilisateur/hoteldetail/$slug');

      if (jsonData == null || jsonData['hotels'] == null) {
        throw Exception("API returned null data");
      }

      final List<dynamic>? hotels = jsonData['hotels'];
      final firstHotel = hotels!.first;

      if (firstHotel != null) {
        return HotelDetail.fromJson(firstHotel);
      } else {
        throw Exception("Unexpected data format: ${jsonData['hotels']}");
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<Hotel>> searchHotels(String query) async {
    final jsonData = await _client.get('/utilisateur/hotels?search=$query');
    final List list = jsonData['hotels']['data'];
    return list.map((e) => Hotel.fromJson(e)).toList();
  }

  Future<List<Hotel>> getHotelsByState(String state) async {
    final jsonData = await _client.get('/utilisateur/hotelsbystate/$state');
    final List<dynamic> list = jsonData['hotels']?['data'] ?? [];
    return list.map((e) => Hotel.fromJson(e)).toList();
  }

  // ── Disponibility endpoints ─────────────────────────────────────────────

  /// Calls POST /utilisateur/hoteldisponiblepontion?page={page}
  ///
  /// Returns the raw response map containing paginated hotel disponibility
  /// data with pension/room/price information.
  Future<Map<String, dynamic>> getDisponibilityPontion({
    required Map<String, dynamic> payload,
    int page = 1,
  }) async {
    final jsonData = await _client.post(
      '/utilisateur/hoteldisponiblepontion?page=$page',
      body: payload,
    );
    return jsonData as Map<String, dynamic>;
  }

  /// Calls POST /utilisateur/hotels/showDisponibility/{slug}
  ///
  /// Returns the raw response for a single hotel's disponibility with
  /// pension/room/price data.
  Future<Map<String, dynamic>> getHotelDisponibilityPontion({
    required String slug,
    required Map<String, dynamic> payload,
  }) async {
    final url = '/utilisateur/hotels/showDisponibility/$slug';
    debugPrint('\n🔍 ═══════════════════════════════════════════════════');
    debugPrint('🔍 SINGLE HOTEL DISPONIBILITY REQUEST');
    debugPrint('🔍 URL: $url');
    debugPrint('🔍 Payload: ${const JsonEncoder.withIndent("  ").convert(payload)}');
    debugPrint('🔍 ═══════════════════════════════════════════════════');

    final jsonData = await _client.post(
      url,
      body: payload,
    );
    final response = jsonData as Map<String, dynamic>;

    debugPrint('\n📦 ═══════════════════════════════════════════════════');
    debugPrint('📦 SINGLE HOTEL DISPONIBILITY RESPONSE');
    debugPrint('📦 Top-level keys: ${response.keys.toList()}');
    // Log the full response (truncated to avoid flooding)
    final responseStr = const JsonEncoder.withIndent("  ").convert(response);
    // Print in chunks to avoid logcat truncation
    final chunkSize = 800;
    for (var i = 0; i < responseStr.length; i += chunkSize) {
      final end = (i + chunkSize < responseStr.length) ? i + chunkSize : responseStr.length;
      debugPrint('📦 ${responseStr.substring(i, end)}');
    }
    debugPrint('📦 ═══════════════════════════════════════════════════\n');

    return response;
  }

  /// Calls POST /utilisateur/Mouradi/showdisponibility
  ///
  /// Returns the raw Mouradi availability response.
  Future<Map<String, dynamic>> getMouradiDisponibility({
    required Map<String, dynamic> payload,
  }) async {
    final jsonData = await _client.post(
      '/utilisateur/Mouradi/showdisponibility',
      body: payload,
    );
    return jsonData as Map<String, dynamic>;
  }
}
