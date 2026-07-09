import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

enum WithdrawState { pending, requested, approved, denied }

class WithdrawInfo {
  final Map<String, dynamic> fields;

  const WithdrawInfo({required this.fields});
}

class WithdrawalCardWidget extends StatelessWidget {
  final WithdrawState state;
  final double amount;
  final WithdrawInfo? withdrawInfo;
  final String? adminNote;
  final VoidCallback? onWithdrawPressed;
  final VoidCallback? onEditPressed;

  const WithdrawalCardWidget({
    super.key,
    required this.state,
    required this.amount,
    this.withdrawInfo,
    this.adminNote,
    this.onWithdrawPressed,
    this.onEditPressed,
  });

  bool get _isApproved => state == WithdrawState.approved;
  bool get _isDenied => state == WithdrawState.denied;
  bool get _showNote => _isApproved || _isDenied;
  bool get _showInfoCard => state == WithdrawState.requested || state == WithdrawState.approved || state == WithdrawState.denied;

  Color _titleColor(BuildContext context) => _isApproved ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error;
  String _title(BuildContext context) => _isApproved ? getTranslated('payment_received_from_admin', context) ?? "" : getTranslated('amount_paid_by_admin', context) ?? "";
  String _subtitle(BuildContext context) => _isApproved ? getTranslated('admin_has_completed_payment', context) ?? "" : getTranslated('auction_earnings_transferred', context) ?? (_isDenied ? ' .' : '');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Theme.of(context).cardColor),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showNote) NoteBanner(state: state, note: adminNote),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                  ),
                  child: Column(
                    children: [
                      Text(_title(context),
                        textAlign: TextAlign.center,
                        style: titilliumSemiBold.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                          color: _titleColor(context),
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      Text(
                        PriceConverter.convertPrice(context, amount),
                        style: titilliumBold.copyWith(
                          fontSize: Dimensions.fontSizeWithdrawableAmount,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ),
                      ),
                      SizedBox(height: Dimensions.paddingSizeSmall),

                      Text(_subtitle(context),
                        textAlign: TextAlign.center,
                        style: titilliumRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          height: 1.5,
                        ),
                      ),
                    ],
                  )

                ),
                if (_showInfoCard) ...[
                  SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  WithdrawInfoCard(
                    info: withdrawInfo!,
                    showEditButton: state != WithdrawState.approved,
                    onEditPressed: onEditPressed,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NoteBanner extends StatelessWidget {
  final WithdrawState state;
  final String? note;

  const NoteBanner({super.key, required this.state, this.note});

  bool get _isApproved => state == WithdrawState.approved;

  @override
  Widget build(BuildContext context) {
    final Color bgColor = _isApproved ? Theme.of(context).colorScheme.onTertiaryContainer.withValues(alpha: 0.15) : Theme.of(context).colorScheme.error.withAlpha(50);
    final Color textColor = _isApproved ? Theme.of(context).colorScheme.onTertiaryContainer : Theme.of(context).colorScheme.error.withAlpha(150);
    final String label = _isApproved ? getTranslated('approve_note', context) ?? "" : getTranslated('denied_note', context) ?? "";
    final String message = note ?? (_isApproved ? getTranslated('approve_note_default', context) ?? "" : getTranslated('denied_note_default', context) ?? "");

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
              style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
            ),
            SizedBox(height: Dimensions.paddingSizeSmall),

            Text(message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: titilliumRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: textColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatFieldKey(String key) => key.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');

class WithdrawInfoCard extends StatelessWidget {
  final WithdrawInfo info;
  final bool showEditButton;
  final VoidCallback? onEditPressed;

  const WithdrawInfoCard({
    super.key,
    required this.info,
    required this.showEditButton,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.all(Radius.circular(Dimensions.radiusDefault))
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(getTranslated('withdraw_info', context) ?? "",
                style: titilliumSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              if (showEditButton)
                EditButton(onPressed: onEditPressed),
            ],
          ),
          SizedBox(height: Dimensions.paddingSizeDefault),

          ...info.fields.entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
            child: InfoRow(label: _formatFieldKey(e.key), value: e.value?.toString() ?? ''),
          )),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label,
            style: titilliumRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
          ),
        ),
        Text(': ',
          style: titilliumRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodySmall!.color,
          ),
        ),
        Expanded(
          child: Text(value,
            style: titilliumSemiBold.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          ),
        ),
      ],
    );
  }
}

class EditButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const EditButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: Dimensions.heightWidth50 / 1.4,
        height: Dimensions.heightWidth50 / 1.4,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        ),
        child: Icon(Icons.edit, size: Dimensions.iconSizeDefault, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}