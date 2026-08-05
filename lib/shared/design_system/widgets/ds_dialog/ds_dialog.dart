import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_radius.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/utils/extensions/ext_num_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';

class DsDialog {
  static Future<void> show(
    BuildContext context, {
    bool? showCloseButton,
    String? title,
    String? message,
    String? closeButtonText,
    VoidCallback? onClose,
    List<Widget>? actions,
    bool? isDismissible,
    Duration? duration,
  }) async {
    showAdaptiveDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: isDismissible ?? true,

      builder: (context) {
        return _DsDialogWidget(
          showCloseButton: showCloseButton ?? false,
          title: title,
          message: message,
          actions: actions,
          onClose: onClose,
          closeButtonText: closeButtonText,
          duration: duration,
        );
      },
    ).then((_) => onClose?.call());
  }
}

class _DsDialogWidget extends StatefulWidget {
  final String? title;
  final String? message;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final String? closeButtonText;
  final bool showCloseButton;
  final Duration? duration;

  const _DsDialogWidget({
    this.showCloseButton = true,
    this.title,
    this.message,
    this.actions,
    this.onClose,
    this.closeButtonText,
    this.duration,
  });

  @override
  State<StatefulWidget> createState() => _DsDialogWidgetState();
}

class _DsDialogWidgetState extends State<_DsDialogWidget> {
  @override
  void initState() {
    if (widget.duration != null) {
      Future.delayed(widget.duration!).then((_) {
        getIt.get<AppRouter>().pop();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(DsSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(DsSpacing.md),
              decoration: BoxDecoration(
                color: DsColors.white,
                borderRadius: BorderRadius.all(DsRadius.small),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      spacing: 16,
                      children: [
                        // title
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: DsColors.black,
                              decoration: .none,
                              fontSize: 22.sp,
                            ),
                          ),
                        ],
                        // message
                        if (widget.message != null) ...[
                          Text(
                            widget.message!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: DsColors.black,
                              decoration: .none,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],

                        if (widget.actions != null) ...[
                          Row(children: widget.actions!),
                        ],

                        // close
                        if (widget.actions == null &&
                            widget.showCloseButton &&
                            widget.duration == null) ...[
                          DsButton(
                            label: widget.closeButtonText ?? "Fechar",
                            isLoading: false,
                            onTap: () {
                              getIt.get<AppRouter>().pop();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
