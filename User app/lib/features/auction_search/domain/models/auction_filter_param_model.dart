class AuctionFilterParamModel {
  final String? listingSelection;
  final String? uiSortBy;
  final Set<int> categoryIds;
  final Set<int> brandIds;
  final double? priceMin;
  final double? priceMax;
  final double? entryFeeMin;
  final double? entryFeeMax;
  final String? endingTime;

  const AuctionFilterParamModel({
    this.listingSelection,
    this.uiSortBy,
    this.categoryIds = const {},
    this.brandIds = const {},
    this.priceMin,
    this.priceMax,
    this.entryFeeMin,
    this.entryFeeMax,
    this.endingTime,
  });

  static const _listingTypeValues = {
    'ending_soon', 'trending', 'live', 'upcoming', 'no_bids_yet'
  };

  String? get auctionStatus => listingSelection == 'live' || listingSelection == 'upcoming' ? listingSelection : null;

  int get activeFilterCount {
    int count = 0;
    if (listingSelection != null) count++;
    if (uiSortBy != null && uiSortBy != 'default') count++;
    if (categoryIds.isNotEmpty) count++;
    if (brandIds.isNotEmpty) count++;
    if (priceMin != null || priceMax != null) count++;
    if (entryFeeMin != null || entryFeeMax != null) count++;
    if (endingTime != null) count++;
    return count;
  }

  static const double kPriceMax = 1000; /// TODO: SHOULD MAKE IT DYNAMIC (ASK FOR NEW FIELD IN CONFIG MODEL)
  static const double kEntryFeeMax = 1000; /// TODO: SHOULD MAKE IT DYNAMIC (ASK FOR NEW FIELD IN CONFIG MODEL)

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {};

    if (uiSortBy != null && uiSortBy != 'default') {
      params['sort_by'] = uiSortBy;
    }

    if (listingSelection != null && _listingTypeValues.contains(listingSelection)) {
      params['listing_type'] = listingSelection;
    }

    if (categoryIds.isNotEmpty) params['category_ids'] = categoryIds.toList();
    if (brandIds.isNotEmpty) params['brand_ids'] = brandIds.toList();

    if (priceMin != null && priceMin! > 0) params['min_price'] = priceMin;
    if (priceMax != null && priceMax! < kPriceMax) params['max_price'] = priceMax;

    if (entryFeeMin != null && entryFeeMin! > 0) params['min_entry_fee'] = entryFeeMin;
    if (entryFeeMax != null && entryFeeMax! < kEntryFeeMax) params['max_entry_fee'] = entryFeeMax;

    if (endingTime != null) params['ending_time'] = endingTime;

    return params;
  }

  AuctionFilterParamModel copyWith({
    String? listingSelection,
    String? uiSortBy,
    Set<int>? categoryIds,
    Set<int>? brandIds,
    double? priceMin,
    double? priceMax,
    double? entryFeeMin,
    double? entryFeeMax,
    String? endingTime,
    bool clearListing = false,
    bool clearUiSortBy = false,
    bool clearPriceRange = false,
    bool clearEntryFeeRange = false,
    bool clearEndingTime = false,
  }) {
    return AuctionFilterParamModel(
      listingSelection: clearListing ? null : (listingSelection ?? this.listingSelection),
      uiSortBy: clearUiSortBy ? null : (uiSortBy ?? this.uiSortBy),
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      priceMin: clearPriceRange ? null : (priceMin ?? this.priceMin),
      priceMax: clearPriceRange ? null : (priceMax ?? this.priceMax),
      entryFeeMin: clearEntryFeeRange ? null : (entryFeeMin ?? this.entryFeeMin),
      entryFeeMax: clearEntryFeeRange ? null : (entryFeeMax ?? this.entryFeeMax),
      endingTime: clearEndingTime ? null : (endingTime ?? this.endingTime),
    );
  }
}