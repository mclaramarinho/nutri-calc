import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_questionnaire_response.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_score_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/nrs_2002/nrs_2002_step_2_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/nrs_2002/calculate_nrs_2002_score.usecase.dart';

/// The age comes from the patient's registered data (nullable — see
/// `widget.age`), mirroring `EnergyExpenditureSheetBody`'s pattern: the
/// widget takes it as a nullable `int?` param and the save call site reads
/// it back from cubit state directly rather than duplicating it into the
/// gathered typedef below.
typedef GatheredNrs2002Inputs = ({
  bool isSeverelyIll,
  bool weightLossLast3Months,
  bool reducedFoodIntakeLastWeek,
  bool lowBmi,
  Nrs2002Step2Classification nutritionalStatusClassification,
  Nrs2002Step2Classification illnessSeverityClassification,
});

class Nrs2002SheetBody extends StatefulWidget {
  const Nrs2002SheetBody({required this.age, super.key});

  final int? age;

  @override
  State<Nrs2002SheetBody> createState() => _Nrs2002SheetBodyState();
}

class _Nrs2002SheetBodyState extends State<Nrs2002SheetBody> {
  bool _isSeverelyIll = false;
  bool _weightLossLast3Months = false;
  bool _reducedFoodIntakeLastWeek = false;
  bool _lowBmi = false;
  Nrs2002Step2Classification? _nutritionalStatusClassification;
  Nrs2002Step2Classification? _illnessSeverityClassification;

  String? _calcErrorMessage;
  Nrs2002ScoreResult? _result;

  String? get _validationMessage {
    final l10n = AppLocalizations.of(context);
    if (widget.age == null) {
      return l10n.nrs2002RegisterAgeMessage;
    }
    if (_nutritionalStatusClassification == null ||
        _illnessSeverityClassification == null) {
      return l10n.nrs2002SelectClassificationsMessage;
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateNrs2002Score().call(
      Nrs2002QuestionnaireResponse(
        age: widget.age!,
        isSeverelyIll: _isSeverelyIll,
        weightLossLast3Months: _weightLossLast3Months,
        reducedFoodIntakeLastWeek: _reducedFoodIntakeLastWeek,
        lowBmi: _lowBmi,
        nutritionalStatusClassification: _nutritionalStatusClassification!,
        illnessSeverityClassification: _illnessSeverityClassification!,
      ),
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = AppLocalizations.of(context).nrs2002CalcErrorMessage;
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _result = (res as Ok<Nrs2002ScoreResult, String>).value;
    });
  }

  List<DropdownMenuEntry<Nrs2002Step2Classification>>
  get _classificationOptions {
    final l10n = AppLocalizations.of(context);
    return [
      DropdownMenuEntry(value: .absent, label: l10n.nrs2002ClassificationAbsent),
      DropdownMenuEntry(value: .low, label: l10n.nrs2002ClassificationLow),
      DropdownMenuEntry(value: .mild, label: l10n.nrs2002ClassificationMild),
      DropdownMenuEntry(
        value: .severe,
        label: l10n.nrs2002ClassificationSevere,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final validation = _validationMessage;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DsSpacing.sm,
          children: [
            Text(
              l10n.nrs2002Title,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            if (widget.age != null)
              Text(l10n.nrs2002AgeLabel("${widget.age}"))
            else
              Text(
                l10n.nrs2002RegisterAgeMessage,
                style: TextStyle(color: DsColors.of(context).error),
              ),
            DsCheckbox(
              label: l10n.nrs2002SeverelyIllQuestion,
              value: _isSeverelyIll,
              onChanged: (value) => setState(() {
                _isSeverelyIll = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: l10n.nrs2002WeightLossQuestion,
              value: _weightLossLast3Months,
              onChanged: (value) => setState(() {
                _weightLossLast3Months = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: l10n.nrs2002ReducedIntakeQuestion,
              value: _reducedFoodIntakeLastWeek,
              onChanged: (value) => setState(() {
                _reducedFoodIntakeLastWeek = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: l10n.nrs2002LowBmiQuestion,
              value: _lowBmi,
              onChanged: (value) => setState(() {
                _lowBmi = value;
                _result = null;
              }),
            ),
            DsSelect<Nrs2002Step2Classification>(
              label: l10n.nrs2002NutritionalStatusLabel,
              dropdownOptions: _classificationOptions,
              onDropdownSelect: (value) => setState(() {
                _nutritionalStatusClassification = value;
                _result = null;
              }),
            ),
            DsSelect<Nrs2002Step2Classification>(
              label: l10n.nrs2002IllnessSeverityLabel,
              dropdownOptions: _classificationOptions,
              onDropdownSelect: (value) => setState(() {
                _illnessSeverityClassification = value;
                _result = null;
              }),
            ),
            if (_calcErrorMessage != null)
              Text(
                _calcErrorMessage!,
                style: TextStyle(color: DsColors.of(context).error),
              ),
            if (validation != null)
              Text(
                validation,
                style: TextStyle(color: DsColors.of(context).error),
              ),
            SizedBox(height: DsSpacing.sm),
            DsButton(
              label: l10n.nrs2002CalculateButton,
              isLoading: false,
              disabled: validation != null,
              onTap: _calculate,
            ),
            if (_result != null) ...[
              Text(
                l10n.nrs2002ScoreResultLabel(_result!.score),
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              if (_result!.score >= 3)
                Text(
                  l10n.nrs2002RiskIdentifiedMessage,
                  style: TextStyle(color: DsColors.of(context).error),
                ),
            ],
          ],
        ),
        if (_result != null) ...[
          const Divider(),
          Row(
            spacing: DsSpacing.sm,
            children: [
              Expanded(
                child: DsButton(
                  label: l10n.nrs2002CancelButton,
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredNrs2002Inputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: l10n.nrs2002ConfirmButton,
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredNrs2002Inputs?>((
                        isSeverelyIll: _isSeverelyIll,
                        weightLossLast3Months: _weightLossLast3Months,
                        reducedFoodIntakeLastWeek: _reducedFoodIntakeLastWeek,
                        lowBmi: _lowBmi,
                        nutritionalStatusClassification:
                            _nutritionalStatusClassification!,
                        illnessSeverityClassification:
                            _illnessSeverityClassification!,
                      )),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
