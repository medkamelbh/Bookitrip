import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/providers/event_provider.dart';
import 'package:TunisiaBook/screens/eventDetails_screen.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:TunisiaBook/widgets/event_card.dart';
import 'package:TunisiaBook/widgets/hotels/filters/filter_section.dart';
import 'package:TunisiaBook/widgets/hotels/hotel_searchbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
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
          'events.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<EventProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: theme.text),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => provider.fetchEvents(),
                    child: Text('common.retry'.tr(), style: TextStyle(color: theme.primary)),
                  ),
                ],
              ),
            );
          }

          final events = provider.events;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SearchBarWidget(
                    theme: theme,
                    onChanged: (query) {
                      provider.setSearchQuery(query);
                    },
                  ),
                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'activities.results'.tr(namedArgs: {'count': events.length.toString()}),
                        style: TextStyle(
                          color: theme.text.withOpacity(0.6),
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Empty state
                  if (events.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64,
                              color: theme.text.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'common.check_connection'.tr(),
                              style: TextStyle(
                                color: theme.text.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            if (provider.searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => provider.clearSearch(),
                                child: Text(
                                  'activities.clear_search'.tr(),
                                  style: TextStyle(color: theme.primary),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                  /// EVENTS LIST VIEW
                  if (events.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: EventCardWidget(
                            theme: theme,
                            title: event.getName(context.locale),
                            location: event.getAddress(context.locale) ?? 'events.no_location'.tr(),
                            imgUrl: event.cover ?? "",
                            date: event.startDate ?? "",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventDetailsScreen(
                                    event: event,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}