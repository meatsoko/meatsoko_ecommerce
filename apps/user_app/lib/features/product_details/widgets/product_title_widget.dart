
import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_directionality_widget.dart';
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/product_details/domain/models/product_details_model.dart';
import 'package:user_app/features/product_details/widgets/cart_bottom_sheet_widget.dart' show QuantityButton;
// import 'package:user_app/features/product_details/widgets/favourite_button_widget.dart'; // heart moved to the app bar, see product_details_screen.dart
// import 'package:user_app/features/product_details/widgets/product_carousel_image_viewer_widget.dart' show ProductUtilityIconsRow; // share button removed per user request
import 'package:user_app/features/review/controllers/review_controller.dart';
import 'package:user_app/helper/color_helper.dart';
import 'package:user_app/helper/price_converter.dart';
import 'package:user_app/helper/product_helper.dart';
// import 'package:user_app/helper/route_healper.dart'; // was only used by the now-dropped "See More Detail" link
import 'package:user_app/localization/app_localization.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:provider/provider.dart';


/// Opens the full, untruncated product description in a bottom sheet —
/// destination for the "More Details" link under the dashed divider.
void _showMoreDetailsBottomSheet(BuildContext context, String description) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(getTranslated('description', context) ?? 'Description',
                style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(description,
                    style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).hintColor, height: 1.5),
                  ),
                ),
              ),
            ]),
          );
        },
      );
    },
  );
}

class ProductTitleWidget extends StatelessWidget {
  final ProductDetailsModel? productModel;
  final String? averageRatting;
  const ProductTitleWidget({super.key, required this.productModel, this.averageRatting});

  @override
  Widget build(BuildContext context) {

    ({double? end, double? start})? priceRange = ProductHelper.getProductPriceRange(productModel);
    double? startingPrice = priceRange.start;
    double? endingPrice = priceRange.end;

    return productModel != null? Container(
      padding: const EdgeInsets.symmetric(horizontal : Dimensions.homePagePadding),
      child: Consumer<ProductDetailsController>(
        builder: (context, details, child) {
          final String description = ProductHelper.htmlToPlainText(productModel!.details ?? '');

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Name (bold, left) + price (right), same row (reference
            // design) — merges what used to be two separate rows (name +
            // share button, then price on its own row). Share button
            // removed entirely (was ProductUtilityIconsRow here); wishlist
            // heart already lives in the app bar (see
            // product_details_screen.dart), not this row.
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Text(
                    productModel!.name ?? '',
                    style: titleRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color), maxLines: 2,
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                CustomDirectionalityWidget(
                  child: Text(
                    '${startingPrice != null ?
                        PriceConverter.convertPrice(
                          context,
                          startingPrice,
                          discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                              ? productModel?.clearanceSale?.discountAmount
                              : productModel?.discount,
                          discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                              ? productModel?.clearanceSale?.discountType
                              : productModel?.discountType,
                        )
                        : ''}'
                    '${endingPrice != null
                        ? ' - ${PriceConverter.convertPrice(
                              context,
                              endingPrice,
                              discount: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                  ? productModel?.clearanceSale?.discountAmount
                                  : productModel?.discount,
                              discountType: (productModel?.clearanceSale?.discountAmount ?? 0) > 0
                                  ? productModel?.clearanceSale?.discountType
                                  : productModel?.discountType,
                            )}'
                        : ''}',
                    style: titilliumBold.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: Dimensions.fontSizeOverLarge,
                    ),
                  ),
                ),

