import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/cultures/artisanat_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/artisanat_provider.dart';
import 'package:BookiTrip/widgets/hotels/hotel_searchbar.dart';
import 'package:BookiTrip/widgets/skeleton_box.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:BookiTrip/utils/list_transformations.dart';

class ArtisanatScreen extends StatefulWidget {
  const ArtisanatScreen({super.key});

  @override
  State<ArtisanatScreen> createState() => _ArtisanatScreenState();
}

class _ArtisanatScreenState extends State<ArtisanatScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArtisanatProvider>().fetchArtisanats();
    });
  }

  Widget _buildArtisanatSkeletonList(AppTheme theme) {
    Widget cardSkeleton = Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            theme: theme,
            width: double.infinity,
            height: 180,
            radius: 15,
          ),
          const SizedBox(height: 10),
          SkeletonBox(
            theme: theme,
            width: double.infinity,
            height: 20,
            radius: 4,
          ),
          const SizedBox(height: 8),
          SkeletonBox(
            theme: theme,
            width: 150,
            height: 16,
            radius: 4,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SkeletonBox(theme: theme, width: 120, height: 16, radius: 4),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5,
          itemBuilder: (context, index) => cardSkeleton,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final locale = Localizations.localeOf(context);
    const double artisanatCardHeight = 220;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.text),
          onPressed: context.pop,
        ),
        title: Text(
          'cultures.artisanat'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<ArtisanatProvider>(
        builder: (context, artisanatProvider, child) {
          final artisanatList = artisanatProvider.artisanats;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SearchBarWidget(
                  theme: theme,
                  onChanged: (value) {
                    artisanatProvider.setSearchQuery(value, locale);
                  },
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (artisanatProvider.isLoading && artisanatProvider.artisanats.isEmpty)
                          _buildArtisanatSkeletonList(theme)
                        else if (artisanatList.isEmpty && !artisanatProvider.isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.palette_outlined,
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
                                  ),
                                  if (artisanatProvider.searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => artisanatProvider.clearSearch(locale),
                                      child: Text(
                                        'activities.clear_search'.tr(),
                                        style: TextStyle(color: theme.primary),
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () => artisanatProvider.fetchArtisanats(),
                                      icon: Icon(Icons.refresh_rounded, color: theme.primary),
                                      label: Text(
                                        'common.retry'.tr(),
                                        style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        else ...[
                            Text(
                              'activities.results'.tr(namedArgs: {'count': artisanatList.length.toString()}),
                              style: TextStyle(
                                color: theme.text.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 15),

                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: TransformableListView.builder(
                                getTransformMatrix: ListTransformations.getMonumentTransformMatrix,
                                itemCount: artisanatList.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final artisanat = artisanatList[index];

                                  return SizedBox(
                                    height: artisanatCardHeight,
                                    child: ArtisanatCardWidget(
                                      theme: theme,
                                      title: artisanat.getName(locale),
                                      imgUrl: artisanat.vignette.isNotEmpty
                                          ? artisanat.vignette
                                          : artisanat.cover,
                                      onTap: () {
                                        context.pushNamed('artisanatDetails', extra: artisanat);
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        const SizedBox(height: 10),
                      ],
                    ),
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