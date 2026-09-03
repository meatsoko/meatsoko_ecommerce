import 'package:flutter/material.dart';
import 'package:user_app/common/basewidget/custom_asset_image_widget.dart';
import 'package:user_app/common/basewidget/custom_image_widget.dart';
import 'package:user_app/features/category/domain/models/category_model.dart';
import 'package:user_app/helper/route_healper.dart';
import 'package:user_app/localization/language_constrants.dart';
import 'package:user_app/utill/brand_colors.dart';
import 'package:user_app/utill/custom_themes.dart';
import 'package:user_app/utill/dimensions.dart';

/// The grid's 6 tiles are a fixed, curated set (not the live backend
/// category list) — matchTerm is used to jump to the real category tab if
/// one with a matching name exists; null means "More" (opens the full
/// category browser instead of a tab).
class _FixedCategoryTile {
  final String label;
  final String asset;
  final String? matchTerm;

  const _FixedCategoryTile({required this.label, required this.asset, this.matchTerm});
}

const List<_FixedCategoryTile> _homeCategoryTiles = [
  _FixedCategoryTile(label: 'Goat Meat', asset: 'assets/image/category_goat_meat.png', matchTerm: 'goat'),
  _FixedCategoryTile(label: 'Mutton', asset: 'assets/image/category_mutton.png', matchTerm: 'mutton'),
  _FixedCategoryTile(label: 'Offal', asset: 'assets/image/category_offal.png', matchTerm: 'offal'),
  _FixedCategoryTile(label: 'Bones & Soup', asset: 'assets/image/category_bones_soup.png', matchTerm: 'bone'),
  _FixedCategoryTile(label: 'Whole Animal', asset: 'assets/image/category_whole_animal.png', matchTerm: 'whole'),
  _FixedCategoryTile(label: 'More', asset: 'assets/image/category_more.svg', matchTerm: null),
];

