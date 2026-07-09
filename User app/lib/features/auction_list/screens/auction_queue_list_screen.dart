import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/confirmation_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_approval_status_enum.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/user_created_auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_contoller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_tab_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/controllers/auction_product_queue_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/domain/models/auction_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_list/widgets/auction_queue_item_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/widgets/auction_queue_item_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionQueueListScreen extends StatefulWidget {
  final bool? fromNotification;
  const AuctionQueueListScreen({super.key, this.fromNotification = false});

  @override
  State<AuctionQueueListScreen> createState() => _AuctionQueueListScreenState();
}

class _AuctionQueueListScreenState extends State<AuctionQueueListScreen> {
  final ScrollController _scrollController = ScrollController();
  AuctionApprovalStatus selectedStatus = AuctionApprovalStatus.pending;

  final List<AuctionApprovalStatus> _visibleStatuses = AuctionApprovalStatus.values
      .where((status) => status != AuctionApprovalStatus.approved)
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(isReload: true);
    });
  }

  void _loadData({bool isReload = false}) {
    final controller = Provider.of<AuctionProductQueueController>(context, listen: false);
    controller.getAuctionProductList(selectedStatus, 1, reload: isReload);
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
          if (success) _loadData(isReload: true);
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (widget.fromNotification!) {
          /// TODO: Navigation
        } else {
          if (!didPop) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: getTranslated('auction_request', context) ?? 'Auction Request',
        ),
        floatingActionButton: (Provider.of<SplashController>(context, listen: false).configModel?.isAuctionFeatureEnabled == true) &&
            (Provider.of<SplashController>(context, listen: false).configModel?.isActiveAuctionForCustomer == true)
            ? FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).cardColor,
                onPressed: () => RouterHelper.getAddEditAuctionProductRoute(action: RouteAction.push),
                child: Image.asset(Images.addIcon, width: Dimensions.iconSizeLarge),
              ) : null,
        body: Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeTwelve),

                Consumer<AuctionProductQueueController>(
                  builder: (context, queueController, _) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: AuctionTabBarWidget(
                      selectedIndex: _visibleStatuses.indexOf(selectedStatus),
                      tabs: _visibleStatuses.map((status) => status.label(context)).toList(),
                      counts: _visibleStatuses.map((s) => queueController.countFor(s)).toList(),
                      onTabChanged: (index) {
                        setState(() {
                          selectedStatus = _visibleStatuses[index];
                        });
                        _loadData(isReload: true);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeTwelve),

                Expanded(
                  child: Consumer<AuctionProductQueueController>(
                    builder: (context, controller, _) {
                      final bool isLoading = controller.isLoading(selectedStatus);
                      final AuctionProductListModel? model = controller.getModel(selectedStatus);

                      if (isLoading || model == null) {
                        return const AuctionQueueListShimmerWidget();
                      }

                      final List<AuctionProduct>? products = model.products;

                      if (products == null || products.isEmpty) {
                        return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_auction_found', context) ?? 'No auctions found');
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _loadData(isReload: true);
                        },
                        child: SingleChildScrollView(
                          child: PaginatedListView(
                            scrollController: _scrollController,
                            totalSize: model.totalSize,
                            offset: model.offset,
                            onPaginate: (offset) async {
                              await controller.getAuctionProductList(selectedStatus, offset ?? 1);
                            },
                            itemView: ListView.builder(
                              controller: _scrollController,
                              itemCount: products.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final product = products[index];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall,
                                  ),
                                  child: AuctionQueueItemWidget(
                                    auctionId: product.id.toString(),
                                    productName: product.name ?? '',
                                    startingPrice: product.startingPrice?.toDouble(),
                                    categoryName: product.category?.name ?? '',
                                    thumbnailFullUrl: product.thumbnailFullUrl?.path ?? '',
                                    auctionState: UserCreatedAuctionEnum.resolve(
                                      approvalStatus: product.approvalStatus,
                                      auctionStatus: product.auctionStatus,
                                      deliveryStatus: null,
                                    ),
                                    onTap: () => RouterHelper.getCreatorAuctionDetailsRoute(slug: product.slug ?? '', action: RouteAction.push),
                                    onMoreTap: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? '', fromDetails: true, action: RouteAction.push),
                                    onRelaunch: () => RouterHelper.getAddEditAuctionProductRoute(productId: product.id ?? 0, slug: product.slug ?? '', fromDetails: true, isRelaunchMode: true, action: RouteAction.push),
                                    onCancel: () => _showDeleteConfirmationDialog(context, product.id ?? 0),
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

class AuctionQueueListShimmerWidget extends StatelessWidget {
  final int itemCount;

  const AuctionQueueListShimmerWidget({
    super.key,
    this.itemCount = 15,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeSmall,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).cardColor,
          highlightColor: Colors.grey[300]!,
          enabled: true,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: AuctionQueueItemShimmerWidget(),
          ),
        );
      },
    );
  }
}