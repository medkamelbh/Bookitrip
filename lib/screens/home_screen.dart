import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/story_provider.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/utils/circuit_data_mapper.dart';
import 'package:BookiTrip/widgets/dataFetch_status.dart';
import 'package:BookiTrip/widgets/category_row.dart';
import 'package:BookiTrip/widgets/circuit_card.dart';
import 'package:BookiTrip/widgets/homeDestSection.dart';
import 'package:BookiTrip/widgets/event_card.dart';
import 'package:BookiTrip/widgets/experiences_section.dart';
import 'package:BookiTrip/widgets/gallery_section.dart';
import 'package:BookiTrip/widgets/horizental_list_view.dart';
import 'package:BookiTrip/widgets/reservation_searchbar.dart';
import 'package:BookiTrip/widgets/search_bar.dart';
import 'package:BookiTrip/widgets/section_title.dart';
import 'package:BookiTrip/widgets/skeleton_cards/circuit_card_skeleton.dart';
import 'package:BookiTrip/widgets/skeleton_cards/destination_card_skeleton.dart';
import 'package:BookiTrip/widgets/skeleton_cards/event_card_skeleton.dart';
import 'package:BookiTrip/widgets/video_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/providers/destination_provider.dart';
import 'package:BookiTrip/providers/event_provider.dart';
import 'package:BookiTrip/providers/voyage_provider.dart';

