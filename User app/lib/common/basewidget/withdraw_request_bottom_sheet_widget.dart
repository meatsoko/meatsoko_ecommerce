import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/controllers/transaction_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/transaction/domain/models/withdraw_method_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/price_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class WithdrawRequestBottomSheetWidget extends StatefulWidget {
  final double amount;
  final int auctionProductId;
  final int? existingWithdrawId;
  final int? initialMethodId;
  final Map<String, dynamic>? initialFieldValues;
  final VoidCallback? onSuccess;

  const WithdrawRequestBottomSheetWidget({
    super.key,
    required this.amount,
    required this.auctionProductId,
    this.existingWithdrawId,
    this.initialMethodId,
    this.initialFieldValues,
    this.onSuccess,
  });

  static Future<void> show(BuildContext context, {
    required double amount,
    int auctionProductId = 0,
    int? existingWithdrawId,
    int? initialMethodId,
    Map<String, dynamic>? initialFieldValues,
    VoidCallback? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radiusLarge),
        ),
      ),
      builder: (_) => WithdrawRequestBottomSheetWidget(
        amount: amount,
        auctionProductId: auctionProductId,
        existingWithdrawId: existingWithdrawId,
        initialMethodId: initialMethodId,
        initialFieldValues: initialFieldValues,
        onSuccess: onSuccess,
      ),
    );
  }

  @override
  State<WithdrawRequestBottomSheetWidget> createState() => _WithdrawRequestBottomSheetWidgetState();
}

