import 'package:user_app/features/product/domain/models/product_model.dart';
import 'package:user_app/features/product_details/domain/models/product_details_model.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart';

class ProductHelper{

  // Resolves price/stock/variation for whatever combination of color +
  // choice-options (e.g. size/cut) is currently selected — same
  // variation-type-string algorithm CartBottomSheetWidget's own resolution
  // uses (colors[variantIndex].name, then each choiceOptions[i] joined with
  // "-", spaces stripped, matched against product.variation). Used by the
  // page's inline "Customize" section and quantity stepper, and by the
  // direct-add-to-cart path in BottomCartWidget, so both read the exact same
  // resolution the sheet would have used if it were opened instead.
  //
  // `variationIndexList` is optional — omit it (or pass an empty/short list)
  // for a product with only a color variant and no choice-options; each
  // missing/short entry defaults to option index 0, matching
  // ProductDetailsController.initData's own default.
  static ({String variationType, double? price, int? stock, Variation? variation}) resolveVariant(
    ProductDetailsModel product, {
    required int variantIndex,
    List<int>? variationIndexList,
  }) {
    final bool hasColor = product.colors != null && product.colors!.isNotEmpty && variantIndex < product.colors!.length;
    final String? variantName = hasColor ? product.colors![variantIndex].name : null;

    final List<String> variationList = [];
    final choiceOptions = product.choiceOptions ?? const [];
    for (int i = 0; i < choiceOptions.length; i++) {
      final options = choiceOptions[i].options ?? const [];
      final int selected = (variationIndexList != null && i < variationIndexList.length) ? variationIndexList[i] : 0;
      if (selected < options.length) variationList.add(options[selected].trim());
    }

    String variationType;
    if (variantName != null) {
      variationType = variantName;
      for (final v in variationList) {
        variationType = '$variationType-$v';
      }
    } else {
      variationType = variationList.join('-');
    }
    variationType = variationType.replaceAll(' ', '');

    double? price = product.unitPrice;
    int? stock = product.currentStock;
    Variation? matched;
    for (final v in product.variation ?? const []) {
      if (v.type == variationType) {
        matched = v;
        price = v.price;
        stock = v.qty;
        break;
      }
    }
    return (variationType: variationType, price: price, stock: stock, variation: matched);
  }

  static ({double? end, double? start}) getProductPriceRange(ProductDetailsModel? productDetailsModel){
    double? startingPrice = 0;
    double? endingPrice;
    if(productDetailsModel?.variation?.isNotEmpty ?? false) {
      List<double?> priceList = [];
      for (var variation in productDetailsModel!.variation!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = productDetailsModel?.unitPrice;
    }

    return (start: startingPrice, end: endingPrice);
  }

  static String removeIframe(String htmlString) {
    final regex =  RegExp(
      r'(</span></p>)?(</p>)?<iframe[^>]*src="https:\/\/www\.youtube\.com\/embed\/[^"]*"[^>]*><\/iframe><p[^>]*>(<strong[^>]*>\s*<\/strong>)?<span[^>]*>',
      caseSensitive: false,
      dotAll: true,
    );

    return htmlString.replaceAll(regex, '')
        .replaceAll('&nbsp;', '');
  }

  static String htmlToPlainText(String htmlContent) {
    // Parse HTML string
    Document document = parse(htmlContent);

    StringBuffer buffer = StringBuffer();
    int olIndex = 1; // for ordered lists

    void parseNode(Node node) {
      if (node is Element) {
        switch (node.localName) {
          case 'h1':
          case 'h2':
          case 'h3':
          case 'h4':
          case 'h5':
          case 'h6':
            buffer.writeln('\n${node.text.trim()}\n');
            break;
          case 'p':
            buffer.writeln('${node.text.trim()}\n');
            break;
          case 'li':
          // detect if parent is <ol>
            if (node.parent?.localName == 'ol') {
              buffer.writeln('$olIndex. ${node.text.trim()}');
              olIndex++;
            } else {
              buffer.writeln('• ${node.text.trim()}');
            }
            break;
          case 'ol':
            olIndex = 1; // reset counter
            node.nodes.forEach(parseNode);
            buffer.writeln();
            break;
          case 'ul':
            node.nodes.forEach(parseNode);
            buffer.writeln();
            break;
          case 'br':
            buffer.writeln();
            break;
          default:
            node.nodes.forEach(parseNode);
        }
      } else if (node is Text) {
        final text = node.text.trim();
        if (text.isNotEmpty) buffer.write('$text ');
      }
    }

    // Parse body
    document.body?.nodes.forEach(parseNode);

    // Clean up multiple blank lines
    String plainText = buffer.toString()
        .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
        .trim();

    return plainText;
  }
}