import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/must/must_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/must/calculate_must_score.usecase.dart';

/// All fields are manual/editable (the BMI field is only prefilled from the
/// patient's current BMI, when available, for convenience) - the gathered
/// values, popped whole via `AppRouter.pop` on "Confirmar", so the tab can
/// read them back directly. Mirrors `GatheredNitrogenBalanceInputs`.
typedef GatheredMustInputs = ({
  double bmi,
  double avgWeightLossIn3To6Months,
  bool severeIllnessPresent,
  bool reducedFoodIntakeForMoreThan5Days,
  bool willReduceFoodIntakeForMoreThan5Days,
});

class MustSheetBody extends StatefulWidget {
  const MustSheetBody({this.currentBmi, super.key});

  final double? currentBmi;

  @override
  State<MustSheetBody> createState() => _MustSheetBodyState();
}

class _MustSheetBodyState extends State<MustSheetBody> {
  double? _bmi;
  double? _weightLossPercentage;
  bool _severeIllnessPresent = false;
  bool _reducedFoodIntake = false;
  bool _willReduceFoodIntake = false;

  String? _calcErrorMessage;
  MustResult? _result;

  @override
  void initState() {
    super.initState();
    _bmi = widget.currentBmi;
  }

  String? get _validationMessage {
    if (_bmi == null || _weightLossPercentage == null) {
      return "Preencha o IMC e o percentual de perda de peso.";
    }
    if (_bmi! <= 0 || _weightLossPercentage! < 0) {
      return "Os valores precisam ser maiores que zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    // The use case's dead `required` positional param is intentionally left
    // unpassed — see `CalculateMustScore.call()`'s own file.
    final res = CalculateMustScore().call(
      bmi: _bmi!,
      avgWeightLossIn3To6Months: _weightLossPercentage!,
      severeIllnessPresent: _severeIllnessPresent,
      reducedFoodIntakeForMoreThan5Days: _reducedFoodIntake,
      willReduceFoodIntakeForMoreThan5Days: _willReduceFoodIntake,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o MUST.";
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _result = (res as Ok<MustResult, String>).value;
    });
  }

  String _classificationLabel(MustResult result) {
    switch (result.classification) {
      case .lowRisk:
        return "Baixo risco";
      case .mediumRisk:
        return "Risco médio";
      case .highRisk:
        return "Alto risco";
    }
  }

  @override
  Widget build(BuildContext context) {
    final validation = _validationMessage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DsSpacing.sm,
          children: [
            Text(
              "MUST — Triagem de Risco Nutricional",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            DsTextfield(
              label: "IMC",
              type: TextInputType.number,
              initialValue: widget.currentBmi?.toString(),
              onChange: (value) => setState(() {
                _bmi = double.tryParse(value);
                _result = null;
              }),
            ),
            DsTextfield(
              label: "Perda de Peso (3-6 meses) (%)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _weightLossPercentage = double.tryParse(value);
                _result = null;
              }),
            ),
            DsCheckbox(
              label: "Paciente apresenta doença grave?",
              value: _severeIllnessPresent,
              onChanged: (value) => setState(() {
                _severeIllnessPresent = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: "Ingestão alimentar reduzida por mais de 5 dias?",
              value: _reducedFoodIntake,
              onChanged: (value) => setState(() {
                _reducedFoodIntake = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: "Irá reduzir ingestão alimentar por mais de 5 dias?",
              value: _willReduceFoodIntake,
              onChanged: (value) => setState(() {
                _willReduceFoodIntake = value;
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
              label: "Calcular",
              isLoading: false,
              disabled: validation != null,
              onTap: _calculate,
            ),
            if (_result != null)
              Text(
                "MUST: ${_result!.score} (${_classificationLabel(_result!)})",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
          ],
        ),
        if (_result != null) ...[
          const Divider(),
          Row(
            spacing: DsSpacing.sm,
            children: [
              Expanded(
                child: DsButton(
                  label: "Cancelar",
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredMustInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt.get<AppRouter>().pop<GatheredMustInputs?>((
                    bmi: _bmi!,
                    avgWeightLossIn3To6Months: _weightLossPercentage!,
                    severeIllnessPresent: _severeIllnessPresent,
                    reducedFoodIntakeForMoreThan5Days: _reducedFoodIntake,
                    willReduceFoodIntakeForMoreThan5Days: _willReduceFoodIntake,
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
