import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/dropdown_decorator_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/auction_tag_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/controllers/vat_tax_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/tax_vat_model.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class AddAuctionInfoWidget extends StatefulWidget {
  final TextEditingController entryFeeController;
  final TextEditingController startPriceController;
  final TextEditingController minimumIncrementController;
  final TextEditingController maximumDecrementController;
  final DateTime? startTime;
  final DateTime? endTime;
  final ValueChanged<DateTime?> onStartTimeChanged;
  final ValueChanged<DateTime?> onEndTimeChanged;
  final ValueChanged<List<VatTaxModel>> onVatTaxChanged;
  final List<String> initialTags;
  final ValueChanged<List<String>> onTagsChanged;
  final Key? tagFieldKey;

  final bool isAiGenerating;
  final VoidCallback? onAiTap;

  const AddAuctionInfoWidget({
    super.key,
    required this.entryFeeController,
    required this.startPriceController,
    required this.minimumIncrementController,
    required this.maximumDecrementController,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    required this.onVatTaxChanged,
    required this.initialTags,
    required this.onTagsChanged,
    this.tagFieldKey,
    this.startTime,
    this.endTime,
    this.isAiGenerating = false,
    this.onAiTap,
  });

  @override
  State<AddAuctionInfoWidget> createState() => _AddAuctionInfoWidgetState();
}

class _AddAuctionInfoWidgetState extends State<AddAuctionInfoWidget> {
  VatTaxModel? selectedTax;

