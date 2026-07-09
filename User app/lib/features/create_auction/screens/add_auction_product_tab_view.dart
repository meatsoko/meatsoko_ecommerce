import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_app_bar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/controllers/auction_ai_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/ai/widgets/genertate_count_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/controllers/creator/creator_auction_details_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_details/domain/models/creator/creator_auction_details_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_contoller.dart';
import 'package:flutter_sixvalley_ecommerce/features/create_auction/controllers/add_auction_product_media_controller.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'add_auction_product_screen.dart';
import 'add_auction_product_seo_screen.dart';
import 'auction_info_screen.dart';

class AddAuctionProductTabView extends StatefulWidget {
  final bool fromDetails;
  final bool isRelaunchMode;
  final int? productId;
  final String? slug;
  final CreatorAuctionProduct? initialProduct;

  const AddAuctionProductTabView({super.key, this.productId, this.slug, this.initialProduct, this.fromDetails = false, this.isRelaunchMode = false});

  @override
  State<AddAuctionProductTabView> createState() => _AddAuctionProductTabViewState();
}

class _AddAuctionProductTabViewState extends State<AddAuctionProductTabView> with SingleTickerProviderStateMixin {
  CreatorAuctionProduct? _product;
  late TabController _tabController;

  final GlobalKey<AuctionInfoScreenState> _auctionInfoKey = GlobalKey<AuctionInfoScreenState>();
  final GlobalKey<AddAuctionProductScreenState> _generalInfoKey = GlobalKey<AddAuctionProductScreenState>();
  final GlobalKey<AddAuctionProductSeoScreenState> _seoKey = GlobalKey<AddAuctionProductSeoScreenState>();

