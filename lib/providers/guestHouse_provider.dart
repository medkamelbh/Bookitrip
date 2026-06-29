import 'package:flutter/material.dart';
import '../models/guestHouse.dart';
import '../repositories/guest_house_repository.dart';

class GuestHouseProvider with ChangeNotifier {
  final GuestHouseRepository _repository;

  GuestHouseProvider(this._repository);

  List<GuestHouse> _allMaisons = [];
  List<GuestHouse> get allMaisons => _allMaisons;

  List<GuestHouse> _maisons = [];
  List<GuestHouse> get maisons => _maisons;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final int _pageSize = 15;
  int get pageSize => _pageSize;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _lastFetchedPage = 0;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _totalMaisonsCount = 0;
  int get totalMaisonsCount => _totalMaisonsCount;
  int get totalPages => (_totalMaisonsCount / _pageSize).ceil();

  // Filters
  int? selectedStars;
  String? selectedDestination;
  String searchQuery = "";

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  // ---------------------------------------------------------------------------
  // FETCHING DATA
  // ---------------------------------------------------------------------------

  Future<void> fetchAllGuestHouses() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorDetail = null;
    _allMaisons = [];
    _currentPage = 1;
    _lastFetchedPage = 0;
    _hasMorePages = true;
    notifyListeners();

    try {
      final fetchedGuestHouses = await _repository.getGuestHouses(page: 1);
      _allMaisons = fetchedGuestHouses;
      _lastFetchedPage = 1;

      if (fetchedGuestHouses.length < 15) {
        _hasMorePages = false;
      }

      _applyFiltersAndPagination();
    } catch (e) {
      _errorDetail = "Failed to load Guest Houses: $e";
      _allMaisons = [];
      debugPrint("❌ Error fetching Guest Houses: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreFromAPI() async {
    if (_isLoading || !_hasMorePages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _lastFetchedPage + 1;
      final nextGuestHouse = await _repository.getGuestHouses(page: nextPage);

      if (nextGuestHouse.isEmpty || nextGuestHouse.length < 25) {
        _hasMorePages = false;
      }

      if (nextGuestHouse.isNotEmpty) {
        _allMaisons.addAll(nextGuestHouse);
        _lastFetchedPage = nextPage;
        _applyFiltersAndPagination(); // Refresh the list with new data
      }
    } catch (e) {
      debugPrint("❌ Error loading more Guest Houses: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // FILTER SETTERS
  // ---------------------------------------------------------------------------

  void setSearchQuery(String query) {
    searchQuery = query;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void setStars(int? stars) {
    selectedStars = stars;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void setDestination(String? destinationName) {
    selectedDestination = destinationName;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void clearFilters() {
    selectedStars = null;
    selectedDestination = null;
    searchQuery = "";
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void loadPage(int page) {
    _currentPage = page;
    _applyFiltersAndPagination();
  }

  // ---------------------------------------------------------------------------
  // THE UNIFIED METHOD
  // ---------------------------------------------------------------------------

  void _applyFiltersAndPagination() {
    List<GuestHouse> filteredList = List.from(_allMaisons);

    // 1. Filter by Stars
    if (selectedStars != null) {
      filteredList = filteredList
          .where((m) => (double.tryParse(m.noteGoogle) ?? 0.0) >= selectedStars!)
          .toList();
    }

    // 2. Filter by Destination
    if (selectedDestination != null && selectedDestination != "Toutes") {
      filteredList = filteredList
          .where((m) => m.destination.name.toLowerCase() == selectedDestination!.toLowerCase())
          .toList();
    }

    // 3. Filter by Search Query
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filteredList = filteredList
          .where((m) =>
      m.name.toLowerCase().contains(query) ||
          m.address.toLowerCase().contains(query) ||
          m.destination.name.toLowerCase().contains(query))
          .toList();
    }

    _totalMaisonsCount = filteredList.length;

    // 4. Handle Pagination
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= filteredList.length) {
      _maisons = [];
      _hasMore = false;
    } else {
      _maisons = filteredList.sublist(
        startIndex,
        endIndex.clamp(0, filteredList.length),
      );
      _hasMore = endIndex < filteredList.length;
    }

    notifyListeners();
  }
}