                if((productModel!.discount != null && productModel!.discount! > 0) || (productModel!.clearanceSale != null && productModel!.clearanceSale!.discountAmount! > 0) )...[
                  const SizedBox(width: Dimensions.paddingSizeSmall),

                  CustomDirectionalityWidget(
                    child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
                        '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                        style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor,
                            decoration: TextDecoration.lineThrough)),
                  ),
                ],
              ]),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            // Description (reference design) — a plain heading + paragraph,
            // no "See More" link (dropped per the reference, which shows
            // the description directly). Still capped at a handful of
            // lines rather than fully unbounded, since real product
            // descriptions can run far longer than this mockup's — just
            // with no tap target, matching the reference's simplicity.
            if (description.isNotEmpty) ...[
              Text(getTranslated('description', context) ?? 'Description', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(
                description,
                // Capped at 3 lines (was 5) — the "More Details" bottom
                // sheet below already shows the full, untruncated text.
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor, height: 1.4),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              const _DashedDivider(),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              // "More Details" (reference design) — opens the full,
              // untruncated description in a bottom sheet, since the text
              // above is capped at 3 lines. Separate from the "Customize"
              // section's own "More Details" toggle further down, which
              // expands variant selection inline rather than opening a
              // sheet.
              InkWell(
                onTap: () => _showMoreDetailsBottomSheet(context, description),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('More Details',
                    style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, size: 18, color: Theme.of(context).primaryColor),
                ]),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            Consumer<ReviewController>(
              builder: (context, reviewController, _) {
                final double rating = double.tryParse(averageRatting ?? '0') ?? 0;
                final List<String> metaParts = [];

                if (reviewController.reviewList != null && reviewController.reviewList!.isNotEmpty) {
                  metaParts.add('${reviewController.reviewList!.length} ${getTranslated('reviews', context)}');
                }
                // Disabled per user request — dropped the "Unit: kg" entry
                // from the meta row. Reference shows "calories | time |
                // rating" (food-delivery-specific fields this product model
                // doesn't have); `unit` was the closest real substitute,
                // but not wanted here. Kept for reference, not deleted.
                // if ((productModel!.unit ?? '').isNotEmpty) {
                //   metaParts.add('Unit: ${productModel!.unit}');
                // }
                // Disabled (keep-it-minimal pass): order count / wishlist
                // count made the meta row read as sparse "0 orders" style
                // stats on a young catalog rather than as social proof.
                // Kept for reference, not deleted.
                // if ((details.orderCount ?? 0) > 0) {
                //   metaParts.add('${details.orderCount} ${getTranslated('orders', context)}');
                // }
                // if ((details.wishCount ?? 0) > 0) {
                //   metaParts.add('${details.wishCount} ${getTranslated('wish_listed', context)}');
                // }

                if (rating <= 0 && metaParts.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    if (rating > 0) ...[
                      Icon(Icons.star_rounded, color: Colors.amber, size: Dimensions.fontSizeExtraLarge),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: textMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (metaParts.isNotEmpty) Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text('•', style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor)),
                      ),
                    ],
                    if (metaParts.isNotEmpty)
                      Expanded(
                        child: Text(
                          metaParts.join('   •   '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor),
                        ),
                      ),
                  ]),
                );
              },
            ),

            // Disabled (keep-it-minimal pass): the "Available" label was
            // purely decorative text above the color swatches — the
            // swatches are self-explanatory without it. Kept for
            // reference, not deleted (see `_isVariationAvailable` below,
            // also disabled since nothing else calls it now).
            // if(_isVariationAvailable()) ...[
            //   Text(
            //     '${getTranslated('available', context)}',
            //     style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
            //   ),
            //   const SizedBox(height: Dimensions.paddingSizeSmall),
            // ],

            /// ------------------------------------------------------------
            /// Disabled: color swatches used to always show here, above
            /// Customize, sharing a row with the quantity stepper (from an
            /// earlier, different reference). Folded into _CustomizeSection
            /// below instead, matching this reference's single "Customize"
            /// entry point for all variant selection.
            // if (productModel!.colors?.isNotEmpty ?? false)
            //   Padding(
            //     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            //     child: _InlineColorSwatches(productModel: productModel!, detailsController: details),
            //   ),

            /// ------------------------------------------------------------
            /// Disabled: the old label + full-width color grid row. Kept
            /// for reference — replaced above by _InlineColorSwatches so
            /// color selection can share a row with the quantity stepper.
            // productModel!.colors != null && productModel!.colors!.isNotEmpty ?
            // Row(children: [
            //   Text('${getTranslated('color', context)} : ', style: titilliumRegular.copyWith(
            //     fontSize: Dimensions.fontSizeLarge,
            //     color: Theme.of(context).textTheme.bodyLarge?.color,
            //   )),
            //   const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //   Expanded(child: SizedBox(height: Dimensions.paddingSizeLarge, child: ListView.separated(
            //     itemCount: productModel!.colors!.length,
            //     scrollDirection: Axis.horizontal,
            //     itemBuilder: (context, index) {
            //       return Center(child: Container(
            //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
            //           child: Container(
            //             width: Dimensions.marginSizeAuthSmall,
            //             alignment: Alignment.center,
            //             decoration: BoxDecoration(
            //               color: ColorHelper.hexCodeToColor(productModel?.colors?[index].code),
            //               borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraExtraSmall)
            //             ),
            //           ),
            //       ));
            //     },
            //     separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSizeDefaultAddress),
            //   ))),
            // ]) : const SizedBox(),

            // Interactive "Customize" section (matches this reference: a
            // collapsed "Customize / More Details" row that expands to
            // reveal every variant control — color swatches included, not
            // just choice-options). Replaces the old decorative,
            // non-interactive chip list below (kept, disabled, for
            // reference) — selecting an option here now actually writes to
            // ProductDetailsController.setCartVariantIndex/
            // setCartVariationIndex, the same state CartBottomSheetWidget
            // itself reads/writes, so a product with color and/or
            // choice-options no longer needs the sheet at all for the
            // "add to cart" path (see BottomCartWidget._needsSheet).
            if ((productModel!.colors?.isNotEmpty ?? false) || (productModel!.choiceOptions?.isNotEmpty ?? false))
              _CustomizeSection(productModel: productModel!, detailsController: details),

            /// ------------------------------------------------------------
            /// Disabled: the old decorative (non-interactive) choice-option
            /// chip list — every option rendered with no selected state.
            /// Replaced above by _CustomizeSection.
            // productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty ?
            // ListView.builder(
            //   shrinkWrap: true,
            //   itemCount: productModel!.choiceOptions!.length,
            //   physics: const NeverScrollableScrollPhysics(),
            //   itemBuilder: (context, index) {
            //     return Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text('${productModel!.choiceOptions![index].title?.toCapitalized()} : ', style: titilliumRegular.copyWith(
            //           fontSize: Dimensions.fontSizeLarge,
            //           color: Theme.of(context).textTheme.bodyLarge?.color,
            //         )),
            //         const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            //         Expanded(child: Padding(
            //           padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            //           child: SizedBox(height: Dimensions.paddingSizeExtraLarge, child: ListView.separated(
            //             scrollDirection: Axis.horizontal,
            //             itemCount: productModel!.choiceOptions![index].options!.length,
            //             itemBuilder: (context, i) {
            //               return Container(
            //                 alignment: Alignment.center,
            //                 padding: const EdgeInsets.symmetric(
            //                   vertical: Dimensions.paddingSizeExtraExtraSmall,
            //                   horizontal: Dimensions.paddingSizeSmall
            //                 ),
            //                 decoration: BoxDecoration(
            //                   color: Theme.of(context).hintColor.withValues(alpha: 0.125),
            //                   borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraExtraSmall),
            //                 ),
            //                 child: Text(
            //                     productModel!.choiceOptions![index].options![i].trim(),
            //                     overflow: TextOverflow.ellipsis,
            //                     maxLines: 1,
            //                     style: textRegular.copyWith(
            //                       fontSize: Dimensions.fontSizeSmall,
            //                       color: Theme.of(context).textTheme.bodyLarge?.color,
            //                     ),
            //                   ),
            //               );
            //             },
            //             separatorBuilder: (BuildContext context, int index) => const SizedBox(width: Dimensions.paddingSizeDefaultAddress),
            //           )),
            //         )),
            //       ],
            //     );
            //   },
            // ) : const SizedBox(),
          ]);
        },
      ),
    ) : const SizedBox();
  }

  // Disabled along with its only caller above (the "Available" label).
  // bool _isVariationAvailable() => ((productModel!.colors != null && productModel!.colors!.isNotEmpty) && productModel!.choiceOptions != null && productModel!.choiceOptions!.isNotEmpty);
}

