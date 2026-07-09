import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/participation_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/bidding_list_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/responsive_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class ParticipantBidListItem {
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


  const ParticipantBidListItem({
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

const int _kMaxNaturalBids = 4;
const double _kVisibleBidExtent = 4.5;

class ParticipantBiddingListWidget extends StatefulWidget {
  final bool myBidsOnly;
  final int productId;

  const ParticipantBiddingListWidget({
    super.key,
    required this.productId,
    this.myBidsOnly = false,
  });

  @override
  State<ParticipantBiddingListWidget> createState() => _ParticipantBiddingListWidgetState();
}

class _ParticipantBiddingListWidgetState extends State<ParticipantBiddingListWidget> {
  late bool myBidsOnly;

  @override
  void initState() {
    super.initState();
    myBidsOnly = widget.myBidsOnly;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipationAuctionDetailsController>(
      builder: (context, detailsController, _) {
        print('myBidsOnly: ${detailsController.allBids}');
        final bids = detailsController.allBids;
        final hasMore = detailsController.hasMoreBids;
        final isCollapsed = detailsController.isCollapsed;
        final isPaginating = detailsController.isBidPaginating;
        final isLoading = detailsController.isBidListLoading;
        final profileController = Provider.of<ProfileController>(context, listen: false);
        final ownerId = detailsController.auctionDetails?.product?.ownerId;
        final bool isOwner = profileController.userInfoModel?.id != null &&
            profileController.userInfoModel!.id == ownerId;

        final double bidItemHeight = ResponsiveHelper.isTab(context) ? 84 : 64;

        final bool showMyBidsFilter = !isLoading && (bids.isNotEmpty || myBidsOnly);

        return Container(
          color: Theme.of(context).cardColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.homePagePadding,
            vertical: Dimensions.paddingSizeTwelve,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated('live_bidding_activity', context) ?? "",
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  if (!isOwner && showMyBidsFilter)
                    Row(
                      children: [
                        Checkbox(
                          value: myBidsOnly,
                          onChanged: (bool? value) {
                            final checked = value ?? false;
                            setState(() => myBidsOnly = checked);
                            detailsController.getAuctionBidList(
                              productId: widget.productId,
                              isMyBid: checked,
                            );
                          },
                          side: BorderSide(color: Theme.of(context).hintColor),
                        ),
                        Text(
                          getTranslated('my_bids_only', context) ?? "",
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.titleMedium?.color,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeTwelve),

              if (isLoading)
                BiddingListShimmerWidget(itemHeight: bidItemHeight)
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
                SizedBox(
                  height: bids.length > _kMaxNaturalBids
                      ? bidItemHeight * _kVisibleBidExtent
                      : null,
                  child: ListView.builder(
                    shrinkWrap: bids.length <= _kMaxNaturalBids,
                    physics: bids.length > _kMaxNaturalBids
                        ? const ClampingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    itemExtent: bidItemHeight,
                    itemCount: bids.length,
                    itemBuilder: (_, index) {
                    final bid = bids[index];
                    final userContext = bid.userContext;
                    return BidRow(
                      item: ParticipantBidListItem(
                        rank: index + 1,
                        name: '${bid.customer?.fName ?? ''} ${bid.customer?.lName ?? ''}',
                        timeAgo: bid.bidTime ?? '',
                        bidAmount: PriceConverter.convertPrice(context, double.parse(bid.bidAmount?.toString() ?? '0')),
                        avatarUrl: bid.customer?.imageFullUrl?.path ?? '',
                        isLeading: bid.isLeadBid ?? false,
                        isWithdrawBid: bid.isWithdrawBid ?? false,
                        isCurrentUser: bid.isMyBid ?? false,
                        isWinner: (userContext?.isWinner ?? false) && !(userContext?.isClaimExpired ?? false) && (bid.isLeadBid ?? false),
                        isClaimExpired: (userContext?.isWinner == false) && (userContext?.isClaimExpired ?? false),
                      ),
                    );
                    },
                  ),
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
                      isMyBid: myBidsOnly,
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
  final ParticipantBidListItem item;

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
                    color: Theme.of(context).cardColor,
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
                              ? Theme.of(context).textTheme.bodyLarge!.color
                              : item.isClaimExpired
                                  ? Theme.of(context).colorScheme.error
                                  : Theme.of(context).colorScheme.onTertiaryContainer,
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