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

class AuctionCardWidget extends StatefulWidget {
  final String slug;
  final AuctionCardState state;
  final String imageUrl;
  final String productName;
  final double price;
  final DateTime targetTime;
  final int viewCount;
  final int? bidCount;

  const AuctionCardWidget({
    super.key,
    required this.slug,
    required this.state,
    required this.imageUrl,
    required this.productName,
    required this.price,
    required this.targetTime,
    required this.viewCount,
    this.bidCount,
  });

  @override
  State<AuctionCardWidget> createState() => _AuctionCardWidgetState();
}

class _AuctionCardWidgetState extends State<AuctionCardWidget> {
  late Timer _timer;
  late Duration _remaining;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () => RouterHelper.getParticipationAuctionDetailsRoute(slug: widget.slug,
              auctionStatus: widget.state == AuctionCardState.live
              ? AuctionParticipationStatus.live
              : AuctionParticipationStatus.upcoming),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).cardColor.withValues(alpha: 0.01),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSmall)),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CustomImageWidget(
                          image: widget.imageUrl,
                          height: constraints.maxWidth
                        ),
                      )
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraExtraSmall,
                          ),
                          child: Row(
                            children: [
                              Text(
                                isLive ? getTranslated('closes_in', context) ?? '' : getTranslated('starts_in', context) ?? '',
                                style: titilliumRegular.copyWith(
                                  fontSize: Dimensions.fontSizeExtraSmall,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
          
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
                        ),
                      ),
                    ),
                  ],
                ),
          
                const SizedBox(height: Dimensions.paddingSizeSmall),
          
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          
                    Row(
                      children: [
                        Text(
                          isLive ? getTranslated('highest_bid', context) ?? ''
                            : getTranslated('starting_price', context) ?? '',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
          
                        Flexible(
                          child: Text(
                            PriceConverter.convertPrice(context, widget.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          size: Dimensions.iconSizeExtraSmall + 2,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                        Text(
                          '${widget.viewCount}',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            fontWeight: FontWeight.bold,
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
                          Text(
                            '${widget.bidCount}',
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}