final List<String> galleryImages = [
  "assets/images/bizerte.jpg",
  "assets/images/sidibou.jpg",
  "assets/images/djerba.jpg",
  "assets/images/tozeur.jpg",
  "assets/images/carthage.jpg",
  "assets/images/circuit1.jpg",
  "assets/images/sousse.jpg",
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().fetchEvents();
      context.read<VoyageProvider>().fetchVoyages();
      context.read<DestinationProvider>().fetchDestinations();
      context.read<StoryProvider>().fetchStories();
    });
  }

  void _toggleDrawer() {
    final containerState = context
        .findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final destinationProvider = context.watch<DestinationProvider>();
    final eventProvider = context.watch<EventProvider>();
    final voyageProvider = context.watch<VoyageProvider>();
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          /// APP BAR
          SliverAppBar(
            backgroundColor: theme.background,
            elevation: 0,
            floating: true,
            leading: IconButton(
              icon: Icon(Icons.menu_rounded, color: theme.text),
              onPressed: _toggleDrawer,
            ),
            title: SizedBox(
              height: 40,
              child: Image.asset(
                'assets/images/logo_bookitrip.png',
                fit: BoxFit.contain,
              ),
            ),
            centerTitle: true,
            /*actions: [
              GestureDetector(
                child: Icon(
                  Icons.account_circle,
                  color: theme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],*/
          ),

          // CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(theme: theme),
                  const SizedBox(height: 20),



                  //ExperiencesReelSection(theme: theme),
                  VideoBanner(theme: theme),
                  const SizedBox(height: 20),
                  CategoryRowWidget(
                    theme: theme,
                    onDestinationsTap: () => context.go('/destinations'),
                    onHotelsTap: () => context.go('/hotels'),
                    onRestaurantsTap: () => context.go('/restaurants'),
                    onCircuitsTap: () => context.go('/circuits'),
                    onChatBotTap: () => context.go('/chatbot'),
                  ),
                  const SizedBox(height: 20),

                  SectionTitleWidget(
                    title: 'home.categories.plan_and_book'.tr(),
                    theme: theme,
                    showMore: false,
                    onTap: () => context.go('/destinations'),
                  ),
                  const SizedBox(height: 10),

                  ReservationSearchWidget(),
                  const SizedBox(height: 20),

                  /// ================= DESTINATIONS =================
                  SectionTitleWidget(
                    title: "home.sections.destinations".tr(),
                    theme: theme,
                    showMore: true,
                    onTap: () => context.go('/destinations'),
                  ),
                  const SizedBox(height: 10),

                  if (destinationProvider.isLoading)
                    HorizontalListView(
                      height: 200,
                      itemCount: 1,
                      itemBuilder: (_, __) =>
                          DestinationCardSkeleton(theme: theme),
                    ),

                  if (!destinationProvider.isLoading &&
                      destinationProvider.error == null &&
                      destinationProvider.destinations.isNotEmpty)
                    NearbyDestinationSection(
                      destinations: destinationProvider.destinations
                          .take(10)
                          .toList(),
                    ),

                  if (!destinationProvider.isLoading &&
                      (destinationProvider.error != null ||
                          destinationProvider.destinations.isEmpty))
                    SizedBox(
                      height: 210,
                      child: Center(
                        child: DataFetchStatusWidget(
                          theme: theme,
                          errorMessage: destinationProvider.error,
                          isLoading: destinationProvider.isLoading,
                          itemCount: destinationProvider.destinations.length,
                          onRetry: destinationProvider.fetchDestinations,
                          emptyMessage: "common.check_connection".tr(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// ================= CIRCUITS =================
                  SectionTitleWidget(
                    title: "home.sections.circuits".tr(),
                    theme: theme,
                    showMore: true,
                    onTap: () => context.go('/circuits'),
                  ),
                  const SizedBox(height: 10),

                  if (voyageProvider.isLoading)
                    HorizontalListView(
                      height: 180,
                      itemCount: 3,
                      itemBuilder: (_, __) => CircuitCardSkeleton(theme: theme),
                    ),

                  if (!voyageProvider.isLoading &&
                      voyageProvider.error == null &&
                      voyageProvider.voyages.isNotEmpty)
                    HorizontalListView(
                      height: 190,
                      itemCount: voyageProvider.voyages.length > 6
                          ? 6
                          : voyageProvider.voyages.length,
                      itemBuilder: (context, index) {
                        final voyage = voyageProvider.voyages[index];
                        final circuit = voyageToCircuitCardData(voyage, locale);
                        return GestureDetector(
                          onTap: () => context.pushNamed(
                            'circuitDetails',
                            extra: voyage,
                          ),
                          child: CircuitCardWidget(
                            theme: theme,
                            title: circuit["title"]!,
                            subtitle: circuit["subtitle"]!,
                            imgUrl: circuit["image"]!,
                          ),
                        );
                      },
                    ),

                  if (!voyageProvider.isLoading &&
                      (voyageProvider.error != null ||
                          voyageProvider.voyages.isEmpty))
                    SizedBox(
                      height: 210,
                      child: Center(
                        child: DataFetchStatusWidget(
                          theme: theme,
                          errorMessage: voyageProvider.error,
                          isLoading: voyageProvider.isLoading,
                          itemCount: voyageProvider.voyages.length,
                          onRetry: voyageProvider.fetchVoyages,
                          emptyMessage: "common.check_connection".tr(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 10),

                  // ================= EVENTS =================
                  SectionTitleWidget(
                    title: "home.sections.events".tr(),
                    theme: theme,
                    showMore: true,
                    onTap: () => context.go('/events'),
                  ),
                  const SizedBox(height: 10),

                  if (!eventProvider.isLoading &&
                      eventProvider.errorMessage == null &&
                      eventProvider.events.isNotEmpty)
                    HorizontalListView(
                      height: 240,
                      itemCount: eventProvider.events.length > 6
                          ? 6
                          : eventProvider.events.length,
                      itemBuilder: (_, index) {
                        final event = eventProvider.events[index];
                        return GestureDetector(
                          onTap: () => context.push(
                            '/event-details/${event.id}',
                            extra: {'event': event},
                          ),
                          child: EventCardWidget(
                            theme: theme,
                            title:
                                event.getName(locale) ?? "events.no_title".tr(),
                            location:
                                event.getAddress(locale) ??
                                "events.no_location".tr(),
                            date: event.startDate ?? "events.no_date".tr(),
                            imgUrl: event.cover ?? event.image ?? "",
                          ),
                        );
                      },
                    ),

                  if (!eventProvider.isLoading &&
                      (eventProvider.errorMessage != null ||
                          eventProvider.events.isEmpty))
                    SizedBox(
                      height: 240,
                      child: Center(
                        child: DataFetchStatusWidget(
                          theme: theme,
                          errorMessage: eventProvider.errorMessage,
                          isLoading: eventProvider.isLoading,
                          itemCount: eventProvider.events.length,
                          onRetry: eventProvider.fetchEvents,
                          emptyMessage: "common.check_connection".tr(),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  GallerySectionWidget(
                    theme: theme,
                    galleryImages: galleryImages,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
