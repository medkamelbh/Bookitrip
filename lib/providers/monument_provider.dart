import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/monument.dart';
import '../repositories/monument_repository.dart';

class MonumentProvider with ChangeNotifier {
  final MonumentRepository _repository;

  MonumentProvider(this._repository);

  List<Monument> _allMonuments = [];
  List<Monument> _monuments = [];
  Monument? _selectedMonument;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = "";

  List<Monument> get monuments => _monuments;
  List<Monument> get allMonuments => _allMonuments;
  Monument? get selectedMonument => _selectedMonument;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Fetch all monuments
  Future<void> fetchMonuments({String page = '1'}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allMonuments = await _repository.getMonuments(page);
      _monuments = List.from(_allMonuments); // Initialize with all monuments
    } catch (e) {
      _error = e.toString();
      _allMonuments = [];
      _monuments = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set search query and filter monuments
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
    List<Monument> filtered = List.from(_allMonuments);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((monument) {
        final name = monument.getName(locale).toLowerCase();
        final description = monument.getDescription(locale).toLowerCase();
        final categories = monument.getCategories(locale).toLowerCase();
        final destination = monument.getDestinationName(locale).toLowerCase();

        return name.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            categories.contains(_searchQuery) ||
            destination.contains(_searchQuery);
      }).toList();
    }

    _monuments = filtered;
    notifyListeners();
  }

  // Fetch monument details by slug
  Future<void> fetchMonumentBySlug(String slug) async {
    _isLoading = true;
    _error = null;
    _selectedMonument = null;
    notifyListeners();

    try {
      final existingMonument = _allMonuments.firstWhere(
            (monument) => monument.slug == slug,
        orElse: () => Monument(
          id: '',
          name: '',
          description: '',
          categories: '',
          lat: 0.0,
          lng: 0.0,
          images: [],
          cover: '',
          vignette: '',
          slug: '',
          destination: Destination.fromJson({}),
        ),
      );

      if (existingMonument.id.isNotEmpty) {
        _selectedMonument = existingMonument;
      } else {
        _selectedMonument = await _repository.getMonumentBySlug(slug);
      }
    } catch (e) {
      _error = e.toString();
      _selectedMonument = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // get monuments by destination id
  List<Monument> getMonumentsByDestination(String destinationId) {
    return _allMonuments.where((m) => m.destination.id == destinationId).toList();
  }

  void setMonumentsByDestination(String destinationId) {
    _monuments = getMonumentsByDestination(destinationId);
    notifyListeners();
  }

  // Clear selected monument
  void clearSelectedMonument() {
    _selectedMonument = null;
    notifyListeners();
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Force refresh
  void forceRefresh() {
    _allMonuments.clear();
    _monuments.clear();
    _selectedMonument = null;
    _error = null;
    _searchQuery = "";
    notifyListeners();
  }
}