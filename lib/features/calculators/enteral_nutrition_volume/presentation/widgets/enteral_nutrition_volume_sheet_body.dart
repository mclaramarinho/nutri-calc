import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_volume.usecase.dart';

/// Both inputs are fully manual (roadmap 3.1: Enteral Nutrition Volume has
/// no patient-data derivation) - the gathered values, popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read them back directly.
typedef GatheredEnteralNutritionVolumeInputs = ({
  double totalDailyEnergy,
  double caloricDensityOfDiet,
});

class EnteralNutritionVolumeSheetBody extends StatefulWidget {
  const EnteralNutritionVolumeSheetBody({super.key});

  @override
  State<EnteralNutritionVolumeSheetBody> createState() =>
      _EnteralNutritionVolumeSheetBodyState();
}

class _EnteralNutritionVolumeSheetBodyState
    extends State<EnteralNutritionVolumeSheetBody> {
  double? _totalDailyEnergy;
  double? _caloricDensityOfDiet;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_totalDailyEnergy == null || _caloricDensityOfDiet == null) {
      return "Preencha os dois campos.";
    }
    if (_totalDailyEnergy! <= 0) {
      return "A energia diária total precisa ser maior que zero.";
    }
    if (_caloricDensityOfDiet! <= 0) {
      return "A densidade calórica da dieta precisa ser maior que zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateEnteralNutritionVolume().call(
      totalDailyEnergy: _totalDailyEnergy!,
      caloricDensityOfDiet: _caloricDensityOfDiet!,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o volume total.";
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
            Text("Volume Total", style: DsTextStyles.sectionHeader(context)),
            DsTextfield(
              label: "Energia Diária Total (kcal)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _totalDailyEnergy = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            DsTextfield(
              label: "Densidade Calórica da Dieta (kcal/mL)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _caloricDensityOfDiet = double.tryParse(value);
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
            if (_resultValue != null)
              Text(
                "Volume Total: ${_resultValue!.toStringAsFixed(1)} mL/dia",
                style: DsTextStyles.resultBold(context),
              ),
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
                      .pop<GatheredEnteralNutritionVolumeInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEnteralNutritionVolumeInputs?>((
                        totalDailyEnergy: _totalDailyEnergy!,
                        caloricDensityOfDiet: _caloricDensityOfDiet!,
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
