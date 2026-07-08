import 'package:flutter/foundation.dart';
import 'package:BookiTrip/models/vehicle.dart';
import 'package:BookiTrip/repositories/vehicle_repository.dart';
import 'package:BookiTrip/services/api_client.dart';

enum VehicleStatus { initial, loading, success, failure }

enum VehicleReservationStatus { initial, loading, success, failure }

class VehicleProvider with ChangeNotifier {
  final VehicleRepository _repository;

  VehicleProvider(this._repository);

  // ── Vehicle list state ──────────────────────────────────────────────────
  List<Vehicle> _vehicles = [];
  List<Vehicle> get vehicles => _vehicles;

  VehicleStatus _status = VehicleStatus.initial;
  VehicleStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _hasFetched = false;

  DateTime? _searchFrom;
  DateTime? get searchFrom => _searchFrom;

  DateTime? _searchTo;
  DateTime? get searchTo => _searchTo;

  // ── Reservation state ─────────────────────────────────────────────────
  VehicleReservationStatus _reservationStatus =
      VehicleReservationStatus.initial;
  VehicleReservationStatus get reservationStatus => _reservationStatus;

  String? _reservationError;
  String? get reservationError => _reservationError;

  // ── Fetch vehicles ────────────────────────────────────────────────────

  /// Fetches all vehicles from the API.
  ///
  /// Uses [from] and [to] if provided, otherwise uses default wide range.
  Future<void> fetchVehicles({DateTime? from, DateTime? to}) async {
    if (_status == VehicleStatus.loading) return;

    if (from != null) _searchFrom = from;
    if (to != null) _searchTo = to;

    _status = VehicleStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final startDate = _searchFrom ?? DateTime.now();
      final endDate = _searchTo ?? startDate.add(const Duration(days: 365));

      final fromStr =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final toStr =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      _vehicles = await _repository.getVehicles(from: fromStr, to: toStr);
      _status = VehicleStatus.success;
      _hasFetched = true;
    } on ApiException catch (e) {
      _status = VehicleStatus.failure;
      _errorMessage = e.message;
      debugPrint('VehicleProvider fetchVehicles error: $e');
    } catch (e) {
      _status = VehicleStatus.failure;
      _errorMessage = e.toString();
      debugPrint('VehicleProvider fetchVehicles error: $e');
    }

    notifyListeners();
  }

  /// Fetches vehicles only if they haven't been fetched yet.
  Future<void> fetchVehiclesIfNeeded() async {
    if (!_hasFetched) {
      await fetchVehicles();
    }
  }

  // ── Submit reservation ────────────────────────────────────────────────

  /// Submits a vehicle reservation with the given [payload].
  ///
  /// Sets [reservationStatus] to loading/success/failure and notifies.
  Future<bool> submitReservation(Map<String, dynamic> payload) async {
    _reservationStatus = VehicleReservationStatus.loading;
    _reservationError = null;
    notifyListeners();

    try {
      await _repository.submitReservation(payload);
      _reservationStatus = VehicleReservationStatus.success;
      notifyListeners();
      return true;
    } on ServerException catch (_) {
      _reservationStatus = VehicleReservationStatus.failure;
      _reservationError = 'Server error';
      notifyListeners();
      return false;
    } catch (e) {
      _reservationStatus = VehicleReservationStatus.failure;
      _reservationError = e.toString();
      debugPrint('VehicleProvider submitReservation error: $e');
      notifyListeners();
      return false;
    }
  }

  /// Resets the reservation state back to initial.
  void resetReservationState() {
    _reservationStatus = VehicleReservationStatus.initial;
    _reservationError = null;
    notifyListeners();
  }

  /// Force refresh vehicles data.
  void forceRefresh() {
    _hasFetched = false;
    _vehicles = [];
    _status = VehicleStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
