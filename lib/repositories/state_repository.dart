import '../models/state.dart';
import '../services/api_client.dart';

class StateRepository {
  final ApiClient _client;

  StateRepository(this._client);

  Future<List<StateApp>> fetchStates() async {
    final data = await _client.get('/utilisateur/states');
    final List statesJson = data['states'] ?? [];
    return statesJson.map((json) => StateApp.fromJson(json)).toList();
  }
}
