import 'package:BookiTrip/constants/theme.dart';
import 'package:BookiTrip/providers/vehicle_provider.dart';
import 'package:BookiTrip/screens/mainScreen_container.dart';
import 'package:BookiTrip/widgets/circuits/calendar_picker.dart';
import 'package:BookiTrip/widgets/vehicle_card.dart';
import 'package:BookiTrip/widgets/vehicle_reservation_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  void _toggleDrawer() {
    final containerState =
        context.findAncestorStateOfType<MainScreenContainerState>();
    containerState?.toggleDrawer();
  }

  @override
  void initState() {
    super.initState();
    // Fetch vehicles when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehicleProvider>().fetchVehiclesIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: theme.text),
          onPressed: _toggleDrawer,
        ),
        title: Text(
          'vehicles.title'.tr(),
          style: TextStyle(
            color: theme.primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildDateFilter(context, theme),
          Expanded(
            child: Consumer<VehicleProvider>(
              builder: (context, provider, child) {
                if (provider.status == VehicleStatus.loading &&
                    provider.vehicles.isEmpty) {
                  return _buildLoading(theme);
                }

                if (provider.status == VehicleStatus.failure &&
                    provider.vehicles.isEmpty) {
                  return _buildError(theme, provider);
                }

                if (provider.status == VehicleStatus.success &&
                    provider.vehicles.isEmpty) {
                  return _buildEmpty(theme);
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchVehicles(
                    from: provider.searchFrom,
                    to: provider.searchTo,
                  ),
                  color: theme.primary,
                  backgroundColor: theme.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: provider.vehicles.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final vehicle = provider.vehicles[index];
                      return VehicleCard(
                        vehicle: vehicle,
                        theme: theme,
                        searchFrom: provider.searchFrom,
                        searchTo: provider.searchTo,
                        onReserve: () {
                          VehicleReservationForm.show(
                            context: context,
                            vehicle: vehicle,
                            theme: theme,
                            initialFromDate: provider.searchFrom,
                            initialToDate: provider.searchTo,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(BuildContext context, AppTheme theme) {
    final provider = context.watch<VehicleProvider>();
    final fromDate = provider.searchFrom;
    final toDate = provider.searchTo;

    final String dateString;
    if (fromDate != null && toDate != null) {
      final fromFormatted = DateFormat('dd MMM').format(fromDate);
      final toFormatted = DateFormat('dd MMM yyyy').format(toDate);
      dateString = '$fromFormatted - $toFormatted';
    } else {
      dateString = 'vehicles.select_dates'.tr();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.background,
        border: Border(
          bottom: BorderSide(
            color: theme.text.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: _buildDateTile(
        context,
        theme,
        label: 'vehicles.reservation_dates'.tr(),
        dateString: dateString,
        onTap: () => _showCalendarModal(context, theme, provider),
      ),
    );
  }

  void _showCalendarModal(BuildContext context, AppTheme theme, VehicleProvider provider) {
    DateTime? tempFrom = provider.searchFrom;
    DateTime? tempTo = provider.searchTo;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.text.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'vehicles.select_dates'.tr(),
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: AcCalendarPicker(
                        startDate: tempFrom,
                        endDate: tempTo,
                        onStartDateSelected: (date) {
                          setStateModal(() {
                            tempFrom = date;
                            tempTo = null;
                          });
                        },
                        onEndDateSelected: (date) {
                          setStateModal(() => tempTo = date);
                        },
                        theme: theme,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: tempFrom != null && tempTo != null
                        ? () {
                            provider.fetchVehicles(from: tempFrom, to: tempTo);
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: theme.primary.withOpacity(0.3),
                      disabledForegroundColor: Colors.white60,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'reservation.confirm'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDateTile(
    BuildContext context,
    AppTheme theme, {
    required String label,
    required String dateString,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.text.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: theme.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: theme.text.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateString,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: theme.text.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading(AppTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.primary),
          const SizedBox(height: 16),
          Text(
            'vehicles.loading'.tr(),
            style: TextStyle(
              color: theme.text.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(AppTheme theme, VehicleProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'vehicles.error_loading'.tr(),
              style: TextStyle(
                color: theme.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? '',
              style: TextStyle(
                color: theme.text.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: provider.fetchVehicles,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('common.retry'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(AppTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_rounded,
                size: 64,
                color: theme.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'vehicles.no_vehicles'.tr(),
              style: TextStyle(
                color: theme.text,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'vehicles.no_vehicles_message'.tr(),
              style: TextStyle(
                color: theme.text.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
