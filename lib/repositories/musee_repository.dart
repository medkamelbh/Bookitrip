import '../models/musee.dart';
import '../services/api_client.dart';

class MuseeRepository {
  final ApiClient _client;

  MuseeRepository(this._client);

  Future<List<Musees>> getMusees() async {
    final jsonData = await _client.get('/utilisateur/musees');

    if (jsonData == null || jsonData['musees'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['musees']['data'] is List) {
      return (jsonData['musees']['data'] as List)
          .map((item) => Musees.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected data format: ${jsonData['musees']}");
    }
  }

  Future<Musees> getMuseeBySlug(String slug) async {
    final encodedSlug = Uri.encodeComponent(slug);
    final jsonData = await _client.get('/utilisateur/musees/$encodedSlug');
    return Musees.fromJson(jsonData);
  }
}
