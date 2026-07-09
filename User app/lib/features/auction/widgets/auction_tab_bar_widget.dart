import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class AuctionTabBarWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<String> tabs;
  final List<int?>? counts;

  const AuctionTabBarWidget({super.key, required this.selectedIndex, required this.onTabChanged, required this.tabs, this.counts});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.homePagePadding),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedIndex;
          final int? count = counts != null && index < counts!.length ? counts![index] : null;

          return GestureDetector(
            onTap: () => onTabChanged(index),
            child: Container(
              height: 30,
              alignment: Alignment.center,
              margin: const EdgeInsetsDirectional.only(end: Dimensions.paddingSizeSmall),
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tabs[index],
                    style: isSelected ? titilliumSemiBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Colors.white,
                    ) : titilliumRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    Text('($count)',
                      style: isSelected ? titilliumSemiBold.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Colors.white.withValues(alpha: 0.70),
                      ) : titilliumRegular.copyWith(
                        fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.titleMedium?.color?.withValues(alpha: 0.70),
                      ),
                    )
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}