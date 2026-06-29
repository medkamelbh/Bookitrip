// screens/story_viewer_screen.dart

import 'package:flutter/material.dart';
import 'package:BookiTrip/models/story.dart';
import 'dart:async';

class StoryViewerScreen extends StatefulWidget {
  // Support both old format (segments) and new format (story model)
  final List<Map<String, dynamic>>? segments;
  final String? reelTitle;
  final Story? story;
  final Locale? locale;

  const StoryViewerScreen({
    super.key,
    this.segments,
    this.reelTitle,
    this.story,
    this.locale,
  }) : assert(
  (segments != null && reelTitle != null) || story != null,
  'Either provide segments+reelTitle OR story',
  );

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _storySegmentPageController;
  int _currentStorySegmentIndex = 0;
  Timer? _timer;
  double _progress = 0.0;
  Duration _storyDuration = const Duration(seconds: 3);

  List<String> get _imageUrls {
    if (widget.story != null) {
      return widget.story!.images;
    } else {
      return widget.segments!.map((s) => s['url'] as String).toList();
    }
  }

  String get _title {
    if (widget.story != null && widget.locale != null) {
      return widget.story!.getName(widget.locale!);
    } else if (widget.story != null) {
      return widget.story!.name;
    } else {
      return widget.reelTitle!;
    }
  }

  @override
  void initState() {
    super.initState();
    _storySegmentPageController =
        PageController(initialPage: _currentStorySegmentIndex);
    _startStoryTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _storySegmentPageController.dispose();
    super.dispose();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    setState(() {
      _progress = 0.0;
    });

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;

      setState(() {
        _progress += 0.5 / (_storyDuration.inMilliseconds / 50);
        if (_progress >= 1.0) {
          _timer?.cancel();
          _nextStorySegment();
        }
      });
    });
  }

  void _nextStorySegment() {
    if (_currentStorySegmentIndex < _imageUrls.length - 1) {
      _currentStorySegmentIndex++;
      _storySegmentPageController.animateToPage(
        _currentStorySegmentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _startStoryTimer();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _previousStorySegment() {
    if (_currentStorySegmentIndex > 0) {
      _currentStorySegmentIndex--;
      _storySegmentPageController.animateToPage(
        _currentStorySegmentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
      _startStoryTimer();
    } else {
      // First story segment of the reel. Pop the screen.
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          // Pause timer when screen is touched
          _timer?.cancel();
        },
        onTapUp: (details) {
          if (details.globalPosition.dx <
              MediaQuery.of(context).size.width / 2) {
            _previousStorySegment();
          } else {
            _nextStorySegment();
          }
          if (_timer == null || !_timer!.isActive) {
            _startStoryTimer();
          }
        },
        child: Stack(
          children: [
            // Story Content (Image)
            PageView.builder(
              controller: _storySegmentPageController,
              itemCount: _imageUrls.length,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                if (_currentStorySegmentIndex != index) {
                  _currentStorySegmentIndex = index;
                  _startStoryTimer();
                }
              },
              itemBuilder: (context, index) {
                return Center(
                  child: Image.network(
                    _imageUrls[index],
                    fit: BoxFit.contain,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 80,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Failed to load image',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // Progress Indicators
            Positioned(
              top: 40,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(_imageUrls.length, (index) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: LinearProgressIndicator(
                        value: index == _currentStorySegmentIndex
                            ? _progress
                            : (index < _currentStorySegmentIndex ? 1.0 : 0.0),
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Reel Title/User Info
            Positioned(
              top: 65,
              left: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // Close Button
            Positioned(
              top: 55,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}