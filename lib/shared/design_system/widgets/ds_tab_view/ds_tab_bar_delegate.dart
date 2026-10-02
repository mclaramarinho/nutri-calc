import 'package:flutter/material.dart';

import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';

class TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  TabBarDelegate(this._tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: _tabBar.preferredSize.height,
      child: Material(color: DsColors.of(context).white, child: _tabBar),
    );
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
