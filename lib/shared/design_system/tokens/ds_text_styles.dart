import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';

class DsTextStyles {
  static TextStyle sectionHeader(BuildContext context) =>
      TextStyle(fontWeight: FontWeight.w700, color: DsColors.of(context).black);
  static TextStyle resultBold(BuildContext context) =>
      TextStyle(fontWeight: FontWeight.w700, color: DsColors.of(context).black);
}
