import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/ascitis_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/dry_weight.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/weight/oedema_level.enum.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/weight/adjusted/calculate_dry_weight.usecase.dart';

/// `currentWeight`/`imc` are both derived (read-only, resolved by the tab
/// before opening this sheet); `ascitis`/`oedema` are optional manual
/// selects. The gathered value is popped whole via `AppRouter.pop` on
/// "Confirmar", so the tab can read it back directly.
typedef GatheredAdjustedDryWeightInputs = ({
  AscitisLevel? ascitis,
  OedemaLevel? oedema,
  bool considerForCalculations,
});

// Only `OedemaLevel`'s 4 non-ascites cases are exposed here - the
// `ascitisLow/Moderate/Severe` cases duplicate the separate `ascitis`
// field's concern (Slice 10 po decision, 2026-09-26).
const _oedemaOptions = [OedemaLevel.low, OedemaLevel.moderate, OedemaLevel.severe, OedemaLevel.generalized];

String _ascitisLabel(AscitisLevel level) {
  switch (level) {
    case .low:
      return "Ascite leve";
    case .moderate:
      return "Ascite moderada";
    case .severe:
      return "Ascite grave";
  }
}

String _oedemaLabel(OedemaLevel level) {
  switch (level) {
    case .low:
      return "Edema leve";
    case .moderate:
      return "Edema moderado";
    case .severe:
      return "Edema grave";
    case .generalized:
      return "Edema generalizado";
    case .ascitisLow:
    case .ascitisModerate:
    case .ascitisSevere:
      throw UnsupportedError("Not exposed in this dropdown");
  }
}

String _rangeLabel(double min, double max) {
  if (min == max) return "${min.toStringAsFixed(1)} kg";
  return "${min.toStringAsFixed(1)} – ${max.toStringAsFixed(1)} kg";
}

class AdjustedDryWeightSheetBody extends StatefulWidget {
  const AdjustedDryWeightSheetBody({
    required this.currentWeight,
    required this.imc,
    super.key,
  });

  final double currentWeight;
  final Bmi imc;

  @override
  State<AdjustedDryWeightSheetBody> createState() =>
      _AdjustedDryWeightSheetBodyState();
}

class _AdjustedDryWeightSheetBodyState
    extends State<AdjustedDryWeightSheetBody> {
  AscitisLevel? _ascitis;
  OedemaLevel? _oedema;
  // Default checked - see Ideal Weight's rationale (a dietitian reaching for
  // this calculator is usually already doing so because they want a better
  // weight reference than the scale weight).
  bool _considerForCalculations = true;

  String? _calcErrorMessage;
  DryWeight? _result;

  void _calculate() {
    final res = CalculateDryWeight().call(
      currentWeight: widget.currentWeight,
      imc: widget.imc,
      ascitis: _ascitis,
      oedema: _oedema,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o Peso Seco Ajustado.";
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _result = (res as Ok<DryWeight, String>).value;
    });
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
              "Peso Seco Ajustado",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text("Peso Atual: ${widget.currentWeight} kg"),
            Text("IMC: ${widget.imc.value.toStringAsFixed(2)}"),
            DsSelect<AscitisLevel?>(
              label: "Ascite",
              dropdownOptions: [
                DropdownMenuEntry(value: null, label: "Nenhuma"),
                ...AscitisLevel.values.map(
                  (a) => DropdownMenuEntry(value: a, label: _ascitisLabel(a)),
                ),
              ],
              onDropdownSelect: (value) => setState(() {
                _ascitis = value;
                _result = null;
              }),
            ),
            DsSelect<OedemaLevel?>(
              label: "Edema",
              dropdownOptions: [
                DropdownMenuEntry(value: null, label: "Nenhum"),
                ..._oedemaOptions.map(
                  (o) => DropdownMenuEntry(value: o, label: _oedemaLabel(o)),
                ),
              ],
              onDropdownSelect: (value) => setState(() {
                _oedema = value;
                _result = null;
              }),
            ),
            if (_calcErrorMessage != null)
              Text(_calcErrorMessage!, style: TextStyle(color: DsColors.error)),
            SizedBox(height: DsSpacing.sm),
            DsButton(
              label: "Calcular",
              isLoading: false,
              disabled: false,
              onTap: _calculate,
            ),
            if (_result != null) ...[
              Text(
                "Peso Seco Ajustado: ${_rangeLabel(_result!.min, _result!.max)}",
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
                      .pop<GatheredAdjustedDryWeightInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredAdjustedDryWeightInputs?>((
                        ascitis: _ascitis,
                        oedema: _oedema,
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
