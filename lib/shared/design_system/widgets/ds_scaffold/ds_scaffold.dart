import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_nav/ds_bottom_nav.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_nav/ds_bottom_nav_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.dart';

class DsScaffold extends StatefulWidget {
  final List<Widget> children;
  final DsAppBarData? appBar;
  final DsFabData? fabData;
  final DsBottomNavData? bottomNavData;

  const DsScaffold({
    required this.children,
    this.appBar,
    this.fabData,
    this.bottomNavData,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DsScaffoldContent();
}

class _DsScaffoldContent extends State<DsScaffold> {
  @override
  Widget build(BuildContext context) {
    DsScreenAdapter.init(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(
          MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: widget.appBar != null
              ? DsAppBar.build(data: widget.appBar!)
              : null,
          floatingActionButton: widget.fabData != null
              ? DsFab(data: widget.fabData!)
              : null,
          bottomNavigationBar: widget.bottomNavData != null
              ? DsBottomNav(data: widget.bottomNavData!)
              : null,
          body: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: Padding(
              padding: EdgeInsetsGeometry.all(DsSpacing.md),
              child: widget.bottomNavData != null
                  ? IndexedStack(
                      index: widget.bottomNavData!.bottomNavbarActiveIndex,
                      children: widget.children,
                    )
                  : Column(children: widget.children),
            ),
          ),
        ),
      ),
    );
  }
}
