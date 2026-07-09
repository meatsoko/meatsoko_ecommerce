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

class AuctionListItemWidget extends StatefulWidget {
  final AuctionCardState state;
  final String imageUrl;
  final String slug;
  final String productName;
  final double startingPrice;
  final double highestBidAmount;
  final DateTime targetTime;
  final int viewCount;
  final int? bidCount;
  final String? trackingUrl;
  final VoidCallback? onBidTap;
  final VoidCallback? onWithdrawBidTap;
  final VoidCallback? onClaimTap;
  final VoidCallback? onTrackOrderTap;
  final AuctionParticipationStatus? auctionStatus;
  final AuctionCurrentStatus? currentAuctionStatus;
  final bool? isOutbid;
  final bool? hasBid;
  final int auctionId;

  const AuctionListItemWidget({
    super.key,
    required this.state,
    required this.imageUrl,
    required this.slug,
    required this.auctionId,
    required this.productName,
    required this.startingPrice,
    required this.highestBidAmount,
    required this.targetTime,
    required this.viewCount,
    this.bidCount,
    this.trackingUrl,
    this.onBidTap,
    this.onWithdrawBidTap,
    this.onClaimTap,
    this.onTrackOrderTap,
    this.auctionStatus,
    this.currentAuctionStatus,
    this.isOutbid,
    this.hasBid,
  });

  @override
  State<AuctionListItemWidget> createState() => _AuctionListItemWidgetState();
}

