import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/withdraw_request_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/payment_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/creator/creator_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/enum/creator/auction_delivery_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/admin_commission_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_admin_commission_payment_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_creator_address_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_countdown_timer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_details_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_insights_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_payment_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_product_details_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_timeline_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/creator_bidding_list_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_details_bottom_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/creator_auction_deatils_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/product_seo_metadata_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/rejected_note_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/upload_tracking_url_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/withdrawl_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_contoller.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/enum/creator_auction_details_route_action.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/confirmation_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/product_helper.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class CreatorAuctionDetailsScreen extends StatefulWidget {
  static String? activeSlug;

  final bool isNotification;
  final String slug;
  final CreatorAuctionDetailsRouteAction? routeAction;

  const CreatorAuctionDetailsScreen({super.key, this.isNotification = false, required this.slug, this.routeAction});

  @override
  State<CreatorAuctionDetailsScreen> createState() => _CreatorAuctionDetailsScreenState();
}

class _CreatorAuctionDetailsScreenState extends State<CreatorAuctionDetailsScreen> {

  @override
  void initState() {
    super.initState();
    CreatorAuctionDetailsScreen.activeSlug = widget.slug;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Provider.of<CreatorAuctionDetailsController>(context, listen: false);
      await controller.getAuctionDetails(context, widget.slug);

      if (!mounted) return;
      if (widget.routeAction == null) return;

      switch (widget.routeAction!) {
        case CreatorAuctionDetailsRouteAction.payCommission:
          final commission = controller.commissionAmountToPayToAdmin;
          if (commission != null) {
            AuctionAdminCommissionBottomSheetWidget.show(
              context, auctionId: controller.auctionProductId ?? 0, adminCommission: commission,
              onSuccess: () => controller.getAuctionDetails(context, widget.slug),
            );
          }
          break;
        case CreatorAuctionDetailsRouteAction.withdraw:
          WithdrawRequestBottomSheetWidget.show(
            context, amount: controller.withdrawableAmount ?? 0.0, auctionProductId: controller.auctionProductId ?? 0,
            onSuccess: () => controller.getAuctionDetails(context, widget.slug),
          );
          break;
      }
    });
  }

  @override
  void dispose() {
    CreatorAuctionDetailsScreen.activeSlug = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatorAuctionDetailsController>(
      builder: (context, controller, _) {
        final product = controller.auctionProduct;
        final auctionState = product?.auctionState ?? UserCreatedAuctionEnum.pending;

        final List<CreatorBidListItem> bids = [];

        if (controller.bidListModel?.bids != null && controller.bidListModel!.bids!.isNotEmpty) {
          bids.addAll(
              controller.bidListModel!.bids!.asMap().entries.map((entry) {
                final index = entry.key;
                final bid = entry.value;
                return CreatorBidListItem(
                  rank: index + 1,
                  name: '${bid.customer?.fName ?? ''} ${bid.customer?.lName ?? ''}',
                  timeAgo: bid.bidTime ?? '',
                  bidAmount: PriceConverter.convertPrice(context, double.parse(bid.bidAmount?.toString() ?? '0')),
                  avatarUrl: bid.customer?.imageFullUrl?.path ?? '',
                  isLeading: bid.isLeadBid ?? false,
                  isWithdrawBid: bid.isWithdrawBid ?? false,
                  isCurrentUser: bid.isMyBid ?? false,
                  isWinner: (bid.userContext?.isWinner ?? false) && !(bid.userContext?.isClaimExpired ?? false) && (bid.isLeadBid ?? false) && (bid.isMyBid ?? false),
                  isClaimExpired: (bid.userContext?.isWinner ?? false) && (bid.userContext?.isClaimExpired ?? false) && (bid.isLeadBid ?? false) && (bid.isMyBid ?? false),
                );
              }).toList()
          );
        }

        final payment = product?.transactions?.firstWhere((t) => t.type == 'auction_payment', orElse: () => AuctionTransaction());


        return PopScope(
          canPop: !widget.isNotification && Navigator.canPop(context),
          onPopInvokedWithResult: (didPop, result) async {
            if (widget.isNotification) {
              RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil, page: 'auction');
            }
          },
          child: Scaffold(
            appBar: CustomAppBar(
              title: getTranslated('auction_details', context) ?? "",
              centerTitle: false,
              onBackPressed: widget.isNotification
                  ? () => RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil, page: 'auction') : null,
            ),

            bottomNavigationBar: controller.isLoading || product == null || controller.isAdminCommissionPaid ? null
                : AuctionDetailsBottomBarWidget(
              auctionState: auctionState,
              totalBidCount: product.totalBidsCount ?? 0,
              isCashOnDelivery: controller.isCashOnDeliveryCommission,
              hasExistingWithdraw: controller.auctionWithdraw != null,
              isWithdrawDisabled: payment?.paymentStatus == PaymentStatus.unpaid.label,
              onCancel: _showDeleteConfirmationDialog,
              onEdit: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? widget.slug, initialProduct: controller.auctionProduct, fromDetails: true, action: RouteAction.push),
              onRelaunch: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? widget.slug, initialProduct: controller.auctionProduct, fromDetails: true, isRelaunchMode: true, action: RouteAction.push),
              onPayNow: () {
                AuctionAdminCommissionBottomSheetWidget.show(
                  context,
                  auctionId: product.id ?? 0,
                  adminCommission: controller.commissionAmountToPayToAdmin ?? 0.0,
                  onSuccess: () => Provider.of<CreatorAuctionDetailsController>(context, listen: false)
                      .getAuctionDetails(context, widget.slug),
                );
              },
              onWithdraw: () => WithdrawRequestBottomSheetWidget.show(
                context,
                amount: controller.withdrawableAmount ?? 0.0,
                auctionProductId: product.id ?? 0,
                onSuccess: () => Provider.of<CreatorAuctionDetailsController>(context, listen: false)
                    .getAuctionDetails(context, widget.slug),
              ),
              onDeliveryStatusUpdate: (AuctionDeliveryStatus status) async {
                final success = await Provider.of<CreatorAuctionDetailsController>(context, listen: false).updateDeliveryStatus(product.id ?? 0, status);

                if (success && mounted) {
                  await Provider.of<CreatorAuctionDetailsController>(context, listen: false).getAuctionDetails(context, widget.slug);
                }
              },
            ),
            body: controller.isLoading ? const CreatorAuctionDetailsScreenShimmer()
                : product == null ? NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_auction_found', context) ?? 'No auctions found')
              : RefreshIndicator(
              onRefresh: () async {
                await Provider.of<CreatorAuctionDetailsController>(context, listen: false).getAuctionDetails(context, widget.slug);},
                child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: Dimensions.paddingSizeSmall),
                        AuctionStatusHeaderWidget(productId: product.id ?? 0, auctionState: auctionState),

                        if (auctionState == UserCreatedAuctionEnum.rejected) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          RejectedNoteWidget(note: product.rejectedNote ?? ''),
                        ],

                        if (auctionState == UserCreatedAuctionEnum.delivered) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          if (controller.isCashOnDeliveryCommission)
                            AuctionAdminCommissionPaymentWidget(
                              adminCommissionAmount: controller.commissionAmountToPayToAdmin ?? 0.0,
                              isPaid: controller.isAdminCommissionPaid,
                              paymentInfo: controller.codCommissionTransaction?.paymentInfo,
                            )
                          else ...[
                            Builder(builder: (context) {
                              final withdraw = controller.auctionWithdraw;
                              final state = _mapWithdrawStatus(withdraw?.status);
                              final info = withdraw != null
                                  ? WithdrawInfo(fields: Map<String, dynamic>.from(withdraw.withdrawalMethodFields ?? {})) : null;
                              final amount = withdraw?.amount ?? controller.withdrawableAmount ?? 0.0;
                              return WithdrawalCardWidget(
                                state: state,
                                amount: amount,
                                withdrawInfo: info,
                                adminNote: withdraw?.transactionNote,
                                onWithdrawPressed: withdraw != null ? null : () => WithdrawRequestBottomSheetWidget.show(
                                  context,
                                  amount: controller.withdrawableAmount ?? 0.0,
                                  auctionProductId: product.id ?? 0,
                                  onSuccess: () => Provider.of<CreatorAuctionDetailsController>(context, listen: false)
                                      .getAuctionDetails(context, widget.slug),
                                ),
                                onEditPressed: withdraw == null ? null : () => WithdrawRequestBottomSheetWidget.show(
                                  context,
                                  amount: withdraw.amount ?? controller.withdrawableAmount ?? 0.0,
                                  auctionProductId: product.id ?? 0,
                                  existingWithdrawId: withdraw.id,
                                  initialMethodId: withdraw.withdrawalMethodId,
                                  initialFieldValues: withdraw.withdrawalMethodFields,
                                  onSuccess: () => Provider.of<CreatorAuctionDetailsController>(context, listen: false)
                                      .getAuctionDetails(context, widget.slug),
                                ),
                              );
                            }),
                          ],
                        ],

                        if (auctionState == UserCreatedAuctionEnum.live) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          AuctionCountdownTimerWidget(endTime: DateConverter.isoStringToLocalDate(product.endTime!)),
                        ],

                        if ([
                          UserCreatedAuctionEnum.purchaseComplete,
                          UserCreatedAuctionEnum.readyToDelivery,
                          UserCreatedAuctionEnum.onTheWay,
                          UserCreatedAuctionEnum.delivered,
                        ].contains(auctionState)) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          AuctionCreatorAddressWidget(
                            shippingName: product.shippingAddressInfo?.contactPersonName ?? '',
                            shippingPhone: product.shippingAddressInfo?.phone ?? '',
                            shippingCityZip: '${product.shippingAddressInfo?.city ?? ''} ${product.shippingAddressInfo?.zip ?? ''}',
                            shippingAddress: product.shippingAddressInfo?.address ?? '',
                            billingName: product.billingAddressInfo?.contactPersonName ?? '',
                            billingPhone: product.billingAddressInfo?.phone ?? '',
                            billingCityZip: '${product.billingAddressInfo?.city ?? ''} ${product.billingAddressInfo?.zip ?? ''}',
                            billingAddress: product.billingAddressInfo?.address ?? '',
                            isSameAsShipping: product.isSameAddress ?? false,
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          UploadTrackingUrlWidget(
                            initialUrl: product.trackingUrl,
                            onSave: (url) async {
                              return await Provider.of<CreatorAuctionDetailsController>(
                                context,
                                listen: false,
                              ).uploadTrackingUrl(product.id ?? 0, url);
                            },
                          ),
                        ],

                        if ([
                          UserCreatedAuctionEnum.purchaseComplete,
                          UserCreatedAuctionEnum.readyToDelivery,
                          UserCreatedAuctionEnum.onTheWay,
                          UserCreatedAuctionEnum.delivered,
                        ].contains(auctionState)) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          AuctionPaymentInfoWidget(
                            paymentStatus: payment?.paymentStatus == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid,
                            paymentMethod: payment?.paymentMethod ?? '',
                            paidAmount: payment?.amount ?? 0,
                          ),
                        ],

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        AuctionDetailInfoWidget(
                          auctionState: auctionState,
                          imageUrl: product.thumbnailFullUrl?.path ?? '',
                          productName: ProductHelper.htmlToPlainText(product.name ?? ''),
                          productType: product.productType ?? '',
                          brand: product.brand?.name ?? '',
                          category: product.category?.name ?? '',
                          itemCondition: product.itemCondition ?? '',
                          startingPrice: product.startingPrice ?? 0,
                          minIncrement: product.minimumIncrementAmount ?? 0,
                          maximumDecrement: product.maximumDecrementAmount ?? 0,
                          minBidAmount: product.minBidAmount,
                          shippingFee: product.shippingFee ?? 0,
                          taxVats: product.taxVats,
                          auctionStart: product.startTime != null ? DateConverter.isoStringToLocalDate(product.startTime!) : DateTime.now(),
                          auctionEnd: product.endTime != null ? DateConverter.isoStringToLocalDate(product.endTime!) : DateTime.now(),
                          returnPolicy: product.returnPolicy ?? '',
                          highestBid: product.highestBidAmount ?? 0.0,
                          totalView: product.totalViews ?? 0,
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        AuctionProductDetailsWidget(
                          title: ProductHelper.htmlToPlainText(product.name ?? ''),
                          description: ProductHelper.htmlToPlainText(product.details ?? ''),
                          videoProvider: product.videoProvider,
                          videoUrl: product.youtubeVideoUrl,
                          customVideoUrl: product.customVideoUrlFullUrl?.path,
                        ),

                        if (auctionState == UserCreatedAuctionEnum.live || auctionState == UserCreatedAuctionEnum.purchaseComplete) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          CreatorBiddingListWidget(bids: bids, productId: product.id ?? 0),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          AuctionInsightsWidget(
                            totalBids: product.totalBidsCount ?? 0,
                            avgBidIncrease: product.minimumIncrementAmount ?? 0.00,
                            highestJump: product.highestBidAmount ?? 0.00,
                            auctionExpiredAt: product.endTime != null ? DateTime.tryParse(product.endTime!) ?? DateTime.now() : DateTime.now(),
                          ),
                        ],

                        if (product.seoInfo != null && (auctionState == UserCreatedAuctionEnum.pending || auctionState == UserCreatedAuctionEnum.rejected)) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          ProductSeoMetaDataWidget(
                            seoTitle: product.seoInfo?.title ?? '',
                            metaDescription: product.seoInfo?.description ?? '',
                            imageUrl: product.metaImageFullUrl?.path ?? Images.aboutUs,
                          ),
                        ],

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        AuctionTimelineWidget(
                          entries: [
                            if (product.createdAt != null)
                              AuctionTimelineEntry(
                                label: 'Auction Created At',
                                dateTime: DateConverter.isoStringToLocalDate(product.createdAt!),
                              ),
                            if (product.updatedAt != null)
                              AuctionTimelineEntry(
                                label: 'Auction Modified At',
                                dateTime: DateConverter.isoStringToLocalDate(product.updatedAt!),
                              ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                    ),
                  ),
                ]),
              ),
          ),
        );
      },
    );
  }

  WithdrawState _mapWithdrawStatus(String? status) {
    return switch (status) {
      'pending'  => WithdrawState.requested,
      'approved' => WithdrawState.approved,
      'denied'   => WithdrawState.denied,
      _          => WithdrawState.pending,
    };
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialogWidget(
        icon: Images.warning,
        title: getTranslated('delete_auction', context) ?? 'Delete Auction',
        description: getTranslated('are_you_sure_delete_auction', context) ??
            'Are you sure you want to delete this auction? This action cannot be undone.',
        onYesPressed: () async {
          Navigator.pop(context);
          final controller = Provider.of<AddAuctionProductController>(context, listen: false);
          final detailsController = Provider.of<CreatorAuctionDetailsController>(context, listen: false);
          final bool success = await controller.deleteAuctionProduct(context, productId: detailsController.auctionProductId ?? 0);
          if (success) {
            RouterHelper.getAuctionQueueListRoute(action: RouteAction.pushReplacement);
          }
        },
      ),
    );
  }
}