  bool get _isEditMode => widget.fromDetails;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialProduct != null) {
      _product = widget.initialProduct;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      Provider.of<AuctionAiController>(context, listen: false).generateLimitCheck();

      if (widget.fromDetails) {
        final detailsController = Provider.of<CreatorAuctionDetailsController>(context, listen: false);
        await detailsController.getAuctionDetails(context, widget.slug ?? '');
        if (mounted) {
          setState(() => _product = detailsController.auctionProduct);
        }
      } else {
        Provider.of<AddAuctionProductMediaController>(context, listen: false).reset();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onGeneralInfoNext() {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    final imageController = Provider.of<AddAuctionProductMediaController>(context, listen: false);
    final state = _generalInfoKey.currentState;
    if (state == null) return;

    final bool isValid = controller.validateGeneralInfo(
      context,
      nameController: state.titleControllerList.isNotEmpty ? state.titleControllerList[0] : state.nameController,
      descriptionController: state.descriptionControllerList.isNotEmpty ? state.descriptionControllerList[0] : state.descriptionController,
      selectedProductType: state.selectedProductType,
      selectedCategory: state.selectedCategory,
      selectedItemCondition: state.selectedItemCondition,
      shippingFeeController: state.shippingFeeController,
      returnPolicyController: state.returnPolicyController,
      additionalImages: [...imageController.productImages, ...imageController.existingImageUrls],
      videoLinkController: state.videoLinkController,
      videoUploadType: state.videoUploadType,
      thumbnailFile: imageController.thumbnailFile,
      existingThumbnailUrl: imageController.existingThumbnailUrl,
    );

    if (isValid) _tabController.animateTo(1);
  }

  void _onAuctionInfoNext() {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    final state = _auctionInfoKey.currentState;

    if (state == null) return;

    final bool isValid = controller.validateAuctionInfo(
      context,
      startPriceController: state.startPriceController,
      minimumIncrementController: state.minimumIncrementController,
      maximumDecrementController: state.maximumDecrementController,
      selectedVatTaxRate: state.selectedVatTax,
      startTime: state.selectedStartTime,
      endTime: state.selectedEndTime,
    );

    if (isValid) _tabController.animateTo(2);
  }

  Future<void> _onSubmit() async {
    final controller = Provider.of<AddAuctionProductController>(context, listen: false);
    final imageController = Provider.of<AddAuctionProductMediaController>(context, listen: false);

    final generalState = _generalInfoKey.currentState;
    final auctionState = _auctionInfoKey.currentState;
    final seoState = _seoKey.currentState;

    if (generalState == null) { _tabController.animateTo(0); return; }
    if (auctionState == null) { _tabController.animateTo(1); return; }
    if (seoState == null) { _tabController.animateTo(2); return; }

    if (widget.isRelaunchMode) {
      final isGeneralValid = controller.validateGeneralInfo(
        context,
        nameController: generalState.titleControllerList.isNotEmpty ? generalState.titleControllerList[0] : generalState.nameController,
        descriptionController: generalState.descriptionControllerList.isNotEmpty ? generalState.descriptionControllerList[0] : generalState.descriptionController,
        selectedProductType: generalState.selectedProductType,
        selectedCategory: generalState.selectedCategory,
        selectedItemCondition: generalState.selectedItemCondition,
        shippingFeeController: generalState.shippingFeeController,
        returnPolicyController: generalState.returnPolicyController,
        additionalImages: [...imageController.productImages, ...imageController.existingImageUrls],
        videoLinkController: generalState.videoLinkController,
        videoUploadType: generalState.videoUploadType,
        thumbnailFile: imageController.thumbnailFile,
        existingThumbnailUrl: imageController.existingThumbnailUrl,
      );
      if (!isGeneralValid) { _tabController.animateTo(0); return; }

      final isAuctionValid = controller.validateAuctionInfo(
        context,
        startPriceController: auctionState.startPriceController,
        minimumIncrementController: auctionState.minimumIncrementController,
        maximumDecrementController: auctionState.maximumDecrementController,
        selectedVatTaxRate: auctionState.selectedVatTax,
        startTime: auctionState.selectedStartTime,
        endTime: auctionState.selectedEndTime,
      );
      if (!isAuctionValid) { _tabController.animateTo(1); return; }

      final response = await controller.relaunchAuction(
        context,
        productId: widget.productId!,
        nameController: generalState.titleControllerList.isNotEmpty ? generalState.titleControllerList : [generalState.nameController],
        descriptionController: generalState.descriptionControllerList.isNotEmpty ? generalState.descriptionControllerList : [generalState.descriptionController],
        selectedCategory: generalState.selectedCategory,
        selectedBrand: generalState.selectedBrand,
        selectedProductType: generalState.selectedProductType,
        itemCondition: generalState.selectedItemCondition,
        shippingFeeController: generalState.shippingFeeController,
        returnPolicyController: generalState.returnPolicyController,
        videoLinkController: generalState.videoLinkController,
        videoUploadType: generalState.videoUploadType,
        startPriceController: auctionState.startPriceController,
        minimumIncrementController: auctionState.minimumIncrementController,
        maximumDecrementController: auctionState.maximumDecrementController,
        entryFeeController: auctionState.entryFeeController,
        selectedVatTax: auctionState.selectedVatTax,
        startTime: auctionState.selectedStartTime,
        endTime: auctionState.selectedEndTime,
        tags: auctionState.selectedTags,
        metaTitleController: seoState.metaTitleController,
        metaDescriptionController: seoState.metaDescriptionController,
        metaImageFile: imageController.effectiveSeoThumbnail,
      );

      if (response != null && response.response?.statusCode == 200) {
        dynamic responseData = response.response?.data;
        if (responseData is Map && responseData.containsKey('errors') && responseData['errors'] != null) {
          List errors = responseData['errors'];
          if (errors.isNotEmpty) {
            String errorMessage = '';
            if (errors[0] is Map) errorMessage = errors[0]['message'] ?? 'An error occurred';
            if (mounted) showCustomSnackBar(errorMessage, context, isError: true);
            return;
          }
        }
        if (mounted) Navigator.pop(context);
      }
      return;
    }

    final isGeneralValid = controller.validateGeneralInfo(
      context,
      nameController: generalState.titleControllerList.isNotEmpty ? generalState.titleControllerList[0] : generalState.nameController,
      descriptionController: generalState.descriptionControllerList.isNotEmpty ? generalState.descriptionControllerList[0] : generalState.descriptionController,
      selectedProductType: generalState.selectedProductType,
      selectedCategory: generalState.selectedCategory,
      selectedItemCondition: generalState.selectedItemCondition,
      shippingFeeController: generalState.shippingFeeController,
      returnPolicyController: generalState.returnPolicyController,
      additionalImages: [...imageController.productImages, ...imageController.existingImageUrls],
      videoLinkController: generalState.videoLinkController,
      videoUploadType: generalState.videoUploadType,
      thumbnailFile: imageController.thumbnailFile,
      existingThumbnailUrl: imageController.existingThumbnailUrl,
    );
    if (!isGeneralValid) { _tabController.animateTo(0); return; }

    final isAuctionValid = controller.validateAuctionInfo(
      context,
      startPriceController: auctionState.startPriceController,
      minimumIncrementController: auctionState.minimumIncrementController,
      maximumDecrementController: auctionState.maximumDecrementController,
      selectedVatTaxRate: auctionState.selectedVatTax,
      startTime: auctionState.selectedStartTime,
      endTime: auctionState.selectedEndTime,
    );
    if (!isAuctionValid) { _tabController.animateTo(1); return; }

    ApiResponseModel? response;

    if (_isEditMode) {
      response = await controller.updateAuctionProduct(
        context,
        productId: widget.productId!,
        nameController: generalState.titleControllerList.isNotEmpty ? generalState.titleControllerList : [generalState.nameController],
        descriptionController: generalState.descriptionControllerList.isNotEmpty ? generalState.descriptionControllerList : [generalState.descriptionController],
        selectedCategory: generalState.selectedCategory,
        selectedBrand: generalState.selectedBrand,
        selectedProductType: generalState.selectedProductType,
        itemCondition: generalState.selectedItemCondition,
        shippingFeeController: generalState.shippingFeeController,
        returnPolicyController: generalState.returnPolicyController,
        videoLinkController: generalState.videoLinkController,
        videoUploadType: generalState.videoUploadType,
        startPriceController: auctionState.startPriceController,
        minimumIncrementController: auctionState.minimumIncrementController,
        maximumDecrementController: auctionState.maximumDecrementController,
        entryFeeController: auctionState.entryFeeController,
        selectedVatTax: auctionState.selectedVatTax,
        startTime: auctionState.selectedStartTime,
        endTime: auctionState.selectedEndTime,
        tags: auctionState.selectedTags,
        metaTitleController: seoState.metaTitleController,
        metaDescriptionController: seoState.metaDescriptionController,
        metaImageFile: imageController.effectiveSeoThumbnail,
      );
    } else {
      response = await controller.addAuctionProduct(
        context,
        nameController: generalState.titleControllerList.isNotEmpty ? generalState.titleControllerList : [generalState.nameController],
        descriptionController: generalState.descriptionControllerList.isNotEmpty ? generalState.descriptionControllerList : [generalState.descriptionController],
        selectedCategory: generalState.selectedCategory,
        selectedBrand: generalState.selectedBrand,
        selectedProductType: generalState.selectedProductType,
        itemCondition: generalState.selectedItemCondition,
        shippingFeeController: generalState.shippingFeeController,
        returnPolicyController: generalState.returnPolicyController,
        videoLinkController: generalState.videoLinkController,
        videoUploadType: generalState.videoUploadType,
        startPriceController: auctionState.startPriceController,
        minimumIncrementController: auctionState.minimumIncrementController,
        maximumDecrementController: auctionState.maximumDecrementController,
        entryFeeController: auctionState.entryFeeController,
        selectedVatTax: auctionState.selectedVatTax,
        startTime: auctionState.selectedStartTime,
        endTime: auctionState.selectedEndTime,
        tags: auctionState.selectedTags,
        metaTitleController: seoState.metaTitleController,
        metaDescriptionController: seoState.metaDescriptionController,
        metaImageFile: imageController.effectiveSeoThumbnail,
      );
    }

    if (response != null && response.response?.statusCode == 200) {
      // Check if the response contains errors even with 200 status
      dynamic responseData = response.response?.data;
      if (responseData is Map && responseData.containsKey('errors') && responseData['errors'] != null) {
        List errors = responseData['errors'];
        if (errors.isNotEmpty) {
          String errorMessage = '';
          if (errors[0] is Map) {
            errorMessage = errors[0]['message'] ?? 'An error occurred';
          }
          if (mounted) {
            showCustomSnackBar(errorMessage, context, isError: true);
          }
          return;
        }
      }

      // No errors, show success
      RouterHelper.getAuctionQueueListRoute(action: RouteAction.push);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerTitle: false,
        title: widget.isRelaunchMode
            ? getTranslated('relaunch_auction', context) ?? "Relaunch Auction"
            : _isEditMode ? getTranslated('edit_auction_product', context) ?? "Edit Auction" : getTranslated('add_auction_product', context) ?? "Add Auction",
        showActionButton: true,
        actions: [GeneratesLeftCount()],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeSmall,
            ),
            height: 60,
            child: AddProductTitleBar(
              tabController: _tabController,
              tabs: [
                Tab(text: getTranslated('general_info', context) ?? 'General Info'),
                Tab(text: getTranslated('auction_info', context) ?? 'Auction Info'),
                Tab(text: getTranslated('seo', context) ?? 'SEO'),
              ],
            ),
          ),

          Flexible(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                AddAuctionProductScreen(
                  key: _generalInfoKey,
                  onNext: _onGeneralInfoNext,
                  initialProduct: _product,
                ),
                AuctionInfoScreen(
                  key: _auctionInfoKey,
                  onBack: () => _tabController.animateTo(0),
                  onNext: _onAuctionInfoNext,
                  initialProduct: _product,
                  isRelaunchMode: widget.isRelaunchMode,
                  getProductTitle: () => _generalInfoKey.currentState?.titleControllerList.isNotEmpty == true
                      ? _generalInfoKey.currentState!.titleControllerList[0].text : '',
                  getProductDescription: () => _generalInfoKey.currentState?.descriptionControllerList.isNotEmpty == true
                      ? _generalInfoKey.currentState!.descriptionControllerList[0].text : '',
                ),
                AddAuctionProductSeoScreen(
                  key: _seoKey,
                  isLastTab: true,
                  onNext: _onSubmit,
                  initialProduct: _product,
                  getProductTitle: () => _generalInfoKey.currentState?.titleControllerList.isNotEmpty == true
                      ? _generalInfoKey.currentState!.titleControllerList[0].text : '',
                  getProductDescription: () => _generalInfoKey.currentState?.descriptionControllerList.isNotEmpty == true
                      ? _generalInfoKey.currentState!.descriptionControllerList[0].text : '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddProductTitleBar extends StatelessWidget {
  final TabController tabController;
  final List<Tab> tabs;

  const AddProductTitleBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: TabBar(
        labelPadding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        controller: tabController,
        tabs: tabs,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
          border: Border.all(color: Theme.of(context).primaryColor),
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}