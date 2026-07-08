import 'package:BookiTrip/models/vehicle.dart';
import 'package:BookiTrip/services/api_client.dart';

class VehicleRepository {
  final ApiClient _client;

  VehicleRepository(this._client);

  /// Fetches all available vehicles.
  ///
  /// The [from] and [to] query parameters are required by the API
  /// even though they currently have no backend filtering effect.
  Future<List<Vehicle>> getVehicles({
    String? from,
    String? to,
  }) async {
    // We hit allvehicles and handle date filtering locally
    final jsonData = await _client.get(
      '/utilisateur/allvehicles',
    );

    if (jsonData == null || jsonData['data'] == null) {
      return [];
    }

    final List<dynamic> vehicleList = jsonData['data'];
    return vehicleList
        .map((item) => Vehicle.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Submits a vehicle reservation.
  ///
  /// Returns the raw response map from the API.
  Future<Map<String, dynamic>> submitReservation(
    Map<String, dynamic> payload,
  ) async {
    final response = await _client.post(
      '/utilisateur/vehicles/reservations',
      body: payload,
    );
    return response as Map<String, dynamic>;
  }
}
