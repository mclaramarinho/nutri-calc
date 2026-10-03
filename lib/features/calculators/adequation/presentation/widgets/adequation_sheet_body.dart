import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/weight_adequation_classification.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adequation/calculate_weight_adequation.usecase.dart';

/// `currentWeight`/`idealWeight` are both derived (read-only, resolved by
/// the tab before opening this sheet) - there is nothing manual to fill
/// besides the "considerar para cálculos" checkbox. The gathered value is
/// popped whole via `AppRouter.pop` on "Confirmar", so the tab can read it
/// back directly.
typedef GatheredAdequationInputs = ({bool considerForCalculations});

String _classificationLabel(WeightAdequationClassification classification) {
  switch (classification) {
    case .severeMalnutrition:
      return "Desnutrição grave";
    case .moderateMalnutrition:
      return "Desnutrição moderada";
    case .mildMalnutrition:
      return "Desnutrição leve";
    case .eutrophy:
      return "Eutrofia";
    case .overweight:
      return "Sobrepeso";
    case .obesity:
      return "Obesidade";
  }
}

class AdequationSheetBody extends StatefulWidget {
  const AdequationSheetBody({
    required this.currentWeight,
    required this.idealWeight,
    super.key,
  });

  final double currentWeight;
  final double idealWeight;

  @override
  State<AdequationSheetBody> createState() => _AdequationSheetBodyState();
}

class _AdequationSheetBodyState extends State<AdequationSheetBody> {
  // Default checked - see Ideal Weight's rationale (a dietitian reaching for
  // this calculator is usually already doing so because they want a better
  // weight reference than the scale weight).
  bool _considerForCalculations = true;

  String? _calcErrorMessage;
  WeightAdequation? _result;

  void _calculate() {
    final res = CalculateWeightAdequation().call(
      currentWeight: widget.currentWeight,
      idealWeight: widget.idealWeight,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular a Adequação de Peso.";
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _result = (res as Ok<WeightAdequation, String>).value;
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
              "Adequação de Peso",
              style: DsTextStyles.sectionHeader(context),
            ),
            Text("Peso Atual: ${widget.currentWeight} kg"),
            Text("Peso Ideal: ${widget.idealWeight} kg"),
            if (_calcErrorMessage != null)
              Text(
                _calcErrorMessage!,
                style: TextStyle(color: DsColors.of(context).error),
              ),
            if (_result != null) ...[
              Text(
                "Adequação de Peso: ${_result!.value.toStringAsFixed(2)}% "
                "(${_classificationLabel(_result!.classification)})",
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
        if (_result != null) ...[
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
                      .pop<GatheredAdequationInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredAdequationInputs?>((
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
