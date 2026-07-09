import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionProductInfoWidget extends StatelessWidget {
  final String productName;
  final double shippingFee;
  final String itemCondition;
  final String returnPolicy;

  const AuctionProductInfoWidget({
    super.key,
    required this.productName,
    required this.shippingFee,
    required this.itemCondition,
    required this.returnPolicy,
  });

  String _getLocalizedItemCondition(BuildContext context) {

    final conditionMap = {
      'NEW': 'item_condition_new',
      'LIKE_NEW': 'item_condition_like_new',
      'EXCELLENT': 'item_condition_excellent',
      'GOOD': 'item_condition_good',
      'FAIR': 'item_condition_fair',
    };
    final key = conditionMap[itemCondition] ?? itemCondition;
    return getTranslated(key, context) ?? itemCondition;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeLarge,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          SizedBox(height: 1, child: Divider(color: Theme.of(context).hintColor.withValues(alpha: .3), thickness: 1)),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          InfoRow(
            label: getTranslated('shipping_fee', context) ?? "",
            value: PriceConverter.convertPrice(context, shippingFee),
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          InfoRow(
            label: getTranslated('item_condition', context) ?? "",
            value: _getLocalizedItemCondition(context),
            showInfo: true,
            tooltipMessage: getTranslated('item_condition_tooltip', context) ?? '',
          ),

          const SizedBox(height: Dimensions.paddingSizeSmall),

          InfoRow(
            label: getTranslated('return_policy', context) ?? "",
            value: returnPolicy,
          ),
        ],
      ),
    );
  }
}

class InfoRow extends StatefulWidget {
  final String label;
  final String value;
  final bool showInfo;
  final String? tooltipMessage;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.showInfo = false,
    this.tooltipMessage,
  });

  @override
  State<InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<InfoRow> {
  final JustTheController _tooltipController = JustTheController();

  @override
  void dispose() {
    _tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Flexible(
          flex: 2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  widget.label,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              if (widget.showInfo) ...[
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                if (widget.tooltipMessage != null && widget.tooltipMessage!.isNotEmpty)
                  JustTheTooltip(
                    backgroundColor: Colors.black87,
                    controller: _tooltipController,
                    preferredDirection: AxisDirection.down,
                    tailLength: 10,
                    tailBaseWidth: 20,
                    content: Container(
                      width: 150,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Text(
                        widget.tooltipMessage!,
                        style: textRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => _tooltipController.showTooltip(),
                      child: Icon(
                        Icons.info,
                        size: Dimensions.iconSizeExtraSmall,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.info,
                    size: Dimensions.iconSizeExtraSmall,
                    color: Theme.of(context).hintColor,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Flexible(
          flex: 3,
          child: Text(
            widget.value,
            style: titilliumBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w600
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}