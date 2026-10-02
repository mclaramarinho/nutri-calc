import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_select/ds_select.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/protein/protein_needs.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/protein/calculate_protein_needs.usecase.dart';
import 'package:nutri_calc/shared/utils/enums/patient_state.dart';

/// `weight` is derived (read-only, from the patient's latest weight);
/// `patientState` is fully manual, with no default/pre-selection - the
/// dietitian must explicitly choose it. The chosen state is popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read it back directly.
typedef GatheredProteinNeedsInputs = ({PatientState patientState});

class ProteinNeedsSheetBody extends StatefulWidget {
  const ProteinNeedsSheetBody({required this.weightKg, super.key});

  final double weightKg;

  @override
  State<ProteinNeedsSheetBody> createState() => _ProteinNeedsSheetBodyState();
}

class _ProteinNeedsSheetBodyState extends State<ProteinNeedsSheetBody> {
  PatientState? _patientState;

  String? _calcErrorMessage;
  double? _minValue;
  double? _maxValue;

  void _calculate() {
    if (_patientState == null) return;

    final res = CalculateProteinNeeds().call(
      weight: widget.weightKg,
      patientState: _patientState!,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular a necessidade proteica.";
      });
      return;
    }

    final proteinNeeds = (res as Ok<ProteinNeeds, String>).value;

    setState(() {
      _calcErrorMessage = null;
      _minValue = proteinNeeds.min;
      _maxValue = proteinNeeds.max;
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
              "Necessidade Proteica",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text("Peso: ${widget.weightKg} kg"),
            DsSelect<PatientState>(
              label: "Estado do Paciente",
              dropdownOptions: PatientState.values
                  .map((s) => DropdownMenuEntry(value: s, label: s.label))
                  .toList(),
              onDropdownSelect: (value) => setState(() {
                _patientState = value;
                _minValue = null;
                _maxValue = null;
              }),
            ),
            if (_calcErrorMessage != null)
              Text(
                _calcErrorMessage!,
                style: TextStyle(color: DsColors.of(context).error),
              ),
            SizedBox(height: DsSpacing.sm),
            DsButton(
              label: "Calcular",
              isLoading: false,
              disabled: _patientState == null,
              onTap: _calculate,
            ),
            if (_minValue != null && _maxValue != null)
              Text(
                "Necessidade Proteica: ${_minValue!.toStringAsFixed(1)} – "
                "${_maxValue!.toStringAsFixed(1)} g/dia",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
          ],
        ),
        if (_minValue != null && _maxValue != null) ...[
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
                      .pop<GatheredProteinNeedsInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredProteinNeedsInputs?>((
                        patientState: _patientState!,
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
