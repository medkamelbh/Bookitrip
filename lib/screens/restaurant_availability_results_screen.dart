import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/restaurant_provider.dart';
import 'package:BookiTrip/widgets/restaurant_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Screen that displays restaurant search results from the rechercherestaut API.
class RestaurantAvailabilityResultsScreen extends StatelessWidget {
  const RestaurantAvailabilityResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: _buildAppBar(context, theme),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, _) {
          // Loading state
          if (provider.isSearchingAvailability) {
            return _buildLoadingState(theme);
          }

          // Error state
          if (provider.availabilityError != null) {
            return _buildErrorState(theme, provider);
          }

          // Empty state
          if (provider.availabilityResults.isEmpty) {
            return _buildEmptyState(theme);
          }

          // Results
          return _buildResults(context, theme, provider, locale);
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
        'Restaurants disponibles',
        style: TextStyle(
          color: theme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLoadingState(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: theme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Recherche en cours...',
            style: TextStyle(
              color: theme.text.withOpacity(0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AppTheme theme, RestaurantProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.text.withOpacity(0.15),
            ),
            const SizedBox(height: 16),
            Text(
              provider.availabilityError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                if (provider.lastSearchDestinationId != null &&
                    provider.lastSearchDate != null &&
                    provider.lastSearchNumber != null) {
                  provider.searchAvailableRestaurants(
                    destinationId: provider.lastSearchDestinationId!,
                    date: provider.lastSearchDate!,
                    number: provider.lastSearchNumber!,
                  );
                }
              },
              icon: Icon(Icons.refresh_rounded, color: theme.primary),
              label: Text(
                'Réessayer',
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_outlined,
              size: 56,
              color: theme.text.withOpacity(0.12),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun restaurant disponible',
              style: TextStyle(
                color: theme.text.withOpacity(0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos critères de recherche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.text.withOpacity(0.35),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    AppTheme theme,
    RestaurantProvider provider,
    Locale locale,
  ) {
    final results = provider.availabilityResults;

    return Column(
      children: [
        // Search summary
        _buildSearchSummary(theme, provider),

        // Results count
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
            ],
          ),
        ),

        // Results list
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final restaurant = results[index];
              return _buildRestaurantCard(context, theme, restaurant, locale);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSummary(AppTheme theme, RestaurantProvider provider) {
    final date = provider.lastSearchDate;
    final number = provider.lastSearchNumber;

    if (date == null || number == null) return const SizedBox.shrink();

    // Parse date for display
    String displayDate = date;
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        displayDate = '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (_) {}

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
          Icon(Icons.restaurant_rounded, size: 18, color: theme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$displayDate · $number personne${number > 1 ? 's' : ''}',
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

  Widget _buildRestaurantCard(
    BuildContext context,
    AppTheme theme,
    dynamic restaurant,
    Locale locale,
  ) {
    final name = restaurant.getName(locale);
    final location = restaurant.getDestinationName(locale);
    final imgUrl = restaurant.images.isNotEmpty
        ? restaurant.images.first
        : (restaurant.cover ?? restaurant.vignette ?? '');
    final rating = (restaurant.rate is num) ? restaurant.rate.toDouble() : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.isDark ? Colors.white.withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.pushNamed('restaurantDetails', extra: restaurant),
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: SizedBox(
                height: 150,
                child: imgUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imgUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          color: theme.primary.withOpacity(0.08),
                          child: Center(
                            child: Icon(Icons.restaurant_rounded,
                                size: 36,
                                color: theme.primary.withOpacity(0.3)),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: theme.primary.withOpacity(0.08),
                          child: Icon(Icons.broken_image_outlined,
                              size: 36,
                              color: theme.primary.withOpacity(0.3)),
                        ),
                      )
                    : Container(
                        color: theme.primary.withOpacity(0.08),
                        child: Icon(Icons.restaurant_rounded,
                            size: 36,
                            color: theme.primary.withOpacity(0.3)),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (location.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 14, color: theme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: TextStyle(
                              color: theme.text.withOpacity(0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (rating > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 16, color: Colors.amber.shade600),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(
                            color: theme.text.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
