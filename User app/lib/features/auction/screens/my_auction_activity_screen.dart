import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_item_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/controllers/auction_home_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_home/domain/models/recently_viewed_auction_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

AuctionCardState _cardState(AuctionDetails? details) {
  return details?.status == 'upcoming' ? AuctionCardState.upcoming : AuctionCardState.live;
}

DateTime _targetTime(AuctionDetails? details) {
  final isLive = details?.status != 'upcoming';
  final raw = isLive ? details?.endTime : details?.startTime;
  return raw != null ? DateTime.tryParse(raw) ?? DateTime.now() : DateTime.now();
}


class MyAuctionActivityScreen extends StatefulWidget {
  final bool isBackButtonExist;
  final bool fromDashboard;
  final VoidCallback? onLoginSuccess;
  final ValueNotifier<bool>? loginNotifier;

  const MyAuctionActivityScreen({
    super.key,
    this.isBackButtonExist = true,
    this.fromDashboard = false,
    this.onLoginSuccess,
    this.loginNotifier,
  });

  @override
  State<MyAuctionActivityScreen> createState() => _MyAuctionActivityScreenState();
}

class _MyAuctionActivityScreenState extends State<MyAuctionActivityScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
    widget.loginNotifier?.addListener(_onLoginChanged);
    if (_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchData(isUpdate: false);
      });
    }
  }

  void _onLoginChanged() {
    if (widget.loginNotifier?.value == true && mounted && !_isLoggedIn) {
      setState(() => _isLoggedIn = true);
      _fetchData(isUpdate: false);
    }
  }

  Future<void> _fetchData({bool isUpdate = true}) async {
    await Provider.of<AuctionHomeController>(context, listen: false).getRecentlyViewedAuctionList(offset: 1, isUpdate: isUpdate, isLoggedIn: true);
  }

  void _onLoginSuccess() {
    if (mounted) {
      setState(() => _isLoggedIn = true);
      _fetchData(isUpdate: false);
    }
    widget.onLoginSuccess?.call();
  }

  @override
  void dispose() {
    widget.loginNotifier?.removeListener(_onLoginChanged);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<ThemeController>(context).darkTheme;

    return Scaffold(
      backgroundColor: isDarkTheme ? Theme.of(context).scaffoldBackgroundColor : null,
      appBar: CustomAppBar(
        title: !_isLoggedIn
            ? getTranslated('my_activity', context) ?? ''
            : '${getTranslated('my_activity', context)} (${Provider.of<AuctionHomeController>(context).recentlyViewedModel?.totalSize ?? 0})',
        isBackButtonExist: false,
      ),
      body: !_isLoggedIn
          ? NotLoggedInWidget(
        message: getTranslated('to_view_my_activity', context),
        fromPage: RouterHelper.myAuctionActivityScreen,
        backPage: 'auction',
        onLoginSuccess: _onLoginSuccess,
      )
          : Consumer<AuctionHomeController>(
        builder: (context, controller, child) {
          final recentlyViewedModel = controller.recentlyViewedModel;

          if (recentlyViewedModel == null) {
            return const AuctionListScreenShimmer();
          }

          final products = recentlyViewedModel.recentViews ?? [];

          if (products.isEmpty) {
            return const NoInternetOrDataScreenWidget(isNoInternet: false);
          }

          final double bottomNavHeight =  MediaQuery.of(context).padding.bottom;

          return RefreshIndicator(
            onRefresh: _fetchData,
            child: PaginatedListView(
              scrollController: _scrollController,
              totalSize: recentlyViewedModel.totalSize,
              offset: recentlyViewedModel.offset,
              onPaginate: (int? offset) async {
                await controller.getRecentlyViewedAuctionList(offset: offset ?? 1, isLoggedIn: true);
              },
              itemView: Expanded(
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  itemCount: products.length + 1,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  itemBuilder: (context, index) {
                    if (index == products.length) {
                      return SizedBox(height: bottomNavHeight);
                    }
                    final item = products[index];
                    final product = item.auctionProduct;
                    return AuctionListItemWidget(
                      slug: product?.slug ?? '',
                      state: _cardState(product?.auctionDetails),
                      imageUrl: product?.thumbnailFullUrl?.path ?? '',
                      auctionId: product?.id ?? 0,
                      productName: product?.name ?? '',
                      startingPrice: product?.startingPrice?.toDouble() ?? 0.0,
                      highestBidAmount: product?.auctionDetails?.highestBidAmount?.toDouble() ?? 0.0,
                      targetTime: _targetTime(product?.auctionDetails),
                      viewCount: product?.auctionDetails?.totalViews ?? 0,
                      bidCount: product?.auctionDetails?.totalBids,
                      auctionStatus: product?.auctionStatus,
                      currentAuctionStatus: product?.currentAuctionStatus,
                      trackingUrl: product?.trackingUrl,
                      onBidTap: () {
                        RouterHelper.getParticipationAuctionDetailsRoute(
                          slug: product?.slug ?? '',
                          auctionStatus: product?.auctionStatus,
                          action: RouteAction.push,
                          openBidSheet: true,
                        );
                      },
                      onClaimTap: () {
                        RouterHelper.getAuctionCheckoutRoute(
                          productId: item.auctionProductId ?? 0,
                          myBidAmount: product?.auctionDetails?.highestBidAmount?.toDouble() ?? 0,
                          highestBidAmount: product?.auctionDetails?.highestBidAmount?.toDouble() ?? 0,
                          startingPrice: product?.startingPrice?.toDouble() ?? 0,
                          shippingFee: product?.shippingFee ?? 0,
                          tax: product?.totalTaxAmount ?? 0,
                          action: RouteAction.push,
                        );
                      },
                      onTrackOrderTap: () async {
                        final String trackingUrl = product?.trackingUrl ?? '';
                        final uri = Uri.parse(trackingUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}