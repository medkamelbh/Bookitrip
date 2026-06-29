import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/models/availability_result.dart';
import 'package:BookiTrip/models/pension_detail.dart';
import 'package:BookiTrip/providers/reservation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

/// Reservation screen showing hotel info, pensions, and rooms with prices.
/// It uses [ReservationProvider] to track room selections.
class ReservationScreen extends StatefulWidget {
  final AvailabilityResult result;

  const ReservationScreen({super.key, required this.result});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize first pension as default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.result.pensionDetails.isNotEmpty) {
        context.read<ReservationProvider>().setPension(widget.result.pensionDetails.first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;
    final provider = context.watch<ReservationProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Hotel image + back button ─────────────────────────────────
          _buildSliverAppBar(theme),

          // ── Content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), // padding bottom for sticky bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel info header
                  _buildHotelInfo(theme),
                  const SizedBox(height: 24),

                  // Pension selector
                  if (widget.result.pensionDetails.isNotEmpty) ...[
                    _buildSectionTitle('Formule de pension', theme),
                    const SizedBox(height: 12),
                    _buildPensionSelector(theme, provider),
                    const SizedBox(height: 24),

                    // Rooms for selected pension
                    _buildSectionTitle('Chambres disponibles', theme),
                    const SizedBox(height: 12),
                    _buildRoomsList(theme, provider),
                  ] else if (widget.result.pensions.isNotEmpty) ...[
                    _buildSectionTitle('Pensions disponibles', theme),
                    const SizedBox(height: 12),
                    _buildPensionSummaryList(theme),
                  ] else ...[
                    _buildNoPensionState(theme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildStickyBottomBar(theme, provider),
    );
  }

  Widget _buildStickyBottomBar(AppTheme theme, ReservationProvider provider) {
    if (provider.selectedRooms.isEmpty) return const SizedBox.shrink();

    final isComplete = provider.isRoomSelectionComplete;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.isDark ? const Color(0xFF1A1A1A) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (provider.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.totalSelectedRooms} / ${provider.searchParams.totalRooms} chambre(s)',
                  style: TextStyle(
                    color: isComplete ? const Color(0xFF2E7D32) : theme.text.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (provider.hasDiscount)
                  Text(
                    '${provider.totalPriceOriginal.toStringAsFixed(0)} ${widget.result.currency}',
                    style: TextStyle(
                      color: theme.text.withOpacity(0.4),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: theme.text.withOpacity(0.4),
                    ),
                  ),
                Text(
                  '${provider.totalPrice.toStringAsFixed(0)} ${widget.result.currency}',
                  style: TextStyle(
                    color: provider.hasDiscount ? const Color(0xFF2E7D32) : theme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: isComplete
                  ? () {
                      provider.proceedToForm();
                      // context.pushNamed('reservationForm'); // TODO: Create route
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: theme.text.withOpacity(0.1),
                disabledForegroundColor: theme.text.withOpacity(0.4),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Continuer',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
          ],
        ),
      ),
    );
  }

  // ── Sliver app bar with image ─────────────────────────────────────────────

  Widget _buildSliverAppBar(AppTheme theme) {
    final imageUrl = widget.result.cover ?? widget.result.vignette;

    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: theme.background,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black38,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: theme.primary.withOpacity(0.08),
                  child: Center(
                    child: Icon(Icons.hotel_rounded,
                        size: 48, color: theme.primary.withOpacity(0.3)),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: theme.primary.withOpacity(0.08),
                  child: Icon(Icons.broken_image_outlined,
                      size: 48, color: theme.primary.withOpacity(0.3)),
                ),
              )
            else
              Container(
                color: theme.primary.withOpacity(0.08),
                child: Icon(Icons.hotel_rounded,
                    size: 48, color: theme.primary.withOpacity(0.3)),
              ),
            // Gradient
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hotel info header ─────────────────────────────────────────────────────

  Widget _buildHotelInfo(AppTheme theme) {
    final result = widget.result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        Text(
          result.hotelName,
          style: TextStyle(
            color: theme.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),

        // Stars
        if (result.stars != null && result.stars! > 0) ...[
          Row(
            children: List.generate(5, (i) {
              return Icon(
                i < result.stars! ? Icons.star_rounded : Icons.star_border_rounded,
                size: 18,
                color: i < result.stars!
                    ? Colors.amber.shade600
                    : theme.text.withOpacity(0.2),
              );
            }),
          ),
          const SizedBox(height: 8),
        ],

        // Destination
        if (result.destinationName != null &&
            result.destinationName!.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 16, color: theme.primary),
              const SizedBox(width: 4),
              Text(
                result.destinationName!,
                style: TextStyle(
                  color: theme.text.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],

        // Address
        if (result.address != null && result.address!.isNotEmpty)
          Row(
            children: [
              Icon(Icons.map_outlined,
                  size: 16, color: theme.text.withOpacity(0.35)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  result.address!,
                  style: TextStyle(
                    color: theme.text.withOpacity(0.45),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ── Pension selector ──────────────────────────────────────────────────────

  Widget _buildPensionSelector(AppTheme theme, ReservationProvider provider) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.result.pensionDetails.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final pension = widget.result.pensionDetails[index];
          final isSelected = provider.selectedPension?.id == pension.id;

          return GestureDetector(
            onTap: () => provider.setPension(pension),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 160,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.primary.withOpacity(0.10)
                    : (theme.isDark
                        ? Colors.white.withOpacity(0.04)
                        : const Color(0xFFF7F7F7)),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.primary.withOpacity(0.5)
                      : Colors.transparent,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu_rounded,
                        size: 16,
                        color: isSelected
                            ? theme.primary
                            : theme.text.withOpacity(0.4),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pension.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? theme.primary
                                : theme.text.withOpacity(0.7),
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${pension.rooms.length} chambre${pension.rooms.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: theme.text.withOpacity(0.35),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (pension.cheapestPrice > 0)
                    Text(
                      'dès ${pension.cheapestPrice.toStringAsFixed(0)} ${pension.currency}',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Rooms list for selected pension ────────────────────────────────────────

  Widget _buildRoomsList(AppTheme theme, ReservationProvider provider) {
    if (provider.selectedPension == null) return const SizedBox.shrink();

    final pension = provider.selectedPension!;

    if (pension.rooms.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Aucune chambre disponible pour cette pension',
            style: TextStyle(
              color: theme.text.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: pension.rooms.map((room) => _buildRoomCard(room, pension, provider, theme)).toList(),
    );
  }

  Widget _buildRoomCard(RoomDetail room, PensionDetail pension, ReservationProvider provider, AppTheme theme) {
    final qty = provider.selectedRooms[room] ?? 0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: qty > 0 
              ? theme.primary.withOpacity(0.5)
              : (theme.isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
          width: qty > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (theme.shadow ?? Colors.black).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room title
          Row(
            children: [
              Icon(Icons.bed_rounded, size: 20, color: theme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  room.title,
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Capacity
          Row(
            children: [
              _buildInfoChip(
                Icons.person_rounded,
                '${room.maxAdults} adulte${room.maxAdults > 1 ? 's' : ''}',
                theme,
              ),
              const SizedBox(width: 8),
              if (room.maxChildren > 0)
                _buildInfoChip(
                  Icons.child_care_rounded,
                  '${room.maxChildren} enfant${room.maxChildren > 1 ? 's' : ''}',
                  theme,
                ),
              const SizedBox(width: 8),
              if (room.stillAvailable > 0)
                _buildInfoChip(
                  Icons.check_circle_outline_rounded,
                  '${room.stillAvailable} dispo.',
                  theme,
                  color: const Color(0xFF2E7D32),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Price & Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${room.sellingPrice.toStringAsFixed(0)} ${room.currency}',
                      style: TextStyle(
                        color: theme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (pension.nightCount > 0)
                      Text(
                        '${pension.nightCount} nuit${pension.nightCount > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: theme.text.withOpacity(0.4),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
                
                // +/- Counter
                Row(
                  children: [
                    _buildCounterButton(
                      icon: Icons.remove_rounded, 
                      onTap: qty > 0 ? () => provider.updateRoomQuantity(room, qty - 1) : null,
                      theme: theme,
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 32),
                      alignment: Alignment.center,
                      child: Text(
                        '$qty',
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      icon: Icons.add_rounded, 
                      onTap: qty < room.stillAvailable && !provider.isRoomSelectionComplete
                          ? () => provider.updateRoomQuantity(room, qty + 1)
                          : null,
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCounterButton({required IconData icon, required VoidCallback? onTap, required AppTheme theme}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: onTap != null ? theme.primary.withOpacity(0.15) : theme.text.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: onTap != null ? theme.primary : theme.text.withOpacity(0.2),
        ),
      ),
    );
  }


  Widget _buildPensionSummaryList(AppTheme theme) {
    return Column(
      children: widget.result.pensions.map((pension) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.isDark
                ? Colors.white.withOpacity(0.04)
                : const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu_rounded,
                  size: 18, color: theme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pension.name,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${pension.roomCount} type${pension.roomCount > 1 ? 's' : ''} de chambre',
                      style: TextStyle(
                        color: theme.text.withOpacity(0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'dès ${pension.cheapestPrice.toStringAsFixed(0)} ${pension.currency}',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoPensionState(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 48, color: theme.text.withOpacity(0.15)),
            const SizedBox(height: 12),
            Text(
              'Aucune formule de pension disponible',
              style: TextStyle(
                color: theme.text.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppTheme theme) {
    return Text(
      title,
      style: TextStyle(
        color: theme.text,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    AppTheme theme, {
    Color? color,
  }) {
    final c = color ?? theme.text.withOpacity(0.5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
