import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/api_client.dart';
import '../../models/availability_result.dart';
import '../../models/availability_search_params.dart';
import '../../models/pension_detail.dart';
import '../../repositories/reservation_repository.dart';
import '../../models/reservation/contact_info.dart';
import '../../models/reservation/traveler.dart';
import '../../models/reservation/room_travelers.dart';
import '../../models/reservation/reservation_payload.dart';
import '../../models/hotel_details.dart';
import '../../services/pricing_engine.dart';

enum ReservationStep { roomSelection, formFill, payment, confirmation }
enum ReservationStatus { initial, loading, success, failure }

class ReservationProvider extends ChangeNotifier {
  final ReservationRepository repository;

  // Initial Parameters
  final AvailabilitySearchParams searchParams;
  final AvailabilityResult hotel;
  final HotelDetail? hotelDetails;

  // Current State
  ReservationStep currentStep = ReservationStep.roomSelection;
  ReservationStatus status = ReservationStatus.initial;
  String? errorMessage;
  
  // Pricing State
  double _totalPriceOriginal = 0.0;
  double _totalPricePromos = 0.0;

  // Step 1: Selection State
  PensionDetail? selectedPension;
  Map<RoomDetail, int> selectedRooms = {};

  // Step 2: Form State
  ContactInfo? contactInfo;
  List<RoomTravelers> roomTravelers = [];

  // Step 3: Payment State
  String? paymentUrl;
  String? bookingReference;

  ReservationProvider({
    required this.repository,
    required this.searchParams,
    required this.hotel,
    this.hotelDetails,
  });

  // Computed helpers for UI
  int get totalSelectedRooms => selectedRooms.values.fold(0, (s, q) => s + q);
  
  bool get isRoomSelectionComplete => totalSelectedRooms == searchParams.totalRooms;
  
  double get totalPrice {
    // If no hotelDetails (no pricing engine), fall back to static sellingPrice
    if (hotelDetails == null) {
      return selectedRooms.entries.fold(
          0.0, (sum, e) => sum + (e.key.sellingPrice * e.value));
    }
    return _totalPricePromos > 0 ? _totalPricePromos : _totalPriceOriginal;
  }
  double get totalPriceOriginal {
    if (hotelDetails == null) return totalPrice;
    return _totalPriceOriginal;
  }
  bool get hasDiscount => hotelDetails != null && _totalPricePromos > 0 && _totalPricePromos < _totalPriceOriginal;

  // --- Mutators ---

  void setPension(PensionDetail pension) {
    selectedPension = pension;
    selectedRooms.clear();
    notifyListeners();
  }

  void updateRoomQuantity(RoomDetail room, int quantity) {
    if (quantity <= 0) {
      selectedRooms.remove(room);
    } else {
      selectedRooms[room] = quantity;
    }
    _recalculatePrices();
    notifyListeners();
  }

  void _recalculatePrices() {
    if (hotelDetails == null) return; // No pricing engine without hotel details
    
    _totalPriceOriginal = 0.0;
    _totalPricePromos = 0.0;

    int configIndex = 0;
    
    for (var entry in selectedRooms.entries) {
      final room = entry.key;
      final quantity = entry.value;
      
      // Calculate per room based on assigned config
      for (int i = 0; i < quantity; i++) {
        final config = configIndex < searchParams.rooms.length 
            ? searchParams.rooms[configIndex] 
            : searchParams.rooms.first;
            
        final result = PricingEngine.calculateRoomPrice(
          room: room,
          pensionId: room.pensionId,
          config: config,
          hotel: hotelDetails!,
          quantity: 1, // calculate per single room
          stayDate: searchParams.checkIn,
          providerType: hotel.providerType ?? 'tgt',
        );
        
        _totalPriceOriginal += result.priceOriginal;
        _totalPricePromos += result.pricePromos;
        
        configIndex++;
      }
    }
  }

