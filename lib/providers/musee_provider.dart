import 'package:flutter/material.dart';
import '../models/musee.dart';
import '../repositories/musee_repository.dart';

class MuseeProvider with ChangeNotifier {
  final MuseeRepository _repository;

  MuseeProvider(this._repository);

  List<Musees> _allMusees = [];
  List<Musees> _musees = [];
  bool _isLoading = false;
  String? _error;
  Musees? selectedMusee;
  String _searchQuery = "";

  List<Musees> get musees => _musees;
  List<Musees> get allMusees => _allMusees;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> fetchMusees() async {
    _setLoading(true);
    try {
      _allMusees = await _repository.getMusees();
      _musees = List.from(_allMusees); // Initialize with all musees
      _error = null;
    } catch (e) {
      _allMusees = [];
      _musees = [];
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Set search query and filter musees
  void setSearchQuery(String query, Locale locale) {
    _searchQuery = query.toLowerCase();
    _applyFilters(locale);
  }

  // Clear search
  void clearSearch(Locale locale) {
    _searchQuery = "";
    _applyFilters(locale);
  }

  // Apply filters
  void _applyFilters(Locale locale) {
    List<Musees> filtered = List.from(_allMusees);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((musee) {
        final name = musee.getName(locale).toLowerCase();
        final situation = musee.getSituation(locale).toLowerCase();
        final description = musee.getDescription(locale).toLowerCase();

        return name.contains(_searchQuery) ||
            situation.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    _musees = filtered;
    notifyListeners();
  }

  // fetch museum by slug
  Future<void> fetchMuseeBySlug(String slug) async {
    _setLoading(true);
    try {
      selectedMusee = await _repository.getMuseeBySlug(slug);
      if (selectedMusee == null) {
        _error = "Musée introuvable";
      } else {
        _error = null;
      }
    } catch (e) {
      selectedMusee = null;
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMusees() async => fetchMusees();

  // get musee by destination
  List<Musees> getMuseesByDestination(String destinationId) {
    return _allMusees.where((m) => m.destinationId == destinationId).toList();
  }

  void setMuseesByDestination(String destinationId) {
    _musees = getMuseesByDestination(destinationId);
    notifyListeners();
  }

  void clearSelectedMusee() {
    selectedMusee = null;
    notifyListeners();
  }

  void forceRefresh() {
    _allMusees.clear();
    _musees.clear();
    selectedMusee = null;
    _error = null;
    _searchQuery = "";
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}