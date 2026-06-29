import 'package:flutter/material.dart';
import '../models/festival.dart';
import '../repositories/festival_repository.dart';

class FestivalProvider with ChangeNotifier {
  final FestivalRepository _repository;

  FestivalProvider(this._repository);

  /// Cached festivals per destination
  final Map<String, List<Festival>> _festivalsByDestination = {};

  /// All fetched festivals
  List<Festival> allFestivals = [];

  /// Current displayed festivals (filtered)
  List<Festival> _festivals = [];
  List<Festival> get festivals => _festivals;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 1;

  Festival? selectedFestival;
  String? error;
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  /// Flag to track if all festivals have been fetched
  bool _allFestivalsFetched = false;

  /// Fetch all festivals once
  Future<void> fetchAllFestivals() async {
    // Prevent duplicate fetching
    if (_allFestivalsFetched || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      allFestivals = await _repository.getFestivals(_currentPage.toString());
      _allFestivalsFetched = true;

      // Clear existing cache before rebuilding
      _festivalsByDestination.clear();

      // Pre-cache per destination
      for (var festival in allFestivals) {
        final destId = festival.destinationId?.toString() ?? 'unknown';
        _festivalsByDestination.putIfAbsent(destId, () => []);
        _festivalsByDestination[destId]!.add(festival);
      }

      // Initialize _festivals with all festivals
      _festivals = List.from(allFestivals);
    } catch (e) {
      allFestivals = [];
      _festivals = [];
      _allFestivalsFetched = false; // Allow retry on error
      debugPrint("Error fetching all festivals: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch festivals for list view, with pagination
  Future<void> fetchFestivals({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    if (refresh) {
      _currentPage = 1;
      _festivals.clear();
      allFestivals.clear();
      _hasMore = true;
      _allFestivalsFetched = false;
    }

    try {
      final List<Festival> newFestivals =
      await _repository.getFestivals(_currentPage.toString());

      if (newFestivals.isEmpty) {
        _hasMore = false;
      } else {
        // Update cache with new festivals, avoiding duplicates
        for (var festival in newFestivals) {
          final destId = festival.destinationId?.toString() ?? 'unknown';
          _festivalsByDestination.putIfAbsent(destId, () => []);

          // Check for duplicates before adding
          if (!_festivalsByDestination[destId]!.any((f) => f.id == festival.id)) {
            _festivalsByDestination[destId]!.add(festival);
          }
        }

        // Update allFestivals, removing duplicates
        for (var newFestival in newFestivals) {
          if (!allFestivals.any((f) => f.id == newFestival.id)) {
            allFestivals.add(newFestival);
          }
        }

        _currentPage++;

        // Apply current filters after fetching
        _applyFilters(const Locale("fr"));
      }
      error = null;
    } catch (e, stackTrace) {
      debugPrint("Erreur fetchFestivals: $e");
      debugPrint("$stackTrace");
      error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set search query and filter festivals
  void setSearchQuery(String query, Locale locale) {
    _searchQuery = query.toLowerCase();
    _applyFilters(locale);
  }

  /// Clear search
  void clearSearch(Locale locale) {
    _searchQuery = "";
    _applyFilters(locale);
  }

  /// Apply filters
  void _applyFilters(Locale locale) {
    List<Festival> filtered = List.from(allFestivals);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((festival) {
        final name = festival.getName(locale).toLowerCase();
        final description = festival.getDescription(locale).toLowerCase();
        final destination = festival.getDestinationName(locale).toLowerCase();

        return name.contains(_searchQuery) ||
            description.contains(_searchQuery) ||
            destination.contains(_searchQuery);
      }).toList();
    }

    _festivals = filtered;
    notifyListeners();
  }

  /// Get festivals by destination from cache
  void setFestivalsByDestination(String destinationId) {
    _festivals = _festivalsByDestination[destinationId] ?? [];
    error = _festivals.isEmpty ? "No festivals found for destination $destinationId" : null;
    notifyListeners();
  }

  /// Optional: get festivals by destination directly
  List<Festival> getFestivalsByDestination(String destinationId) {
    return _festivalsByDestination[destinationId] ?? [];
  }

  /// Fetch single festival by slug
  void getFestivalBySlug(String slug) {
    try {
      selectedFestival = allFestivals.firstWhere(
            (f) => f.slug.toLowerCase() == slug.toLowerCase(),
        orElse: () => throw Exception("Festival introuvable"),
      );
      error = null;
    } catch (e) {
      selectedFestival = null;
      error = "Festival introuvable";
    }
    notifyListeners();
  }

  /// Clear selected festival
  void clearSelectedFestival() {
    selectedFestival = null;
    error = null;
    notifyListeners();
  }

  /// Force refresh all data
  void forceRefresh() {
    _allFestivalsFetched = false;
    _festivalsByDestination.clear();
    allFestivals.clear();
    _festivals.clear();
    _searchQuery = "";
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}