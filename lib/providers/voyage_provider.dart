import 'package:flutter/material.dart';
import '../models/voyage.dart';
import '../repositories/voyage_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VoyageProvider with ChangeNotifier {
  final VoyageRepository _repository;

  VoyageProvider(this._repository);

  List<Voyage> _voyages = [];
  Voyage? _selectedVoyage;
  bool _isLoading = false;
  String? _error;

  List<Voyage> get voyages => _voyages;
  Voyage? get selectedVoyage => _selectedVoyage;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String _cacheKey = 'cached_voyages';

  // Fetch all circuit predefini
  Future<void> fetchVoyages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedVoyages = await _repository.getAllVoyages();
      _voyages = fetchedVoyages;

      final prefs = await SharedPreferences.getInstance();
      prefs.setString(_cacheKey,
          jsonEncode(_voyages.map((v) => v.toJson()).toList()));
    } catch (e) {
      _error = 'Failed to load voyages: $e';
      await _loadCachedVoyages();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a circuit predéfini by id
  Future<void> getVoyageById(String id) async {
    try {
      final voyage = _voyages.firstWhere((v) => v.id == id);
      _selectedVoyage = voyage;
    } catch (_) {
      _selectedVoyage = null;
      _error = 'Voyage not found';
    }
    notifyListeners();
  }

  //load circuit predefini from cache
  Future<void> _loadCachedVoyages() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);
    if (cachedData != null) {
      try {
        final List jsonList = jsonDecode(cachedData);
        _voyages = jsonList.map((v) => Voyage.fromJson(v)).toList();
        _error = null;
      } catch (_) {
        _voyages = [];
      }
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
    _voyages = [];
    _selectedVoyage = null;
    notifyListeners();
  }
}