class AuctionStatusHeaderWidget extends StatelessWidget {
  final int productId;
  final UserCreatedAuctionEnum? auctionState;

  const AuctionStatusHeaderWidget({
    super.key,
    required this.productId,
    required this.auctionState,
  });

  Color _badgeColor(BuildContext context) {
    return switch (auctionState) {
      UserCreatedAuctionEnum.rejected => Theme.of(context).colorScheme.error,
      UserCreatedAuctionEnum.live => Theme.of(context).colorScheme.error,
      UserCreatedAuctionEnum.purchaseComplete ||
      UserCreatedAuctionEnum.delivered => Theme.of(context).colorScheme.onTertiaryContainer,
      _ => Theme.of(context).primaryColor,
    };
  }


  String _label(BuildContext context) {
    return switch (auctionState) {
      UserCreatedAuctionEnum.pending => getTranslated('pending', context) ?? '',
      UserCreatedAuctionEnum.rejected => getTranslated('rejected', context) ?? '',
      UserCreatedAuctionEnum.upcoming => getTranslated('upcoming', context) ?? '',
      UserCreatedAuctionEnum.live => getTranslated('live', context) ?? '',
      UserCreatedAuctionEnum.readyToClaim => getTranslated('ready_to_claim', context) ?? '',
      UserCreatedAuctionEnum.purchaseComplete => getTranslated('purchase_complete', context) ?? '',
      UserCreatedAuctionEnum.unsold => getTranslated('unsold', context) ?? '',
      UserCreatedAuctionEnum.canceled => getTranslated('canceled', context) ?? '',
      UserCreatedAuctionEnum.readyToDelivery => getTranslated('ready_to_delivery', context) ?? '',
      UserCreatedAuctionEnum.onTheWay => getTranslated('on_the_way', context) ?? '',
      UserCreatedAuctionEnum.delivered => getTranslated('delivered', context) ?? '',
      null => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(text: '${getTranslated('auction_id', context) ?? ""} ',
                style: titleRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                children: [
                  TextSpan(text: '#$productId',
                    style: titleRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              color: _badgeColor(context),
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Text(_label(context),
              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

