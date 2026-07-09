import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/controllers/customer_auction_list_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/models/customer_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_item_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyBidsScreen extends StatefulWidget {
  final bool showBackButton;
  final bool fromDashboard;
  final VoidCallback? onLoginSuccess;
  final ValueNotifier<bool>? loginNotifier;
  const MyBidsScreen({super.key, this.showBackButton = true, this.fromDashboard = false, this.onLoginSuccess, this.loginNotifier});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  late bool isGuestMode;

  final List<String?> _auctionStatusFilters = ['participated', 'live', 'won', 'claimed', 'lost', 'claim_expired_lost'];

  @override
  void initState() {
    super.initState();
    isGuestMode = !Provider.of<AuthController>(context, listen: false).isLoggedIn();
    widget.loginNotifier?.addListener(_onLoginChanged);

    if (!isGuestMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchList(isRefresh: true);
      });
    }
  }

  void _onLoginChanged() {
    if (widget.loginNotifier?.value == true && mounted && isGuestMode) {
      setState(() => isGuestMode = false);
      _fetchList(isRefresh: true);
    }
  }

  @override
  void dispose() {
    widget.loginNotifier?.removeListener(_onLoginChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchList({bool isRefresh = false}) {
    final String? auctionStatus = _auctionStatusFilters[_selectedTab];
    Provider.of<CustomerAuctionListController>(context, listen: false).getCustomerAuctionList(context, status: 'all', auctionStatus: auctionStatus, isRefresh: isRefresh);
  }

  void _onTabChanged(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    _fetchList(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.fromDashboard,
      onPopInvokedWithResult: (didPop, _) async {},
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated('my_bids', context) ?? "", isBackButtonExist: widget.showBackButton),
        body: Column(
          children: [
            if (!isGuestMode) ...[
              const SizedBox(height: Dimensions.paddingSizeDefault),
              AuctionTabBarWidget(
                selectedIndex: _selectedTab,
                counts: Provider.of<CustomerAuctionListController>(context).counts?.toCountList(),
                tabs: [
                  getTranslated('participated', context)!,
                  getTranslated('live', context)!,
                  getTranslated('won', context)!,
                  getTranslated('claimed', context)!,
                  getTranslated('lost', context)!,
                  getTranslated('claim_expired', context)!
                ],
                onTabChanged: _onTabChanged,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            Expanded(
              child: isGuestMode
                ? NotLoggedInWidget(
                    message: getTranslated('to_view_my_bids', context),
                    fromPage: RouterHelper.myBidsScreen,
                    backPage: 'auction',
                    onLoginSuccess: () {
                      if (mounted) {
                        setState(() => isGuestMode = false);
                        _fetchList(isRefresh: true);
                      }
                      widget.onLoginSuccess?.call();
                    },
                  )
                : Consumer<CustomerAuctionListController>(
                    builder: (context, controller, _) {
                      if (controller.isLoading && controller.auctionList.isEmpty) {
                        return const AuctionListScreenShimmer();
                      }

                      if (!controller.isLoading && controller.auctionList.isEmpty) {
                        return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_auction_found', context) ?? 'No auctions found');
                      }

                      return RefreshIndicator(
                        onRefresh: () async => _fetchList(isRefresh: true),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: PaginatedListView(
                            scrollController: _scrollController,
                            totalSize: controller.totalSize,
                            offset: controller.currentOffset,
                            limit: 10,
                            onPaginate: (_) => controller.loadMore(context),
                            itemView: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.auctionList.length,
                              itemBuilder: (context, index) {
                                final CustomerAuctionProduct product = controller.auctionList[index];
                                final bool isLive = product.auctionStatus?.isLive == true;
                                final bool showBidActions = (product.auctionStatus?.isLive == true) && product.hasMyBid;

                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: Dimensions.homePagePadding,
                                    right: Dimensions.homePagePadding,
                                    bottom: Dimensions.paddingSizeEight,
                                  ),
                                  child: AuctionListItemWidget(
                                    state: isLive ? AuctionCardState.live : AuctionCardState.upcoming,
                                    imageUrl: product.thumbnailFullUrl?.path ?? '',
                                    slug: product.slug ?? '',
                                    auctionId: product.id ?? 0,
                                    productName: product.name ?? '',
                                    startingPrice: product.startingPrice ?? 0,
                                    highestBidAmount: product.highestBidAmount ?? 0,
                                    targetTime: product.endTime != null ? DateConverter.isoStringToLocalDate(product.endTime!) : DateTime.now(),
                                    viewCount: product.totalViews ?? 0,
                                    bidCount: product.totalParticipantsCount,
                                    isOutbid: product.isOutbid,
                                    hasBid: product.myBid != null,
                                    auctionStatus: product.auctionStatus,
                                    currentAuctionStatus: product.currentAuctionStatus,
                                    trackingUrl: product.trackingUrl,
                                    onBidTap: () {
                                      RouterHelper.getParticipationAuctionDetailsRoute(
                                        slug: product.slug ?? '',
                                        auctionStatus: product.auctionStatus,
                                        action: RouteAction.push,
                                        openBidSheet: true,
                                      );
                                    },
                                    onWithdrawBidTap: showBidActions
                                        ? () => Provider.of<AuctionParticipationController>(context, listen: false).withdrawAuctionBid(context, auctionProductId: product.id ?? 0) : null,
                                    onClaimTap: _selectedTab == 5 ? null : () {
                                      RouterHelper.getAuctionCheckoutRoute(
                                        productId: product.id ?? 0,
                                        myBidAmount: product.highestBidAmount ?? 0,
                                        highestBidAmount: product.highestBidAmount ?? 0,
                                        startingPrice: product.startingPrice ?? 0,
                                        shippingFee: product.shippingFee ?? 0,
                                        tax: product.totalTaxAmount ?? 0,
                                        action: RouteAction.push,
                                      );
                                    },
                                    onTrackOrderTap: () async {
                                      final String trackingUrl = product.trackingUrl ?? '';
                                      final uri = Uri.parse(trackingUrl);
                                      if (await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