/// Dashed horizontal rule (reference design), between the description and
/// the Customize section. No dependency needed — a row of alternating
/// colored/transparent segments reads as a dashed line at any width.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    // Fewer, chunkier segments + a darker/more opaque tone than before —
    // the original (60 hairline segments at 0.3 alpha) read as barely
    // there.
    return Row(
      children: List.generate(36, (index) => Expanded(
        child: Container(
          height: 1.5,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          color: index.isEven ? Theme.of(context).hintColor.withValues(alpha: 0.6) : Colors.transparent,
        ),
      )),
    );
  }
}

/// Compact single-row color swatches (reference design) — same selection
/// state (`variantIndex`) as the old full-width labeled grid above (now
/// disabled), just smaller and laid out to share a row with the quantity
/// stepper instead of taking the full width on its own.
class _InlineColorSwatches extends StatelessWidget {
  final ProductDetailsModel productModel;
  final ProductDetailsController detailsController;
  const _InlineColorSwatches({required this.productModel, required this.detailsController});

  @override
  Widget build(BuildContext context) {
    final colors = productModel.colors!;
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: Dimensions.paddingSizeSmall),
        itemBuilder: (context, index) {
          final bool isSelected = detailsController.variantIndex == index;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => detailsController.setCartVariantIndex(productModel.minimumOrderQty ?? 1, index, context),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorHelper.hexCodeToColor(colors[index].code),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Inline "− qty +" stepper (reference design) — lets a shopper set
/// quantity directly on the page instead of only inside the add-to-cart
/// sheet. Reuses the existing `QuantityButton` (from
/// cart_bottom_sheet_widget.dart) so increment/decrement bounds-checking
/// (stock, minimum order quantity) stays identical to the sheet's.
///
/// Public (not `_InlineQuantityStepper`) — moved out of this widget's own
/// layout and into the bottom bar (see `BottomCartWidget`, adopted from a
/// food-app reference that pairs quantity with "Add to Cart" in one row
/// instead of splitting them), so it needs to be importable from there.
class InlineQuantityStepper extends StatelessWidget {
  final ProductDetailsModel productModel;
  final ProductDetailsController detailsController;
  const InlineQuantityStepper({super.key, required this.productModel, required this.detailsController});

  @override
  Widget build(BuildContext context) {
    final bool isDigital = productModel.productType == 'digital';
    final int? stock = isDigital
        ? null
        : ProductHelper.resolveVariant(productModel, variantIndex: detailsController.variantIndex ?? 0, variationIndexList: detailsController.variationIndex).stock ?? productModel.currentStock;
    final int quantity = detailsController.quantity ?? productModel.minimumOrderQty ?? 1;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      QuantityButton(
        isIncrement: false,
        quantity: quantity,
        stock: stock,
        minimumOrderQuantity: productModel.minimumOrderQty,
        digitalProduct: isDigital,
      ),
      SizedBox(
        width: 36,
        child: Text('$quantity', textAlign: TextAlign.center,
          style: textMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      QuantityButton(
        isIncrement: true,
        quantity: quantity,
        stock: stock,
        minimumOrderQuantity: productModel.minimumOrderQty,
        digitalProduct: isDigital,
      ),
    ]);
  }
}

/// Collapsed-by-default "Customize" section (adopted from a food-app
/// reference: "Customize" label + "More Details ⌄" toggle). Expands to the
/// same choice-option chips CartBottomSheetWidget itself uses — same
/// `setCartVariationIndex` call, same selection state — so this is a real
/// alternative entry point to that state, not a separate copy of it.
class _CustomizeSection extends StatefulWidget {
  final ProductDetailsModel productModel;
  final ProductDetailsController detailsController;
  const _CustomizeSection({required this.productModel, required this.detailsController});

  @override
  State<_CustomizeSection> createState() => _CustomizeSectionState();
}

class _CustomizeSectionState extends State<_CustomizeSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool hasColors = widget.productModel.colors?.isNotEmpty ?? false;
    final choiceOptions = widget.productModel.choiceOptions ?? const [];

    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Hardcoded English (not getTranslated) — no existing
            // translation key fits, and adding one would need updating
            // every bundled language file for one label.
            Text('Customize', style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
            Row(children: [
              Text('More Details', style: textMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
              Icon(_expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Theme.of(context).primaryColor, size: 22),
            ]),
          ]),
        ),

        if (_expanded) ...[
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if (hasColors) ...[
            Text('${getTranslated('color', context)}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            _InlineColorSwatches(productModel: widget.productModel, detailsController: widget.detailsController),
            if (choiceOptions.isNotEmpty) const SizedBox(height: Dimensions.paddingSizeSmall),
          ],

          ListView.builder(
            shrinkWrap: true,
            itemCount: choiceOptions.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final choice = choiceOptions[index];
              final options = choice.options ?? const [];

              return Padding(
                padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${choice.title?.toCapitalized()}', style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Wrap(spacing: 8, runSpacing: 8, children: List.generate(options.length, (i) {
                    final bool isSelected = (widget.detailsController.variationIndex?.length ?? 0) > index
                        && widget.detailsController.variationIndex![index] == i;
                    return InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => widget.detailsController.setCartVariationIndex(widget.productModel.minimumOrderQty ?? 1, index, i, context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).hintColor.withValues(alpha: 0.1),
                          border: Border.all(width: 1, color: isSelected ? Theme.of(context).primaryColor : Colors.transparent),
                        ),
                        child: Text(options[i].trim(),
                          style: textRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    );
                  })),
                ]),
              );
            },
          ),
        ],
      ]),
    );
  }
}
