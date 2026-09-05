import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart' show NoInternetOrDataScreenWidget;
import 'package:user_app/features/deal/controllers/flash_deal_controller.dart';
// import 'package:user_app/features/product/controllers/product_controller.dart'; // only used by the disabled specification-and-below block
// import 'package:user_app/features/product/controllers/seller_product_controller.dart'; // only used by the disabled specification-and-below block
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/product_details/widgets/bottom_cart_widget.dart';
import 'package:user_app/features/product_details/widgets/favourite_button_widget.dart';
import 'package:user_app/features/product_details/widgets/product_carousel_image_viewer_widget.dart';
// import 'package:user_app/features/product_details/widgets/product_specification_widget.dart'; // only used by the disabled inline Specification block below
import 'package:user_app/features/product_details/widgets/product_title_widget.dart';
// import 'package:user_app/features/product_details/widgets/promise_widget.dart'; // only used by the disabled specification-and-below block
// import 'package:user_app/features/product_details/widgets/related_product_widget.dart'; // only used by the disabled specification-and-below block
// import 'package:user_app/features/product_details/widgets/review_and_specification_widget.dart'; // only used by the disabled specification-and-below block
import 'package:user_app/features/product_details/widgets/shop_info_widget.dart' show VendorMiniCardWidget;
// import 'package:user_app/features/product_details/widgets/youtube_video_widget.dart'; // only used by the disabled specification-and-below block
import 'package:user_app/features/review/controllers/review_controller.dart';
// import 'package:user_app/common/basewidget/custom_app_bar_widget.dart'; // was for the disabled CustomAppBar, see build()
import 'package:user_app/features/home/shimmers/product_details_shimmer.dart';
// import 'package:user_app/features/review/widgets/review_section.dart'; // only used by the disabled specification-and-below block
import 'package:user_app/features/shop/controllers/shop_controller.dart';
// import 'package:user_app/features/shop/widgets/shop_more_product_view_list.dart'; // only used by the disabled specification-and-below block
import 'package:user_app/features/splash/controllers/splash_controller.dart';
// import 'package:user_app/helper/product_helper.dart'; // only used by the disabled inline Specification block below
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/common/basewidget/title_row_widget.dart'; // TitleRowWidget only used by the disabled block below, but TimerBox (also here) is still used by the flash-deal countdown banner above
import 'package:user_app/utill/images.dart';
import 'package:provider/provider.dart';