  void proceedToForm() {
    if (isRoomSelectionComplete && selectedPension != null) {
      // Validation Check: Release
      if (hotelDetails != null && hotelDetails!.releaseHotels.isNotEmpty) {
        final daysBetween = searchParams.checkIn.difference(DateTime.now()).inDays;
        bool releaseFailed = false;
        for (final release in hotelDetails!.releaseHotels) {
          final start = DateTime.tryParse(release.dateStart);
          final end = DateTime.tryParse(release.dateEnd);
          if (start != null && end != null && !searchParams.checkIn.isBefore(start) && !searchParams.checkOut.isAfter(end)) {
            if (daysBetween <= release.dayNumber) {
              releaseFailed = true;
              break;
            }
          }
        }
        if (releaseFailed) {
          errorMessage = "Délai de réservation dépassé (Release)";
          notifyListeners();
          return;
        }
      }

      // Validation Check: Minimum Stay
      if (hotelDetails != null && hotelDetails!.minimumstay.isNotEmpty) {
        bool minStayFailed = false;
        for (final rule in hotelDetails!.minimumstay) {
          final start = DateTime.tryParse(rule.dateStart);
          final end = DateTime.tryParse(rule.dateEnd);
          if (start != null && end != null && !searchParams.checkIn.isBefore(start) && !searchParams.checkOut.isAfter(end)) {
            if (searchParams.nights < rule.number) {
              minStayFailed = true;
              break;
            }
          }
        }
        if (minStayFailed) {
          errorMessage = "Le séjour minimum n'est pas respecté";
          notifyListeners();
          return;
        }
      }

      errorMessage = null;
      currentStep = ReservationStep.formFill;
      _initializeTravelers();
      notifyListeners();
    }
  }

  void goBackToRoomSelection() {
    currentStep = ReservationStep.roomSelection;
    notifyListeners();
  }

  void goToConfirmation() {
    currentStep = ReservationStep.confirmation;
    notifyListeners();
  }

  void _initializeTravelers() {
    roomTravelers.clear();
    
    // We need to match selected rooms against the searchParams room configs.
    // Since the API search params specify e.g. "Room 1: 2 adults, 1 child", 
    // and the user selected e.g. "2 Standard Rooms", we assign the configs sequentially.
    int configIndex = 0;
    
    for (var entry in selectedRooms.entries) {
      final roomDetail = entry.key;
      final quantity = entry.value;
      
      for (int i = 0; i < quantity; i++) {
        // If we have more rooms selected than configs (shouldn't happen if validation is strict), fallback to 1 adult
        final config = configIndex < searchParams.rooms.length 
            ? searchParams.rooms[configIndex] 
            : null;
            
        final adultCount = config?.adults ?? 1;
        final childCount = config?.children ?? 0;
        
        List<Traveler> adults = List.generate(adultCount, (index) => Traveler(
          civility: 'Mr',
          firstName: '',
          lastName: '',
          isHolder: configIndex == 0 && index == 0, // First adult of first room is holder
        ));
        
        List<Traveler> children = List.generate(childCount, (index) => Traveler(
          civility: 'Enfant',
          firstName: '',
          lastName: '',
          age: config?.childAges.length != null && config!.childAges.length > index ? config.childAges[index] : 5,
        ));
        
        roomTravelers.add(RoomTravelers(
          room: roomDetail,
          pension: selectedPension!,
          adults: adults,
          children: children,
        ));
        
        configIndex++;
      }
    }
  }

  void updateContactInfo(ContactInfo info) {
    contactInfo = info;
    notifyListeners();
  }
  
  void updateRoomTraveler(int roomIndex, RoomTravelers travelers) {
    if (roomIndex >= 0 && roomIndex < roomTravelers.length) {
      roomTravelers[roomIndex] = travelers;
      notifyListeners();
    }
  }

  Future<void> submitReservation() async {
    if (contactInfo == null || roomTravelers.isEmpty || selectedPension == null) {
      errorMessage = "Veuillez remplir toutes les informations requises.";
      status = ReservationStatus.failure;
      notifyListeners();
      return;
    }

    status = ReservationStatus.loading;
    notifyListeners();

    try {
      final payload = ReservationPayload(this);
      
      String url;
      final providerType = hotel.providerType?.toLowerCase() ?? '';
      
      if (providerType == 'tgt') {
        url = await repository.submitHotelReservation(payload: payload.toTgtJson(), providerType: 'tgt');
      } else if (providerType == 'bhr') {
         final quoteId = '';
        url = await repository.submitHotelReservation(payload: payload.toBhrJson(quoteId), providerType: 'bhr');
      } else if (providerType == 'mouradi') {
        url = await repository.submitHotelReservation(payload: payload.toMouradiJson(), providerType: 'mouradi');
      } else {
        throw Exception("Unknown provider type: $providerType");
      }

      paymentUrl = url;
      status = ReservationStatus.success;
    } on ServerException catch (_) {
      status = ReservationStatus.failure;
      errorMessage = 'reservation.error_server'.tr();
    } catch (e) {
      status = ReservationStatus.failure;
      errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  void handlePaymentResult(bool success) {
     if (success) {
       currentStep = ReservationStep.confirmation;
     } else {
       // Return to form if payment cancelled
       currentStep = ReservationStep.formFill;
       errorMessage = "Le paiement a été annulé.";
       status = ReservationStatus.initial; 
     }
     notifyListeners();
  }
}
