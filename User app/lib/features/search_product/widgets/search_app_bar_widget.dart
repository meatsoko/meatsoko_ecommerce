import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/search_product/widgets/partial_matched_widget.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onBackPressed;
  final bool fromCompare;
  final int? id;

  const SearchAppBar({super.key, this.onBackPressed, this.fromCompare = false, this.id});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).cardColor,
      automaticallyImplyLeading: false,
      toolbarHeight: preferredSize.height,
      titleSpacing: 0,
      elevation: 0,
      scrolledUnderElevation: 0,
      clipBehavior: Clip.none,
      shadowColor: Colors.transparent,
      title: Row(children: [
        // Matches the search field's bottom padding so the back icon lines up with its center.
        Padding(padding: const EdgeInsets.only(bottom: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18,
                color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: .75)),
            onPressed: () => onBackPressed != null ? onBackPressed!() : Navigator.pop(context))),

        Expanded(child: Padding(padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
          child: SearchSuggestion(fromCompare: fromCompare, id: id))),
      ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
