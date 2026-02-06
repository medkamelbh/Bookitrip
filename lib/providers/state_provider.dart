import 'package:TunisiaBook/models/state.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class StateProvider with ChangeNotifier {
  final ApiService apiService;

  StateProvider({required this.apiService});

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
      _states = await apiService.fetchStates();
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
