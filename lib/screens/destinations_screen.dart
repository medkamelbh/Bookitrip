import 'package:TunisiaBook/constants/theme.dart';
import 'package:TunisiaBook/screens/destinationDetails_screen.dart';
import 'package:TunisiaBook/screens/mainScreen_container.dart';
import 'package:TunisiaBook/widgets/destination_card.dart';
import 'package:TunisiaBook/widgets/hotels/hotel_searchbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/destination_provider.dart';

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  final AppTheme theme;

  const SkeletonBox({
    Key? key,
    required this.width,
    required this.height,
    required this.theme,
    this.radius = 8.0,
  }) : super(key: key);

  @override
  _SkeletonBoxState createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    final Color startColor = widget.theme.text.withOpacity(0.1);
    final Color endColor = widget.theme.text.withOpacity(0.05);

    _animation = ColorTween(
      begin: startColor,
      end: endColor,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _animation.value,
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        );
      },
    );
  }
}

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  void _toggleDrawer() {
    final containerState = context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DestinationProvider>().clearSearch();
      }
    });
  }

  Widget _buildDestinationsSkeleton(AppTheme theme) {
    Widget cardSkeleton = AspectRatio(
      aspectRatio: 0.95,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SkeletonBox(
              theme: theme,
              width: double.infinity,
              height: double.infinity,
              radius: 20,
            ),
          ),
          const SizedBox(height: 10),
          SkeletonBox(theme: theme, width: double.infinity, height: 18, radius: 4),
        ],
      ),
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(theme: theme, width: double.infinity, height: 50, radius: 10),
          const SizedBox(height: 25),
          SkeletonBox(theme: theme, width: 120, height: 16, radius: 4),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15.0,
              mainAxisSpacing: 15.0,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) => cardSkeleton,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final theme = Provider.of<ThemeProvider>(context).currentTheme;
    final destinationProvider = context.watch<DestinationProvider>();
    final destinations = destinationProvider.filteredDestinations;
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
          'destinations.title'.tr(),
          style: TextStyle(color: theme.primary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: destinationProvider.isLoading
          ? _buildDestinationsSkeleton(theme)
          : destinationProvider.error != null
          ? Center(
        child: Text(
          destinationProvider.error!.tr(),
          style: TextStyle(color: const Color(0xFF6C0606)),
        ),
      )
          : SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SearchBarWidget(
                theme: theme,
                hint: 'common.search_placeholder'.tr(),
                onChanged: (value) {
                  if (mounted) {
                    destinationProvider.setSearchQuery(value);
                  }
                },
              ),
              const SizedBox(height: 25),
              Text(
                'activities.results'
                    .tr(namedArgs: {'count': destinations.length.toString()}),
                style: TextStyle(
                  color: theme.text.withOpacity(0.6),
                  fontWeight: FontWeight.w300,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 15),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: destinations.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.0,
                  mainAxisSpacing: 15.0,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final d = destinations[index];
                  return DestinationCardWidget(
                    theme: theme,
                    title: d.getName(locale) ?? 'activities.untitled'.tr(),
                    imgUrl: d.vignette ?? "assets/images/placeholder.jpg",
                    onTap: () {
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DestinationDetailsScreen(
                            title: d.getName(locale) ?? 'activities.untitled'.tr(),
                            description: d.getDescription(locale) ?? "",
                            gallery: d.gallery,
                            destinationId: d.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}