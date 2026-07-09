import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/confirmation_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_contoller.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/controllers/user_created_auction_list_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/enum/user_created_auction_purchase_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/enum/user_created_auction_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/domain/models/user_created_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/user_created_auction_list/widgets/user_created_auction_list_item_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class UserCreatedAuctionListScreen extends StatefulWidget {
  const UserCreatedAuctionListScreen({super.key});

  @override
  State<UserCreatedAuctionListScreen> createState() => _UserCreatedAuctionListScreenState();
}

class _UserCreatedAuctionListScreenState extends State<UserCreatedAuctionListScreen> {
  final List<UserCreatedAuctionStatusEnum> _statuses = UserCreatedAuctionStatusEnum.values;

  int _selectedTabIndex = 0;

  UserCreatedAuctionStatusEnum get _currentStatus => _statuses[_selectedTabIndex];

  int _countForStatus(UserCreatedAuctionStatusEnum status, AuctionCounts? counts) {
    if (counts == null) return 0;
    switch (status) {
      case UserCreatedAuctionStatusEnum.all:           return counts.total;
      case UserCreatedAuctionStatusEnum.upcoming:      return counts.upcoming;
      case UserCreatedAuctionStatusEnum.live:          return counts.live;
      case UserCreatedAuctionStatusEnum.readyToClaim:  return counts.readyToClaim;
      case UserCreatedAuctionStatusEnum.purchaseComplete: return counts.purchaseComplete;
      case UserCreatedAuctionStatusEnum.readyToDelivery:  return counts.readyToDelivery;
      case UserCreatedAuctionStatusEnum.onTheWay:      return counts.onTheWay;
      case UserCreatedAuctionStatusEnum.delivered:     return counts.delivered;
      case UserCreatedAuctionStatusEnum.unsold:        return counts.unsold;
      case UserCreatedAuctionStatusEnum.canceled:      return counts.canceled;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchList(reload: true);
    });
  }

  void _fetchList({bool reload = false}) {
    context.read<UserCreatedAuctionListController>().getMyAuctionList(_currentStatus, 1, reload: reload);
  }

  void _onTabChanged(int index) {
    if (_selectedTabIndex == index) return;
    setState(() => _selectedTabIndex = index);
    _fetchList(reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('my_auctions', context) ?? '', isBackButtonExist: true),
      body: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Consumer<UserCreatedAuctionListController>(
            builder: (context, controller, _) {
              final AuctionCounts? counts = controller.counts;
              return AuctionTabBarWidget(
                selectedIndex: _selectedTabIndex,
                tabs: _statuses.map((s) {
                  final int count = _countForStatus(s, counts);
                  return '${s.label(context)} ($count)';
                }).toList(),
                onTabChanged: _onTabChanged,
              );
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Expanded(
            child: Consumer<UserCreatedAuctionListController>(
              builder: (context, controller, _) {
                final bool isLoading = controller.isLoading(_currentStatus);
                final UserCreatedAuctionListModel? model = controller.getModel(_currentStatus);
                final List<UserCreatedAuctionProduct> products = model?.products ?? [];

                if (isLoading && products.isEmpty) {
                  return const AuctionListScreenShimmer();
                }

                if (!isLoading && products.isEmpty) {
                  return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_auction_found', context) ?? 'No auctions found');
                }

                return RefreshIndicator(
                  onRefresh: () async => _fetchList(reload: true),
                  child: PaginatedListView(
                    scrollController: null,
                    totalSize: model?.totalSize,
                    offset: model?.offset,
                    limit: 10,
                    onPaginate: (int? offset) =>
                        context.read<UserCreatedAuctionListController>().getMyAuctionList(_currentStatus, offset ?? 1),
                    itemView: Expanded(
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final UserCreatedAuctionProduct product = products[index];
                          final details = product.auctionDetails;

                          final UserCreatedAuctionPurchaseEnum itemStatus = UserCreatedAuctionPurchaseEnum.fromApi(details?.status, details?.deliveryStatus, isRelaunched: product.isRelaunched ?? false);

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.paddingSizeDefault),
                            child: UserCreatedAuctionListItemWidget(
                              auctionStatus: itemStatus,
                              imageUrl: product.thumbnailFullUrl?.path ?? '',
                              slug: product.slug ?? '',
                              auctionId: product.id ?? 0,
                              productName: product.name ?? '',
                              startingPrice: (product.startingPrice ?? 0).toDouble(),
                              participantCount: product.auctionDetails?.totalParticipants ?? 0,
                              totalBidCount: details?.totalBids ?? 0,
                              highestBidAmount: (details?.highestBidAmount ?? 0).toDouble(),
                              targetTime: itemStatus == UserCreatedAuctionPurchaseEnum.upcoming
                                  ? (details?.startTime != null ? DateConverter.isoStringToLocalDate(details!.startTime!) : DateTime.now())
                                  : (details?.endTime != null ? DateConverter.isoStringToLocalDate(details!.endTime!) : DateTime.now()),
                              viewCount: details?.totalViews ?? 0,
                              adminCommission: product.adminCommission ?? 0.0,
                              isAdminCommissionPaid: product.isAdminCommissionPaid ?? false,
                              claimPaymentStatus: product.claimTransaction?.paymentStatus,
                              onRelaunch: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? '', fromDetails: true, isRelaunchMode: true, action: RouteAction.push),
                              onEdit: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? '', fromDetails: true, action: RouteAction.push),
                              onCancel: () => _showCancelConfirmationDialog(context, product.id ?? 0),
                              onDelete: () => _showDeleteConfirmationDialog(context, product.id ?? 0),
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
    );
  }

  void _showCancelConfirmationDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialogWidget(
        icon: Images.warning,
        title: getTranslated('cancel_auction', context) ?? 'Cancel Auction',
        description: getTranslated('are_you_sure_cancel_auction', context) ??
            'Are you sure you want to cancel this auction? This action cannot be undone.',
        onYesPressed: () async {
          Navigator.pop(context);
          final addController = Provider.of<AddAuctionProductController>(context, listen: false);
          final bool success = await addController.cancelAuctionProduct(context, productId: productId);
          if (success) _fetchList(reload: true);
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int productId) {
    showDialog(
      context: context,
      builder: (_) => ConfirmationDialogWidget(
        icon: Images.warning,
        title: getTranslated('delete_auction', context) ?? 'Delete Auction',
        description: getTranslated('are_you_sure_delete_auction', context) ??
            'Are you sure you want to delete this auction? This action cannot be undone.',
        onYesPressed: () async {
          Navigator.pop(context);
          final addController = Provider.of<AddAuctionProductController>(context, listen: false);
          final bool success = await addController.deleteAuctionProduct(context, productId: productId);
          if (success) _fetchList(reload: true);
        },
      ),
    );
  }

}