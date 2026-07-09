import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/swipeable_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class AuctionDetailsBottomBarWidget extends StatefulWidget {
  final UserCreatedAuctionEnum auctionState;
  final int totalBidCount;
  final bool isCashOnDelivery;
  final bool hasExistingWithdraw;
  final bool isWithdrawDisabled;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final VoidCallback onPayNow;
  final VoidCallback onWithdraw;
  final VoidCallback? onRelaunch;
  final Future<void> Function(AuctionDeliveryStatus status) onDeliveryStatusUpdate;

  const AuctionDetailsBottomBarWidget({
    super.key,
    required this.auctionState,
    this.totalBidCount = 0,
    this.isCashOnDelivery = false,
    this.hasExistingWithdraw = false,
    this.isWithdrawDisabled = false,
    required this.onCancel,
    required this.onEdit,
    required this.onPayNow,
    required this.onWithdraw,
    this.onRelaunch,
    required this.onDeliveryStatusUpdate,
  });

  @override
  State<AuctionDetailsBottomBarWidget> createState() => _AuctionDetailsBottomBarWidgetState();
}

class _AuctionDetailsBottomBarWidgetState extends State<AuctionDetailsBottomBarWidget> {
  final JustTheController _tooltipController = JustTheController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  bool get _showBottomBar {
    if (widget.auctionState == UserCreatedAuctionEnum.readyToClaim) return false;
    // Live auctions only expose a cancel action while no bids have been placed.
    if (widget.auctionState == UserCreatedAuctionEnum.live) return widget.totalBidCount == 0;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_showBottomBar) return const SizedBox.shrink();

    return ColoredBox(
      color: Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: _buildChild(context),
        ),
      ),
    );
  }

  Widget _buildChild(BuildContext context) {
    return switch (widget.auctionState) {
      UserCreatedAuctionEnum.pending ||
      UserCreatedAuctionEnum.upcoming ||
      UserCreatedAuctionEnum.canceled => AuctionActionButtonsWidget(
          onCancelAuction: widget.onCancel,
          onEditAuction: widget.onEdit,
          cancelLabel: getTranslated('delete_auction', context) ?? 'Delete Auction',
        ),

      UserCreatedAuctionEnum.rejected ||
      UserCreatedAuctionEnum.unsold => AuctionActionButtonsWidget(
          onCancelAuction: widget.onCancel,
          onEditAuction: widget.onRelaunch ?? () {},
          editLabel: getTranslated('relaunch', context) ?? 'Relaunch',
        ),

      UserCreatedAuctionEnum.live => _buildCancelButton(context),

      UserCreatedAuctionEnum.purchaseComplete =>
          _buildSwipe(
            context,
            label: getTranslated('swipe_to_ready_to_delivery', context) ?? '',
            nextStatus: AuctionDeliveryStatus.readyToDelivery,
          ),

      UserCreatedAuctionEnum.readyToDelivery =>
          _buildSwipe(
            context,
            label: getTranslated('swipe_to_on_the_way', context) ?? '',
            nextStatus: AuctionDeliveryStatus.onTheWay,
          ),

      UserCreatedAuctionEnum.onTheWay =>
          _buildSwipe(
            context,
            label: getTranslated('swipe_to_delivered', context) ?? '',
            nextStatus: AuctionDeliveryStatus.delivered,
          ),

      UserCreatedAuctionEnum.delivered => _buildDeliveredButton(context),

      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCancelButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: widget.onCancel,
        style: OutlinedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: .08),
          side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: .3)),
          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
        child: Text(
          getTranslated('cancel_auction', context)!,
          style: titilliumSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipe(
      BuildContext context, {
        required String label,
        required AuctionDeliveryStatus nextStatus,
      }) {
    return SwipeableButtonWidget(
      key: ValueKey(nextStatus),
      action: () => widget.onDeliveryStatusUpdate(nextStatus),
      label: Text(label,
        style: titilliumSemiBold.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor,
        ),
      ),
      icon: Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
      buttonColor: Theme.of(context).colorScheme.primary,
      baseColor: Theme.of(context).textTheme.bodyLarge!.color!,
      highlightedColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDeliveredButton(BuildContext context) {
    if (!widget.isCashOnDelivery && widget.hasExistingWithdraw) return const SizedBox.shrink();

    final isDisabledWithdraw = !widget.isCashOnDelivery && widget.isWithdrawDisabled;
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.primary,
      disabledBackgroundColor: Theme.of(context).colorScheme.primary,
      disabledForegroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      elevation: 0,
    );

    Widget child;
    if (widget.isCashOnDelivery) {
      child = Text(
        getTranslated('pay_now', context) ?? 'Pay Now',
        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
      );
    } else if (isDisabledWithdraw) {
      child = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated('withdraw_request', context) ?? 'Withdraw Request',
            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
          ),
          const SizedBox(width: 6),
          JustTheTooltip(
            controller: _tooltipController,
            tailLength: 10,
            tailBaseWidth: 20,
            backgroundColor: Colors.black87,
            content: Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
              child: Text(
                getTranslated('withdraw_disabled_unpaid', context) ?? 'Payment must be completed before withdrawal can be requested',
                style: titilliumRegular.copyWith(color: Colors.white),
              ),
            ),
            child: GestureDetector(
              onTap: () => _tooltipController.showTooltip(),
              child: const Icon(Icons.info_outline, size: 16, color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      child = Text(
        getTranslated('withdraw_request', context) ?? 'Withdraw Request',
        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
      );
    }

    final button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabledWithdraw ? null : (widget.isCashOnDelivery ? widget.onPayNow : widget.onWithdraw),
        style: buttonStyle,
        child: child,
      ),
    );

    return isDisabledWithdraw ? Opacity(opacity: 0.5, child: button) : button;
  }
}

class AuctionActionButtonsWidget extends StatelessWidget {
  final VoidCallback onCancelAuction;
  final VoidCallback onEditAuction;
  final String? editLabel;
  final String? cancelLabel;

  const AuctionActionButtonsWidget({
    super.key,
    required this.onCancelAuction,
    required this.onEditAuction,
    this.editLabel,
    this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancelAuction,
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error.withValues(alpha: .08),
              side: BorderSide(color: Theme.of(context).colorScheme.error.withValues(alpha: .3)),
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
            child: Text(
              cancelLabel ?? getTranslated('cancel_auction', context)!,
              style: titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: ElevatedButton(
            onPressed: onEditAuction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
              elevation: 0,
            ),
            child: Text(
              editLabel ?? getTranslated('edit_auction', context)!,
              style: titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}