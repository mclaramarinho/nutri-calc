import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/utils/extensions/ext_num_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_nav/ds_bottom_nav_data.dart';

class DsBottomNav extends StatefulWidget {
  final DsBottomNavData data;

  const DsBottomNav({required this.data, super.key});

  @override
  State<StatefulWidget> createState() => _DsBottomNavContent();
}

class _DsBottomNavContent extends State<DsBottomNav> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      iconSize: 120.w,
      currentIndex: widget.data.bottomNavbarActiveIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: DsColors.gray,
      selectedItemColor: DsColors.blue,
      unselectedItemColor: DsColors.black,
      elevation: 0,
      landscapeLayout: .centered,
      onTap: widget.data.onTapBottomNavbar,
      type: .fixed,
      items: widget.data.bottomNavbarItems,
    );
  }
}
