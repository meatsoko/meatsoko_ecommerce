import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/controllers/banner_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/domain/models/banner_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/banner/widgets/banner_shimmer.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_image_widget.dart';
import 'package:provider/provider.dart';

class BannersSliderWidget extends StatefulWidget {
  final List<BannerModel>? bannerList;
  final bool useFooterBanners;

  const BannersSliderWidget({super.key, this.bannerList, this.useFooterBanners = false});

  @override
  State<BannersSliderWidget> createState() => _BannersSliderWidgetState();
}

class _BannersSliderWidgetState extends State<BannersSliderWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final SplashController splashController = Provider.of<SplashController>(context,listen: false);
    final double width = MediaQuery.of(context).size.width;

    return Consumer<BannerController>(
      builder: (context, bannerProvider, child) {
        final List<BannerModel>? activeBanners = widget.bannerList
            ?? (widget.useFooterBanners ? bannerProvider.footerBannerList : bannerProvider.mainBannerList);

        // Collapse entirely (no residual gap) when banners are loaded but empty.
        if (activeBanners != null && activeBanners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(
            left: Dimensions.homePagePadding,
            right: Dimensions.homePagePadding,
            bottom: Dimensions.homePagePadding,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            activeBanners != null ? activeBanners.isNotEmpty ?
            CarouselSlider.builder(
              options: CarouselOptions(
                  initialPage: _currentIndex,
                  height: width * 0.4,
                  viewportFraction: 1,
                  autoPlay: true,
                  pauseAutoPlayOnTouch: true,
                  pauseAutoPlayOnManualNavigate: true,
                  pauseAutoPlayInFiniteScroll: true,
                  enlargeFactor: 0,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  onPageChanged: (index, reason) {
                    _currentIndex = index;
                    Provider.of<BannerController>(context, listen: false).setCurrentIndex(index);}),
              itemCount: activeBanners.isEmpty ? 1 : activeBanners.length,
              itemBuilder: (context, index, _)=> InkWell(
                onTap: () {
                  if(activeBanners[index].resourceId != null){
                    bannerProvider.clickBannerRedirect(context,
                        activeBanners[index].resourceId,
                        activeBanners[index].resourceType =='product'?
                        activeBanners[index].product : null,
                        activeBanners[index].resourceType);
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall)),
                    child: CustomImageWidget(
                      width: width,
                      image: '${splashController.baseUrls?.bannerImageUrl}''/${activeBanners[index].photo}',
                    ),
                  ),
                ),
              ),
            ) : const SizedBox() : const BannerShimmer(),
            const SizedBox(height: Dimensions.paddingSizeSmall),

            if(activeBanners != null && activeBanners.isNotEmpty)
              SizedBox(
                height: Dimensions.paddingSizeExtraSmall,
                child: ListView.separated(
                  separatorBuilder: (_, index){
                    return const SizedBox(width: 3);
                  },
                  itemCount: activeBanners.length,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      width: _currentIndex == index ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeExtraSmall,
                      height: Dimensions.paddingSizeExtraSmall, decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: _currentIndex == index ? Theme.of(context).primaryColor :  Theme.of(context).primaryColor.withValues(alpha: 0.3),
                    ),
                    );
                  },
                ),
              ),
          ],
          ),
        );
      },
    );
  }
}
