import '../models/destination.dart';
import '../services/api_client.dart';

class DestinationRepository {
  final ApiClient _client;

  DestinationRepository(this._client);

  Future<List<Destination>> getDestinations() async {
    final jsonData = await _client.get('/utilisateur/alldestinations');
    final List<dynamic> data = jsonData['destinations'];
    return data.map((json) => Destination.fromJson(json)).toList();
  }
}
