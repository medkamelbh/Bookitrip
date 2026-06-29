import '../models/festival.dart';
import '../services/api_client.dart';

class FestivalRepository {
  final ApiClient _client;

  FestivalRepository(this._client);

  Future<List<Festival>> getFestivals([String page = "1"]) async {
    final jsonData = await _client.get('/utilisateur/festival?page=$page');

    if (jsonData == null || jsonData['festival'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['festival']['data'] is List) {
      return (jsonData['festival']['data'] as List)
          .map((item) => Festival.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected data format: ${jsonData['festival']}");
    }
  }
}
