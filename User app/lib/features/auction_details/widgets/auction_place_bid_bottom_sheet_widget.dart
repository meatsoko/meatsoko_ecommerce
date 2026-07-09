import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionPlaceBidBottomSheet extends StatefulWidget {
  final int auctionProductId;
  final double highestBid;
  final double stepAmount;
  final List<double> suggestedAmounts;
  final Function(double) onPlaceBid;
  final Function(double)? onRollbackBid;
  final bool isFirstBid;
  final bool isLeadBid;
  final bool hasUsedRollback;
  final double? myCurrentBidAmount;
  final double? minimumRollbackBid;

  const AuctionPlaceBidBottomSheet({
    super.key,
    this.auctionProductId = 0,
    required this.highestBid,
    this.stepAmount = 1.0,
    required this.suggestedAmounts,
    required this.onPlaceBid,
    this.onRollbackBid,
    this.isFirstBid = false,
    this.isLeadBid = false,
    this.hasUsedRollback = false,
    this.myCurrentBidAmount,
    this.minimumRollbackBid,
  });

  static Future<void> show(
      BuildContext context, {
        int auctionProductId = 0,
        required double highestBid,
        double stepAmount = 1.0,
        required List<double> suggestedAmounts,
        required Function(double) onPlaceBid,
        Function(double)? onRollbackBid,
        bool isFirstBid = false,
        bool isLeadBid = false,
        bool hasUsedRollback = false,
        double? myCurrentBidAmount,
        double? minimumRollbackBid,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      builder: (_) => AuctionPlaceBidBottomSheet(
        auctionProductId: auctionProductId,
        highestBid: highestBid,
        stepAmount: stepAmount,
        suggestedAmounts: suggestedAmounts,
        onPlaceBid: onPlaceBid,
        onRollbackBid: onRollbackBid,
        isFirstBid: isFirstBid,
        isLeadBid: isLeadBid,
        hasUsedRollback: hasUsedRollback,
        myCurrentBidAmount: myCurrentBidAmount,
        minimumRollbackBid: minimumRollbackBid,
      ),
    );
  }

  @override
  State<AuctionPlaceBidBottomSheet> createState() => _AuctionPlaceBidBottomSheetState();
}

class _AuctionPlaceBidBottomSheetState extends State<AuctionPlaceBidBottomSheet> {
  late double _currentAmount;
  int? _selectedSuggestionIndex;
  bool _showBidError = false;
  late TextEditingController _amountController;
  final FocusNode _amountFocusNode = FocusNode();

  int _decimalPlaces() {
    return Provider.of<SplashController>(context, listen: false).configModel?.decimalPointSettings ?? 1;
  }

  bool get _canRollback =>
      widget.isLeadBid && !widget.hasUsedRollback &&
          widget.myCurrentBidAmount != null &&
          _currentAmount < PriceConverter.toLocalDouble(context, widget.myCurrentBidAmount!);

  bool get _isRollback => _currentAmount < PriceConverter.toLocalDouble(context, widget.highestBid);

