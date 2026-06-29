import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../repositories/destination_repository.dart';

class DestinationProvider extends ChangeNotifier {
  final DestinationRepository _repository;

  DestinationProvider(this._repository) {
    fetchDestinations();
  }

  /// Cached destinations
  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Fetch all destinations once
  Future<void> fetchDestinations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _destinations = await _repository.getDestinations();
    } catch (e) {
      _destinations = [];
      _error = "Vérifiez votre connexion Internet et réessayez.";
      debugPrint(_error);
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Destination> get filteredDestinations {
    if (_searchQuery.isEmpty) return _destinations;

    return _destinations.where((d) {
      final name = d.name.toLowerCase();
      final state = d.state.toLowerCase();
      return name.contains(_searchQuery) || state.contains(_searchQuery);
    }).toList();
  }

  String _searchQuery = "";
  void setSearchQuery(String value) {
    _searchQuery = value.toLowerCase().trim();
    notifyListeners();
  }

  /// Get a destination by its ID
  Destination? getDestinationById(String id) {
    try {
      return _destinations.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a destination by its name (case-insensitive)
  Destination? getDestinationByName(String name) {
    try {
      return _destinations
          .firstWhere((d) => d.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  /// Get destinations by state (case-insensitive)
  List<Destination> getDestinationsByState(String state) {
    try {
      return _destinations
          .where((d) => d.state.toLowerCase() == state.toLowerCase())
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get a destination's localized name
  String getDestinationName(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return "";
    return destination.getName(locale);
  }

  /// Get a destination's localized description
  String? getDestinationDescription(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getDescription(locale);
  }

  /// Get a destination's localized title
  String? getDestinationTitle(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getTitle(locale);
  }

  /// Get a destination's localized subtitle
  String? getDestinationSubtitle(String id, Locale locale) {
    final destination = getDestinationById(id);
    if (destination == null) return null;
    return destination.getSubtitle(locale);
  }

  void clearSearch() {
    _searchQuery = "";
    notifyListeners();
  }
}
