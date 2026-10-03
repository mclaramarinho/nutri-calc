import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/ideal/calculate_ideal_weight.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/gender.dart';

/// `heightCm` is derived (read-only, from the patient's latest height);
/// `gender` is fully manual, no default (`PatientEntity` has no gender
/// field, same precedent as Energy Expenditure). The gathered value is
/// popped whole via `AppRouter.pop` on "Confirmar", so the tab can read it
/// back directly.
typedef GatheredIdealWeightInputs = ({
  Gender gender,
  bool considerForCalculations,
});

class IdealWeightSheetBody extends StatefulWidget {
  const IdealWeightSheetBody({
    required this.heightCm,
    required this.weightKg,
    super.key,
  });

  final double heightCm;

  // Only used to satisfy `CalculateIdealWeight`'s required `weight` param
  // (its `weight < 0` validation guard) so the preview calculation here
  // matches the persisted one exactly - it plays no role in the ideal
  // weight formula itself and is intentionally not shown in the UI, per
  // design's explicit scoping.
  final double weightKg;

  @override
  State<IdealWeightSheetBody> createState() => _IdealWeightSheetBodyState();
}

class _IdealWeightSheetBodyState extends State<IdealWeightSheetBody> {
  Gender? _gender;
  // Default checked - see design-conventions.md's rationale (a dietitian
  // reaching for Ideal Weight is usually already doing so because they want
  // a better weight reference than the scale weight).
  bool _considerForCalculations = true;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_gender == null) return "Selecione o sexo.";
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateIdealWeight().call(
      weight: widget.weightKg,
      height: widget.heightCm / 100, // cm -> m, mirrors BMI's convention
      gender: _gender!,
      amputation: null,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o Peso Ideal.";
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
            Text("Peso Ideal", style: DsTextStyles.sectionHeader(context)),
            Text("Altura: ${widget.heightCm} cm"),
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
                "Peso Ideal: ${_resultValue!.toStringAsFixed(1)} kg",
                style: DsTextStyles.resultBold(context),
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
                      .pop<GatheredIdealWeightInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredIdealWeightInputs?>((
                        gender: _gender!,
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