class _AuctionListItemWidgetState extends State<AuctionListItemWidget> {
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
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
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
                  width: 100,
                  height: 100,
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
                        children: [
                          Expanded(
                            child: Text(
                              '${getTranslated('auction_id', context) ?? 'Auction id'} #${widget.auctionId}',
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
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
                                } else if (value == 'raise_bid') {
                                  widget.onBidTap?.call();
                                } else if (value == 'withdraw_bid') {
                                  widget.onWithdrawBidTap?.call();
                                }else if (value == 'claim') {
                                  widget.onClaimTap?.call();
                                }else if (value == 'track_order') {
                                  widget.onTrackOrderTap?.call();
                                }
                              },
                              itemBuilder: (context) {
                                final status = widget.auctionStatus;
                                final hideActions = status == null ||
                                    status.isParticipated ||
                                    status.isLost ||
                                    status.isClaimExpiredLost;

                                return [
                                  PopupMenuItem(
                                    value: 'details',
                                    height: 35,
                                    child: PopupMenuIconItem(
                                      label: getTranslated('view_details', context) ?? 'View Details',
                                      icon: Icons.remove_red_eye,
                                    ),
                                  ),

                                  if (!hideActions && status.isUpcoming)
                                    PopupMenuItem<String>(
                                      enabled: false,
                                      height: 35,
                                      child: PopupMenuIconItem(
                                        label: getTranslated('bid', context) ?? 'Bid',
                                        icon: Icons.gavel,
                                        iconColor: Theme.of(context).hintColor,
                                      ),
                                    ),

                                  if (!hideActions && status.isLive) ...[
                                    if (widget.onBidTap != null)
                                      PopupMenuItem(
                                        value: 'raise_bid',
                                        height: 35,
                                        child: PopupMenuIconItem(
                                          label: getTranslated('raise_bid', context) ?? 'Raise Bid',
                                          icon: Icons.gavel,
                                        ),
                                      ),
                                    if (widget.onWithdrawBidTap != null)
                                      PopupMenuItem(
                                        value: 'withdraw_bid',
                                        height: 35,
                                        child: PopupMenuIconItem(
                                          label: getTranslated('withdraw_bid', context) ?? 'Withdraw Bid',
                                          icon: Icons.file_upload_outlined,
                                        ),
                                      ),
                                  ],

                                  if (!hideActions && status.isWon && widget.onClaimTap != null)
                                    PopupMenuItem(
                                      value: 'claim',
                                      height: 35,
                                      child: PopupMenuIconItem(
                                        label: getTranslated('claim', context) ?? 'Claim',
                                        icon: Icons.check_circle_outline,
                                      ),
                                    ),

                                  if (!hideActions && status.isClaimed && !status.isClaimExpiredLost && widget.onTrackOrderTap != null && widget.trackingUrl != null)
                                    PopupMenuItem(
                                      value: 'track_order',
                                      height: 35,
                                      child: PopupMenuIconItem(
                                        label: getTranslated('track_order', context) ?? 'Track Order',
                                        icon: Icons.local_shipping_outlined,
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
                      Text(
                        widget.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textBold.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                      DetailRow(
                        label: getTranslated('start_price', context) ?? 'Start Price',
                        value: PriceConverter.convertPrice(context, widget.startingPrice),
                        valueStyle: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),

                      ((isLive || widget.auctionStatus?.isWon == true) && widget.highestBidAmount != 0)
                          ? DetailRow(
                        label: widget.auctionStatus?.isWon == true
                            ? (getTranslated('final_bid_price', context) ?? 'Final Bid Price')
                            : (getTranslated('highest_bid', context) ?? 'Highest Bid'),
                        value: PriceConverter.convertPrice(context, widget.highestBidAmount),
                        valueStyle: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ) : DetailRow(label: '', value: ''),

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
                          const Spacer(),

                          AuctionActionButton(
                            auctionStatus: widget.auctionStatus,
                            currentAuctionStatus: widget.currentAuctionStatus,
                            tooltipController: tooltipController,
                            isOutbid: widget.isOutbid,
                            hasBid: widget.hasBid,
                            onBidTap: widget.onBidTap,
                            onClaimTap: widget.onClaimTap,
                            onTrackOrderTap: widget.onTrackOrderTap,
                            trackingUrl: widget.trackingUrl,
                          ),
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

class AuctionActionButton extends StatelessWidget {
  final AuctionParticipationStatus? auctionStatus;
  final AuctionCurrentStatus? currentAuctionStatus;
  final bool? isOutbid;
  final bool? hasBid;
  final VoidCallback? onBidTap;
  final VoidCallback? onClaimTap;
  final VoidCallback? onTrackOrderTap;
  final JustTheController tooltipController;
  final String? trackingUrl;

  const AuctionActionButton({
    super.key,
    required this.auctionStatus,
    required this.tooltipController,
    this.currentAuctionStatus,
    this.isOutbid = false,
    this.hasBid,
    this.onBidTap,
    this.onClaimTap,
    this.onTrackOrderTap,
    this.trackingUrl,
  });

  @override
  Widget build(BuildContext context) {
    final status = auctionStatus;

    if (currentAuctionStatus?.isUpcoming == true) {
      return Opacity(
        opacity: 0.5,
        child: JustTheTooltip(
        controller: tooltipController,
        tailLength: 10,
        tailBaseWidth: 20,
        preferredDirection: AxisDirection.down,
        backgroundColor: Colors.black87,
        content: Container(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Text(getTranslated('auction_not_live_tooltip', context) ?? "",
            style: textRegular.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () => tooltipController.showTooltip(),
          child: _AuctionButtonContainer(
            context: context,
            icon: CustomAssetImageWidget(Images.gavelOutlinedIcon),
            label: getTranslated('bid', context) ?? "",
          ),
        ),
      ),
      );
    }

    if (status == null || status.isParticipated || status.isLost || status.isClaimExpiredLost) {
      return const SizedBox.shrink();
    }

    if (status.isLive) {
      return GestureDetector(
        onTap: () => onBidTap?.call(),
        child: _AuctionButtonContainer(
          context: context,
          icon: CustomAssetImageWidget(Images.gavelOutlinedIcon),
          label: (hasBid ?? false) ? getTranslated('raise_bid', context) ?? "" : getTranslated('bid', context) ?? "",
        ),
      );
    }

    if (status.isWon && onClaimTap != null) {
      return GestureDetector(
        onTap: () => onClaimTap?.call(),
        child: _AuctionButtonContainer(
          context: context,
          label: getTranslated('claim', context) ?? "Claim",
        ),
      );
    }

    if (status.isClaimed) {
      if (trackingUrl == null) {
        return Opacity(
          opacity: 0.5,
          child: JustTheTooltip(
            controller: tooltipController,
            tailLength: 10,
            tailBaseWidth: 20,
            preferredDirection: AxisDirection.down,
            backgroundColor: Colors.black87,
            content: Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Text(
                getTranslated('tracking_url_not_provided_yet', context) ?? "",
                style: textRegular.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
            ),
            child: GestureDetector(
              onTap: () => tooltipController.showTooltip(),
              child: _AuctionButtonContainer(
                context: context,
                label: getTranslated('track_order', context) ?? "Track Order",
              ),
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: () => onTrackOrderTap?.call(),
        child: _AuctionButtonContainer(
          context: context,
          label: getTranslated('track_order', context) ?? "Track Order",
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _AuctionButtonContainer extends StatelessWidget {
  final BuildContext context;
  final Widget? icon;
  final String label;

  const _AuctionButtonContainer({required this.context, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeEight,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusHundred),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon ?? const SizedBox.shrink(),
          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
          Text(
            label,
            style: titilliumSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Colors.white
            ),
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