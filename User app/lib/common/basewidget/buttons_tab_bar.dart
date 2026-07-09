import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/theme/controllers/theme_controller.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:provider/provider.dart';

class ButtonsTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  // When true (e.g. the tab bar is pinned right under the sticky search bar),
  // each tab is sized tightly to its 30px button instead of Flutter's default
  // 46px minimum, removing the internal dead space above/below the buttons.
  final bool isSticky;

  const ButtonsTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    this.isSticky = false,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      indicator: const BoxDecoration(),
      dividerColor: Colors.transparent,
      labelPadding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      tabs: tabs.asMap().entries.map((entry) => SelectedTab(
        label: entry.value,
        controller: controller,
        index: entry.key,
        isSticky: isSticky,
      )).toList(),
    );
  }
}

class SelectedTab extends StatelessWidget {
  final String label;
  final TabController controller;
  final int index;
  final bool isSticky;

  const SelectedTab({super.key,
    required this.label,
    required this.controller,
    required this.index,
    this.isSticky = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final bool selected = controller.index == index;
        final bool isDark = Provider.of<ThemeController>(context, listen: false).darkTheme;

        return Tab(
          height: isSticky ? 30 : null,
          child: Container(
            height: 30,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: selected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: selected ? Theme.of(context).primaryColor : Theme.of(context).hintColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),

            // is it pollible to implement that banner comes out fdormn the screen left and keep left
            child: Text(label,
              style: selected
                  ? titilliumSemiBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isDark ? Colors.white : Colors.white,
              ) : titilliumRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.titleMedium?.color,
              ),
            ),
          ),
        );
      },
    );
  }
}