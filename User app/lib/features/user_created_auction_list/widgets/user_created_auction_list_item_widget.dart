// STUB: auction feature not fully implemented — minimal shape to satisfy compile-time references only.
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/enum/user_created_auction_purchase_enum.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class UserCreatedAuctionListItemWidget extends StatelessWidget {
  final UserCreatedAuctionPurchaseEnum auctionStatus;
  final String imageUrl;
  final String slug;
  final int auctionId;
  final String productName;
  final double startingPrice;
  final int participantCount;
  final int totalBidCount;
  final double highestBidAmount;
  final DateTime targetTime;
  final int viewCount;
  final double adminCommission;
  final bool isAdminCommissionPaid;
  final String? claimPaymentStatus;
  final VoidCallback? onRelaunch;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const UserCreatedAuctionListItemWidget({
    super.key,
    required this.auctionStatus,
    required this.imageUrl,
    required this.slug,
    required this.auctionId,
    required this.productName,
    required this.startingPrice,
    required this.participantCount,
    required this.totalBidCount,
    required this.highestBidAmount,
    required this.targetTime,
    required this.viewCount,
    required this.adminCommission,
    required this.isAdminCommissionPaid,
    this.claimPaymentStatus,
    this.onRelaunch,
    this.onEdit,
    this.onCancel,
    this.onDelete,
  });

  bool get _canEdit => auctionStatus == UserCreatedAuctionPurchaseEnum.upcoming;

  bool get _canCancel => auctionStatus == UserCreatedAuctionPurchaseEnum.upcoming || auctionStatus == UserCreatedAuctionPurchaseEnum.live;

  bool get _canRelaunch => auctionStatus == UserCreatedAuctionPurchaseEnum.unsold || auctionStatus == UserCreatedAuctionPurchaseEnum.canceled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.15)),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImageWidget(
                  image: imageUrl,
                  placeholder: Images.placeholder,
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      PriceConverter.convertPrice(context, startingPrice),
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                    Text(
                      DateConverter.dateStringMonthYear(targetTime),
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (onEdit != null || onCancel != null || onDelete != null || onRelaunch != null)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Theme.of(context).hintColor),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'cancel':
                        onCancel?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                      case 'relaunch':
                        onRelaunch?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (_canEdit) PopupMenuItem(value: 'edit', child: Text(getTranslated('edit', context) ?? 'Edit')),
                    if (_canCancel) PopupMenuItem(value: 'cancel', child: Text(getTranslated('cancel', context) ?? 'Cancel')),
                    if (_canRelaunch) PopupMenuItem(value: 'relaunch', child: Text(getTranslated('relaunch', context) ?? 'Relaunch')),
                    PopupMenuItem(value: 'delete', child: Text(getTranslated('delete', context) ?? 'Delete')),
                  ],
                ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            children: [
              Icon(Icons.remove_red_eye, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Text('$viewCount', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Icon(Icons.groups_outlined, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Text('$participantCount', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              Icon(Icons.gavel, size: Dimensions.iconSizeSmall, color: Theme.of(context).hintColor),
              const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
              Text('$totalBidCount', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
              const Spacer(),
              if (highestBidAmount > 0)
                Text(
                  PriceConverter.convertPrice(context, highestBidAmount),
                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
            ],
          ),
          if (adminCommission > 0) ...[
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(
              '${getTranslated('admin_commission', context) ?? 'Admin Commission'}: ${PriceConverter.convertPrice(context, adminCommission)} '
              '(${isAdminCommissionPaid ? getTranslated('paid', context) ?? 'Paid' : getTranslated('unpaid', context) ?? 'Unpaid'})',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor),
            ),
          ],
        ],
      ),
    );
  }
}
