import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/confirmation_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_offline_payment_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

import 'auction_place_bid_bottom_sheet_widget.dart';

class AuctionBidActionWidget extends StatelessWidget {
  final int auctionId;
  final String? slug;
  final double currentBidAmount;
  final double minimumIncrementAmount;
  final AuctionParticipationStatus? auctionStatus;
  final ParticipationAuctionDetailsModel? auctionDetails;
  final MyBid? myBid;
  final bool isGuest;

  const AuctionBidActionWidget(
      {super.key,
      required this.auctionId,
      this.slug,
      required this.currentBidAmount,
      required this.minimumIncrementAmount,
      required this.auctionStatus,
      required this.auctionDetails,
      this.myBid,
      this.isGuest = false,
      });

  static void openAuctionBidActionWidget(
      BuildContext context, {
        required int auctionId,
        required double currentBidAmount,
        required double minimumIncrementAmount,
        required bool isEntryFeeEnabled,
        required bool isEntryFeePaid,
        required double entryFee,
        required String selectedCurrency,
        required AuctionParticipationStatus? auctionStatus,
        required ParticipationAuctionDetailsModel? auctionDetails,
        required bool isGuest,
      }) {

    if (auctionStatus?.isLive == true &&
        !(auctionDetails?.product?.myParticipation?.entryFeePaidStatus == '1' || auctionDetails?.product?.myParticipation?.entryFeePaidStatus == 'paid') &&
        isEntryFeeEnabled) {
      AuctionEntryFeeBottomSheet.show(context, auctionId: auctionId, entryFee: entryFee,
        onPayEntryFee: () {
          AuctionPaymentBottomSheet.show(context, auctionId: auctionId, entryFee: entryFee);
        },
      );
    } else {
      Provider.of<AuctionParticipationController>(context, listen: false).clearMinimumBidRequired();

      final myBidData = auctionDetails?.product?.myBid;
      final product = auctionDetails?.product;

      final bool isFirstBid = (product?.totalBidsCount ?? 0) == 0 || (product?.isAllBidWithdrawn ?? false);

      final secondHighestBidAmount = product?.secondHighestBid?.bidAmount ?? 0.0;
      final startingPrice = product?.startingPrice ?? 0.0;
      final minimumRollbackBid = product?.secondHighestBid == null ? startingPrice : secondHighestBidAmount + minimumIncrementAmount;

      final double baseBidAmount = isFirstBid ? (product?.startingPrice ?? currentBidAmount) : currentBidAmount;

      AuctionPlaceBidBottomSheet.show(
        context,
        highestBid: baseBidAmount,
        stepAmount: minimumIncrementAmount,
        isFirstBid: isFirstBid,
        suggestedAmounts: List.generate(5, (index) => baseBidAmount + (minimumIncrementAmount * (isFirstBid ? index : index + 1))),
        isLeadBid: myBidData?.isLeadBid ?? false,
        hasUsedRollback: myBidData?.isRollbackBid ?? false,
        myCurrentBidAmount: myBidData?.bidAmount,
        minimumRollbackBid: minimumRollbackBid,
        auctionProductId: auctionId,
        onPlaceBid: (amount) async {
          final bidAmountController = TextEditingController(text: amount.toString());
          final auctionController = Provider.of<AuctionParticipationController>(context, listen: false);

          final response = await auctionController.placeAuctionBid(context, auctionProductId: auctionId, bidAmountController: bidAmountController);

          bidAmountController.dispose();

          if (context.mounted && response?.response?.statusCode == 200) {
            Navigator.pop(context);
          }
        },
        onRollbackBid: (amount) async {
          final auctionController = Provider.of<AuctionParticipationController>(context, listen: false);
          await auctionController.rollbackAuctionBid(context, auctionProductId: auctionId, bidAmount: amount);
        },
      );
    }
  }

