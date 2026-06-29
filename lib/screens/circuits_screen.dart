import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/search_reservation/circuit_body.dart';
import 'package:BookiTrip/widgets/circuit_card_ver.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/voyage_provider.dart';
import 'package:BookiTrip/models/voyage.dart';

class CircuitScreen extends StatefulWidget {
  const CircuitScreen({super.key});

  @override
  State<CircuitScreen> createState() => _CircuitScreenState();
}

class _CircuitScreenState extends State<CircuitScreen> {
  final Map<String, Map<String, dynamic>> _cardDataCache = {};

  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoyageProvider>().fetchVoyages();
    });
  }

  Map<String, dynamic> _voyageToCardData(Voyage voyage, Locale locale) {
    final cacheKey = '${voyage.id}_${locale.languageCode}';
    if (_cardDataCache.containsKey(cacheKey)) {
      return _cardDataCache[cacheKey]!;
    }

    final progress = ((voyage.id.hashCode % 100) / 100).clamp(0.4, 0.9);

    final daysText = 'circuits.days'.tr();
    final duration = voyage.number.isNotEmpty
        ? '${voyage.number} $daysText'
        : '3 $daysText';

    final name = voyage.getName(locale);
    String startDest = 'Tunis';
    String endDest = 'Various';

    if (name.contains(' - ')) {
      final parts = name.split(' - ');
      if (parts.length >= 2) {
        endDest = parts.last.split(':').first.trim();
      }
    } else if (name.toLowerCase().contains('djerba')) {
      endDest = 'Djerba';
    } else if (name.toLowerCase().contains('douz')) {
      endDest = 'Douz';
    } else if (name.toLowerCase().contains('tozeur')) {
      endDest = 'Tozeur';
    } else if (name.toLowerCase().contains('tabarka')) {
      endDest = 'Tabarka';
    }

    final cardData = {
      'id': voyage.id,
      'title': name,
      'duration': duration,
      'startDestination': startDest,
      'endDestination': endDest,
      'image': voyage.images.length > 1
          ? voyage.images[1]
          : (voyage.images.isNotEmpty ? voyage.images[0] : 'assets/images/circuit1.jpg'),
      'progress': progress,
    };

    _cardDataCache[cacheKey] = cardData;
    return cardData;
  }

  void _navigateToDetails(BuildContext context, Voyage voyage) {
    context.pushNamed('circuitDetails', extra: voyage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final voyageProvider = Provider.of<VoyageProvider>(context);
    final locale = Localizations.localeOf(context);
    final voyages = voyageProvider.voyages;

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
          'circuits.title'.tr(),
          style: TextStyle(
            color: theme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: voyageProvider.isLoading
          ? Center(
        child: CircularProgressIndicator(color: theme.primary),
      )
          : voyageProvider.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.text.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'errors.fetch_failed'.tr(),
              style: TextStyle(color: theme.text, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => voyageProvider.fetchVoyages(),
              child: Text('common.retry'.tr(), style: TextStyle(color: theme.primary)),
            ),
          ],
        ),
      )
          : voyages.isEmpty
          ? Center(
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
                    style: TextStyle(color: theme.text, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => voyageProvider.fetchVoyages(),
                    icon: Icon(Icons.refresh_rounded, color: theme.primary),
                    label: Text(
                      'common.retry'.tr(),
                      style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'circuits.create_yours'.tr(),
                    style: TextStyle(
                      color: theme.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CircuitBody(
                    theme: theme,
                    onManualTap: () => context.push('/manual-circuit'),
                    onAutoTap: () => context.push('/auto-circuit'),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 12),
            sliver: SliverToBoxAdapter(
              child: Text(
                'circuits.all'.tr(),
                style: TextStyle(
                  color: theme.text,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: voyages.length,
              separatorBuilder: (context, index) => const SizedBox(height: 15),
              itemBuilder: (context, index) {
                final voyage = voyages[index];
                final circuit = _voyageToCardData(voyage, locale);

                return SizedBox(
                  height: 200,
                  child: CircuitCard(
                    theme: theme,
                    title: circuit["title"]!,
                    duration: circuit["duration"]!,
                    startDestination: circuit["startDestination"]!,
                    endDestination: circuit["endDestination"]!,
                    imgUrl: circuit["image"]!,
                    progress: circuit["progress"] ?? 0.5,
                    onTap: () => _navigateToDetails(context, voyage),
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardDataCache.clear();
    super.dispose();
  }
}