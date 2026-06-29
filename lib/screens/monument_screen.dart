import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/cultures/monument_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/monument_provider.dart';
import 'package:BookiTrip/widgets/hotels/hotel_searchbar.dart';
import 'package:BookiTrip/widgets/skeleton_box.dart';
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:BookiTrip/utils/list_transformations.dart';

class MonumentScreen extends StatefulWidget {
  const MonumentScreen({super.key});

  @override
  State<MonumentScreen> createState() => _MonumentScreenState();
}

class _MonumentScreenState extends State<MonumentScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MonumentProvider>();
      if (provider.monuments.isEmpty) {
        provider.fetchMonuments();
      }
    });
  }

  Widget _buildMonumentSkeletonList(AppTheme theme) {
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
    final locale = context.locale;
    const double monumentCardHeight = 220;


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
          'cultures.monuments'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<MonumentProvider>(
        builder: (context, monumentProvider, child) {
          final monumentList = monumentProvider.monuments;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                SearchBarWidget(
                  theme: theme,
                  onChanged: (value) {
                    monumentProvider.setSearchQuery(value, locale);
                  },
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (monumentProvider.isLoading && monumentProvider.monuments.isEmpty)
                          _buildMonumentSkeletonList(theme)
                        else if (monumentList.isEmpty && !monumentProvider.isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 50.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_city_outlined,
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
                                  if (monumentProvider.searchQuery.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: () => monumentProvider.clearSearch(locale),
                                      child: Text(
                                        'activities.clear_search'.tr(),
                                        style: TextStyle(color: theme.primary),
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: () => monumentProvider.fetchMonuments(),
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
                              'activities.results'.tr(namedArgs: {'count': monumentList.length.toString()}),
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
                                itemCount: monumentList.length,
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final monument = monumentList[index];

                                  return SizedBox(
                                    height: monumentCardHeight,
                                    child: MonumentCardWidget(
                                      theme: theme,
                                      title: monument.getName(locale),
                                      destination: monument.destination.getName(locale),
                                      category: monument.getCategories(locale),
                                      imgUrl: monument.vignette.isNotEmpty
                                          ? monument.vignette
                                          : monument.cover,
                                      onTap: () {
                                        context.pushNamed('monumentDetails', extra: monument);
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