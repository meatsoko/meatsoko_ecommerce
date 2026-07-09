import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/withdraw_request_bottom_sheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

enum ParticipateOfflinePaymentStatus { pending, approved, denied }

class ParticipateOfflinePaymentDetailsWidget extends StatefulWidget {
  final ParticipateOfflinePaymentStatus status;
  final double participateFee;
  final String? deniedNote;
  final String? bankName;
  final String? bankBranch;
  final String? accountName;
  final String? accountNo;
  final String? methodName;
  final String? accountNumber;
  final double? amount;
  final String? reference;
  final String? paymentNote;

  const ParticipateOfflinePaymentDetailsWidget({
    super.key,
    required this.status,
    required this.participateFee,
    this.deniedNote,
    this.bankName,
    this.bankBranch,
    this.accountName,
    this.accountNo,
    this.methodName,
    this.accountNumber,
    this.amount,
    this.reference,
    this.paymentNote,
  });

  @override
  State<ParticipateOfflinePaymentDetailsWidget> createState() => _ParticipateOfflinePaymentDetailsWidgetState();
}

class _ParticipateOfflinePaymentDetailsWidgetState extends State<ParticipateOfflinePaymentDetailsWidget> {
  bool _isExpanded = false;

  Color _statusColor(BuildContext context) => switch (widget.status) {
    ParticipateOfflinePaymentStatus.pending => Theme.of(context).colorScheme.primary,
    ParticipateOfflinePaymentStatus.approved => Theme.of(context).colorScheme.onTertiaryContainer,
    ParticipateOfflinePaymentStatus.denied => Theme.of(context).colorScheme.error,
  };

  String _statusLabel(BuildContext context) => switch (widget.status) {
    ParticipateOfflinePaymentStatus.pending => getTranslated('pending', context)!,
    ParticipateOfflinePaymentStatus.approved => getTranslated('approve', context)!,
    ParticipateOfflinePaymentStatus.denied => getTranslated('denied', context)!,
  };

  @override
  Widget build(BuildContext context) {
    final double entryFee = Provider.of<SplashController>(context, listen: false).configModel?.auctionEntryFeeAmount ?? 0.0;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  getTranslated('participate_payment_details', context)!,
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraExtraSmall),
                decoration: BoxDecoration(
                  color: _statusColor(context).withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                ),
                child: Text(_statusLabel(context),
                  style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: _statusColor(context)),
                ),
              ),
            ],
          ),

          if (_isExpanded) ...[
            const SizedBox(height: Dimensions.paddingSizeDefault),

            Row(
              children: [
                Text(getTranslated('auction_payment_participate_fee', context)!,
                  style: titilliumRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(PriceConverter.convertPrice(context, entryFee),
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),

            if (widget.status == ParticipateOfflinePaymentStatus.denied && widget.deniedNote != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getTranslated('denied_note', context)!,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraExtraSmall),
                    Text(widget.deniedNote!,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
            ],

            _InfoCard(
              title: getTranslated('my_submitted_info', context)!,
              trailing: (widget.status == ParticipateOfflinePaymentStatus.pending || widget.status == ParticipateOfflinePaymentStatus.denied)
                  ? GestureDetector(
                onTap: () => WithdrawRequestBottomSheetWidget.show(context, amount: widget.participateFee),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: .3), width: 1.5),
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: Dimensions.iconSizeSmall,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
                  : null,
              rows: [
                _InfoRow(
                    label: getTranslated('method_name', context)!,
                    value: widget.methodName ?? ''),
                _InfoRow(
                    label: getTranslated('account_number', context)!,
                    value: widget.accountNumber ?? ''),
                _InfoRow(
                    label: getTranslated('amount', context)!,
                    value: PriceConverter.convertPrice(context, widget.amount ?? 0)),
                _InfoRow(
                    label: getTranslated('reference', context)!,
                    value: widget.reference ?? ''),
              ],
              footer: widget.paymentNote != null
                  ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                      '${getTranslated('payment_note', context)!} :  ',
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    TextSpan(
                      text: widget.paymentNote!,
                      style: titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ) : null,
            ),
          ],
          const SizedBox(height: Dimensions.paddingSizeSmall),

          Center(
            child: GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? getTranslated('see_less', context)! : getTranslated('see_more', context)!,
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  final Widget? trailing;
  final Widget? footer;

  const _InfoCard({
    required this.title,
    required this.rows,
    this.trailing,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).hintColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                  style: titilliumBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          ...rows,
          if (footer != null) ...[
            const SizedBox(height: Dimensions.paddingSizeSmall),
            footer!,
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraExtraSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(': ',
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}