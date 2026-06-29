import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class RestaurantProvider with ChangeNotifier {
  final RestaurantRepository _repository;

  RestaurantProvider(this._repository);

  List<Restaurant> _allRestaurants = [];
  List<Restaurant> get allRestaurants => _allRestaurants;

  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final int _pageSize = 15;
  int get pageSize => _pageSize;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _lastFetchedPage = 0;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _totalRestaurantsCount = 0;
  int get totalRestaurantsCount => _totalRestaurantsCount;
  int get totalPages => (_totalRestaurantsCount / _pageSize).ceil();

  // --- Filter State ---
  String _searchQuery = "";
  String? _currentState;
  double? _minRating;

  String get searchQuery => _searchQuery;
  String? get currentState => _currentState;
  String? _currentDestinationId;
  String? get currentDestinationId => _currentDestinationId;

  double? get minRating => _minRating;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get error => _error;

  List<Restaurant> _searchResults = [];
  List<Restaurant> get searchResults => _searchResults;

  final Map<String, List<Restaurant>> _restaurantsByDestination = {};
  List<Restaurant> getRestaurantsByDestination(String destinationId) =>
      _restaurantsByDestination[destinationId] ?? [];

  Restaurant? _selectedRestaurant;
  Restaurant? get selectedRestaurant => _selectedRestaurant;

  void filterByDestination(String destinationId) {
    _currentDestinationId = destinationId;
    _currentPage = 1;
    _applyFiltersAndPagination();
    notifyListeners();
  }


  void searchRestaurants(String query) {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchQuery = query.toLowerCase();

      if (_searchQuery.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allRestaurants.where((r) {
          final name = r.getName(const Locale("fr")).toLowerCase();
          return name.contains(_searchQuery);
        }).toList();
      }
    } catch (e) {
      _error = "Search failed: $e";
      debugPrint("❌ Search Error: $e");
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Resets search state
  void clearSearch() {
    _searchQuery = "";
    _searchResults = [];
    _isSearching = false;
    _error = null;
    notifyListeners();
  }

  // fetchRestaurants
  Future<void> fetchAllRestaurants() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorDetail = null;
    _allRestaurants = [];
    _currentPage = 1;
    _lastFetchedPage = 0;
    _hasMorePages = true;
    notifyListeners();

    try {
      final fetchedRestaurants = await _repository.getRestaurants(page: 1);
      _allRestaurants = fetchedRestaurants;
      _lastFetchedPage = 1;

      if (fetchedRestaurants.length < 15) {
        _hasMorePages = false;
      }

      _applyFiltersAndPagination();
    } catch (e) {
      _errorDetail = "Failed to load restaurants: $e";
      _allRestaurants = [];
      debugPrint("❌ Error fetching restaurants: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // LOAD MORE PAGES
  Future<void> continueLoadingAllPages() async {
    while (_hasMorePages && !_isLoading) {
      await loadMoreFromAPI();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  Future<void> loadMoreFromAPI() async {
    if (_isLoading || !_hasMorePages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final nextPage = _lastFetchedPage + 1;
      final nextRestaurants = await _repository.getRestaurants(page: nextPage);

      if (nextRestaurants.isEmpty || nextRestaurants.length < 15) {
        _hasMorePages = false;
      }

      if (nextRestaurants.isNotEmpty) {
        _allRestaurants.addAll(nextRestaurants);
        _lastFetchedPage = nextPage;

        // Reapply filters with new data
        _applyFiltersAndPagination();
      }
    } catch (e) {
      debugPrint("❌ Error loading more restaurants: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Filter Setters
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void setStateFilter(String? state) {
    _currentState = state;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void setMinRating(double? rating) {
    _minRating = rating;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void clearFilters() {
    _searchQuery = "";
    _currentState = null;
    _currentDestinationId = null;
    _minRating = null;
    _currentPage = 1;
    _applyFiltersAndPagination();
  }

  void loadPage(int page) {
    _currentPage = page;
    _applyFiltersAndPagination();
  }

  void _applyFiltersAndPagination() {
    List<Restaurant> filtered = List.from(_allRestaurants);

    if (_currentDestinationId != null) {
      filtered = filtered.where((r) =>
      r.destinationId == _currentDestinationId
      ).toList();
    }

    if (_currentState != null) {
      filtered = filtered.where((r) =>
      r.destinationName?.toLowerCase() == _currentState!.toLowerCase()
      ).toList();
    }
    if (_minRating != null) {
      filtered = filtered
          .where((r) => (r.rate is num ? r.rate.toDouble() : 0.0) >= _minRating!)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final name = r.getName(const Locale("fr")).toLowerCase();
        return name.contains(_searchQuery);
      }).toList();
    }

    _totalRestaurantsCount = filtered.length;

    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;

    if (startIndex >= filtered.length) {
      _restaurants = [];
      _hasMore = false;
    } else {
      _restaurants = filtered.sublist(
        startIndex,
        endIndex.clamp(0, filtered.length),
      );
      _hasMore = endIndex < filtered.length;
    }

    notifyListeners();
  }

  Future<void> selectRestaurantBySlug(String slug) async {
    final i = _allRestaurants.indexWhere(
          (r) => r.slug?.toLowerCase() == slug.toLowerCase(),
    );
    _selectedRestaurant = i != -1 ? _allRestaurants[i] : null;
    notifyListeners();
  }

  // ── Restaurant Availability Search ──────────────────────────────────────────

  List<Restaurant> _availabilityResults = [];
  List<Restaurant> get availabilityResults => _availabilityResults;

  bool _isSearchingAvailability = false;
  bool get isSearchingAvailability => _isSearchingAvailability;

  String? _availabilityError;
  String? get availabilityError => _availabilityError;

  String? _lastSearchDestinationId;
  String? _lastSearchDate;
  int? _lastSearchNumber;

  String? get lastSearchDestinationId => _lastSearchDestinationId;
  String? get lastSearchDate => _lastSearchDate;
  int? get lastSearchNumber => _lastSearchNumber;

  /// Searches available restaurants via the rechercherestaut API.
  Future<void> searchAvailableRestaurants({
    required String destinationId,
    required String date,
    required int number,
  }) async {
    _isSearchingAvailability = true;
    _availabilityError = null;
    _availabilityResults = [];
    _lastSearchDestinationId = destinationId;
    _lastSearchDate = date;
    _lastSearchNumber = number;
    notifyListeners();

    try {
      _availabilityResults = await _repository.searchAvailableRestaurants(
        destinationId: destinationId,
        date: date,
        number: number,
      );
    } catch (e) {
      _availabilityError =
          'Impossible de charger les restaurants disponibles. Veuillez réessayer.';
      debugPrint('❌ RestaurantProvider.searchAvailableRestaurants: $e');
    }

    _isSearchingAvailability = false;
    notifyListeners();
  }

  void clearAvailabilityResults() {
    _availabilityResults = [];
    _availabilityError = null;
    _isSearchingAvailability = false;
    _lastSearchDestinationId = null;
    _lastSearchDate = null;
    _lastSearchNumber = null;
    notifyListeners();
  }
}