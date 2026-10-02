import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';

class DsButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool disabled;
  final VoidCallback onTap;

  const DsButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
    this.disabled = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = !isLoading && !disabled;

    return ElevatedButton(
      onPressed: isInteractive ? onTap : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: DsColors.gray,
        disabledForegroundColor: DsColors.textDisabled,
      ),
      child: isLoading ? CircularProgressIndicator() : Text(label),
    );
  }
}
