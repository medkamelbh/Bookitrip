import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/review.dart';
import 'package:BookiTrip/services/review_service.dart';
import 'package:flutter/material.dart';

class ReviewsSection extends StatefulWidget {
  final AppTheme theme;
  final String hotelId;

  const ReviewsSection({
    super.key,
    required this.theme,
    required this.hotelId,
  });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final ReviewService _reviewService = ReviewService();
  List<Review> _reviews = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final reviews = await _reviewService.fetchReviews(
        modelId: widget.hotelId,
        model: 'hotel',
      );
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Impossible de charger les avis.';
          _isLoading = false;
        });
      }
    }
  }

  /// Average rating out of 10
  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold<double>(0, (acc, r) {
      final v = r.ratingOutOf10;
      return acc + (v is double ? v : 0.0);
    });
    return sum / _reviews.length;
  }


  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis clients',
              style: TextStyle(
                color: theme.text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!_isLoading && _reviews.isNotEmpty)
              _buildAverageBadge(theme),
          ],
        ),
        const SizedBox(height: 14),

        // ── Body ──────────────────────────────────────────────────────────────
        if (_isLoading)
          _buildSkeleton(theme)
        else if (_error != null)
          _buildError(theme)
        else if (_reviews.isEmpty)
          _buildEmpty(theme)
        else
          _buildReviewList(theme),
      ],
    );
  }

  // ── Average badge (out of 10) ─────────────────────────────────────────────
  Widget _buildAverageBadge(AppTheme theme) {
    final avg = _averageRating;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            '${avg.toStringAsFixed(1)}/10',
            style: TextStyle(
              color: theme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            '  (${_reviews.length})',
            style: TextStyle(
              color: theme.text.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── Review list ───────────────────────────────────────────────────────────
  Widget _buildReviewList(AppTheme theme) {
    return Column(
      children: _reviews.map((r) => _ReviewCard(review: r, theme: theme)).toList(),
    );
  }

  // ── Skeleton loader ───────────────────────────────────────────────────────
  Widget _buildSkeleton(AppTheme theme) {
    return Column(
      children: List.generate(
        2,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                _SkeletonBox(w: 36, h: 36, radius: 18, theme: theme),
                const SizedBox(width: 10),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _SkeletonBox(w: 80, h: 12, radius: 6, theme: theme),
                  const SizedBox(height: 6),
                  _SkeletonBox(w: 60, h: 10, radius: 6, theme: theme),
                ]),
              ]),
              const SizedBox(height: 10),
              _SkeletonBox(w: double.infinity, h: 10, radius: 6, theme: theme),
              const SizedBox(height: 6),
              _SkeletonBox(w: 180, h: 10, radius: 6, theme: theme),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────────
  Widget _buildError(AppTheme theme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline,
              color: theme.text.withValues(alpha: 0.4), size: 36),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
                color: theme.text.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _fetchReviews,
            icon: Icon(Icons.refresh, color: theme.primary, size: 18),
            label: Text('Réessayer',
                style: TextStyle(color: theme.primary)),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmpty(AppTheme theme) {
    return Center(
      child: Column(
        children: [
          Icon(Icons.rate_review_outlined,
              color: theme.text.withValues(alpha: 0.3), size: 40),
          const SizedBox(height: 8),
          Text(
            'Aucun avis pour le moment.',
            style: TextStyle(
              color: theme.text.withValues(alpha: 0.5),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Individual review card ────────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final Review review;
  final AppTheme theme;

  const _ReviewCard({required this.review, required this.theme});

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = review.ratingStars.round().clamp(0, 5);
    final ratingLabel = review.ratingOutOf10.toStringAsFixed(
        review.ratingOutOf10 % 1 == 0 ? 0 : 1);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: avatar + rating info + date
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar placeholder (no user name in API)
              CircleAvatar(
                radius: 18,
                backgroundColor: theme.primary.withValues(alpha: 0.15),
                child: Icon(
                  Icons.person_outline_rounded,
                  color: theme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stars + numeric score
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 14,
                        )),
                        const SizedBox(width: 6),
                        Text(
                          '$ratingLabel/10',
                          style: TextStyle(
                            color: theme.text.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    // Type tag
                    if (review.type != null && review.type!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          review.type!,
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  color: theme.text.withValues(alpha: 0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),

          // Description
          if (review.discription != null &&
              review.discription!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              review.discription!,
              style: TextStyle(
                color: theme.text.withValues(alpha: 0.75),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Skeleton box helper ───────────────────────────────────────────────────────
class _SkeletonBox extends StatelessWidget {
  final double w;
  final double h;
  final double radius;
  final AppTheme theme;

  const _SkeletonBox({
    required this.w,
    required this.h,
    required this.radius,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: theme.text.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
