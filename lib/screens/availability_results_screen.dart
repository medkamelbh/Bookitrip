import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/hotel.dart';
import 'package:BookiTrip/models/availability_result.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:BookiTrip/widgets/availability/availability_result_card.dart';
import 'package:BookiTrip/widgets/availability/availability_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Available sort modes for the results list.
enum _SortMode { priceAsc, priceDesc, stars, defaultSort }

class AvailabilityResultsScreen extends StatefulWidget {
  const AvailabilityResultsScreen({super.key});

  @override
  State<AvailabilityResultsScreen> createState() =>
      _AvailabilityResultsScreenState();
}

class _AvailabilityResultsScreenState extends State<AvailabilityResultsScreen> {
  _SortMode _sortMode = _SortMode.defaultSort;
  bool _onlyWithPrice = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: _buildAppBar(context, theme),
      body: Consumer<AvailabilityProvider>(
        builder: (context, provider, _) {
          return AvailabilityStatusWidget(
            status: provider.status,
            errorMessage: provider.error,
            onRetry: provider.currentParams != null
                ? () {
                    if (provider.currentParams!.isHotelSpecific) {
                      provider.getHotelAvailability(provider.currentParams!);
                    } else {
                      provider.searchAvailability(provider.currentParams!);
                    }
                  }
                : null,
            theme: theme,
            successChild: _buildResultsList(context, provider, theme),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppTheme theme) {
    return AppBar(
      backgroundColor: theme.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.text),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Disponibilité',
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    AvailabilityProvider provider,
    AppTheme theme,
  ) {
    final params = provider.currentParams;
    final results = _applySortAndFilter(provider.results);

    return Column(
      children: [
        // ── Search summary header ─────────────────────────────────────
        if (params != null) _buildSearchSummary(params, theme),

        // ── Sort & filter bar ─────────────────────────────────────────
        if (provider.results.length > 1)
          _buildSortFilterBar(theme, provider.results),

        // ── Results count ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${results.length} résultat${results.length > 1 ? 's' : ''}',
                style: TextStyle(
                  color: theme.text.withOpacity(0.4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_hasPricedResults(provider.results))
                Text(
                  _onlyWithPrice ? 'Avec prix uniquement' : 'Tous les hôtels',
                  style: TextStyle(
                    color: theme.text.withOpacity(0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            ],
          ),
        ),

        // ── Results list ──────────────────────────────────────────────
        Expanded(
          child: results.isEmpty
              ? _buildNoFilterResults(theme)
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final result = results[index];
                    return AvailabilityResultCard(
                      result: result,
                      theme: theme,
                      onTap: result.hotelSlug != null
                          ? () {
                              final hotel = Hotel(
                                id: result.hotelId,
                                id_hotel_bbx: '',
                                email: '',
                                phone: '',
                                name: result.hotelName,
                                name_en: '',
                                name_ar: '',
                                name_ru: '',
                                name_ja: '',
                                name_ko: '',
                                name_zh: '',
                                address: '',
                                cover: result.cover ?? '',
                                vignette: result.vignette ?? '',
                                images: [],
                                video_link: '',
                                lat: '',
                                lng: '',
                                reservable: result.reservable,
                                slug: result.hotelSlug ?? '',
                                destinationId: '',
                                categoryCode: result.stars,
                                destinationName: result.destinationName,
                              );
                              context.pushNamed('hotelDetails', extra: hotel);
                            }
                          : null,
                      onReserve: result.isAvailable
                          ? () {
                              context.pushNamed('reservation', extra: {
                                'result': result,
                                'params': provider.currentParams!,
                              });
                            }
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Sort & filter bar ─────────────────────────────────────────────────────

  Widget _buildSortFilterBar(AppTheme theme, List<AvailabilityResult> allResults) {
    final hasPriced = _hasPricedResults(allResults);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            // Sort chips
            _buildSortChip(
              theme: theme,
              label: 'Pertinence',
              icon: Icons.auto_awesome_rounded,
              isSelected: _sortMode == _SortMode.defaultSort,
              onTap: () => setState(() => _sortMode = _SortMode.defaultSort),
            ),
            const SizedBox(width: 6),
            if (hasPriced) ...[
              _buildSortChip(
                theme: theme,
                label: 'Prix ↑',
                icon: Icons.arrow_upward_rounded,
                isSelected: _sortMode == _SortMode.priceAsc,
                onTap: () => setState(() => _sortMode = _SortMode.priceAsc),
              ),
              const SizedBox(width: 6),
              _buildSortChip(
                theme: theme,
                label: 'Prix ↓',
                icon: Icons.arrow_downward_rounded,
                isSelected: _sortMode == _SortMode.priceDesc,
                onTap: () => setState(() => _sortMode = _SortMode.priceDesc),
              ),
              const SizedBox(width: 6),
            ],
            _buildSortChip(
              theme: theme,
              label: 'Étoiles',
              icon: Icons.star_rounded,
              isSelected: _sortMode == _SortMode.stars,
              onTap: () => setState(() => _sortMode = _SortMode.stars),
            ),
            if (hasPriced) ...[
              const SizedBox(width: 12),
              // Filter toggle
              _buildFilterToggle(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip({
    required AppTheme theme,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primary.withOpacity(0.12)
              : (theme.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F2)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? theme.primary
                  : theme.text.withOpacity(0.4),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? theme.primary
                    : theme.text.withOpacity(0.55),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle(AppTheme theme) {
    return GestureDetector(
      onTap: () => setState(() => _onlyWithPrice = !_onlyWithPrice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _onlyWithPrice
              ? const Color(0xFF2E7D32).withOpacity(0.10)
              : (theme.isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F2F2)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _onlyWithPrice
                ? const Color(0xFF2E7D32).withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _onlyWithPrice
                  ? Icons.filter_alt_rounded
                  : Icons.filter_alt_off_rounded,
              size: 14,
              color: _onlyWithPrice
                  ? const Color(0xFF2E7D32)
                  : theme.text.withOpacity(0.4),
            ),
            const SizedBox(width: 4),
            Text(
              'Avec prix',
              style: TextStyle(
                color: _onlyWithPrice
                    ? const Color(0xFF2E7D32)
                    : theme.text.withOpacity(0.55),
                fontSize: 12,
                fontWeight: _onlyWithPrice ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sorting & filtering logic ─────────────────────────────────────────────

  List<AvailabilityResult> _applySortAndFilter(List<AvailabilityResult> raw) {
    var results = List<AvailabilityResult>.from(raw);

    // Filter
    if (_onlyWithPrice) {
      results = results.where((r) => r.hasPrice).toList();
    }

    // Sort
    switch (_sortMode) {
      case _SortMode.priceAsc:
        results.sort((a, b) {
          if (a.hasPrice && b.hasPrice) {
            return a.startingPrice!.compareTo(b.startingPrice!);
          }
          return a.hasPrice ? -1 : 1;
        });
        break;
      case _SortMode.priceDesc:
        results.sort((a, b) {
          if (a.hasPrice && b.hasPrice) {
            return b.startingPrice!.compareTo(a.startingPrice!);
          }
          return b.hasPrice ? -1 : 1;
        });
        break;
      case _SortMode.stars:
        results.sort((a, b) =>
            (b.stars ?? 0).compareTo(a.stars ?? 0));
        break;
      case _SortMode.defaultSort:
        // Keep original sort from repository
        break;
    }

    return results;
  }

  bool _hasPricedResults(List<AvailabilityResult> results) =>
      results.any((r) => r.hasPrice);

  Widget _buildNoFilterResults(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt_off_rounded,
            size: 48,
            color: theme.text.withOpacity(0.12),
          ),
          const SizedBox(height: 12),
          Text(
            'Aucun résultat avec les filtres actifs',
            style: TextStyle(
              color: theme.text.withOpacity(0.4),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() {
              _onlyWithPrice = false;
              _sortMode = _SortMode.defaultSort;
            }),
            child: Text(
              'Réinitialiser les filtres',
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSummary(
    dynamic params,
    AppTheme theme,
  ) {
    final p = params as dynamic;
    final checkIn = p.checkIn as DateTime;
    final checkOut = p.checkOut as DateTime;
    final nights = p.nights as int;
    final totalAdults = p.totalAdults as int;
    final totalChildren = p.totalChildren as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range_rounded, size: 18, color: theme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${checkIn.day}/${checkIn.month} → ${checkOut.day}/${checkOut.month} · '
              '$nights nuit${nights > 1 ? 's' : ''} · '
              '$totalAdults adulte${totalAdults > 1 ? 's' : ''}'
              '${totalChildren > 0 ? ' · $totalChildren enfant${totalChildren > 1 ? 's' : ''}' : ''}',
              style: TextStyle(
                color: theme.text.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
