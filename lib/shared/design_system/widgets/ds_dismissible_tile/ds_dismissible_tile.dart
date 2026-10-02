import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dialog/ds_dialog.dart';

/// Shared swipe-to-delete primitive (ADR 0010): wraps a [Dismissible] with
/// the confirm -> delete -> success/error [DsDialog] choreography that used
/// to be a `// TODO - use when delete weight record is available` comment
/// in `MeasurementsList`. Content-agnostic - both `MeasurementsList` and
/// `PatientHistoryTab` wrap their own row [child] in this widget.
///
/// [onDelete] is expected to already trigger any necessary state refresh
/// (e.g. the owning cubit re-fetching its list) before resolving - this
/// widget has no knowledge of cubits/state, only of the dialog choreography.
class DsDismissibleTile extends StatelessWidget {
  const DsDismissibleTile({
    required this.itemKey,
    required this.child,
    required this.confirmTitle,
    required this.confirmMessage,
    required this.onDelete,
    this.successMessage = "Excluído com sucesso.",
    this.errorMessage = "Não foi possível excluir. Tente novamente.",
    super.key,
  });

  final Key itemKey;
  final Widget child;
  final String confirmTitle;
  final String confirmMessage;
  final Future<Result<void, String>> Function() onDelete;
  final String successMessage;
  final String errorMessage;

  Future<bool?> _showConfirmDialog(BuildContext context) {
    return DsDialog.show<bool>(
      context,
      title: confirmTitle,
      message: confirmMessage,
      actions: [
        Expanded(
          child: DsButton(
            label: "Cancelar",
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(false),
          ),
        ),
        Expanded(
          child: DsButton(
            label: "Excluir",
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(true),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _showConfirmDialog(context);
        if (confirmed != true) return false;

        final res = await onDelete();

        if (!context.mounted) return res.isOk;

        if (res.isError) {
          await DsDialog.show(
            context,
            title: "Erro",
            message: errorMessage,
            showCloseButton: true,
          );
          return false;
        }

        await DsDialog.show(
          context,
          title: "Sucesso",
          message: successMessage,
          showCloseButton: false,
          isDismissible: false,
          duration: const Duration(seconds: 2),
        );
        return true;
      },
      background: Container(
        color: DsColors.of(context).error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: DsSpacing.lg),
        child: Icon(Icons.delete, color: DsColors.of(context).white),
      ),
      child: child,
    );
  }
}
