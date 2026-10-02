import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';

/// Stateless/controlled checkbox + label row. Value comes from the caller's
/// state (cubit), mirrors `DsButton`'s `disabled` convention (ADR 0003).
class DsCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool value)? onChanged;
  final bool disabled;
  final String? helperText;

  const DsCheckbox({
    required this.label,
    required this.value,
    this.onChanged,
    this.disabled = false,
    this.helperText,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = disabled
        ? DsColors.of(context).textDisabled
        : DsColors.of(context).black;

    return InkWell(
      onTap: disabled || onChanged == null ? null : () => onChanged!(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: disabled ? null : (v) => onChanged?.call(v ?? false),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (disabled) {
                return DsColors.of(context).gray;
              }
              if (states.contains(WidgetState.selected)) {
                return DsColors.of(context).blue;
              }
              return null;
            }),
          ),
          SizedBox(width: DsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: DsTypography.small,
                    color: textColor,
                  ),
                ),
                if (helperText != null)
                  Text(
                    helperText!,
                    style: TextStyle(
                      fontSize: DsTypography.xxs,
                      color: disabled
                          ? DsColors.of(context).textDisabled
                          : DsColors.of(context).textMuted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
