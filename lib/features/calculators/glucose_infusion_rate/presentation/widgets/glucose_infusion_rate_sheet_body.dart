import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/parenteral_nutrition/calculate_glucose_infusion_rate.usecase.dart';

/// `weightKg` is derived (read-only, from the patient's latest weight);
/// `totalGlucose` is fully manual, with zero allowed (matches the pure-math
/// use case's own `>= 0` guard). The gathered value, popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read it back directly.
typedef GatheredGlucoseInfusionRateInputs = ({double totalGlucose});

class GlucoseInfusionRateSheetBody extends StatefulWidget {
  const GlucoseInfusionRateSheetBody({required this.weightKg, super.key});

  final double weightKg;

  @override
  State<GlucoseInfusionRateSheetBody> createState() =>
      _GlucoseInfusionRateSheetBodyState();
}

class _GlucoseInfusionRateSheetBodyState
    extends State<GlucoseInfusionRateSheetBody> {
  double? _totalGlucose;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_totalGlucose == null) {
      return "Preencha o campo.";
    }
    if (_totalGlucose! < 0) {
      return "O valor precisa ser maior ou igual a zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateGlucoseInfusionRate().call(
      totalGlucose: _totalGlucose!,
      weight: widget.weightKg,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular a TIG.";
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
            Text("TIG", style: TextStyle(fontWeight: FontWeight.w700)),
            Text("Peso: ${widget.weightKg} kg"),
            DsTextfield(
              label: "Glicose Total (g)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _totalGlucose = double.tryParse(value);
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
                "Taxa de Infusão de Glicose (TIG): ${_resultValue!.toStringAsFixed(2)} mg/kg/min",
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
                      .pop<GatheredGlucoseInfusionRateInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredGlucoseInfusionRateInputs?>((
                        totalGlucose: _totalGlucose!,
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
