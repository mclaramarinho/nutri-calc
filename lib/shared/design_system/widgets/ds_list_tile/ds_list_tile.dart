import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';

class DsListTile extends StatelessWidget {
  const DsListTile({
    required this.title,
    this.overline,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  final String? overline;
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: DsSpacing.md,
        vertical: DsSpacing.sm,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, SizedBox(width: DsSpacing.sm)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (overline != null) ...[
                  Text(
                    overline!,
                    style: TextStyle(
                      fontSize: DsTypography.xxs,
                      color: DsColors.textMuted,
                    ),
                  ),
                  SizedBox(height: DsSpacing.xxs),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: DsTypography.small,
                    fontWeight: FontWeight.w600,
                    color: DsColors.black,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: DsSpacing.xxs),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: DsTypography.xxs,
                      color: DsColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[SizedBox(width: DsSpacing.sm), trailing!],
        ],
      ),
    );

    return onTap == null ? content : InkWell(onTap: onTap, child: content);
  }
}
