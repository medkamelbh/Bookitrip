import 'package:TunisiaBook/widgets/reel_circle.dart';
import 'package:TunisiaBook/widgets/section_title.dart';
import 'package:TunisiaBook/widgets/story_viewer.dart';
import 'package:TunisiaBook/widgets/horizental_list_view.dart';
import 'package:TunisiaBook/widgets/story_circle_skeleton.dart';
import 'package:TunisiaBook/widgets/dataFetch_status.dart';
import 'package:TunisiaBook/providers/story_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:TunisiaBook/constants/theme.dart';

class ExperiencesReelSection extends StatelessWidget {
  final AppTheme theme;

  const ExperiencesReelSection({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final storyProvider = context.watch<StoryProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(title: "home.sections.moments".tr(), theme: theme),
        const SizedBox(height: 15),

        // Loading state
        if (storyProvider.isLoading)
          HorizontalListView(
            height: 105,
            itemCount: 5,
            itemBuilder: (_, __) => StoryCircleSkeleton(theme: theme),
          ),

        // Success state with data
        if (!storyProvider.isLoading &&
            storyProvider.error == null &&
            storyProvider.stories.isNotEmpty)
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: storyProvider.stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final story = storyProvider.stories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => StoryViewerScreen(
                          story: story,
                          locale: locale,
                        ),
                      ),
                    );
                  },
                  child: ReelCircleWidget(
                    theme: theme,
                    title: story.getName(locale),
                    imgUrl: story.images.isNotEmpty ? story.images.first : '',
                  ),
                );
              },
            ),
          ),

        // Error or empty state
        if (!storyProvider.isLoading &&
            (storyProvider.error != null || storyProvider.stories.isEmpty))
          SizedBox(
            height: 105,
            child: Center(
              child: DataFetchStatusWidget(
                theme: theme,
                errorMessage: storyProvider.error,
                isLoading: storyProvider.isLoading,
                itemCount: storyProvider.stories.length,
                onRetry: storyProvider.fetchStories,
                emptyMessage: "common.check_connection".tr(),
              ),
            ),
          ),
      ],
    );
  }
}