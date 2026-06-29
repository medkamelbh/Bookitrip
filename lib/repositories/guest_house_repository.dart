import '../models/guestHouse.dart';
import '../services/api_client.dart';

class GuestHouseRepository {
  final ApiClient _client;

  GuestHouseRepository(this._client);

  Future<List<GuestHouse>> getGuestHouses({int page = 1}) async {
    final jsonData = await _client.get('/utilisateur/maison?page=$page');
    final List<dynamic>? guestHousesList = jsonData['maisons']?['data'];

    if (guestHousesList != null) {
      return guestHousesList.map((item) => GuestHouse.fromJson(item)).toList();
    } else {
      throw Exception("Key 'data' not found in response");
    }
  }
}
