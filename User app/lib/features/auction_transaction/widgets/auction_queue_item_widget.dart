import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionQueueItemWidget extends StatelessWidget {
  final String auctionId;
  final String productName;
  final String thumbnailFullUrl;
  final double? startingPrice;
  final String? categoryName;
  final UserCreatedAuctionEnum auctionState;
  final VoidCallback? onMoreTap;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onRelaunch;

  const AuctionQueueItemWidget({
    super.key,
    required this.auctionId,
    required this.productName,
    required this.thumbnailFullUrl,
    this.startingPrice,
    this.categoryName,
    this.auctionState = UserCreatedAuctionEnum.pending,
    this.onMoreTap,
    this.onTap,
    this.onCancel,
    this.onRelaunch,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
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
        child: Slidable(
          key: ValueKey(auctionId),
          endActionPane: _buildActionPane(context),
          child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
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
                      image: thumbnailFullUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${getTranslated('auction_id', context) ?? ''} #$auctionId',
                          style: titilliumRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 25,
                        height: 15,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Provider.of<ThemeController>(context, listen: false).darkTheme
                              ? Theme.of(context).cardColor
                              : null,
                          onSelected: (value) {
                            if (value == 'view') {
                              onTap?.call();
                            } else if (value == 'edit') {
                              onMoreTap?.call();
                            } else if (value == 'relaunch') {
                              onRelaunch?.call();
                            } else if (value == 'cancel') {
                              onCancel?.call();
                            }
                          },
                          itemBuilder: (BuildContext context) => _buildMenuItems(context),
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: Dimensions.iconSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textBold.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),

                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    ],
                  ),


                  DetailRow(
                    label: getTranslated('start_price', context) ?? 'Start Price',
                    value: PriceConverter.convertPrice(context, startingPrice ?? 0),
                    valueStyle: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),

                  DetailRow(
                    label: getTranslated('category', context) ?? 'Category',
                    value: categoryName ?? '',
                    valueStyle: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
            ),
          ),
        ),
      ),
    );
  }

  ActionPane? _buildActionPane(BuildContext context) {
    if (auctionState == UserCreatedAuctionEnum.pending ||
        auctionState == UserCreatedAuctionEnum.upcoming) {
      return ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  icon: Icons.delete_rounded,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    Slidable.of(context)?.close();
                    onCancel?.call();
                  },
                ),
                const SizedBox(height: 8),

                Container(width: 36, height: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                const SizedBox(height: 8),

                ActionButton(
                  icon: Icons.edit,
                  color: Theme.of(context).primaryColor,
                  onTap: () {
                    Slidable.of(context)?.close();
                    onMoreTap?.call();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (auctionState == UserCreatedAuctionEnum.rejected) {
      return ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          CustomSlidableAction(
            onPressed: (_) {},
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ActionButton(
                  icon: Icons.cancel_outlined,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    Slidable.of(context)?.close();
                    onCancel?.call();
                  },
                ),
                const SizedBox(height: 8),

                Container(width: 36, height: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                const SizedBox(height: 8),

                ActionButton(
                  icon: Icons.refresh,
                  color: Theme.of(context).primaryColor,
                  onTap: () {
                    Slidable.of(context)?.close();
                    onRelaunch?.call();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    return null;
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final viewItem = PopupMenuItem<String>(
      value: 'view',
      height: 35,
      child: PopupMenuIconItem(
        label: getTranslated('view_details', context) ?? 'View Details',
        icon: Icons.remove_red_eye,
      ),
    );

    if (auctionState == UserCreatedAuctionEnum.rejected) {
      return [
        viewItem,
        PopupMenuItem<String>(
          value: 'relaunch',
          height: 35,
          child: PopupMenuIconItem(
            label: getTranslated('relaunch', context) ?? 'Relaunch',
            icon: Icons.refresh,
          ),
        ),
        PopupMenuItem<String>(
          value: 'cancel',
          height: 35,
          child: PopupMenuIconItem(
            label: getTranslated('cancel_auction', context) ?? 'Cancel',
            icon: Icons.cancel_outlined,
            iconColor: Colors.red,
          ),
        ),
      ];
    }

    if (auctionState == UserCreatedAuctionEnum.pending ||
        auctionState == UserCreatedAuctionEnum.upcoming) {
      return [
        viewItem,
        PopupMenuItem<String>(
          value: 'edit',
          height: 35,
          child: PopupMenuIconItem(
            label: getTranslated('edit_details', context) ?? 'Edit Details',
            icon: Icons.edit,
          ),
        ),

        PopupMenuItem<String>(
          value: 'cancel',
          height: 35,
          child: PopupMenuIconItem(
            label: getTranslated('delete_auction', context) ?? 'Delete Auction',
            icon: Icons.delete_rounded,
            iconColor: Colors.red,
          ),
        ),
      ];
    }

    return [viewItem];
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
        Text(
          '$label  ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        Expanded(
          child: Text(
            value,
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
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
          child: Icon(icon, size: Dimensions.iconSizeExtraSmall, color: Colors.white),
        ),
      ],
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ActionButton({super.key, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}