import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/entities/bmi_calculation_entity.dart';
import 'package:nutri_calc/features/calculators/bmi/domain/use_cases/save_bmi_calculation_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/entities/body_measurement_entity.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/create_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/body_measurement/domain/use_cases/get_body_measurement_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/entities/height_entity.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/create_height_use_case.dart';
import 'package:nutri_calc/features/measurements/height/domain/use_cases/get_heights_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_entity.dart';
import 'package:nutri_calc/features/measurements/weight/domain/entities/weight_type_enum.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/create_weight_use_case.dart';
import 'package:nutri_calc/features/measurements/weight/domain/use_cases/get_weights_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/entities/edit_patient_form_entity.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/load_patient_details_use_case.dart';
import 'package:nutri_calc/features/patients/details/domain/use_cases/update_patient_use_case.dart';
import 'package:nutri_calc/features/patients/details/presentation/cubit/patient_details_state.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/tabs/patient_calculators_tab.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/services/calculator/domain/entities/bmi/bmi_classification.enum.dart';
import 'package:go_router/go_router.dart';

/// Fakes implementing the abstract use-case interfaces directly - no mocking
/// package is set up in this project, matching patient_details_cubit_test.dart.
class _FakeLoadPatientDetailsUseCase implements LoadPatientDetailsUseCase {
  EditPatientFormEntity? formToReturn;

  @override
  Future<Result<EditPatientFormEntity, String>> call(
    String patientLocalId,
  ) async {
    return Ok(
      formToReturn ??
          EditPatientFormEntity(
            firstName: "Ana",
            lastName: "Silva",
            patientLocalId: patientLocalId,
          ),
    );
  }
}

class _FakeUpdatePatientUseCase implements UpdatePatientUseCase {
  @override
  Future<Result<void, String>> call(EditPatientFormEntity form) async =>
      Ok(null);
}

class _FakeGetWeightsUseCase implements GetWeightsUseCase {
  List<WeightEntity> weightsToReturn = [];

  @override
  Future<Result<List<WeightEntity>, String>> call(String patientId) async =>
      Ok(weightsToReturn);
}

class _FakeGetHeightsUseCase implements GetHeightsUseCase {
  List<HeightEntity> heightsToReturn = [];

  @override
  Future<Result<List<HeightEntity>, String>> call(String patientId) async =>
      Ok(heightsToReturn);
}

class _FakeGetBodyMeasurementUseCase implements GetBodyMeasurementUseCase {
  @override
  Future<Result<List<BodyMeasurementEntity>, String>> call(
    String patientId,
  ) async => Ok(const []);
}

class _FakeCreateWeightUseCase implements CreateWeightUseCase {
  @override
  Future<Result<WeightEntity, String>> call({
    required WeightEntity weight,
  }) async => Ok(weight);
}

class _FakeCreateHeightUseCase implements CreateHeightUseCase {
  @override
  Future<Result<HeightEntity, String>> call({
    required HeightEntity height,
  }) async => Ok(height);
}

class _FakeCreateBodyMeasurementUseCase
    implements CreateBodyMeasurementUseCase {
  @override
  Future<Result<BodyMeasurementEntity, String>> call(
    BodyMeasurementEntity entity,
  ) async => Ok(entity);
}

class _FakeSaveBmiCalculationUseCase implements SaveBmiCalculationUseCase {
  int callCount = 0;

  @override
  Future<Result<BmiCalculationEntity, String>> call({
    required String patientId,
    required double weightKg,
    required double heightM,
    required int age,
  }) async {
    callCount++;
    return Ok(
      BmiCalculationEntity(
        id: 'bmi-1',
        patientId: patientId,
        value: weightKg / (heightM * heightM),
        classification: BmiClassification.eutrophy,
        createdAt: DateTime.now(),
        inputParams: const [],
      ),
    );
  }
}

