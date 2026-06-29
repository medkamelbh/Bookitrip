import '../models/story.dart';
import '../services/api_client.dart';

class StoryRepository {
  final ApiClient _client;

  StoryRepository(this._client);

  Future<List<Story>> fetchStories() async {
    final jsonData = await _client.get('/utilisateur/story');

    if (jsonData is List) {
      return jsonData
          .map((json) => Story.fromJson(json))
          .where((story) => story.status)
          .toList();
    } else {
      throw Exception('Unexpected stories data format');
    }
  }
}
