import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/filter_icon_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/no_internet_screen_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/home/shimmers/transaction_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/controllers/loyalty_point_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/domain/models/loyalty_point_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/widget/loyalty_filter_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/widget/loyalty_point_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/profile/controllers/profile_contrroller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_loggedin_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/loyaltyPoint/widget/loyalty_point_converter_dialogue_widget.dart';
import 'package:provider/provider.dart';

class LoyaltyPointScreen extends StatefulWidget {
  const LoyaltyPointScreen({super.key});

  @override
  State<LoyaltyPointScreen> createState() => _LoyaltyPointScreenState();
}

class _LoyaltyPointScreenState extends State<LoyaltyPointScreen> {

  @override
  void initState() {
    super.initState();

    if (context.read<AuthController>().isLoggedIn()) {
      context.read<LoyaltyPointController>().getLoyaltyPointList(context, 1, isUpdate: false);
    }
  }

  int _getFilterCount(LoyaltyPointModel? model) {
    if (model == null) return 0;

    final baseFilters = [
      model.filterBy,
      model.startDate,
    ].whereType<Object>().length;

    return baseFilters + (model.transactionTypes?.length ?? 0);
  }

  bool _isFilterApplied(LoyaltyPointModel? model) => _getFilterCount(model) > 0;

  bool _isListEmpty(LoyaltyPointModel? model) => model?.loyaltyPointList?.isEmpty ?? true;

  // Header (title + filter icon) and the convert button are shown when the list has
  // data or when a filter is applied (even if the result is empty). They are hidden
  // during the initial load (shimmer) and when there is no history and no filter.
  bool _showHeaderAndConvert(LoyaltyPointModel? model) {
    if (model == null) return false;
    return !_isListEmpty(model) || _isFilterApplied(model);
  }

  @override
  Widget build(BuildContext context) {
    final bool isGuest = !context.read<AuthController>().isLoggedIn();

    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('loyalty_point', context)),
      body: isGuest
          ? Center(child: NotLoggedInWidget(fromPage: RouterHelper.loyaltyPointScreen))
          : Consumer<LoyaltyPointController>(
              builder: (_, controller, __) {
                final model = controller.loyaltyPointModel;

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.getLoyaltyPointList(context, 1);
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      if (_showHeaderAndConvert(model)) _buildHeader(context, model),
                      _buildContent(context, model),
                    ],
                  ),
                );
              },
            ),

      floatingActionButton: isGuest
          ? null
          : Consumer<LoyaltyPointController>(
              builder: (_, controller, __) {
                if (!_showHeaderAndConvert(controller.loyaltyPointModel)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeThirty),
                  child: Consumer<ProfileController>(
                    builder: (_, profile, __) {
                      return CustomButton(
                        leftIcon: Images.dollarIcon,
                        buttonText: getTranslated('convert_to_currency', context)!,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: LoyaltyPointConverterDialogueWidget(
                                myPoint: profile.userInfoModel?.loyaltyPoint ?? 0,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader(BuildContext context, LoyaltyPointModel? model) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _FilterHeaderDelegate(
        child: Container(
          height: 60,
          color: Theme.of(context).canvasColor,
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.homePagePadding,
            vertical: Dimensions.paddingSizeSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslated('point_history', context)!,
                style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              FilterIconWidget(
                filterCount: _getFilterCount(model),
                onTap: model == null ? null : () {
                  showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (_) => const LoyaltyFilterBottomSheetWidget());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LoyaltyPointModel? model) {
    if (model == null) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.homePagePadding,
            vertical: Dimensions.paddingSizeDefault,
          ),
          child: TransactionShimmer(),
        ),
      );
    }

    final List<LoyaltyPointList> list = model.loyaltyPointList ?? [];

    if (list.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: NoInternetOrDataScreenWidget(
            isNoInternet: false,
            icon: Images.noTransactionIcon,
            message: 'no_transaction_history',
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => LoyaltyPointWidget(
          loyaltyPointModel: list[index],
          isLastItem: index == list.length - 1,
        ),
        childCount: list.length,
      ),
    );
  }
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
