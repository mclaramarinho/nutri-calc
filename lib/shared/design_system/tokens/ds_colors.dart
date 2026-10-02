import 'package:flutter/material.dart';

class DsColors {
  static Color get white => Colors.white;
  static Color get blue => Colors.blue;
  static Color get black => Colors.black;
  static Color get gray => Colors.grey.shade200;
  static Color get error => Colors.red;
  static Color get textDisabled => DsColors.black.withValues(alpha: 0.38);
  static Color get textMuted => DsColors.black.withValues(alpha: 0.54);
}
