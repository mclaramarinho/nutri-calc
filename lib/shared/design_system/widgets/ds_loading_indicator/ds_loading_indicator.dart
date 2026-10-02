import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_sizing.dart';

enum DsLoadingIndicatorVariant { page, inline }

class DsLoadingIndicator extends StatelessWidget {
  const DsLoadingIndicator({
    this.variant = DsLoadingIndicatorVariant.page,
    this.color,
    super.key,
  });

  final DsLoadingIndicatorVariant variant;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final size = variant == DsLoadingIndicatorVariant.page
        ? DsSizing.loadingIndicatorPage
        : DsSizing.loadingIndicatorInline;
    final strokeWidth = variant == DsLoadingIndicatorVariant.page ? 4.0 : 2.5;
    final defaultColor = variant == DsLoadingIndicatorVariant.page
        ? DsColors.of(context).blue
        : DsColors.of(context).white;

    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? defaultColor,
      ),
    );

    return variant == DsLoadingIndicatorVariant.page
        ? Center(child: indicator)
        : indicator;
  }
}
