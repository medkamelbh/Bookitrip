import 'package:BookiTrip/models/event.dart';
import 'package:flutter/material.dart';
import '../repositories/event_repository.dart';

class EventProvider with ChangeNotifier {
  final EventRepository _repository;

  EventProvider(this._repository);

  List<Event> _allEvents = [];
  List<Event> _events = [];
  Event? _selectedEvent;

  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = "";

  List<Event> get events => _events;
  List<Event> get allEvents => _allEvents;
  Event? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allEvents = await _repository.getAllEvents();
      _events = List.from(_allEvents); // Initialize with all events
    } catch (e, stackTrace) {
      debugPrint("Error in fetchEvents (from Repository): $e");
      debugPrint("StackTrace: $stackTrace");
      _errorMessage = "Impossible de charger les événements";
      _allEvents = [];
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set search query and filter events
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = "";
    _events = List.from(_allEvents);
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    List<Event> filtered = List.from(_allEvents);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        final title = (event.title ?? "").toLowerCase();
        final address = (event.address ?? "").toLowerCase();
        final description = (event.description ?? "").toLowerCase();

        return title.contains(_searchQuery) ||
            address.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    _events = filtered;
    notifyListeners();
  }

  // Filter events by destinationId
  List<Event> getEventsByDestination(String destinationId) {
    return _allEvents.where((event) => event.destinationId == destinationId).toList();
  }

  void setEventsByDestination(String destinationId) {
    _events = getEventsByDestination(destinationId);
    notifyListeners();
  }

  Future<void> fetchEventBySlug(String slug) async {
    _isLoading = true;
    notifyListeners();
    try {
      _selectedEvent = _allEvents.firstWhere((event) => event.slug == slug);
    } catch (e) {
      _selectedEvent = null;
      _errorMessage = "Événement introuvable";
      debugPrint("Erreur fetchEventBySlug: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearSelectedEvent() {
    _selectedEvent = null;
    notifyListeners();
  }

  void forceRefresh() {
    _allEvents.clear();
    _events.clear();
    _selectedEvent = null;
    _errorMessage = null;
    _searchQuery = "";
    notifyListeners();
  }
}