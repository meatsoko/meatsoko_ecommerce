import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/controllers/order_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_shimmer_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_type_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/order/widgets/order_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/paginated_list_view_widget.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  final bool isBacButtonExist;
  final bool fromDashboard;
  final bool fromPlaceOrder;
  final VoidCallback? onLoginSuccess;
  final ValueNotifier<bool>? loginNotifier;
  const OrderScreen({super.key, this.isBacButtonExist = true, this.fromDashboard = false, this.fromPlaceOrder = false, this.onLoginSuccess, this.loginNotifier});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  ScrollController scrollController  = ScrollController();
   bool isGuestMode = !Provider.of<AuthController>(Get.context!, listen: false).isLoggedIn();
  @override
  void initState() {
    super.initState();
    widget.loginNotifier?.addListener(_onLoginChanged);
    if (!isGuestMode) {
      Provider.of<OrderController>(context, listen: false).setIndex(0, notify: false);
      Provider.of<OrderController>(context, listen: false).getOrderList(1, 'ongoing');
    }
  }

  void _onLoginChanged() {
    if (!mounted) return;
    final bool loggedIn = widget.loginNotifier?.value ?? false;

    if (loggedIn && isGuestMode) {
      // Guest -> logged in: load the order list.
      setState(() => isGuestMode = false);
      Provider.of<OrderController>(context, listen: false)
        ..setIndex(0, notify: false)
        ..getOrderList(1, 'ongoing');
    } else if (!loggedIn && !isGuestMode) {
      // Logged in -> logged out (sign out / account deletion): drop back to the guest view.
      setState(() => isGuestMode = true);
      Provider.of<OrderController>(context, listen: false).resetOrderList();
    }
  }

  @override
  void dispose() {
    widget.loginNotifier?.removeListener(_onLoginChanged);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if(widget.fromPlaceOrder) {
          RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
        } else {
          return;
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          return await Provider.of<OrderController>(context, listen: false).getOrderList(
            1, Provider.of<OrderController>(context, listen: false).selectedType, refresh: true
          );
        },
        child: Scaffold(
         appBar: CustomAppBar(title: getTranslated('order', context), isBackButtonExist: widget.isBacButtonExist,
         onBackPressed: () {
           if(widget.fromPlaceOrder) {
             RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
           } else {
             Navigator.of(context).pop();
           }
          },
         ),
          body: isGuestMode ? NotLoggedInWidget(
            message: getTranslated('to_view_the_order_history', context),
            fromPage: widget.fromDashboard ? '${RouterHelper.dashboardScreen}?page=orders' : RouterHelper.orderScreen,
            onLoginSuccess: () {
              if (mounted) {
                setState(() => isGuestMode = false);
                Provider.of<OrderController>(context, listen: false)
                  ..setIndex(0, notify: false)
                  ..getOrderList(1, 'ongoing');
              }
              widget.onLoginSuccess?.call();
            },
          ) :
          Consumer<OrderController>(
            builder: (context, orderController, child) {
              return Column(children: [


                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeSmall),
                  child: Row(children: [
                    OrderTypeButton(text: getTranslated('RUNNING', context), index: 0),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    OrderTypeButton(text: getTranslated('DELIVERED', context), index: 1),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    OrderTypeButton(text: getTranslated('CANCELED', context), index: 2)])),



                  Expanded(child: orderController.orderModel != null ? (orderController.orderModel!.orders != null &&
                      orderController.orderModel!.orders!.isNotEmpty)?
                    SingleChildScrollView(
                      controller: scrollController,
                      child: PaginatedListView(scrollController: scrollController,
                        onPaginate: (int? offset) async{
                          await orderController.getOrderList(offset!, orderController.selectedType);
                        },
                        totalSize: orderController.orderModel?.totalSize,
                        offset: orderController.orderModel?.offset != null ? int.parse(orderController.orderModel!.offset!):1,
                        itemView: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (orderController.orderModel?.orders!.length ?? 0) + 1,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            if (index == orderController.orderModel?.orders!.length) {
                              return SizedBox(height: MediaQuery.of(context).padding.bottom);
                            }
                            return OrderWidget(orderModel: orderController.orderModel?.orders![index]);
                          },
                        ),
                      ),
                    ) : const NoInternetOrDataScreenWidget(isNoInternet: false, icon: Images.noOrder, message: 'no_order_found') :
                      const OrderShimmerWidget()
                  )

                ],
              );
            }
          ),
        ),
      ),
    );
  }
}




