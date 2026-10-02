import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_text_styles.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_textfield/ds_textfield.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/nitrogen/calculate_nitrogen_balance.usecase.dart';

/// Both inputs are fully manual (roadmap 3.1: Nitrogen Balance has no
/// patient-data derivation) - the gathered values, popped whole via
/// `AppRouter.pop` on "Confirmar", so the tab can read them back directly.
typedef GatheredNitrogenBalanceInputs = ({
  double ingestedProtein,
  double urineNitrogen24h,
});

class NitrogenBalanceSheetBody extends StatefulWidget {
  const NitrogenBalanceSheetBody({super.key});

  @override
  State<NitrogenBalanceSheetBody> createState() =>
      _NitrogenBalanceSheetBodyState();
}

class _NitrogenBalanceSheetBodyState extends State<NitrogenBalanceSheetBody> {
  double? _ingestedProtein;
  double? _urineNitrogen24h;

  String? _calcErrorMessage;
  double? _resultValue;

  String? get _validationMessage {
    if (_ingestedProtein == null || _urineNitrogen24h == null) {
      return "Preencha os dois campos.";
    }
    if (_ingestedProtein! < 0 || _urineNitrogen24h! < 0) {
      return "Os valores precisam ser maiores ou iguais a zero.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    final res = CalculateNitrogenBalance().call(
      ingestedProtein: _ingestedProtein!,
      urineNitrogen24h: _urineNitrogen24h!,
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o balanço nitrogenado.";
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
              "Balanço Nitrogenado",
              style: DsTextStyles.sectionHeader,
            ),
            DsTextfield(
              label: "Proteína Ingerida (g)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _ingestedProtein = double.tryParse(value);
                _resultValue = null;
              }),
            ),
            DsTextfield(
              label: "Nitrogênio Urinário 24h (g)",
              type: TextInputType.number,
              onChange: (value) => setState(() {
                _urineNitrogen24h = double.tryParse(value);
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
                "Balanço Nitrogenado: ${_resultValue!.toStringAsFixed(2)} g/dia",
                style: DsTextStyles.resultBold,
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
                      .pop<GatheredNitrogenBalanceInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () => getIt
                      .get<AppRouter>()
                      .pop<GatheredNitrogenBalanceInputs?>((
                        ingestedProtein: _ingestedProtein!,
                        urineNitrogen24h: _urineNitrogen24h!,
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
