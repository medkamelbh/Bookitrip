import 'package:flutter/foundation.dart';
import 'package:BookiTrip/models/story.dart';
import '../repositories/story_repository.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository _repository;

  StoryProvider(this._repository);

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
      _stories = await _repository.fetchStories();
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