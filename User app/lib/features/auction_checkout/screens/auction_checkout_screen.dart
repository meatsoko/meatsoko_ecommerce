import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/amount_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/widgets/auction_choose_payment_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/widgets/auction_payment_method_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/widgets/auction_shipping_details_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/checkout_condition_checkbox.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/widgets/auction_order_place_bottomsheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';


class AuctionCheckoutScreen extends StatefulWidget {
  final int productId;
  final double myBidAmount;
  final double highestBidAmount;
  final double startingPrice;
  final double shippingFee;
  final double tax;

  const AuctionCheckoutScreen({super.key, required this.productId, required this.myBidAmount, required this.highestBidAmount, required this.startingPrice, required this.shippingFee, required this.tax});

  @override
  AuctionCheckoutScreenState createState() => AuctionCheckoutScreenState();
}

class AuctionCheckoutScreenState extends State<AuctionCheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> passwordFormKey = GlobalKey<FormState>();

  double _subtotal = 0;
  double _shippingFee = 0;
  double _tax = 0;
  late bool _billingAddress;

  SplashController splashController = Provider.of<SplashController>(Get.context!, listen: false);

  @override
  void initState() {
    super.initState();
    Provider.of<AddressController>(context, listen: false).getAddressList();
    Provider.of<AuctionCheckoutController>(context, listen: false).clearData();

    if (splashController.configModel != null && splashController.configModel!.offlinePayment != null) {
      Provider.of<AuctionCheckoutController>(context, listen: false).getOfflinePaymentList();
    }
    Provider.of<ProfileController>(context, listen: false).getUserInfo(context);

    _billingAddress = splashController.configModel!.billingInputByCustomer == 1;

    _subtotal = widget.myBidAmount;
    _shippingFee = widget.shippingFee;
    _tax = widget.tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      bottomNavigationBar: Consumer<AddressController>(builder: (context, locationProvider, _) {
        return Consumer<AuctionCheckoutController>(
            builder: (context, orderProvider, child) {
          return Consumer<ProfileController>(
              builder: (context, profileProvider, _) {
            double totalPayable = _subtotal + _shippingFee + _tax;

            return orderProvider.isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [SizedBox(width: 30, height: 30, child: CircularProgressIndicator())]
                )
                : Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CheckoutConditionCheckBox(),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${getTranslated('final_bid_price', context) ?? " "} ${splashController.configModel?.systemTaxIncludeStatus == 1 ? "(${getTranslated('inc_vat_tax', context)})" : ""}',
                                style: textRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                              ),
                            ),
                            Text(PriceConverter.convertPrice(context, totalPayable),
                              style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        CustomButton(
                          onTap: (orderProvider.isLoading )
                            ? null
                            : () async {
                                if (orderProvider.addressIndex == null) {
                                  RouterHelper.getAuctionSavedAddressListRoute(fromGuest: !Provider.of<AuthController>(context, listen: false).isLoggedIn());
                                  showCustomSnackBarWidget(getTranslated('select_a_shipping_address', context), Get.context!, snackBarType: SnackBarType.warning);
                                } else if (orderProvider.billingAddressIndex == null && _billingAddress && !orderProvider.sameAsBilling) {
                                  RouterHelper.getAuctionSavedBillingAddressListRoute(fromGuest: !Provider.of<AuthController>(context, listen: false).isLoggedIn());
                                  showCustomSnackBarWidget(getTranslated('select_a_billing_address', context), Get.context!, snackBarType: SnackBarType.warning);
                                } else {
                                  String paymentMethod = '';
                                  if (orderProvider.paymentMethodIndex != -1) {
                                    paymentMethod = orderProvider.selectedDigitalPaymentMethodName;
                                  } else if (orderProvider.isOfflineChecked) {
                                    paymentMethod = 'offline_payment';
                                  } else if (orderProvider.isWalletChecked) {
                                    paymentMethod = 'wallet';
                                  } else if (orderProvider.isCODChecked) {
                                    paymentMethod = 'cash_on_delivery';
                                  } else {
                                    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
                                      builder: (c) {
                                        return AuctionPaymentMethodBottomSheetWidget(onlyDigital: false, totalAmount: totalPayable);
                                      },
                                    );
                                    return;
                                  }

                                  if (paymentMethod == 'offline_payment') {
                                    Navigator.pushNamed(context, RouterHelper.getAuctionOfflinePaymentRoute(totalPayable, widget.productId));
                                    return;
                                  }

                                  final addressData = orderProvider.getAddressData(locationProvider.addressList!, _billingAddress);
                                  if (addressData == null) return;

                                  await orderProvider.claimAuction(
                                    auctionProductId: widget.productId,
                                    paymentMethod: paymentMethod,
                                    paymentPlatform: 'app',
                                    currentCurrencyCode: splashController.configModel?.systemDefaultCurrency?.toString() ?? 'USD',
                                    addressId: addressData.addressId,
                                    billingAddressId: addressData.billingAddressId,
                                    shippingAddressInfo: addressData.shippingAddressInfo,
                                    billingAddressInfo: addressData.billingAddressInfo,
                                    paymentNote: orderProvider.orderNoteController.text,
                                    callback: (isSuccess, message, redirectLink) {
                                      if (isSuccess) {
                                        if (redirectLink != null) {
                                          RouterHelper.getAuctionDigitalPaymentScreenRoute(url: redirectLink, action: RouteAction.push);
                                        } else {
                                          _callback(isSuccess, message, false);
                                        }
                                      } else {
                                        showCustomSnackBarWidget(message, context, snackBarType: SnackBarType.error);
                                      }
                                    },
                                  );
                                }
                              },
                          buttonText: getTranslated('proceed_to_checkout', context) ?? " ",
                        )
                      ],
                    ),
                  );
          });
        });
      }),


      appBar: CustomAppBar(title: getTranslated('auction_checkout', context) ?? ""),
      body: Consumer<AuctionCheckoutController>(builder: (context, orderProvider, _) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(0),
                children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                    child: AuctionShippingDetailsWidget(
                      hasPhysical: true,
                      billingAddress: _billingAddress,
                      passwordFormKey: passwordFormKey,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: AuctionChoosePaymentWidget(onlyDigital: false, totalAmount: _subtotal + _shippingFee + _tax),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).hintColor.withValues(alpha: 0.2), spreadRadius: 3, blurRadius: 3)
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeDefault,
                      Dimensions.paddingSizeSmall,
                    ),
                    child: Text(
                      getTranslated('auction_summary', context) ?? 'Auction Summary',
                      style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AmountWidget(
                          title: getTranslated('sub_total', context),
                          amount: PriceConverter.convertPrice(context, _subtotal),
                        ),
                        AmountWidget(
                          title: getTranslated('shipping_fee', context),
                          amount: PriceConverter.convertPrice(context, _shippingFee),
                        ),

                        if (_tax > 0)
                          AmountWidget(
                            title: getTranslated('tax', context),
                            amount: PriceConverter.convertPrice(context, _tax),
                          ),
                        Divider(height: 5, color: Theme.of(context).hintColor),

                        AmountWidget(
                          fontSize: Dimensions.fontSizeLarge,
                          isTitleBlack: true,
                          title: '${getTranslated('total_payable', context)} ${splashController.configModel?.systemTaxIncludeStatus == 1 ? "(${getTranslated('inc_vat_tax', context)})" : ''} ',
                          amount: PriceConverter.convertPrice(context, _subtotal + _shippingFee + _tax),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _callback(bool isSuccess, String message, bool createAccount) async {
    if (isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'auction');

        Future.delayed(const Duration(milliseconds: 300), () {
          showModalBottomSheet(
            isDismissible: false,
            enableDrag: false,
            context: Get.context!,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return AuctionOrderPlaceBottomSheetWidget(
                title: getTranslated('auction_claimed_successfully', Get.context!),
                description: getTranslated('your_auction_claimed_successfully', Get.context!),
              );
            },
          );
        });
      });
    } else {
      showCustomSnackBarWidget(message, context,
          snackBarType: SnackBarType.error);
    }
  }
}