  @override
  void initState() {
    super.initState();
    _currentAmount = PriceConverter.toLocalDouble(context, widget.suggestedAmounts.isNotEmpty
        ? widget.suggestedAmounts.first
        : widget.isFirstBid
            ? widget.highestBid
            : widget.highestBid + widget.stepAmount);
    _selectedSuggestionIndex = widget.suggestedAmounts.isNotEmpty ? 0 : null;
    _amountController = TextEditingController(text: _currentAmount.toStringAsFixed(_decimalPlaces()));
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) _onAmountFocusLost();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    setState(() {
      _currentAmount = parsed;
      _selectedSuggestionIndex = _getSuggestionIndex(_currentAmount);
    });
  }

  void _onAmountFocusLost() {
    if (widget.isLeadBid && !widget.hasUsedRollback) {
      final floor = widget.minimumRollbackBid != null
          ? PriceConverter.toLocalDouble(context, widget.minimumRollbackBid!)
          : null;
      if (floor != null && _currentAmount < floor) {
        setState(() {
          _currentAmount = floor;
          _amountController.text = floor.toStringAsFixed(_decimalPlaces());
          _selectedSuggestionIndex = _getSuggestionIndex(floor);
        });
      }
      return;
    }

    final minAmount = PriceConverter.toLocalDouble(
        context, widget.isFirstBid ? widget.highestBid : widget.highestBid + widget.stepAmount);
    if (_currentAmount < minAmount) {
      setState(() {
        _currentAmount = minAmount;
        _amountController.text = minAmount.toStringAsFixed(_decimalPlaces());
        _selectedSuggestionIndex = _getSuggestionIndex(minAmount);
      });
    }
  }

  void _increment() {
    setState(() {
      _currentAmount += PriceConverter.toLocalDouble(context, widget.stepAmount);
      _selectedSuggestionIndex = _getSuggestionIndex(_currentAmount);
      _amountController.text = _currentAmount.toStringAsFixed(_decimalPlaces());
    });
  }

  void _decrement() {
    final localStep = PriceConverter.toLocalDouble(context, widget.stepAmount);
    final newAmount = _currentAmount - localStep;

    if (widget.isLeadBid && !widget.hasUsedRollback) {
      final floor = widget.minimumRollbackBid != null
          ? PriceConverter.toLocalDouble(context, widget.minimumRollbackBid!)
          : 0.01;
      if (newAmount >= floor) {
        setState(() {
          _currentAmount = newAmount;
          _selectedSuggestionIndex = _getSuggestionIndex(_currentAmount);
          _amountController.text = _currentAmount.toStringAsFixed(_decimalPlaces());
        });
      }
      return;
    }

    final minAmount = PriceConverter.toLocalDouble(
        context, widget.isFirstBid ? widget.highestBid : widget.highestBid + widget.stepAmount);
    if (newAmount >= minAmount) {
      setState(() {
        _currentAmount = newAmount;
        _selectedSuggestionIndex = _getSuggestionIndex(_currentAmount);
        _amountController.text = _currentAmount.toStringAsFixed(_decimalPlaces());
      });
    }
  }

  void _selectSuggestion(int index) {
    setState(() {
      _selectedSuggestionIndex = index;
      _currentAmount = PriceConverter.toLocalDouble(context, widget.suggestedAmounts[index]);
      _amountController.text = _currentAmount.toStringAsFixed(_decimalPlaces());
    });
  }

  int? _getSuggestionIndex(double localAmount) {
    for (int i = 0; i < widget.suggestedAmounts.length; i++) {
      if (PriceConverter.toLocalDouble(context, widget.suggestedAmounts[i]) == localAmount) return i;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionParticipationController>(
      builder: (context, auctionController, _) {
        debugPrint("_amountController: ${_amountController.text}");

        final isBidLoading = auctionController.isBidLoading;
        final isRollbackLoading = auctionController.isRollbackBidLoading;
        final canRollback = _canRollback;
        final isRollback = _isRollback;

        return Padding(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeLarge,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
          ),
          child: Column(mainAxisSize: MainAxisSize.min,
            children: [
              Stack(alignment: Alignment.center,
                children: [

                  if(!widget.isFirstBid)
                  Column(
                    children: [
                      Text(PriceConverter.convertPrice(context, widget.highestBid),
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      Text(getTranslated('highest_bid', context) ?? "",
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),


                  Align(alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraExtraSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: .2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: Dimensions.iconSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(
                  children: [
                    Text(getTranslated('enter_amount_higher_than_current_bid', context) ?? "",
                      textAlign: TextAlign.center,
                      style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    Container(
                      width: 240,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .2)),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _decrement,
                            child: Container(
                              margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                color: Theme.of(context).hintColor.withValues(alpha: 0.20)
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(Icons.arrow_downward_rounded, color: Theme.of(context).colorScheme.error, size: Dimensions.iconSizeExtraSmall),
                            ),
                          ),
                          Flexible(
                            child: TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: _onAmountChanged,
                            ),
                          ),
                          GestureDetector(
                            onTap: _increment,
                            child: Container(
                              margin : const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  color: Theme.of(context).hintColor.withValues(alpha: 0.20)
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                size: Dimensions.iconSizeExtraSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Row(children: [],),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              SizedBox(
                height: 35,
                child: Center(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.suggestedAmounts.length,
                    separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedSuggestionIndex == index;
                      return GestureDetector(
                        onTap: () => _selectSuggestion(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeEight, horizontal: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.radiusHundred),
                            border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).hintColor.withValues(alpha: .3)),
                          ),
                          child: Center(
                            child: Text(PriceConverter.convertPrice(context, widget.suggestedAmounts[index]),
                              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall,
                                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (_showBidError)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                        size: Dimensions.iconSizeExtraSmall,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Expanded(
                        child: Text(
                          getTranslated('bid_amount_less_than_required', context) ?? '',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (isRollback && widget.minimumRollbackBid != null &&
                  _currentAmount == PriceConverter.toLocalDouble(context, widget.minimumRollbackBid!) &&
                  !_showBidError)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    ),
                    child: Builder(builder: (context) {
                        final template = getTranslated('rollback_bid_info', context) ?? '';
                        final amount = PriceConverter.convertPrice(context, widget.minimumRollbackBid ?? 0);
                        final parts = template.split('{amount}');
                        final baseStyle = titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.titleMedium!.color,
                        );
                        return Text.rich(TextSpan(children: [
                          TextSpan(text: parts.first, style: baseStyle),
                          TextSpan(text: amount, style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
                          if (parts.length > 1) TextSpan(text: parts.last, style: baseStyle),
                        ]));
                      }),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: (isBidLoading || isRollbackLoading) ? null : () {
                      setState(() => _showBidError = false);
                      if (canRollback && widget.onRollbackBid != null) {
                        widget.onRollbackBid!(_currentAmount);
                      } else {
                        widget.onPlaceBid(_currentAmount);
                      }
                    },
                    icon: (isBidLoading || isRollbackLoading) ?
                      const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 1, color: Colors.white))
                      : CustomAssetImageWidget(Images.gavelOutlinedIcon),
                    label: Text(
                      getTranslated(!isRollback ? 'place_bid' : 'update_bid', context) ?? "",
                      style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                      elevation: 0,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
