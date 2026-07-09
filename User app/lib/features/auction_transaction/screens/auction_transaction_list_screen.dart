import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_icon_search_field_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/filter_icon_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/widgets/auction_transaction_filter_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/widgets/auction_transaction_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/widgets/auction_transaction_tile_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/debounce_helper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';


class AuctionTransactionListScreen extends StatefulWidget {
  const AuctionTransactionListScreen({super.key});

  @override
  State<AuctionTransactionListScreen> createState() => _AuctionTransactionListScreenState();
}

class _AuctionTransactionListScreenState extends State<AuctionTransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DebounceHelper _debounce = DebounceHelper(milliseconds: 500);
  final ScrollController _scrollController = ScrollController();
  int? _searchAuctionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuctionTransactionController>(context, listen: false).getAuctionTransactionList(context, isRefresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce.run(() {
      _searchAuctionId = int.tryParse(query.trim());
      Provider.of<AuctionTransactionController>(context, listen: false).getAuctionTransactionList(context, isRefresh: true, searchAuctionId: _searchAuctionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated('auction_transactions', context) ?? 'Auction Transactions',
        actions: [
          Consumer<AuctionTransactionController>(
            builder: (context, controller, _) => Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
              child: FilterIconWidget(
                filterCount: controller.activeFilterCount,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AuctionTransactionFilterBottomSheetWidget(searchAuctionId: _searchAuctionId),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            child: CustomIconSearchFieldWidget(
              controller: _searchController,
              hint: getTranslated('search_by_auction_id', context) ?? 'Search by auction ID',
              prefix: Images.iconsSearch,
              keyboardType: TextInputType.number,
              iconPressed: () => _onSearchChanged(_searchController.text),
              onSubmit: (text) => _onSearchChanged(text),
              onChanged: (value) => _onSearchChanged(value as String),
              onClear: () {
                _searchAuctionId = null;
                Provider.of<AuctionTransactionController>(context, listen: false).getAuctionTransactionList(context, isRefresh: true);
              },
            ),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          Expanded(
            child: Consumer<AuctionTransactionController>(
              builder: (context, controller, _) {
                if (controller.isLoading && controller.transactions.isEmpty) {
                  return const AuctionTransactionShimmerWidget();
                }

                if (controller.transactions.isEmpty) {
                  return Center(
                    child: Text(
                      getTranslated('no_transaction_found', context) ?? 'No transactions found',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.getAuctionTransactionList(
                    context,
                    isRefresh: true,
                    searchAuctionId: _searchAuctionId,
                  ),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: PaginatedListView(
                      scrollController: _scrollController,
                      totalSize: controller.totalSize,
                      offset: controller.offset,
                      onPaginate: (offset) => controller.getAuctionTransactionList(context, offset: offset ?? 1, searchAuctionId: _searchAuctionId),
                      itemView: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeExtraSmall,
                          bottom: Dimensions.paddingSizeDefault,
                        ),
                        itemCount: controller.transactions.length,
                        itemBuilder: (context, index) {
                          final t = controller.transactions[index];
                          return AuctionTransactionTileWidget(
                            amount: t.amount ?? 0.0,
                            auctionNumber: '${t.auctionProductId ?? ''}',
                            dateTime: DateTime.tryParse(t.date ?? '') ?? DateTime.now(),
                            type: t.type == 'credit' ? TransactionType.credit : TransactionType.debit,
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
}
