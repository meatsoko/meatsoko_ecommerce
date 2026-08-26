import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/auction/controllers/auction_product_controller.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/auction_action_sheet_widget.dart';
import 'package:sixvalley_vendor_app/features/auction/widgets/payment_widgets/custom_check_box_widget.dart';
import 'package:sixvalley_vendor_app/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

/// Lets the vendor pick how to pay the admin commission for a delivered
/// auction: wallet, offline payment, or one of the configured digital
/// gateways. When [onlyDigital] is true, only the digital gateway list is
/// shown (used for the "Pay Now" flow, which doesn't support COD).
class PaymentMethodBottomSheetWidget extends StatelessWidget {
  final bool onlyDigital;
  const PaymentMethodBottomSheetWidget({super.key, this.onlyDigital = false});

  @override
  Widget build(BuildContext context) {
    final paymentMethods = Provider.of<SplashController>(context, listen: false).configModel?.paymentMethods ?? [];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(Dimensions.paddingSizeDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(getTranslated('select_payment_method', context) ?? 'Select Payment Method', style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              )),
              InkWell(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.clear)),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            Flexible(
              child: Consumer<AuctionProductController>(
                builder: (context, controller, child) {
                  return SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (!onlyDigital) ...[
                        _PaymentOptionTile(
                          icon: Icons.account_balance_wallet_outlined,
                          title: getTranslated('wallet_payment', context) ?? 'Wallet Payment',
                          isSelected: controller.isWalletChecked,
                          onTap: () => controller.setOfflineChecked('wallet'),
                        ),
                        _PaymentOptionTile(
                          icon: Icons.receipt_long_outlined,
                          title: getTranslated('offline_payment', context) ?? 'Offline Payment',
                          isSelected: controller.isOfflineChecked,
                          onTap: () => controller.setOfflineChecked('offline'),
                        ),
                      ],
                      for (int i = 0; i < paymentMethods.length; i++)
                        CustomCheckBoxWidget(
                          index: i,
                          isDigital: true,
                          icon: paymentMethods[i].additionalDatas?.gatewayImage,
                          name: paymentMethods[i].keyName ?? '',
                          title: paymentMethods[i].additionalDatas?.gatewayTitle ?? paymentMethods[i].keyName ?? '',
                        ),
                    ]),
                  );
                },
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeSmall),
            SizedBox(width: double.infinity, child: CustomButton(
              label: getTranslated('continue', context) ?? 'Continue',
              onPressed: () => Navigator.of(context).pop(),
            )),
          ]),
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({required this.icon, required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: Row(children: [
          Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          Expanded(child: Text(title, style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ))),
          Checkbox(
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
            value: isSelected,
            activeColor: Colors.green,
            checkColor: Theme.of(context).cardColor,
            onChanged: (_) => onTap(),
          ),
        ]),
      ),
    );
  }
}
