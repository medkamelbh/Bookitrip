import '../models/activity.dart';
import '../services/api_client.dart';

class ActivityRepository {
  final ApiClient _client;

  ActivityRepository(this._client);

  Future<List<Activity>> getAllActivities() async {
    final jsonData = await _client.get('/utilisateur/allactivity');

    if (jsonData == null || jsonData['activety'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['activety']['data'] is List) {
      return (jsonData['activety']['data'] as List)
          .map((item) => Activity.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected data format: ${jsonData['activety']}");
    }
  }
}
