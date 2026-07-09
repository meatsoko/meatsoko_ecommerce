import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/address/controllers/address_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_bottomsheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/offline_card_widget.dart';
import 'package:provider/provider.dart';

class AuctionOfflinePaymentScreen extends StatefulWidget {
  final double payableAmount;
  final int auctionProductId;
  const AuctionOfflinePaymentScreen({super.key, required this.payableAmount, required this.auctionProductId});

  @override
  State<AuctionOfflinePaymentScreen> createState() => _AuctionOfflinePaymentScreenState();
}

class _AuctionOfflinePaymentScreenState extends State<AuctionOfflinePaymentScreen> {
  TextEditingController paymentController = TextEditingController();
  final GlobalKey<FormState> offlineFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('offline_payment', context)),
      body: Consumer<AuctionCheckoutController>(
        builder: (context, auctionCheckoutController, _) {
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Center(child: SizedBox(height: 100, child: Image.asset(Images.offlinePayment))),
                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Text('${getTranslated('offline_payment_helper_text', context)}', textAlign: TextAlign.center,
                      style: textRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault)),),

                if(auctionCheckoutController.offlinePaymentModel != null && auctionCheckoutController.offlinePaymentModel!.offlineMethods != null &&
                    auctionCheckoutController.offlinePaymentModel!.offlineMethods!.isNotEmpty)
                  SizedBox(height: 190,
                    child: RepaintBoundary(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: auctionCheckoutController.offlinePaymentModel!.offlineMethods!.length,
                        itemBuilder: (context, index){
                          return InkWell(
                            splashColor: Colors.transparent,
                            onTap: (){
                              if(auctionCheckoutController.offlinePaymentModel?.offlineMethods != null &&
                                  auctionCheckoutController.offlinePaymentModel!.offlineMethods!.isNotEmpty){
                                auctionCheckoutController.setOfflinePaymentMethodSelectedIndex(index);
                              }
                            }, child: OfflineCardWidget(
                              selectedIndex: auctionCheckoutController.offlineMethodSelectedIndex,
                              offlinePaymentModel: auctionCheckoutController.offlinePaymentModel!.offlineMethods![index],
                              index: index));
                        }),
                    )),

                Center(child: Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Text('${getTranslated('amount', context)} : ${PriceConverter.convertPrice(context, widget.payableAmount)}',
                    style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge)))),

                Text('${getTranslated('payment_info', context)}', style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),),

                Form(
                  key: offlineFormKey,
                  child: RepaintBoundary(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: auctionCheckoutController.offlinePaymentModel!.offlineMethods![auctionCheckoutController.offlineMethodSelectedIndex].methodInformations?.length,
                      itemBuilder: (context, index){
                        MethodInformations? methodInformation = auctionCheckoutController.offlinePaymentModel!.offlineMethods![auctionCheckoutController.offlineMethodSelectedIndex].methodInformations?[index];

                        return Padding(
                          padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                          child: CustomTextFieldWidget(
                            controller: auctionCheckoutController.inputFieldControllerList[index],
                            required: methodInformation?.isRequired == 1,
                            labelText: '${methodInformation?.customerInput}'.replaceAll('_', ' ').capitalize(),
                            hintText: '${methodInformation?.customerPlaceholder}'.replaceAll('_', ' ').capitalize(),
                            validator: (value) {
                              if(methodInformation?.isRequired == 1) {
                                return ValidateCheck.validateEmptyText(value, '${methodInformation?.customerInput}'.replaceAll('_', ' ').capitalize());
                              }else{
                                return null;
                              }
                            },
                          ),
                        );
                      }),
                  ),
                ),

                const SizedBox(height: 20,),
                CustomTextFieldWidget(controller: paymentController,
                  labelText:  getTranslated('note', context),
                  hintText: getTranslated('note', context),),
                const SizedBox(height: 20,),
              ])))]);}),

      bottomNavigationBar: Consumer<AuctionCheckoutController>(
        builder: (context, auctionCheckoutController, _) {
          return Consumer<AddressController>(
            builder: (context, locationProvider,_) {
              return Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(
                  isLoading: auctionCheckoutController.isLoading,
                  onTap: (){
                    if(offlineFormKey.currentState?.validate() ?? false){
                      String paymentNote = paymentController.text.trim();
                      
                      final splashController = Provider.of<SplashController>(context, listen: false);
                      
                      final addressData = auctionCheckoutController.getAddressData(locationProvider.addressList!, splashController.configModel?.billingInputByCustomer == 1);
                      if (addressData == null) return;

                      final Map<String, String> methodInformations = {};
                      for (int i = 0; i < auctionCheckoutController.keyList.length; i++) {
                        methodInformations[auctionCheckoutController.keyList[i] ?? ''] = auctionCheckoutController.inputFieldControllerList[i].text.trim();
                      }

                      auctionCheckoutController.claimAuction(
                        auctionProductId: widget.auctionProductId,
                        paymentMethod: 'offline_payment',
                        paymentPlatform: 'app',
                        currentCurrencyCode: splashController.myCurrency?.code ?? 'USD',
                        addressId: addressData.addressId,
                        billingAddressId: addressData.billingAddressId,
                        shippingAddressInfo: addressData.shippingAddressInfo,
                        billingAddressInfo: addressData.billingAddressInfo,
                        paymentNote: paymentNote,
                        methodId: auctionCheckoutController.offlineMethodSelectedId,
                        methodName: auctionCheckoutController.offlineMethodSelectedName,
                        methodInformations: methodInformations,
                        callback: (isSuccess, message, redirectLink) {
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
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: OrderPlaceBottomSheetWidget(
                                        orderID: '',
                                        icon: Icons.check,
                                        title: getTranslated('auction_claimed_successfully', Get.context!),
                                        description: getTranslated('your_auction_claimed_successfully', Get.context!),
                                        isFailed: false,
                                      ),
                                    );
                                  },
                                );
                              });
                            });
                          } else {
                            showCustomSnackBarWidget(message, context, snackBarType: SnackBarType.error);
                          }
                        },
                      );
                    }
                  },
                  buttonText: getTranslated('proceed', context),
                ),
              );
            }
          );
        }
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
