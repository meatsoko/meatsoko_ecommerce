import 'package:flutter/material.dart';
import 'package:user_app/features/cart/domain/models/cart_model.dart';
import 'package:user_app/features/product_details/controllers/product_details_controller.dart';
import 'package:user_app/features/product_details/domain/models/product_details_model.dart';
import 'package:user_app/features/product_details/widgets/cart_bottom_sheet_widget.dart';
import 'package:user_app/features/product_details/widgets/product_title_widget.dart' show InlineQuantityStepper;
import 'package:user_app/features/splash/controllers/splash_controller.dart';
import 'package:user_app/helper/product_helper.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/helper/shop_helper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/features/cart/controllers/cart_controller.dart';
import 'package:user_app/theme/controllers/theme_controller.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:provider/provider.dart';

// Reference-design adoption (a food-app reference): quantity stepper and
// "Add to Cart" consolidated into one bottom-bar row, matching that
// reference's layout — the separate cart-shortcut icon (with its
// item-count badge) that used to sit beside the button is dropped
// entirely rather than kept alongside a second control; not deleted, see
// the disabled block in build() below.
//
// Behavior: tapping "Add to Cart" adds directly, using whatever
// color/choice-options/quantity is currently selected inline on the page
// (see ProductTitleWidget's `_InlineColorSwatches` / `_CustomizeSection` /
// `InlineQuantityStepper`). Products with choice-options (e.g. size) are
// now resolved the same way color-only products are — via
// `ProductHelper.resolveVariant` — since `_CustomizeSection` gives them a
// real inline selection UI now; CartBottomSheetWidget is still used,
// unchanged, only as a fallback for digital products and out-of-stock/
// restock handling.
class BottomCartWidget extends StatefulWidget {
  final ProductDetailsModel? product;
  const BottomCartWidget({super.key, required this.product});

  @override
  State<BottomCartWidget> createState() => _BottomCartWidgetState();
}

class _BottomCartWidgetState extends State<BottomCartWidget> {
  bool vacationIsOn = false;
  bool temporaryClose = false;
  // Guards against rapid repeated taps firing multiple add-to-cart
  // requests before the first one resolves.
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();

    vacationIsOn = ShopHelper.isVacationActive(
      context,
      startDate: widget.product?.seller?.shop?.vacationStartDate,
      endDate: widget.product?.seller?.shop?.vacationEndDate,
      vacationDurationType: widget.product?.seller?.shop?.vacationDurationType,
      vacationStatus: widget.product?.seller?.shop?.vacationStatus,
      isInHouseSeller: widget.product?.addedBy == 'admin',
    );


