import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/auction/auction_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/participator/participation_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionHorizontalProductItem {
  final int? id;
  final String? slug;
  final String? name;
  final double? startingPrice;
  final AuctionParticipationStatus? auctionCurrentStatus;
  final AuctionDetails? auctionDetails;
  final ThumbnailFullUrl? thumbnailFullUrl;

  const AuctionHorizontalProductItem({
    this.id,
    this.slug,
    this.name,
    this.startingPrice,
    this.auctionCurrentStatus,
    this.auctionDetails,
    this.thumbnailFullUrl,
  });

  factory AuctionHorizontalProductItem.fromSimilar(SimilarProduct p) =>
      AuctionHorizontalProductItem(
        id: p.id,
        slug: p.slug,
        name: p.name,
        startingPrice: p.startingPrice,
        auctionCurrentStatus: p.auctionCurrentStatus,
        auctionDetails: p.auctionDetails,
        thumbnailFullUrl: p.thumbnailFullUrl,
      );

  factory AuctionHorizontalProductItem.fromSameAuthor(SameAuthorProduct p) =>
      AuctionHorizontalProductItem(
        id: p.id,
        slug: p.slug,
        name: p.name,
        startingPrice: p.startingPrice,
        auctionCurrentStatus: p.auctionCurrentStatus,
        auctionDetails: p.auctionDetails,
        thumbnailFullUrl: p.thumbnailFullUrl,
      );
}

class AuctionProductHorizontalListWidget extends StatelessWidget {
  final String sectionTitle;
  final List<AuctionHorizontalProductItem> products;
  final VoidCallback? onViewAllTap;

  const AuctionProductHorizontalListWidget({
    super.key,
    required this.sectionTitle,
    required this.products,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Dimensions.homePagePadding, right: Dimensions.homePagePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,           // remove inner padding
                  minimumSize: Size.zero,             // remove default min size
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // remove extra tap area
                ),
                onPressed: onViewAllTap,
                child: Text(getTranslated('view_all', context) ?? '',
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    )
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.paddingSizeSmall),

        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
            itemBuilder: (context, index) {
              final product = products[index];
              final auctionDetails = product.auctionDetails;

              return SizedBox(
                width: 160,
                child: AuctionCardWidget(
                  state: product.auctionCurrentStatus?.isLive == true ? AuctionCardState.live : AuctionCardState.upcoming,
                  slug: product.slug ?? '',
                  imageUrl: product.thumbnailFullUrl?.path ?? Images.placeholder,
                  productName: product.name ?? '',
                  price: product.startingPrice ?? 0.0,
                  targetTime: auctionDetails?.endTime != null
                      ? DateTime.tryParse(auctionDetails!.endTime!) ?? DateTime.now()
                      : DateTime.now(),
                  viewCount: auctionDetails?.totalViews ?? 0,
                  bidCount: auctionDetails?.totalBids ?? 0,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}