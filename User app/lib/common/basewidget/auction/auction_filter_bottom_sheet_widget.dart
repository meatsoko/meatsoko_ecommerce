import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_category/controllers/auction_category_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/domain/models/auction_filter_param_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionFilterBottomSheet extends StatefulWidget {
  final AuctionFilterParamModel? initialFilter;
  final bool isCategoryPage;
  final int? categoryId;

  const AuctionFilterBottomSheet({
    super.key,
    this.initialFilter,
    this.isCategoryPage = false,
    this.categoryId,
  });

  static Future<AuctionFilterParamModel?> show(
    BuildContext context, {
    AuctionFilterParamModel? currentFilter,
    bool isCategoryPage = false,
    int? categoryId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      builder: (_) => AuctionFilterBottomSheet(
        initialFilter: currentFilter,
        isCategoryPage: isCategoryPage,
        categoryId: categoryId,
      ),
    );
  }

  @override
  State<AuctionFilterBottomSheet> createState() => _AuctionFilterBottomSheetState();
}

class _AuctionFilterBottomSheetState extends State<AuctionFilterBottomSheet> {

  late String _selectedSort;
  late String _selectedListing;
  late String? _endingTime;
  late RangeValues _entryFeeRange;
  late RangeValues _priceRange;
  late Set<int> _selectedCategoryIds;
  late Set<int> _selectedBrandIds;

  bool _showAllCategories = false;
  bool _showAllBrands = false;
  static const int _initialCategoryCount = 5;
  static const int _initialBrandCount = 5;
  static double get _entryFeeMax => AuctionFilterParamModel.kEntryFeeMax;
  static double get _priceMax => AuctionFilterParamModel.kPriceMax;

  static RangeValues _safeRange(double? min, double? max, double fullMax) {
    final double start = (min != null && min >= 1.0) ? min : 1.0;
    final double end   = (max != null && max > start) ? max : fullMax;
    return start < end ? RangeValues(start, end) : RangeValues(1.0, fullMax);
  }

  List<({String value, String label})> getSortOptions(BuildContext context) {
    return [
      (value: 'default', label: getTranslated("default_recent_created", context)!),
      (value: 'auction_price_low_to_high', label: getTranslated("auction_price_low_to_high", context)!),
      (value: 'auction_price_high_to_low', label: getTranslated("auction_price_high_to_low", context)!),
      (value: 'bid_lowest_to_highest', label: getTranslated("bid_lowest_to_highest", context)!),
      (value: 'bid_highest_to_lowest', label: getTranslated("bid_highest_to_lowest", context)!),
    ];
  }

  List<({String value, String label})> getListingOptions(BuildContext context) {
    return [
      (value: 'ending_soon', label: getTranslated("ending_soon", context)!),
      (value: 'trending', label: getTranslated("trending", context)!),
      (value: 'live', label: getTranslated("live", context)!),
      (value: 'upcoming', label: getTranslated("upcoming", context)!),
      (value: 'no_bids_yet', label: getTranslated("no_bids_yet", context)!),
    ];
  }

  void _applyFilters() {
    if (_priceRange.start <= 0 || _priceRange.end <= 0) {
      showCustomSnackBarWidget(getTranslated('price_range_min_max_validation', context)!, context, snackBarType: SnackBarType.error);
      return;
    }
    if (_entryFeeRange.start <= 0 || _entryFeeRange.end <= 0) {
      showCustomSnackBarWidget(getTranslated('entry_fee_min_max_validation', context)!, context, snackBarType: SnackBarType.error);
      return;
    }
    final model = AuctionFilterParamModel(
      listingSelection: _selectedListing == 'default' ? null : _selectedListing,
      uiSortBy: _selectedSort == 'default' ? null : _selectedSort,
      categoryIds: Set.from(_selectedCategoryIds),
      brandIds: Set.from(_selectedBrandIds),
      endingTime: _endingTime,
      priceMin: _priceRange.start > 1.0 ? _priceRange.start : null,
      priceMax: _priceRange.end < _priceMax ? _priceRange.end : null,
      entryFeeMin: _entryFeeRange.start > 1.0 ? _entryFeeRange.start : null,
      entryFeeMax: _entryFeeRange.end < _entryFeeMax ? _entryFeeRange.end : null,
    );
    Navigator.pop(context, model);
  }

