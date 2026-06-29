import 'package:BookiTrip/models/pension_detail.dart';
import 'traveler.dart';

class RoomTravelers {
  final RoomDetail room;
  final PensionDetail pension;
  final List<Traveler> adults;
  final List<Traveler> children;

  const RoomTravelers({
    required this.room,
    required this.pension,
    required this.adults,
    required this.children,
  });

  RoomTravelers copyWith({
    RoomDetail? room,
    PensionDetail? pension,
    List<Traveler>? adults,
    List<Traveler>? children,
  }) {
    return RoomTravelers(
      room: room ?? this.room,
      pension: pension ?? this.pension,
      adults: adults ?? this.adults,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toTgtPaxJson() => {
    "Id": room.id,
    "Boarding": pension.id,
    "View": [],
    "Supplement": [],
    "Pax": {
      "Adult": adults.map((a) => a.toTgtAdultJson()).toList(),
      "Child": children.map((c) => c.toTgtChildJson()).toList(),
    }
  };
}
