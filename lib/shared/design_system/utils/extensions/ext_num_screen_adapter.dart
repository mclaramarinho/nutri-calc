import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';

extension ExtNumScreenAdapter on num {
  /// Width scaling
  double get w => this * DsScreenAdapter.scaleWidth;

  /// Height scaling (for vertical spacing)
  double get h => this * DsScreenAdapter.scaleHeight;

  /// Radius scaling (typically tied to width to maintain circular/proportional shapes)
  double get r => this * DsScreenAdapter.scaleWidth;
}