  @override
  void initState() {
    super.initState();
    final f = widget.initialFilter;
    _selectedSort        = f?.uiSortBy ?? 'default';
    _selectedListing     = f?.listingSelection ?? 'ending_soon';
    _endingTime          = f?.endingTime;
    _priceRange    = _safeRange(f?.priceMin, f?.priceMax, _priceMax);
    _entryFeeRange = _safeRange(f?.entryFeeMin, f?.entryFeeMax, _entryFeeMax);
    _selectedCategoryIds = Set.from(f?.categoryIds ?? {});
    _selectedBrandIds    = Set.from(f?.brandIds ?? {});

    if (widget.isCategoryPage && widget.categoryId != null) {
      _selectedCategoryIds.add(widget.categoryId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionCategoryController>(context, listen: false).getCategoryList(false);
      Provider.of<BrandController>(context, listen: false).getBrandList(offset: 1);
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedSort    = 'default';
      _selectedListing = 'ending_soon';
      _endingTime      = null;
      _entryFeeRange   = RangeValues(1.0, _entryFeeMax);
      _priceRange      = RangeValues(1.0, _priceMax);
      _selectedCategoryIds.clear();
      if (widget.isCategoryPage && widget.categoryId != null) {
        _selectedCategoryIds.add(widget.categoryId!);
      }
      _selectedBrandIds.clear();
      _showAllCategories  = false;
      _showAllBrands   = false;
    });
    final clearedCategoryIds = (widget.isCategoryPage && widget.categoryId != null) ? {widget.categoryId!} : const <int>{};
    Navigator.of(context).pop(AuctionFilterParamModel(categoryIds: clearedCategoryIds));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              child: Row(
                children: [
                  const Spacer(),
                  Text(
                    getTranslated('filter_data', context)!,
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraExtraSmall),
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor.withValues(alpha: .15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: Dimensions.iconSizeSmall,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SortingSection(
                      selectedValue: _selectedSort,
                      options: getSortOptions(context),
                      onChanged: (val) => setState(() => _selectedSort = val),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _AuctionListingSection(
                      selectedValue: _selectedListing,
                      options: getListingOptions(context),
                      onChanged: (val) => setState(() => _selectedListing = val),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _AuctionEndingTimeSection(
                      selectedValue: _endingTime,
                      onChanged: (val) => setState(() => _endingTime = val == _endingTime ? null : val),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _RangeSection(
                      title: getTranslated('auction_entry_fee', context)!,
                      range: _entryFeeRange,
                      max: _entryFeeMax,
                      onChanged: (val) => setState(() => _entryFeeRange = val),
                      onApply: _applyFilters
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    _RangeSection(
                      title: getTranslated('price_range', context)!,
                      range: _priceRange,
                      max: _priceMax,
                      onChanged: (val) => setState(() => _priceRange = val),
                      onApply: _applyFilters
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    if (!widget.isCategoryPage) ...[
                      _CategorySection(
                        selectedIds: _selectedCategoryIds,
                        showAll: _showAllCategories,
                        initialCount: _initialCategoryCount,
                        onSeeMoreTap: () => setState(() => _showAllCategories = !_showAllCategories),
                        onToggle: (id) {
                          setState(() {
                            if (_selectedCategoryIds.contains(id)) {
                              _selectedCategoryIds.remove(id);
                            } else {
                              _selectedCategoryIds.add(id);
                            }
                          });
                        },
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],

                    _BrandSection(
                      selectedBrandIds: _selectedBrandIds,
                      showAll: _showAllBrands,
                      initialCount: _initialBrandCount,
                      onToggle: (id) {
                        setState(() {
                          if (_selectedBrandIds.contains(id)) {
                            _selectedBrandIds.remove(id);
                          } else {
                            _selectedBrandIds.add(id);
                          }
                        });
                      },
                      onSeeMoreTap: () => setState(() => _showAllBrands = !_showAllBrands),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha: .075),
                    blurRadius: 5,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: .3)),
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                      ),
                      child: Text(
                        getTranslated('clear_filter', context)!,
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        getTranslated('filter', context)!,
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        );
      },
    );
  }
}

class _SortingSection extends StatelessWidget {
  final String selectedValue;
  final List<({String value, String label})> options;
  final ValueChanged<String> onChanged;

  const _SortingSection({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: getTranslated('sorting', context)!,
      child: RadioGroup<String>(
        groupValue: selectedValue,
        onChanged: (val) { if (val != null) onChanged(val); },
        child: Column(
          children: options.map((option) => _RadioRow(
            label: option.label,
            value: option.value,
            onChanged: onChanged,
          )).toList(),
        ),
      ),
    );
  }
}

class _AuctionListingSection extends StatelessWidget {
  final String selectedValue;
  final List<({String value, String label})> options;
  final ValueChanged<String> onChanged;

  const _AuctionListingSection({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: getTranslated('auction_listings', context)!,
      child: RadioGroup<String>(
        groupValue: selectedValue,
        onChanged: (val) { if (val != null) onChanged(val); },
        child: Column(
          children: options.map((option) => _RadioRow(
            label: option.label,
            value: option.value,
            onChanged: onChanged,
          )).toList(),
        ),
      ),
    );
  }
}

class _AuctionEndingTimeSection extends StatelessWidget {
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  const _AuctionEndingTimeSection({
    required this.selectedValue,
    required this.onChanged,
  });

  static const List<({String value, String label})> _options = [
    (value: '1h',  label: 'Within 1 hour'),
    (value: '6h',  label: 'Within 6 hours'),
    (value: '24h', label: 'Within 24 hours'),
  ];

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: getTranslated('auction_ending_time', context)!,
      child: RadioGroup<String>(
        groupValue: selectedValue ?? '',
        onChanged: (val) { if (val != null) onChanged(val); },
        child: Column(
          children: _options.map((option) => _RadioRow(
            label: option.label,
            value: option.value,
            onChanged: onChanged,
          )).toList(),
        ),
      ),
    );
  }
}

class _RangeSection extends StatelessWidget {
  final String title;
  final RangeValues range;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  final VoidCallback onApply;

  const _RangeSection({
    required this.title,
    required this.range,
    required this.max,
    required this.onChanged,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: title,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Min', style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              )),
              Text('Max', style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              )),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

          Row(
            children: [
              Expanded(child: _RangeInputBox(value: PriceConverter.convertPrice(context, range.start))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text('-', style: titilliumBold.copyWith(color: Theme.of(context).hintColor)),
              ),
              Expanded(child: _RangeInputBox(value: PriceConverter.convertPrice(context, range.end))),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              GestureDetector(
                onTap: onApply,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: Dimensions.iconSizeSmall),
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.primary.withValues(alpha: .2),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: .1),
            ),
            child: RangeSlider(values: range, min: 1, max: max, onChanged: onChanged, divisions: max.toInt() - 1),
          ),
        ],
      ),
    );
  }
}

