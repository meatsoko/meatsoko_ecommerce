import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_asset_image_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';


enum TransactionType { credit, debit }

class AuctionTransactionTileWidget extends StatelessWidget {
  final double amount;
  final String auctionNumber;
  final DateTime dateTime;
  final TransactionType type;

  const AuctionTransactionTileWidget({
    super.key,
    required this.amount,
    required this.auctionNumber,
    required this.dateTime,
    required this.type,
  });

  bool get _isCredit => type == TransactionType.credit;

  Color get _accentColor => _isCredit ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

  String _formattedAmount(BuildContext context) => '${_isCredit ? '+' : '-'}${PriceConverter.convertPrice(context, amount)}';

  String get _formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeExtraSmall,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: ThemeShadow.getShadow(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CustomAssetImageWidget(
                _isCredit ? Images.creditCoinIcon : Images.debitCoinIcon,
                height: 20, width: 20),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(_formattedAmount(context),
                style: titilliumSemiBold.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: Dimensions.fontSizeDefault,
                ),
              ),
              const Spacer(),

              Text(_formattedDate,
                style: titilliumRegular.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.fontSizeExtraSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Row(
            children: [
              Text('Auction # $auctionNumber',
                style: titilliumSemiBold.copyWith(
                  color: Colors.grey,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
              const Spacer(),

              Text(_isCredit ? 'Credit' : 'Debit',
                style: titleRegular.copyWith(
                  color: _accentColor.withValues(alpha: 0.9),
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}