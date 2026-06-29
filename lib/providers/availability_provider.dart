import 'package:flutter/foundation.dart';
import '../models/availability_result.dart';
import '../models/availability_search_params.dart';
import '../repositories/availability_repository.dart';

/// Possible states for the availability search flow.
enum AvailabilityStatus { idle, loading, success, error, empty }

class AvailabilityProvider extends ChangeNotifier {
  final AvailabilityRepository _repository;

  AvailabilityProvider(this._repository);

  // ── State ─────────────────────────────────────────────────────────────────

  AvailabilityStatus _status = AvailabilityStatus.idle;
  AvailabilityStatus get status => _status;

  List<AvailabilityResult> _results = [];
  List<AvailabilityResult> get results => _results;

  AvailabilityResult? _singleResult;
  AvailabilityResult? get singleResult => _singleResult;

  AvailabilitySearchParams? _currentParams;
  AvailabilitySearchParams? get currentParams => _currentParams;

  String? _error;
  String? get error => _error;

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isLoading => _status == AvailabilityStatus.loading;
  bool get hasResults =>
      _status == AvailabilityStatus.success && _results.isNotEmpty;
  bool get hasSingleResult =>
      _status == AvailabilityStatus.success && _singleResult != null;

  // ── Destination-wide search ───────────────────────────────────────────────

  Future<void> searchAvailability(AvailabilitySearchParams params) async {
    // Avoid duplicate calls with identical params
    if (_status == AvailabilityStatus.loading && _currentParams == params) {
      return;
    }

    _currentParams = params;
    _status = AvailabilityStatus.loading;
    _error = null;
    _results = [];
    _singleResult = null;
    notifyListeners();

    try {
      _results = await _repository.searchAvailability(params);
      _status = _results.isEmpty
          ? AvailabilityStatus.empty
          : AvailabilityStatus.success;
    } catch (e) {
      _error = 'Impossible de charger les disponibilités. Veuillez réessayer.';
      _status = AvailabilityStatus.error;
      debugPrint('❌ AvailabilityProvider.searchAvailability: $e');
    }

    notifyListeners();
  }

  // ── Single-hotel availability ─────────────────────────────────────────────

  /// Checks availability for a specific hotel.
  ///
  /// Stores the result in [singleResult] for inline display or navigation.
  Future<void> getHotelAvailability(AvailabilitySearchParams params) async {
    if (_status == AvailabilityStatus.loading && _currentParams == params) {
      return;
    }

    _currentParams = params;
    _status = AvailabilityStatus.loading;
    _error = null;
    _singleResult = null;
    _results = [];
    notifyListeners();

    try {
      final result = await _repository.getHotelAvailability(params);
      _singleResult = result;
      _results = [result];
      _status = AvailabilityStatus.success;
    } catch (e) {
      _error = 'Impossible de vérifier la disponibilité. Veuillez réessayer.';
      _status = AvailabilityStatus.error;
      debugPrint('❌ AvailabilityProvider.getHotelAvailability: $e');
    }

    notifyListeners();
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void clearResults() {
    _results = [];
    _singleResult = null;
    _currentParams = null;
    _error = null;
    _status = AvailabilityStatus.idle;
    notifyListeners();
  }
}
