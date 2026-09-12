import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_radius.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';

class DsBottomSheet {
  static bool _isOpen = false;

  static void _clearGuard() {
    _isOpen = false;
  }

  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget body,
    List<Widget>? actions,
    bool isDismissible = true,
    bool enableDrag = true,
    double maxHeightFraction = 0.9,
  }) async {
    if (_isOpen) {
      return Future<T?>.value(null);
    }

    _isOpen = true;

    final future = showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: DsColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: DsRadius.small,
          topRight: DsRadius.small,
        ),
      ),
      builder: (context) {
        return _DsBottomSheetWidget(
          title: title,
          body: body,
          actions: actions,
          enableDrag: enableDrag,
          maxHeightFraction: maxHeightFraction,
          onDispose: _clearGuard,
        );
      },
    );

    try {
      return await future;
    } finally {
      _clearGuard();
    }
  }
}

class _DsBottomSheetWidget extends StatefulWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final bool enableDrag;
  final double maxHeightFraction;
  final VoidCallback onDispose;

  const _DsBottomSheetWidget({
    this.title,
    required this.body,
    this.actions,
    required this.enableDrag,
    required this.maxHeightFraction,
    required this.onDispose,
  });

  @override
  State<_DsBottomSheetWidget> createState() => _DsBottomSheetWidgetState();
}

class _DsBottomSheetWidgetState extends State<_DsBottomSheetWidget> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight =
        widget.maxHeightFraction * MediaQuery.of(context).size.height;
    final hasActions = widget.actions != null;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.enableDrag) ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: DsSpacing.sm),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: DsColors.gray,
                      borderRadius: BorderRadius.all(DsRadius.full),
                    ),
                  ),
                ),
              ),
            ],
            if (widget.title != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: DsSpacing.md),
                child: Text(
                  widget.title!,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: DsColors.black,
                    decoration: TextDecoration.none,
                    fontSize: DsTypography.large,
                  ),
                ),
              ),
              SizedBox(height: DsSpacing.vSm),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: DsSpacing.md,
                  right: DsSpacing.md,
                  top: DsSpacing.sm,
                  bottom: hasActions ? 0 : DsSpacing.md,
                ),
                child: widget.body,
              ),
            ),
            if (hasActions) ...[
              const Divider(),
              Padding(
                padding: EdgeInsets.all(DsSpacing.md),
                child: Row(spacing: DsSpacing.sm, children: widget.actions!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
