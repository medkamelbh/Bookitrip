import '../models/circuit_form_data.dart';
import '../models/destination.dart';
import '../services/api_client.dart';

/// Repository for all circuit-related API calls.
///
/// Follows the same `Repository(ApiClient)` pattern used by
/// [DestinationRepository], [VoyageRepository], etc.
class CircuitRepository {
  final ApiClient _client;

  CircuitRepository(this._client);

  // ── Manual Step 1 ────────────────────────────────────────────────────────

  /// Fetch available destinations for the given criteria.
  ///
  /// POST /utilisateur/newcircuit
  /// Returns a list of [Destination] objects the user can select from.
  Future<List<Destination>> fetchManualDestinations(
    CircuitFormData form,
  ) async {
    final json = await _client.post(
      '/utilisateur/newcircuit',
      body: form.toFetchPayload(),
    );

    final List<dynamic> raw = json['alldestinationnew'] ?? [];
    return raw
        .map((d) => Destination.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  // ── Manual Step 2 ────────────────────────────────────────────────────────

  /// Generate an itinerary from the user's destination selections.
  ///
  /// POST /utilisateur/createcircuit
  /// Returns the raw JSON response containing `listparjours`, `alldestination`, etc.
  Future<Map<String, dynamic>> createManualCircuit({
    required CircuitFormData form,
    required List<DestinationSelection> selections,
  }) async {
    final destinationPayload = selections
        .where((s) => s.days > 0)
        .map((s) => {
              'destination_id': s.id,
              'days': s.days,
              'startedCity': s.isStart,
            })
        .toList();

    final json = await _client.post(
      '/utilisateur/createcircuit',
      body: form.toCreatePayload(destinationPayload),
    );

    return json as Map<String, dynamic>;
  }

  // ── Auto ─────────────────────────────────────────────────────────────────

  /// Generate a complete auto-circuit in one call.
  ///
  /// POST /utilisateur/circuitsmobile
  /// Returns the raw JSON response containing `listparjours`, `alldestination`, etc.
  Future<Map<String, dynamic>> generateAutoCircuit(
    CircuitFormData form,
  ) async {
    final json = await _client.post(
      '/utilisateur/circuitsmobile',
      body: form.toFetchPayload(),
    );

    return json as Map<String, dynamic>;
  }

  // ── Reservation (shared) ─────────────────────────────────────────────────

  /// Submit a circuit reservation.
  ///
  /// POST /utilisateur/newreservationcircuit
  Future<Map<String, dynamic>> submitReservation(
    Map<String, dynamic> payload,
  ) async {
    final json = await _client.post(
      '/utilisateur/newreservationcircuit',
      body: payload,
    );

    return json as Map<String, dynamic>;
  }
}