    if(widget.product?.addedBy == 'admin') {
      if(widget.product != null && (Provider.of<SplashController>(context, listen: false).configModel?.inhouseTemporaryClose?.status ?? false)){
        temporaryClose = true;
      }else{
        temporaryClose = false;
      }
    } else {
      if(widget.product != null && widget.product!.seller != null && widget.product!.seller!.shop!.temporaryClose!){
        temporaryClose = true;
      }else{
        temporaryClose = false;
      }
    }
  }

  /// True when the product needs CartBottomSheetWidget's fuller resolution
  /// — digital variants or an out-of-stock/restock state — rather than the
  /// page's own inline color + choice-options + quantity. Choice-options
  /// no longer force the sheet: `_CustomizeSection` on the page itself
  /// resolves them the same way the sheet would.
  bool _needsSheet(ProductDetailsModel product, int? stock) {
    final bool isDigital = product.productType == 'digital';
    final bool outOfStock = !isDigital && (stock ?? 0) <= 0;
    return isDigital || outOfStock;
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0),
      builder: (con) => CartBottomSheetWidget(product: widget.product, callback: (){
        showCustomSnackBarWidget(getTranslated('added_to_cart', context), context, snackBarType: SnackBarType.success);
      },)
    );
  }

  void _handleAddTap(BuildContext context) {
    if (_isAdding) return;

    if (vacationIsOn || temporaryClose) {
      showCustomSnackBarWidget(getTranslated('this_shop_is_close_now', context), context, snackBarType: SnackBarType.error);
      return;
    }

    final product = widget.product;
    if (product == null) return;

    final detailsController = Provider.of<ProductDetailsController>(context, listen: false);
    final int variantIndex = detailsController.variantIndex ?? 0;
    final resolved = ProductHelper.resolveVariant(product, variantIndex: variantIndex, variationIndexList: detailsController.variationIndex);

    if (_needsSheet(product, resolved.stock)) {
      _openSheet(context);
      return;
    }

    final int minQty = product.minimumOrderQty ?? 1;
    final int quantity = detailsController.quantity ?? minQty;

    if (quantity < minQty) {
      showCustomSnackBarWidget(getTranslated('to_order_this_item_minimum_order_quantity_is', context), context, snackBarType: SnackBarType.warning);
      return;
    }

    if ((resolved.stock ?? 0) < minQty) {
      showCustomSnackBarWidget(getTranslated('out_of_stock', context), context, snackBarType: SnackBarType.warning);
      return;
    }

    final bool hasColor = product.colors?.isNotEmpty ?? false;

    final cart = CartModelBody(
      productId: product.id,
      variant: hasColor ? product.colors![variantIndex].name : '',
      color: hasColor ? product.colors![variantIndex].code : '',
      variation: resolved.variation,
      quantity: quantity,
    );

    setState(() => _isAdding = true);

    Provider.of<CartController>(context, listen: false).addToCartAPI(
      cart, context, product.choiceOptions ?? [], detailsController.variationIndex,
      popOnSuccess: false,
    ).then((response) {
      if (mounted) setState(() => _isAdding = false);
      if (response.response?.statusCode == 200 && context.mounted) {
        // No snackbar here per user request — navigating straight to the
        // cart page is confirmation enough that the add succeeded.
        RouterHelper.getCartScreenRoute(action: RouteAction.push);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).highlightColor,
        boxShadow: [BoxShadow(color: Theme.of(context).hintColor.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Consumer<ProductDetailsController>(
          builder: (context, detailsController, _) {
            return Row(children: [
              if (product != null) ...[
                InlineQuantityStepper(productModel: product, detailsController: detailsController),
                const SizedBox(width: Dimensions.paddingSizeDefault),
              ],

              // ----------------------------------------------------------
              // Disabled: the old cart-shortcut icon (with item-count
              // badge) that used to sit here, before the quantity stepper
              // took this spot. Kept for reference, not deleted.
              // InkWell(
              //   onTap: () => RouterHelper.getCartScreenRoute(action: RouteAction.push),
              //   borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              //   child: Container(
              //     width: 52,
              //     height: 52,
              //     alignment: Alignment.center,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              //       border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.25)),
              //     ),
              //     child: Stack(clipBehavior: Clip.none, children: [
              //       Image.asset(Images.cartArrowDownImage, height: 22, color: Theme.of(context).textTheme.bodyMedium?.color),
              //       Positioned(
              //         right: -6,
              //         top: -6,
              //         child: Consumer<CartController>(builder: (context, cart, child) {
              //           if (cart.cartList.isEmpty) return const SizedBox.shrink();
              //           return Container(height: ResponsiveHelper.isTab(context)? 22 : 18, width: ResponsiveHelper.isTab(context)? 22 : 18,
              //             alignment: Alignment.center,
              //             decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
              //             child: Center(
              //               child: Text(cart.cartList.length.toString(),
              //                 style: textRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Colors.white)),
              //             ),
              //           );
              //         }),
              //       ),
              //     ]),
              //   ),
              // ),
              // const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(child: InkWell(
                // Disabling the tap handler outright (not just guarding
                // inside _handleAddTap) so rapid taps can't even queue up
                // via the InkWell's own gesture recognizer.
                onTap: _isAdding ? null : () => _handleAddTap(context),
                borderRadius: BorderRadius.circular(Dimensions.radiusHundred),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusHundred),
                    color: _isAdding ? Theme.of(context).primaryColor.withValues(alpha: 0.6) : Theme.of(context).primaryColor),
                  child: _isAdding
                      ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Provider.of<ThemeController>(context, listen: false).darkTheme ? Theme.of(context).hintColor : Colors.white,
                          ),
                        ))
                      : Text(getTranslated('add_to_cart', context)!,
                    style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge,
                        color: Provider.of<ThemeController>(context, listen: false).darkTheme?
                        Theme.of(context).hintColor : Colors.white),),
                ),
              )),
            ]);
          },
        ),
      ),
    );
  }
}
