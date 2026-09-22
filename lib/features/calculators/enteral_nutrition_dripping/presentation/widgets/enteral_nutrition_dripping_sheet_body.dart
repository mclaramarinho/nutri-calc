import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_dripping.usecase.dart';

/// Both inputs are fully manual (roadmap 3.1: Enteral Nutrition Dripping has
/// no patient-data derivation) - the gathered values, popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read them back directly.
typedef GatheredEnteralNutritionDrippingInputs = ({
  double totalVolume,
  double totalHoursForVolume,
});

class EnteralNutritionDrippingSheetBody extends StatefulWidget {
  const EnteralNutritionDrippingSheetBody({super.key});

  @override
  State<EnteralNutritionDrippingSheetBody> createState() =>
      _EnteralNutritionDrippingSheetBodyState();
}

class _EnteralNutritionDrippingSheetBodyState
    extends State<EnteralNutritionDrippingSheetBody> {
  double? _totalVolume;
  double? _totalHoursForVolume;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_totalVolume == null || _totalHoursForVolume == null) {
      return "Preencha os dois campos.";
    }
    if (_totalVolume! <= 0) {
      return "O volume total precisa ser maior que zero.";
    }
    if (_totalHoursForVolume! <= 0) {
      return "O tempo total precisa ser maior que zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateEnteralNutritionDripping().call(
      totalVolume: _totalVolume!,
      totalHoursForVolume: _totalHoursForVolume!,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o gotejamento.";
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
              "Gotejamento",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            DsTextfield(
              label: "Volume Total (mL)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _totalVolume = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            DsTextfield(
              label: "Tempo Total (h)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _totalHoursForVolume = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            if (_calcErrorMessage != null)
              Text(_calcErrorMessage!, style: TextStyle(color: DsColors.error)),
            if (validation != null)
              Text(validation, style: TextStyle(color: DsColors.error)),
            SizedBox(height: DsSpacing.sm),
            DsButton(
              label: "Calcular",
              isLoading: false,
              disabled: validation != null,
              onTap: _calculate,
            ),
            if (_resultValue != null)
              Text(
                "Gotejamento: ${_resultValue!.toStringAsFixed(1)} gotas/min",
                style: TextStyle(fontWeight: FontWeight.w700),
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
                      .pop<GatheredEnteralNutritionDrippingInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEnteralNutritionDrippingInputs?>((
                        totalVolume: _totalVolume!,
                        totalHoursForVolume: _totalHoursForVolume!,
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