/// Pops via the Navigator wired to [navigatorKey], mirroring how a real
/// GoRouter-backed AppRouter.pop() closes the DsBottomSheet's modal route -
/// needed so DsBottomSheet.show's returned Future actually resolves in tests.
class _FakeAppRouter implements AppRouter {
  _FakeAppRouter(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  @override
  BuildContext? get context => navigatorKey.currentContext;

  @override
  AppRoutes? get currentRoute => null;

  @override
  Object? get params => null;

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  GoRouter get router => throw UnimplementedError();
}

void main() {
  const patientId = "local-id-1";

  late _FakeLoadPatientDetailsUseCase fakeLoad;
  late _FakeGetWeightsUseCase fakeGetWeights;
  late _FakeGetHeightsUseCase fakeGetHeights;
  late _FakeSaveBmiCalculationUseCase fakeSaveBmiCalculation;
  late PatientDetailsCubit cubit;
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    fakeLoad = _FakeLoadPatientDetailsUseCase();
    fakeGetWeights = _FakeGetWeightsUseCase();
    fakeGetHeights = _FakeGetHeightsUseCase();
    fakeSaveBmiCalculation = _FakeSaveBmiCalculationUseCase();

    cubit = PatientDetailsCubit(
      loadPatientDetailsUseCase: fakeLoad,
      updatePatientUseCase: _FakeUpdatePatientUseCase(),
      createWeightUseCase: _FakeCreateWeightUseCase(),
      getWeightsUseCase: fakeGetWeights,
      createHeightUseCase: _FakeCreateHeightUseCase(),
      getHeightsUseCase: fakeGetHeights,
      createBodyMeasurementUseCase: _FakeCreateBodyMeasurementUseCase(),
      getBodyMeasurementUseCase: _FakeGetBodyMeasurementUseCase(),
      saveBmiCalculationUseCase: fakeSaveBmiCalculation,
    );

    getIt.registerSingleton<AppRouter>(_FakeAppRouter(navigatorKey));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap() => MaterialApp(
    navigatorKey: navigatorKey,
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: const PatientCalculatorsTab(),
          ),
        );
      },
    ),
  );

  group('PatientCalculatorsTab', () {
    testWidgets(
      'BMI tap-flow regression: insufficient data shows message and does '
      'not call saveBmiCalculation',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        fakeGetWeights.weightsToReturn = [];
        fakeGetHeights.heightsToReturn = [];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            "Não há dados suficientes para calcular o IMC. Cadastre ao "
            "menos um peso e uma altura para esse paciente.",
          ),
          findsOneWidget,
        );

        await tester.tap(find.text('Fechar'));
        await tester.pumpAndSettle();

        expect(fakeSaveBmiCalculation.callCount, 0);
      },
    );

    testWidgets(
      'BMI tap-flow regression: preview shown, Confirmar calls '
      'cubit.saveBmiCalculation()',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        fakeGetWeights.weightsToReturn = [
          WeightEntity(
            createdAt: DateTime.now(),
            value: 70,
            patientId: patientId,
            considerForCalculations: true,
            weightType: WeightTypeEnum.measuredByScale,
          ),
        ];
        fakeGetHeights.heightsToReturn = [
          HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
        ];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);

        await tester.tap(find.text('Confirmar'));
        await tester.pump();
        // Flush the 2s isBmiSaved auto-reset delay in
        // PatientDetailsCubit.saveBmiCalculation so no pending Timer leaks
        // past the end of the test.
        await tester.pump(const Duration(seconds: 3));

        expect(fakeSaveBmiCalculation.callCount, 1);
      },
    );

    testWidgets(
      'age < 19 with only BMI registered -> empty relevant list, toggle '
      'reveals IMC under its group header',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 10,
        );
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.text('Nenhuma calculadora relevante no momento.'),
          findsOneWidget,
        );
        expect(find.byType(DsListTile), findsNothing);

        await tester.tap(find.byType(DsButton));
        await tester.pumpAndSettle();

        // "IMC" is both the group header (CalculatorType.bmi.label) and the
        // tile title (the definition's name) - genuine collision, not a
        // test bug.
        expect(find.text('IMC'), findsNWidgets(2));
        expect(find.byType(DsListTile), findsOneWidget);
      },
    );

    testWidgets(
      'age 25+ with weight/height -> BMI shown directly in flat view, tap '
      'still works',
      (tester) async {
        fakeLoad.formToReturn = EditPatientFormEntity(
          firstName: "Ana",
          lastName: "Silva",
          patientLocalId: patientId,
          age: 25,
        );
        fakeGetWeights.weightsToReturn = [
          WeightEntity(
            createdAt: DateTime.now(),
            value: 70,
            patientId: patientId,
            considerForCalculations: true,
            weightType: WeightTypeEnum.measuredByScale,
          ),
        ];
        fakeGetHeights.heightsToReturn = [
          HeightEntity(createdAt: DateTime.now(), value: 175, patientId: patientId),
        ];
        await cubit.init(patientId);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.byType(DsListTile), findsOneWidget);
        expect(find.text('IMC'), findsOneWidget);

        await tester.tap(find.text('IMC'));
        await tester.pumpAndSettle();

        expect(find.text('Cancelar'), findsOneWidget);
        expect(find.text('Confirmar'), findsOneWidget);
      },
    );
  });
}
