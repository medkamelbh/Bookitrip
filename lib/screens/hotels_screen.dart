import 'package:TunisiaBook/screens/hotelDetails_screen.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:TunisiaBook/widgets/hotels/filters/filter_section.dart';
import 'package:TunisiaBook/widgets/pagination_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/widgets/hotels/hotel_card.dart';
import 'package:TunisiaBook/providers/hotel_provider.dart';
import 'package:TunisiaBook/providers/destination_provider.dart';
import 'package:TunisiaBook/widgets/hotels/hotel_searchbar.dart';
import 'package:TunisiaBook/widgets/skeleton_box.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  late FixedExtentScrollController _wheelScrollController;
  bool _isFetchingMore = false;

  @override
  void initState() {
    super.initState();
    _wheelScrollController = FixedExtentScrollController(initialItem: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoLoadAllPages());
  }

  @override
  void dispose() {
    _wheelScrollController.dispose();
    super.dispose();
  }

  Future<void> _autoLoadAllPages() async {
    final provider = Provider.of<HotelProvider>(context, listen: false);
    if (!provider.hasStartedFetching) {
      await provider.fetchAllHotels();
    }
    if (!provider.hasMorePages || _isFetchingMore) return;

    if (mounted) setState(() => _isFetchingMore = true);
    await provider.continueLoadingAllPages();
    if (mounted) setState(() => _isFetchingMore = false);
  }

  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  void _onPageChanged(int page, HotelProvider provider) {
    provider.loadPage(page);
    if (_wheelScrollController.hasClients) {
      _wheelScrollController.jumpToItem(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final locale = context.locale;
    final size = MediaQuery.of(context).size;

    // Responsive Logic
    final bool isTablet = size.width > 600;
    final double horizontalPadding = isTablet ? size.width * 0.06 : 18.0;
    final double wheelExtent = size.height * 0.28; // Dynamic height for wheel items

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
          'hotels.title'.tr(),
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.bold,
            fontSize: isTablet ? 26 : 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<HotelProvider, DestinationProvider>(
        builder: (context, hotelProvider, destinationProvider, _) {
          final hotelsList = hotelProvider.hotels;
          final bool isLoadingInitial = hotelProvider.isLoading && hotelsList.isEmpty;
          final bool isLoadingMore = _isFetchingMore && hotelsList.isNotEmpty;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                const SizedBox(height: 10),
                SearchBarWidget(theme: theme, onChanged: hotelProvider.setSearchQuery),
                const SizedBox(height: 15),
                FilterSection(theme: theme, type: FilterType.hotel),
                const SizedBox(height: 15),

                Expanded(
                  child: Column(
                    children: [
                      if (isLoadingInitial)
                        Expanded(child: _buildHotelsSkeletonList(theme, isTablet))
                      else if (hotelsList.isEmpty && !hotelProvider.isLoading)
                        Expanded(child: _buildEmptyState(theme, hotelProvider))
                      else
                        Expanded(
                          child: Column(
                            children: [
                              _buildResultHeader(theme, hotelProvider.currentlyFilteredHotels.length, isLoadingMore),
                              const SizedBox(height: 10),
                              Expanded(
                                child: isTablet
                                    ? _buildGridView(hotelsList, theme, locale, size.width)
                                    : _buildWheelView(hotelsList, theme, locale, wheelExtent),
                              ),
                            ],
                          ),
                        ),

                      // Responsive Pagination Wrapper
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02, top: 10),
                        child: PaginationControls(
                          totalPages: hotelProvider.totalPages,
                          currentPage: hotelProvider.currentPage,
                          primaryColor: theme.primary,
                          textColor: theme.text,
                          isEmptyOrLoading: isLoadingInitial,
                          onPageChange: (page) => _onPageChanged(page, hotelProvider),
                        ),
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

  Widget _buildGridView(List hotels, AppTheme theme, Locale locale, double width) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 900 ? 3 : 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: hotels.length,
      itemBuilder: (context, index) => _buildHotelCard(hotels[index], theme, locale),
    );
  }

  Widget _buildWheelView(List hotels, AppTheme theme, Locale locale, double extent) {
    return ListWheelScrollView.useDelegate(
      controller: _wheelScrollController,
      itemExtent: extent,
      perspective: 0.003,
      diameterRatio: 1.8,
      physics: const FixedExtentScrollPhysics(),
      childDelegate: ListWheelChildBuilderDelegate(
        childCount: hotels.length,
        builder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildHotelCard(hotels[index], theme, locale),
        ),
      ),
    );
  }

  Widget _buildHotelCard(dynamic hotel, AppTheme theme, Locale locale) {
    return HotelCardWidget(
      theme: theme,
      title: hotel.getName(locale),
      destination: hotel.getDestinationName(locale) ?? 'hotels.unknown_destination'.tr(),
      imgUrl: hotel.vignette ?? hotel.cover ?? "assets/images/placeholder.jpg",
      rating: hotel.categoryCode?.toDouble() ?? 4.0,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
      ),
    );
  }

  Widget _buildResultHeader(AppTheme theme, int count, bool loadingMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'activities.results'.tr(namedArgs: {'count': count.toString()}),
          style: TextStyle(
              color: theme.text.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500
          ),
        ),
        if (loadingMore)
          const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2)
          ),
      ],
    );
  }

  Widget _buildEmptyState(AppTheme theme, HotelProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 70, color: theme.text.withOpacity(0.2)),
          const SizedBox(height: 15),
          Text('hotels.no_results'.tr(), style: TextStyle(fontSize: 17, color: theme.text)),
          TextButton(
            onPressed: () => provider.clearFilters(),
            child: Text('common.clear_filters'.tr(), style: TextStyle(color: theme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelsSkeletonList(AppTheme theme, bool isTablet) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 2 : 1,
        childAspectRatio: isTablet ? 1.2 : 1.8,
        mainAxisSpacing: 20,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Column(
        children: [
          SkeletonBox(theme: theme, width: double.infinity, height: 160, radius: 15),
          const SizedBox(height: 10),
          SkeletonBox(theme: theme, width: double.infinity, height: 20, radius: 4),
        ],
      ),
    );
  }
}