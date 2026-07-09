import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/controllers/search_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/shop/domain/models/shop_navigation_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/wishlist/controllers/wishlist_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/not_logged_in_bottom_sheet_widget.dart';
import 'package:provider/provider.dart';

class FavouriteButtonWidget extends StatefulWidget {
  final Color backgroundColor;
  final int? productId;
  final bool? fromProductDetails;
  final SellerNavigationModel? sellerNavigationModel;

  const FavouriteButtonWidget({
    super.key,
    this.backgroundColor = Colors.black,
    this.productId,
    this.fromProductDetails = false,
    this.sellerNavigationModel,
  });

  @override
  State<FavouriteButtonWidget> createState() => _FavouriteButtonWidgetState();
}

class _FavouriteButtonWidgetState extends State<FavouriteButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  bool _localIsInWishlist = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final wishController = Provider.of<WishListController>(context, listen: false);
      final isInWishlist = wishController.addedIntoWish.contains(widget.productId);
      _localIsInWishlist = isInWishlist;
      _animController.value = isInWishlist ? 1.0 : 0.0;
      _initialized = true;
    }
  }

  void _syncWithProvider(bool providerState) {
    if (!_initialized || _animController.isAnimating) return;
    if (providerState == _localIsInWishlist) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _localIsInWishlist = providerState);
      _animController.value = providerState ? 1.0 : 0.0;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeController>(context).darkTheme;

    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final isGuestMode = !authController.isLoggedIn();
        return Consumer<WishListController>(
          builder: (context, wishProvider, _) {
            _syncWithProvider(wishProvider.addedIntoWish.contains(widget.productId));

            return GestureDetector(
              onTap: () {
                final currentRouteName = ModalRoute.of(context)?.settings.name;
                final searchProvider = Provider.of<SearchProductController>(context, listen: false);

                if (isGuestMode) {
                  if (searchProvider.searchFocusNode.hasFocus) {
                    searchProvider.searchFocusNode.unfocus();
                  }
                  showModalBottomSheet(backgroundColor: Colors.transparent,
                    context: context, builder: (_)=> NotLoggedInBottomSheetWidget(
                      fromFavoriteButton: true,
                      fromPage: currentRouteName,
                      onLoginSuccess: widget.sellerNavigationModel?.sellerId == null ? null : () {
                              RouterHelper.getTopSellerRoute(
                                action: RouteAction.pushReplacement,
                                slug: widget.sellerNavigationModel?.slug,
                                sellerId: widget.sellerNavigationModel?.sellerId,
                                temporaryClose: widget.sellerNavigationModel?.temporaryClose,
                                vacationStatus: widget.sellerNavigationModel?.vacationStatus,
                                vacationEndDate: widget.sellerNavigationModel?.vacationEndDate,
                                vacationStartDate: widget.sellerNavigationModel?.vacationStartDate,
                                vacationDurationType: widget.sellerNavigationModel?.vacationDurationType,
                                name: widget.sellerNavigationModel?.name,
                                banner: widget.sellerNavigationModel?.banner,
                                image: widget.sellerNavigationModel?.image,
                                fromMore: widget.sellerNavigationModel?.fromMore,
                                totalReview: widget.sellerNavigationModel?.totalReview,
                                totalProduct: widget.sellerNavigationModel?.totalProduct,
                              );
                            },
                    ),
                  );
                } else {
                  final newState = !_localIsInWishlist;
                  setState(() => _localIsInWishlist = newState);
                  if (newState) {
                    _animController.forward(from: 0.0);
                    wishProvider.addWishList(widget.productId);
                  } else {
                    _animController.reverse(from: 1.0);
                    wishProvider.removeWishList(widget.productId);
                  }
                }
              },
              child: Container(
                height: (widget.fromProductDetails ?? false) ? 40 : null,
                width: (widget.fromProductDetails ?? false) ? 40 : null,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.transparent : Theme.of(context).cardColor,
                  border: Border.all(color: isDarkMode ? Theme.of(context).primaryColor : Colors.transparent, width: 1),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.10),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0,3),
                  )],
                ),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeEight),
                  transform: Matrix4.translationValues(0, 1, 0),
                  child: SizedBox(
                    width: Dimensions.paddingSizeDefaultAddress,
                    height: Dimensions.paddingSizeDefaultAddress,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Icon(
                          CupertinoIcons.heart,
                          color: isDarkMode ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                          size: Dimensions.paddingSizeDefaultAddress,
                        ),
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) => ClipPath(
                            clipper: _CircleFillClipper(progress: _animation.value),
                            child: child,
                          ),
                          child: Icon(
                            CupertinoIcons.heart_fill,
                            color: Theme.of(context).primaryColor,
                            size: Dimensions.paddingSizeDefaultAddress,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CircleFillClipper extends CustomClipper<Path> {
  final double progress;

  const _CircleFillClipper({required this.progress});

  @override
  Path getClip(Size size) {
    if (progress <= 0) return Path();

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) / 2;
    final holeRadius = maxRadius * (1 - progress);

    if (holeRadius < 1) {
      return Path()..addOval(Rect.fromCircle(center: center, radius: maxRadius));
    }
    return Path()
      ..addOval(Rect.fromCircle(center: center, radius: maxRadius))
      ..addOval(Rect.fromCircle(center: center, radius: holeRadius))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_CircleFillClipper old) => old.progress != progress;
}