/// Sliver header showing the real product categories as a 2-row grid on
/// first paint, then smoothly crossfading into a compact single-row sticky
/// bar as the user scrolls — same [tabController] (and therefore the same
/// category tabs / [HomeCategoryContent]) drives both representations, so
/// tapping a tile in either state is identical to tapping the old category
/// TabBar.
class CategoryMorphHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List<CategoryModel> categories;
  final TabController tabController;
  final double gridExtent;
  final double barExtent;

  const CategoryMorphHeaderDelegate({
    required this.categories,
    required this.tabController,
    this.gridExtent = 312,
    this.barExtent = 64,
  });

  @override
  double get maxExtent => gridExtent;

  @override
  double get minExtent => barExtent;

  void _selectCategory(int categoryIndex) {
    // Tab 0 is the Explore/home feed; categories start at tab 1.
    tabController.animateTo(categoryIndex + 1);
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double range = maxExtent - minExtent;
    final double clampedShrink = shrinkOffset.clamp(0.0, range);
    final double height = maxExtent - clampedShrink;
    final double t = range <= 0 ? 1.0 : (clampedShrink / range);

    final double gridOpacity = (1 - t * 2).clamp(0.0, 1.0);
    final double barOpacity = ((t - 0.5) * 2).clamp(0.0, 1.0);

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (gridOpacity > 0)
              IgnorePointer(
                ignoring: t > 0.5,
                child: Opacity(
                  opacity: gridOpacity,
                  child: _CategoryGrid(
                    categories: categories,
                    tabController: tabController,
                  ),
                ),
              ),
            if (barOpacity > 0)
              IgnorePointer(
                ignoring: t < 0.5,
                child: Opacity(
                  opacity: barOpacity,
                  child: _CategoryBar(
                    categories: categories,
                    tabController: tabController,
                    onTap: _selectCategory,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant CategoryMorphHeaderDelegate oldDelegate) =>
      oldDelegate.categories != categories ||
      oldDelegate.tabController != tabController ||
      oldDelegate.gridExtent != gridExtent ||
      oldDelegate.barExtent != barExtent;
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final TabController tabController;

  const _CategoryGrid({required this.categories, required this.tabController});

  /// Tapping any special-category tile (including "More") navigates to the
  /// Categories page. When the tile matches a real backend category by
  /// name, its id/name are passed on the route so Categories can highlight
  /// it on open (not yet consumed there — see getCategoryScreenRoute).
  void _handleTap(_FixedCategoryTile tile) {
    if (tile.matchTerm == null) {
      RouterHelper.getCategoryScreenRoute(action: RouteAction.push);
      return;
    }
    final int index = categories.indexWhere(
      (c) => (c.name ?? '').toLowerCase().contains(tile.matchTerm!),
    );
    if (index != -1) {
      final matched = categories[index];
      RouterHelper.getCategoryScreenRoute(
        action: RouteAction.push,
        categoryId: matched.id,
        categoryName: matched.name,
      );
    } else {
      RouterHelper.getCategoryScreenRoute(action: RouteAction.push);
    }
  }

  int? _matchedTabIndex(_FixedCategoryTile tile) {
    if (tile.matchTerm == null) return null;
    final int index = categories.indexWhere(
      (c) => (c.name ?? '').toLowerCase().contains(tile.matchTerm!),
    );
    return index == -1 ? null : index + 1;
  }

  @override
  Widget build(BuildContext context) {
    // Fit 3 tiles per row (matching the reference's 3-column grid) on the
    // current screen width, rather than a fixed tile size.
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tileWidth = (screenWidth - Dimensions.paddingSizeSmall * 2 - Dimensions.paddingSizeSmall * 2) / 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
      child: AnimatedBuilder(
        animation: tabController,
        builder: (context, _) {
          return GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              // Scroll direction is horizontal here, so mainAxisExtent is
              // each tile's *width* — fixing it directly (rather than via
              // childAspectRatio) avoids re-deriving the axis math wrong.
              mainAxisExtent: tileWidth,
              mainAxisSpacing: Dimensions.paddingSizeSmall,
              crossAxisSpacing: Dimensions.paddingSizeSmall,
            ),
            itemCount: _homeCategoryTiles.length,
            itemBuilder: (context, index) {
              final tile = _homeCategoryTiles[index];
              final int? matchedTab = _matchedTabIndex(tile);
              final bool isSelected = matchedTab != null && tabController.index == matchedTab;
              return _CategoryTile(
                title: tile.label,
                asset: tile.asset,
                isSelected: isSelected,
                onTap: () => _handleTap(tile),
              );
            },
          );
        },
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final List<CategoryModel> categories;
  final TabController tabController;
  final ValueChanged<int> onTap;

  const _CategoryBar({required this.categories, required this.tabController, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
          itemCount: categories.length,
          separatorBuilder: (context, index) => const SizedBox(width: Dimensions.paddingSizeSmall),
          itemBuilder: (context, index) {
            final bool isSelected = tabController.index == index + 1;
            return _CategoryChip(
              title: categories[index].name,
              icon: categories[index].imageFullUrl?.path,
              isSelected: isSelected,
              onTap: () => onTap(index),
            );
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String? title;
  final String asset;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTile({required this.title, required this.asset, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
          border: isSelected ? Border.all(color: BrandColors.burgundy, width: 1.4) : null,
          boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              child: CustomAssetImageWidget(asset, height: 76, width: 76, fit: BoxFit.cover),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Text(
                getTranslated(title, context) ?? title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected ? BrandColors.burgundy : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.title, required this.icon, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.burgundy.withValues(alpha: 0.08) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(100),
          border: isSelected ? Border.all(color: BrandColors.burgundy, width: 1.4) : null,
          boxShadow: isSelected ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CustomImageWidget(image: '$icon', height: 22, width: 22, fit: BoxFit.cover),
            ),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),
            Text(
              getTranslated(title, context) ?? title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: isSelected ? BrandColors.burgundy : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
