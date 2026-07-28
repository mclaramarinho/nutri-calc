import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_app_bar/ds_app_bar_data.type.dart';
import 'package:nutri_calc/shared/utils/extensions/widget.ext.dart';

class DsAppBar {
  static AppBar build({required AppBarData data}) {
    return AppBar(
      title: data.title != null ? Text(data.title!) : null,
      leading: Icon(Icons.chevron_left, size: 30,).touchEvents(onTap: data.onBack?.call),
      actions: [
        Icon(Icons.close).touchEvents(onTap: () => data.onClose?.call()),
      ],
      actionsPadding: EdgeInsets.all(16),
    );
  }
}
