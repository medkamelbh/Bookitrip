import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/availability_search_params.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';
import 'package:BookiTrip/models/destination.dart';
import 'package:BookiTrip/providers/availability_provider.dart';
import 'package:BookiTrip/providers/restaurant_provider.dart';
import 'package:BookiTrip/widgets/availability/availability_search_modal.dart';
import 'package:BookiTrip/widgets/availability/destination_picker_sheet.dart';
import 'package:BookiTrip/widgets/search_reservation/circuit_body.dart';
// import 'package:BookiTrip/widgets/search_reservation/forms/evenements_form.dart';
import 'package:BookiTrip/widgets/search_reservation/forms/hotels_form.dart';
import 'package:BookiTrip/widgets/search_reservation/forms/restos_form.dart';
import 'package:BookiTrip/widgets/search_reservation/forms/transports_form.dart';
// import 'package:BookiTrip/widgets/search_reservation/forms/vols_form.dart';
import 'package:BookiTrip/widgets/search_reservation/reservation_category_row.dart';
import 'package:BookiTrip/widgets/search_reservation/reservation_tab_switcher.dart';
import 'package:BookiTrip/widgets/search_reservation/transport_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationSearchWidget extends StatefulWidget {
  const ReservationSearchWidget({super.key});

  @override
  State<ReservationSearchWidget> createState() =>
      _ReservationSearchWidgetState();
}

class _ReservationSearchWidgetState extends State<ReservationSearchWidget> {
  int _selectedTab = 0;
  int _selectedCategory = 0;
  bool _isExpanded = false;

  // ── Hôtels ────────────────────────────────────────────────────────────────
  Destination? _hotelDestination;
  DateTime? _checkIn;
  DateTime? _checkOut;
  List<RoomConfig> _rooms = [const RoomConfig(adults: 2, childAges: [])];

  // ── Restos ────────────────────────────────────────────────────────────────
  Destination? _restoDestination;
  DateTime? _restoDate;
  TimeOfDay? _restoTime;
  int _restoPersons = 2;

  // ── Vols (commented out) ──────────────────────────────────────────────────
  // Destination? _volDepart;
  // Destination? _volArrival;
  // DateTime? _volDepartDate;
  // DateTime? _volArrivalDate;
  // int _volPassengers = 1;

  // ── Événements (commented out) ────────────────────────────────────────────
  // Destination? _eventDestination;
  // DateTime? _eventDate;

  // ── Transports ────────────────────────────────────────────────────────────
  TransportType? _selectedTransport;

  // ── Transport URLs (to be filled later) ───────────────────────────────────
  static const Map<TransportType, String> _transportUrls = {
    TransportType.bateaux: 'http://www.ctn.com.tn',
    TransportType.transfert: '',
    TransportType.taxi: '',
  };

  static const _categories = [
    CategoryItem(label: 'Hôtels',      icon: Icons.hotel),
    CategoryItem(label: 'Restos',      icon: Icons.restaurant),
    // CategoryItem(label: 'Vols',        icon: Icons.flight),
    // CategoryItem(label: 'Évènements',  icon: Icons.event),
    CategoryItem(label: 'Transports',  icon: Icons.directions_bus),
  ];

  void _toggleExpand() => setState(() => _isExpanded = !_isExpanded);

