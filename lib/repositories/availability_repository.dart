import 'package:flutter/foundation.dart';
import '../models/availability_result.dart';
import '../models/availability_search_params.dart';
import '../models/hotel.dart';
import '../models/hotel_details.dart';
import '../models/pension_detail.dart';
import '../repositories/hotel_repository.dart';

/// Centralized repository for hotel availability operations.
///
/// Uses the real-time `/hoteldisponiblepontion` endpoint to fetch
/// pension/room/price data from TGT and BHR providers.
/// Falls back to client-side computation for hotels not covered.
class AvailabilityRepository {
  final HotelRepository _hotelRepo;

  AvailabilityRepository(this._hotelRepo);

  // ── Destination-wide search ───────────────────────────────────────────────

  /// Searches availability using the disponibility/pension API.
  ///
  /// 1. Calls `/hoteldisponiblepontion` for real-time pricing (pages 1-3)
  /// 2. Parses TGT/BHR results with commission-applied pricing
  /// 3. Falls back to client-side check for remaining hotels
  Future<List<AvailabilityResult>> searchAvailability(
    AvailabilitySearchParams params,
  ) async {
    try {
      final results = <AvailabilityResult>[];
      final payload = params.toDisponibilityPayload();

      // Fetch hotel catalog in parallel for enrichment (images, destination)
      final catalogFuture = _hotelRepo.getHotels(page: 1);

      // Fetch up to 3 pages from the disponibility API
      for (int page = 1; page <= 3; page++) {
        try {
          final response = await _hotelRepo.getDisponibilityPontion(
            payload: payload,
            page: page,
          );

          final data = response['data'] as List<dynamic>? ?? [];
          if (data.isEmpty) break;

          for (final hotelJson in data) {
            try {
              final result = _parseDisponibilityResult(
                hotelJson as Map<String, dynamic>,
                params,
              );
              if (result != null) results.add(result);
            } catch (e) {
              debugPrint('⚠️ Failed to parse hotel entry: $e');
            }
          }

          // Stop if we've reached the last page
          final lastPage = response['last_page'] ?? 1;
          if (page >= lastPage) break;
        } catch (e) {
          debugPrint('⚠️ Disponibility page $page failed: $e');
          if (page == 1) rethrow;
          break;
        }
      }

      // Enrich results with catalog data (images, destination, stars)
      try {
        final catalog = await catalogFuture;
        _enrichResultsFromCatalog(results, catalog);
      } catch (e) {
        debugPrint('⚠️ Catalog enrichment failed: $e');
      }

      // Sort: available first, then by price (cheapest first)
      results.sort((a, b) {
        if (a.isAvailable != b.isAvailable) {
          return a.isAvailable ? -1 : 1;
        }
        if (a.hasPrice && b.hasPrice) {
          return a.startingPrice!.compareTo(b.startingPrice!);
        }
        if (a.hasPrice) return -1;
        if (b.hasPrice) return 1;
        return b.offers.length.compareTo(a.offers.length);
      });

      return results;
    } catch (e) {
      debugPrint('❌ AvailabilityRepository.searchAvailability error: $e');
      // Fall back to client-side computation
      return _fallbackSearch(params);
    }
  }

  // ── Single-hotel availability ─────────────────────────────────────────────

