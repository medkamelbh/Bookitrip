import 'package:BookiTrip/constants/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/hotels/filters/filter_section.dart';
import 'package:BookiTrip/widgets/hotels/hotel_card.dart';
import 'package:BookiTrip/widgets/hotels/hotel_searchbar.dart';
import 'package:BookiTrip/widgets/pagination_controls.dart';
import 'package:BookiTrip/widgets/skeleton_box.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/providers/guestHouse_provider.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:BookiTrip/utils/list_transformations.dart';

class GuestHouseScreen extends StatefulWidget {
  const GuestHouseScreen({super.key});

  @override
  State<GuestHouseScreen> createState() => _GuestHouseScreenState();
}

class _GuestHouseScreenState extends State<GuestHouseScreen> {
  bool _isFetchingMore = false;
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoLoadAllPages();
    });
  }

  Future<void> _autoLoadAllPages() async {
    final provider = Provider.of<GuestHouseProvider>(context, listen: false);

    if (!provider.hasMorePages && provider.maisons.isNotEmpty) return;

    if (_isFetchingMore) return;

    if (provider.maisons.isEmpty) {
      await provider.fetchAllGuestHouses();
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
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(theme: theme, width: double.infinity, height: 180, radius: 15),
            const SizedBox(height: 10),
            SkeletonBox(theme: theme, width: 200, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final locale = context.locale;

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
          'guest_houses.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<GuestHouseProvider>(
        builder: (context, provider, child) {
          final bool isLoadingInitial = provider.isLoading && provider.maisons.isEmpty;
          final bool isLoadingMore = _isFetchingMore && provider.maisons.isNotEmpty;

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
                      'activities.results'.tr(namedArgs: {'count': provider.totalMaisonsCount.toString()}),
                      style: TextStyle(
                        color: theme.text.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w300,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isLoadingMore)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    const Spacer(),
                    FilterSection(theme: theme, type: FilterType.guestHouse),
                  ],
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: Column(
                    children: [
                      if (isLoadingInitial)
                        Expanded(child: _buildSkeletonLoader(theme))
                      else if (provider.maisons.isEmpty)
                        Expanded(
                          child: Center(
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
                              itemCount: provider.maisons.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final g = provider.maisons[index];
                                return HotelCardWidget(
                                  theme: theme,
                                  title: g.getName(locale),
                                  destination: g.getAddress(locale),
                                  imgUrl: g.images.isNotEmpty
                                      ? g.images.first
                                      : "https://via.placeholder.com/300x200?text=No+Image",
                                  rating: double.tryParse(g.noteGoogle) ?? 0.0,
                                  isHotel: false,
                                  onTap: () => context.pushNamed('guestHouseDetails', extra: g),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      if (_isAtBottom || provider.maisons.length < 3)
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