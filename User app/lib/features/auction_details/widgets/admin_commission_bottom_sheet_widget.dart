import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_checkout/controllers/auction_checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/widgets/auction_offline_payment_screen.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/controllers/transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';

class AuctionAdminCommissionBottomSheetWidget extends StatefulWidget {
  final int auctionId;
  final double adminCommission;
  final VoidCallback? onSuccess;

  const AuctionAdminCommissionBottomSheetWidget({
    super.key,
    required this.auctionId,
    required this.adminCommission,
    this.onSuccess,
  });

  static Future<void> show(BuildContext context, {
    required int auctionId,
    required double adminCommission,
    VoidCallback? onSuccess,
  }) {
    Provider.of<WalletController>(context, listen: false).getTransactionList(1, reload: false, isUpdate: true);
    Provider.of<AuctionCheckoutController>(context, listen: false).getOfflinePaymentList();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge))),
      builder: (_) => AuctionAdminCommissionBottomSheetWidget(
        auctionId: auctionId,
        adminCommission: adminCommission,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<AuctionAdminCommissionBottomSheetWidget> createState() => _AuctionAdminCommissionBottomSheetWidgetState();
}

class _AuctionAdminCommissionBottomSheetWidgetState extends State<AuctionAdminCommissionBottomSheetWidget> {
  bool _isWalletSelected = false;
  int _selectedOnlineMethodIndex = -1;
  String _selectedOnlineMethodName = '';
  bool _isOfflinePaymentSelected = false;
  int _selectedOfflineMethodIndex = 0;

  void _onWalletTap() {
    setState(() {
      _isWalletSelected = !_isWalletSelected;
      if (_isWalletSelected) {
        _selectedOnlineMethodIndex = -1;
        _selectedOnlineMethodName = '';
        _isOfflinePaymentSelected = false;
      }
    });
  }

  void _onOnlineMethodTap(int index, String keyName) {
    setState(() {
      _selectedOnlineMethodIndex = index;
      _selectedOnlineMethodName = keyName;
      _isWalletSelected = false;
      _isOfflinePaymentSelected = false;
    });
  }

  void _onOfflineToggle() {
    setState(() {
      _isOfflinePaymentSelected = !_isOfflinePaymentSelected;
      if (_isOfflinePaymentSelected) {
        _isWalletSelected = false;
        _selectedOnlineMethodIndex = -1;
        _selectedOnlineMethodName = '';
        _selectedOfflineMethodIndex = 0;
      }
    });
  }

  void _onOfflineMethodChipTap(int index) {
    setState(() {
      _selectedOfflineMethodIndex = index;
    });
  }

