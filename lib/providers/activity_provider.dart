import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../repositories/activity_repository.dart';

class ActivityProvider with ChangeNotifier {
  final ActivityRepository _repository;

  ActivityProvider(this._repository);

  /// Cached activities per destination
  final Map<String, List<Activity>> _activitiesByDestination = {};

  /// All fetched activities
  List<Activity> allActivities = [];

  /// Current displayed activities (filtered/searched)
  List<Activity> _activities = [];
  List<Activity> get activities => _activities;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Activity? selectedActivity;

  // Search
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  int _totalActivitiesCount = 0;
  int get totalActivitiesCount => _totalActivitiesCount;

  /// Flag to track if all activities have been fetched
  bool _allActivitiesFetched = false;

  /// Fetch all activities once
  Future<void> fetchAllActivities() async {
    if (_allActivitiesFetched || _isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      allActivities = await _repository.getAllActivities();
      _allActivitiesFetched = true;

      _activitiesByDestination.clear();

      // Pre-cache per destination
      for (var activity in allActivities) {
        final destId = activity.destinationId?.toString() ?? 'unknown';
        _activitiesByDestination.putIfAbsent(destId, () => []);
        _activitiesByDestination[destId]!.add(activity);
      }

      _activities = List.from(allActivities);
      _totalActivitiesCount = allActivities.length;

    } catch (e) {
      allActivities = [];
      _activities = [];
      _allActivitiesFetched = false;
      _errorMessage = "Erreur lors du chargement: $e";
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Original method maintained for backward compatibility
  Future<void> fetchActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _activities = await _repository.getAllActivities();

      // Update allActivities and cache
      allActivities = _activities;
      _allActivitiesFetched = true;

      // Clear and rebuild cache
      _activitiesByDestination.clear();
      for (var activity in allActivities) {
        final destId = activity.destinationId?.toString() ?? 'unknown';
        _activitiesByDestination.putIfAbsent(destId, () => []);
        _activitiesByDestination[destId]!.add(activity);
      }

      _totalActivitiesCount = _activities.length;

    } catch (e) {
      _activities = [];
      _errorMessage = "Erreur lors du chargement: $e";
      debugPrint(_errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  // Get activities by destination from cache
  void setActivitiesByDestination(String destinationId) {
    _activities = _activitiesByDestination[destinationId] ?? [];
    _totalActivitiesCount = _activities.length;
    _errorMessage = _activities.isEmpty ? "No activities found for destination $destinationId" : null;
    notifyListeners();
  }

  /// Optional: get activities by destination directly
  List<Activity> getActivitiesByDestination(String destinationId) {
    return _activitiesByDestination[destinationId] ?? [];
  }

  /// Original method maintained for backward compatibility
  List<Activity> getByCity(String cityId) {
    return _activities.where((a) => a.cityId == cityId).toList();
  }

  /// Fetch single activity by slug
  Future<Activity?> fetchActivityBySlug(String slug) async {
    try {
      // First try to find in cached activities
      if (allActivities.isNotEmpty) {
        final activity = allActivities.firstWhere(
              (a) => a.slug == slug,
          orElse: () => Activity(id: '', title: 'Non trouvé'),
        );

        if (activity.id.isNotEmpty) {
          selectedActivity = activity;
          notifyListeners();
          return activity;
        }
      }

      // If not found in cache, fetch from API
      final activities = await _repository.getAllActivities();
      final activity = activities.firstWhere(
            (a) => a.slug == slug,
        orElse: () => Activity(id: '', title: 'Non trouvé'),
      );

      selectedActivity = activity.id.isNotEmpty ? activity : null;
      notifyListeners();
      return activity.id.isNotEmpty ? activity : null;
    } catch (e) {
      debugPrint("Erreur fetchActivityBySlug: $e");
      selectedActivity = null;
      notifyListeners();
      return null;
    }
  }

  /// Clear selected activity
  void clearSelectedActivity() {
    selectedActivity = null;
    notifyListeners();
  }

  /// Force refresh all data
  void forceRefresh() {
    _allActivitiesFetched = false;
    _activitiesByDestination.clear();
    allActivities.clear();
    _activities.clear();
    selectedActivity = null;
    _errorMessage = null;
    _searchQuery = "";
    _totalActivitiesCount = 0;
    notifyListeners();
  }

  /// Set search query and apply filter
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFiltersAndPagination();
  }

  /// Apply filters and update the _activities list
  void _applyFiltersAndPagination() {
    List<Activity> filtered = List.from(allActivities);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((a) {
        final name = a.getName(const Locale("fr")).toLowerCase();
        final title = (a.title ?? "").toLowerCase();
        return name.contains(_searchQuery) || title.contains(_searchQuery);
      }).toList();
    }

    _activities = filtered;
    _totalActivitiesCount = filtered.length;

    notifyListeners();
  }

  /// Clear search and show all activities
  void clearSearch() {
    _searchQuery = "";
    _activities = List.from(allActivities);
    _totalActivitiesCount = allActivities.length;
    notifyListeners();
  }
}