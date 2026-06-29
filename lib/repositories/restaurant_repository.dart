import '../models/restaurant.dart';
import '../services/api_client.dart';

class RestaurantRepository {
  final ApiClient _client;

  RestaurantRepository(this._client);

  Future<List<Restaurant>> getRestaurants({int page = 1}) async {
    final jsonData = await _client.get('/utilisateur/restaurants?page=$page');
    final List<dynamic>? restaurantsList = jsonData['restaurants']?['data'];

    if (restaurantsList != null) {
      return restaurantsList.map((item) => Restaurant.fromJson(item)).toList();
    } else {
      throw Exception("Key 'data' not found in response");
    }
  }

  Future<List<Restaurant>> searchRestaurants(String query) async {
    final jsonData = await _client.get('/utilisateur/restaurants?search=$query');
    final List list = jsonData['restaurants']['data'];
    return list.map((e) => Restaurant.fromJson(e)).toList();
  }

  Future<List<Restaurant>> getRestaurantsByState(String state) async {
    final jsonData = await _client.get('/utilisateur/restaurantsbystate/$state');
    final List<dynamic> list = jsonData['restaurants']?['data'] ?? [];
    return list.map((e) => Restaurant.fromJson(e)).toList();
  }

  /// Searches available restaurants for a given destination, date and number of persons.
  /// API: GET /utilisateur/rechercherestaut?id={destinationId}&date={yyyy-MM-dd}&number={number}
  Future<List<Restaurant>> searchAvailableRestaurants({
    required String destinationId,
    required String date,
    required int number,
  }) async {
    final jsonData = await _client.get(
      '/utilisateur/rechercherestaut?id=$destinationId&date=$date&number=$number',
    );

    // The API may return the list under different keys — handle flexibly
    List<dynamic> list = [];
    if (jsonData is List) {
      list = jsonData;
    } else if (jsonData is Map) {
      // Try common response keys
      list = jsonData['restaurants'] ?? jsonData['data'] ?? jsonData['results'] ?? [];
      // If the value itself is a map with 'data', unwrap it
      if (list is Map) {
        list = (list as Map)['data'] ?? [];
      }
    }

    return list.map((e) => Restaurant.fromJson(e as Map<String, dynamic>)).toList();
  }
}
