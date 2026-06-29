import '../../providers/reservation_provider.dart';

class ReservationPayload {
  final ReservationProvider provider;

  ReservationPayload(this.provider);

  Map<String, dynamic> toTgtJson() {
    final contact = provider.contactInfo!;
    
    List<String> accIds = [];
    List<String> roomIds = [];
    List<int> quantities = [];
    
    for (var entry in provider.selectedRooms.entries) {
      for (int i = 0; i < entry.value; i++) {
        accIds.add(provider.selectedPension!.id);
        roomIds.add(entry.key.id);
        quantities.add(1);
      }
    }

    return {
      "name": "${contact.firstName} ${contact.lastName}",
      "accommodation_id": accIds,
      "room_id": roomIds,
      "hotel_id": provider.hotel.hotelId,
      "date_start": _fmtDate(provider.searchParams.checkIn),
      "date_end": _fmtDate(provider.searchParams.checkOut),
      "number": quantities,
      "email": contact.email,
      "phone": contact.phone,
      "city": contact.city,
      "country": contact.countryCode,
      "cin": contact.cin,
      "pax": provider.roomTravelers.map((rt) => rt.toTgtPaxJson()).toList(),
      "adults": provider.searchParams.totalAdults,
      "children": provider.searchParams.totalChildren,
      "total_price": provider.totalPrice
    };
  }
  
  String _fmtDate(DateTime d) => 
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toBhrJson(String quoteId) {
    final contact = provider.contactInfo!;
    final expectedPrice = provider.totalPrice / 1.1; 
    
    return {
      "date_start": _fmtDate(provider.searchParams.checkIn),
      "date_end": _fmtDate(provider.searchParams.checkOut),
      "hotel_id": provider.hotel.hotelId,
      "hotel_title": provider.hotel.hotelName,
      "quote_id": quoteId,
      "source": "mobile",
      "address": provider.hotel.hotelName, 
      "total_price": provider.totalPrice,
      "expected_price": expectedPrice,
      "margeProfit": provider.totalPrice - expectedPrice,
      "client_first_name": contact.firstName,
      "client_last_name": contact.lastName,
      "client_email": contact.email,
      "phone": contact.phone,
      "city": contact.city,
      "cin": contact.cin,
      "nationality": contact.countryCode,
      "customer": {"email": contact.email},
      "selected_rooms": provider.roomTravelers.map((rt) => {
        "id": rt.room.id,
        "title": rt.room.title,
        "boarding_id": rt.pension.id,
        "boarding_title": rt.pension.name,
        "adult": rt.adults.length,
        "child": rt.children.length,
        "infant": 0,
        "offer_id": "",
        "customers": [
           ...rt.adults.map((a) => a.toBhrJson()),
           ...rt.children.map((c) => c.toBhrJson()),
        ]
      }).toList()
    };
  }

  Map<String, dynamic> toMouradiJson() {
    final contact = provider.contactInfo!;
    final expectedPrice = provider.totalPrice / 1.1;
    
    return {
      "PreBooking": false,
      "Hotel": provider.hotel.hotelId,
      "City": "city_id_placeholder",
      "CheckIn": _fmtDate(provider.searchParams.checkIn),
      "CheckOut": _fmtDate(provider.searchParams.checkOut),
      "Option": [],
      "Source": "mobile",
      "Rooms": provider.roomTravelers.map((rt) => {
        "Id": rt.room.id,
        "Boarding": rt.pension.id,
        "Pax": {
          "Adult": rt.adults.map((a) => a.toTgtAdultJson()).toList(),
          "Child": rt.children.map((c) => c.toTgtChildJson()).toList()
        }
      }).toList(),
      "name": contact.firstName,
      "lastname": contact.lastName,
      "email": contact.email,
      "phone": contact.phone,
      "city": contact.city,
      "cin": contact.cin,
      "total_price": provider.totalPrice,
      "margeProfit": provider.totalPrice - expectedPrice,
      "country": contact.countryCode
    };
  }
}
