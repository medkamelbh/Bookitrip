import 'package:flutter/foundation.dart';
import '../repositories/transfer_repository.dart';

enum TransferStatus { initial, loading, success, failure }

class TransferProvider with ChangeNotifier {
  final TransferRepository _repository;

  TransferProvider(this._repository);

  TransferStatus _status = TransferStatus.initial;
  TransferStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submitTransfer({
    required String name,
    required String email,
    required String phone,
    required int numberPerson,
    required String date,
    required String hour,
    required String adresseDepart,
    required String adresseArrive,
  }) async {
    _status = TransferStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.submitTransferReservation(
        name: name,
        email: email,
        phone: phone,
        numberPerson: numberPerson,
        date: date,
        hour: hour,
        adresseDepart: adresseDepart,
        adresseArrive: adresseArrive,
      );
      _status = TransferStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = TransferStatus.failure;
      notifyListeners();
      return false;
    }
  }
}
