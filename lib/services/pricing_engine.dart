import 'package:BookiTrip/models/hotel_details.dart';
import 'package:BookiTrip/models/pension_detail.dart';
import 'package:BookiTrip/models/availability_search_params.dart';
import 'package:BookiTrip/models/circuit_form_data.dart';

class PricingResult {
  final double priceOriginal;
  final double pricePromos;

  const PricingResult({
    required this.priceOriginal,
    required this.pricePromos,
  });

  /// The final price to charge the user
  double get finalPrice => pricePromos > 0 && pricePromos < priceOriginal 
      ? pricePromos 
      : priceOriginal;
}

class PricingEngine {
  /// Calculates the price for a specific room based on active policies and occupants.
  static PricingResult calculateRoomPrice({
    required RoomDetail room,
    required String pensionId,
    required RoomConfig config,
    required HotelDetail hotel,
    required int quantity,
    required DateTime stayDate,
    required String providerType,
  }) {
    if (providerType != 'tgt') {
      // For non-TGT providers like BHR, we just return the flat rate * quantity
      // BHR rate already includes the 10% commission when parsed
      final total = room.purchasePrice * quantity;
      return PricingResult(priceOriginal: total, pricePromos: total);
    }

    final double purchasePrice = room.purchasePrice;
    final double commissionPct = room.commission;
    final double commissionFactor = 1 + (commissionPct / 100);
    final double childCommissionFactor = 1.12; // Children/Babies always 12%

    // 1. Group occupants
    final int adults = config.adults;
    final int childCount = config.children;
    final List<int> childAges = config.childAges;
    final int nbOfPersons = adults + childCount;

    // Base Price: (Purchase + Commission) * persons * quantity
    // Using 12% for the base price generation to match existing logic
    final double basePrice = (purchasePrice * childCommissionFactor) * nbOfPersons * quantity;

    double totalPriceRoomWithoutPromo = basePrice;
    double totalPriceRoom = basePrice;

    // Active Policy Extraction
    final today = DateTime.now();
    
    // Find active Discount for stay date
    Discount? activeDiscount;
    for (final discount in hotel.discounts) {
      final start = DateTime.tryParse(discount.dateStart);
      final end = DateTime.tryParse(discount.dateEnd);
      if (start != null && end != null && !stayDate.isBefore(start) && !stayDate.isAfter(end)) {
        activeDiscount = discount;
        break;
      }
    }

    // Find active Flash Sale for TODAY
    FlashSale? activeSale;
    for (final sale in hotel.flashSales) {
      final start = DateTime.tryParse(sale.dateStart);
      final end = DateTime.tryParse(sale.dateEnd);
      if (start != null && end != null && !today.isBefore(start) && !today.isAfter(end)) {
        activeSale = sale;
        break;
      }
    }

    // Find active SPO for stay date
    Spo? activeSPO;
    for (final spo in hotel.spo) {
      final start = DateTime.tryParse(spo.dateStartStay);
      final end = DateTime.tryParse(spo.dateEndStay);
      if (start != null && end != null && !stayDate.isBefore(start) && !stayDate.isAfter(end)) {
        activeSPO = spo;
        break;
      }
    }

    // 2. Baby & Child Discounts
    if (activeDiscount != null && childAges.isNotEmpty) {
      // Find baby rule
      DiscountDetail? babyRule;
      try {
        babyRule = activeDiscount.discounts.firstWhere((d) => d.type == 'bébé');
      } catch (_) {}

      // Find child rule
      DiscountDetail? childRule;
      try {
        childRule = activeDiscount.discounts.firstWhere(
          (d) => d.type == 'enfant' && 
                 d.numberChild == childCount && 
                 d.numberAdultes == adults
        );
      } catch (_) {}

      int babyCount = 0;
      int regularChildCount = 0;

      for (final age in childAges) {
        if (babyRule != null && age <= babyRule.ageMax) {
          babyCount++;
        } else {
          regularChildCount++;
        }
      }

      // Apply baby discount
      if (babyRule != null && babyCount > 0) {
        final babyDiscount = (purchasePrice * childCommissionFactor) * babyCount * quantity * (babyRule.percentage / 100);
        totalPriceRoom -= babyDiscount;
      }

      // Apply child discount
      if (childRule != null && regularChildCount > 0) {
        int appliedChildren = 0;
        for (final age in childAges) {
          // Skip if it was counted as a baby
          if (babyRule != null && age <= babyRule.ageMax) continue;
          
          if (age >= childRule.ageMin && age < childRule.ageMax) {
            if (appliedChildren < childRule.percentages.length) {
              final pct = childRule.percentages[appliedChildren];
              final discountAmt = (purchasePrice * childCommissionFactor * quantity) * (pct / 100);
              totalPriceRoom -= discountAmt;
            }
            appliedChildren++;
          }
        }
      }
    }

    // 3. Adult Discount
    if (activeDiscount != null) {
      try {
        final adultRule = activeDiscount.discounts.firstWhere(
          (d) => d.type == 'adultes' && d.lit == adults.toString()
        );
        final adultDiscountAmt = (purchasePrice * commissionFactor) * quantity * (adultRule.percentage / 100);
        totalPriceRoom -= adultDiscountAmt;
      } catch (_) {}
    }

    // 4. Flash Sale
    if (activeSale != null) {
      final saleDiscount = (purchasePrice * commissionFactor) * adults * quantity * (activeSale.percentage / 100);
      totalPriceRoom -= saleDiscount;
    }

    // 5. SPO (Special Promotional Offer)
    if (activeSPO != null) {
      Percentage? pensionSpo;
      try {
        pensionSpo = activeSPO.percentage.firstWhere((p) => p.accommodationId == pensionId);
      } catch (_) {}

      if (pensionSpo != null) {
        if (pensionSpo.value > 0) { 
          // Assuming value is percentage for now based on SPO spec
          final spoDiscount = (purchasePrice * commissionFactor) * adults * quantity * (pensionSpo.value / 100);
          totalPriceRoom -= spoDiscount;
        }
      }
    }

    // Floor at 0
    if (totalPriceRoom < 0) {
      totalPriceRoom = 0;
    }

    return PricingResult(
      priceOriginal: totalPriceRoomWithoutPromo,
      pricePromos: totalPriceRoom,
    );
  }
}
