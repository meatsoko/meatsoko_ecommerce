import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/participation_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_experied_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_finalizing_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_participant_address_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_participant_billing_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_payment_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_product_horizontal_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_product_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_stat_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_bid_action_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_track_order_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_winner_banner_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_countdown_timer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_feature_tags_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_insights_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_person_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_product_details_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/participate_offline_payment_deatils_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_product_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/participant_bidding_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/participation_auction_deatils_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/product_image_viewer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/chat/controllers/chat_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:share_plus/share_plus.dart';

class ParticipationAuctionDetailsScreen extends StatefulWidget {
  static String? activeSlug;

  final bool isNotification;
  final String slug;
  final AuctionParticipationStatus? auctionStatus;
  final bool openBidSheet;
  final bool fromDeepLink;

  const ParticipationAuctionDetailsScreen({
    super.key,
    this.isNotification = false,
    required this.slug,
    this.auctionStatus,
    this.openBidSheet = false,
    this.fromDeepLink = false,
  });

  @override
  State<ParticipationAuctionDetailsScreen> createState() => _ParticipationAuctionDetailsScreenState();
}

class _ParticipationAuctionDetailsScreenState extends State<ParticipationAuctionDetailsScreen> {

  @override
  void initState() {
    super.initState();
    ParticipationAuctionDetailsScreen.activeSlug = widget.slug;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParticipationAuctionDetailsController>(context, listen: false)
          .getAuctionProductOverview(context, slug: widget.slug, auctionStatus: widget.auctionStatus?.label,);

      if ((widget.auctionStatus?.isLive ?? false) &&
        Provider.of<AuthController>(context, listen: false).isLoggedIn()) {
        Provider.of<WalletController>(context, listen: false).getTransactionList(1, isUpdate: false);
      }

      if (widget.openBidSheet && (widget.auctionStatus?.isLive ?? false)) {
        Provider.of<ParticipationAuctionDetailsController>(context, listen: false).addListener(_openAuctionBidActionSheet);
      }
    });
  }

  void _openAuctionBidActionSheet() {
    final detailsController = Provider.of<ParticipationAuctionDetailsController>(context, listen: false);
    if (!detailsController.isLoading && detailsController.auctionDetails?.product != null) {
      detailsController.removeListener(_openAuctionBidActionSheet);

      final splashController = Provider.of<SplashController>(context, listen: false);
      final product = detailsController.auctionDetails!.product!;

      final bool isEntryFeeEnabled = ((splashController.configModel?.isAuctionEntryFeeEnabled ?? false) && (splashController.configModel?.auctionEntryFeeAmount ?? 0) > 0);
      final double entryFeePercentage = splashController.configModel?.auctionEntryFeeAmount ?? 0.0;
      final double entryFee = (entryFeePercentage / 100) * (product.startingPrice ?? 0);
      final String selectedCurrency = splashController.myCurrency?.code ?? '';
      final bool isEntryFeePaid = Provider.of<AuctionParticipationController>(context, listen: false).isEntryFeePaid;

      AuctionBidActionWidget.openAuctionBidActionWidget(
        context,
        auctionId: product.id ?? 0,
        currentBidAmount: (product.currentHighestBidAmount ?? 0) > 0 ? product.currentHighestBidAmount! : product.startingPrice ?? 0,
        minimumIncrementAmount: product.minimumIncrementAmount ?? 0,
        isEntryFeeEnabled: isEntryFeeEnabled,
        isEntryFeePaid: isEntryFeePaid,
        entryFee: entryFee,
        selectedCurrency: selectedCurrency,
        auctionStatus: widget.auctionStatus,
        auctionDetails: detailsController.auctionDetails,
        isGuest: !Provider.of<AuthController>(context, listen: false).isLoggedIn(),
      );
    }
  }

  @override
  void dispose() {
    ParticipationAuctionDetailsScreen.activeSlug = null;
    Provider.of<ParticipationAuctionDetailsController>(context, listen: false).removeListener(_openAuctionBidActionSheet);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ParticipationAuctionDetailsController>(

      builder: (context, controller, _) {

        final splashController = Provider.of<SplashController>(context, listen: false);
        final bool isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();


        AuctionProductDetails? product = controller.auctionDetails?.product;

        debugPrint('myAuctionStatus.label: ${product?.myAuctionStatus?.label}');
        debugPrint('auctionOwnerStatus: ${product?.auctionOwnerStatus}');

        PaymentInfo? paymentInfo  = controller.auctionDetails?.paymentInfo;
        BillingInfo? billingInfo = controller.auctionDetails?.billingInfo;

        final profileController = Provider.of<ProfileController>(context, listen: false);
        final bool isOwner = profileController.userInfoModel?.id != null && profileController.userInfoModel!.id == product?.ownerId && product?.ownerType == AuctionOwnerType.customer;


        final DateTime? endTime = product?.auctionStatus?.isUpcoming == true
          ? DateTime.tryParse(product?.startTime ?? '')
          : (product?.auctionStatus?.isLive == true || product?.auctionStatus?.isWon == true)
          ? DateTime.tryParse(product?.endTime ?? '')
          : null;

        // TODO: remove ready to delivery
        final bool isWonOrReadyToClaim = (product?.myAuctionStatus?.isWon == true || product?.auctionStatus?.isClaimed == true) &&  product?.myBid?.claimStartTime != null;

        final claimLimit = splashController.configModel?.auctionWinnerClaimTimeLimit;
        final DateTime? claimDeadline = isWonOrReadyToClaim ? DateConverter.auctionClaimDeadline(
          claimStartTime: product?.myBid?.claimStartTime,
          limitValue: claimLimit?.value,
          limitUnit: claimLimit?.unit,
        ) : null;

        bool? availableClaimDeadline = claimDeadline?.isAfter(DateTime.now());

        bool isParticipated = product?.myParticipation != null;





        return PopScope(
          canPop: !widget.isNotification && !widget.fromDeepLink && Navigator.canPop(context),
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (widget.isNotification) {
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil, page: 'auction');
            } else if (widget.fromDeepLink) {
              _handleDeepLinkBack();
            }
          },

          child: Scaffold(
            appBar: CustomAppBar(
              title: getTranslated('auction_details', context) ?? '',
              centerTitle: false,
              onBackPressed: widget.isNotification
                  ? () => RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil, page: 'auction')
                  : widget.fromDeepLink
                  ? () => _handleDeepLinkBack()
                  : null,
              actions: [
                if (product?.myAuctionStatus?.isClaimed != true) ...[
                  Consumer<AuctionParticipationController>(
                    builder: (context, participationController, _) {
                      return Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.30),
                          ),
                        ),
                        child: participationController.isSaveLoading
                            ? Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ) : IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 16,
                          color: Theme.of(context).colorScheme.error,
                          icon: Icon((product?.isAuctionSave ?? false) ? Icons.bookmark : Icons.bookmark_outline),
                          onPressed: product == null ? null : () {
                            final isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
                            if (!isLoggedIn) {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (_) => NotLoggedInBottomSheetWidget(
                                  fromPage: RouterHelper.participationAuctionDetailsScreen,
                                  onLoginSuccess: () {
                                    RouterHelper.getParticipationAuctionDetailsRoute(slug: widget.slug, auctionStatus: widget.auctionStatus);
                                    participationController.toggleSaveAuctionProduct(context, auctionProductId: product.id!);
                                  },
                                ),
                              );
                              return;
                            }
                            if (!participationController.validateToggleSave(context, auctionProductId: product.id)) return;
                            participationController.toggleSaveAuctionProduct(context, auctionProductId: product.id!);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.30)),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 16,
                      color: Theme.of(context).primaryColor,
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () async {
                        final participationController = Provider.of<AuctionParticipationController>(context, listen: false);

                        await participationController.getAuctionSocialShareLink(
                          context,
                          productId: product!.id!,
                        );

                        final shareData = participationController.socialShareLink;

                        if (shareData != null) {
                          SharePlus.instance.share(ShareParams(text: shareData.link));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],

                if (product?.myAuctionStatus?.isClaimed == true) ...[
                  Consumer<AuctionParticipationController>(
                    builder: (context, participationController, _) =>
                      participationController.isInvoiceLoading
                        ? const Padding(
                            padding: EdgeInsets.all(Dimensions.paddingSizeEight),
                            child: SizedBox(
                              width: Dimensions.paddingSizeExtraLarge,
                              height: Dimensions.paddingSizeExtraLarge,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                          )
                        : GestureDetector(
                            onTap: product == null ? null : () {
                              participationController.getAuctionInvoice(product.id!, context);
                            },
                            child: CustomAssetImageWidget(
                              Images.downloadInvoice,
                              height: Dimensions.paddingSizeExtraLarge,
                              width: Dimensions.paddingSizeExtraLarge,
                            ),
                          ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                ],
              ],
            ),





            // TODO: add auction ready to delivery status
            bottomNavigationBar: (controller.isLoading || product == null || product.myAuctionStatus?.isLost == true
              || product.myAuctionStatus?.isClaimExpiredLost == true  || product.myAuctionStatus?.isClaimed == true
              || product.auctionOwnerStatus == 'unsold' || product.myAuctionStatus?.isFinalizing == true
              || ((product.myAuctionStatus?.isWon == true) &&  isWonOrReadyToClaim  && !(availableClaimDeadline ?? false))
              || isOwner
            ) ? null : SafeArea(
              top: false,
              child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    offset: const Offset(0, -2),
                    blurRadius: 12,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
              child: isWonOrReadyToClaim  &&  (availableClaimDeadline ?? false) ?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslated('final_bid_price', context) ?? 'Final bid price', style: textRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor)),
                      Text(PriceConverter.convertPrice(context, product.myBid?.bidAmount ?? product.currentHighestBidAmount ?? 0), style: titilliumBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor)),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    height: 40,
                    child: CustomButton(
                      radius: Dimensions.radiusSmall,
                      buttonText: getTranslated('claim_product', context) ?? 'Claim Product',
                      onTap: () {
                        RouterHelper.getAuctionCheckoutRoute(
                          productId: product.id ?? 0,
                          myBidAmount: product.myBid?.bidAmount ?? product.currentHighestBidAmount ?? 0,
                          highestBidAmount: product.currentHighestBidAmount ?? 0,
                          startingPrice: product.startingPrice ?? 0,
                          shippingFee: product.shippingFee ?? 0,
                          tax: product.totalTaxAmount ?? 0,
                          action: RouteAction.push,
                        );
                      },
                    ),
                  ),
                ],
              ) : (product.myAuctionStatus?.isWon == true || product.myAuctionStatus?.isClaimed == true) ? null : AuctionBidActionWidget(
                auctionId: product.id ?? 0,
                slug: widget.slug,
                currentBidAmount: (((product.currentHighestBidAmount ?? 0) > 0) ? product.currentHighestBidAmount! : product.startingPrice ?? 0.00     ),
                minimumIncrementAmount: product.minimumIncrementAmount ?? 0.00,
                auctionStatus: product.auctionStatus,
                auctionDetails: controller.auctionDetails,
                myBid: product.myBid,
                isGuest: isGuestMode,
              ),
            )),

            body: controller.isLoading ? const Center(child: ParticipationAuctionDetailsScreenShimmer()) : product == null
              ? NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('auction_product_not_found', context) ?? 'Auction product not found')
              : RefreshIndicator(
              onRefresh: () async {
                await Provider.of<ParticipationAuctionDetailsController>(context, listen: false)
                    .getAuctionProductOverview(context, slug: widget.slug, auctionStatus: widget.auctionStatus?.label);
              },
                child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.homePagePadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '${getTranslated('auction_id', context) ?? ""} ',
                                        style: titleRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color),
                                      ),

                                      WidgetSpan(
                                        child: SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                      ),

                                      TextSpan(
                                        text: '#${product.id}',
                                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Builder(builder: (context) {
                                final statusLabel = isParticipated ? product.myAuctionStatus?.label : product.auctionOwnerStatus;
                                if (statusLabel == null || statusLabel.isEmpty) return const SizedBox.shrink();
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                  ),
                                  child: Text(
                                    getTranslated(statusLabel, context)?.toUpperCase() ?? '',
                                    style: titilliumSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                );
                              })
                            ],
                          ),
                        ),
                
                
                
                        if ((product.myAuctionStatus?.isWon == true) && claimDeadline != null && (availableClaimDeadline ?? false)) ...[
                          AuctionWinnerBannerWidget(claimDeadline: claimDeadline, onTimerComplete: _onCountdownComplete),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],

                        if (product.myAuctionStatus?.isLost == true) ...[
                          const AuctionExpiredBannerWidget(),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],

                        if (product.myAuctionStatus?.isFinalizing == true) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeEight),
                            child: const AuctionFinalizingBannerWidget(),
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if (product.myAuctionStatus?.isClaimed == true && product.trackingUrl != null) ...[
                          AuctionTrackOrderWidget(trackingUrl: product.trackingUrl),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if(endTime != null && ((product.auctionStatus?.isLive ?? false) || (product.auctionStatus?.isUpcoming ?? false)))...[
                          AuctionCountdownTimerWidget(endTime: endTime, status: product.auctionStatus, onTimerComplete: _onCountdownComplete),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if (product.myAuctionStatus?.isClaimed == true) ...[
                          AuctionProductImageWidget(
                            productName: ProductHelper.htmlToPlainText(product.name ?? ''),
                            thumbnailUrl: product.thumbnailFullUrl?.path ?? '',
                            itemCondition: product.itemCondition ?? '',
                            totalViews: product.totalViews ?? 0,
                            totalBids: product.totalBidsCount ?? 0,
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ] else ...[
                          ProductImageViewerWidget(
                            images: product.imagesFullUrl != null && product.imagesFullUrl!.isNotEmpty
                                ? product.imagesFullUrl!.map((img) => img.path ?? Images.placeholder).toList()
                                : [Images.placeholder],
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                
                          AuctionStatInfoWidget(product: product),
                
                          AuctionProductInfoWidget(
                            productName: ProductHelper.htmlToPlainText(product.name ?? ''),
                            shippingFee: product.shippingFee ?? 0.00,
                            itemCondition: product.itemCondition ?? '',
                            returnPolicy: product.returnPolicy ?? '',
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if (product.myParticipation != null && product.myParticipation!.entryFeePaymentMethod == 'offline_payment') ...[
                          ParticipateOfflinePaymentDetailsWidget(
                            status: _mapParticipationStatus(product.myParticipation!.entryFeePaymentStatus),
                            participateFee: product.myParticipation!.entryFeePaidAmount ?? 0,
                            deniedNote: product.myParticipation!.entryFeeDeniedNote,
                            methodName: product.myParticipation!.auctionTransaction?.paymentInfo?.methodName,
                            accountNumber: product.myParticipation!.auctionTransaction?.paymentInfo?.methodInformations?.mobileNumber,
                            amount: product.myParticipation!.auctionTransaction?.amount,
                            reference: product.myParticipation!.auctionTransaction?.paymentInfo?.methodInformations?.reference,
                            paymentNote: product.myParticipation!.auctionTransaction?.paymentInfo?.paymentNote,
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],

                        AuctionProductDetailsWidget(
                          title: ProductHelper.htmlToPlainText(product.name ?? ''),
                          description: ProductHelper.htmlToPlainText(product.details ?? ''),
                          videoProvider: product.videoProvider,
                          videoUrl: product.youtubeVideoUrl,
                          customVideoUrl: product.customVideoUrlFullUrl?.path,
                        ),
                        const SizedBox(height: Dimensions.homePagePadding),
                
                        if (product.myAuctionStatus?.isClaimed == true) ...[
                          AuctionParticipantAddressWidget(
                            isSameAsShipping: product.isSameAddress ?? false,
                            shippingName: product.shippingAddressInfo?.contactPersonName ?? '',
                            shippingPhone: product.shippingAddressInfo?.phone ?? '',
                            shippingAddress: product.shippingAddressInfo?.address ?? '',
                            shippingCityZip: [
                              product.shippingAddressInfo?.city,
                              product.shippingAddressInfo?.zip,
                            ].where((e) => e != null && e.isNotEmpty).join(', '),
                            billingName: product.billingAddressInfo?.contactPersonName ?? '',
                            billingPhone: product.billingAddressInfo?.phone ?? '',
                            billingAddress: product.billingAddressInfo?.address ?? '',
                            billingCityZip: [
                              product.billingAddressInfo?.city,
                              product.billingAddressInfo?.zip,
                            ].where((e) => e != null && e.isNotEmpty).join(', '),
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if (product.myAuctionStatus?.isClaimed == true) ...[
                          AuctionPaymentInfoWidget(paymentStatus: paymentInfo?.paymentStatus, paymentMethod: paymentInfo?.paymentMethod ?? '', paidAmount: paymentInfo?.paidAmount ?? 0),
                          const SizedBox(height: Dimensions.homePagePadding),
                          AuctionParticipantBillingInfoWidget(
                            productPrice: billingInfo?.winningBid ?? 0,
                            shippingFee: billingInfo?.shippingFee ?? 0,
                            tax: billingInfo?.taxAmount ?? 0,
                            total: paymentInfo?.paidAmount ?? 0,
                            paymentMethod: paymentInfo?.paymentMethod ?? '',
                            paidAmount: paymentInfo?.paidAmount ?? 0,
                          ),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],
                
                        if (product.auctionStatus?.isLive == true || product.auctionStatus?.isUpcoming == true) ...[
                          AuctionFeatureTagsWidget(),
                          const SizedBox(height: Dimensions.homePagePadding),
                        ],

                        if (product.auctionStatus?.isUpcoming != true) ...[
                          ParticipantBiddingListWidget(
                            productId: product.id ?? 0,
                            myBidsOnly: false,
                          ),
                        ],
                
                        AuctionInsightsWidget(
                          totalBids: product.auctionInsights?.totalBids ?? 0,
                          avgBidIncrease: product.auctionInsights?.avgBidIncrease ??0.00,
                          highestJump: product.auctionInsights?.highestJump ?? 0.00,
                          auctionExpiredAt: product.endTime != null ? DateTime.tryParse(product.endTime!) ?? DateTime.now() : DateTime.now(),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        AuctionPersonWidget(
                          name: product.ownerType == AuctionOwnerType.admin ?
                          (splashController.configModel?.inHouseShop?.name ?? '').trim()
                            : '${product.ownerInfo?.fName ?? ''} ${product.ownerInfo?.lName ?? ''}'.trim(),
                          avatarUrl: product.ownerType == AuctionOwnerType.admin ?
                          (splashController.configModel?.inHouseShop?.imageFullUrl?.path ?? '').trim() : product.ownerInfo?.imageFullUrl?.path ?? '',
                          isOwner: isOwner,
                          showChatIcon: product.ownerType != AuctionOwnerType.customer,
                          onTap: () => RouterHelper.getViewAllAuctionProductScreenRoute(
                            auctionEnum: AuctionEnum.all,
                            ownerId: product.ownerId,
                            ownerName: '${product.ownerInfo?.fName ?? ''} ${product.ownerInfo?.lName ?? ''}'.trim(),
                            action: RouteAction.push,
                          ),
                          onMessageTap: () {
                            if (isGuestMode) {
                              _showNotLoggedInSheet(context);
                              return;
                            }
                            if (product.ownerType == AuctionOwnerType.seller && product.ownerId != null) {
                              Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
                              RouterHelper.getChatScreenRoute(
                                action: RouteAction.push,
                                id: product.ownerId ?? 0,
                                name: '${product.ownerInfo?.fName ?? ''} ${product.ownerInfo?.lName ?? ''}'.trim(),
                                userType: 1,
                                image: product.ownerInfo?.imageFullUrl?.path ?? '',
                              );
                            } else if (product.ownerType == AuctionOwnerType.admin) {
                              Provider.of<ChatController>(context, listen: false).setUserTypeIndex(context, 1);
                              RouterHelper.getChatScreenRoute(
                                action: RouteAction.push,
                                id: 0,
                                name: splashController.configModel?.inHouseShop?.name ?? '',
                                userType: 1,
                                image: splashController.configModel?.inHouseShop?.imageFullUrl?.path ?? '',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: Dimensions.homePagePadding),
                      ],
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AuctionProductHorizontalListWidget(
                      sectionTitle: getTranslated('similar_products', context) ?? '',
                      products: controller.auctionDetails?.similarProducts
                          ?.map(AuctionHorizontalProductItem.fromSimilar).toList() ?? [],
                      onViewAllTap: () {
                        RouterHelper.getViewAllAuctionProductScreenRoute(
                          auctionEnum: AuctionEnum.all,
                          categoryId: product.categoryId,
                          action: RouteAction.push,
                        );
                      },
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: AuctionProductHorizontalListWidget(
                      sectionTitle: getTranslated('auction_from_this_author', context) ?? '',
                      products: controller.auctionDetails?.sameAuthorProducts
                          ?.map(AuctionHorizontalProductItem.fromSameAuthor).toList() ?? [],
                      onViewAllTap: () {
                        RouterHelper.getViewAllAuctionProductScreenRoute(
                          auctionEnum: AuctionEnum.all,
                          ownerId: product.ownerId,
                          ownerName: '${product.ownerInfo?.fName ?? ''} ${product.ownerInfo?.lName ?? ''}'.trim(),
                          action: RouteAction.push,
                        );
                      },
                    ),
                  ),
                ],
               ),
              ),
          ),
        );
      },
    );
  }
  void _handleDeepLinkBack() {
    final bool isAuctionEnabled = Provider.of<SplashController>(context, listen: false)
        .configModel?.isAuctionFeatureEnabled ?? false;
    RouterHelper.getDashboardRoute(
      action: RouteAction.pushNamedAndRemoveUntil,
      page: isAuctionEnabled ? 'auction' : 'home',
    );
  }

  void _onCountdownComplete() {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Provider.of<ParticipationAuctionDetailsController>(context, listen: false)
          .getAuctionProductOverview(
            context,
            slug: widget.slug,
            auctionStatus: widget.auctionStatus?.label,
            silent: true,
          );
    });
  }

  ParticipateOfflinePaymentStatus _mapParticipationStatus(String? status) {
    return switch (status) {
      'verified' || 'approved' => ParticipateOfflinePaymentStatus.approved,
      'denied' => ParticipateOfflinePaymentStatus.denied,
      _ => ParticipateOfflinePaymentStatus.pending,
    };
  }

  void _showNotLoggedInSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => NotLoggedInBottomSheetWidget(
        fromPage: RouterHelper.participationAuctionDetailsScreen,
        onLoginSuccess: () => RouterHelper.getParticipationAuctionDetailsRoute(slug: widget.slug, auctionStatus: widget.auctionStatus),
      ),
    );
  }
}