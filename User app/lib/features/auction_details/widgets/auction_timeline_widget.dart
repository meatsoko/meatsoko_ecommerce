import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionTimelineEntry {
  final String label;
  final DateTime dateTime;

  const AuctionTimelineEntry({
    required this.label,
    required this.dateTime,
  });
}

class AuctionTimelineWidget extends StatelessWidget {
  final List<AuctionTimelineEntry> entries;

  const AuctionTimelineWidget({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
        children: [
          Text(getTranslated('auction_timeline', context) ?? "",
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),

          ...entries.asMap().entries.map((map) {
            final index = map.key;
            final entry = map.value;
            return Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeTwelve),
                Text(entry.label,
                    style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.titleMedium?.color)
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                Text(DateConverter.formatDateWithCommaAnd24Hour(entry.dateTime),
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),

                if (index < entries.length - 1)
                  Divider(color: Theme.of(context).cardColor, thickness: 1, height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }
}
