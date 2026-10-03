import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/enteral_nutrition/calculate_enteral_nutrition_speed.usecase.dart';

/// The input is fully manual (roadmap 3.1: Enteral Nutrition Speed has no
/// patient-data derivation) - the gathered value, popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read it back directly.
typedef GatheredEnteralNutritionSpeedInputs = ({double totalDailyVolume});

class EnteralNutritionSpeedSheetBody extends StatefulWidget {
  const EnteralNutritionSpeedSheetBody({super.key});

  @override
  State<EnteralNutritionSpeedSheetBody> createState() =>
      _EnteralNutritionSpeedSheetBodyState();
}

class _EnteralNutritionSpeedSheetBodyState
    extends State<EnteralNutritionSpeedSheetBody> {
  double? _totalDailyVolume;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_totalDailyVolume == null) {
      return "Preencha o campo.";
    }
    if (_totalDailyVolume! <= 0) {
      return "O volume diário total precisa ser maior que zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateEnteralNutritionSpeed().call(
      totalDailyVolume: _totalDailyVolume!,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage =
            "Não foi possível calcular a velocidade de infusão.";
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
              "Velocidade de Infusão",
              style: DsTextStyles.sectionHeader(context),
            ),
            DsTextfield(
              label: "Volume Diário Total (mL)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _totalDailyVolume = double.tryParse(value);
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
                "Velocidade de Infusão: ${_resultValue!.toStringAsFixed(1)} mL/h",
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
                      .pop<GatheredEnteralNutritionSpeedInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredEnteralNutritionSpeedInputs?>((
                        totalDailyVolume: _totalDailyVolume!,
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
