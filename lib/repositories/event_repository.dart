import '../models/event.dart';
import '../services/api_client.dart';

class EventRepository {
  final ApiClient _client;

  EventRepository(this._client);

  Future<List<Event>> getAllEvents() async {
    final jsonData = await _client.get('/utilisateur/allevent');

    if (jsonData == null || jsonData['events'] == null) {
      throw Exception("API returned null data");
    }

    if (jsonData['events']['data'] is List) {
      return (jsonData['events']['data'] as List)
          .map((item) => Event.fromJson(item))
          .toList();
    } else {
      throw Exception("Unexpected data format: ${jsonData['events']}");
    }
  }
}
