import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/di/di.dart';
import 'package:nutri_calc/routing/app_router.dart';
import 'package:nutri_calc/routing/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_calc/shared/design_system/tokens/ds_typography.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_bottom_sheet/ds_bottom_sheet.dart';

/// Minimal fake [AppRouter] used only to exercise the `pop<T>([T? result])`
/// dismiss path from within a bottom-sheet action button, without depending
/// on a real [GoRouter]/navigator-key setup. It pops whatever [Navigator] is
/// reachable from the [navigatorKey] supplied by the test, mirroring what
/// [AppRouterImpl.pop] does against its own root navigator.
class _FakeAppRouter implements AppRouter {
  _FakeAppRouter(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  @override
  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop(result);
  }

  @override
  GoRouter get router => throw UnimplementedError();

  @override
  BuildContext? get context => navigatorKey.currentContext;

  @override
  AppRoutes? get currentRoute => throw UnimplementedError();

  @override
  Object? get params => throw UnimplementedError();

  @override
  void push(AppRoutes route, {Map<String, dynamic>? params}) =>
      throw UnimplementedError();

  @override
  void replace(AppRoutes route, {Map<String, dynamic>? params}) =>
      throw UnimplementedError();
}

/// A [Container] matching the drag-handle pill's fixed dimensions
/// (40x4, see `_DsBottomSheetWidget`).
final Finder _dragHandleFinder = find.byWidgetPredicate((widget) {
  if (widget is! Container) return false;
  final constraints = widget.constraints;
  return constraints != null &&
      constraints.maxWidth == 40 &&
      constraints.maxHeight == 4;
});

/// A [Text] styled like the bottom sheet's title (bold + `DsTypography.large`).
Finder _titleStyledTextFinder() => find.byWidgetPredicate((widget) {
  if (widget is! Text) return false;
  final style = widget.style;
  return style != null &&
      style.fontWeight == FontWeight.w700 &&
      style.fontSize == DsTypography.large;
});

/// Pumps a bare [MaterialApp] with a single "Open" button wired to [onOpen],
/// initializing [DsScreenAdapter] first (mirrors what `DsScaffold` does in
/// production; `DsSpacing` getters used inside `DsBottomSheet` throw
/// `LateInitializationError` otherwise).
Future<void> _pumpOpener(
  WidgetTester tester,
  void Function(BuildContext context) onOpen, {
  GlobalKey<NavigatorState>? navigatorKey,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () => onOpen(context),
                  child: const Text('Open'),
                );
              },
            ),
          );
        },
      ),
    ),
  );
}

/// Force-closes whatever sheet/route is open on top of the root [Navigator],
/// bypassing `isDismissible`. `DsBottomSheet`'s single-instance guard
/// (`_inFlight`) is a *static* field, so a sheet left open at the end of one
/// test would otherwise leak into the next `testWidgets` in this file (same
/// isolate) and make its `show()` call silently return the stale in-flight
/// future instead of opening a new sheet.
Future<void> _closeOpenSheet(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  if (navigator.canPop()) {
    navigator.pop();
  }
  await tester.pumpAndSettle();
}

