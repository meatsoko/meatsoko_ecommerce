import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/ai_button_widgets.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/controllers/vat_tax_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/vat_tax/domain/models/tax_vat_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/widgets/add_auction_info_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/date_converter.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class AuctionInfoScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final CreatorAuctionProduct? initialProduct;
  final String Function()? getProductTitle;
  final String Function()? getProductDescription;
  final bool isRelaunchMode;
  const AuctionInfoScreen({super.key, this.onBack, this.onNext, this.initialProduct, this.getProductTitle, this.getProductDescription, this.isRelaunchMode = false});

  @override
  AuctionInfoScreenState createState() => AuctionInfoScreenState();
}

class AuctionInfoScreenState extends State<AuctionInfoScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController? _tabController;

  final TextEditingController startPriceController = TextEditingController();
  final TextEditingController minimumIncrementController = TextEditingController();
  final TextEditingController maximumDecrementController = TextEditingController();
  final TextEditingController entryFeeController = TextEditingController();

  List<VatTaxModel> selectedVatTax = [];
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  List<String> selectedTags = [];
  int _tagsRevision = 0;

  @override
  void initState() {
    super.initState();
    initData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isEditMode = widget.initialProduct != null;
      final aiController = Provider.of<AuctionAiController>(context, listen: false);
      if (!isEditMode && aiController.requestTypeImage) {
        _loadDataFromImage();
      }
    });
  }

  void initData() {
    final p = widget.initialProduct;
    final isEditMode = p != null;

    if (isEditMode) {
      startPriceController.text = p.startingPrice?.toString() ?? '';
      minimumIncrementController.text = p.minimumIncrementAmount?.toString() ?? '';
      maximumDecrementController.text = p.maximumDecrementAmount?.toString() ?? '';
      entryFeeController.text = p.entryFee?.toString() ?? '';
      selectedTags = p.tags ?? [];

      if (!widget.isRelaunchMode) {
        setState(() {
          selectedStartTime = p.startTime != null ? DateConverter.isoStringToLocalDate(p.startTime!) : null;
          selectedEndTime = p.endTime != null ? DateConverter.isoStringToLocalDate(p.endTime!) : null;
        });
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final vatTaxController = Provider.of<VatTaxController>(context, listen: false);

      vatTaxController.clearSelectedTaxList();
      await vatTaxController.getVatTaxList();

      if (isEditMode && mounted) {
        vatTaxController.setProductVatTax(p.taxVats);
        vatTaxController.notifyListeners();

        setState(() {
          selectedVatTax = List.from(vatTaxController.selectedTaxList);
        });
      }
    });
  }

  Future<void> _loadDataFromImage() async {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';

    if (title.isEmpty || description.isEmpty) return;

    await aiController.generateAuctionInfoSetup(
      title: title,
      description: description,
      langCode: 'en',
    );

    if (mounted) {
      _applyAuctionInfoResult();
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    entryFeeController.dispose();
    startPriceController.dispose();
    minimumIncrementController.dispose();
    maximumDecrementController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AuctionAiController>(
        builder: (context, aiController, _) {
          return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Expanded(
            child: SingleChildScrollView(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AddAuctionInfoWidget(
                    entryFeeController: entryFeeController,
                    startPriceController: startPriceController,
                    minimumIncrementController: minimumIncrementController,
                    maximumDecrementController: maximumDecrementController,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    initialTags: selectedTags,
                    tagFieldKey: ValueKey('tags_$_tagsRevision'),
                    onTagsChanged: (tags) {
                      selectedTags = tags;
                    },
                    onVatTaxChanged: (List<VatTaxModel> value) {
                      setState(() => selectedVatTax = value);
                    },
                    onStartTimeChanged: (value) {
                      setState(() => selectedStartTime = value);
                    },
                    onEndTimeChanged: (value) {
                      setState(() => selectedEndTime = value);
                    },
                    onAiTap: _onAuctionInfoAiTap,
                    isAiGenerating: aiController.auctionInfoLoading,
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.grey[200]!, spreadRadius: 0.5, blurRadius: 0.3)],
            ),
            child: aiController.setupAutoFillLoading
                ? const AiLoadingState()
                : Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).hintColor.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated('go_back', context) ?? '',
                            style: titilliumBold.copyWith(
                              color: Theme.of(context).textTheme.bodyLarge!.color!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                Expanded(
                  child: NextButton(
                    onTap: widget.onNext,
                    isLoading: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });}

  void _onAuctionInfoAiTap() {
    final title = widget.getProductTitle?.call() ?? '';
    final description = widget.getProductDescription?.call() ?? '';
    if (title.isEmpty) {
      showCustomSnackBarWidget(getTranslated('product_name_required', context) ?? 'Please enter a product name first', context, snackBarType: SnackBarType.warning);
      return;
    }
    if (description.isEmpty) {
      showCustomSnackBarWidget(getTranslated('please_input_all_des', context) ?? 'Please enter a description first', context, snackBarType: SnackBarType.warning);
      return;
    }
    Provider.of<AuctionAiController>(context, listen: false).generateAuctionInfoSetup(title: title, description: description, langCode: 'en').then((_) => _applyAuctionInfoResult());
  }

  void _applyAuctionInfoResult() {
    final aiController = Provider.of<AuctionAiController>(context, listen: false);
    final data = aiController.auctionInfoModel?.data?.auctionInfoData;
    if (data == null) return;

    setState(() {
      if (data.startingPrice != null) startPriceController.text = data.startingPrice.toString();
      if (data.entryFee != null) entryFeeController.text = data.entryFee.toString();
      if (data.minimumIncrementAmount != null) minimumIncrementController.text = data.minimumIncrementAmount.toString();
      if (data.maximumDecrementAmount != null) maximumDecrementController.text = data.maximumDecrementAmount.toString();
      if (data.startTime?.isNotEmpty == true) selectedStartTime = DateTime.tryParse(data.startTime!);
      if (data.endTime?.isNotEmpty == true) selectedEndTime = DateTime.tryParse(data.endTime!);
      selectedTags = data.tags ??
          (data.tagsCsv?.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() ?? []);
      _tagsRevision++;
    });

    if (data.taxIds?.isNotEmpty == true) {
      final vatController = Provider.of<VatTaxController>(context, listen: false);

      final List<VatTaxModel> matched = [];
      for (final id in data.taxIds!) {
        for (final tax in vatController.taxVatList) {
          if (tax.id == id) {
            matched.add(tax);
            break;
          }
        }
      }

      vatController.setAIProductVatTax(matched);
      setState(() => selectedVatTax = List.from(vatController.selectedTaxList));
    }
  }
}