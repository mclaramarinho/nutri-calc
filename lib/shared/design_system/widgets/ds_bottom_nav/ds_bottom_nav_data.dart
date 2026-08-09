import 'package:flutter/widgets.dart';

class DsBottomNavData {
  final void Function(int) onTapBottomNavbar;
  final List<BottomNavigationBarItem> bottomNavbarItems;
  final int bottomNavbarActiveIndex;

  const DsBottomNavData({
    required this.onTapBottomNavbar,
    required this.bottomNavbarActiveIndex,
    required this.bottomNavbarItems,
  });

  DsBottomNavData copyWith({
    void Function(int)? onTapBottomNavbar,
    List<BottomNavigationBarItem>? bottomNavbarItems,
    int? bottomNavbarActiveIndex,
  }) => DsBottomNavData(
    onTapBottomNavbar: onTapBottomNavbar ?? this.onTapBottomNavbar,
    bottomNavbarActiveIndex:
        bottomNavbarActiveIndex ?? this.bottomNavbarActiveIndex,
    bottomNavbarItems: bottomNavbarItems ?? this.bottomNavbarItems,
  );
}