class ProductDetails extends StatefulWidget {
  final int? productId;
  final String? slug;
  final bool isFromWishList;
  final bool isNotification;
  final bool fromFlashDeals;
  const ProductDetails({super.key, required this.productId, required this.slug, this.isFromWishList = false, this.isNotification = false, this.fromFlashDeals = false});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {

  List<TextSpan> _publishingHouse = [];
  List<TextSpan> _authors = [];

  Size widgetSize = const Size(100, 400);

  Future<void> _loadData( BuildContext context) async {
    // .then() rather than await: initializes variant/quantity state (used by
    // the inline color swatches + quantity stepper on the details page, and
    // by CartBottomSheetWidget if it's opened as a fallback) as soon as the
    // product loads, without holding up the other independent calls below.
    Provider.of<ProductDetailsController>(context, listen: false)
        .getProductDetails(context, widget.slug.toString(), widget.slug.toString())
        .then((_) {
      if (!mounted) return;
      final detailsController = Provider.of<ProductDetailsController>(context, listen: false);
      final product = detailsController.productDetailsModel;
      if (product != null) {
        detailsController.initData(product, product.minimumOrderQty ?? 1, context);
        detailsController.initDigitalVariationIndex();
      }
    });
    Provider.of<ReviewController>(context, listen: false).removePrevReview();
    Provider.of<ProductDetailsController>(context, listen: false).removePrevLink();
    Provider.of<ReviewController>(context, listen: false).getReviewList(1, productSlug: widget.slug);
    // Related-products fetch — only ever fed the now-disabled "Related
    // Products" row (_ProductDetailsProductListWidget, further down).
    // Provider.of<ProductController>(context, listen: false).removePrevRelatedProduct();
    // Provider.of<ProductController>(context, listen: false).initRelatedProductList(widget.slug.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).getCount(widget.slug.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).getSharableLink(widget.slug.toString(), context);
    Provider.of<ProductDetailsController>(context, listen: false).setImageSliderSelectedIndex(0, isUpdate: false);
    Provider.of<ShopController>(context, listen: false).emptyProductDetailsSeller();
  }

  void _onBackPressed() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
    }
  }

  @override
  void initState() {
    Provider.of<ProductDetailsController>(context, listen: false).selectReviewSection(false, isUpdate: false);
    _loadData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Only fed the now-disabled _ProductDetailsProductListWidget below.
    // ScrollController scrollController = ScrollController();
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async{
        if(widget.isNotification) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushNamedAndRemoveUntil);
        } else {
          return;
        }
      },
      child: Scaffold(
        // One consistent page background (reference design — no separate
        // white-behind-image / gray-sheet-below split, which is what the
        // *other* reference this page briefly borrowed from used).
        //
        // ------------------------------------------------------------------
        // Disabled: the earlier solid CustomAppBar (title text + plain back
        // arrow), then later a floating circular back button + rating pill
        // over the hero image (see the removed `_BackButtonChip`/`_RatingPill`
        // Stack in the body below). Matching this reference now means a real
        // app bar row again — back + centered "Details" title + heart — just
        // built from plain circles instead of CustomAppBar's solid bar, and
        // with the heart where the reference puts it (header, not price row).
        // appBar: CustomAppBar(
        //   title: getTranslated('product_details', context),
        //   onBackPressed: _onBackPressed,
        // ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
              child: Row(children: [
                _BackButtonChip(onTap: _onBackPressed),
                Expanded(
                  child: Center(
                    child: Text(getTranslated('details', context) ?? 'Details',
                      style: textBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                ),
                Consumer<ProductDetailsController>(
                  builder: (context, details, _) => details.productDetailsModel != null
                      ? FavouriteButtonWidget(productId: details.productDetailsModel!.id, fromProductDetails: true)
                      : const SizedBox(width: 40, height: 40),
                ),
              ]),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async => _loadData(context),
          child: Consumer<ProductDetailsController>(
            builder: (context, details, child) {
              if(details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty) {
                _publishingHouse = [];
                for(String? houseName in details.productDetailsModel!.publishingHouse!) {
                  _publishingHouse.add(TextSpan(text: '${houseName!} ' , style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)));
                }
              }

              if(details.productDetailsModel?.authors != null && details.productDetailsModel!.authors!.isNotEmpty) {
                _authors = [];
                for(String? authorName in details.productDetailsModel!.authors!) {
                  _authors.add(TextSpan(text: '${authorName!} ', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeDefault)));
                }
              }


              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: !details.isDetails ?
                (!details.isDetails && details.productDetailsModel?.userId == null) ?
                SizedBox(
                  height: MediaQuery.of(context).size.height - 200,
                  child: NoInternetOrDataScreenWidget(isNoInternet: false, icon: Images.noProduct, message: 'no_product_found')) :
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ProductCarouselImageViewerWidget(productModel: details.productDetailsModel, fromFlashDeals: widget.fromFlashDeals),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      // Lightweight vendor mini-card (reference design) —
                      // name + "Visit Store" pill, no stats bar. Sits above
                      // the title, not down in the disabled
                      // specification-and-below section where the old,
                      // heavier ShopInfoWidget used to live.
                      if (details.productDetailsModel != null)
                        VendorMiniCardWidget(
                          sellerId: details.productDetailsModel!.addedBy == 'seller'
                              ? details.productDetailsModel!.seller!.shop!.slug!.toString()
                              : Provider.of<SplashController>(context, listen: false).configModel!.inHouseShop!.slug!,
                        ),

                      if(widget.fromFlashDeals) ...[
                        Consumer<FlashDealController>(
                          builder: (context, flashDealController, child) {
                            Duration? eventDuration = flashDealController.duration;

                            int? days, hours, minutes, seconds;
                            if (eventDuration != null) {
                              days = eventDuration.inDays;
                              hours = eventDuration.inHours - days * 24;
                              minutes = eventDuration.inMinutes - (24 * days * 60) - (hours * 60);
                              seconds = eventDuration.inSeconds - (24 * days * 60 * 60) - (hours * 60 * 60) - (minutes * 60);
                            }

                            return  Padding(
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        getTranslated('this_product_is_now_on_a_flash_deal', context) ?? '',
                                        style: textMedium.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          color: Theme.of(context).textTheme.bodyLarge?.color
                                        ),
                                      ),
                                    ),

                                    if (eventDuration != null)
                                      Row(mainAxisSize: MainAxisSize.min, children: [
                                        TimerBox(time: days, day: getTranslated('day', context), isDetailsPage: true),
                                        TimerBox(time: hours, day: getTranslated('hour', context), isDetailsPage:  true),
                                        TimerBox(time: minutes, day: getTranslated('min', context), isDetailsPage:  true),
                                        TimerBox(time: seconds,day: getTranslated('sec', context), isDetailsPage:  true),
                                      ]),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],

                      ProductTitleWidget(
                        productModel: details.productDetailsModel,
                        averageRatting: details.productDetailsModel?.averageReview ?? "0",
                      ),

                      (details.productDetailsModel?.productType == 'digital' && (_publishingHouse.isNotEmpty || _authors.isNotEmpty)) ?
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
                        child: RichText(text: TextSpan(
                            text: '',
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.w400,
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            children: [
                              if (details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty)
                                TextSpan( text: "${getTranslated('publishing_housec', context)}", style: titilliumRegular.copyWith(
                                    fontSize: Dimensions.fontSizeDefault,
                                    color: Theme.of(context).hintColor,
                                )),

                              ..._publishingHouse,

                              if (details.productDetailsModel?.publishingHouse != null && details.productDetailsModel!.publishingHouse!.isNotEmpty)
                                WidgetSpan(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                    height: 15.0, width: 1.0,
                                    color: Theme.of(context).primaryColor.withValues(alpha:0.50),
                                  ),
                                ),

                              if (details.productDetailsModel?.authors != null && details.productDetailsModel!.authors!.isNotEmpty)
                                TextSpan( text: "${getTranslated('author', context)}",
                                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)
                                ),
                              ..._authors,
                            ],
                        )),
                      ) : const SizedBox(),

                      // ------------------------------------------------------
                      // Disabled (keep-it-minimal pass, user request: "comment
                      // out all from specification to all below"): everything
                      // from the Specification/Reviews tab selector through
                      // the end of the page — the tab selector itself, review
                      // list, video, shop info card, trust-badge promise
                      // widget, and both "Related Products" / "More From This
                      // Shop" cross-sell rows. Kept for reference, not deleted.
                      //
                      // ReviewAndSpecificationSectionWidget(
                      //   averageReview: double.tryParse(details.productDetailsModel?.averageReview ?? '0'),
                      // ),
                      //
                      // details.isReviewSelected?
                      // Column(children: [
                      //   ReviewSection(details: details),
                      //   _ProductDetailsProductListWidget(scrollController: scrollController),
                      // ]):
                      //
                      // Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      //   // Disabled earlier (keep-it-minimal pass): the full HTML
                      //   // description here duplicated the short excerpt +
                      //   // "See More Detail" link ProductTitleWidget now
                      //   // shows up top, which already routes to the
                      //   // dedicated specification screen for the full text.
                      //   // (details.productDetailsModel?.details != null && details.productDetailsModel!.details!.isNotEmpty) ?
                      //   // Container(
                      //   //   decoration: BoxDecoration(
                      //   //     color: Theme.of(context).cardColor,
                      //   //     borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      //   //   ),
                      //   //   margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding, vertical: Dimensions.paddingSizeSmall),
                      //   //   padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      //   //   child: ProductSpecificationWidget(
                      //   //     productSpecification: ProductHelper.removeIframe(details.productDetailsModel!.details ?? ''),
                      //   //   ),
                      //   // ) : const SizedBox(),
                      //
                      //   (details.productDetailsModel?.videoUrl != null && details.isValidYouTubeUrl(details.productDetailsModel!.videoUrl!)) ?
                      //   Padding(
                      //     padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                      //     child: YoutubeVideoWidget(url: details.productDetailsModel!.videoUrl)
                      //   ) : const SizedBox(),
                      //
                      //
                      //   (details.productDetailsModel != null) ?
                      //   ShopInfoWidget(sellerId: details.productDetailsModel!.addedBy == 'seller'? details.productDetailsModel!.seller!.shop!.slug!.toString()
                      //     : Provider.of<SplashController>(context, listen: false).configModel!.inHouseShop!.slug!
                      //   ) : const SizedBox.shrink(),
                      //   const SizedBox(height: Dimensions.paddingSizeSmall),
                      //
                      //   Consumer<SplashController>(
                      //     builder: (context, splashController, _) {
                      //       final config = splashController.configModel;
                      //       final showPromiseWidget = config?.activeTheme == 'default' && config?.companyReliability?.any((item) => item.status == 1) == true;
                      //
                      //       if (showPromiseWidget) {
                      //         return Container(
                      //           padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge, bottom: Dimensions.paddingSizeDefault),
                      //           decoration: BoxDecoration(color: Theme.of(context).cardColor),
                      //           child: const PromiseWidget(),
                      //         );
                      //       }
                      //       return const SizedBox();
                      //     },
                      //   ),
                      //
                      //   _ProductDetailsProductListWidget(scrollController: scrollController),
                      //
                      //
                      // ]),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                ]) :
                const ProductDetailsShimmer(),
              );
            },
          ),
        ),

        bottomNavigationBar: Consumer<ProductDetailsController>(
          builder: (context, details, child) {
            return !details.isDetails && details.productDetailsModel?.userId != null ?
            BottomCartWidget(product: details.productDetailsModel):const SizedBox();
          }
        ),
      ),
    );
  }
}

