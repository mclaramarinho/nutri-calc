import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_spacing.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';

// Slice 1 scope (roadmap 2.1.4, "Slice 1 scope" note, 2026-09-19): a single
// tappable "IMC" entry point, in place of the full relevant/all-calculators
// list — relevance filtering and the remaining ~12 calculator types are
// explicitly deferred to later slices.
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientDetailsCubit, PatientDetailsState>(
      builder: (context, state) {
        if (state is! PatientDetailsStateLoaded) {
          return CircularProgressIndicator();
        }

        final cubit = context.read<PatientDetailsCubit>();

        return DsListTile(
          title: "IMC",
          onTap: () => _openBmiBottomSheet(context, cubit, state),
        );
      },
    );
  }
}
