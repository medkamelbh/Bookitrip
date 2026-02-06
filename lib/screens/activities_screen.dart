import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/screens/activityDetails_screen.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:TunisiaBook/widgets/activity_card.dart';
import 'package:TunisiaBook/widgets/hotels/hotel_searchbar.dart';
import 'package:TunisiaBook/providers/activity_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Transformations Imports
import 'package:transformable_list_view/transformable_list_view.dart';
import 'package:TunisiaBook/utils/list_transformations.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  // Constant height to ensure transformation matrices calculate correctly
  static const double activityCardHeight = 220;

  void _toggleDrawer() {
    final containerState =
    context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(
        context,
        listen: false,
      ).fetchAllActivities();
    });
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
          "activities.title".tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<ActivityProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.activities.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonContainer(
                    height: 50,
                    width: double.infinity,
                    borderRadius: 12,
                    theme: theme,
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SkeletonActivityCard(theme: theme),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // --- ERROR STATE ---
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 10),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: theme.text),
                  ),
                  TextButton(
                    onPressed: () => provider.forceRefresh(),
                    child: Text("activities.retry".tr()),
                  ),
                ],
              ),
            );
          }

          final activities = provider.activities;

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SearchBarWidget(
                  theme: theme,
                  onChanged: (query) => provider.setSearchQuery(query),
                ),
                const SizedBox(height: 25),
                Text(
                  "activities.results".tr(
                    namedArgs: {'count': activities.length.toString()},
                  ),
                  style: TextStyle(
                    color: theme.text.withOpacity(0.6),
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 15),

                // --- LIST STATE ---
                Expanded(
                  child: activities.isEmpty
                      ? _buildEmptyState(theme, provider)
                      : TransformableListView.builder(
                    getTransformMatrix:
                    ListTransformations.getMonumentTransformMatrix,
                    itemCount: activities.length,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 40),
                    itemBuilder: (context, index) {
                      final activity = activities[index];
                      final imageUrl = (activity.vignette?.isNotEmpty ??
                          false)
                          ? activity.vignette!
                          : (activity.cover ?? "");

                      return SizedBox(
                        height: activityCardHeight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: ActivityCardWidget(
                            theme: theme,
                            title: activity.getName(context.locale) ??
                                'activities.untitled'.tr(),
                            destId: activity.destinationId ?? "Tunisie",
                            imgUrl: imageUrl,
                            category: activity.getSubtype(context.locale),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ActivityDetailsScreen(
                                          activity: activity),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppTheme theme, ActivityProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.text.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "activities.check_connection".tr(),
            style: TextStyle(
              color: theme.text.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          if (provider.searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => provider.clearSearch(),
              child: Text(
                "activities.clear_search".tr(),
                style: TextStyle(color: theme.primary),
              ),
            ),
        ],
      ),
    );
  }
}

// --- SKELETON WIDGETS ---

class SkeletonContainer extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;
  final AppTheme theme;

  const SkeletonContainer({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 8,
    required this.theme,
  });

  @override
  State<SkeletonContainer> createState() => _SkeletonContainerState();
}

class _SkeletonContainerState extends State<SkeletonContainer> {
  Key _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: _key,
      tween: Tween(begin: 0.2, end: 0.8),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      onEnd: () {
        if (mounted) {
          setState(() {
            _key = UniqueKey();
          });
        }
      },
      builder: (context, opacity, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: widget.theme.primary.withOpacity(opacity * 0.2),
          ),
        );
      },
    );
  }
}

class SkeletonActivityCard extends StatelessWidget {
  final AppTheme theme;

  const SkeletonActivityCard({super.key, required this.theme});

  static const double cardHeight = 220;
  static const double borderRadius = 16;
  static const double padding = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(
        children: [
          SkeletonContainer(
            height: cardHeight,
            width: double.infinity,
            borderRadius: borderRadius,
            theme: theme,
          ),
          Positioned(
            left: padding,
            bottom: 40,
            child: SkeletonContainer(
              height: 20,
              width: 180,
              borderRadius: 4,
              theme: theme,
            ),
          ),
          Positioned(
            left: padding,
            bottom: padding,
            child: SkeletonContainer(
              height: 14,
              width: 120,
              borderRadius: 4,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}