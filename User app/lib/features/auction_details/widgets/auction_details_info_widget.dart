import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/vat_tax_type_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionDetailInfoWidget extends StatelessWidget {
  final UserCreatedAuctionEnum? auctionState;
  final String imageUrl;
  final String productName;
  final String productType;
  final String brand;
  final String category;
  final String itemCondition;
  final double startingPrice;
  final double minIncrement;
  final double maximumDecrement;
  final double minBidAmount;
  final double shippingFee;
  final List<TaxVats>? taxVats;
  final DateTime auctionStart;
  final DateTime auctionEnd;
  final String returnPolicy;
  final double highestBid;
  final int totalView;

  const AuctionDetailInfoWidget({
    super.key,
    required this.auctionState,
    required this.imageUrl,
    required this.productName,
    required this.productType,
    required this.brand,
    required this.category,
    required this.itemCondition,
    required this.startingPrice,
    required this.minIncrement,
    required this.maximumDecrement,
    required this.minBidAmount,
    required this.shippingFee,
    this.taxVats,
    required this.auctionStart,
    required this.auctionEnd,
    required this.returnPolicy,
    required this.highestBid,
    required this.totalView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        border: Border.all(width: 0.5, color: Theme.of(context).hintColor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        child: CustomImageWidget(
                          image: imageUrl,
                          width: 90,
                          height: 90,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Row(
                        children: [
                          MetaChip(label: getTranslated('brand', context)!, value: brand),

                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            child: Text('|',
                              style: titilliumRegular.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ),

                          Flexible(child: MetaChip(label: getTranslated('category', context)!, value: category)),
                        ],
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                      MetaChip(
                        label: getTranslated('item_condition', context)!,
                        value: itemCondition,
                        showInfo: true,
                        tooltipMessage: getTranslated('item_condition_tooltip', context) ?? '',
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: .2)),

            if (auctionState != null &&
                auctionState != UserCreatedAuctionEnum.pending &&
                auctionState != UserCreatedAuctionEnum.rejected &&
                auctionState != UserCreatedAuctionEnum.upcoming)...[
              Text(getTranslated('bidding_info', context)!,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              InfoRow(
                label: getTranslated('highest_bid', context)!,
                value: PriceConverter.convertPrice(context, highestBid),
              ),
              InfoRow(
                label: getTranslated('total_view', context)!,
                value: '$totalView',
              ),
            ],

            Text(getTranslated('pricing_info', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            InfoRow(
              label: getTranslated('starting_price', context)!,
              value: PriceConverter.convertPrice(context, startingPrice),
            ),

            InfoRow(
              label: getTranslated('min_increment', context)!,
              value: PriceConverter.convertPrice(context, minIncrement),
            ),

            InfoRow(
              label: getTranslated('maximum_decrement', context)!,
              value: PriceConverter.convertPrice(context, maximumDecrement),
            ),

            InfoRow(
              label: getTranslated('min_bid_amount', context)!,
              value: PriceConverter.convertPrice(context, minBidAmount),
            ),

            InfoRow(
              label: getTranslated('shipping_fee', context)!,
              value: PriceConverter.convertPrice(context, shippingFee),
            ),

            if (taxVats != null && taxVats!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        getTranslated('tax_rate', context)!,
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.titleMedium?.color,
                        ),
                      ),
                    ),

                    Expanded(
                      flex: 3,
                      child: Wrap(
                        spacing: Dimensions.paddingSizeExtraSmall,
                        runSpacing: Dimensions.paddingSizeExtraSmall,
                        children: taxVats!.map((t) {
                          return Text(
                            '${t.tax?.name ?? ''} (${t.tax?.taxRate?.toStringAsFixed(1)}%)', // PriceConverter.convertPrice(context, t.tax?.taxRate?)
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

            Divider(height: Dimensions.paddingSizeLarge, color: Theme.of(context).hintColor.withValues(alpha: .2)),

            Text(
              getTranslated('auction_info', context)!,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              getTranslated('auction_duration', context)!,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

            Text(
              '${DateConverter.localDateToIsoStringAMPMOrder(auctionStart)} - ${DateConverter.localDateToIsoStringAMPMOrder(auctionEnd)}',
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Text(
              getTranslated('return_policy', context)!,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

            Text(
              returnPolicy,
              style: titilliumBold.copyWith(
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

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Text(
              value,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetaChip extends StatefulWidget {
  final String label;
  final String value;
  final bool showInfo;
  final String? tooltipMessage;

  const MetaChip({
    super.key,
    required this.label,
    required this.value,
    this.showInfo = false,
    this.tooltipMessage,
  });

  @override
  State<MetaChip> createState() => _MetaChipState();
}

class _MetaChipState extends State<MetaChip> {
  final JustTheController _tooltipController = JustTheController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${widget.label}  ',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          if (widget.showInfo)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: widget.tooltipMessage != null && widget.tooltipMessage!.isNotEmpty
                  ? JustTheTooltip(
                      backgroundColor: Colors.black87,
                      controller: _tooltipController,
                      preferredDirection: AxisDirection.down,
                      tailLength: 10,
                      tailBaseWidth: 20,
                      content: Container(
                        width: 150,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        child: Text(
                          widget.tooltipMessage!,
                          style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _tooltipController.showTooltip(),
                        child: Icon(
                          Icons.info,
                          size: Dimensions.iconSizeExtraSmall,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.info,
                      size: Dimensions.iconSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                    ),
            ),
          if (widget.showInfo) const TextSpan(text: '  '),
          TextSpan(
            text: widget.value,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}