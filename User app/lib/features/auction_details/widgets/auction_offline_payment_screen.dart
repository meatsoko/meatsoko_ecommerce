import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_textfield_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/participator/auction_participation_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/domain/models/offline_payment_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/offline_payment/widgets/offline_card_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/controllers/transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/helper/velidate_check.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionOfflinePaymentScreen extends StatefulWidget {
  final double amount;
  final int auctionId;
  final String auctionStatus;
  final bool isCommissionPayment;
  final VoidCallback? onSuccess;

  const AuctionOfflinePaymentScreen({
    super.key,
    required this.amount,
    required this.auctionId,
    this.auctionStatus = '',
    this.isCommissionPayment = false,
    this.onSuccess,
  });

  @override
  State<AuctionOfflinePaymentScreen> createState() => _AuctionOfflinePaymentScreenState();
}

class _AuctionOfflinePaymentScreenState
    extends State<AuctionOfflinePaymentScreen> {
  final TextEditingController _noteController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('offline_payment', context)),
      body: Consumer<AuctionCheckoutController>(
        builder: (context, checkoutController, _) {
          final offlineMethods =
              checkoutController.offlinePaymentModel?.offlineMethods ?? [];

          if (offlineMethods.isEmpty) {
            return Center(
              child: Text(
                getTranslated('no_payment_method_available_right_now', context) ?? '',
                style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.homePagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: SizedBox(
                          height: 100,
                          child: Image.asset(Images.offlinePayment),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault),
                        child: Text(getTranslated('offline_payment_helper_text', context) ?? '',
                          textAlign: TextAlign.center,
                          style: textRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 190,
                        child: RepaintBoundary(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: offlineMethods.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                splashColor: Colors.transparent,
                                onTap: () => checkoutController.setOfflinePaymentMethodSelectedIndex(index),
                                child: OfflineCardWidget(
                                  selectedIndex: checkoutController.offlineMethodSelectedIndex,
                                  offlinePaymentModel: offlineMethods[index],
                                  index: index,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                          child: Text('${getTranslated('amount', context)} : ${PriceConverter.convertPrice(context, widget.amount)}',
                            style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                        ),
                      ),

                      Text(getTranslated('payment_info', context) ?? '',
                        style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                      ),

                      Form(
                        key: _formKey,
                        child: RepaintBoundary(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: offlineMethods.isNotEmpty
                                ? (offlineMethods[checkoutController.offlineMethodSelectedIndex].methodInformations?.length ?? 0) : 0,
                            itemBuilder: (context, index) {
                              final MethodInformations? info = offlineMethods[checkoutController.offlineMethodSelectedIndex].methodInformations?[index];

                              return Padding(
                                padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                child: CustomTextFieldWidget(
                                  controller: checkoutController.inputFieldControllerList[index],
                                  required: info?.isRequired == 1,
                                  labelText: '${info?.customerInput}'.replaceAll('_', ' ').capitalize(),
                                  hintText: '${info?.customerPlaceholder}'.replaceAll('_', ' ').capitalize(),
                                  validator: (value) {
                                    if (info?.isRequired == 1) {
                                      return ValidateCheck.validateEmptyText(value, '${info?.customerInput}'.replaceAll('_', ' ').capitalize(),);
                                    }
                                    return null;
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: Dimensions.paddingSizeDefault),
                      CustomTextFieldWidget(
                        controller: _noteController,
                        labelText: getTranslated('note', context),
                        hintText: getTranslated('note', context),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer3<AuctionCheckoutController,
          AuctionParticipationController, TransactionController>(
        builder: (context, checkoutController, participationController, txController, _) {
          final isLoading = widget.isCommissionPayment ? txController.isCommissionPayLoading : participationController.isEntryFeeLoading;

          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: CustomButton(
              isLoading: isLoading,
              buttonText: getTranslated('proceed', context),
              onTap: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;

                final Map<String, String> methodInformations = {};
                for (int i = 0; i < checkoutController.keyList.length; i++) {
                  methodInformations[checkoutController.keyList[i] ?? ''] = checkoutController.inputFieldControllerList[i].text.trim();
                }

                final String? paymentNote = _noteController.text.trim().isEmpty ? null : _noteController.text.trim();

                if (widget.isCommissionPayment) {
                  final splashController = Provider.of<SplashController>(context, listen: false);
                  final selectedCurrency = splashController.myCurrency?.code ?? 'USD';
                  await txController.payCommission(
                    context,
                    auctionProductId: widget.auctionId,
                    feeAmount: widget.amount,
                    currencyCode: selectedCurrency,
                    paymentMethod: 'offline_payment',
                    methodId: checkoutController.offlineMethodSelectedId,
                    methodName: checkoutController.offlineMethodSelectedName,
                    methodInformations: methodInformations,
                    paymentNote: paymentNote,
                  );
                  if (!txController.isCommissionPayLoading && context.mounted) {
                    Navigator.of(context).pop();
                    widget.onSuccess?.call();
                  }
                } else {
                  final splashController = Provider.of<SplashController>(context, listen: false);
                  final selectedCurrency = splashController.myCurrency?.code ?? 'USD';

                  await participationController.payAuctionEntryFee(
                    context,
                    auctionProductId: widget.auctionId,
                    feeAmount: widget.amount,
                    currency: selectedCurrency,
                    auctionStatus: widget.auctionStatus,
                    paymentMethod: 'offline_payment',
                    methodId: checkoutController.offlineMethodSelectedId,
                    methodName: checkoutController.offlineMethodSelectedName,
                    methodInformations: methodInformations,
                    paymentNote: paymentNote,
                  );

                  if (participationController.isEntryFeePaid && context.mounted) {
                    participationController.resetPaymentState();
                    Navigator.of(context).pop(true);
                    showCustomSnackBarWidget(getTranslated('auction_entry_fee_paid_successfully', Get.context!) ?? '', Get.context!, snackBarType: SnackBarType.success);
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}

extension _StringCapitalize on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
