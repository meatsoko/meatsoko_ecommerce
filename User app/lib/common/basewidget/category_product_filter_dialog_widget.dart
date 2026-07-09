import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_loader_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/domain/models/brand_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/domain/models/author_model.dart';
import 'package:flutter_sixvalley_ecommerce/features/splash/controllers/splash_controller.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/features/brand/controllers/brand_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/controllers/search_product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/custom_button_widget.dart';
import 'package:provider/provider.dart';

class CategoryProductFilterDialog extends StatefulWidget {
  final int categoryId;
  const CategoryProductFilterDialog({super.key, required this.categoryId});

  @override
  CategoryProductFilterDialogState createState() => CategoryProductFilterDialogState();
}

class CategoryProductFilterDialogState extends State<CategoryProductFilterDialog> {
  List<int> authors = [];
  List<int> publishingHouses = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);

    return Dismissible(
      key: const Key('key'),
      direction: DismissDirection.down,
      onDismissed: (_) => Navigator.pop(context),
      child: Consumer<SearchProductController>(builder: (context, searchProvider, child) {
        late List<AuthorModel>? authorList = Provider.of<SearchProductController>(context, listen: false).authorsList;

        late List<AuthorModel>? publishingHouse = Provider.of<SearchProductController>(context, listen: false).publishingHouseList;

        if (authorList!.isNotEmpty) {
          for (int i = 0; i < authorList.length; i++) {
            authors.add(i);
          }
        }

        if (publishingHouse!.isNotEmpty) {
          for (int i = 0; i < publishingHouse.length; i++) {
            publishingHouses.add(i);
          }
        }

        return Consumer<BrandController>(builder: (context, brandProvider, _) {
          return Container(
            constraints: BoxConstraints(maxHeight: size.height * 0.9),
            decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: Dimensions.paddingSizeSmall),

                  Center(
                      child: Container(
                          width: 35,
                          height: 4,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Dimensions.paddingSizeDefault),
                              color: Theme.of(context).hintColor.withValues(alpha: .5)))),
                  const SizedBox(height: Dimensions.paddingSizeDefault),

                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const SizedBox(width: 64),

                    Text(getTranslated('filter', context) ?? '',
                        style: titilliumSemiBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color)),

                    (brandProvider.selectedBrandIds.isNotEmpty || searchProvider.publishingHouseIds.isNotEmpty || searchProvider.selectedAuthorIds.isNotEmpty)
                        ? InkWell(
                            onTap: () async {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => const CustomLoaderWidget());

                              searchProvider.setFilterApply(isFiltered: false);
                              brandProvider.selectedBrandIds.clear();
                              searchProvider.publishingHouseIds.clear();
                              searchProvider.selectedAuthorIds.clear();
                              searchProvider.resetChecked(null, false);

                              if (context.mounted) {
                                Provider.of<SearchProductController>(context, listen: false).setProductTypeIndex(0, false);

                                Provider.of<ProductController>(context, listen: false)
                                    .clearCategoryProductFor(widget.categoryId);
                                await Provider.of<ProductController>(context, listen: false)
                                    .getCategoryProducts(widget.categoryId, 1);

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                              }
                            },
                            child: Row(children: [
                              SizedBox(width: 20, child: Image.asset(Images.reset)),
                              Text('${getTranslated('reset', context)}',
                                  style: textRegular.copyWith(color: Theme.of(context).primaryColor)),
                              const SizedBox(width: Dimensions.paddingSizeDefault)
                            ]),
                          ) : SizedBox(width: size.width * 0.19),
                  ]),
                ]),

                Flexible(
                    child: Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (Provider.of<SplashController>(context, listen: false).configModel?.digitalProductSetting == '1') ...[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Text(getTranslated('product_type', context)!,
                                  style: titilliumSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                              const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  border: Border.all(width: .7, color: Theme.of(context).hintColor.withValues(alpha: .3)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                ),
                                child: DropdownButton<String>(
                                  value: searchProvider.productTypeIndex == 0 ? 'all_product_search' : searchProvider.productTypeIndex == 1 ? 'physical' : 'digital',
                                  style: textRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context).textTheme.bodyLarge?.color),
                                  items: <String>['all_product_search', 'physical', 'digital'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(getTranslated(value, context)!),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    searchProvider.setProductTypeIndex(value == 'all_product_search' ? 0 : value == 'physical' ? 1 : 2, true);
                                  },
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                        ],

                        if ((searchProvider.productTypeIndex == 0 || searchProvider.productTypeIndex == 1) && brandProvider.brandList.isNotEmpty) ...[
                          Padding(
                              padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                              child: Text(getTranslated('brand', context) ?? '',
                                  style: titilliumSemiBold.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Theme.of(context).textTheme.bodyLarge?.color))),

                          Divider(color: Theme.of(context).hintColor.withValues(alpha: .25), thickness: .5),

                          ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: 40.0,
                              maxHeight: 350.0,
                            ),
                            child: RepaintBoundary(
                              child: ListView.builder(
                                  itemCount: brandProvider.brandList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return CategoryFilterItem(
                                        title: brandProvider.brandList[index].name,
                                        checked: brandProvider.brandList[index].checked!,
                                        onTap: () => brandProvider.checkedToggleBrand(index));
                                  }),
                            ),
                          ),
                        ],

                        if ((authorList.isNotEmpty) && searchProvider.productTypeIndex == 0 || searchProvider.productTypeIndex == 2) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(getTranslated('author_creator_artist', context) ?? '',
                              style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Autocomplete<int>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty) {
                                return const Iterable<int>.empty();
                              } else {
                                return authors.where((author) => authorList[author].name!.toLowerCase().contains(value.text.toLowerCase()));
                              }
                            },
                            fieldViewBuilder: (context, controller, node, onComplete) {
                              return Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).highlightColor,
                                  border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .50)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                ),
                                child: TextField(
                                  controller: controller,
                                  focusNode: node,
                                  onEditingComplete: onComplete,
                                  decoration: InputDecoration(
                                    hintText: getTranslated('search_by_author', context),
                                    hintStyle: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall), borderSide: BorderSide.none),
                                  ),
                                ),
                              );
                            },
                            displayStringForOption: (value) => authorList[value].name!,
                            onSelected: (int value) {
                              searchProvider.checkedToggleAuthors(value, false);
                            },
                          ),

                          if (authorList.isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                maxHeight: 350.0,
                              ),
                              child: RepaintBoundary(
                                child: ListView.builder(
                                    itemCount: authorList.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return CategoryFilterItem(
                                        title: authorList[index].name,
                                        checked: authorList[index].isChecked!,
                                        onTap: () => searchProvider.checkedToggleAuthors(index, false),
                                      );
                                    }),
                              ),
                            ),
                        ],

                        if ((publishingHouse.isNotEmpty) && searchProvider.productTypeIndex == 0 ||
                            searchProvider.productTypeIndex == 2) ...[
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(getTranslated('publishing_house', context) ?? '',
                              style: titilliumSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).textTheme.bodyLarge?.color)),
                          const SizedBox(height: Dimensions.paddingSizeSmall),

                          Autocomplete<int>(
                            optionsBuilder: (TextEditingValue value) {
                              if (value.text.isEmpty) {
                                return const Iterable<int>.empty();
                              } else {
                                return publishingHouses.where((ph) => publishingHouse[ph].name!.toLowerCase().contains(value.text.toLowerCase()));
                              }
                            },
                            fieldViewBuilder: (context, controller, node, onComplete) {
                              return Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).highlightColor,
                                  border: Border.all(width: 1, color: Theme.of(context).hintColor.withValues(alpha: .50)),
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                                ),
                                child: TextField(
                                  controller: controller,
                                  focusNode: node,
                                  onEditingComplete: onComplete,
                                  decoration: InputDecoration(
                                    hintText: getTranslated('search_by_publishing_house', context),
                                    hintStyle: textMedium.copyWith(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).hintColor),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall), borderSide: BorderSide.none),
                                  ),
                                ),
                              );
                            },
                            displayStringForOption: (value) => publishingHouse[value].name!,
                            onSelected: (int value) {
                              searchProvider.checkedTogglePublishingHouse(value, false);
                            },
                          ),

                          if (publishingHouse.isNotEmpty)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minHeight: 40.0,
                                maxHeight: 350.0,
                              ),
                              child: RepaintBoundary(
                                child: ListView.builder(
                                    itemCount: publishingHouse.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return CategoryFilterItem(
                                        title: publishingHouse[index].name,
                                        checked: publishingHouse[index].isChecked!,
                                        onTap: () => searchProvider.checkedTogglePublishingHouse(index, false),
                                      );
                                    }),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                )),

                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: CustomButton(
                    buttonText: getTranslated('apply', context),
                    onTap: brandProvider.selectedBrandIds.isEmpty &&
                            searchProvider.selectedAuthorIds.isEmpty &&
                            searchProvider.publishingHouseIds.isEmpty &&
                            searchProvider.productTypeIndex == 0
                        ? null
                        : () {
                            searchProvider.setFilterApply(isFiltered: true);

                            List<int> selectedBrandIdsList = [];
                            for (BrandModel brand in brandProvider.brandList) {
                              if (brand.checked!) {
                                selectedBrandIdsList.add(brand.id!);
                              }
                            }

                            String selectedBrandId = selectedBrandIdsList.isNotEmpty ? jsonEncode(selectedBrandIdsList) : '[]';
                            String selectedAuthorId = searchProvider.selectedAuthorIds.isNotEmpty ? jsonEncode(searchProvider.selectedAuthorIds) : '[]';
                            String selectedPublishingId = searchProvider.publishingHouseIds.isNotEmpty ? jsonEncode(searchProvider.publishingHouseIds) : '[]';

                            String? productType = searchProvider.productTypeIndex == 1
                                ? 'physical'
                                : searchProvider.productTypeIndex == 2
                                    ? 'digital'
                                    : null;

                            Provider.of<ProductController>(context, listen: false)
                                .clearCategoryProductFor(widget.categoryId);
                            Provider.of<ProductController>(context, listen: false).getCategoryProducts(
                              widget.categoryId,
                              1,
                              productType: productType,
                              brandIds: selectedBrandId,
                              authorIds: selectedAuthorId,
                              publishingIds: selectedPublishingId,
                            );
                            Navigator.pop(context);
                          },
                  ),
                ),
              ],
            ),
          );
        });
      }),
    );
  }
}

class CategoryFilterItem extends StatelessWidget {
  final String? title;
  final bool checked;
  final Function()? onTap;
  const CategoryFilterItem({super.key, required this.title, required this.checked, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
              child: Icon(
                  checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: (checked && !Provider.of<ThemeController>(context, listen: false).darkTheme)
                      ? Theme.of(context).primaryColor
                      : (checked && Provider.of<ThemeController>(context, listen: false).darkTheme) ? Colors.white : Theme.of(context).hintColor.withValues(alpha: .5)),
            ),
            Expanded(
                child: Text(title ?? '',
                    style: textRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color))),
          ]),
        ),
      ),
    );
  }
}
