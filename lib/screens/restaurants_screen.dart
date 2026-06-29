import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/restaurant_provider.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:go_router/go_router.dart';
import 'package:BookiTrip/widgets/hotels/filters/filter_section.dart';
import 'package:BookiTrip/widgets/hotels/hotel_searchbar.dart';
import 'package:BookiTrip/widgets/pagination_controls.dart';
import 'package:BookiTrip/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:BookiTrip/utils/list_transformations.dart';
import '../widgets/skeleton_box.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _isAtBottom = false;
  static const double restaurantCardHeight = 220;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadAllPages();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _autoLoadAllPages() async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);

    if (!provider.hasMorePages && provider.allRestaurants.isNotEmpty) return;

    if (_isFetchingMore) return;

    if (provider.restaurants.isEmpty) {
      await provider.fetchAllRestaurants();
    }

    if (mounted) setState(() => _isFetchingMore = true);

    while (provider.hasMorePages && mounted) {
      await provider.loadMoreFromAPI();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (mounted) setState(() => _isFetchingMore = false);
  }

  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  Widget _buildSkeletonLoader(AppTheme theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          decoration: BoxDecoration(
            color: theme.CardBG,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              SkeletonBox(theme: theme, height: 130, width: double.infinity, radius: 15),
              Padding(
                padding: const EdgeInsets.all(15),
                child: SkeletonBox(theme: theme, height: 18, width: 120, radius: 4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: theme.text),
          onPressed: _toggleDrawer,
        ),
        title: Text(
          'restaurants.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          final bool isLoadingInitial = provider.isLoading && provider.restaurants.isEmpty;
          final bool isLoadingMore = _isFetchingMore && provider.restaurants.isNotEmpty;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(
                  theme: theme,
                  onChanged: (query) => provider.setSearchQuery(query),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Text(
                      'activities.results'.tr(namedArgs: {'count': provider.totalRestaurantsCount.toString()}),
                      style: TextStyle(
                        color: theme.text.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLoadingMore)
                      Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                            ),
                          ),
                        ],
                      ),
                    const Spacer(),
                    FilterSection(theme: theme, type: FilterType.restaurant),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      if (isLoadingInitial)
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: _buildSkeletonLoader(theme),
                          ),
                        )
                      else if (provider.restaurants.isEmpty)
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 64,
                                    color: theme.text.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'common.check_connection'.tr(),
                                    style: TextStyle(
                                      color: theme.text.withValues(alpha: 0.6),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: () => _autoLoadAllPages(),
                                    icon: Icon(Icons.refresh_rounded, color: theme.primary),
                                    label: Text(
                                      'common.retry'.tr(),
                                      style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 20) {
                                if (!_isAtBottom) setState(() => _isAtBottom = true);
                              } else {
                                if (_isAtBottom) setState(() => _isAtBottom = false);
                              }
                              return false;
                            },
                            child: TransformableListView.builder(
                              getTransformMatrix: ListTransformations.getMonumentTransformMatrix,
                              itemCount: provider.restaurants.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final r = provider.restaurants[index];
                                return SizedBox(
                                  height: restaurantCardHeight,
                                  child: RestaurantCardWidget(
                                    title: r.getName(Localizations.localeOf(context)),
                                    location: r.getDestinationName(Localizations.localeOf(context)) ?? 'restaurants.unknown'.tr(),
                                    imgUrl: r.images.isNotEmpty ? r.images.first : "assets/images/placeholder.jpg",
                                    rating: (r.rate is num) ? r.rate.toDouble() : 4.0,
                                    onTap: () => context.pushNamed('restaurantDetails', extra: r),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      if (_isAtBottom || provider.restaurants.length < 3)
                        PaginationControls(
                          totalPages: provider.totalPages,
                          currentPage: provider.currentPage,
                          primaryColor: theme.primary,
                          textColor: theme.text,
                          isEmptyOrLoading: isLoadingInitial,
                          onPageChange: (page) => provider.loadPage(page),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}