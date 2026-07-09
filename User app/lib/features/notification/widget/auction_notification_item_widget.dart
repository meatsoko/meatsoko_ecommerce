import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/controllers/notification_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/domain/models/notification_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/notification/widget/auction_notification_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionNotificationItemWidget extends StatelessWidget {
  final AuctionNotificationItem item;
  final int index;
  const AuctionNotificationItemWidget({super.key, required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, notificationController, _) {
        return InkWell(
          onTap: () {
            notificationController.markAuctionSeen(id: item.id);
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => AuctionNotificationDialogWidget(item: item),
            );
          },
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if (_willShowDate(index, notificationController.auctionNotificationModel?.notifications)) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Padding(
                padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                child: Text(
                  DateConverter.getRelativeDateStatus(
                    notificationController.auctionNotificationModel?.notifications?[index].createdAt ?? '',
                    context,
                  ),
                  style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                  textDirection: TextDirection.ltr,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],

            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    spreadRadius: 0,
                    blurRadius: 7,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(children: [

                Stack(children: [
                  Container(
                    width: 45,
                    height: 45,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05), width: 2),
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    ),
                    child: CustomAssetImageWidget(Images.gavelIcon, width: 45, height: 45, fit: BoxFit.contain),
                  ),
                  if (!item.isRead)
                    CircleAvatar(backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: .75), radius: 3),
                ]),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(child: SizedBox(height: 45, child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(child: Text(item.typeLabel,
                        style: textBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(
                        DateConverter.getLocalTimeWithAMPM(item.createdAt ?? ''),
                        style: textRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ]),

                    Text(
                      item.message ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),

                  ],
                ))),

              ]),
            ),

          ]),
        );
      },
    );
  }

  bool _willShowDate(int index, List<AuctionNotificationItem>? list) {
    if (list?.isEmpty ?? true) return false;
    if (index == 0) return true;
    final currentDate = DateTime.tryParse(list?[index].createdAt ?? '');
    final previousDate = DateTime.tryParse(list?[index - 1].createdAt ?? '');
    return currentDate?.day != previousDate?.day;
  }
}
