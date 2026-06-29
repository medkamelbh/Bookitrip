import 'package:flutter/foundation.dart';
import '../models/user_reservation.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

class ReservationHistoryProvider with ChangeNotifier {
  final AuthRepository _repository;

  ReservationHistoryProvider(this._repository);

  List<UserReservation> _reservations = [];
  List<UserReservation> get reservations => _reservations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchReservations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reservations = await _repository.getHotelReservations();
    } on AuthException catch (e) {
      _error = e.message;
      _reservations = [];
    } catch (e) {
      _error = 'Erreur réseau. Vérifiez votre connexion.';
      _reservations = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _reservations = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
