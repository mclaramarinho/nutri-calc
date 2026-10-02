import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/l10n/generated/app_localizations.dart';
import 'package:nutri_calc/features/patients/list/domain/entities/patient_list_card_entity.dart';
import 'package:nutri_calc/features/patients/list/domain/use_cases/get_patients_list_use_case.dart';
import 'package:nutri_calc/features/patients/list/presentation/cubit/list_patients_cubit.dart';
import 'package:nutri_calc/features/patients/list/presentation/pages/list_patients_page.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_button/ds_button.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_loading_indicator/ds_loading_indicator.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_placeholder/ds_placeholder.dart';
import 'package:nutri_calc/shared/utils/enums/time_unit.dart';

/// Minimal fake - no mocking package is set up in this project (see
/// `new_patient_cubit_test.dart`).
class _FakeGetPatientsListUseCase implements GetPatientsListUseCase {
  _FakeGetPatientsListUseCase(this._results);

  final List<Result<List<PatientListCardEntity>, String>> _results;
  int callCount = 0;

  @override
  Future<Result<List<PatientListCardEntity>, String>> call() async {
    final result = _results[callCount.clamp(0, _results.length - 1)];
    callCount++;
    return result;
  }
}

class _FakeAppRouter implements AppRouter {
  AppRoutes? pushedRoute;
  Map<String, dynamic>? pushedParams;

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) {
    pushedRoute = route;
    pushedParams = params;
  }

  @override
  BuildContext? get context => null;

  @override
  AppRoutes? get currentRoute => null;

  @override
  Object? get params => null;

  @override
  void pop<T extends Object?>([T? result]) {}

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) {}

  @override
  GoRouter get router => throw UnimplementedError();
}

void main() {
  late _FakeGetPatientsListUseCase fakeUseCase;
  late _FakeAppRouter fakeRouter;

  void registerFakes(
    List<Result<List<PatientListCardEntity>, String>> results,
  ) {
    fakeUseCase = _FakeGetPatientsListUseCase(results);
    fakeRouter = _FakeAppRouter();
    getIt.registerFactory<GetPatientsListUseCase>(() => fakeUseCase);
    getIt.registerFactory<ListPatientsCubit>(
      () => ListPatientsCubit(
        getPatientsListUseCase: getIt.get<GetPatientsListUseCase>(),
      ),
    );
    getIt.registerSingleton<AppRouter>(fakeRouter);
  }

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return const Scaffold(body: ListPatientsPage());
      },
    ),
  );

  group('ListPatientsPage', () {
    testWidgets('loading state renders DsLoadingIndicator', (tester) async {
      registerFakes([Ok(const [])]);

      await tester.pumpWidget(wrap());

      expect(find.byType(DsLoadingIndicator), findsOneWidget);
    });

    testWidgets(
      'empty result renders DsPlaceholder with empty-state copy and no '
      'DsListTile',
      (tester) async {
        registerFakes([Ok(const [])]);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.byType(DsPlaceholder), findsOneWidget);
        expect(
          find.text('Você ainda não tem pacientes cadastrados'),
          findsOneWidget,
        );
        expect(find.byType(DsListTile), findsNothing);
      },
    );

    testWidgets(
      'populated result renders one DsListTile per patient, overline only '
      'when patientId is present, and tapping navigates via AppRouter',
      (tester) async {
        registerFakes([
          Ok([
            const PatientListCardEntity(
              firstName: 'Ana',
              lastName: 'Silva',
              localId: 'local-1',
              patientId: 'PID-1',
              age: 32,
              ageUnit: TimeUnit.year,
            ),
            const PatientListCardEntity(
              firstName: 'Bruno',
              lastName: 'Souza',
              localId: 'local-2',
            ),
          ]),
        ]);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(find.byType(DsListTile), findsNWidgets(2));
        expect(find.text('Ana Silva'), findsOneWidget);
        expect(find.text('Bruno Souza'), findsOneWidget);
        expect(find.text('PID-1'), findsOneWidget);
        expect(find.text('32 ano(s)'), findsOneWidget);
        expect(find.text('Idade não informada'), findsOneWidget);

        await tester.tap(find.text('Ana Silva'));
        await tester.pumpAndSettle();

        expect(fakeRouter.pushedRoute, AppRoutes.patientDetails);
        expect(fakeRouter.pushedParams, {'patientId': 'local-1'});
      },
    );

    testWidgets(
      'error result renders DsPlaceholder with error copy and a '
      '"Tentar novamente" DsButton that re-invokes the use case on tap',
      (tester) async {
        registerFakes([
          Error('boom'),
          Ok([
            const PatientListCardEntity(
              firstName: 'Ana',
              lastName: 'Silva',
              localId: 'local-1',
            ),
          ]),
        ]);

        await tester.pumpWidget(wrap());
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível carregar seus pacientes'),
          findsOneWidget,
        );
        expect(find.text('Tentar novamente'), findsOneWidget);
        expect(fakeUseCase.callCount, 1);

        await tester.tap(find.byType(DsButton));
        await tester.pumpAndSettle();

        expect(fakeUseCase.callCount, 2);
        expect(find.byType(DsListTile), findsOneWidget);
        expect(find.text('Ana Silva'), findsOneWidget);
      },
    );
  });
}