  // ── Perform search ────────────────────────────────────────────────────────
  void _performSearch() {
    switch (_selectedCategory) {
      case 0: // Hôtels
        final params = AvailabilitySearchParams(
          destinationId: _hotelDestination!.id,
          checkIn: _checkIn!,
          checkOut: _checkOut!,
          rooms: _rooms,
        );
        final error = params.validate();
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(error),
                behavior: SnackBarBehavior.floating),
          );
          return;
        }
        Provider.of<AvailabilityProvider>(context, listen: false)
            .searchAvailability(params);
        context.pushNamed('availabilityResults');
        break;

      case 1: // Restos
        if (_restoDestination == null || _restoDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Veuillez sélectionner une destination et une date'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        // Format date as yyyy-MM-dd for the API
        final dateStr =
            '${_restoDate!.year}-${_restoDate!.month.toString().padLeft(2, '0')}-${_restoDate!.day.toString().padLeft(2, '0')}';
        Provider.of<RestaurantProvider>(context, listen: false)
            .searchAvailableRestaurants(
              destinationId: _restoDestination!.id,
              date: dateStr,
              number: _restoPersons,
            );
        context.pushNamed('restoAvailabilityResults');
        break;

      // case 2: Vols (commented out)
      // case 3: Événements (commented out)

      case 2: // Transports
        if (_selectedTransport == null) return;
        if (_selectedTransport == TransportType.locationVoiture) {
          context.pushNamed('vehicles');
          return;
        }
        _launchTransportUrl(_selectedTransport!);
        break;
    }
  }

  Future<void> _launchTransportUrl(TransportType type) async {
    final url = _transportUrls[type] ?? '';
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lien pour ${type.name} bientôt disponible'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.inAppWebView);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le lien'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Picker helpers ────────────────────────────────────────────────────────
  void _openDestinationPicker({required ValueChanged<Destination> onSelected}) {
    final theme = context.read<ThemeProvider>().currentTheme;
    DestinationPickerSheet.show(
      context: context,
      theme: theme,
      onSelected: onSelected,
    );
  }

  void _openHotelModal() {
    final theme = context.read<ThemeProvider>().currentTheme;
    AvailabilitySearchModal.show(
      context: context,
      theme: theme,
      destinationId: _hotelDestination?.id,
      initialCheckIn: _checkIn,
      initialCheckOut: _checkOut,
      initialRooms: _rooms,
      onSearch: (params) => setState(() {
        _checkIn = params.checkIn;
        _checkOut = params.checkOut;
        _rooms = params.rooms;
      }),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    final Color fieldBg = theme.isDark
        ? theme.surface.withOpacity(0.6)
        : const Color(0xFFF2F2F2);
    final Color iconInactive =
    theme.isDark ? Colors.white38 : Colors.black45;
    final Color hintColor =
    theme.isDark ? Colors.white38 : Colors.black45;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(_isExpanded ? 24 : 20),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.10),
            blurRadius: _isExpanded ? 24 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_isExpanded ? 24 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 350),
              reverseDuration: const Duration(milliseconds: 250),
              sizeCurve: Curves.easeInOutCubic,
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _selectedTab == 0
                    ? _buildReservationBody(
                    theme, fieldBg, iconInactive, hintColor)
                    : CircuitBody(
                  theme: theme,
                  onManualTap: () => context.push('/manual-circuit'),
                  onAutoTap: () => context.push('/auto-circuit'),
                ),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppTheme theme) {
    return InkWell(
      onTap: _toggleExpand,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: ReservationTabSwitcher(
                selectedTab: _selectedTab,
                theme: theme,
                onTabChanged: (i) => setState(() {
                  _selectedTab = i;
                  if (!_isExpanded) _isExpanded = true;
                }),
              ),
            ),
            const SizedBox(width: 12),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: theme.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Reservation body ──────────────────────────────────────────────────────
  Widget _buildReservationBody(
      AppTheme theme,
      Color fieldBg,
      Color iconInactive,
      Color hintColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReservationCategoryRow(
          categories: _categories,
          selectedIndex: _selectedCategory,
          theme: theme,
          onCategorySelected: (i) => setState(() => _selectedCategory = i),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                  begin: const Offset(0, 0.06), end: Offset.zero)
                  .animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(
            key: ValueKey(_selectedCategory),
            child: _buildActiveForm(
                theme, fieldBg, iconInactive, hintColor),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveForm(
      AppTheme theme,
      Color fieldBg,
      Color iconInactive,
      Color hintColor,
      ) {
    switch (_selectedCategory) {
      case 0: // Hôtels
        return HotelsForm(
          theme: theme,
          fieldBg: fieldBg,
          iconInactive: iconInactive,
          hintColor: hintColor,
          selectedDestination: _hotelDestination,
          checkIn: _checkIn,
          checkOut: _checkOut,
          rooms: _rooms,
          onDestinationTap: () => _openDestinationPicker(
              onSelected: (d) =>
                  setState(() => _hotelDestination = d)),
          onDatesTap: _openHotelModal,
          onGuestsTap: _openHotelModal,
          onSearch: _performSearch,
        );

      case 1: // Restos
        return RestosForm(
          theme: theme,
          fieldBg: fieldBg,
          iconInactive: iconInactive,
          hintColor: hintColor,
          destination: _restoDestination,
          date: _restoDate,
          time: _restoTime,
          persons: _restoPersons,
          onDestinationTap: () => _openDestinationPicker(
              onSelected: (d) =>
                  setState(() => _restoDestination = d)),
          onDateChanged: (d) => setState(() => _restoDate = d),
          onTimeChanged: (t) => setState(() => _restoTime = t),
          onPersonsChanged: (v) => setState(() => _restoPersons = v),
          onSearch: _performSearch,
        );

      // case 2: Vols (commented out)
      // case 3: Événements (commented out)

      case 2: // Transports
        return TransportsForm(
          theme: theme,
          selectedTransport: _selectedTransport,
          onTransportSelected: (t) =>
              setState(() => _selectedTransport = t),
          onSearch: _performSearch,
        );

      default:
        return const SizedBox();
    }
  }
}