  void _onProceed() async {
    if (!_isWalletSelected && _selectedOnlineMethodIndex < 0 && !_isOfflinePaymentSelected) return;

    if (_isOfflinePaymentSelected) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => AuctionOfflinePaymentScreen(
          auctionId: widget.auctionId,
          amount: widget.adminCommission,
          isCommissionPayment: true,
          onSuccess: widget.onSuccess,
        ),
      ));
      return;
    }

    final txController = Provider.of<TransactionController>(context, listen: false);
    final splashController = Provider.of<SplashController>(context, listen: false);
    final currencyCode = splashController.myCurrency?.code ?? 'USD';
    final method = _isWalletSelected ? 'wallet' : _selectedOnlineMethodName;
    await txController.payCommission(
      context,
      auctionProductId: widget.auctionId,
      feeAmount: widget.adminCommission,
      currencyCode: currencyCode,
      paymentMethod: method,
    );

    if (txController.isCommissionPayLoading) return;
    if (!mounted) return;

    final redirectLink = txController.commissionPayRedirectLink;
    if (redirectLink != null) {
      Navigator.pop(context);
      RouterHelper.getAuctionDigitalPaymentScreenRoute(
        url: redirectLink,
        onSuccess: widget.onSuccess,
        action: RouteAction.push,
      );
    } else {
      Navigator.pop(context);
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<SplashController, WalletController, AuctionCheckoutController>(
      builder: (context, splashController, walletController, checkoutController, _) {
        final configModel = splashController.configModel;
        final paymentMethods = configModel?.paymentMethods ?? [];
        final hasDigitalPayment = (configModel?.digitalPayment ?? false) && paymentMethods.isNotEmpty;
        final offlineMethods = checkoutController.offlinePaymentModel?.offlineMethods ?? [];
        final hasOfflinePayment = configModel?.offlinePayment != null && offlineMethods.isNotEmpty;
        final walletBalance = double.tryParse(walletController.walletTransactionModel?.totalWalletBalance.toString() ?? '0') ?? 0.0;

        return Padding(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            left: Dimensions.paddingSizeDefault,
            right: Dimensions.paddingSizeDefault,
            bottom: MediaQuery.of(context).viewInsets.bottom + Dimensions.paddingSizeDefault),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).hintColor.withValues(alpha: .15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: Dimensions.iconSizeSmall,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              Text(getTranslated('choose_payment_method', context) ?? '',
                style: titilliumBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
              Text(getTranslated('pay_commission', context) ?? 'Pay commission',
                style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(PriceConverter.convertPrice(context, widget.adminCommission),
                style: titilliumBold.copyWith(
                  fontSize: 28,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              InkWell(
                onTap: walletController.walletTransactionModel == null ? null : _onWalletTap,
                borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeSmall,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isWalletSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: .5) : Theme.of(context).hintColor.withValues(alpha: .3),
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Row(
                    children: [
                      CustomAssetImageWidget(Images.wallet, height: 24, width: 24),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(getTranslated('pay_via_wallet', context) ?? 'Pay via Wallet',
                              style: titilliumSemiBold.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            walletController.walletTransactionModel == null
                                ? const SizedBox(height: 12, width: 12, child: CircularProgressIndicator(strokeWidth: 1.5),
                            ) : Text(PriceConverter.convertPrice(context, walletBalance),
                              style: titilliumRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Theme(
                        data: Theme.of(context).copyWith(
                          unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                        ),
                        child: Checkbox(
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
                          value: _isWalletSelected,
                          activeColor: Colors.green,
                          checkColor: Theme.of(context).cardColor,
                          onChanged: walletController.walletTransactionModel == null ? null : (_) => _onWalletTap(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              if (hasDigitalPayment) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(getTranslated('pay_via_online', context) ?? '',
                    style: titilliumBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedOnlineMethodIndex >= 0 ? Theme.of(context).colorScheme.primary.withValues(alpha: .5)
                          : Theme.of(context).hintColor.withValues(alpha: .3),
                    ),
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: Dimensions.paddingSizeExtraSmall,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paymentMethods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      final isSelected = _selectedOnlineMethodIndex == index;
                      return InkWell(
                        onTap: () => _onOnlineMethodTap(index, method.keyName ?? ''),
                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeSmall,
                            vertical: Dimensions.paddingSizeExtraSmall,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                  child: CustomImageWidget(
                                    image: '${configModel?.paymentMethodImagePath}/${method.additionalDatas?.gatewayImage ?? ''}',
                                    fit: BoxFit.contain)
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  method.additionalDatas?.gatewayTitle ?? method.keyName ?? '',
                                  style: titilliumRegular.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                ),
                                child: Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge),
                                  ),
                                  value: isSelected,
                                  activeColor: Colors.green,
                                  checkColor: Theme.of(context).cardColor,
                                  onChanged: (_) => _onOnlineMethodTap(index, method.keyName ?? ''),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              if (hasOfflinePayment) ...[
                Container(
                  decoration: BoxDecoration(
                    color: _isOfflinePaymentSelected ? Theme.of(context).primaryColor.withValues(alpha: .10) : null,
                    borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
                    border: Border.all(
                      color: _isOfflinePaymentSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: .5) : Theme.of(context).hintColor.withValues(alpha: .3),
                    ),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        onTap: _onOfflineToggle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                          child: Row(
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  unselectedWidgetColor: Theme.of(context).primaryColor.withValues(alpha: .25),
                                ),
                                child: Checkbox(
                                  visualDensity: VisualDensity.compact,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraLarge)),
                                  value: _isOfflinePaymentSelected,
                                  activeColor: Colors.green,
                                  checkColor: Colors.white,
                                  onChanged: (_) => _onOfflineToggle(),
                                ),
                              ),
                              Text(getTranslated('pay_offline', context) ?? 'Pay Offline',
                                style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_isOfflinePaymentSelected) ...[
                        Padding(
                          padding: const EdgeInsets.only(
                            left: Dimensions.paddingSizeDefault,
                            right: Dimensions.paddingSizeDefault,
                            bottom: Dimensions.paddingSizeDefault,
                          ),
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: offlineMethods.length,
                              itemBuilder: (context, index) {
                                final isSelected = _selectedOfflineMethodIndex == index;
                                return InkWell(
                                  onTap: () => _onOfflineMethodChipTap(index),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                                        border: Border.all(
                                          color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).primaryColor.withValues(alpha: .3),
                                          width: isSelected ? 1.5 : 0.5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                      child: Center(
                                        child: Text(
                                          offlineMethods[index].methodName ?? '',
                                          style: titilliumRegular.copyWith(
                                            fontSize: Dimensions.fontSizeDefault,
                                            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],

              Consumer<TransactionController>(
                builder: (context, txController, _) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: txController.isCommissionPayLoading ? null : _onProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).cardColor,
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                      elevation: 0,
                    ),
                    child: txController.isCommissionPayLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(getTranslated('proceed_now', context) ?? 'Proceed',
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}