import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionInsightsWidget extends StatefulWidget {
  final int totalBids;
  final double avgBidIncrease;
  final double highestJump;
  final DateTime auctionExpiredAt;

  const AuctionInsightsWidget({
    super.key,
    required this.totalBids,
    required this.avgBidIncrease,
    required this.highestJump,
    required this.auctionExpiredAt,
  });

  @override
  State<AuctionInsightsWidget> createState() => _AuctionInsightsWidgetState();
}

class _AuctionInsightsWidgetState extends State<AuctionInsightsWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsGeometry.only(
        left: Dimensions.paddingSizeDefault,
        right: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeDefault,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
        ),
        padding: EdgeInsets.all(Dimensions.paddingSizeTwelve),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: Row(
                children: [
                  CustomAssetImageWidget(Images.auctionInsightIcon, height: Dimensions.paddingSizeLarge),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
        
                  Text(getTranslated('auction_insights', context) ?? "",
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
        
                  const Spacer(),
        
                  GestureDetector(
                    onTap: () => setState(() => _isExpanded = !_isExpanded),
                    child: AnimatedRotation(
                      turns: _isExpanded ? 0 : 0.5,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_up_rounded, size: Dimensions.iconSizeDefault, color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),
        
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded ? Container(
                child: Wrap(
                  spacing: Dimensions.paddingSizeLarge,
                  runSpacing: Dimensions.paddingSizeDefault,
                  children: [
                    InsightStat(
                      label: getTranslated('total_bids', context) ?? "",
                      value: '${widget.totalBids}',
                    ),
        
                    InsightStat(
                      label: getTranslated('avg_bid_increase', context) ?? "",
                      value: PriceConverter.convertPrice(context, widget.avgBidIncrease),
                    ),
        
                    InsightStat(
                      label: getTranslated('highest_jump', context) ?? "",
                      value: '+${PriceConverter.convertPrice(context, widget.highestJump)}',
                    ),

                    Container(
                      padding: EdgeInsets.all(Dimensions.paddingSizeEight),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
                      ),
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: getTranslated('auction_expired_at', context) ?? "",
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                            WidgetSpan(child: SizedBox(width: Dimensions.paddingSizeExtraSmall)),

                            TextSpan(
                              text: DateConverter.localDateToIsoStringAMPMOrder(widget.auctionExpiredAt),
                              style: titilliumBold.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  ],
                )
              ) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class InsightStat extends StatelessWidget {
  final String label;
  final String value;

  const InsightStat({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.paddingSizeEight),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall)
      ),
      child: RichText(
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            TextSpan(
              text: value,
              style: titilliumBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}