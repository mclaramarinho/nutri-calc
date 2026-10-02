import 'package:flutter/material.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_colors.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_checkbox/ds_checkbox.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/screening/strong_kids/strong_kids_result.entity.dart';
import 'package:nutri_calc/shared/services/calculator/domain/use_cases/screening/strong_kids/calculate_strong_kids_score.usecase.dart';

/// All 4 questions are fully manual - the gathered raw boolean answers,
/// popped whole via `AppRouter.pop` on "Confirmar", so the tab/cubit can
/// read them back directly and do the point mapping at the save call site
/// (mirrors `GatheredNitrogenBalanceInputs`).
typedef GatheredStrongKidsInputs = ({
  bool clinicalAppearanceOfMalnutrition,
  bool highRiskDiseasePresent,
  bool reducedIntakeOrLosses,
  bool weightLossOrGrowthDeficit,
});

class StrongKidsSheetBody extends StatefulWidget {
  const StrongKidsSheetBody({super.key});

  @override
  State<StrongKidsSheetBody> createState() => _StrongKidsSheetBodyState();
}

class _StrongKidsSheetBodyState extends State<StrongKidsSheetBody> {
  // RESOLVED UX decision (senior-analyst/po): unlike MUST's numeric-only
  // gating, all 4 questions here use a nullable `bool?` and must be
  // explicitly tapped at least once before "Calcular" enables. A silent
  // untouched-defaults-to-"Baixo risco" result is a more consequential
  // silent-failure mode for a pediatric risk screen than a missing numeric
  // field would be elsewhere, so this tool intentionally gates on
  // "answered", not just "valid".
  bool? _q1;
  bool? _q2;
  bool? _q3;
  bool? _q4;

  String? _calcErrorMessage;
  StrongkidsResult? _result;

  String? get _validationMessage {
    if (_q1 == null || _q2 == null || _q3 == null || _q4 == null) {
      return "Responda todas as perguntas.";
    }
    return null;
  }

  void _calculate() {
    final validation = _validationMessage;
    if (validation != null) return;

    // Point mapping: q1/q2 are worth 2 points each, q3/q4 are worth 1 point
    // each - mirrors `SaveStrongKidsCalculationUseCase`'s mapping.
    final res = CalculateStrongKidsScore().call(
      stepsResponsesInOrder: [
        _q1! ? 2 : 0,
        _q2! ? 2 : 0,
        _q3! ? 1 : 0,
        _q4! ? 1 : 0,
      ],
    );

    if (res.isError) {
      setState(() {
        _calcErrorMessage = "Não foi possível calcular o STRONG-Kids.";
      });
      return;
    }

    setState(() {
      _calcErrorMessage = null;
      _result = (res as Ok<StrongkidsResult, String>).value;
    });
  }

  String _classificationLabel(StrongkidsResult result) {
    switch (result.classification) {
      case .low:
        return "Baixo risco";
      case .medium:
        return "Risco médio";
      case .highRisk:
        return "Alto risco";
    }
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
              "STRONG-Kids — Triagem de Risco Nutricional Pediátrica",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            DsCheckbox(
              label: "Aparência clínica sugestiva de desnutrição?",
              helperText:
                  "Ex.: magreza, tecido adiposo/muscular diminuído, face encovada",
              value: _q1 ?? false,
              onChanged: (value) => setState(() {
                _q1 = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label: "Presença de doença de alto risco?",
              helperText:
                  "Ex.: grande cirurgia, doença cardíaca congênita, prematuridade",
              value: _q2 ?? false,
              onChanged: (value) => setState(() {
                _q2 = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label:
                  "Ingestão alimentar reduzida ou perdas (vômitos/diarreia) "
                  "nos últimos dias, ou ingestão reduzida antes da internação?",
              value: _q3 ?? false,
              onChanged: (value) => setState(() {
                _q3 = value;
                _result = null;
              }),
            ),
            DsCheckbox(
              label:
                  "Houve perda de peso ou déficit de crescimento (peso/altura) "
                  "nas últimas semanas/meses?",
              value: _q4 ?? false,
              onChanged: (value) => setState(() {
                _q4 = value;
                _result = null;
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
            if (_result != null)
              Text(
                "STRONG-Kids: ${_result!.score} (${_classificationLabel(_result!)})",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
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
                      .pop<GatheredStrongKidsInputs?>(null),
                ),
              ),
              Expanded(
                child: DsButton(
                  label: "Confirmar",
                  isLoading: false,
                  onTap: () =>
                      getIt.get<AppRouter>().pop<GatheredStrongKidsInputs?>((
                        clinicalAppearanceOfMalnutrition: _q1!,
                        highRiskDiseasePresent: _q2!,
                        reducedIntakeOrLosses: _q3!,
                        weightLossOrGrowthDeficit: _q4!,
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
