import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixvalley_vendor_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:sixvalley_vendor_app/helper/color_helper.dart';
import 'package:sixvalley_vendor_app/helper/price_converter.dart';
import 'package:sixvalley_vendor_app/localization/language_constrants.dart';
import 'package:sixvalley_vendor_app/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_vendor_app/features/transaction/controllers/transaction_controller.dart';
import 'package:sixvalley_vendor_app/utill/dimensions.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_vendor_app/common/basewidgets/no_data_screen.dart';
import 'package:sixvalley_vendor_app/features/transaction/screens/transaction_screen.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/wallet_card_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/wallet_transaction_list_view_widget.dart';
import 'package:sixvalley_vendor_app/features/wallet/widgets/withdraw_balance_widget.dart';
import 'package:sixvalley_vendor_app/utill/styles.dart';

class WalletScreen extends StatefulWidget {
  final bool fromNotification;
  const WalletScreen({super.key, this.fromNotification = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  
  @override
  void initState() {
    if(widget.fromNotification && Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
      Provider.of<ProfileController>(context, listen: false).getSellerInfo();
    }

    super.initState();
  }
  final ScrollController _scrollController = ScrollController();


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {

        if(widget.fromNotification) {
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (BuildContext context) => const DashboardScreen(),
          ), (route) => false);

        }else {
          if(!didPop) {
            Navigator.of(context).pop();
          }
        }
      },

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBarWidget(
          title: getTranslated('wallet', context),
          onBackPressed: () {
            if(widget.fromNotification) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const DashboardScreen()));
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            Provider.of<TransactionController>(context, listen: false).getTransactionList(context,'all','','');
            Provider.of<ProfileController>(context, listen: false).getSellerInfo();
          },
          color: Theme.of(context).cardColor,
          backgroundColor: Theme.of(context).primaryColor,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [

              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(children: [
                  Consumer<ProfileController>(
                    builder: (context, seller, child) {
                      return seller.userInfoModel == null ? const SizedBox() : Column(children: [

                        seller.userInfoModel == null ? const SizedBox() : const WithdrawBalanceWidget(),

                        Container(
                          margin: const EdgeInsets.all(Dimensions.fontSizeSmall).copyWith(right: 0, top: Dimensions.paddingSizeDefault),
                          height: 76,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [

                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                  PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                  double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.withdrawn)
                                ) : 0.0)),
                                title: '${getTranslated('withdrawn', context)}',
                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                              ),



                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.pendingWithdraw)
                                ) : 0.0)),
                                title: '${getTranslated('pending_withdrawn', context)}',
                                color: Theme.of(context).colorScheme.surfaceTint,
                              ),

                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                  PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                  double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.commissionGiven)
                                  ) : 0.0)),
                                title: '${getTranslated('commission_given', context)}',
                                color: ColorHelper.darken(Theme.of(context).colorScheme.tertiary, 0.1),
                              ),

                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                  PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                  double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.deliveryChargeEarned)
                                  ) : 0.0)),
                                title: '${getTranslated('delivery_charge_earned', context)}',
                                color: ColorHelper.darken(Theme.of(context).colorScheme.outline, 0.18),
                              ),

                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                  PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                  double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.collectedCash)
                                  ) : 0.0)),
                                title: '${getTranslated('collected_cash', context)}',
                                color: Theme.of(context).colorScheme.onTertiaryContainer
                              ),

                              WalletCardWidget(
                                amount: PriceConverter.showCurrencyCode(context,
                                  PriceConverter.longToShortPrice(seller.userInfoModel!.wallet != null ?
                                  double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.wallet!.totalTaxCollected)
                                  ) : 0.0)),
                                title: '${getTranslated('total_collected_tax', context)}',
                                color: Theme.of(context).colorScheme.error,
                              )
                            ],

                          ),
                        ),

                        if (seller.userInfoModel?.auctionWalletVisible == true) ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Dimensions.fontSizeSmall,
                              Dimensions.paddingSizeDefault,
                              Dimensions.fontSizeSmall,
                              0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                getTranslated('auction_wallet', context)!,
                                style: robotoBold.copyWith(
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(Dimensions.fontSizeSmall).copyWith(right: 0, top: Dimensions.paddingSizeSmall),
                            height: 76,
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: [
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionTotalEarning ?? 0.0)))),
                                  title: getTranslated('auction_total_earning', context)!,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionTotalVat ?? 0.0)))),
                                  title: getTranslated('auction_total_vat', context)!,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionTotalShipping ?? 0.0)))),
                                  title: getTranslated('auction_total_shipping', context)!,
                                  color: ColorHelper.darken(Theme.of(context).colorScheme.outline, 0.18),
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionWithdrawableBalance ?? 0.0)))),
                                  title: getTranslated('auction_withdrawable_balance', context)!,
                                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionPendingWithdraw ?? 0.0)))),
                                  title: getTranslated('auction_pending_withdraw', context)!,
                                  color: Theme.of(context).colorScheme.surfaceTint,
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionTotalCommissionGiven ?? 0.0)))),
                                  title: getTranslated('auction_total_commission_given', context)!,
                                  color: ColorHelper.darken(Theme.of(context).colorScheme.tertiary, 0.1),
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionPendingCommission ?? 0.0)))),
                                  title: getTranslated('auction_pending_commission', context)!,
                                  color: ColorHelper.darken(Theme.of(context).colorScheme.tertiary, 0.2),
                                ),
                                WalletCardWidget(
                                  amount: PriceConverter.showCurrencyCode(context,
                                    PriceConverter.longToShortPrice(
                                      double.parse(PriceConverter.convertPriceWithoutSymbol(context, seller.userInfoModel!.auctionTotalPendingAmount ?? 0.0)))),
                                  title: getTranslated('auction_total_pending_amount', context)!,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ],

                      ]);
                    }
                  ),

                  const _TransactionTitleRowWidget(),

                  Consumer<TransactionController>(
                    builder: (context, transactionProvider, child) {
                      return  Container(
                        child: transactionProvider.transactionList !=null ? transactionProvider.transactionList!.isNotEmpty ?
                        WalletTransactionListViewWidget(transactionProvider: transactionProvider, limit: 10) : const NoDataScreen()
                          : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),
                      );
                    }
                  ),
                ]),
              ))
            ],
          ),
        ),
      ),
    );
  }
}


class _TransactionTitleRowWidget extends StatelessWidget {
  const _TransactionTitleRowWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Dimensions.paddingSizeMedium, Dimensions.paddingSizeSmall, Dimensions.paddingSizeMedium, Dimensions.paddingSizeSmall),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
        Text(getTranslated('withdraw_history', context)!, style: robotoBold.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.50),
            fontSize: Dimensions.fontSizeDefault
        )),

        InkWell(
          onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionScreen())),
          child: Row(children: [
            Text(getTranslated('view_all', context)!, style: robotoBold.copyWith(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: Dimensions.fontSizeSmall,
            )),
            const SizedBox(width: Dimensions.paddingSizeVeryTiny),

            Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSecondary, size: Dimensions.paddingSize)
          ]),
        )
      ]),
    );
  }
}


