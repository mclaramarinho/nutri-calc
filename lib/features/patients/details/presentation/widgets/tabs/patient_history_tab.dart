import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/core/utils/extensions/ext_datetime.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/domain/entities/history_entry_entity.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/no_data_found_for_patient.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_dismissible_tile/ds_dismissible_tile.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';

/// Slice 11 (roadmap 2.1.4, History): shows every persisted calculator
/// result across all 18 shipped calculator types, grouped by the existing
/// `CalculatorType` enum (reused, not a new taxonomy - ADR 0009), latest
/// first within each group, empty groups suppressed. Tap opens a read-only
/// bottom sheet with `inputParams` + result; swipe deletes via the same
/// `PatientDetailsCubit` delete paths `MeasurementsList` uses.
class PatientHistoryTab extends StatelessWidget {
  const PatientHistoryTab({super.key});

  Map<CalculatorType, List<HistoryEntryEntity>> _groupByType(
    List<HistoryEntryEntity> entries,
  ) {
    final grouped = <CalculatorType, List<HistoryEntryEntity>>{};
    for (final entry in entries) {
      (grouped[entry.type] ??= []).add(entry);
    }
    return grouped;
  }

  Future<void> _openDetailsBottomSheet(
    BuildContext context,
    HistoryEntryEntity entry,
  ) async {
    final l10n = AppLocalizations.of(context);
    await DsBottomSheet.show<void>(
      context,
      title: entry.label,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.sm,
        children: [
          for (final param in entry.inputParams)
            Text("${param.label}: ${param.value}"),
          SizedBox(height: DsSpacing.sm),
          Text(
            entry.resultSummary,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        Expanded(
          child: DsButton(
            label: l10n.patientHistoryCloseButton,
            isLoading: false,
            onTap: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildGroups(
    BuildContext context,
    PatientDetailsCubit cubit,
    List<HistoryEntryEntity> entries,
  ) {
    final l10n = AppLocalizations.of(context);
    final grouped = _groupByType(entries);
    final widgets = <Widget>[];

    for (final type in CalculatorType.values) {
      final entriesForType = grouped[type];
      if (entriesForType == null || entriesForType.isEmpty) continue;

      widgets.add(
        Text(type.label, style: TextStyle(fontWeight: FontWeight.bold)),
      );
      widgets.add(SizedBox(height: DsSpacing.sm));

      for (final entry in entriesForType) {
        widgets.add(
          DsDismissibleTile(
            itemKey: Key(entry.id),
            confirmTitle: l10n.patientHistoryDeleteConfirmTitle,
            confirmMessage: l10n.patientHistoryDeleteConfirmMessage,
            onDelete: () => cubit.deleteHistoryEntry(entry),
            child: DsListTile(
              title: entry.label,
              subtitle:
                  "${entry.resultSummary} · ${entry.createdAt.formattedDateTime()}",
              onTap: () => _openDetailsBottomSheet(context, entry),
            ),
          ),
        );
      }

      widgets.add(SizedBox(height: DsSpacing.vLg));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        if (state.historyEntries.isEmpty) {
          return Column(
            children: [
              NoDataFoundForPatient(
                message: AppLocalizations.of(context).patientHistoryEmptyState,
              ),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildGroups(context, cubit, state.historyEntries),
          ),
        );
      },
    );
  }
}
