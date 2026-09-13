import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutri_calc/shared/design_system/utils/ds_screen_adapter.dart';
import 'package:nutri_calc/shared/design_system/widgets/ds_list_tile/ds_list_tile.dart';

/// Pumps a bare [MaterialApp] hosting a single [DsListTile], initializing
/// [DsScreenAdapter] first (`DsSpacing`'s `.w` extension throws
/// `LateInitializationError` otherwise - same pattern as
/// `ds_checkbox_test.dart`).
Future<void> _pumpTile(
  WidgetTester tester, {
  required String title,
  String? overline,
  String? subtitle,
  Widget? leading,
  Widget? trailing,
  VoidCallback? onTap,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) {
          DsScreenAdapter.init(context);
          return Scaffold(
            body: DsListTile(
              title: title,
              overline: overline,
              subtitle: subtitle,
              leading: leading,
              trailing: trailing,
              onTap: onTap,
            ),
          );
        },
      ),
    ),
  );
}

void main() {
  group('DsListTile', () {
    testWidgets('title always renders', (tester) async {
      await _pumpTile(tester, title: 'Ana Silva');

      expect(find.text('Ana Silva'), findsOneWidget);
    });

    testWidgets('overline renders when provided', (tester) async {
      await _pumpTile(tester, title: 'Ana Silva', overline: '#12345');

      expect(find.text('#12345'), findsOneWidget);
    });

    testWidgets('overline is absent when not provided', (tester) async {
      await _pumpTile(tester, title: 'Ana Silva');

      expect(find.text('#12345'), findsNothing);
    });

    testWidgets('subtitle renders when provided', (tester) async {
      await _pumpTile(tester, title: 'Ana Silva', subtitle: '32 anos');

      expect(find.text('32 anos'), findsOneWidget);
    });

    testWidgets('subtitle is absent when not provided', (tester) async {
      await _pumpTile(tester, title: 'Ana Silva');

      expect(find.text('32 anos'), findsNothing);
    });

    testWidgets('leading renders when provided', (tester) async {
      await _pumpTile(
        tester,
        title: 'Ana Silva',
        leading: const Icon(Icons.person),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('trailing renders when provided', (tester) async {
      await _pumpTile(
        tester,
        title: 'Ana Silva',
        trailing: const Icon(Icons.chevron_right),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets(
      'no onTap provided: renders without an InkWell and tapping is a '
      'safe no-op',
      (tester) async {
        await _pumpTile(tester, title: 'Ana Silva');

        expect(find.byType(InkWell), findsNothing);

        await tester.tap(find.text('Ana Silva'));
        await tester.pump();
      },
    );

    testWidgets('tapping fires onTap when provided', (tester) async {
      var tapped = false;
      await _pumpTile(
        tester,
        title: 'Ana Silva',
        onTap: () => tapped = true,
      );

      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
