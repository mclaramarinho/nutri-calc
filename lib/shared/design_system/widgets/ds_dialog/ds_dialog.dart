import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/app_router.service.dart';

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
        return DsDialogWidget(
          showCloseButton: showCloseButton ?? false,
          title: title,
          message: message,
          actions: actions,
          onClose: onClose,
          closeButtonText: closeButtonText,
          duration: duration,
        );
      },
    ).then((_) => duration == null ? onClose?.call() : {});
  }
}

class DsDialogWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final List<Widget>? actions;
  final VoidCallback? onClose;
  final String? closeButtonText;
  final bool showCloseButton;
  final Duration? duration;

  const DsDialogWidget({
    this.showCloseButton = true,
    this.title,
    this.message,
    this.actions,
    this.onClose,
    this.closeButtonText,
    this.duration,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (duration != null) {
      Future.delayed(duration!).then((_) {
        getIt.get<AppRouter>().pop();
        onClose?.call();
      });
    }
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: .center,
                      spacing: 16,
                      children: [
                        // title
                        if (title != null) ...[
                          Text(
                            title!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: Colors.black,
                              decoration: .none,
                              fontSize: 22,
                            ),
                          ),
                        ],
                        // message
                        if (message != null) ...[
                          Text(
                            message!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: Colors.black,
                              decoration: .none,
                              fontSize: 16,
                            ),
                          ),
                        ],

                        if (actions != null) ...[Row(children: actions!)],

                        // close
                        if (actions == null &&
                            showCloseButton &&
                            duration == null) ...[
                          DsButton(
                            label: closeButtonText ?? "Fechar",
                            isLoading: false,
                            onTap: () {
                              onClose?.call();
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
