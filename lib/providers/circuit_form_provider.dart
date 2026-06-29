import 'package:flutter/foundation.dart';

import '../models/circuit_form_data.dart';
import '../models/destination.dart';
import '../repositories/circuit_repository.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

enum CircuitMode { auto, manual }

enum CircuitLoadingState {
  idle,
  fetchingDestinations, // Manual only
  creatingCircuit,      // Both
  submittingReservation,
}

// ── Provider ───────────────────────────────────────────────────────────────

/// Unified state management for both Circuit Manuel and Circuit Automatique.
///
/// Registered globally in `main.dart`.
class CircuitFormProvider extends ChangeNotifier {
  final CircuitRepository _repository;

  CircuitFormProvider(this._repository);

  // ── State ────────────────────────────────────────────────────────────────

  CircuitLoadingState _state = CircuitLoadingState.idle;
  CircuitLoadingState get state => _state;

  String? _error;
  String? get error => _error;

  bool get isLoading => _state != CircuitLoadingState.idle;

  // ── Manual: destination selections ───────────────────────────────────────

  List<DestinationSelection> _destinations = [];
  List<DestinationSelection> get destinations =>
      List.unmodifiable(_destinations);

  // ── Shared: circuit result ───────────────────────────────────────────────

  Map<String, dynamic>? _circuitResult;
  Map<String, dynamic>? get circuitResult => _circuitResult;

  // ── Manual Step 1: Fetch destinations ────────────────────────────────────

  /// Fetches available destinations for the manual circuit criteria.
  Future<void> fetchDestinations(CircuitFormData form) async {
    _state = CircuitLoadingState.fetchingDestinations;
    _error = null;
    notifyListeners();

    try {
      final rawDestinations = await _repository.fetchManualDestinations(form);
      _destinations = rawDestinations
          .map((d) => DestinationSelection.fromDestination(d))
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des destinations.';
      _destinations = [];
      debugPrint('CircuitFormProvider.fetchDestinations error: $e');
    }

    _state = CircuitLoadingState.idle;
    notifyListeners();
  }

  // ── Manual: destination management ───────────────────────────────────────

  void updateDestinationDays(int index, int days) {
    if (index < 0 || index >= _destinations.length) return;
    _destinations[index].days = days.clamp(0, 30);
    notifyListeners();
  }

  void setStartDestination(int index) {
    for (int i = 0; i < _destinations.length; i++) {
      _destinations[i].isStart = (i == index);
    }
    notifyListeners();
  }

  /// Validates destination selection for manual circuit.
  ///
  /// Returns `null` if valid, or a French error message.
  String? validateDestinationSelection(int maxDays) {
    final selected = _destinations.where((d) => d.days > 0).toList();

    if (selected.isEmpty) {
      return 'Veuillez sélectionner au moins une destination.';
    }

    final hasStart = _destinations.any((d) => d.isStart);
    if (!hasStart) {
      return 'Veuillez choisir une ville de départ.';
    }

    final startCity = _destinations.firstWhere((d) => d.isStart);
    if (startCity.days < 1) {
      return 'La ville de départ doit avoir au moins 1 jour.';
    }

    final totalDays = selected.fold<int>(0, (sum, d) => sum + d.days);
    if (totalDays > maxDays) {
      return 'Total des jours ($totalDays) dépasse la durée du séjour ($maxDays).';
    }

    return null; // valid
  }

  // ── Manual Step 2: Create circuit ────────────────────────────────────────

  /// Generates an itinerary from the selected destinations (Manual flow).
  Future<void> createManualCircuit(CircuitFormData form) async {
    _state = CircuitLoadingState.creatingCircuit;
    _error = null;
    notifyListeners();

    try {
      _circuitResult = await _repository.createManualCircuit(
        form: form,
        selections: _destinations,
      );
    } catch (e) {
      _error = 'Erreur lors de la création du circuit.';
      _circuitResult = null;
      debugPrint('CircuitFormProvider.createManualCircuit error: $e');
    }

    _state = CircuitLoadingState.idle;
    notifyListeners();
  }

  // ── Auto: Generate circuit ───────────────────────────────────────────────

  /// Generates a complete circuit automatically (Auto flow).
  Future<void> generateAutoCircuit(CircuitFormData form) async {
    _state = CircuitLoadingState.creatingCircuit;
    _error = null;
    notifyListeners();

    try {
      _circuitResult = await _repository.generateAutoCircuit(form);
    } catch (e) {
      _error = 'Erreur lors de la génération du circuit.';
      _circuitResult = null;
      debugPrint('CircuitFormProvider.generateAutoCircuit error: $e');
    }

    _state = CircuitLoadingState.idle;
    notifyListeners();
  }

  // ── Reservation ──────────────────────────────────────────────────────────

  /// Submits a circuit reservation.
  Future<bool> submitReservation(Map<String, dynamic> payload) async {
    _state = CircuitLoadingState.submittingReservation;
    _error = null;
    notifyListeners();

    try {
      await _repository.submitReservation(payload);
      _state = CircuitLoadingState.idle;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la soumission de la réservation.';
      debugPrint('CircuitFormProvider.submitReservation error: $e');
      _state = CircuitLoadingState.idle;
      notifyListeners();
      return false;
    }
  }

  // ── Reset ────────────────────────────────────────────────────────────────

  /// Resets all state. Call when navigating away from the circuit flow.
  void reset() {
    _state = CircuitLoadingState.idle;
    _error = null;
    _destinations = [];
    _circuitResult = null;
    notifyListeners();
  }
}
