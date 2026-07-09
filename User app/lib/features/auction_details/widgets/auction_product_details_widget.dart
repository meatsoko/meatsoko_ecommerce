import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_video_player_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/widgets/youtube_video_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class AuctionProductDetailsWidget extends StatefulWidget {
  final String title;
  final String description;
  final String? videoProvider;
  final String? videoUrl;
  final String? customVideoUrl;

  const AuctionProductDetailsWidget({super.key, required this.title, required this.description, this.videoProvider, this.videoUrl, this.customVideoUrl});

  @override
  State<AuctionProductDetailsWidget> createState() => _AuctionProductDetailsWidgetState();
}

class _AuctionProductDetailsWidgetState extends State<AuctionProductDetailsWidget> {
  bool _isExpanded = false;

  bool get _isLong => widget.description.isNotEmpty && widget.description.length > 400;

  Widget _buildToggleButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Icon(
            _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(getTranslated('details', context) ?? '',
            style: titilliumBold.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          SizedBox(height: 1, child: Divider(color: Theme.of(context).hintColor.withValues(alpha: .3), thickness: 1)),
          const SizedBox(height: Dimensions.paddingSizeDefault),


          Text(widget.title,
            style: titilliumBold.copyWith(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: _isLong ? 0 : 15),
                  child: SizedBox(
                  width: double.infinity,
                  height: (_isLong && !_isExpanded) ? 150 : null,
                  child: HtmlWidget(widget.description,
                    onTapUrl: (String url) {
                      return launchUrl(
                        Uri.parse(url), mode: LaunchMode.externalApplication,
                      );
                    },
                    textStyle: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: Dimensions.fontSizeSmall,
                    ),
                  ),
                ),
                ),

                if (_isLong && !_isExpanded)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Theme.of(context).cardColor.withValues(alpha: 0),
                              Theme.of(context).cardColor,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                if (_isLong && !_isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Dimensions.homePagePadding),
                    child: _buildToggleButton(context),
                  ),
              ],
            ),
          ),

          if (_isLong && _isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: Dimensions.homePagePadding),
              child: Center(child: _buildToggleButton(context)),
            ),

          if (widget.videoProvider == 'youtube_link' && (widget.videoUrl?.isNotEmpty ?? false)) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            YoutubeVideoWidget(url: widget.videoUrl),
          ],

          if (widget.videoProvider == 'custom_video' && (widget.customVideoUrl?.isNotEmpty ?? false)) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomVideoPlayerWidget(url: widget.customVideoUrl!),
          ],
        ],
      ),
    );
  }
}