  /// Checks availability for a specific hotel using the disponibility API.
  Future<AvailabilityResult> getHotelAvailability(
    AvailabilitySearchParams params,
  ) async {
    try {
      final slug = params.hotelSlug;
      if (slug == null || slug.isEmpty) {
        return AvailabilityResult(
          hotelId: params.hotelId ?? '',
          hotelName: '',
          isAvailable: false,
        );
      }

      // Try disponibility endpoint first
      try {
        final payload = params.toDisponibilityPayload();
        final responseFuture = _hotelRepo.getHotelDisponibilityPontion(
          slug: slug,
          payload: payload,
        );
        // Fetch catalog entry in parallel for enrichment
        final catalogFuture = _hotelRepo.getHotels(page: 1);

        final response = await responseFuture;

        debugPrint('\n🧩 ── getHotelAvailability parsing ────────────────────');
        debugPrint('🧩 Response top-level keys: ${response.keys.toList()}');

        // The response may contain the hotel directly or in a list
        final Map<String, dynamic>? hotelData = _extractHotelData(response);
        debugPrint(
          '🧩 _extractHotelData result: ${hotelData != null ? "FOUND (keys: ${hotelData.keys.toList()})" : "NULL"}',
        );

        if (hotelData != null) {
          final result = _parseDisponibilityResult(hotelData, params);
          debugPrint(
            '🧩 _parseDisponibilityResult: ${result != null ? "isAvailable=${result.isAvailable}, pensions=${result.pensions.length}, price=${result.startingPrice}" : "NULL"}',
          );
          debugPrint('🧩 ───────────────────────────────────────────────\n');

          if (result != null) {
            // The single-hotel API doesn't return hotel metadata,
            // so inject hotelId/slug from search params for catalog matching.
            final patched = AvailabilityResult(
              hotelId: result.hotelId.isNotEmpty
                  ? result.hotelId
                  : (params.hotelId ?? ''),
              hotelName: result.hotelName.isNotEmpty ? result.hotelName : '',
              hotelSlug: result.hotelSlug?.isNotEmpty == true
                  ? result.hotelSlug
                  : params.hotelSlug,
              cover: result.cover,
              vignette: result.vignette,
              stars: result.stars,
              destinationName: result.destinationName,
              address: result.address,
              isAvailable: result.isAvailable,
              rooms: result.rooms,
              offers: result.offers,
              minimumStayNights: result.minimumStayNights,
              reservable: result.reservable,
              providerType: result.providerType,
              startingPrice: result.startingPrice,
              currency: result.currency,
              nightCount: result.nightCount,
              pensions: result.pensions,
              pensionDetails: result.pensionDetails,
            );

            // Enrich with catalog data (cover, name, stars, destination)
            try {
              final catalog = await catalogFuture;
              final enriched = _enrichSingleResult(patched, catalog);
              return enriched;
            } catch (_) {
              return patched;
            }
          }
        } else {
          debugPrint('🧩 ───────────────────────────────────────────────\n');
        }
      } catch (e) {
        debugPrint('⚠️ Disponibility API failed for $slug, falling back: $e');
      }

      // Fallback: client-side computation
      return _fallbackSingleHotel(params, slug);
    } catch (e) {
      debugPrint('❌ AvailabilityRepository.getHotelAvailability error: $e');
      rethrow;
    }
  }

  // ── Disponibility response parser ─────────────────────────────────────────

  /// Parses a single hotel entry from the disponibility API response.
  AvailabilityResult? _parseDisponibilityResult(
    Map<String, dynamic> json,
    AvailabilitySearchParams params,
  ) {
    final disponibility = json['disponibility'] as Map<String, dynamic>?;
    if (disponibility == null) {
      debugPrint(
        '⚠️ _parseDisponibilityResult: no "disponibility" key found in json. Keys: ${json.keys.toList()}',
      );
      return null;
    }

    final type = disponibility['disponibilitytype']?.toString() ?? '';
    final hotelName = json['name']?.toString() ?? '';
    final pensionsList = disponibility['pensions'] as List<dynamic>? ?? [];
    debugPrint(
      '🎯 _parseDisponibilityResult: type="$type", hotel="$hotelName", pensionsCount=${pensionsList.length}',
    );
    debugPrint('🎯 disponibility keys: ${disponibility.keys.toList()}');

    // If the API returned an empty type AND empty pensions, it means the hotel
    // has no availability configured on the server for the requested dates.
    if (type.isEmpty && pensionsList.isEmpty) {
      debugPrint(
        '⚠️ API returned empty disponibilitytype AND empty pensions for "$hotelName". '
        'This hotel likely has no contract/pricing configured on the server for these dates.',
      );
      // Return a not-available result instead of null so we get a clear message
      return AvailabilityResult(
        hotelId: json['id']?.toString() ?? '',
        hotelName: hotelName,
        hotelSlug: json['slug']?.toString(),
        isAvailable: false,
        providerType: type,
      );
    }

    // Detect Mouradi by name (as per existing pattern)
    final isMouradi = hotelName.toLowerCase().contains('mouradi');

    if (type == 'tgt') {
      return _parseTgtResult(json, disponibility, params);
    } else if (type == 'bhr') {
      return _parseBhrResult(json, disponibility, params);
    } else if (isMouradi) {
      // Mouradi hotels may appear in the general search
      return _buildBasicResult(json, 'mouradi', params);
    }

    return _buildBasicResult(json, type, params);
  }