  Future<void> _pickDateTime({
    required DateTime? initial,
    required ValueChanged<DateTime?> onPicked,
  }) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial ?? DateTime.now()),
    );
    if (time == null) return;

    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, 6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Color(0x0D1B7FED),
            offset: Offset(0, -6),
            blurRadius: 12,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall, horizontal: Dimensions.homePagePadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    getTranslated('auction_info', context) ?? "",
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge?.color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (Provider.of<SplashController>(context, listen: false).configModel?.isAiFeatureEnabled == true && widget.onAiTap != null)
                  InkWell(
                    onTap: widget.onAiTap,
                    borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                      child: Icon(Icons.auto_awesome,
                          size: Dimensions.iconSizeSmall,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.homePagePadding),
            child: Text(
              getTranslated('auction_info_description', context) ?? "",
              style: titilliumRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          _ShimmerOverlayWrapper(
            isActive: widget.isAiGenerating,
            baseColor: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: Dimensions.paddingSizeSmall),

                // _AuctionTextField(
                //   controller: widget.entryFeeController,
                //   hintText: getTranslated('entry_fee', context) ?? "Entry Fee",
                //   keyboardType: TextInputType.number,
                // ),
                // const SizedBox(height: Dimensions.paddingSizeSmall),

                _AuctionTextField(
                  controller: widget.startPriceController,
                  hintText: getTranslated('start_price', context) ?? "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _AuctionTextField(
                  controller: widget.minimumIncrementController,
                  hintText: getTranslated('minimum_increment', context) ?? "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                _AuctionTextField(
                  controller: widget.maximumDecrementController,
                  hintText: getTranslated('maximum_decrement', context) ?? "",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),

                if(Provider.of<SplashController>(context, listen: false).configModel?.systemTaxType == 'product_wise')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Consumer<VatTaxController>(
                      builder: (context, vatTaxController, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownDecoratorWidget(
                              child: DropdownButton<VatTaxModel>(
                                icon: const Icon(Icons.keyboard_arrow_down_outlined),
                                borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeEight)),
                                hint: Text(getTranslated('select_tax_rate', context) ?? '',
                                    style: titilliumRegular.copyWith(color: Theme.of(context).hintColor)),
                                items: vatTaxController.taxVatList.map((VatTaxModel? value) {
                                  bool isSelected = vatTaxController.isSelected(value!);
                                  return DropdownMenuItem<VatTaxModel>(
                                    enabled: !isSelected,
                                    value: value,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${value.name} ${value.id != 0 ? '(${value.taxRate}%)' : ''}'),
                                        if (isSelected)
                                          Icon(Icons.check, color: Theme.of(context).primaryColor, size: 18),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (VatTaxModel? value) {
                                  if (value == null) return;
                                  if (value.id == 0) {
                                    for (VatTaxModel vatTaxModel in vatTaxController.taxVatList) {
                                      if (vatTaxModel.id != 0 && !vatTaxController.isSelected(vatTaxModel)) {
                                        vatTaxController.addToSelectedTaxList(vatTaxModel);
                                      }
                                    }
                                    widget.onVatTaxChanged(vatTaxController.selectedTaxList);
                                    return;
                                  } else {
                                    vatTaxController.addToSelectedTaxList(value);
                                  }
                                  widget.onVatTaxChanged(vatTaxController.selectedTaxList);
                                },
                                isExpanded: true,
                                underline: const SizedBox(),
                              ),
                            ),

                            !vatTaxController.selectedTaxList.isNotEmpty ?
                            const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox.shrink(),

                            vatTaxController.selectedTaxList.isNotEmpty ?
                            SizedBox(
                              height: vatTaxController.selectedTaxList.isNotEmpty ? 40 : 0,
                              child: ListView.builder(
                                itemCount: vatTaxController.selectedTaxList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeExtraExtraSmall),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault),
                                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeExtraSmall),
                                      decoration: BoxDecoration(color: Theme.of(context).primaryColor.withValues(alpha:.20),
                                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                                      ),
                                      child: Row(children: [
                                        Consumer<SplashController>(builder: (ctx, colorP,child){
                                          return Text(
                                            '${vatTaxController.selectedTaxList[index].name} (${vatTaxController.selectedTaxList[index].taxRate}%)',
                                            style: titilliumRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
                                          );
                                        }),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: (){
                                            vatTaxController.removeToSelectedTaxList (vatTaxController.selectedTaxList[index], index);
                                            widget.onVatTaxChanged(vatTaxController.selectedTaxList);
                                          },
                                          child: Icon(Icons.close, size: 15, color: Theme.of(context).textTheme.bodyLarge?.color),
                                        ),
                                      ]),
                                    ),
                                  );
                                },
                              ),
                            ) : const SizedBox(),

                            vatTaxController.selectedTaxList.isNotEmpty ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                          ],
                        );
                      }
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: _AuctionDateTimeField(
                    hintText: getTranslated('start_time', context) ?? "",
                    value: _formatDateTime(widget.startTime),
                    onTap: () => _pickDateTime(
                      initial: widget.startTime,
                      onPicked: widget.onStartTimeChanged,
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault),
                  child: _AuctionDateTimeField(
                    hintText: getTranslated('end_time', context) ?? "",
                    value: _formatDateTime(widget.endTime),
                    onTap: () => _pickDateTime(
                      initial: widget.endTime,
                      onPicked: widget.onEndTimeChanged,
                    ),
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeSmall),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AuctionTagWidget(
                        key: widget.tagFieldKey,
                        initialTags: widget.initialTags,
                        onTagsChanged: widget.onTagsChanged,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuctionTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;

  const _AuctionTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        style: titilliumRegular.copyWith(
            color: Theme.of(context).textTheme.bodyLarge?.color),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault),
          hintText: '$hintText *',
          hintStyle: titilliumRegular.copyWith(color: Theme.of(context).hintColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.15), width: 1),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          ),
        ),
      ),
    );
  }
}

class _AuctionDateTimeField extends StatelessWidget {
  final String hintText;
  final String value;
  final VoidCallback onTap;

  const _AuctionDateTimeField({
    required this.hintText,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: .25), width: .75),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              value.isEmpty ? '$hintText *' : value,
              style: value.isEmpty ? titilliumRegular.copyWith(
                  color: Theme.of(context).hintColor)
                  : titilliumSemiBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
          Icon(Icons.calendar_month_outlined,
              size: Dimensions.iconSizeSmall,
              color: Theme.of(context).hintColor),
        ]),
      ),
    );
  }
}

class _ShimmerOverlayWrapper extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerOverlayWrapper({
    required this.child,
    this.isActive = false,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      child,
      if (isActive)
        Positioned.fill(
          child: Opacity(
            opacity: 0.3,
            child: Shimmer.fromColors(
              baseColor: baseColor ?? Theme.of(context).primaryColor,
              highlightColor: highlightColor ?? Colors.grey[100]!,
              child: Container(color: Colors.white),
            ),
          ),
        ),
    ]);
  }
}