void main() {
  group('DsBottomSheet', () {
    testWidgets('shows the title and body content when both are provided', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(
          context,
          title: 'My Title',
          body: const Text('My Body'),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('My Title'), findsOneWidget);
      expect(find.text('My Body'), findsOneWidget);

      await _closeOpenSheet(tester);
    });

    testWidgets('omits the title from the tree when title is null', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(context, body: const Text('Body Only')),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Body Only'), findsOneWidget);
      expect(_titleStyledTextFinder(), findsNothing);

      await _closeOpenSheet(tester);
    });

    testWidgets('renders the actions row and a Divider when actions are provided', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(
          context,
          body: const Text('Body'),
          actions: [
            ElevatedButton(onPressed: () {}, child: const Text('Action 1')),
          ],
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Action 1'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      await _closeOpenSheet(tester);
    });

    testWidgets('omits the actions row and the Divider when actions is null', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(context, body: const Text('Body')),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(Divider), findsNothing);

      await _closeOpenSheet(tester);
    });

    testWidgets('renders the drag handle when enableDrag is true', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(
          context,
          body: const Text('Body'),
          enableDrag: true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(_dragHandleFinder, findsOneWidget);

      await _closeOpenSheet(tester);
    });

    testWidgets('omits the drag handle when enableDrag is false', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(
          context,
          body: const Text('Body'),
          enableDrag: false,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(_dragHandleFinder, findsNothing);

      await _closeOpenSheet(tester);
    });

    testWidgets('dismisses on tap-outside when isDismissible is true', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => DsBottomSheet.show(
          context,
          body: const Text('Dismissible Body'),
          isDismissible: true,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Dismissible Body'), findsOneWidget);

      // Tap the barrier, well above where the (bottom-anchored) sheet is laid
      // out.
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Dismissible Body'), findsNothing);
    });

    testWidgets(
      'does NOT dismiss on tap-outside when isDismissible is false',
      (tester) async {
        await _pumpOpener(
          tester,
          (context) => DsBottomSheet.show(
            context,
            body: const Text('Non Dismissible Body'),
            isDismissible: false,
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Non Dismissible Body'), findsOneWidget);

        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(find.text('Non Dismissible Body'), findsOneWidget);

        await _closeOpenSheet(tester);
      },
    );

    testWidgets(
      'resolves show() with the value passed to AppRouter.pop from an action',
      (tester) async {
        final navigatorKey = GlobalKey<NavigatorState>();
        getIt.registerSingleton<AppRouter>(_FakeAppRouter(navigatorKey));
        addTearDown(() => getIt.unregister<AppRouter>());

        String? result;

        await _pumpOpener(tester, (context) {
          DsBottomSheet.show<String>(
            context,
            body: const Text('Body'),
            actions: [
              ElevatedButton(
                onPressed: () => getIt.get<AppRouter>().pop('confirmed'),
                child: const Text('Confirm'),
              ),
            ],
          ).then((value) => result = value);
        }, navigatorKey: navigatorKey);

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(result, 'confirmed');
        expect(find.text('Body'), findsNothing);
      },
    );

    testWidgets(
      'a second concurrent show() call does not stack a second sheet instance '
      'and resolves immediately with null instead of aliasing the first call',
      (tester) async {
        String? secondResult = 'not yet resolved';

        await _pumpOpener(tester, (context) {
          DsBottomSheet.show<String>(context, body: const Text('First Sheet'));
          DsBottomSheet.show<String>(
            context,
            body: const Text('Second Sheet'),
          ).then((value) => secondResult = value);
        });

        await tester.tap(find.text('Open'));
        await tester.pump();

        // The second, unrelated concurrent call resolves synchronously with
        // null rather than aliasing/casting the first call's typed future
        // (which would throw for mismatched type arguments).
        expect(secondResult, isNull);

        await tester.pumpAndSettle();

        expect(find.text('First Sheet'), findsOneWidget);
        expect(find.text('Second Sheet'), findsNothing);

        await _closeOpenSheet(tester);
      },
    );

    testWidgets(
      'a second concurrent show<T>() call with a different type argument than '
      'the first in-flight call does not throw a cast error',
      (tester) async {
        await _pumpOpener(tester, (context) {
          DsBottomSheet.show<int>(context, body: const Text('First Sheet'));
          // Different type argument than the first call above: this used to
          // crash with a `type cast` error when the guard aliased the first
          // call's typed Future.
          DsBottomSheet.show<String>(context, body: const Text('Second Sheet'));
        });

        await tester.tap(find.text('Open'));

        expect(tester.takeException(), isNull);

        await tester.pumpAndSettle();

        expect(find.text('First Sheet'), findsOneWidget);
        expect(find.text('Second Sheet'), findsNothing);

        await _closeOpenSheet(tester);
      },
    );
  });
}
