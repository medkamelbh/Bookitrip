import 'package:flutter/foundation.dart';
import 'package:TunisiaBook/models/story.dart';
import 'package:TunisiaBook/services/api_service.dart';

class StoryProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Story> _stories = [];
  bool _isLoading = false;
  String? _error;

  List<Story> get stories => _stories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch stories from the API
  Future<void> fetchStories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stories = await _apiService.fetchStories();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _stories = [];
      debugPrint('Error fetching stories: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh stories
  Future<void> refreshStories() async {
    await fetchStories();
  }

  /// Clear stories
  void clearStories() {
    _stories = [];
    _error = null;
    notifyListeners();
  }
}