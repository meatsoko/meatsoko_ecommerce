import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/enums/product_type.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';

extension ProductTypeExtension on ProductType {
  String displayName(BuildContext context) {
    switch (this) {
      case ProductType.allProduct:
        return getTranslated('all_product', context)!;
      case ProductType.latestProduct:
        return getTranslated('latest_product', context)!;
      case ProductType.sellerProduct:
        return getTranslated('seller_product', context)!;
      case ProductType.featuredProduct:
        return getTranslated('featured_product', context)!;
      case ProductType.topProduct:
        return getTranslated('top_product', context)!;
      case ProductType.newArrival:
        return getTranslated('new_arrival', context)!;
      case ProductType.bestSelling:
        return getTranslated('best_selling', context)!;
      case ProductType.discountedProduct:
        return getTranslated('discounted_product', context)!;
      case ProductType.justForYou:
        return getTranslated('just_for_you', context)!;
    }
  }
}