  void _showNotLoggedInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => NotLoggedInBottomSheetWidget(
        fromPage: RouterHelper.participationAuctionDetailsScreen,
        onLoginSuccess: () => RouterHelper.getParticipationAuctionDetailsRoute(slug: slug ?? ''),
      ),
    );
  }

  void _showWithdrawConfirmationDialog(BuildContext context, AuctionParticipationController auctionController) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialogWidget(
        icon: Images.warning,
        title: getTranslated('are_you_sure?', context) ?? 'Are You Sure?',
        description: getTranslated('are_you_sure_you_want_to_with_draw_bid', context) ?? 'Are you sure you want to withdraw your bid',
        onYesPressed: () async {
          await auctionController.withdrawAuctionBid(context, auctionProductId: auctionId);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openPlaceBidSheet(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final isEntryFeeEnabled = ((splashController.configModel?.isAuctionEntryFeeEnabled ?? false) && (splashController.configModel?.auctionEntryFeeAmount ?? 0) > 0);
    final double entryFeePercentage = splashController.configModel?.auctionEntryFeeAmount ?? 0.0;
    final double entryFee = (entryFeePercentage / 100) * (auctionDetails?.product?.startingPrice ?? 0);
    final String selectedCurrency = splashController.myCurrency?.code ?? '';
    final isEntryFeePaid = Provider.of<AuctionParticipationController>(context, listen: false).isEntryFeePaid;

    AuctionBidActionWidget.openAuctionBidActionWidget(
      context,
      auctionId: auctionId,
      currentBidAmount: currentBidAmount,
      minimumIncrementAmount: minimumIncrementAmount,
      isEntryFeeEnabled: isEntryFeeEnabled,
      isEntryFeePaid: isEntryFeePaid,
      entryFee: entryFee,
      selectedCurrency: selectedCurrency,
      auctionStatus: auctionStatus,
      auctionDetails: auctionDetails,
      isGuest: isGuest,
    );
  }

  @override
  Widget build(BuildContext context) {
    final splashController = Provider.of<SplashController>(context, listen: false);
    final isEntryFeeEnabled = ((splashController.configModel?.isAuctionEntryFeeEnabled ?? false) && (splashController.configModel?.auctionEntryFeeAmount ?? 0) > 0);
    double entryFeePercentage = splashController.configModel?.auctionEntryFeeAmount ?? 0.0;
    final selectedCurrency = splashController.myCurrency?.code;
    bool isParticipated = auctionDetails?.product?.myParticipation != null;
    double entryFee = (entryFeePercentage / 100) * (auctionDetails?.product?.startingPrice ?? 0);

    return Consumer<AuctionParticipationController>(
      builder: (context, auctionController, _) {
        final isLoading = auctionController.isEntryFeeLoading || auctionController.isBidLoading;
        final isWithdrawLoading = auctionController.isWithdrawBidLoading;

        final bool hasBid = myBid != null && auctionStatus?.isLive == true;
        final double riseAmount = currentBidAmount + minimumIncrementAmount;

        // Withdrawn bids still count, so totalBidsCount stays > 0; treat all-withdrawn as a first bid.
        final bool isFirstBid = ((auctionDetails?.product?.totalBidsCount ?? 0) == 0) || (auctionDetails?.product?.isAllBidWithdrawn ?? false);
        final double baseBidAmount = isFirstBid ? (auctionDetails?.product?.startingPrice ?? currentBidAmount) : currentBidAmount;
        final bool isPendingVerification = auctionDetails?.product?.myParticipation?.entryFeePaymentMethod == 'offline_payment' &&
            auctionDetails?.product?.myParticipation?.entryFeePaymentStatus == 'pending';

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            if (isPendingVerification) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, size: Dimensions.iconSizeSmall, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: Text(
                      getTranslated('auction_entry_fee_pending_verification', context) ?? 'You have Participated this auction. Waiting for payment verification.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ] else if (isEntryFeeEnabled && auctionDetails?.product?.myParticipation?.entryFeePaymentMethod == null ) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, size: Dimensions.iconSizeSmall, color: Theme.of(context).colorScheme.tertiary),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                  Expanded(
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        children: [
                          TextSpan(text: getTranslated('to_participate_in_this_bid', context) ?? ""),
                          TextSpan(
                            text: PriceConverter.convertPrice(context, entryFee),
                            style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                          TextSpan(text: getTranslated('entry_fee_will_be_charged', context) ?? ""),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
            ],

            if (hasBid) ...[
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 40,
                    child: CustomButton(
                      buttonText: getTranslated('withdraw_bid', context) ?? 'Withdraw Bid',
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      textColor: Theme.of(context).textTheme.bodyLarge?.color,
                      isLoading: isWithdrawLoading,
                      loadingColor: Colors.white,
                      radius: Dimensions.radiusSmall,
                      fontSize: Dimensions.fontSizeDefault,
                      onTap: (isWithdrawLoading || isLoading) ? null : () {
                        if (isGuest) { _showNotLoggedInSheet(context); return; }
                        _showWithdrawConfirmationDialog(context, auctionController);
                      },
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),


                  Expanded(
                    child: ElevatedButton(
                      onPressed: (isLoading || isWithdrawLoading) ? null
                        : () => _openPlaceBidSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).cardColor,
                        disabledBackgroundColor: Theme.of(context).hintColor,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        elevation: 0,
                      ),
                      child: isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('${getTranslated('rise_bid', context) ?? ' '} (${PriceConverter.convertPrice(context, riseAmount)})',
                          style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                    ),
                  ),

                ],
              ),
            ] else ...[
              Opacity(
                opacity: isPendingVerification ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: isPendingVerification,
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: (isLoading || (isParticipated && auctionStatus?.isUpcoming == true))
                        ? null
                        : () async {
                        if (isGuest) { _showNotLoggedInSheet(context); return; }
                          if (auctionStatus?.isUpcoming == true && !isParticipated) {
                            await auctionController.payAuctionEntryFee(context,
                              auctionProductId: auctionId,
                              feeAmount: 0,
                              currency: selectedCurrency ?? '',
                              auctionStatus: auctionStatus?.label ?? '',
                              paymentMethod: 'wallet'
                            );
                          } else if (auctionStatus?.isLive == true && !(auctionDetails?.product?.myParticipation?.entryFeePaidStatus == '1' || auctionDetails?.product?.myParticipation?.entryFeePaidStatus == 'paid') && isEntryFeeEnabled) {
                            AuctionEntryFeeBottomSheet.show(
                              context,
                              auctionId: auctionId,
                              entryFee: entryFee,
                              onPayEntryFee: () {
                                AuctionPaymentBottomSheet.show(
                                  context,
                                  auctionId: auctionId,
                                  entryFee: entryFee,
                                );
                              },
                            );
                          } else {
                            if (isGuest) { _showNotLoggedInSheet(context); return; }
                            _openPlaceBidSheet(context);
                          }
                        },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).cardColor,
                        disabledBackgroundColor: (isParticipated && auctionStatus?.isUpcoming == true) ?
                        Theme.of(context).primaryColor.withValues(alpha: 0.20)
                        : Theme.of(context).hintColor,
                        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                        elevation: 0,
                      ),
                      child: isLoading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text((!isParticipated)
                            ? '${getTranslated('participate', context)}'
                            : (isParticipated && auctionStatus?.isUpcoming == true)
                            ? '${getTranslated('participated', context)}'
                            : '${getTranslated('start_bidding', context)} (${PriceConverter.convertPrice(context, isFirstBid ? baseBidAmount : riseAmount)})',
                            style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                              color:  (isParticipated && auctionStatus?.isUpcoming == true) ?
                              Theme.of(context).primaryColor : Colors.white,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class AuctionEntryFeeBottomSheet extends StatelessWidget {
  final int auctionId;
  final double entryFee;
  final VoidCallback onPayEntryFee;

  const AuctionEntryFeeBottomSheet({
    super.key,
    required this.auctionId,
    required this.entryFee,
    required this.onPayEntryFee,
  });

  static Future<void> show(
    BuildContext context, {
    required int auctionId,
    required double entryFee,
    required VoidCallback onPayEntryFee,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      builder: (_) => AuctionEntryFeeBottomSheet(
        auctionId: auctionId,
        entryFee: entryFee,
        onPayEntryFee: onPayEntryFee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding:
                    const EdgeInsets.all(Dimensions.paddingSizeExtraExtraSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withValues(alpha: .2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: Dimensions.iconSizeSmall - 2,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
          Text(
            getTranslated('pay_entry_fee_to_bid', context) ?? "",
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeLarge,
              vertical: Dimensions.paddingSizeDefault,
            ),
            child: Column(
              children: [
                Text(
                  PriceConverter.convertPrice(context, entryFee),
                  style: titilliumBold.copyWith(
                    fontSize: 32,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  getTranslated('entry_fee_info', context) ?? "",
                  textAlign: TextAlign.center,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onPayEntryFee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).cardColor,
                  padding: const EdgeInsets.symmetric(
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  getTranslated('pay_entry_fee', context) ?? "",
                  style: titleRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuctionPaymentBottomSheet extends StatefulWidget {
  final int auctionId;
  final double entryFee;

  const AuctionPaymentBottomSheet({
    super.key,
    required this.auctionId,
    required this.entryFee,
  });

  static Future<void> show(
    BuildContext context, {
    required int auctionId,
    required double entryFee,
  }) {

    Provider.of<AuctionParticipationController>(context, listen: false).resetPaymentState();
    bool isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
    if(isLoggedIn) {
      Provider.of<WalletController>(context, listen: false).getTransactionList(1, reload: false, isUpdate: true);
    }
    Provider.of<AuctionCheckoutController>(context, listen: false).getOfflinePaymentList();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      builder: (_) => AuctionPaymentBottomSheet(
        auctionId: auctionId,
        entryFee: entryFee,
      ),
    );
  }

  @override
  State<AuctionPaymentBottomSheet> createState() => _AuctionPaymentBottomSheetState();
}

class _AuctionPaymentBottomSheetState extends State<AuctionPaymentBottomSheet> {
  bool _showPaymentError = false;

  @override
  Widget build(BuildContext context) {
    return Consumer4<SplashController, WalletController, AuctionParticipationController, AuctionCheckoutController>(
      builder: (context, splashController, walletController, auctionController, checkoutController, _) {
        final configModel = splashController.configModel;
        final paymentMethods = configModel?.paymentMethods ?? [];
        final hasDigitalPayment = (configModel?.digitalPayment ?? false) && paymentMethods.isNotEmpty;
        final selectedCurrency = Provider.of<SplashController>(Get.context!, listen: false).myCurrency?.code;
        final walletBalance = double.tryParse(
            walletController.walletTransactionModel?.totalWalletBalance.toString() ?? '0') ?? 0.0;
        final offlineMethods = checkoutController.offlinePaymentModel?.offlineMethods ?? [];
        final hasOfflinePayment = configModel?.offlinePayment != null && offlineMethods.isNotEmpty;

        return Padding(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: Dimensions.iconSizeExtraSmall + 2, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                      Text(
                        getTranslated('go_back', context) ?? "",
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(
                getTranslated('choose_payment_method', context) ?? "",
                style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text(
                getTranslated('auction_entry_fee', context) ?? "",
                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodySmall?.color),
              ),


              Text(
                PriceConverter.convertPrice(context, widget.entryFee),
                style: titilliumBold.copyWith(fontSize: 28, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  border: Border.all(color: auctionController.isWalletApplied
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: .5)
                    : Theme.of(context).hintColor.withValues(alpha: .3)),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(getTranslated('wallet_balance', context) ?? "",
                            style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).textTheme.bodySmall?.color)),
                          walletController.walletTransactionModel == null
                            ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 1.5))
                            : Text(PriceConverter.convertPrice(context, walletBalance),
                                style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: walletController.walletTransactionModel == null ? null : () {
                          auctionController.applyWallet(walletBalance: walletBalance, entryFee: widget.entryFee);
                          setState(() => _showPaymentError = false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: auctionController.isWalletApplied
                            ? Theme.of(context).colorScheme.onTertiaryContainer
                            : Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraExtraSmall),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          minimumSize: Size.zero,
                        ),
                        icon: auctionController.isWalletApplied
                          ? Icon(Icons.check_circle_outline_rounded, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.onTertiaryContainer)
                          : const SizedBox.shrink(),
                        label: Text(
                          auctionController.isWalletApplied ? getTranslated('applied', context) ?? 'Applied' : getTranslated('apply', context) ?? 'Apply',
                          style: titilliumSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: auctionController.isWalletApplied ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.primary),
                        ),
                      ),
                    ]),
                    if (auctionController.isWalletInsufficient) ...[
                      const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                      Row(children: [
                        Icon(Icons.error_outline_rounded, size: Dimensions.iconSizeExtraSmall, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
                        Text(getTranslated('insufficient_balance', context) ?? '',
                          style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error)),
                      ]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),


              if (hasDigitalPayment) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(getTranslated('pay_via_online', context) ?? "",
                    style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color)),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                  itemBuilder: (context, index) {
                    final method = paymentMethods[index];
                    final isSelected = auctionController.selectedPaymentMethodIndex == index;
                    return InkWell(
                      onTap: () {
                        auctionController.setSelectedPaymentMethod(index, method.keyName ?? '');
                        setState(() => _showPaymentError = false);
                      },
                      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall,),
                        decoration: BoxDecoration(
                          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                child: CustomImageWidget(
                                  image: '${configModel?.paymentMethodImagePath}/${method.additionalDatas?.gatewayImage ?? ''}',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                method.additionalDatas?.gatewayTitle ?? method.keyName ?? '',
                                style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                              ),
                            ),
                            Theme(
                              data: Theme.of(context).copyWith(unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha: .25)),
                              child: Checkbox(
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
                                value: isSelected,
                                activeColor: Colors.green,
                                checkColor: Theme.of(context).cardColor,
                                onChanged: (_) => auctionController.setSelectedPaymentMethod(index, method.keyName ?? ''),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              if (hasOfflinePayment) ...[
                Container(
                  decoration: BoxDecoration(
                    color: auctionController.isOfflinePaymentSelected
                        ? Theme.of(context).primaryColor.withValues(alpha: .10) : null,
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                      color: auctionController.isOfflinePaymentSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: .5) : Theme.of(context).hintColor.withValues(alpha: .3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        onTap: () {
                          final nowSelected = !auctionController.isOfflinePaymentSelected;
                          auctionController.setOfflinePaymentSelected(nowSelected);
                          if (nowSelected) {
                            checkoutController.setOfflinePaymentMethodSelectedIndex(0);
                            setState(() => _showPaymentError = false);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: 0,
                          ),
                          child: Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                ),
                                child: Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
                                  ),
                                  value: auctionController.isOfflinePaymentSelected,
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                  onChanged: (_) {
                                    final nowSelected = !auctionController.isOfflinePaymentSelected;
                                    auctionController.setOfflinePaymentSelected(nowSelected);
                                    if (nowSelected) {
                                      checkoutController.setOfflinePaymentMethodSelectedIndex(0);
                                    }
                                  },
                                ),
                              ),
                              Text(
                                getTranslated('pay_offline', context) ?? 'Pay Offline',
                                style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (auctionController.isOfflinePaymentSelected) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeDefault,
                          ),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: offlineMethods.length,
                              itemBuilder: (context, index) {
                                final isSelected =
                                    checkoutController.offlineMethodSelectedIndex == index;
                                return InkWell(
                                  onTap: () => checkoutController
                                      .setOfflinePaymentMethodSelectedIndex(index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context).primaryColor.withValues(alpha: .3),
                                          width: isSelected ? 1.5 : 0.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: Dimensions.paddingSizeDefault,
                                      ),
                                      child: Center(
                                        child: Text(
                                          offlineMethods[index].methodName ?? '',
                                          style: titilliumRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              if (_showPaymentError)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                  child: Text(
                    getTranslated('please_select_payment_method', context) ?? 'Please select a payment method',
                    style: titilliumRegular.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: auctionController.isEntryFeeLoading
                      ? null
                      : () async {
                          final bool noMethodSelected = !auctionController.isWalletApplied
                              && auctionController.selectedPaymentMethodName.isEmpty && !auctionController.isOfflinePaymentSelected;
                          if (noMethodSelected) {
                            setState(() => _showPaymentError = true);
                            return;
                          }

                          if (auctionController.isOfflinePaymentSelected) {
                            Navigator.pop(context);
                            final result = await Navigator.push<bool>(
                              Get.context!,
                              MaterialPageRoute(
                                builder: (_) => AuctionOfflinePaymentScreen(
                                  amount: widget.entryFee,
                                  auctionId: widget.auctionId,
                                ),
                              ),
                            );
                            if (result == true && Get.context!.mounted) {Navigator.of(Get.context!).pop();}
                            return;
                          }

                          final paymentMethod = auctionController.isWalletApplied ? 'wallet' : auctionController.selectedPaymentMethodName;

                          await auctionController.payAuctionEntryFee(
                            Get.context!,
                            auctionProductId: widget.auctionId,
                            feeAmount: widget.entryFee,
                            currency: selectedCurrency ?? '',
                            auctionStatus: '',
                            paymentMethod: paymentMethod,
                          );

                          if (auctionController.isEntryFeePaid) {
                            auctionController.resetPaymentState();
                            Navigator.pop(Get.context!);
                            Navigator.pop(Get.context!);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
                    elevation: 0,
                  ),
                  child: auctionController.isEntryFeeLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        auctionController.isOfflinePaymentSelected
                            ? getTranslated('continue', context) ?? 'Continue'
                            : getTranslated('proceed_bid', context) ?? '',
                        style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Colors.white),
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
