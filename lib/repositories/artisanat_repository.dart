import '../models/artisanat.dart';
import '../services/api_client.dart';

class ArtisanatRepository {
  final ApiClient _client;

  ArtisanatRepository(this._client);

  Future<List<Artisanat>> getArtisanats() async {
    final jsonData = await _client.get('/utilisateur/artisanat');

    if (jsonData == null || jsonData['data'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['data'] is List) {
      return (jsonData['data'] as List)
          .map((item) => Artisanat.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected artisanat format: ${jsonData['data']}");
    }
  }

  Future<Artisanat> getArtisanatBySlug(String slug) async {
    final jsonData = await _client.get('/artisanat/$slug');
    return Artisanat.fromJson(jsonData['artisanat'] ?? jsonData);
  }
}
