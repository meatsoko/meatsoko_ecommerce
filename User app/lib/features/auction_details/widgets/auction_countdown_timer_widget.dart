import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/enums/auction_enum.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionCountdownTimerWidget extends StatefulWidget {
  final DateTime endTime;
  final AuctionParticipationStatus? status;
  final VoidCallback? onTimerComplete;
  const AuctionCountdownTimerWidget({super.key, required this.endTime, this.status, this.onTimerComplete});

  @override
  State<AuctionCountdownTimerWidget> createState() => _AuctionCountdownTimerWidgetState();
}

class _AuctionCountdownTimerWidgetState extends State<AuctionCountdownTimerWidget> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.endTime.difference(DateTime.now());
    _startTimer();
  }

  @override
  void didUpdateWidget(AuctionCountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endTime != widget.endTime) {
      _timer.cancel();
      _remaining = widget.endTime.difference(DateTime.now());
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = widget.endTime.difference(DateTime.now());
      if (diff.isNegative || diff == Duration.zero) {
        setState(() => _remaining = Duration.zero);
        _timer.cancel();
        widget.onTimerComplete?.call();
      } else {
        setState(() => _remaining = diff);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) return const SizedBox.shrink();
    final days    = _remaining.inDays;
    final hours   = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
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
      child: Row(mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.status?.isUpcoming == true
              ? (getTranslated('auction_start_in', context) ?? "")
              : (getTranslated('auction_end_in', context) ?? ""),
            style: textMedium.copyWith(
              color: Theme.of(context).textTheme.titleMedium?.color,
              fontSize: Dimensions.fontSizeSmall,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),

          Row(
            children: [
              const SizedBox(width: Dimensions.paddingSizeLarge),
              TimeUnit(value: days,    labelKey: 'day'),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              TimeUnit(value: hours,   labelKey: 'hour'),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              TimeUnit(value: minutes, labelKey: 'min'),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              TimeUnit(value: seconds, labelKey: 'sec'),
            ],
          ),

        ],
      ),
    );
  }
}

class TimeUnit extends StatelessWidget {
  final int value;
  final String labelKey;

  const TimeUnit({super.key, required this.value, required this.labelKey});

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
          getTranslated(labelKey, context) ?? labelKey,
          style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: Dimensions.fontSizeExtraSmall,
          ),
        ),
      ],
    );
  }
}