  // ── TGT price parsing ────────────────────────────────────────────────────

  /// Parses TGT disponibility: pensions[] → rooms[] → purchase_price[].
  ///
  /// Price formula (matches website `calculateBasePrice`):
  ///   SUM(all purchase_price entries) × 1.12 × nbOfPersons
  /// Where nbOfPersons = adults + children from the first room config.
  /// Commission is hardcoded at 12% for the base selling price.
  AvailabilityResult _parseTgtResult(
    Map<String, dynamic> hotelJson,
    Map<String, dynamic> disponibility,
    AvailabilitySearchParams params,
  ) {
    final pensionsJson = disponibility['pensions'] as List<dynamic>? ?? [];
    final pensions = <PensionSummary>[];
    final pensionDetailsList = <PensionDetail>[];
    double? globalCheapest;
    String currency = 'TND';
    int? nightCount;

    // Number of persons from search params (first room)
    final nbOfPersons = params.rooms.isNotEmpty
        ? params.rooms.first.adults + params.rooms.first.children
        : 2;

    for (final pensionJson in pensionsJson) {
      final pension = pensionJson as Map<String, dynamic>;
      final pensionId = pension['id']?.toString() ?? '';
      final pensionName = pension['name']?.toString() ?? '';
      final pensionNameEn = pension['name_en']?.toString();
      final pensionNameAr = pension['name_ar']?.toString();
      final devise = pension['devise']?.toString() ?? 'TND';
      currency = devise;

      // Get night count from $diffInDays
      final diffInDays = pension[' \$diffInDays'] ?? pension['\$diffInDays'];
      if (diffInDays != null && nightCount == null) {
        nightCount = (diffInDays is int)
            ? diffInDays
            : int.tryParse(diffInDays.toString());
      }

      final roomsJson = pension['rooms'] as List<dynamic>? ?? [];
      double? cheapestForPension;
      int roomCount = 0;

      for (final roomJson in roomsJson) {
        final room = roomJson as Map<String, dynamic>;
        final priceList = room['purchase_price'] as List<dynamic>? ?? [];

        if (priceList.isEmpty) continue;
        roomCount++;

        // SUM all purchase_price entries (each represents a date range/night)
        double roomPurchasePrice = 0;
        for (final priceEntry in priceList) {
          final entry = priceEntry as Map<String, dynamic>;
          final pp = (entry['purchase_price'] as num?)?.toDouble() ?? 0;
          roomPurchasePrice += pp;
        }

        if (roomPurchasePrice <= 0) continue;

        // Base selling price: SUM × 1.12 × nbOfPersons
        final sellingPrice =
            (roomPurchasePrice + (roomPurchasePrice * 12) / 100) * nbOfPersons;

        if (cheapestForPension == null || sellingPrice < cheapestForPension) {
          cheapestForPension = sellingPrice;
        }
      }

      if (cheapestForPension != null) {
        pensions.add(
          PensionSummary(
            id: pensionId,
            name: pensionName,
            nameEn: pensionNameEn,
            nameAr: pensionNameAr,
            cheapestPrice: cheapestForPension,
            roomCount: roomCount,
            currency: currency,
          ),
        );

        if (globalCheapest == null || cheapestForPension < globalCheapest) {
          globalCheapest = cheapestForPension;
        }
      }

      // Parse full pension detail for reservation screen
      pensionDetailsList.add(
        PensionDetail.fromDisponibility(pension, nbOfPersons: nbOfPersons),
      );
    }

    return AvailabilityResult(
      hotelId: hotelJson['id']?.toString() ?? '',
      hotelName: hotelJson['name']?.toString() ?? '',
      hotelSlug: hotelJson['slug']?.toString(),
      cover: hotelJson['cover']?.toString(),
      vignette: hotelJson['vignette']?.toString(),
      stars: _parseStars(hotelJson),
      destinationName: _parseDestinationName(hotelJson),
      isAvailable: pensions.isNotEmpty,
      providerType: 'tgt',
      startingPrice: globalCheapest,
      currency: currency,
      nightCount: nightCount ?? params.nights,
      pensions: pensions,
      pensionDetails: pensionDetailsList,
      reservable: true,
    );
  }