class _WithdrawRequestBottomSheetWidgetState extends State<WithdrawRequestBottomSheetWidget > {
  WithdrawMethodModel? _selectedMethod;

  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<int?, Map<String, String>> _methodFieldCache = {};
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: PriceConverter.convertPrice(context, widget.amount)); // PriceConverter.convertPrice(context, widget.amount)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final controller = Provider.of<TransactionController>(context, listen: false);
      await controller.getWithdrawMethodList(context);

      if (controller.withdrawMethods.isEmpty) return;

      final method = widget.initialMethodId != null
          ? controller.withdrawMethods.firstWhere(
              (m) => m.id == widget.initialMethodId,
              orElse: () => controller.withdrawMethods.first,
            )
          : controller.withdrawMethods.firstWhere(
              (m) => m.isDefault,
              orElse: () => controller.withdrawMethods.first,
            );
      _onMethodChanged(method);

      // Pre-fill field values if provided
      if (widget.initialFieldValues != null) {
        widget.initialFieldValues!.forEach((key, value) {
          if (_fieldControllers.containsKey(key)) {
            _fieldControllers[key]!.text = value?.toString() ?? '';
          }
        });
        if (mounted) setState(() {});
      }
    });
  }

  void _onMethodChanged(WithdrawMethodModel method) {
    if (_selectedMethod != null) {
      _methodFieldCache[_selectedMethod!.id] = {
        for (final e in _fieldControllers.entries) e.key: e.value.text,
      };
    }

    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    _fieldControllers.clear();

    final cached = _methodFieldCache[method.id];
    for (final field in method.methodFields) {
      final key = field.inputName;
      _fieldControllers[key] = TextEditingController(text: cached?[key] ?? '');
    }

    setState(() => _selectedMethod = method);
  }

  @override
  void dispose() {
    for (final c in _fieldControllers.values) {
      c.dispose();
    }
    _amountController.dispose();
    super.dispose();
  }

  void _onSendRequest() async {
    if (_selectedMethod == null) return;

    for (final field in _selectedMethod!.methodFields) {
      if (field.isRequired &&
          (_fieldControllers[field.inputName]?.text.trim().isEmpty ?? true)) {
        showCustomSnackBar('${_formatLabel(field.inputName)} ${getTranslated('is_required', context)!}', context, isError: true);
        return;
      }
    }

    if (_amountController.text.trim().isEmpty) {
      showCustomSnackBar(getTranslated('please_enter_withdraw_amount', context)!, context, isError: true);
      return;
    }

    final Map<String, dynamic> methodInfo = {};
    _fieldControllers.forEach((key, controller) {
      methodInfo[key] = controller.text.trim();
    });

    final accountDisplay = _fieldControllers.values.isNotEmpty ? _fieldControllers.values.first.text.trim() : '';

    final txController = Provider.of<TransactionController>(context, listen: false);
    await txController.storeOrUpdateWithdraw(
      context,
      auctionProductId: widget.auctionProductId,
      withdrawMethodId: _selectedMethod!.id,
      existingWithdrawId: widget.existingWithdrawId,
      amount: double.tryParse(_amountController.text),
      methodInfo: methodInfo,
      displayMethodName: _selectedMethod!.methodName,
      displayAccountInfo: accountDisplay,
    );

    if (txController.withdrawResponse != null && mounted) {
      Navigator.pop(context);
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Consumer<TransactionController>(
        builder: (context, transactionController, _) {
          final methods = transactionController.withdrawMethods;

          return Column(mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      getTranslated('withdraw_information', context)!,
                      style: titilliumBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(
                              Dimensions.paddingSizeExtraExtraSmall,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor.withValues(alpha: .2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close,
                              size: Dimensions.iconSizeSmall,
                              color: Theme.of(context).textTheme.bodySmall?.color),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Theme.of(context).hintColor.withValues(alpha: .15)),

              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_rounded, size: Dimensions.iconSizeSmall, color: Theme.of(context).colorScheme.tertiary),
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                            Expanded(
                              child: Text(
                                getTranslated('withdraw_info_message', context)!,
                                style: titilliumRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodySmall?.color,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      _FieldLabel(
                        label: getTranslated('select_withdrawal_method', context)!,
                        isRequired: true,
                        showInfo: true,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      transactionController.isLoading ? const Center(child: CircularProgressIndicator()) : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeDefault,
                          vertical: Dimensions.paddingSizeExtraExtraSmall,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).hintColor.withValues(alpha: .3),
                          ),
                          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<WithdrawMethodModel>(
                            value: _selectedMethod,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            style: titilliumRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            items: methods.where((m) => m.isActive).map((m) => DropdownMenuItem(value: m, child: Text(m.methodName))).toList(),
                            onChanged: (m) {
                              if (m != null) _onMethodChanged(m);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeDefault),

                      if (_selectedMethod != null)
                        ...(_selectedMethod!.methodFields.map((field) {
                          return Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: _formatLabel(field.inputName),
                                isRequired: field.isRequired,
                                showInfo: true,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              _InputField(
                                controller: _fieldControllers[
                                field.inputName] ?? TextEditingController(),
                                hintText: field.placeholder,
                                isNumber: field.inputType == 'number',
                              ),
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                            ],
                          );
                        })),

                      _FieldLabel(
                        label: '${getTranslated('withdraw_amount', context)!} (\$)',
                        isRequired: true,
                        showInfo: true,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      _InputField(
                        controller: _amountController,
                        hintText: 'Ex: 260.50',
                        isNumber: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).hintColor.withValues(alpha: .3),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                        ),
                        child: Text(
                          getTranslated('cancel', context)!,
                          style: titilliumSemiBold.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (transactionController.isLoading || transactionController.isWithdrawLoading)
                            ? null
                            : _onSendRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
                          elevation: 0,
                        ),
                        child: transactionController.isWithdrawLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                getTranslated('send_request', context)!,
                                style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatLabel(String inputName) {
    return inputName.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;
  final bool showInfo;

  const _FieldLabel({required this.label, this.isRequired = false, this.showInfo = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
          style: titilliumSemiBold.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
          Text('*',
            style: titilliumBold.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
        ],
        // if (showInfo) ...[
        //   const SizedBox(width: Dimensions.paddingSizeExtraExtraSmall),
        //   Icon(
        //     Icons.info_outline_rounded,
        //     size: Dimensions.iconSizeExtraSmall + 2,
        //     color: Theme.of(context).hintColor,
        //   ),
        // ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isNumber;
  final bool readOnly;

  const _InputField({
    required this.controller,
    required this.hintText,
    this.isNumber = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: titilliumRegular.copyWith(
        fontSize: Dimensions.fontSizeDefault,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: titilliumRegular.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color: Theme.of(context).hintColor,
        ),
        //isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).hintColor.withValues(alpha: .3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).hintColor.withValues(alpha: .3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}