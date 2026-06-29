import 'package:BookiTrip/services/api_client.dart';

class ReservationRepository {
  final ApiClient _client;

  ReservationRepository(this._client);

  Future<String> submitHotelReservation({
    required Map<String, dynamic> payload,
    required String providerType,
  }) async {
    String endpoint;
    if (providerType == 'tgt') {
      endpoint = '/utilisateur/hotels/reservationhotel';
    } else if (providerType == 'bhr') {
      endpoint = '/utilisateur/bhr/hotelsreservation';
    } else if (providerType == 'mouradi') {
      endpoint = '/utilisateur/Mouradi/book';
    } else {
      throw Exception('Unknown provider type: $providerType');
    }

    final response = await _client.post(endpoint, body: payload);
    
    // TGT, BHR, and Mouradi return the payment URL usually in a 'url' or 'formUrl' key, 
    // or sometimes direct string if not properly JSON wrapped.
    // Assuming 'formUrl' for now based on typical integrations, need to be resilient.
    if (response is Map) {
      if (response.containsKey('formUrl')) return response['formUrl'] as String;
      if (response.containsKey('url')) return response['url'] as String;
      if (response['success'] == true) return '';
    }
    
    // If it's a direct string return
    if (response is String && response.startsWith('http')) {
       return response;
    }
    
    throw Exception('Failed to parse payment URL from reservation response: $response');
  }

  Future<Map<String, dynamic>> submitCircuitReservation(Map<String, dynamic> payload) async {
    final response = await _client.post('/utilisateur/newreservationcircuit', body: payload);
    return response as Map<String, dynamic>;
  }

  Future<void> submitRestaurantReservation(Map<String, dynamic> payload) async {
    await _client.post('/utilisateur/restaurants/reservation', body: payload);
  }
}
