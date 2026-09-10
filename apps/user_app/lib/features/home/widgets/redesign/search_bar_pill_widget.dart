import 'package:flutter/material.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';

/// The rounded search-bar pill (+ adjacent, currently inert, filter icon)
/// originally built for the Home page. Shared here so any other page that
/// wants "the same search bar as Home" (e.g. Categories) reuses this exact
/// widget instead of an independently maintained copy that can drift out of
/// sync — [onTap] is the only thing callers need to vary, since where the
/// pill should navigate differs per page (Home sends it to Categories;
/// Categories sends it to the Search screen).
class SearchBarPillWidget extends StatelessWidget {
  final VoidCallback onTap;

  const SearchBarPillWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            onTap: onTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(children: [
                Icon(Icons.search,
                    color: Theme.of(context).hintColor, size: 22),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: Text(
                    getTranslated('search_hint', context) ??
                        'Search for products...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault),
                  ),
                ),
              ]),
            ),
          ),
        ),
        const SizedBox(width: Dimensions.paddingSizeSmall),
        // Filter icon: intentionally inert — no filter behavior wired up
        // yet, and it previously duplicated the pill's own search
        // navigation, which read as a second search bar.
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(Icons.filter_list,
              color: Theme.of(context).textTheme.bodyLarge?.color, size: 20),
        ),
      ],
    );
  }
}
