import 'package:flutter/material.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/di/di.dart';
import 'package:nutri_calc/shared/services/router/navigation_service.dart';

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
        getIt.get<NavigationService>().pop();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                        if (widget.title != null) ...[
                          Text(
                            widget.title!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: Colors.black,
                              decoration: .none,
                              fontSize: 22,
                            ),
                          ),
                        ],
                        // message
                        if (widget.message != null) ...[
                          Text(
                            widget.message!,
                            style: TextStyle(
                              fontWeight: .w700,
                              color: Colors.black,
                              decoration: .none,
                              fontSize: 16,
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
                              getIt.get<NavigationService>().pop();
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