class _RangeInputBox extends StatelessWidget {
  final String value;
  const _RangeInputBox({required this.value});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      style: titilliumRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: value,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: .3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: .3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final Set<int> selectedIds;
  final bool showAll;
  final int initialCount;
  final ValueChanged<int> onToggle;
  final VoidCallback onSeeMoreTap;

  const _CategorySection({
    required this.selectedIds,
    required this.showAll,
    required this.initialCount,
    required this.onToggle,
    required this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: getTranslated('category', context)!,
      child: Consumer<AuctionCategoryController>(
        builder: (context, categoryController, _) {
          final categories = categoryController.categoryList;
          if (categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final visibleCategories = showAll ? categories : categories.take(initialCount).toList();
          final remaining = categories.length - initialCount;
          final hasMore = categories.length > initialCount;

          return Column(
            children: [
              ...visibleCategories.map((category) => _CheckboxRow(
                label: category.name ?? '',
                isSelected: selectedIds.contains(category.id),
                onToggle: () => onToggle(category.id ?? 0),
              )),
              if (hasMore) ...[
                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                GestureDetector(
                  onTap: onSeeMoreTap,
                  child: Text(
                    showAll ? getTranslated('see_less', context)! : '${getTranslated('see_more', context)!} ($remaining)',
                    style: titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  final Set<int> selectedBrandIds;
  final bool showAll;
  final int initialCount;
  final ValueChanged<int> onToggle;
  final VoidCallback onSeeMoreTap;

  const _BrandSection({
    required this.selectedBrandIds,
    required this.showAll,
    required this.initialCount,
    required this.onToggle,
    required this.onSeeMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return _FilterCard(
      title: getTranslated('brand', context)!,
      child: Consumer<BrandController>(
        builder: (context, brandController, _) {
          final brands = brandController.brandList;
          if (brands.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final visibleBrands = showAll ? brands : brands.take(initialCount).toList();
          final remaining = brands.length - initialCount;
          final hasMore = brands.length > initialCount;

          return Column(
            children: [
              _CheckboxRow(
                label: getTranslated('all', context)!,
                isSelected: selectedBrandIds.isEmpty,
                onToggle: () {
                  if (selectedBrandIds.isNotEmpty) selectedBrandIds.clear();
                },
              ),
              ...visibleBrands.map((brand) => _CheckboxRow(
                label: brand.name ?? '',
                isSelected: selectedBrandIds.contains(brand.id),
                onToggle: () => onToggle(brand.id ?? 0),
              )),
              if (hasMore) ...[
                Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                GestureDetector(
                  onTap: onSeeMoreTap,
                  child: Text(
                    showAll ? getTranslated('see_less', context)! : '${getTranslated('see_more', context)!} ($remaining)',
                    style: titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _RadioRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              activeColor: Theme.of(context).colorScheme.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(label,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onToggle;

  const _CheckboxRow({
    required this.label,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Checkbox(
              value: isSelected,
              onChanged: (_) => onToggle(),
              activeColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}