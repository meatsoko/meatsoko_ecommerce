import 'package:flutter/material.dart';
import 'package:user_app/features/profile/controllers/profile_contrroller.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/features/auth/controllers/auth_controller.dart';
import 'package:user_app/features/coupon/controllers/coupon_controller.dart';
import 'package:user_app/utill/dimensions.dart';
import 'package:user_app/utill/images.dart';
import 'package:user_app/common/basewidget/custom_app_bar_widget.dart';
import 'package:user_app/common/basewidget/no_internet_screen_widget.dart';
import 'package:user_app/common/basewidget/not_loggedin_widget.dart';
import 'package:user_app/features/coupon/widgets/coupon_item_widget.dart';
import 'package:user_app/features/order/widgets/order_shimmer_widget.dart';
import 'package:provider/provider.dart';

class CouponList extends StatefulWidget {
  const CouponList({super.key});

  @override
  State<CouponList> createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {
  @override
  void initState() {
    if(Provider.of<AuthController>(context, listen: false).isLoggedIn()){
      Provider.of<CouponController>(context, listen: false).getCouponList(context, 1);
      if(Provider.of<ProfileController>(context, listen: false).userInfoModel == null) {
        Provider.of<ProfileController>(context, listen: false).getUserInfo(context);
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('coupons', context)),
      body: Provider.of<AuthController>(context, listen: false).isLoggedIn()?

      Consumer<CouponController>(
        builder: (context, couponProvider,_) {
          return couponProvider.couponList != null ? couponProvider.couponList!.isNotEmpty ?
          Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: couponProvider.couponList!.length,
              itemBuilder: (context, index)=> CouponItemWidget(coupons: couponProvider.couponList![index])
            )) :
          const NoInternetOrDataScreenWidget(isNoInternet: false,
            icon: Images.noCoupon, message: 'no_coupon_available') : const OrderShimmerWidget();
        }
      ): NotLoggedInWidget(
        fromPage: RouterHelper.couponListScreen,
        onLoginSuccess: (){
          RouterHelper.getCouponListScreenRoute(action: RouteAction.pushReplacement);
        }
      ),
    );
  }
}