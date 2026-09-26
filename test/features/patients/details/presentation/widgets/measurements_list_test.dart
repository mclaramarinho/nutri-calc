import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/core/utils/result/result.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/features/patients/details/presentation/widgets/measurements_list.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';

/// Pops via the Navigator wired to [navigatorKey], mirroring the fake used in
/// patient_history_tab_test.dart - needed so `DsDialog.show`'s
/// `getIt.get<AppRouter>().pop()` calls actually close the dialogs raised by
/// `DsDismissibleTile`'s confirm/success/error choreography (ADR 0010).
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
  final navigatorKey = GlobalKey<NavigatorState>();

  setUp(() {
    getIt.registerSingleton<AppRouter>(_FakeAppRouter(navigatorKey));
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget wrap(Widget child) => MaterialApp(
    navigatorKey: navigatorKey,
    home: Builder(
      builder: (context) {
        DsScreenAdapter.init(context);
        return Scaffold(body: Column(children: [child]));
      },
    ),
  );

  group('MeasurementsList DsDismissibleTile retrofit (ADR 0010)', () {
    testWidgets(
      'swiping an item shows the confirm dialog and, on confirm, invokes '
      'onDelete with the item id',
      (tester) async {
        final deletedIds = <String>[];

        await tester.pumpWidget(
          wrap(
            MeasurementsList(
              dataList: [
                MeasurementsListItem(
                  id: 'w1',
                  value: '70.0 kg',
                  createdAt: DateTime(2026, 1, 1),
                ),
              ],
              onDelete: (id) async {
                deletedIds.add(id);
                return const Ok(null);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Dismissible), findsOneWidget);

        // Swipe end-to-start to trigger the delete confirmation dialog.
        await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
        await tester.pumpAndSettle();

        expect(find.text('Excluir'), findsWidgets);
        expect(
          find.text('Deseja realmente excluir esta medida?'),
          findsOneWidget,
        );
        expect(deletedIds, isEmpty);

        // Confirm the deletion.
        await tester.tap(find.text('Excluir').last);
        await tester.pumpAndSettle();

        expect(deletedIds, ['w1']);
        expect(find.text('Excluído com sucesso.'), findsOneWidget);

        // The success dialog auto-dismisses after 2s (see DsDialog.show's
        // `duration` handling).
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'cancelling the confirm dialog does not invoke onDelete',
      (tester) async {
        final deletedIds = <String>[];

        await tester.pumpWidget(
          wrap(
            MeasurementsList(
              dataList: [
                MeasurementsListItem(
                  id: 'w1',
                  value: '70.0 kg',
                  createdAt: DateTime(2026, 1, 1),
                ),
              ],
              onDelete: (id) async {
                deletedIds.add(id);
                return const Ok(null);
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.drag(find.byType(Dismissible), const Offset(-500, 0));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancelar'));
        await tester.pumpAndSettle();

        expect(deletedIds, isEmpty);
        expect(find.byType(Dismissible), findsOneWidget);
      },
    );
  });
}
