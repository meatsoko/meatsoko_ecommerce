import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionFeatureBannerWidget extends StatelessWidget {
  final VoidCallback? onClose;
  final VoidCallback? onGetItNow;

  const AuctionFeatureBannerWidget({
    super.key,
    this.onClose,
    this.onGetItNow,
  });


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          _buildBody(context),
        ],
      ),
    );
  }


  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            const Color(0xFF2D6EC8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomAssetImageWidget(
              Images.circleBg,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 18),
            child: Column(
              children: [
                const CustomAssetImageWidget(Images.gavelIcon, width: 35, height: 35),
                const SizedBox(height: 15),
                Text(
                  getTranslated('new_business_opportunities_with_auction', context) ?? '',
                  textAlign: TextAlign.center,
                  style: titleHeader.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 18),
                  child: Text(
                    getTranslated('auction_banner_subtitle', context) ?? '',
                    textAlign: TextAlign.center,
                    style: titilliumRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onClose ?? () => Navigator.of(context).pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFeatureGrid(context),
          const SizedBox(height: 10),
          _buildRatingRow(context),
          const SizedBox(height: 12),
          _buildGetItNowButton(context),
          const SizedBox(height: 12),
          _buildWarningText(context),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    final features = [
      _FeatureItem(icon: Images.liveBiddingIcon, title: getTranslated('live_bidding', context) ?? '', subtitle: getTranslated('live_bidding_subtitle', context) ?? ''),
      _FeatureItem(icon: Images.extraRevenueIcon, title: getTranslated('extra_revenue', context) ?? '', subtitle: getTranslated('extra_revenue_subtitle', context) ?? ''),
      _FeatureItem(icon: Images.moreTrafficIcon, title: getTranslated('more_traffic', context) ?? '', subtitle: getTranslated('more_traffic_subtitle', context) ?? ''),
      _FeatureItem(icon: Images.instantLunchIcon, title: getTranslated('instant_launch', context) ?? '', subtitle: getTranslated('instant_launch_subtitle', context) ?? ''),
    ];

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFeatureCard(context, features[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildFeatureCard(context, features[1])),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildFeatureCard(context, features[2])),
              const SizedBox(width: 8),
              Expanded(child: _buildFeatureCard(context, features[3])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem feature) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: CustomAssetImageWidget(
                feature.icon,
                width: 16,
                height: 16,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature.subtitle,
                  style: titilliumRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 10,
                    height: 1.0,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomAssetImageWidget(Images.fiveStarIcon, width: 72, height: 10),
        const SizedBox(width: 6),
        Text(
          getTranslated('trusted_by_sellers', context) ?? '',
          style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.titleMedium?.color,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildGetItNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        onPressed: onGetItNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).cardColor,
          disabledBackgroundColor: Theme.of(context).colorScheme.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getTranslated('get_it_now', context) ?? '',
              style: textBold.copyWith(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningText(BuildContext context) {
    final fullText = getTranslated('auction_addon_warning', context) ?? '';
    const boldWord = 'Add-on';
    final splitIndex = fullText.indexOf(boldWord);
    final errorColor = Theme.of(context).colorScheme.error;
    final baseStyle = titilliumRegular.copyWith(color: errorColor, fontSize: 10, height: 1.3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.warning, color: errorColor, size: 12),
        const SizedBox(width: 2),
        Expanded(
          child: splitIndex == -1
            ? Text(fullText, style: baseStyle)
            : Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: fullText.substring(0, splitIndex)),
                  TextSpan(text: boldWord, style: baseStyle.copyWith(fontWeight: FontWeight.bold)),
                  TextSpan(text: fullText.substring(splitIndex + boldWord.length)),
                ],
              ),
            ),
        ),
      ],
    );
  }
}

class _FeatureItem {
  final String icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
