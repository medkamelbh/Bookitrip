import 'package:BookiTrip/models/state.dart';
import 'package:flutter/material.dart';
import '../repositories/state_repository.dart';

class StateProvider with ChangeNotifier {
  final StateRepository _repository;

  StateProvider(this._repository);

  List<StateApp> _states = [];
  bool _isLoading = false;
  String? _error;

  List<StateApp> get states => _states;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _states = await _repository.fetchStates();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  StateApp? getStateByName(String name) {
    try {
      return _states.firstWhere((state) => state.name == name);
    } catch (e) {
      return null;
    }
  }

  StateApp? getStateById(String id) {
    try {
      return _states.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

}
