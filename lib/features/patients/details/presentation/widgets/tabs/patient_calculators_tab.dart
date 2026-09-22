import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/bmi_calculator_relevance.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_definition.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_relevance_context.dart';
import 'package:nutri_calc/features/calculators/domain/entities/calculator_type_enum.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/domain/energy_expenditure_relevance.dart';
import 'package:nutri_calc/features/calculators/energy_expenditure/presentation/widgets/energy_expenditure_sheet_body.dart';
import 'package:nutri_calc/features/calculators/presentation/widgets/calculator_list.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

// Slice 2 scope (roadmap 2.1.4, ADR 0006): a relevance-filtered/See All
// calculator list, backed by a plain, non-injected CalculatorDefinition
// registry assembled here. Only BMI registers this slice; the remaining
// calculator types are deferred to later slices.
class PatientCalculatorsTab extends StatelessWidget {
  const PatientCalculatorsTab({super.key});

  String _classificationLabel(BmiClassification classification) {
    switch (classification) {
      case .low:
        return "Baixo peso";
      case .eutrophy:
        return "Eutrofia";
      case .overweight:
        return "Sobrepeso";
      case .obesity:
        return "Obesidade Grau I";
      case .obesityGrade2:
        return "Obesidade Grau II";
      case .obesityGrade3:
        return "Obesidade Grau III";
    }
  }

  Future<void> _openBmiBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    final bmi = state.bmi;

    if (bmi == null) {
      await DsBottomSheet.show<void>(
        context,
        title: "IMC",
        body: Text(
          "Não há dados suficientes para calcular o IMC. Cadastre ao menos um peso e uma altura para esse paciente.",
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: "Fechar",
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;
    final height = state.heights.first;
    final age = state.form.age;

    final confirmed = await DsBottomSheet.show<bool>(
      context,
      title: "IMC",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: DsSpacing.sm,
        children: [
          Text("Peso: ${weight.value} kg"),
          Text("Altura: ${height.value} cm"),
          Text("Idade: ${age ?? '-'}"),
          SizedBox(height: DsSpacing.sm),
          Text(
            "IMC: ${bmi.value.toStringAsFixed(2)} (${_classificationLabel(bmi.classification)})",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        Expanded(
          child: DsButton(
            label: "Cancelar",
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(false),
          ),
        ),
        Expanded(
          child: DsButton(
            label: "Confirmar",
            isLoading: false,
            onTap: () => getIt.get<AppRouter>().pop<bool>(true),
          ),
        ),
      ],
    );

    if (confirmed == true) {
      await cubit.saveBmiCalculation();
    }
  }

  Future<void> _openEnergyExpenditureBottomSheet(
    BuildContext context,
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) async {
    if (state.weights.isEmpty) {
      await DsBottomSheet.show<void>(
        context,
        title: "Gasto Energético",
        body: Text(
          "Não há dados suficientes para calcular o gasto energético. Cadastre ao menos um peso para esse paciente.",
        ),
        actions: [
          Expanded(
            child: DsButton(
              label: "Fechar",
              isLoading: false,
              onTap: () => getIt.get<AppRouter>().pop(),
            ),
          ),
        ],
      );
      return;
    }

    final weight = state.weights.first;
    final height = state.heights.isNotEmpty ? state.heights.first : null;
    final age = state.form.age;

    final gathered = await DsBottomSheet
        .show<GatheredEnergyExpenditureInputs?>(
          context,
          title: "Gasto Energético",
          body: EnergyExpenditureSheetBody(
            weightKg: weight.value,
            heightCm: height?.value,
            age: age,
          ),
          actions: null,
        );

    if (gathered != null) {
      await cubit.saveEnergyExpenditureCalculation(
        formula: gathered.formula,
        gender: gathered.gender,
        activityFactor: gathered.activityFactor,
        injuryFactor: gathered.injuryFactor,
        temperatureFactor: gathered.temperatureFactor,
        stressLevel: gathered.stressLevel,
      );
    }
  }

  List<CalculatorDefinition> _buildDefinitions(
    PatientDetailsCubit cubit,
    PatientDetailsStateLoaded state,
  ) {
    return [
      CalculatorDefinition(
        id: "bmi",
        type: CalculatorType.bmi,
        name: "IMC",
        isRelevant: isBmiRelevant,
        onTap: (ctx) => _openBmiBottomSheet(ctx, cubit, state),
      ),
      CalculatorDefinition(
        id: "energy_expenditure",
        type: CalculatorType.energyExpenditure,
        name: "Gasto Energético",
        isRelevant: isEnergyExpenditureRelevant,
        onTap: (ctx) => _openEnergyExpenditureBottomSheet(ctx, cubit, state),
      ),
    ];
  }

  CalculatorRelevanceContext _buildRelevanceContext(
    PatientDetailsStateLoaded state,
  ) {
    return CalculatorRelevanceContext(
      age: state.form.age,
      ageUnit: state.form.ageUnit,
      enteralNutrition: state.form.enteralNutrition,
      parenteralNutrition: state.form.parenteralNutrition,
      hospitalized: state.form.hospitalized,
      confinedToBed: state.form.confinedToBed,
      weights: state.weights,
      bmi: state.bmi,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        return CalculatorList(
          definitions: _buildDefinitions(cubit, state),
          relevanceContext: _buildRelevanceContext(state),
        );
      },
    );
  }
}
