import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/status_badge_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/helper/color_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class AuctionSaveCardWidget extends StatefulWidget {
  final AuctionCardState state;
  final String imageUrl;
  final String slug;
  final String productName;
  final double startingPrice;
  final double highestBidAmount;
  final DateTime targetTime;
  final int viewCount;
  final int? bidCount;
  final AuctionParticipationStatus? auctionStatus;
  final AuctionCurrentStatus? currentAuctionStatus;
  final bool? isOutbid;
  final bool? hasBid;

  const AuctionSaveCardWidget({
    super.key,
    required this.state,
    required this.imageUrl,
    required this.slug,
    required this.productName,
    required this.startingPrice,
    required this.highestBidAmount,
    required this.targetTime,
    required this.viewCount,
    this.bidCount,
    this.auctionStatus,
    this.currentAuctionStatus,
    this.isOutbid,
    this.hasBid,
  });

  @override
  State<AuctionSaveCardWidget> createState() => _AuctionSaveCardWidgetState();
}

class _AuctionSaveCardWidgetState extends State<AuctionSaveCardWidget> {
  late Timer _timer;
  late Duration _remaining;
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  void _updateRemaining() {
    final diff = widget.targetTime.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.state == AuctionCardState.live;

    return GestureDetector(
      onTap: () => RouterHelper.getParticipationAuctionDetailsRoute(slug: widget.slug, auctionStatus: widget.auctionStatus),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withValues(alpha: .075),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          border: Border.all(
                            color: Theme.of(context).hintColor.withValues(alpha: .15),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                          child: CustomImageWidget(
                            image: widget.imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),

                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: (isLive || widget.state == AuctionCardState.upcoming) && _remaining > Duration.zero ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).hintColor, 0.35),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(Dimensions.radiusDefault),
                                bottomRight: Radius.circular(Dimensions.radiusDefault),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Flexible(
                                //   child: Text(
                                //     isLive ? getTranslated('closes_in', context) ?? 'Closes in' : getTranslated('starts_in', context) ?? 'Starts in',
                                //     overflow: TextOverflow.ellipsis,
                                //     style: titilliumBold.copyWith(
                                //       fontSize: Dimensions.fontSizeExtraSmall,
                                //       color: Theme.of(context).colorScheme.error,
                                //     ),
                                //   ),
                                // ),
                                Icon(
                                  Icons.timer_outlined,
                                  size: Dimensions.iconSizeExtraSmall + 2,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                                Flexible(
                                  child: Text(
                                    DateConverter.formatDuration(_remaining),
                                    overflow: TextOverflow.ellipsis,
                                    style: titilliumBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ) : const SizedBox.shrink()
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textBold.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 25,
                            height: 20,
                            child: PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              ),
                              onSelected: (value) {
                                if (value == 'details') {
                                  RouterHelper.getParticipationAuctionDetailsRoute(
                                    slug: widget.slug,
                                    auctionStatus: widget.auctionStatus,
                                  );
                                }
                              },
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 'details',
                                    height: 35,
                                    child: PopupMenuIconItem(
                                      label: getTranslated('view_details', context) ?? 'View Details',
                                      icon: Icons.remove_red_eye,
                                    ),
                                  ),
                                ];
                              },
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: Dimensions.iconSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      DetailRow(
                        label: getTranslated('start_price', context) ?? 'Start Price',
                        value: PriceConverter.convertPrice(context, widget.startingPrice),
                        valueStyle: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),

                      if ((isLive || widget.auctionStatus?.isWon == true) && widget.highestBidAmount != 0)
                        DetailRow(
                          label: widget.auctionStatus?.isWon == true
                              ? (getTranslated('final_bid_price', context) ?? 'Final Bid Price')
                              : (getTranslated('highest_bid', context) ?? 'Highest Bid'),
                          value: PriceConverter.convertPrice(context, widget.highestBidAmount),
                          valueStyle: titilliumBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),

                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                      Row(
                        children: [
                          Icon(Icons.remove_red_eye, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
                          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                          Text('${widget.viewCount}',
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),

                          if (isLive && widget.bidCount != null) ...[
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            CustomAssetImageWidget(Images.gavelGreyIcon, height: Dimensions.iconSizeSmall),
                            const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                            Text('${widget.bidCount}',
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          PositionedDirectional(
            top: 0,
            start: 0,
            child: (isLive || widget.auctionStatus?.isUpcoming == true)
                ? StatusBadgeWidget(
              text: isLive
                  ? ((widget.isOutbid ?? false)
                  ? getTranslated('outbid', context) ?? ""
                  : getTranslated('leading_bid', context) ?? "")
                  : getTranslated('upcoming', context) ?? "",
              color: isLive
                  ? ((widget.isOutbid ?? false)
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onTertiaryContainer)
                  : Theme.of(context).colorScheme.onTertiaryContainer,
            ) : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const DetailRow({super.key, required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label  ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Expanded(
          child: Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: valueStyle ??
                titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
          ),
        ),
      ],
    );
  }
}

class PopupMenuIconItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? iconColor;

  const PopupMenuIconItem({super.key, required this.label, required this.icon, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const Spacer(),
        Container(width: 20, height: 20,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
          child: Icon(icon, size: Dimensions.iconSizeExtraSmall, color: Colors.white),
        ),
      ],
    );
  }
}