import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.dart';
import 'package:nutri_calc/core/utils/extensions/ext_widget.dart';

class DsAppBar {
  static AppBar build({required DsAppBarData data}) {
    return AppBar(
      title: data.title != null ? Text(data.title!) : null,
      leading: Icon(
        Icons.chevron_left,
        size: DsSizing.iconAppBar,
      ).touchEvents(onTap: data.onBack?.call),
      actions: [
        Icon(Icons.close).touchEvents(onTap: () => data.onClose?.call()),
      ],
      actionsPadding: EdgeInsets.all(DsSpacing.md),
    );
  }
}
