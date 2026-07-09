import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/creator/creator_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/bidding_list_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class CreatorBidListItem {
  final int rank;
  final String name;
  final String timeAgo;
  final String bidAmount;
  final String? avatarUrl;
  final bool isLeading;
  final bool isWinner;
  final bool isClaimExpired;
  final bool isWithdrawBid;
  final bool isCurrentUser;
  final bool isBidUp;


  const CreatorBidListItem({
    required this.rank,
    required this.name,
    required this.timeAgo,
    required this.bidAmount,
    this.avatarUrl,
    this.isLeading = false,
    this.isWinner = false,
    this.isClaimExpired = false,
    this.isWithdrawBid = false,
    this.isCurrentUser = false,
    this.isBidUp = true,
  });
}

class CreatorBiddingListWidget extends StatefulWidget {
  final List<CreatorBidListItem> bids;
  final int productId;

  const CreatorBiddingListWidget({
    super.key,
    required this.bids,
    required this.productId,
  });

  @override
  State<CreatorBiddingListWidget> createState() => _CreatorBiddingListWidgetState();
}

class _CreatorBiddingListWidgetState extends State<CreatorBiddingListWidget> {
  late bool myBidsOnly;


  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorAuctionDetailsController>(
      builder: (context, detailsController, _) {
        final bids = detailsController.allBids;
        final hasMore = detailsController.hasMoreBids;
        final isCollapsed = detailsController.isCollapsed;
        final isPaginating = detailsController.isBidPaginating;
        final isLoading = detailsController.isBidListLoading;

        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeTwelve,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated('live_bidding_activity', context) ?? "",
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeTwelve),

              if (isLoading)
                const BiddingListShimmerWidget()
              else if (bids.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                    child: Text(
                      getTranslated('no_bids_yet', context) ?? 'No bids yet',
                      style: titilliumRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bids.length,
                  separatorBuilder: (_, __) => const SizedBox.shrink(),
                  itemBuilder: (_, index) => BidRow(item: widget.bids[index]),
                ),

              if (!isLoading && bids.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                if (isPaginating)
                  const Center(child: CircularProgressIndicator())
                else if (hasMore)
                  _SeeMoreLessButton(
                    label: getTranslated('see_more', context) ?? 'See More',
                    icon: Icons.keyboard_arrow_down_rounded,
                    onTap: () => detailsController.loadMoreBids(
                      productId: widget.productId,
                    ),
                  )
                else if (!isCollapsed)
                    _SeeMoreLessButton(
                      label: getTranslated('see_less', context) ?? 'See Less',
                      icon: Icons.keyboard_arrow_up_rounded,
                      onTap: () => detailsController.collapseBids(),
                    ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _SeeMoreLessButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SeeMoreLessButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
              style: titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),

            Icon(icon, size: Dimensions.iconSizeSmall, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}

class BidRow extends StatelessWidget {
  final CreatorBidListItem item;

  const BidRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: Dimensions.paddingSizeSmall,
        horizontal: Dimensions.paddingSizeExtraSmall,
      ),
      decoration: BoxDecoration(
        color: (item.isWinner || item.isClaimExpired)
            ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.10) : item.isLeading
            ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.10)
            : Theme.of(context).cardColor,
        borderRadius: (item.isLeading || item.isWinner || item.isClaimExpired) ? BorderRadius.circular(Dimensions.radiusDefault) : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: Dimensions.paddingSizeDefault + Dimensions.paddingSizeSmall,
            child: Text('${item.rank}.',
              style: titilliumBold.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),

          ClipOval(child: CustomImageWidget(image: item.avatarUrl ?? "", placeholder: Images.user, height: Dimensions.iconSizeLarge, width: Dimensions.iconSizeLarge)),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: Dimensions.paddingSizeExtraSmall,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: item.name,
                            style: titilliumSemiBold.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (item.isCurrentUser)
                            TextSpan(
                              text: ' (${getTranslated('you', context) ?? ""})',
                              style: titilliumSemiBold.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (item.isWithdrawBid)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeExtraSmall,
                          vertical: Dimensions.paddingSizeExtraExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Text(
                          getTranslated('withdraw', context) ?? 'Withdraw',
                          style: titilliumSemiBold.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeExtraSmall,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                Text(DateConverter.compareDates(item.timeAgo),
                  style: titilliumRegular.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(item.bidAmount,
                    style: titilliumSemiBold.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                  Icon(
                    item.isBidUp ? Icons.arrow_upward : Icons.arrow_downward,
                    color: item.isBidUp ? Colors.green : Colors.red,
                    size: Dimensions.iconSizeSmall,
                  ),
                ],
              ),
              if (item.isLeading || item.isWinner || item.isClaimExpired) ...[
                const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall,
                    vertical: Dimensions.paddingSizeExtraExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeController>(context, listen: false).darkTheme
                        ? ((item.isWinner || item.isClaimExpired)
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.onTertiaryContainer)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      item.isWinner
                          ? CustomAssetImageWidget(Images.winner, height: Dimensions.iconSizeExtraSmall)
                          : item.isClaimExpired
                              ? Icon(Icons.timer_outlined, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.error)
                              : CustomAssetImageWidget(Images.leadingBid, height: Dimensions.iconSizeExtraSmall),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Text(
                        item.isWinner
                            ? getTranslated('winner', context) ?? ""
                            : item.isClaimExpired
                                ? getTranslated('claim_expired', context) ?? ""
                                : getTranslated('leading_bid', context) ?? "",
                        style: titilliumSemiBold.copyWith(
                          color: item.isWinner
                              ? (Provider.of<ThemeController>(context, listen: false).darkTheme
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSecondary)
                              : item.isClaimExpired
                                  ? Theme.of(context).colorScheme.error
                                  : (Provider.of<ThemeController>(context, listen: false).darkTheme
                                      ? Colors.black87
                                      : Theme.of(context).colorScheme.onTertiaryContainer),
                          fontSize: Dimensions.fontSizeExtraSmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}