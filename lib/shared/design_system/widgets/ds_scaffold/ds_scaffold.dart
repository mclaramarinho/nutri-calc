import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_fab/ds_fab_data.dart';

class DsScaffold extends StatelessWidget {
  final Widget child;
  final DsAppBarData? appBar;
  final DsFabData? fabData;

  const DsScaffold({required this.child, this.appBar, this.fabData, super.key});

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
          appBar: appBar != null ? DsAppBar.build(data: appBar!) : null,
          floatingActionButton: fabData != null ? DsFab(data: fabData!) : null,
          body: SizedBox(
            width: MediaQuery.sizeOf(context).width,
            height: MediaQuery.sizeOf(context).height,
            child: Padding(padding: EdgeInsetsGeometry.all(DsSpacing.md), child: child),
          ),
        ),
      ),
    );
  }
}
