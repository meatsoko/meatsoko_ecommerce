import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/controllers/customer_auction_list_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/domain/models/saved_auction_list_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_list_screen_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction/widgets/auction_save_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionSaveListScreen extends StatefulWidget {
  const AuctionSaveListScreen({super.key,});

  @override
  State<AuctionSaveListScreen> createState() => _AuctionSaveListScreenState();
}

class _AuctionSaveListScreenState extends State<AuctionSaveListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerAuctionListController>(context, listen: false).getCustomerSavedAuctionList(context, isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {},
      child: Scaffold(
        appBar: CustomAppBar(title: getTranslated('saved_auctions', context) ?? "Saved Auctions"),
        body: Column(
          children: [
            Expanded(
              child: Consumer<CustomerAuctionListController>(
                builder: (context, controller, _) {

                  if (controller.isSavedLoading && controller.savedAuctionList.isEmpty) {
                    return const AuctionListScreenShimmer();
                  }

                  if (!controller.isSavedLoading && controller.savedAuctionList.isEmpty) {
                    return NoInternetOrDataScreenWidget(isNoInternet: false, message: getTranslated('no_saved_auction_found', context) ?? 'No saved auctions found');
                  }

                  return RefreshIndicator(
                    onRefresh: () async => controller.getCustomerSavedAuctionList(context, isRefresh: true),
                    child: PaginatedListView(
                      scrollController: _scrollController,
                      totalSize: controller.savedAuctionList.length + (controller.hasSavedMore ? 1 : 0),
                      offset: controller.savedOffset,
                      limit: 10,
                      onPaginate: (_) => controller.loadMoreSaved(context),
                      itemView: Expanded(
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: controller.savedAuctionList.length,
                          itemBuilder: (context, index) {
                            final SavedAuctionProduct saved =
                            controller.savedAuctionList[index];
                            final AuctionProductSummary? product = saved.auctionProduct;

                            final DateTime now = DateTime.now();
                            final DateTime? endTime = product?.endTime != null ? DateConverter.isoStringToLocalDate(product!.endTime!) : null;
                            final DateTime? startTime = product?.startTime != null ? DateConverter.isoStringToLocalDate(product!.startTime!) : null;
                            final bool isLive = startTime != null && endTime != null && now.isAfter(startTime) && now.isBefore(endTime);

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeExtraSmall),
                              child: AuctionSaveCardWidget(
                                state: isLive ? AuctionCardState.live : AuctionCardState.upcoming,
                                imageUrl: product?.thumbnailFullUrl?.path ?? '',
                                slug: product?.slug ?? '',
                                productName: product?.name ?? '',
                                startingPrice: product?.startingPrice ?? 0,
                                highestBidAmount: product?.highestBid ?? 0,
                                targetTime: endTime ?? now,
                                viewCount: product?.totalViews ?? 0,
                                bidCount: product?.bidsCount,
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