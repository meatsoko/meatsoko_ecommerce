// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_asset_image_widget.dart';
import 'package:user_app/common/basewidget/custom_button_widget.dart';
import 'package:user_app/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionTransactionFilterBottomSheetWidget extends StatefulWidget {
  final int? searchAuctionId;

  const AuctionTransactionFilterBottomSheetWidget({super.key, this.searchAuctionId});

  @override
  State<AuctionTransactionFilterBottomSheetWidget> createState() => _AuctionTransactionFilterBottomSheetWidgetState();
}

class _AuctionTransactionFilterBottomSheetWidgetState extends State<AuctionTransactionFilterBottomSheetWidget> {
  static const List<String> _filterByList = ['all', 'credit', 'debit'];
  static const List<String> _durationList = ['all', 'today', 'this_week', 'this_month', 'this_year'];

  @override
  void initState() {
    super.initState();
    Provider.of<AuctionTransactionController>(context, listen: false).initFilterData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionTransactionController>(
      builder: (context, controller, _) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.70),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.paddingSizeTwelve),
              topRight: Radius.circular(Dimensions.paddingSizeTwelve),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                child: Stack(children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      getTranslated('filter_data', context) ?? 'Filter',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  Positioned(
                    right: Dimensions.paddingSizeDefault,
                    top: Dimensions.paddingSizeTwelve,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).hintColor.withValues(alpha: .25),
                        ),
                        child: const Center(child: CustomAssetImageWidget(Images.crossIcon, height: 15)),
                      ),
                    ),
                  ),
                ]),
              ),
              Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated('filter_by', context) ?? 'Filter By',
                            style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Wrap(
                          spacing: Dimensions.paddingSizeSmall,
                          children: _filterByList.map((type) {
                            final bool isSelected = controller.selectedFilterBy == type || (controller.selectedFilterBy == null && type == 'all');
                            return ChoiceChip(
                              label: Text(getTranslated(type, context) ?? type),
                              selected: isSelected,
                              onSelected: (_) => controller.setSelectedFilterBy(type: type == 'all' ? null : type),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),
                        Text(getTranslated('duration', context) ?? 'Duration',
                            style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Wrap(
                          spacing: Dimensions.paddingSizeSmall,
                          children: _durationList.map((type) {
                            final bool isSelected = controller.selectedDurationType == type;
                            return ChoiceChip(
                              label: Text(getTranslated(type, context) ?? type),
                              selected: isSelected,
                              onSelected: (_) => controller.setSelectedDurationType(type),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: getTranslated('clear_filter', context) ?? 'Clear Filter',
                        backgroundColor: Theme.of(context).primaryColor.withValues(alpha: .125),
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        onTap: () {
                          Navigator.pop(context);
                          controller.setSelectedFilterBy(type: null);
                          controller.setSelectedDurationType('all');
                          controller.getAuctionTransactionList(
                            context,
                            isRefresh: true,
                            searchAuctionId: widget.searchAuctionId,
                            applyFilter: true,
                            filterBy: null,
                            filterDurationType: 'all',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: CustomButton(
                        buttonText: getTranslated('filter', context) ?? 'Filter',
                        onTap: () {
                          Navigator.pop(context);
                          controller.getAuctionTransactionList(
                            context,
                            isRefresh: true,
                            searchAuctionId: widget.searchAuctionId,
                            applyFilter: true,
                            filterBy: controller.selectedFilterBy,
                            filterDurationType: controller.selectedDurationType,
                            startDate: controller.startDate,
                            endDate: controller.endDate,
                          );
                        },
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
