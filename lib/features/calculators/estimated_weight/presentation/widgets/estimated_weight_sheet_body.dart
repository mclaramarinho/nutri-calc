import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/estimated/calculate_estimated_weight.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/ethnicity.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// `kneeHeight`/`armCircumference` are fully manual (no existing Body
/// Measurements type backs these); `gender`/`ethnicity` are fully manual, no
/// default; `age` is derived (read-only, from the patient - the tab
/// pre-gates before opening this sheet if `age` is null). The gathered
/// value is popped whole via `AppRouter.pop` on "Confirmar", so the tab can
/// read it back directly.
typedef GatheredEstimatedWeightInputs = ({
  double kneeHeight,
  double armCircumference,
  Gender gender,
  Ethnicity ethnicity,
  bool considerForCalculations,
});

String _ethnicityLabel(Ethnicity ethnicity) {
  switch (ethnicity) {
    case .white:
      return "Branca";
    case .black:
      return "Negra";
  }
}

class EstimatedWeightSheetBody extends StatefulWidget {
  const EstimatedWeightSheetBody({required this.age, super.key});

  final int age;

  @override
  State<EstimatedWeightSheetBody> createState() =>
      _EstimatedWeightSheetBodyState();
}

class _EstimatedWeightSheetBodyState extends State<EstimatedWeightSheetBody> {
  double? _kneeHeight;
  double? _armCircumference;
  Gender? _gender;
  Ethnicity? _ethnicity;
  // Default checked - see Ideal Weight's rationale (a dietitian reaching for
  // this calculator is usually already doing so because they want a better
  // weight reference than the scale weight).
  bool _considerForCalculations = true;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (widget.age > 80) {
      return "Peso Estimado é válido apenas para pacientes de até 80 anos.";
    }
    if (_kneeHeight == null || _armCircumference == null) {
      return "Preencha os dois campos.";
    }
    if (_kneeHeight! < 0 || _armCircumference! < 0) {
      return "Os valores precisam ser maiores ou iguais a zero.";
    }
    if (_gender == null || _ethnicity == null) {
      return "Selecione o sexo e a etnia.";
    }
    return null;
  }

  String _friendlyCalcError(String error) {
    switch (error) {
      case "INVALID_AGE":
        return "Peso Estimado é válido apenas para pacientes de até 80 anos.";
      case "INVALID_PARAMS":
        return "Parâmetros inválidos.";
      default:
        return "Não foi possível calcular o Peso Estimado.";
    }
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateEstimatedWeight().call(
      kneeHeight: _kneeHeight!,
      armCircumference: _armCircumference!,
      gender: _gender!,
      age: widget.age,
      ethnicity: _ethnicity!,
      amputation: null,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = _friendlyCalcError(
          (res as Error<double, String>).error,
        );
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _resultValue = (res as Ok<double, String>).value;
    });
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
              "Peso Estimado",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text("Idade: ${widget.age}"),
            DsTextfield(
              label: "Altura do Joelho (cm)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _kneeHeight = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            DsTextfield(
              label: "Circunferência do Braço (cm)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _armCircumference = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            DsSelect<Gender>(
              label: "Sexo",
              dropdownOptions: [
                DropdownMenuEntry(value: Gender.male, label: "Masculino"),
                DropdownMenuEntry(value: Gender.female, label: "Feminino"),
              ],
              onDropdownSelect: (value) => setState(() {
                _gender = value;
                _resultValue = null;
              }),
            ),
            DsSelect<Ethnicity>(
              label: "Etnia",
              dropdownOptions: Ethnicity.values
                  .map(
                    (e) =>
                        DropdownMenuEntry(value: e, label: _ethnicityLabel(e)),
                  )
                  .toList(),
              onDropdownSelect: (value) => setState(() {
                _ethnicity = value;
                _resultValue = null;
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
            if (_resultValue != null) ...[
              Text(
                "Peso Estimado: ${_resultValue!.toStringAsFixed(1)} kg",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              DsCheckbox(
                label: "Considerar este peso para cálculos futuros",
                helperText:
                    "Substitui o peso atual como referência até que um novo peso seja marcado dessa forma.",
                value: _considerForCalculations,
                onChanged: (value) =>
                    setState(() => _considerForCalculations = value),
              ),
            ],
          ],
        ),
        if (_resultValue != null) ...[
          const Divider(),
          Row(
            spacing: DsSpacing.sm,
            children: [
              Expanded(
                child: DsButton(
                  label: "Cancelar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEstimatedWeightInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEstimatedWeightInputs?>((
                        kneeHeight: _kneeHeight!,
                        armCircumference: _armCircumference!,
                        gender: _gender!,
                        ethnicity: _ethnicity!,
                        considerForCalculations: _considerForCalculations,
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
