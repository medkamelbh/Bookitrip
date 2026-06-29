import 'package:flutter/material.dart';
import '../models/artisanat.dart';
import '../repositories/artisanat_repository.dart';

class ArtisanatProvider with ChangeNotifier {
  final ArtisanatRepository _repository;

  ArtisanatProvider(this._repository);

  List<Artisanat> _allArtisanats = [];
  List<Artisanat> _artisanats = [];
  Artisanat? _selectedArtisanat;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = "";

  List<Artisanat> get artisanats => _artisanats;
  List<Artisanat> get allArtisanats => _allArtisanats;
  Artisanat? get selectedArtisanat => _selectedArtisanat;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> fetchArtisanats() async {
    _setLoading(true);
    try {
      _allArtisanats = await _repository.getArtisanats();
      _artisanats = List.from(_allArtisanats); // Initialize with all artisanats
      _error = null;
    } catch (e) {
      _allArtisanats = [];
      _artisanats = [];
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Set search query and filter artisanats
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
    List<Artisanat> filtered = List.from(_allArtisanats);

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((artisanat) {
        final name = artisanat.getName(locale).toLowerCase();
        final description = artisanat.getDescription(locale).toLowerCase();

        return name.contains(_searchQuery) ||
            description.contains(_searchQuery);
      }).toList();
    }

    _artisanats = filtered;
    notifyListeners();
  }

  Future<void> fetchArtisanatBySlug(String slug) async {
    _setLoading(true);
    _selectedArtisanat = null;
    _error = null;

    try {
      // First, try to find in existing artisanats list
      final existingArtisanat = _allArtisanats.firstWhere(
            (artisanat) => artisanat.slug == slug,
        orElse: () => Artisanat(
          id: '',
          name: '',
          nameEn: '',
          nameKo: '',
          nameAr: '',
          nameZh: '',
          nameRu: '',
          nameJa: '',
          description: '',
          descriptionEn: '',
          descriptionKo: '',
          descriptionAr: '',
          descriptionZh: '',
          descriptionRu: '',
          descriptionJa: '',
          slug: '',
          videoLink: '',
          cover: '',
          vignette: '',
          images: [],
        ),
      );

      if (existingArtisanat.id.isNotEmpty) {
        _selectedArtisanat = existingArtisanat;
      } else {
        _selectedArtisanat = await _repository.getArtisanatBySlug(slug);
      }
    } catch (e) {
      _error = e.toString();
      _selectedArtisanat = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshArtisanats() async => fetchArtisanats();

  // Clear selected artisanat (useful when navigating away)
  void clearSelectedArtisanat() {
    _selectedArtisanat = null;
    notifyListeners();
  }

  // Reset error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Force refresh
  void forceRefresh() {
    _allArtisanats.clear();
    _artisanats.clear();
    _selectedArtisanat = null;
    _error = null;
    _searchQuery = "";
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}