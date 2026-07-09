import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionStatInfoWidget extends StatefulWidget {
  final AuctionProductDetails product;

  const AuctionStatInfoWidget({
    super.key,
    required this.product,
  });

  @override
  State<AuctionStatInfoWidget> createState() => _AuctionStatInfoWidgetState();
}

class _AuctionStatInfoWidgetState extends State<AuctionStatInfoWidget> {
  final JustTheController _startingPriceTooltipController = JustTheController();
  final JustTheController _highestBidTooltipController = JustTheController();
  final JustTheController _myBidTooltipController = JustTheController();

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWon = product.myAuctionStatus?.isWon == true;
    final isLost = product.myAuctionStatus?.isLost == true;
    final isLive = product.auctionStatus?.isLive == true;
    final isUpcoming = product.auctionStatus?.isUpcoming == true;

    if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeTwelve, horizontal: Dimensions.homePagePadding),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LabelText(getTranslated('starting_price', context) ?? 'Starting Price', context),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                JustTheTooltip(
                  backgroundColor: Colors.black87,
                  controller: _startingPriceTooltipController,
                  preferredDirection: AxisDirection.down,
                  tailLength: 10,
                  tailBaseWidth: 20,
                  content: Container(
                    width: 150,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: Text(
                      getTranslated('starting_price_tooltip', context) ?? 'This is auction start price.',
                      style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _startingPriceTooltipController.showTooltip(),
                    child: _InfoIcon(context),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Flexible(child: _BoldValueText(PriceConverter.convertPrice(context, product.startingPrice ?? 0.0), fontSize: Dimensions.fontSizeSmall, context)),
              ],
            ),


            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                _CountText('${product.totalViews ?? 0}', context),
              ],
            ),

          ],
        ),
      );
    }

    final String? rightCardLabel;
    final double? rightCardValue;

    if (isUpcoming) {
      rightCardLabel = null;
      rightCardValue = null;
    } else if (isWon) {
      rightCardLabel = getTranslated('final_bid_price', context) ?? 'Final Bid Price';
      rightCardValue = product.currentHighestBidAmount ?? product.highestBidAmount ?? 0.0;
    } else {
      rightCardLabel = getTranslated('highest_bid', context) ?? 'Highest Bid';
      rightCardValue = product.highestBidAmount ?? 0.0;
    }

    final String myBidLabel = isWon ? (getTranslated('my_latest_bid', context) ?? 'My Latest Bid') : (getTranslated('my_bid', context) ?? 'My Bid');
    final double? myBidAmount = product.myBid?.bidAmount;
    final bool showMyBidRow = (isLive && myBidAmount != null) || isWon || isLost;
    final bool showParticipateCount = !isUpcoming || product.totalParticipantsCount != null;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatRow(
                    children: [
                      _LabelText(getTranslated('starting_price', context) ?? 'Starting Price', context),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      JustTheTooltip(
                        backgroundColor: Colors.black87,
                        controller: _startingPriceTooltipController,
                        preferredDirection: AxisDirection.down,
                        tailLength: 10,
                        tailBaseWidth: 20,
                        content: Container(
                          width: 150,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Text(
                            getTranslated('starting_price_tooltip', context) ?? 'This is auction start price.',
                            style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                          ),
                        ),
                        child: InkWell(
                          onTap: () => _startingPriceTooltipController.showTooltip(),
                          child: _InfoIcon(context),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Flexible(child: _BoldValueText( PriceConverter.convertPrice(context, product.startingPrice ?? 0.0), fontSize: Dimensions.fontSizeSmall, context)),
                    ],
                  ),

                  if (showMyBidRow) ...[
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    _StatRow(
                      children: [
                        _LabelText(myBidLabel, context),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: _myBidTooltipController,
                          preferredDirection: AxisDirection.down,
                          tailLength: 10,
                          tailBaseWidth: 20,
                          content: Container(
                            width: 150,
                            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                            child: Text(
                              getTranslated('my_bid_tooltip', context) ?? 'This is your latest bid placed in this auction.',
                              style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                            ),
                          ),
                          child: InkWell(
                            onTap: () => _myBidTooltipController.showTooltip(),
                            child: _InfoIcon(context),
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        Flexible(child: _BoldValueText(PriceConverter.convertPrice(context, myBidAmount ?? 0.0), context)),
                      ],
                    ),
                  ],
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                  _StatRow(
                    children: [
                      Icon(Icons.remove_red_eye, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      _CountText('${product.totalViews ?? 0}', context),
                      const SizedBox(width: Dimensions.paddingSizeDefault),

                      CustomAssetImageWidget(
                        Images.gavelGreyIcon,
                        height: Dimensions.iconSizeSmall,
                      ),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                      if (isUpcoming && showParticipateCount)
                        _CountText('${product.totalParticipantsCount}', context)
                      else if (!isUpcoming)
                        _CountText('${product.totalBidsCount ?? 0}', context),
                    ],
                  ),
                ],
              ),
            ),

            if (rightCardLabel != null && rightCardValue != null) ...[
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeEight,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(horizontal: Dimensions.paddingSizeExtraLarge),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _LabelText(rightCardLabel, context),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                          if (!isWon)
                            JustTheTooltip(
                              backgroundColor: Colors.black87,
                              controller: _highestBidTooltipController,
                              preferredDirection: AxisDirection.down,
                              tailLength: 10,
                              tailBaseWidth: 20,
                              content: Container(
                                width: 150,
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Text(
                                  getTranslated('highest_bid_tooltip', context) ?? 'This is the current top bid placed in this auction.',
                                  style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _highestBidTooltipController.showTooltip(),
                                child: _InfoIcon(context),
                              ),
                            )
                          else
                            _InfoIcon(context),
                        ],
                      ),
                    ),
                    Text(
                      PriceConverter.convertPrice(context, rightCardValue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final List<Widget> children;
  const _StatRow({required this.children});

  @override
  Widget build(BuildContext context) => Row(children: children);
}

class _LabelText extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _LabelText(this.text, this.ctx);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: titilliumRegular.copyWith(
      color: Theme.of(ctx).textTheme.bodySmall?.color,
      fontSize: Dimensions.fontSizeSmall,
    ),
  );
}

class _BoldValueText extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  final double? fontSize;

  const _BoldValueText(
      this.text,
      this.ctx, {
        this.fontSize,
      });

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: titilliumBold.copyWith(
      fontSize: fontSize ?? Dimensions.fontSizeDefault,
      color: Theme.of(ctx).textTheme.titleMedium?.color,
    ),
  );
}

class _CountText extends StatelessWidget {
  final String text;
  final BuildContext ctx;
  const _CountText(this.text, this.ctx);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: textMedium.copyWith(
      fontSize: Dimensions.fontSizeDefault,
      fontWeight: FontWeight.bold,
      color: Theme.of(ctx).textTheme.bodyLarge?.color,
    ),
  );
}

class _InfoIcon extends StatelessWidget {
  final BuildContext ctx;
  const _InfoIcon(this.ctx);

  @override
  Widget build(BuildContext context) => Icon(
    Icons.info,
    size: Dimensions.iconSizeExtraSmall,
    color: Theme.of(ctx).hintColor,
  );
}