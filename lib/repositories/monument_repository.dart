import '../models/monument.dart';
import '../services/api_client.dart';

class MonumentRepository {
  final ApiClient _client;

  MonumentRepository(this._client);

  Future<List<Monument>> getMonuments(String page) async {
    final jsonData = await _client.get('/utilisateur/monument?page=$page');

    if (jsonData == null || jsonData['monument'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['monument']['data'] is List) {
      return (jsonData['monument']['data'] as List)
          .map((item) => Monument.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected data format: ${jsonData['monument']}");
    }
  }

  Future<Monument> getMonumentBySlug(String slug) async {
    final jsonData = await _client.get('/monument/$slug');
    return Monument.fromJson(jsonData['monument'] ?? jsonData);
  }
}
