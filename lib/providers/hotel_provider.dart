import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/hotel_details.dart';
import '../services/api_service.dart';

class HotelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// All fetched hotels from API (accumulated across pages)
  List<Hotel> _allHotels = [];
  List<Hotel> get allHotels => _allHotels;
  bool _hasStartedFetching = false;
  bool get hasStartedFetching => _hasStartedFetching;

  /// Hotels currently displayed on the current UI page
  List<Hotel> _hotels = [];
  List<Hotel> get hotels => _hotels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _selectedDestinationId;
  String? get selectedDestinationId => _selectedDestinationId;

  /// API Pagination state (Fetching from Server)
  int _lastFetchedPage = 0;
  bool _hasMorePages = true;
  bool get hasMorePages => _hasMorePages;

  /// UI Pagination state (Displaying local filtered list)
  final int _displayPageSize = 15;
  int get pageSize => _displayPageSize;

  int _currentDisplayPage = 1;
  // --- ADDED GETTER FOR UI ---
  int get currentPage => _currentDisplayPage;

  /// Hotels matching all active filters
  List<Hotel> _currentlyFilteredHotels = [];
  List<Hotel> get currentlyFilteredHotels => _currentlyFilteredHotels;

  /// Filters
  int? selectedStars;
  String? selectedDestination;
  String searchQuery = "";

  /// Hotel Details
  HotelDetail? _selectedHotel;
  HotelDetail? get selectedHotel => _selectedHotel;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  /// Cached by destination
  final Map<String, List<Hotel>> _hotelsByDestination = {};

  /// Hotels by state (governorate)
  final Map<String, List<Hotel>> _hotelsByState = {};
  String? _currentState;

  List<Hotel> get hotelsByState =>
      _currentState != null ? _hotelsByState[_currentState!] ?? [] : [];

  /// Search API
  List<Hotel> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  List<Hotel> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String? get error => _error;

  // --- ADDED GETTER FOR TOTAL PAGES ---
  int get totalPages => (_currentlyFilteredHotels.length / _displayPageSize).ceil();

  // ---------------------------------------------------------------------------
  // INITIAL FETCH
  // ---------------------------------------------------------------------------
  Future<void> fetchAllHotels() async {
    if (_isLoading || _hasStartedFetching) return;

    _hasStartedFetching = true;
    _isLoading = true;
    _errorDetail = null;
    _allHotels = [];
    _lastFetchedPage = 0;
    _hasMorePages = true;
    notifyListeners();

    try {
      final fetchedHotels = await _apiService.gethotels(page: 1);
      _allHotels = fetchedHotels;
      _lastFetchedPage = 1;

      if (fetchedHotels.length < 15) {
        _hasMorePages = false;
      }

      applyFilters();
    } catch (e) {
      _errorDetail = "Failed to load hotels";
      _allHotels = [];
      debugPrint("❌ Error fetching hotels: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 📄 LOAD MORE PAGES - Fetch next page from API
  // ---------------------------------------------------------------------------
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
      final nextHotels = await _apiService.gethotels(page: nextPage);

      if (nextHotels.isEmpty || nextHotels.length < 15) {
        _hasMorePages = false;
      }

      if (nextHotels.isNotEmpty) {
        _allHotels.addAll(nextHotels);
        _lastFetchedPage = nextPage;
        applyFilters(); // Re-apply filters to include new items
      }
    } catch (e) {
      debugPrint("❌ Error loading more hotels: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🔍 FILTER LOGIC
  // ---------------------------------------------------------------------------
  void setSearchQuery(String value) {
    searchQuery = value.trim().toLowerCase();
    applyFilters();
  }

  void setStars(int? stars) {
    selectedStars = stars;
    applyFilters();
  }

  void setDestination(String? destination) {
    selectedDestination = destination;
    applyFilters();
  }

  void filterByDestination(String destinationId) {
    _selectedDestinationId = destinationId;
    applyFilters();
  }

  void applyFilters() {
    _currentlyFilteredHotels = _allHotels.where((hotel) {
      final matchesSearch =
          hotel.name.toLowerCase().contains(searchQuery) ||
              (hotel.destinationName?.toLowerCase().contains(searchQuery) ?? false);

      final matchesStars =
          selectedStars == null ||
              (hotel.categoryCode?.toInt() ?? 0) == selectedStars;

      final matchesDestinationId =
          _selectedDestinationId == null ||
              hotel.destinationId == _selectedDestinationId;

      final matchesDestination =
          selectedDestination == null ||
              hotel.destinationName == selectedDestination;

      return matchesSearch &&
          matchesStars &&
          matchesDestination &&
          matchesDestinationId;
    }).toList();

    // Always reset to first display page when filters change
    _currentDisplayPage = 1;
    _updateDisplayedHotels();
  }

  void clearFilters() {
    selectedStars = null;
    selectedDestination = null;
    _selectedDestinationId = null;
    searchQuery = "";
    applyFilters();
  }

  // ---------------------------------------------------------------------------
  // 📊 DISPLAY PAGINATION (Local Logic)
  // ---------------------------------------------------------------------------
  void loadPage(int page) {
    _currentDisplayPage = page;
    _updateDisplayedHotels();
  }

  void _updateDisplayedHotels() {
    final start = (_currentDisplayPage - 1) * _displayPageSize;
    final end = start + _displayPageSize;
    final filteredLength = _currentlyFilteredHotels.length;

    if (start >= filteredLength) {
      _hotels = [];
    } else {
      _hotels = _currentlyFilteredHotels.sublist(
        start,
        end > filteredLength ? filteredLength : end,
      );
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 🛏️ HOTEL DETAILS & UTILS
  // ---------------------------------------------------------------------------
  Future<void> fetchHotelDetail(String slug) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    notifyListeners();

    try {
      final detail = await _apiService.gethoteldetail(slug);
      _selectedHotel = detail;
      if (detail == null) _errorDetail = "Hotel details not found.";
    } catch (e) {
      _errorDetail = "Error: $e";
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  void clearSelectedHotel() {
    _selectedHotel = null;
    _errorDetail = null;
    notifyListeners();
  }

  Future<void> fetchHotelsByState(String state) async {
    _isLoading = true;
    _currentState = state;
    notifyListeners();

    try {
      final hotels = await _apiService.getHotelsByState(state);
      _hotelsByState[state] = hotels;
      _hotels = hotels;
    } catch (e) {
      _hotels = [];
      debugPrint("❌ Error fetching hotels by state '$state': $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchHotels(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    _isSearching = true;
    _error = null;
    notifyListeners();
    try {
      _searchResults = await _apiService.searchHotels(query);
    } catch (e) {
      _error = "Failed to search hotels";
      _searchResults = [];
    }
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchResults = [];
    _error = null;
    _isSearching = false;
    notifyListeners();
  }
}