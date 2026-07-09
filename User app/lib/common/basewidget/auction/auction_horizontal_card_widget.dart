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

class AuctionHorizontalCardWidget extends StatefulWidget {
  final AuctionCardState state;
  final String slug;
  final String imageUrl;
  final String productName;
  final double price;
  final DateTime targetTime;
  final int viewCount;
  final int? bidCount;
  final VoidCallback? onTap;

  const AuctionHorizontalCardWidget({
    super.key,
    required this.state,
    required this.imageUrl,
    required this.slug,
    required this.productName,
    required this.price,
    required this.targetTime,
    required this.viewCount,
    this.bidCount,
    this.onTap,
  });

  @override
  State<AuctionHorizontalCardWidget> createState() => _AuctionHorizontalCardWidgetState();
}

class _AuctionHorizontalCardWidgetState extends State<AuctionHorizontalCardWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1), (_) => _updateRemaining(),
    );
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

    return InkWell(
      onTap: () => RouterHelper.getParticipationAuctionDetailsRoute(slug: widget.slug,
          auctionStatus: widget.state == AuctionCardState.live
              ? AuctionParticipationStatus.live
              : AuctionParticipationStatus.upcoming),
      child: SizedBox(
        child: Row(
          children: [
            SizedBox(
              height: 75,
              width: 75,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImageWidget(
                      image: widget.imageUrl,
                      height: double.infinity,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.state.showBadge)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: StatusBadgeWidget(
                        text: isLive ? getTranslated('live', context) ?? '' : getTranslated('upcoming', context) ?? '',
                        color: isLive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: ColorHelper.blendColors(Theme.of(context).cardColor, Theme.of(context).hintColor, 0.35),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(Dimensions.radiusSmall),
                            bottomRight: Radius.circular(Dimensions.radiusSmall),
                          )
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.timer_outlined, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                          Flexible(
                            child: Text(DateConverter.formatDuration(_remaining),
                              overflow: TextOverflow.ellipsis,
                              style: titilliumBold.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeEight, vertical: Dimensions.paddingSizeExtraSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    Row(
                      children: [
                        Text(
                          isLive ? getTranslated('highest_bid', context) ?? '' : getTranslated('starting_price', context) ?? '',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                        Expanded(
                          child: Text(PriceConverter.convertPrice(context, widget.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye_outlined,
                          size: Dimensions.iconSizeExtraSmall + 2,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                        Text('${widget.viewCount}',
                          style: titilliumBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (isLive && widget.bidCount != null) ...[
                          const SizedBox(width: Dimensions.paddingSizeSmall),

                          CustomAssetImageWidget(
                            Images.gavelGreyIcon,
                            height: Dimensions.iconSizeExtraSmall + 2,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

                          Text('${widget.bidCount}',
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}