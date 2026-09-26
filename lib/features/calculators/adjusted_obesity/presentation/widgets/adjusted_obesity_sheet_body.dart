import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adjusted/calculate_adjusted_obesity_weight.usecase.dart';

/// `currentWeight`/`idealWeight` are both derived (read-only, resolved by
/// the tab before opening this sheet) - there is nothing manual to fill
/// besides the "considerar para cálculos" checkbox. The gathered value is
/// popped whole via `AppRouter.pop` on "Confirmar", so the tab can read it
/// back directly.
typedef GatheredAdjustedObesityInputs = ({bool considerForCalculations});

class AdjustedObesitySheetBody extends StatefulWidget {
  const AdjustedObesitySheetBody({
    required this.currentWeight,
    required this.idealWeight,
    super.key,
  });

  final double currentWeight;
  final double idealWeight;

  @override
  State<AdjustedObesitySheetBody> createState() =>
      _AdjustedObesitySheetBodyState();
}

class _AdjustedObesitySheetBodyState extends State<AdjustedObesitySheetBody> {
  // Default checked - see Ideal Weight's rationale (a dietitian reaching for
  // this calculator is usually already doing so because they want a better
  // weight reference than the scale weight).
  bool _considerForCalculations = true;

  String? _calcErrorMessage;
  double? _resultValue;

  void _calculate() {
    final res = CalculateAdjustedObesityWeight().call(
      idealWeight: widget.idealWeight,
      currentWeight: widget.currentWeight,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o Peso Ajustado.";
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _resultValue = (res as Ok<double, String>).value;
    });
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: DsSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: DsSpacing.sm,
          children: [
            Text(
              "Peso Ajustado - Obesidade",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text("Peso Atual: ${widget.currentWeight} kg"),
            Text("Peso Ideal: ${widget.idealWeight} kg"),
            if (_calcErrorMessage != null)
              Text(_calcErrorMessage!, style: TextStyle(color: DsColors.error)),
            if (_resultValue != null) ...[
              Text(
                "Peso Ajustado: ${_resultValue!.toStringAsFixed(1)} kg",
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
                      .pop<GatheredAdjustedObesityInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredAdjustedObesityInputs?>((
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
