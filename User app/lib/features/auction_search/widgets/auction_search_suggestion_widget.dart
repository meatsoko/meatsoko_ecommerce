import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auction_search/controllers/auction_search_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/domain/models/suggestion_product_model.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/images.dart';
import 'package:provider/provider.dart';
import 'package:substring_highlight/substring_highlight.dart';

class AuctionSearchSuggestionWidget extends StatelessWidget {
  const AuctionSearchSuggestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuctionSearchController>(
      builder: (context, controller, _) {
        return SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  final String query = textEditingValue.text.trim();
                  if (query.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final List<String> names = await controller.getSuggestionAuctionProductName(query);
                  return names.where((word) => word.toLowerCase().contains(query.toLowerCase()));
                },
                optionsViewOpenDirection: OptionsViewOpenDirection.down,
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    elevation: 4,
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return InkWell(
                          onTap: () {
                            final Products? selectedProduct = controller.suggestionModel?.products
                                ?.firstWhere((product) => product.name == option,
                                orElse: () => Products());
                            if (selectedProduct?.slug != null) {
                              controller.searchFocusNode.unfocus();
                              RouterHelper.getParticipationAuctionDetailsRoute(
                                slug: selectedProduct!.slug!,
                                action: RouteAction.push,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Icon(Icons.history, color: Theme.of(context).hintColor, size: 25),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: SubstringHighlight(
                                      text: option,
                                      textStyle: textRegular.copyWith(
                                        color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                      term: controller.searchController.text,
                                      textStyleHighlight: textMedium.copyWith(
                                        color: Theme.of(context).textTheme.bodyLarge?.color,
                                        fontSize: Dimensions.fontSizeLarge,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                  child: Icon(CupertinoIcons.arrow_up_right, color: Theme.of(context).hintColor, size: 25),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                onSelected: (selectedString) {
                  controller.updateSearchText(selectedString);
                  controller.saveSearchName(selectedString);
                  controller.getAuctionList(search: selectedString, offset: 1, reload: true);
                },
                fieldViewBuilder: (context, fieldController, focusNode, onEditingComplete) {
                  if (controller.searchController != fieldController) {
                    controller.searchController = fieldController;
                  }
                  controller.searchFocusNode = focusNode;

                  return TextFormField(
                    controller: fieldController,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) {
                      if (val.isEmpty) {
                        controller.cleanAuctionSearch(notify: true);
                      }
                    },
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        focusNode.unfocus();
                        controller.updateSearchText(value);
                        controller.saveSearchName(value);
                        controller.getAuctionList(search: value, offset: 1, reload: true);
                      }
                    },
                    style: textMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      hintText: getTranslated('search_auction', context) ?? '',
                      hintStyle: textRegular.copyWith(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.9)),
                      suffixIcon: SizedBox(
                        width: fieldController.text.isNotEmpty ? 70 : 50,
                        child: Row(
                          children: [
                            if (fieldController.text.isNotEmpty)
                              InkWell(
                                onTap: () {
                                  fieldController.clear();
                                  controller.cleanAuctionSearch(notify: true);
                                },
                                child: const Icon(Icons.clear, size: 20),
                              ),
                            InkWell(
                              onTap: () {
                                if (fieldController.text.trim().isNotEmpty) {
                                  focusNode.unfocus();
                                  controller.updateSearchText(fieldController.text);
                                  controller.saveSearchName(fieldController.text);
                                  controller.getAuctionList(search: fieldController.text, offset: 1, reload: true);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeExtraSmall),
                                ),
                                child: Image.asset(Images.search, color: Colors.white, height: Dimensions.iconSizeSmall, width: Dimensions.iconSizeSmall, fit: BoxFit.contain),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
      },
    );
  }
}