// Disabled along with its only two call sites above (the Specification/
// Reviews tab section and everything below it) — this class rendered the
// "Related Products" and "More From This Shop" rows. Kept for reference,
// not deleted.
/*
class _ProductDetailsProductListWidget extends StatelessWidget {
  const _ProductDetailsProductListWidget({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailsController>(
        builder: (context, productDetailsController, _) {
          return Column(children: [
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Consumer<ProductController>(
              builder: (context, productController,_) {
                return (productController.relatedProductList != null && productController.relatedProductList!.isNotEmpty)?Padding(padding: const EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeExtraSmall),
                  child: TitleRowWidget(title: getTranslated('related_products', context), isDetailsPage: true)): const SizedBox();
              }
            ),
            const SizedBox(height: 5),
            const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: RelatedProductWidget(),
            ),


            Consumer<SellerProductController>(
              builder: (context, sellerProductController, _) {
                return (sellerProductController.sellerMoreProduct != null && sellerProductController.sellerMoreProduct!.products != null &&
                    sellerProductController.sellerMoreProduct!.products!.isNotEmpty)?
                Padding(
                  padding: const EdgeInsets.symmetric(vertical : Dimensions.paddingSizeDefault),
                  child: TitleRowWidget(title: getTranslated('more_from_the_shop', context),
                    onTap: () {
                      if(productDetailsController.productDetailsModel?.addedBy == 'seller') {
                        RouterHelper.getTopSellerRoute(
                          action: RouteAction.push,
                          slug: productDetailsController.productDetailsModel?.seller?.shop?.slug,
                          sellerId: productDetailsController.productDetailsModel?.seller?.id,
                          temporaryClose: productDetailsController.productDetailsModel?.seller?.shop?.temporaryClose,
                          vacationStatus: productDetailsController.productDetailsModel?.seller?.shop?.vacationStatus ?? false,
                          vacationEndDate: productDetailsController.productDetailsModel?.seller?.shop?.vacationEndDate,
                          vacationStartDate: productDetailsController.productDetailsModel?.seller?.shop?.vacationStartDate,
                          vacationDurationType: productDetailsController.productDetailsModel?.seller?.shop!.vacationDurationType,
                          name: productDetailsController.productDetailsModel?.seller?.shop?.name,
                          banner: productDetailsController.productDetailsModel?.seller?.shop?.bannerFullUrl?.path,
                          image: productDetailsController.productDetailsModel?.seller?.shop?.imageFullUrl?.path,
                          fromMore: true,
                        );
                      } else {
                        RouterHelper.getTopSellerRoute(
                          sellerId: 0,
                          fromMore: true,
                          slug: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.slug,
                          temporaryClose: Provider.of<SplashController>(context, listen: false).configModel?.inhouseTemporaryClose?.status ?? false,
                          vacationStatus: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.status,
                          vacationEndDate: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationEndDate,
                          vacationStartDate: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationStartDate,
                          vacationDurationType: Provider.of<SplashController>(context, listen: false).configModel?.inhouseVacationAdd?.vacationDurationType,
                          name: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.name,
                          banner: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.bannerFullUrl?.path,
                          image: Provider.of<SplashController>(context, listen: false).configModel?.inHouseShop?.imageFullUrl?.path
                        );
                      }
                    },

                  ),
                ) : const SizedBox();
              }
            ),

            Padding(padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall),
              child: ShopMoreProductViewList(
              scrollController: scrollController, sellerId: productDetailsController.productDetailsModel!.userId!)
            ),



          ]);
        }
    );
  }
}
*/

/// Plain circular back button, used in the app bar's leading slot (used to
/// float over the hero image instead, before matching this reference's
/// real app-bar-row layout — see the disabled CustomAppBar comment above).
class _BackButtonChip extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButtonChip({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }
}

// Disabled — rating now shows in ProductTitleWidget's meta row instead
// (matching this reference, which puts rating alongside other stats rather
// than as a floating badge on the image). Kept for reference, not deleted.
/*
class _RatingPill extends StatelessWidget {
  final String? averageReview;
  const _RatingPill({required this.averageReview});

  @override
  Widget build(BuildContext context) {
    final double rating = double.tryParse(averageReview ?? '0') ?? 0;
    if (rating <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(rating.toStringAsFixed(1), style: textMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
      ]),
    );
  }
}
*/