  // ── BHR price parsing ────────────────────────────────────────────────────

  /// Parses BHR disponibility: rooms[] → boardings[] → rate.
  ///
  /// Price formula: rate × 1.1 (10% commission). Rate is total stay.
  AvailabilityResult _parseBhrResult(
    Map<String, dynamic> hotelJson,
    Map<String, dynamic> disponibility,
    AvailabilitySearchParams params,
  ) {
    final roomsJson = disponibility['rooms'] as List<dynamic>? ?? [];
    final pensions = <PensionSummary>[];
    double? globalCheapest;
    final boardingMap = <String, _BoardingAccumulator>{};

    for (final roomJson in roomsJson) {
      final room = roomJson as Map<String, dynamic>;
      final boardingsJson = room['boardings'] as List<dynamic>? ?? [];

      for (final boardingJson in boardingsJson) {
        final boarding = boardingJson as Map<String, dynamic>;
        final boardingId = boarding['id']?.toString() ?? '';
        final boardingTitle = boarding['title']?.toString() ?? '';
        final rate = (boarding['rate'] as num?)?.toDouble() ?? 0;

        if (rate <= 0) continue;

        // BHR: 10% commission on the total rate
        final priceWithCommission = rate * 1.1;

        if (!boardingMap.containsKey(boardingId)) {
          boardingMap[boardingId] = _BoardingAccumulator(
            id: boardingId,
            name: boardingTitle,
            cheapest: priceWithCommission,
            roomCount: 1,
          );
        } else {
          final acc = boardingMap[boardingId]!;
          acc.roomCount++;
          if (priceWithCommission < acc.cheapest) {
            acc.cheapest = priceWithCommission;
          }
        }

        if (globalCheapest == null || priceWithCommission < globalCheapest) {
          globalCheapest = priceWithCommission;
        }
      }
    }

    for (final entry in boardingMap.entries) {
      pensions.add(
        PensionSummary(
          id: entry.value.id,
          name: entry.value.name,
          cheapestPrice: entry.value.cheapest,
          roomCount: entry.value.roomCount,
          currency: 'TND',
        ),
      );
    }

    return AvailabilityResult(
      hotelId: hotelJson['id']?.toString() ?? '',
      hotelName: hotelJson['name']?.toString() ?? '',
      hotelSlug: hotelJson['slug']?.toString(),
      cover: hotelJson['cover']?.toString(),
      vignette: hotelJson['vignette']?.toString(),
      stars: _parseStars(hotelJson),
      destinationName: _parseDestinationName(hotelJson),
      isAvailable: pensions.isNotEmpty,
      providerType: 'bhr',
      startingPrice: globalCheapest,
      currency: 'TND',
      nightCount: params.nights,
      pensions: pensions,
      reservable: true,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  AvailabilityResult _buildBasicResult(
    Map<String, dynamic> json,
    String providerType,
    AvailabilitySearchParams params,
  ) {
    return AvailabilityResult(
      hotelId: json['id']?.toString() ?? '',
      hotelName: json['name']?.toString() ?? '',
      hotelSlug: json['slug']?.toString(),
      cover: json['cover']?.toString(),
      vignette: json['vignette']?.toString(),
      stars: _parseStars(json),
      destinationName: _parseDestinationName(json),
      isAvailable: true,
      providerType: providerType.isNotEmpty ? providerType : null,
      nightCount: params.nights,
      reservable: true,
    );
  }

  int? _parseStars(Map<String, dynamic> json) {
    final code = json['category_code'] ?? json['stars'];
    if (code is int) return code;
    return int.tryParse(code?.toString() ?? '');
  }

  String? _parseDestinationName(Map<String, dynamic> json) {
    if (json['destination_name'] != null) {
      return json['destination_name'].toString();
    }
    if (json['destination'] is Map) {
      return json['destination']['name']?.toString();
    }
    return null;
  }

  Map<String, dynamic>? _extractHotelData(Map<String, dynamic> response) {
    // Response might be the hotel directly or wrapped in data/hotels
    if (response.containsKey('disponibility')) return response;

    // Single-hotel endpoint returns disponibility at the top level:
    // { "disponibilitytype": "tgt", "pensions": [...] }
    // Wrap it into the expected structure for _parseDisponibilityResult.
    if (response.containsKey('disponibilitytype') &&
        response.containsKey('pensions')) {
      return {'disponibility': response};
    }

    if (response['data'] is List && (response['data'] as List).isNotEmpty) {
      return (response['data'] as List).first as Map<String, dynamic>?;
    }
    if (response['hotels'] is List && (response['hotels'] as List).isNotEmpty) {
      return (response['hotels'] as List).first as Map<String, dynamic>?;
    }
    return null;
  }

  void _enrichResultsFromCatalog(
    List<AvailabilityResult> results,
    List<Hotel> catalog,
  ) {
    // Build lookup maps by slug and id for fast matching
    final bySlug = <String, Hotel>{};
    final byId = <String, Hotel>{};
    for (final hotel in catalog) {
      if (hotel.slug.isNotEmpty) bySlug[hotel.slug] = hotel;
      if (hotel.id.isNotEmpty) byId[hotel.id] = hotel;
    }

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final match =
          (result.hotelSlug != null ? bySlug[result.hotelSlug] : null) ??
          byId[result.hotelId];

      if (match != null) {
        results[i] = AvailabilityResult(
          hotelId: result.hotelId,
          hotelName: result.hotelName,
          hotelSlug: result.hotelSlug,
          cover: result.cover?.isNotEmpty == true ? result.cover : match.cover,
          vignette: result.vignette?.isNotEmpty == true
              ? result.vignette
              : (match.vignette.isNotEmpty ? match.vignette : null),
          stars: result.stars ?? match.categoryCode,
          destinationName: result.destinationName?.isNotEmpty == true
              ? result.destinationName
              : match.destinationName,
          isAvailable: result.isAvailable,
          rooms: result.rooms,
          offers: result.offers,
          minimumStayNights: result.minimumStayNights,
          reservable: result.reservable,
          providerType: result.providerType,
          startingPrice: result.startingPrice,
          currency: result.currency,
          nightCount: result.nightCount,
          pensions: result.pensions,
          pensionDetails: result.pensionDetails,
          address: result.address ?? match.address,
        );
      }
    }
  }

  /// Enriches a single result with catalog data.
  AvailabilityResult _enrichSingleResult(
    AvailabilityResult result,
    List<Hotel> catalog,
  ) {
    Hotel? match;
    for (final hotel in catalog) {
      if ((result.hotelSlug != null && hotel.slug == result.hotelSlug) ||
          hotel.id == result.hotelId) {
        match = hotel;
        break;
      }
    }

    if (match == null) return result;

    return AvailabilityResult(
      hotelId: result.hotelId.isNotEmpty ? result.hotelId : match.id,
      hotelName: result.hotelName.isNotEmpty ? result.hotelName : match.name,
      hotelSlug: result.hotelSlug ?? match.slug,
      cover: result.cover?.isNotEmpty == true ? result.cover : match.cover,
      vignette: result.vignette?.isNotEmpty == true
          ? result.vignette
          : (match.vignette.isNotEmpty ? match.vignette : null),
      stars: result.stars ?? match.categoryCode,
      destinationName: result.destinationName?.isNotEmpty == true
          ? result.destinationName
          : match.destinationName,
      isAvailable: result.isAvailable,
      rooms: result.rooms,
      offers: result.offers,
      minimumStayNights: result.minimumStayNights,
      reservable: result.reservable,
      providerType: result.providerType,
      startingPrice: result.startingPrice,
      currency: result.currency,
      nightCount: result.nightCount,
      pensions: result.pensions,
      pensionDetails: result.pensionDetails,
      address: result.address ?? match.address,
    );
  }

  // ── Fallback: client-side computation ─────────────────────────────────────

  Future<List<AvailabilityResult>> _fallbackSearch(
    AvailabilitySearchParams params,
  ) async {
    final allHotels = await _hotelRepo.getHotels(page: 1);

    List<Hotel> filtered;
    if (params.destinationId != null && params.destinationId!.isNotEmpty) {
      filtered = allHotels
          .where((h) => h.destinationId == params.destinationId)
          .toList();
    } else {
      filtered = allHotels;
    }

    final reservable = filtered.where((h) => h.reservable).take(20).toList();
    if (reservable.isEmpty) return [];

    final futures = reservable.map((hotel) async {
      try {
        final detail = await _hotelRepo.getHotelDetail(hotel.slug);
        if (detail == null) return _buildUnavailableResult(hotel);
        return _computeAvailability(hotel, detail, params);
      } catch (e) {
        return _buildUnavailableResult(hotel);
      }
    });

    final results = await Future.wait(futures);
    results.sort((a, b) {
      if (a.isAvailable != b.isAvailable) return a.isAvailable ? -1 : 1;
      return b.offers.length.compareTo(a.offers.length);
    });
    return results;
  }

  Future<AvailabilityResult> _fallbackSingleHotel(
    AvailabilitySearchParams params,
    String slug,
  ) async {
    final detail = await _hotelRepo.getHotelDetail(slug);
    if (detail == null) {
      return AvailabilityResult(
        hotelId: params.hotelId ?? '',
        hotelName: '',
        isAvailable: false,
      );
    }

    final hotel = Hotel(
      id: detail.id ?? params.hotelId ?? '',
      id_hotel_bbx: detail.idHotelBbx,
      email: detail.email,
      phone: detail.phone,
      name: detail.name,
      name_en: detail.nameEn ?? '',
      name_ar: detail.nameAr ?? '',
      name_ru: detail.nameRu ?? '',
      name_ja: detail.nameJa ?? '',
      name_ko: detail.nameKo ?? '',
      name_zh: detail.nameZh ?? '',
      address: detail.address,
      cover: detail.cover,
      vignette: detail.vignette ?? '',
      images: detail.images ?? [],
      video_link: detail.videoLink ?? '',
      lat: detail.lat.toString(),
      lng: detail.lng.toString(),
      reservable: detail.reservable,
      slug: detail.slug ?? slug,
      destinationId: detail.destinationId ?? '',
      categoryCode: int.tryParse(detail.categoryCode ?? ''),
      destinationName: detail.destination?.name,
    );

    return _computeAvailability(hotel, detail, params);
  }

  // ── Availability computation engine (fallback) ────────────────────────────

  AvailabilityResult _computeAvailability(
    Hotel hotel,
    HotelDetail detail,
    AvailabilitySearchParams params,
  ) {
    if (!detail.reservable) {
      return _buildResultFromDetail(hotel, detail, false, [], null);
    }

    bool releaseCovered = detail.releaseHotels.isEmpty;
    if (detail.releaseHotels.isNotEmpty) {
      releaseCovered = _isDateRangeCoveredByReleases(
        params.checkIn,
        params.checkOut,
        detail.releaseHotels,
      );
    }

    int? applicableMinStay;
    if (detail.minimumstay.isNotEmpty) {
      applicableMinStay = _getApplicableMinimumStay(
        params.checkIn,
        params.checkOut,
        detail.minimumstay,
      );
    }

    final meetsMinStay =
        applicableMinStay == null || params.nights >= applicableMinStay;
    final isAvailable = releaseCovered && meetsMinStay;

    final offers = <OfferBadge>[
      ..._getActiveFlashSales(
        params.checkIn,
        params.checkOut,
        detail.flashSales,
      ),
      ..._getActiveSpos(params.checkIn, detail.spo),
    ];

    return _buildResultFromDetail(
      hotel,
      detail,
      isAvailable,
      offers,
      applicableMinStay,
    );
  }

  bool _isDateRangeCoveredByReleases(
    DateTime checkIn,
    DateTime checkOut,
    List<ReleaseHotel> releases,
  ) {
    for (final release in releases) {
      final start = DateTime.tryParse(release.dateStart);
      final end = DateTime.tryParse(release.dateEnd);
      if (start == null || end == null) continue;
      if (!checkIn.isBefore(start) && !checkOut.isAfter(end)) return true;
    }
    return false;
  }

  int? _getApplicableMinimumStay(
    DateTime checkIn,
    DateTime checkOut,
    List<MinimumStay> rules,
  ) {
    for (final rule in rules) {
      final start = DateTime.tryParse(rule.dateStart);
      final end = DateTime.tryParse(rule.dateEnd);
      if (start == null || end == null) continue;
      if (!checkIn.isBefore(start) && !checkIn.isAfter(end)) return rule.number;
    }
    return null;
  }

  List<OfferBadge> _getActiveFlashSales(
    DateTime checkIn,
    DateTime checkOut,
    List<FlashSale> sales,
  ) {
    final badges = <OfferBadge>[];
    for (final sale in sales) {
      final start = DateTime.tryParse(sale.dateStart);
      final end = DateTime.tryParse(sale.dateEnd);
      if (start == null || end == null) continue;
      if (checkIn.isBefore(end) && checkOut.isAfter(start)) {
        badges.add(
          OfferBadge(
            type: 'flash_sale',
            label: 'Flash Sale',
            percentage: sale.percentage,
            validUntil: end,
          ),
        );
      }
    }
    return badges;
  }

  List<OfferBadge> _getActiveSpos(DateTime checkIn, List<Spo> spos) {
    final badges = <OfferBadge>[];
    final now = DateTime.now();
    for (final spo in spos) {
      final before = DateTime.tryParse(spo.dateBefore);
      final stayStart = DateTime.tryParse(spo.dateStartStay);
      final stayEnd = DateTime.tryParse(spo.dateEndStay);
      if (before == null || stayStart == null || stayEnd == null) continue;
      if (now.isBefore(before) &&
          checkIn.isBefore(stayEnd) &&
          checkIn.isAfter(stayStart.subtract(const Duration(days: 1)))) {
        final maxDiscount = spo.percentage.isNotEmpty
            ? spo.percentage.map((p) => p.value).reduce((a, b) => a > b ? a : b)
            : 0;
        if (maxDiscount > 0) {
          badges.add(
            OfferBadge(
              type: 'spo',
              label: 'Offre Spéciale',
              percentage: maxDiscount,
              validUntil: before,
            ),
          );
        }
      }
    }
    return badges;
  }

  AvailabilityResult _buildResultFromDetail(
    Hotel hotel,
    HotelDetail detail,
    bool isAvailable,
    List<OfferBadge> offers,
    int? minimumStayNights,
  ) {
    return AvailabilityResult(
      hotelId: hotel.id,
      hotelName: hotel.name,
      hotelSlug: hotel.slug,
      cover: hotel.cover,
      vignette: hotel.vignette.isNotEmpty ? hotel.vignette : detail.vignette,
      stars: hotel.categoryCode,
      destinationName: hotel.destinationName ?? detail.destination?.name,
      isAvailable: isAvailable,
      offers: offers,
      minimumStayNights: minimumStayNights,
      reservable: detail.reservable,
    );
  }

  AvailabilityResult _buildUnavailableResult(Hotel hotel) {
    return AvailabilityResult(
      hotelId: hotel.id,
      hotelName: hotel.name,
      hotelSlug: hotel.slug,
      cover: hotel.cover,
      vignette: hotel.vignette,
      stars: hotel.categoryCode,
      destinationName: hotel.destinationName,
      isAvailable: false,
      reservable: hotel.reservable,
    );
  }
}

/// Internal accumulator for BHR boarding aggregation.
class _BoardingAccumulator {
  final String id;
  final String name;
  double cheapest;
  int roomCount;

  _BoardingAccumulator({
    required this.id,
    required this.name,
    required this.cheapest,
    required this.roomCount,
  });
}
