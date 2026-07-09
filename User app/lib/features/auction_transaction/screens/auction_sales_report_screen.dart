import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/controller/auction_transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/domain/models/auction_sales_report_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_transaction/widgets/auction_sales_trend_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AuctionSalesReportScreen extends StatefulWidget {
  const AuctionSalesReportScreen({super.key});

  @override
  State<AuctionSalesReportScreen> createState() => _AuctionSalesReportScreenState();
}

class _AuctionSalesReportScreenState extends State<AuctionSalesReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuctionTransactionController>().getSalesReport(dateType: AuctionReportDateType.allTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('auction_sales_report', context) ?? ""),
      body: Consumer<AuctionTransactionController>(
        builder: (context, controller, _) {
          final AuctionSalesReportModel? report = controller.salesReport;
          final bool isLoading = controller.isReportLoading;

          return RefreshIndicator(
            onRefresh: () => context.read<AuctionTransactionController>().getSalesReport(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                isLoading
                    ? _buildShimmer()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: Dimensions.paddingSizeEight,
                          mainAxisSpacing: Dimensions.paddingSizeEight,
                          childAspectRatio: 1.3,
                          children: [
                            AuctionStatCard(
                              imagePath: Images.gavelIcon,
                              count: (report?.totalAuctionsCreated ?? 0).toString(),
                              label: 'auctions_created',
                            ),
                            AuctionStatCard(
                              imagePath: Images.packageIcon,
                              count: (report?.totalAuctionsSold ?? 0).toString(),
                              label: 'total_sold',
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                            AuctionStatCard(
                              imagePath: Images.package01Icon,
                              count: (report?.totalProductSalesValue ?? 0).toStringAsFixed(2),
                              label: 'total_sales_value',
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                            AuctionStatCard(
                              imagePath: Images.vatIcon,
                              count: (report?.totalVatTax ?? 0).toStringAsFixed(2),
                              label: 'vat_tax_collected',
                              color: Theme.of(context).colorScheme.error,
                            ),
                            AuctionStatCard(
                              imagePath: Images.shippingDeliveredIcon,
                              count: (report?.totalShippingFee ?? 0).toStringAsFixed(2),
                              label: 'shipping_fee_collected',
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            AuctionStatCard(
                              imagePath: Images.coinIcon,
                              count: (report?.grossSalesAmount ?? 0).toStringAsFixed(2),
                              label: 'total_gross_amount',
                            ),
                          ],
                        ),
                      ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  child: SalesTrendWidget(),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),
              ],
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: Dimensions.paddingSizeEight,
        mainAxisSpacing: Dimensions.paddingSizeEight,
        childAspectRatio: 1.3,
        children: List.generate(
          6,
          (_) => Shimmer.fromColors(
            baseColor: Theme.of(context).cardColor,
            highlightColor: Colors.grey[300]!,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuctionStatCard extends StatelessWidget {
  final String imagePath;
  final String count;
  final String? label;
  final double imageSize;
  final Color? color;

  const AuctionStatCard({
    super.key,
    required this.imagePath,
    required this.count,
    this.label,
    this.imageSize = Dimensions.iconSizeDefault,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAssetImageWidget(imagePath, height: imageSize, width: imageSize, fit: BoxFit.contain),
          SizedBox(height: Dimensions.paddingSizeSmall),

          Text(PriceConverter.convertPrice(context, double.tryParse(count) ?? 0),
            style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeWallet, color: color ?? theme.colorScheme.primary),
          ),

          SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Flexible(
            child: Text(label != null ? (getTranslated(label!, context) ?? label!) : '',
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: theme.textTheme.bodyLarge?.color),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
