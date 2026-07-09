import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';

class AuctionWinnerBannerWidget extends StatefulWidget {
  final DateTime claimDeadline;
  final VoidCallback? onTimerComplete;

  const AuctionWinnerBannerWidget({super.key, required this.claimDeadline, this.onTimerComplete});

  @override
  State<AuctionWinnerBannerWidget> createState() => _AuctionWinnerBannerWidgetState();
}

class _AuctionWinnerBannerWidgetState extends State<AuctionWinnerBannerWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    final diff = widget.claimDeadline.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
    if (_remaining == Duration.zero) {
      _timer.cancel();
      widget.onTimerComplete?.call();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: .075),
            blurRadius: 5,
            spreadRadius: 1,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).hintColor, width: 1)),
                  child: CustomAssetImageWidget(Images.gavelIcon)),
              const SizedBox(width: Dimensions.paddingSizeDefault),

              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: getTranslated('congratulations', context) ?? "",
                            style: titilliumBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                          const TextSpan(text: ' 🎉'),
                        ],
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),

                    Text(
                      getTranslated('winning_bidder_message', context) ?? "",
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeDefault,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TimeUnit(
                      value: _remaining.inDays,
                      label: getTranslated('days', context) ?? "",
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    TimeUnit(
                      value: _remaining.inHours.remainder(24),
                      label: getTranslated('hours', context) ?? "",
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    TimeUnit(
                      value: _remaining.inMinutes.remainder(60),
                      label: getTranslated('mins', context) ?? "",
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),

                    TimeUnit(
                      value: _remaining.inSeconds.remainder(60),
                      label: getTranslated('sec', context) ?? "",
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.5,
                    ),
                    children: [
                      TextSpan(text: getTranslated('claim_before_time_runs_out', context) ?? ""),

                      TextSpan(text: ' \'${getTranslated('claim_product', context) ?? ""}\' ',
                        style: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),

                      TextSpan(text: getTranslated('to_complete_payment', context) ?? "",),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const TimeUnit({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: titilliumBold.copyWith(
              color: Colors.white,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        Text(
          getTranslated(label, context) ?? label,
          style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Dimensions.fontSizeExtraSmall,
          ),
        ),
      ],
    );
  }
}